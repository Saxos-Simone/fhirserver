unit TerminologyServer;

interface

uses
  SysUtils, Classes, IniFiles,
  StringSupport,
  AdvObjects, AdvStringObjectMatches, AdvStringLists,
  KDBManager, KDBOdbcExpress,
  FHIRTypes, FHIRResources, FHIRUtilities,
  TerminologyServices, SnomedServices, LoincServices, UcumServices, RxNormServices, UniiServices, CvxServices,
  CountryCodeServices, AreaCodeServices,
  FHIRValueSetChecker,
  TerminologyServerStore;

Type
  TTerminologyServer = class (TTerminologyServerStore)
  private
    FExpansions : TAdvStringObjectMatch;
    FDependencies : TAdvStringObjectMatch; // object is TAdvStringList of identity

    procedure AddDependency(name, value : String);
    function getCodeDefinition(c : TFhirValueSetCodeSystemConcept; code : string) : TFhirValueSetCodeSystemConcept; overload;
    function getCodeDefinition(vs : TFHIRValueSet; code : string) : TFhirValueSetCodeSystemConcept; overload;
    function makeAnyValueSet: TFhirValueSet;

    // database maintenance
    procedure processClosureEntry(ClosureEntryKey, ClosureKey, ConceptKey : integer; conn2, conn3 : TKDBConnection; uri, code : String);
    function subsumes(uri1, code1, uri2, code2 : String) : boolean;
    procedure processValueSet(ValueSetKey : integer; URL : String; conn2, conn3 : TKDBConnection);
    procedure processConcept(ConceptKey : integer; URL, Code : String; conn2, conn3 : TKDBConnection);
    function isOkTarget(cm: TLoadedConceptMap; vs: TFHIRValueSet): boolean;
    function isOkSource(cm: TLoadedConceptMap; vs: TFHIRValueSet; coding: TFHIRCoding; out match : TFhirConceptMapElement): boolean;
  protected
    procedure invalidateVS(id : String); override;
  public
    constructor Create(db : TKDBManager); override;
    Destructor Destroy; override;
    function Link: TTerminologyServer; overload;

    // load external terminology resources (snomed, Loinc, etc)
    procedure load(ini : TIniFile);
    // functional services

    // if this id identifies a value set known to the external resources (if it does, construct it and return it)
    function isKnownValueSet(id : String; out vs : TFHIRValueSet): Boolean;

    // given a value set, expand it
    function expandVS(vs : TFHIRValueSet; cacheId : String; profile, textFilter : String; limit : integer; allowIncomplete : boolean) : TFHIRValueSet; overload;
    function expandVS(uri : String; profile, textFilter : String; limit : integer; allowIncomplete : boolean) : TFHIRValueSet; overload;

    // these are internal services - not for use outside the terminology server
    function expandVS(uri: String; profile, textFilter : String; dependencies : TStringList; limit : integer; allowIncomplete : boolean) : TFHIRValueSet; overload;
    function expandVS(vs: TFHIRValueSet; cacheId : String; profile, textFilter : String; dependencies : TStringList; limit : integer; allowIncomplete : boolean): TFHIRValueSet; overload;

    function lookupCode(coding : TFhirCoding) : TFhirResource;
    function validate(vs : TFHIRValueSet; coding : TFhirCoding; abstractOk : boolean) : TFhirParameters; overload;
    function validate(vs : TFHIRValueSet; coded : TFhirCodeableConcept; abstractOk : boolean) : TFhirParameters; overload;
    function translate(source : TFHIRValueSet; coding : TFhirCoding; target : TFHIRValueSet) : TFHIRParameters; overload;
    function translate(source : TFHIRValueSet; coded : TFhirCodeableConcept; target : TFHIRValueSet) : TFHIRParameters; overload;
    Function MakeChecker(uri : string) : TValueSetChecker;
    function getDisplayForCode(system, code : String): String;
    function checkCode(op : TFhirOperationOutcome; path : string; code : string; system : string; display : string) : boolean;

    // database maintenance
    procedure BuildIndexes(prog : boolean);

  end;

implementation

uses
  SystemService,
  USStateCodeServices,
  FHIRValueSetExpander;


{ TTerminologyServer }

