unit fhir_healthcard;

{
Copyright (c) 2001-2021, Health Intersections Pty Ltd (http://www.healthintersections.com.au)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of HL7 nor the names of its contributors may be used to
   endorse or promote products derived from this software without specific
   prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
}

{$i fhir.inc}

interface

uses
  SysUtils, Classes, DateUtils,
  fsl_base, fsl_utilities, fsl_http, fsl_crypto, fsl_json, fsl_fetcher,
  fhir_objects, fhir_factory, fhir_parser, fhir_utilities;

type
  { THealthcareCardUtilities }

  THealthcareCardUtilities = class (TFslObject)
  private
    FFactory: TFHIRFactory;
    FJWKList: TJWKList;
    procedure SetFactory(const Value: TFHIRFactory);
    function buildPayload(card : THealthcareCard) : String;
    function readCredential(code : String) : TCredentialType;
    procedure SetJWKList(AValue: TJWKList);
    procedure findKey (jwt : TJWT);
  public
    destructor Destroy; override;

    { also packs as well - output in card.jws }
    procedure sign(card : THealthcareCard; jwk : TJWK);

    { unpacks, and verifies, and sets isValid to true }
    function verify(token : String) : THealthcareCard;

    class function readQR(src : String) : String; // returns a JWS

    property Factory : TFHIRFactory read FFactory write SetFactory;
    property JWKList : TJWKList read FJWKList write SetJWKList;
  end;

implementation

{ THealthcareCardUtilities }

destructor THealthcareCardUtilities.Destroy;
begin
  FJWKList.Free;
  FFactory.Free;
  inherited;
end;

procedure THealthcareCardUtilities.SetFactory(const Value: TFHIRFactory);
begin
  FFactory.Free;
  FFactory := Value;
end;

function THealthcareCardUtilities.buildPayload(card: THealthcareCard): String;
var
  json : TFHIRComposer;
begin
  result := '{"iss":"'+card.Issuer+'",'+
     '"nbf":'+IntToStr(SecondsBetween(card.IssueDate.DateTime, EncodeDate(1970, 1, 1)))+','+
     '"vc":{'+
      '"type":["https://smarthealth.cards#health-card"';
  if ctCovidCard in card.types then
    result := result + ',"https://smarthealth.cards#covid19"';
  if ctImmunizationCard in card.types then
    result := result + ',"https://smarthealth.cards#immunization"';
  if ctLabCard in card.types then
    result := result + ',"https://smarthealth.cards#laboratory"';
  result := result + '],"credentialSubject":{'+
     '"fhirVersion":"4.0.1",'+
     '"fhirBundle":';
  json := FFactory.makeComposer(nil, ffJson, defLang, OutputStyleNormal);
  try
    result := result + json.Compose(card.bundle);
  finally
    json.Free;
  end;
  result := result + '}}}';
end;

function THealthcareCardUtilities.readCredential(code: String): TCredentialType;
begin
  if (code = 'https://smarthealth.cards#health-card') then
    result := ctHealthCard
  else if (code = 'https://smarthealth.cards#covid19') then
    result := ctCovidCard
  else if (code = 'https://smarthealth.cards#immunization') then
    result := ctImmunizationCard
  else if (code = 'https://smarthealth.cards#laboratory') then
    result := ctLabCard
  else
    result := ctUnknown;
end;

procedure THealthcareCardUtilities.SetJWKList(AValue: TJWKList);
begin
  FJWKList.Free;
  FJWKList := AValue;
end;

procedure THealthcareCardUtilities.findKey(jwt: TJWT);
var
  id : String;
  jwk : TJWK;
  json : TJsonObject;
  jwks : TJWKList;
  i : integer;
begin
  id := jwt.kid;
  for jwk in FJWKList do
    if (jwk.id = id) then
      exit;

  if jwt.issuer <> '' then // it's supposed to be
  begin
    json := TInternetFetcher.fetchJson(URLPath([jwt.issuer, '.well-known', 'jwks.json']));
    try
      jwks := TJWKList.create(json);
      try
        FJWKList.AddAll(jwks);
      finally
        jwks.free;
      end;
    finally
      json.free;
    end;
  end;
end;

procedure THealthcareCardUtilities.sign(card: THealthcareCard; jwk : TJWK);
var
  payload : String;
  bytes : TBytes;
  jwt : TJWT;
begin
  payload := buildPayload(card);
  bytes := DeflateRfc1951(TEncoding.UTF8.GetBytes(payload));
  card.jws := TJWTUtils.encodeJWT('{"alg":"ES256","zip":"DEF","kid":"'+jwk.id+'"}', bytes, jwt_es256, jwk);
end;

function THealthcareCardUtilities.verify(token : String): THealthcareCard;
var
  jwt : TJWT;
  i : integer;
  p, vc, cs : TJsonObject;
  j :  TFHIRJsonParserBase;
  dt1, dt2 : TDateTime;
begin
  jwt := TJWTUtils.decodeJWT(token);
  try
    findKey(jwt);

    TJWTUtils.verifyJWT(jwt, FJWKList, false);

    p := jwt.payload;
    result := factory.makeHealthcareCard;
    try
      result.issuer := p.str['iss'];
      dt1 := EncodeDate(1970, 1, 1);
      dt2 := trunc((p.int['nbf'] * DATETIME_SECOND_ONE));
      result.issueDate := TFslDateTime.make(dt1+dt2, dttzUTC);
      vc := p.obj['vc'];
      if (vc = nil) then
        raise EFHIRException.create('"vc" not found in JWT');
      result.types := [];
      for i := 0 to vc.forceArr['type'].Count - 1 do
        result.types := result.types + [readCredential(vc.arr['type'].Value[i])];
      result.IsValid := jwt.valid;
      result.validationMessage := jwt.validationMessage;
      result.jws := token;
      cs := vc.obj['credentialSubject'];
      if (cs = nil) then
        raise EFHIRException.create('"credentialSubject" not found in JWT');
      if (TFHIRVersions.getMajMin(Factory.versionString) <> TFHIRVersions.getMajMin(cs.str['fhirVersion'])) then
        raise EFHIRException.create('Healthcard fhir version is not supported (found '+cs.str['fhirVersion']+' expecting '+Factory.versionString+')');

      j := Factory.makeParser(nil, ffjson, defLang) as TFHIRJsonParserBase;
      try
        j.Parse(cs.obj['fhirBundle']);
        result.bundle := j.resource.link;
      finally
        j.free;
      end;
      result.makeSummary;
      result.link;
    finally
      result.free;
    end;
  finally
    jwt.Free;
  end;
end;

class function THealthcareCardUtilities.readQR(src: String): String;
var
  b : TFslStringBuilder;
  i, v : integer;
  c : char;
begin
  if not src.StartsWith('shc:/') then
    raise EFslException.Create('Unable to process smart health card (didn''t start with shc:/)');
  b := TFslStringBuilder.create;
  try
    for i := 0 to ((length(src)-5) div 2) - 1 do
    begin
      v := StrToInt(copy(src, 6+(i*2), 2));
      c := chr(45+v);
      b.append(c);
    end;
    result := b.toString;
  finally
    b.free;
  end;
end;


end.