constructor TTerminologyServer.Create(db : TKDBManager);
begin
  inherited;
  FExpansions := TAdvStringObjectMatch.create;
  FExpansions.PreventDuplicates;
  FDependencies := TAdvStringObjectMatch.create;
  FDependencies.PreventDuplicates;
end;

destructor TTerminologyServer.Destroy;
begin
  FDependencies.Free;
  FExpansions.free;
  inherited;
end;

procedure TTerminologyServer.load(ini : TIniFile);
var
  fn : string;
  p : TCodeSystemProvider;
begin
  writelnt('Load DB Terinologies');
  Unii := TUniiServices.Create(TKDBOdbcDirect.create('tx', 100, 'SQL Server Native Client 11.0',
        Ini.ReadString('database', 'server', ''), Ini.ReadString('database', 'tx', ''),
        Ini.ReadString('database', 'username', ''), Ini.ReadString('database', 'password', '')));
  Cvx := TCvxServices.Create(unii.db);
  CountryCode := TCountryCodeServices.Create(unii.db);
  AreaCode := TAreaCodeServices.Create(unii.db);
  p := TUSStateCodeServices.Create(unii.db);
  ProviderClasses.Add(p.system(nil), p);
  writelnt(' - done');

  if ini.ReadString('RxNorm', 'database', '') <> '' then
  begin
    writelnt('Connect to RxNorm');
    RxNorm := TRxNormServices.Create(TKDBOdbcDirect.create('rxnorm', 100, 'SQL Server Native Client 11.0',
        Ini.ReadString('database', 'server', ''), Ini.ReadString('RxNorm', 'database', ''),
        Ini.ReadString('database', 'username', ''), Ini.ReadString('database', 'password', '')));
  end;
  if ini.ReadString('NciMeta', 'database', '') <> '' then
  begin
    writelnt('Connect to NciMeta');
    NciMeta := TNciMetaServices.Create(TKDBOdbcDirect.create('ncimeta', 100, 'SQL Server Native Client 11.0',
        Ini.ReadString('database', 'server', ''), Ini.ReadString('NciMeta', 'database', ''),
        Ini.ReadString('database', 'username', ''), Ini.ReadString('database', 'password', '')));
  end;
  fn := ini.ReadString('snomed', 'cache', '');
  if fn <> '' then
  begin
    writelnt('Load Snomed from '+fn);
    Snomed := TSnomedServices.Create;
    Snomed.Load(fn);
    writelnt(' - done');
  end;
  fn := ini.ReadString('loinc', 'cache', '');
  if fn <> '' then
  begin
    writelnt('Load Loinc from '+fn);
    Loinc := TLoincServices.Create;
    Loinc.Load(fn);
    writelnt(' - done');
  end;
  fn := ini.ReadString('ucum', 'source', '');
  if fn <> '' then
  begin
    writelnt('Load Ucum from '+fn);
    Ucum := TUcumServices.Create;
    Ucum.Import(fn);
    writelnt(' - done');
  end;
end;

function TTerminologyServer.lookupCode(coding: TFhirCoding): TFhirResource;
var
  provider : TCodeSystemProvider;
  params : TFhirParameters;
  op : TFHIROperationOutcome;
  ctxt : TCodeSystemProviderContext;
  s : String;
begin
  try
    params := TFhirParameters.Create;
    try
      provider := getProvider(coding.system);
      try
        s := provider.name(nil);
        params.AddParameter('name', s);
        if (provider.version(nil) <> '') then
          params.AddParameter('version', provider.version(nil));
        ctxt := provider.locate(coding.code);
        try
          if ctxt = nil then
            raise Exception.Create('Unable to find code '+coding.code+' in '+s);

          if provider.IsAbstract(ctxt) then
            params.AddParameter('abstract', TFhirBoolean.Create(true));
          params.AddParameter('display', provider.Display(ctxt));
          provider.extendLookup(ctxt, params);
          // todo : add designations
        finally
          provider.Close(ctxt);
        end;
      finally
        provider.Free;
      end;
      result := params.Link;
    finally
      result.free;
    end;
  except
    on e : exception do
    begin
      op := TFhirOperationOutcome.Create;
      try
        op.error('terminology', TFhirIssueType.IssueTypeCodeInvalid, 'coding', false, e.Message);
        result := op.Link;
      finally
        op.Free;
      end;
    end;
  end;
end;

function TTerminologyServer.Link: TTerminologyServer;
begin
  result := TTerminologyServer(inherited Link);
end;

procedure TTerminologyServer.AddDependency(name, value : String);
var
  ts : TAdvStringList;
begin
  // must be in lock
  if FDependencies.ExistsByKey(name) then
    ts := FDependencies.GetValueByKey(name) as TAdvStringList
  else
  begin
    ts := TAdvStringList.Create;
    FDependencies.Add(name, ts);
  end;
  if not ts.ExistsByValue(value) then
    ts.Add(value);
end;

procedure TTerminologyServer.invalidateVS(id: String);
var
  ts : TAdvStringList;
  i : integer;
begin
  // must be in lock
  if FDependencies.ExistsByKey(id) then
  begin
    ts := FDependencies.GetValueByKey(id) as TAdvStringList;
    for i := 0 to ts.Count - 1 do
      if FExpansions.ExistsByKey(ts[i]) then
        FExpansions.DeleteByKey(ts[i]);
    FDependencies.DeleteByKey(id);
  end;
  for i := FExpansions.Count - 1 downto 0 do
   if FExpansions.KeyByIndex[i].StartsWith(id+#1) then
     FExpansions.DeleteByIndex(i);
end;

function TTerminologyServer.expandVS(vs: TFHIRValueSet; cacheId : String; profile : String; textFilter : String; limit : integer; allowIncomplete : boolean): TFHIRValueSet;
var
  ts : TStringList;
begin
  ts := TStringList.create;
  try
    result := expandVS(vs, cacheId, profile, textFilter, ts, limit, allowIncomplete);
  finally
    ts.free;
  end;
end;

function TTerminologyServer.expandVS(vs: TFHIRValueSet; cacheId : String; profile : String; textFilter : String; dependencies : TStringList; limit : integer; allowIncomplete : boolean): TFHIRValueSet;
var
  s, d : String;
  p : TArray<String>;
  exp : TFHIRValueSetExpander;
begin
  result := nil;
  if cacheId <> '' then
  begin
    FLock.Lock('expandVS.1');
    try
      if FExpansions.ExistsByKey(cacheId+#1+profile+#1+textFilter+#1+inttostr(limit)) then
      begin
        result := (FExpansions.matches[cacheId+#1+profile+#1+textFilter+#1+inttostr(limit)] as TFhirValueSet).link;
        p := result.Tags['cache'].Split([#1]);
        for s in p do
          if (s <> '') then
            dependencies.Add(s);
      end;
    finally
      FLock.Unlock;
    end;
  end;
  if result = nil then
  begin
    exp := TFHIRValueSetExpander.create(self.Link);
    try
      result := exp.expand(vs, profile, textFilter, dependencies, limit, allowIncomplete);
      if (dependencies.Count > 0) and (cacheId <> '') then
      begin
        FLock.Lock('expandVS.2');
        try
          if not FExpansions.ExistsByKey(cacheId+#1+profile+#1+textFilter+#1+inttostr(limit)) then
          begin
            FExpansions.Add(cacheId+#1+profile+#1+textFilter+#1+inttostr(limit), result.Link);
            // in addition, we trace the dependencies so we can expire the cache
            d := '';
            for s in dependencies do
            begin
              AddDependency(s, cacheId);
              d := d + s+#1;
            end;
            result.Tags['cache'] := d;
          end;
        finally
          FLock.Unlock;
        end;
      end;
    finally
      exp.Free;
    end;
  end;
end;



function TTerminologyServer.expandVS(uri: String; profile : String; textFilter : String; limit : integer; allowIncomplete : boolean): TFHIRValueSet;
var
  vs : TFHIRValueSet;
  ts : TStringList;
begin
  ts := TStringList.create;
  try
    vs := getValueSetByUrl(uri);
    try
      result := expandVS(vs, uri, profile, textFilter, ts, limit, allowIncomplete);
    finally
      vs.Free;
    end;
  finally
    ts.Free;
  end;
end;

function TTerminologyServer.expandVS(uri: String; profile : String; textFilter : String; dependencies: TStringList; limit : integer; allowIncomplete : boolean): TFHIRValueSet;
var
  vs : TFHIRValueSet;
begin
  vs := getValueSetByUrl(uri);
  try
    if vs = nil then
      raise Exception.Create('Unable to find value set "'+uri+'"');
    result := expandVS(vs, uri, profile, textFilter, limit, allowIncomplete);
  finally
    vs.Free;
  end;
end;


function TTerminologyServer.makeAnyValueSet: TFhirValueSet;
begin
  result := TFhirValueSet.Create;
  try
    result.url := ANY_CODE_VS;
    result.name := 'All codes known to the system';
    result.description := 'All codes known to the system';
    result.status := ConformanceResourceStatusActive;
    result.compose := TFhirValueSetCompose.create;
    result.compose.includeList.Append.system := ANY_CODE_VS;
    result.link;
  finally
    result.Free;
  end;
end;


function TTerminologyServer.isKnownValueSet(id: String; out vs: TFHIRValueSet): Boolean;
begin
  vs := nil;
  if id.StartsWith('http://snomed.info/') then
    vs := Snomed.buildValueSet(id)
  else if id.StartsWith('http://loinc.org/vs/LP') or id.StartsWith('http://loinc.org/vs/LL') then
    vs := Loinc.buildValueSet(id)
  else if id = ANY_CODE_VS then
    vs := makeAnyValueSet;
  result := vs <> nil;
end;

function TTerminologyServer.MakeChecker(uri: string): TValueSetChecker;
var
  vs : TFhirValueSet;
begin
  result := TValueSetChecker.create(self.Link, uri);
  try
    vs := getValueSetByUrl(uri);
    try
      result.prepare(vs);
    finally
      vs.Free;
    end;
    result.Link;
  finally
    result.Free;
  end;
end;

function TTerminologyServer.validate(vs : TFHIRValueSet; coding : TFhirCoding; abstractOk : boolean) : TFhirParameters;
var
  check : TValueSetChecker;
begin
  check := TValueSetChecker.create(self.Link, vs.url);
  try
    check.prepare(vs);
    result := check.check(coding, abstractOk);
  finally
    check.Free;
  end;
end;


function TTerminologyServer.validate(vs : TFHIRValueSet; coded : TFhirCodeableConcept; abstractOk : boolean) : TFhirParameters;
var
  check : TValueSetChecker;
begin
  check := TValueSetChecker.create(self.Link, vs.url);
  try
    check.prepare(vs);
    result := check.check(coded, abstractOk);
  finally
    check.Free;
 end;
end;

function TTerminologyServer.checkCode(op : TFhirOperationOutcome; path : string; code : string; system : string; display : string) : boolean;
var
  vs : TFhirValueSet;
  def : TFhirValueSetCodeSystemConcept;
  d : String;
begin
  result := false;
  if system.StartsWith('http://hl7.org/fhir') then
  begin
    if (system = 'http://hl7.org/fhir/sid/icd-10') then
      result := true// nothing for now....
    else
    begin
      vs := getCodeSystem(system);
      if op.warning('InstanceValidator', IssueTypeCodeInvalid, path, vs <> nil, 'Unknown Code System '+system) then
      begin
        def := getCodeDefinition(vs, code);
        if (op.warning('InstanceValidator', IssueTypeCodeInvalid, path, def <> nil, 'Unknown Code ('+system+'#'+code+')')) then
            result := op.warning('InstanceValidator', IssueTypeCodeInvalid, path, (display = '') or (display = def.Display), 'Display for '+system+' code "'+code+'" should be "'+def.Display+'"');
      end;
    end;
  end
  else if system.StartsWith('http://snomed.info/sct') and (Snomed <> nil) then
  begin
    if op.warning('InstanceValidator', IssueTypeCodeInvalid, path, Snomed.IsValidConcept(code), 'The SNOMED-CT term "'+code+'" is unknown') then
    begin
      d := Snomed.GetDisplayName(code, '');
      result := op.warning('InstanceValidator', IssueTypeCodeInvalid, path, (display = '') or (display = d), 'Display for SNOMED-CT term "'+code+'" should be "'+d+'"');
    end;
  end
  else if system.StartsWith('http://loinc.org') and (Loinc <> nil) then
  begin
    d := Loinc.GetDisplayByName(code);
    if op.warning('InstanceValidator', IssueTypeCodeInvalid, path, d <> '', 'The LOINC code "'+code+'" is unknown') then
      result := op.warning('InstanceValidator', IssueTypeCodeInvalid, path, (display = '') or (display = d), 'Display for Loinc Code "'+code+'" should be "'+d+'"');
  end
  else if system.StartsWith('http://unitsofmeasure.org') and (Ucum <> nil) then
  begin
    d := Ucum.validate(code);
    result := op.warning('InstanceValidator', IssueTypeCodeInvalid, path, d = '', 'The UCUM code "'+code+'" is not valid: '+d);
    // we don't make rules about display for UCUM.
  end
  else
    result := true;
end;



function TTerminologyServer.getCodeDefinition(c : TFhirValueSetCodeSystemConcept; code : string) : TFhirValueSetCodeSystemConcept;
var
  i : integer;
  g : TFhirValueSetCodeSystemConcept;
  r : TFhirValueSetCodeSystemConcept;
begin
  result := nil;
  if (code = c.Code) then
    result := c;
  for i := 0 to c.conceptList.Count - 1 do
  begin
    g := c.conceptList[i];
    r := getCodeDefinition(g, code);
    if (r <> nil) then
    begin
      result := r;
      exit;
    end;
  end;
end;

function TTerminologyServer.getCodeDefinition(vs : TFHIRValueSet; code : string) : TFhirValueSetCodeSystemConcept;
var
  i : integer;
  c : TFhirValueSetCodeSystemConcept;
  r : TFhirValueSetCodeSystemConcept;
begin
  result := nil;
  for i := 0 to vs.codeSystem.conceptList.Count - 1 do
  begin
    c := vs.codeSystem.conceptList[i];
    r := getCodeDefinition(c, code);
    if (r <> nil) then
    begin
      result := r;
      exit;
    end;
  end;
end;


function TTerminologyServer.getDisplayForCode(system, code: String): String;
var
  provider : TCodeSystemProvider;
begin
  provider := getProvider(system, true);
  if provider <> nil then
  try
    result := provider.getDisplay(code);
  finally
    provider.Free;
  end;
end;

function TTerminologyServer.isOkTarget(cm : TLoadedConceptMap; vs : TFHIRValueSet) : boolean;
begin
  if cm.Target <> nil then
    result := cm.Target.url = vs.url
  else
    result := false;
  // todo: or it might be ok to use this value set if it's a subset of the specified one?
end;

function TTerminologyServer.isOkSource(cm : TLoadedConceptMap; vs : TFHIRValueSet; coding : TFHIRCoding; out match : TFhirConceptMapElement) : boolean;
var
  em : TFhirConceptMapElement;
begin
  result := false;
  if (vs = nil) or ((cm.source <> nil) and (cm.Source.url = vs.url)) then
  begin
    for em in cm.Resource.elementList do
      if (em.system = coding.system) and (em.code = coding.code) then
      begin
        result := true;
        match := em;
      end;
  end;
end;

function TTerminologyServer.translate(source : TFHIRValueSet; coding : TFhirCoding; target : TFHIRValueSet) : TFHIRParameters;
var
  op : TFHIROperationOutcome;
  list : TLoadedConceptMapList;
  i : integer;
  cm : TLoadedConceptMap;
  p : TFhirParameters;
  em : TFhirConceptMapElement;
  map : TFhirConceptMapElementTarget;
  outcome : TFhirCoding;
begin
  result := nil;
  op := TFhirOperationOutcome.Create;
  try
    try
      if not checkCode(op, '', coding.code, coding.system, coding.display) then
        raise Exception.Create('Code '+coding.code+' in system '+coding.system+' not recognized');

      // check to see whether the coding is already in the target value set, and if so, just return it
      p := validate(target, coding, false);
      try
        if TFhirBoolean(p.NamedParameter['result']).value then
        begin
          result := TFhirParameters.create;
          result.AddParameter('result', true);
          result.AddParameter('outcome', coding.Link);
          result.AddParameter('equivalence', TFhirCode.Create('equal'));
          exit;
        end;
      finally
        p.Free;
      end;

      list := GetConceptMapList;
      try
        for i := 0 to list.Count - 1 do
        begin
          cm := list[i];
          if isOkTarget(cm, target) and isOkSource(cm, source, coding, em) then
          begin
            if em.targetList.Count = 0 then
              raise Exception.Create('Concept Map has an element with no map for '+'Code '+coding.code+' in system '+coding.system);
            map := em.targetList[0]; // todo: choose amongst dependencies
            result := TFhirParameters.create;
            if (map.equivalence in [ConceptMapEquivalenceEquivalent, ConceptMapEquivalenceEqual, ConceptMapEquivalenceWider, ConceptMapEquivalenceSubsumes, ConceptMapEquivalenceNarrower, ConceptMapEquivalenceSpecializes, ConceptMapEquivalenceInexact]) then
            begin
              result.AddParameter('result', true);
              outcome := TFhirCoding.Create;
              result.AddParameter('outcome', outcome);
              outcome.system := map.codeSystem;
              outcome.code := map.code;
            end
            else
            begin
              result.AddParameter('result', false);
            end;
            result.AddParameter('equivalence', map.equivalenceElement.Link);
            if (map.commentsElement <> nil) then
              result.AddParameter('message', map.commentsElement.Link);
            exit;
          end;
        end;
      finally
        list.Free;
      end;
    except
      on e : exception do
      begin
        result := TFHIRParameters.create;
        result.AddParameter('result', false);
        result.AddParameter('message', e.message);
      end;
    end;
  finally
    op.Free;
  end;
end;

function TTerminologyServer.translate(source : TFHIRValueSet; coded : TFhirCodeableConcept; target : TFHIRValueSet) : TFHIRParameters;
begin
  raise Exception.Create('Not done yet');
end;

(*function TTerminologyServer.translate(vs: TFHIRValueSet; coding: TFhirCoding; dest : String): TFHIRParameters;
var
  isCs, ok: boolean;
  i, j : integer;
  cc : TFhirCodeableConcept;
  c : TFHIRCoding;
  maps : TFhirConceptMapConcepttargetList;
  map : TFhirConceptMapConceptMap;
begin
  result := TFhirOperationOutcome.Create;
  try
    if checkCode(result, '', coding.code, coding.system, coding.display) then
    begin
      cc := TFhirCodeableConcept.Create;
      try
        cc.codingList.Add(coding.Link);

        isCs := HasCodeSystem(dest);
        ok := false;

        // iterate the concept maps
        // a concept map is a match if there is a translation from source to dest
        FLock.Lock('translate');
        try
          for i := 0 to FConceptMaps.count - 1 do
          begin
            cm := FConceptMaps.values[i] as TLoadedConceptMap;
            if (cm.source <> nil) and (cm.source.url = vs.url) and
              cm.hasTranslation(coding.system, coding.code, maps) then
            try
              for j := 0 to maps.Count - 1 do
              begin
                map := maps[j];
                if (map.equivalence in [ConceptEquivalenceEqual, ConceptEquivalenceEquivalent, ConceptEquivalenceWider, ConceptEquivalenceInexact]) and
                  (not isCs {if we'rea value set mapping, we'll just run with all the maps) } or (map.codeSystem = dest)) then
                begin
                  ok := true;
                  c := cc.codingList.Append;
                  c.system := map.codeSystem;
                  c.code := map.code;
                  c.display := getDisplayForCode(map.codeSystem, map.code);
                  if map.comments <> '' then
                    result.hint('terminology-server', 'mapping', '', false, 'Mapping from "'+coding.system+'"/"'+coding.code+'" to "'+c.system+'"/"'+c.code+'": '+map.comments)
                end;
              end;
            finally
              maps.free;
            end;
          end;
          result.error('terminology-server', 'mapping', '', ok, 'No Mapping found');
        finally
          FLock.Unlock;
        end;
        if ok then
          result.AddExtension('http://hl7.org/fhir/Profile/general-extensions#translation', cc.Link);
      finally
        cc.free;
      end;
    end;
    result.Link;
  finally
    result.Free;
  end;
end;
*)

procedure TTerminologyServer.BuildIndexes(prog : boolean);
var
  conn1, conn2, conn3 : TKDBConnection;
  i : integer;
begin
  conn1 := DB.GetConnection('BuildIndexes');
  try
    conn2 := DB.GetConnection('BuildIndexes');
    try
      conn3 := DB.GetConnection('BuildIndexes');
      try
        if conn1.CountSQL('Select Count(*) from ValueSets where NeedsIndexing = 0') = 0 then
          conn1.ExecSQL('Update Concepts set NeedsIndexing = 0'); // we're going to index them all anwyay

        // first, update value set member information
        if (prog) then Writet('Updating ValueSet Members');
        conn1.SQL := 'Select ValueSetKey, URL from ValueSets where NeedsIndexing = 1';
        conn1.Prepare;
        conn1.Execute;
        i := 0;
        while conn1.FetchNext do
        begin
          inc(i);
          if (prog and (i mod 10 = 0)) then Write('.');
          processValueSet(conn1.ColIntegerByName['ValueSetKey'], conn1.ColStringByName['URL'], conn2, conn3);
        end;
        conn1.Terminate;
        if (prog) then Writeln;

        // second, for each concept that needs indexing, check it's value set information
        if (prog) then Writet('Indexing Concepts');
        conn1.SQL := 'Select ConceptKey, URL, Code from Concepts where NeedsIndexing = 1';
        conn1.Prepare;
        conn1.Execute;
        i := 0;
        while conn1.FetchNext do
        begin
          inc(i);
          if (prog and (i mod 10 = 0)) then Write('.');
          processConcept(conn1.ColIntegerByName['ConceptKey'], conn1.ColStringByName['URL'], conn1.ColStringByName['Code'], conn2, conn3);
        end;
        conn1.Terminate;
        if (prog) then Writeln;


        // last, for each entry in the closure entry table that needs closureing, do it
        if (prog) then Writet('Generating Closures');
        conn1.SQL := 'select ClosureEntryKey, ClosureKey, SubsumesKey, URL, Code from ClosureEntries, Concepts where ClosureEntries.NeedsIndexing = 1 and ClosureEntries.SubsumesKey = Concepts.ConceptKey';
        conn1.Prepare;
        conn1.Execute;
        while conn1.FetchNext do
        begin
          inc(i);
          if (prog and (i mod 100 = 0)) then Write('.');
          processClosureEntry(conn1.ColIntegerByName['ClosureEntryKey'], conn1.ColIntegerByName['ClosureKey'], conn1.ColIntegerByName['SubsumesKey'], conn2, conn3, conn1.ColStringByName['URL'], conn1.ColStringByName['Code']);
        end;
        conn1.Terminate;
        if (prog) then Writeln;

        if (prog) then Writelnt('Done');
        conn3.Release;
      except
        on e : exception do
        begin
          conn3.Error(e);
        end;
      end;
      conn2.Release;
    except
      on e : exception do
      begin
        conn2.Error(e);
      end;
    end;
    conn1.Release;
  except
    on e : exception do
    begin
      conn1.Error(e);
    end;
  end;
end;

function TTerminologyServer.subsumes(uri1, code1, uri2, code2: String): boolean;
var
  prov : TCodeSystemProvider;
  loc :  TCodeSystemProviderContext;
begin
  result := false;
  if (uri1 <> uri2) then
    result := false // todo later - check that concept maps
  else if (snomed <> nil) and (uri1 = Snomed.system(nil)) then
    result := Snomed.Subsumes(code1, code2)
  else
  begin
    prov := getProvider(uri1, true);
    if prov <> nil then
    begin
      try
        loc := prov.locateIsA(code2, code1);
        result := Loc <> nil;
        prov.Close(loc);
      finally
        prov.Free;
      end;
    end;
  end;
end;

procedure TTerminologyServer.processClosureEntry(ClosureEntryKey, ClosureKey, ConceptKey: integer; conn2, conn3: TKDBConnection; uri, code : String);
var
  b : boolean;
begin
  conn2.SQL := 'select ConceptKey, URL, Code from Concepts where ConceptKey in (select SubsumesKey from ClosureEntries where ClosureKey = '+inttostr(ClosureKey)+' and ClosureEntryKey <> '+inttostr(ClosureEntryKey)+')';
  conn2.prepare;
  try
    conn2.execute;
    while conn2.fetchnext do
    begin
      try
        b := subsumes(uri, code, conn2.ColStringByName['URL'],conn2.ColStringByName['Code']) ;
      except
        b := false;
      end;
      if b then
        conn3.execSQL('Insert into ClosureEntries (ClosureEntryKey, ClosureKey, SubsumesKey, SubsumedKey, NeedsIndexing) values ('+inttostr(NextClosureEntryKey)+', '+inttostr(ClosureKey)+', '+inttostr(ConceptKey)+', '+conn2.colStringByName['ConceptKey']+', 0)');
    end;
  finally
    conn2.terminate;
  end;
  conn2.ExecSQL('Update ClosureEntries set NeedsIndexing = 0 where ClosureEntryKey = '+inttostr(ClosureEntryKey));
end;

procedure TTerminologyServer.processConcept(ConceptKey: integer; URL, Code: String; conn2, conn3: TKDBConnection);
var
  vs : TFhirValueSet;
  val : TValuesetChecker;
begin
  conn2.SQL := 'select ValueSetKey, URL from ValueSets';
  conn2.Prepare;
  conn2.Execute;
  while conn2.FetchNext do
  begin
    vs := getValueSetByURL(conn2.ColStringByName['URL']);
    if vs = nil then
      conn3.ExecSQL('Update ValueSets set NeedsIndexing = 0, Error = ''Unable to find definition'' where ValueSetKey = '+conn2.ColStringByName['ValueSetKey'])
    else
      try
        try
          val := TValueSetChecker.create(self.Link, vs.url);
          try
            val.prepare(vs);
            if not val.check(URL, code, true) then
              conn3.ExecSQL('Delete from ValueSetMembers where ValueSetKey = '+conn2.ColStringByName['ValueSetKey']+' and ConceptKey = '+inttostr(ConceptKey))
            else if conn3.CountSQL('select Count(*) from ValueSetMembers where ValueSetKey = '+conn2.ColStringByName['ValueSetKey']+' and ConceptKey = '+inttostr(ConceptKey)) = 0 then
              conn3.ExecSQL('insert into ValueSetMembers (ValueSetMemberKey, ValueSetKey, ConceptKey) values ('+inttostr(NextValueSetMemberKey)+','+conn2.ColStringByName['ValueSetKey']+', '+inttostr(ConceptKey)+')');
          finally
            val.Free;
          end;
        finally
          vs.Free;
        end;
      except
        on e : Exception do
        begin
          conn3.ExecSQL('Update ValueSets set NeedsIndexing = 0, Error = '''+sqlwrapstring(e.Message)+''' where ValueSetKey = '+conn2.ColStringByName['ValueSetKey']);
        end;
      end;
  end;
  Conn2.Terminate;
  conn2.ExecSQL('Update Concepts set NeedsIndexing = 0 where ConceptKey = '+inttostr(ConceptKey));
end;

procedure TTerminologyServer.processValueSet(ValueSetKey: integer; URL: String; conn2, conn3: TKDBConnection);
var
  vs : TFhirValueSet;
  val : TValuesetChecker;
  system, code : String;
begin
  vs := getValueSetByURL(URL);
  if vs = nil then
    conn2.ExecSQL('Update ValueSets set NeedsIndexing = 0, Error = ''Unable to find definition'' where ValueSetKey = '+inttostr(valuesetKey))
  else
    try
      try
        val := TValueSetChecker.create(self.Link, vs.url);
        try
          val.prepare(vs);
          conn2.SQL := 'select ConceptKey, URL, Code from Concepts';
          conn2.Prepare;
          conn2.Execute;
          while conn2.FetchNext do
          begin
            system := conn2.ColStringByName['URL'];
            code := conn2.ColStringByName['Code'];
            if not val.check(system, code, true) then
              conn3.ExecSQL('Delete from ValueSetMembers where ValueSetKey = '+inttostr(ValueSetKey)+' and ConceptKey = '+conn2.ColStringByName['ConceptKey'])
            else if conn3.CountSQL('select Count(*) from ValueSetMembers where ValueSetKey = '+inttostr(ValueSetKey)+' and ConceptKey = '+conn2.ColStringByName['ConceptKey']) = 0 then
              conn3.ExecSQL('insert into ValueSetMembers (ValueSetMemberKey, ValueSetKey, ConceptKey) values ('+inttostr(NextValueSetMemberKey)+','+inttostr(ValueSetKey)+', '+conn2.ColStringByName['ConceptKey']+')');
          end;
          Conn2.Terminate;
          conn2.ExecSQL('Update ValueSets set NeedsIndexing = 0, Error = null where ValueSetKey = '+inttostr(valuesetKey));
        finally
          val.Free;
        end;
      finally
        vs.Free;
      end;
    except
      on e : Exception do
      begin
        conn2.ExecSQL('Update ValueSets set NeedsIndexing = 0, Error = '''+sqlwrapstring(e.Message)+''' where ValueSetKey = '+inttostr(valuesetKey));
      end;
    end;
end;


end.