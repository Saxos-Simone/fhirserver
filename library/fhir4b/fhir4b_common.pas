unit fhir4b_common;

{
Copyright (c) 2011+, HL7 and Health Intersections Pty Ltd (http://www.healthintersections.com.au)
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

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS' AND
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

{$I fhir.inc}
{$I fhir4b.inc}

interface

uses
  SysUtils, Classes, Generics.Collections,
  fsl_base, fsl_utilities,
  fsl_http,
  fhir_objects, fhir_common, fhir_features,
  fhir4b_enums, fhir4b_types, fhir4b_resources, fhir4b_operations, fhir4b_opbase;

const
  ExceptionTypeTranslations : array [TFhirIssueType] of TFhirIssueTypeEnum = (IssueTypeNull, IssueTypeInvalid, IssueTypeStructure, IssueTypeRequired, IssueTypeValue,
    IssueTypeInvariant, IssueTypeSecurity, IssueTypeLogin, IssueTypeUnknown, IssueTypeExpired, IssueTypeForbidden, IssueTypeSuppressed, IssueTypeProcessing,
    IssueTypeNotSupported, IssueTypeDuplicate, IssueTypeNotFound, IssueTypeTooLong, IssueTypeCodeInvalid, IssueTypeExtension, IssueTypeTooCostly, IssueTypeBusinessRule,
    IssueTypeConflict, IssueTypeIncomplete, IssueTypeTransient, IssueTypeLockError, IssueTypeNoStore, IssueTypeException, IssueTypeTimeout, IssueTypeThrottled, IssueTypeInformational);

  ISSUE_SEVERITY_MAP : array [TFhirIssueSeverityEnum] of TIssueSeverity = (isNull, isFatal, isError, isWarning, isInformation);
  ISSUE_SEVERITY_MAP2 : array [TIssueSeverity] of TFhirIssueSeverityEnum = (IssueSeverityNull, IssueSeverityFatal, IssueSeverityError, IssueSeverityWarning, IssueSeverityInformation);
  INTERACTION_MAP : array [TFHIRInteraction] of TFhirTypeRestfulInteractionEnum = (TypeRestfulInteractionRead, TypeRestfulInteractionSearchType, TypeRestfulInteractionHistoryType, TypeRestfulInteractionCreate, TypeRestfulInteractionUpdate, TypeRestfulInteractionDelete, TypeRestfulInteractionPatch);
  INTERACTION_MAP2 : array [TFHIRInteraction] of TFhirSystemRestfulInteractionEnum = (SystemRestfulInteractionNull, SystemRestfulInteractionSearchSystem, SystemRestfulInteractionHistorySystem, SystemRestfulInteractionHistorySystem, SystemRestfulInteractionHistorySystem, SystemRestfulInteractionHistorySystem, SystemRestfulInteractionHistorySystem);
  MAP_SearchParamType : array [TFhirSearchParamTypeEnum] of TFHIRSearchParamType = (sptString, sptNumber, sptDate, sptString, sptToken, sptReference, sptComposite, sptQuantity, sptUri, sptSpecial);
  MAP_SEARCH_MODE : array [TFhirSearchEntryModeEnum] of TFHIRBundleEntrySearchMode = (smUnknown, smMatch, smInclude, smOutcome);
  MAP_SEARCH_MODE2 : array [TFHIRBundleEntrySearchMode] of TFhirSearchEntryModeEnum = (SearchEntryModeNull, SearchEntryModeMatch, searchEntryModeInclude, searchEntryModeOutcome);
  MAP_ELEMENT_DEFINITION_BINDING : array [TFhirBindingStrengthEnum] of TElementDefinitionBinding = (edbNone, edbRequired, edbExtensible, edbPreferred, edpExample);
  MAP_TFilterOperator : array [TFhirFilterOperatorEnum] of TFilterOperator = (foNull, foEqual, foIsA, foDescendentOf, foIsNotA, foRegex, foIn, foNotIn, foGeneralizes, foExists);
  MAP_TFilterOperatorR : array [TFilterOperator] of TFhirFilterOperatorEnum = (filterOperatorNull, filterOperatorEqual, filterOperatorIsA, filterOperatorDescendentOf, filterOperatorIsNotA, filterOperatorRegex, filterOperatorIn, filterOperatorNotIn, filterOperatorGeneralizes, filterOperatorExists, filterOperatorNull, filterOperatorNull);
  MAP_TFhirConceptPropertyTypeEnum : array [TFhirConceptPropertyTypeEnum] of TFhirCodeSystemPropertyType = (cptNull, cptCode, cptCoding, cptString, cptInteger, cptBoolean, cptDateTime, cptDecimal);
  MAP_TFHIRSearchParamType1 : array [TFhirSearchParamTypeEnum] of TFHIRSearchParamType = (sptNull, sptNumber, sptDate, sptString, sptToken, sptReference, sptComposite, sptQuantity, sptUri, sptSpecial);
  MAP_TFHIRSearchParamType2 : array [TFhirSearchParamType] of TFHIRSearchParamTypeEnum = (SearchParamTypeNull, SearchParamTypeNumber, SearchParamTypeDate, SearchParamTypeString, SearchParamTypeToken, SearchParamTypeReference, SearchParamTypeComposite, SearchParamTypeQuantity, SearchParamTypeUri, SearchParamTypeNull);
  MAP_TPublicationStatus : array [TPublicationStatus] of TFHIRPublicationStatusEnum = (PublicationStatusNull, PublicationStatusDraft, PublicationStatusActive, PublicationStatusRetired);
  MAP_TPublicationStatusR : array [TFHIRPublicationStatusEnum] of TPublicationStatus = (psNull, psDraft, psActive, psRetired, psNull);
  MAP_TFhirCodeSystemContentMode : array [TFhirCodeSystemContentMode] of TFhirCodeSystemContentModeEnum = (CodesystemContentModeNull, CodesystemContentModeNotPresent, CodesystemContentModeExample, CodesystemContentModeFragment, CodesystemContentModeComplete, CodesystemContentModeSupplement);
  MAP_TFhirCodeSystemContentModeR : array [TFhirCodeSystemContentModeEnum] of TFhirCodeSystemContentMode = (cscmNull, cscmNotPresent, cscmExample, cscmFragment, cscmComplete, cscmSupplement);
  MAP_TFHIRConceptEquivalence : array [TFhirConceptMapEquivalenceEnum] of TFHIRConceptEquivalence = (cmeNull, cmeRelatedto, cmeEquivalent, cmeEqual, cmeWider, cmeSubsumes, cmeNarrower, cmeSpecializes, cmeInexact, cmeUnmatched, cmeDisjoint);
  MAP_TFHIRConceptEquivalenceR : array [TFHIRConceptEquivalence] of TFHIRConceptMapEquivalenceEnum = (ConceptMapEquivalenceNull, ConceptMapEquivalenceRelatedto, ConceptMapEquivalenceEquivalent, ConceptMapEquivalenceEqual, ConceptMapEquivalenceWider, ConceptMapEquivalenceSubsumes, ConceptMapEquivalenceNarrower, ConceptMapEquivalenceSpecializes, ConceptMapEquivalenceInexact, ConceptMapEquivalenceUnmatched, ConceptMapEquivalenceDisjoint);
  MAP_TContactType : array [TContactType] of TFhirContactPointSystemEnum = (ContactPointSystemNull, ContactPointSystemPhone, ContactPointSystemFax, ContactPointSystemEmail, ContactPointSystemPager, ContactPointSystemUrl, ContactPointSystemSms, ContactPointSystemOther);
  MAP_TContactType2 : array [TFhirContactPointSystemEnum] of TContactType = (cpsNull, cpsPhone, cpsFax, cpsEmail, cpsPager, cpsUrl, cpsSms, cpsOther);
  MAP_TSubscriptionMethod : array [TFhirSubscriptionChannelTypeEnum] of TSubscriptionMethod = (smNull, smRestHook, smWebsocket, smEmail, smSms, smChangeScript);
  MAP_TSubscriptionMethod2 : array [TSubscriptionMethod] of TFhirSubscriptionChannelTypeEnum = (SubscriptionChannelTypeNull, SubscriptionChannelTypeRestHook, SubscriptionChannelTypeWebsocket, SubscriptionChannelTypeEmail, SubscriptionChannelTypeSms, SubscriptionChannelTypeMessage);
  MAP_TSubscriptionStatus : array [TFhirSubscriptionStatusEnum] of TSubscriptionStatus = (ssNull, ssRequested, ssActive, ssError, ssOff);
  MAP_TSubscriptionStatus2 : array [TSubscriptionStatus] of TFhirSubscriptionStatusEnum = (SubscriptionStatusNull, SubscriptionStatusRequested, SubscriptionStatusActive, SubscriptionStatusError, SubscriptionStatusOff, SubscriptionStatusNull);
  BUNDLE_TYPE_TITLE : Array[TFhirBundleTypeEnum] of String = ('', 'Document', 'Message', 'Transaction', 'Transaction Response', 'Batch', 'Batch Response', 'History Record', 'Search Results', 'Resource Collection');
  MAP_TFHIRBundleType  : array [TBundleType] of TFhirBundleTypeEnum = (BundleTypeNull, BundleTypeDocument, BundleTypeMessage, BundleTypeTransaction, BundleTypeTransactionResponse, BundleTypeBatch, BundleTypeBatchResponse, BundleTypeHistory, BundleTypeSearchset, BundleTypeCollection);
  MAP_TFHIRBundleTypeR : array [TFhirBundleTypeEnum] of TBundleType = (btNull, btDocument, btMessage, btTransaction, btTransactionResponse, btBatch, btBatchResponse, btHistory, btSearchset, btCollection);
  MAP_TObservationStatus : array [TObservationStatus] of TFhirObservationStatusEnum = (ObservationStatusNull, ObservationStatusRegistered, ObservationStatusPreliminary, ObservationStatusFinal, ObservationStatusAmended, ObservationStatusCorrected, ObservationStatusCancelled, ObservationStatusEnteredInError, ObservationStatusUnknown);
  MAP_TObservationStatus2 : array [TFhirObservationStatusEnum] of TObservationStatus = (obssNull, obssRegistered, obssPreliminary, obssFinal, obssAmended, obssCorrected, obssCancelled, obssEnteredInError, obssUnknown);


type
  TFHIRExtension4B = class (TFHIRExtensionW)
  public
    function url : String; override;
    function value : TFHIRObject; override;
    function renderText : String; override;
  end;

  TFHIRCoding4B = class (TFHIRCodingW)
  public
    function getSystem : String; override;
    function getCode : String; override;
    function getVersion : String; override;
    function getDisplay : String; override;
    procedure setCode(Value: String); override;
    procedure setDisplay(Value: String); override;
    procedure setSystem(Value: String); override;
    procedure setVersion(Value: String); override;
    function renderText : String; override;
  end;

  TFhirCodeableConcept4B = class (TFhirCodeableConceptW)
  protected
    function GetText: String; override;
    procedure SetText(const Value: String); override;
  public
    function codingCount : integer; override;
    function codings : TFslList<TFhirCodingW>; override;
    procedure addCoding(coding : TFHIRCodingW); override;
    function addCoding : TFHIRCodingW; override;
    function summary : String; override;
    function fromSystem(System : String; required : boolean = false) : String; overload; override;
    function fromSystem(Systems : TArray<String>; required : boolean = false) : String; overload; override;
    function renderText : String; override;
  end;

  TFhirIdentifier4B = class (TFhirIdentifierW)
  private
    function id : TFHIRIdentifier;
  protected
    function GetSystem: String; override;
    function GetUse: TIdentifierUse; override;
    function GetValue: String; override;
    procedure SetSystem(const Value: String); override;
    procedure SetUse(const Value: TIdentifierUse); override;
    procedure SetValue(const Value: String); override;
    function GetTypeV: TFhirCodeableConceptW; override;
    procedure SetTypeV(const Value: TFhirCodeableConceptW); override;
    function renderText : String; override;
  end;

  TFhirOperationOutcome4B = class (TFhirOperationOutcomeW)
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function hasText : boolean; override;
    function text : String; override;
    function code : TFhirIssueType; override;
    procedure addIssue(issue : TFhirOperationOutcomeIssueW; free : boolean); override;
    function hasIssues : boolean; override;
    function issues : TFslList<TFhirOperationOutcomeIssueW>; override;
    function rule(level : TIssueSeverity; source : String; typeCode : TFhirIssueType; path : string; test : boolean; msg : string) : boolean; override;
    function severity : TIssueSeverity; override;
    function issueCount : integer; override;
    function hasErrors : boolean; override;
  end;

  TFHIRBundleEntry4B = class (TFHIRBundleEntryW)
  private
    function entry : TFhirBundleEntry;
  protected
    function getRequestMethod: String; override;
    function getRequestUrl: String; override;
    function getResource: TFHIRResourceV; override;
    function getResponseDate: TFslDateTime; override;
    function getResponseStatus: String; override;
    function getSearchMode: TFHIRBundleEntrySearchMode; override;
    function getSearchMpiMatch: String; override;
    function getSearchScore: String; override;
    procedure setRequestMethod(Value: String); override;
    procedure setRequestUrl(Value: String); override;
    procedure setResource(Value: TFHIRResourceV); override;
    procedure setResponseDate(Value: TFslDateTime); override;
    procedure setResponseStatus(Value: String); override;
    procedure setSearchMode(Value: TFHIRBundleEntrySearchMode); override;
    procedure setSearchMpiMatch(Value: String); override;
    procedure setSearchScore(Value: String); override;
    function getURL: String; override;
    procedure setUrl(Value: String);  override;
    function getrequestIfNoneExist: String; override;
    procedure setrequestIfNoneExist(Value: String); override;
    function getrequestIfMatch: String; override;
    procedure setrequestIfMatch(Value: String); override;
    function getrequestIfNoneMatch: String; override;
    procedure setrequestIfNoneMatch(Value: String); override;
    function getResponseETag: string; override;
    procedure setResponseETag(Value: string); override;
    function getResponseLocation: string; override;
    procedure setResponseLocation(Value: string); override;
    function getrequestIfModifiedSince: TFslDateTime; override;
    procedure setrequestIfModifiedSince(Value: TFslDateTime); override;
  public
    function getLink(rel: String): String; override;
    procedure setLink(rel: String; const Value: String); override;
  end;

  TFhirBinary4B = class (TFhirBinaryW)
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function ContentType : String; override;
    function content : TBytes; override;
  end;


  TFHIRBundle4B = class (TFHIRBundleW)
  private
    function bundle : TFhirBundle;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function next(bnd : TFHIRResourceV) : String; overload; override;
    procedure addEntries(bnd : TFHIRResourceV); override;
    procedure addEntry(bnd : TFhirBundleEntryW; first : boolean); overload; override;
    procedure addEntry(url : String; bnd : TFhirResourceV); overload; override;
    function addEntry : TFhirBundleEntryW; overload; override;
    function moveToFirst(res : TFhirResourceV) : TFhirBundleEntryW; override;
    function count(rtype : String = '') : Integer; override;
    procedure clearLinks; override;
    function entries : TFslList<TFhirBundleEntryW>; override;
    procedure listLinks(links : TFslStringDictionary); override;
    function getLink(rel: String): String; override;
    procedure setLink(rel: String; const Value: String); override;
    function getTotal: integer; override;
    procedure setTotal(Value: integer); override;
    function title : String; override;
    function getType : TBundleType; override;
    procedure setType(value: TBundleType); override;
    function getLastUpdated : TFslDateTime; override;
    procedure setLastUpdated(Value: TFslDateTime); override;
    function getTimestamp: TFslDateTime; override;
    procedure setTimestamp(Value: TFslDateTime); override;
  end;

  TFHIROperationOutcomeIssue4B = class (TFHIROperationOutcomeIssueW)
  private
    function issue : TFHIROperationOutcomeIssue;
  public
    function display : String; override;
    function severity : TIssueSeverity; override;
    function getDiagnostics: String; override;
    procedure setDiagnostics(Value: String); override;
  end;

  TFHIRSearchParamDefinition4B = class (TFHIRSearchParamDefinitionW)
  private
    function param : TFhirCapabilityStatementRestResourceSearchParam;
  public
    function name : String; override;
    function documentation : String; override;
    function type_ : TFHIRSearchParamType; override;
  end;

  TFhirCapabilityStatementRestResource4B = class (TFhirCapabilityStatementRestResourceW)
  public
    function getCode: String; override;
    procedure setCode(Value: String); override;
    function getProfile: String; override;
    function hasInteraction : boolean; override;
    procedure setProfile(Value: String); override;
    procedure addInteraction(code : String);  override;
    function getReadHistory: boolean; override;
    procedure setReadHistory(Value: boolean); override;
    procedure addParam(html, n, url, d : String; t : TFHIRSearchParamType; tgts : Array of String); override;
  end;

  TFHIRCapabilityStatement4B = class (TFHIRCapabilityStatementW)
  private
    function statement : TFhirCapabilityStatement;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function hasRest : boolean; override;
    function hasSecurity(system, code : String) : boolean; override;

    procedure readSmartExtension(var authorize, token, register: String); override;
    procedure addSmartExtensions(authorize, token, register, manage: String; caps : Array of String); override;
    function hasFormat(fmt : String) : boolean; override;

    procedure contact(kind : TContactType; value : String); override;
    procedure software(name, version, release : String); override;
    procedure impl(url, desc : String); override;
    procedure fmt(mt : String); override;
    procedure standardServer(ts, ws, pv, cv, iv : String; transactions, search, history : boolean); override;
    procedure defineFeatures(features : TFslList<TFHIRFeature>); override;
    function addResource(code : String) : TFhirCapabilityStatementRestResourceW; override;
    procedure addOperation(name, url : String); override;

    function getURL: String; override;
    procedure setUrl(Value: String); override;
    function getName : String; override;
    procedure setName(value : String); override;
    function getVersion : String; override;
    procedure setVersion(value : String); override;
    function getDescription : String; override;
    procedure setDescription(value : String); override;
    function getStatus: TPublicationStatus; override;
    procedure setStatus(Value: TPublicationStatus); override;
    function getDate: TFslDateTime; override;
    procedure setDate(Value: TFslDateTime); override;
    function getFhirVersion: string; override;
    procedure setFhirVersion(Value: string); override;
    function getKind: TCapabilityStatementKind; override;
    procedure setKind(Value: TCapabilityStatementKind); override;
    function getAcceptUnknown: TCapabilityStatementAcceptUnknown; override;
    procedure setAcceptUnknown(const Value: TCapabilityStatementAcceptUnknown); override;

    function supportsType(name : String; interaction : TFHIRInteraction) : boolean; override;
    procedure listTypes(interactions : TFHIRInteractions; names : TStrings); override;
    procedure listSearchParams(name : String; list : TFslList<TFHIRSearchParamDefinitionW>); override;
    procedure addInstantiates(url : String); override;
  end;

  TFhirElementDefinition4B = class (TFhirElementDefinitionW)
  private
    function edefn : TFhirElementDefinition;
  public
    function path : String; override;
    function min : integer; override;
    function max : integer; override;
    function defn : String; override;
    function types : String; override;
    function typeList : TArray<String>; override;
    function explicitTypeName : String; override;
    function binding : TElementDefinitionBinding; override;
    function isSummary : boolean; override;
    function valueSet : String; override;
  end;

  TFHIRStructureDefinition4B = class (TFhirStructureDefinitionW)
  private
    function sd : TFhirStructureDefinition;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function kind : TStructureDefinitionKind; override;
    function name : String; override;
    function url : String; override;
    function type_ : String; override;
    function elements : TFslList<TFHIRElementDefinitionW>; override;
    function getDefinition(id : String; source : TElementDefinitionSourceOption) : TFHIRElementDefinitionW; override;
  end;

  TFhirParametersParameter4B = class (TFhirParametersParameterW)
  private
    function parameter : TFhirParametersParameter;
  protected
    function getValue: TFHIRObject; override;
    procedure setValue(Value: TFHIRObject); override;
    procedure populateList; override;
    function getParameterParameter(name: String): TFhirParametersParameterW; override;
    function getResourceParameter(name: String): TFHIRResourceV; override;
    function getStringParameter(name: String): String; override;
  public
    function name : String; override;
    function hasValue : boolean; override;
    function valueString : String; override;
    property value : TFHIRObject read GetValue write SetValue;
    function getResource: TFHIRResourceV; override;
    procedure setResource(Value: TFHIRResourceV); override;
    function hasResource : boolean; override;
    procedure addParamBool(name : String; value : boolean); override;
    procedure addParamStr(name : String; value : string); override;
    procedure addParamCode(name : String; value : string); override;
    procedure addParam(name : String; value : TFHIRObject); override;
    function addParam(name : String) : TFhirParametersParameterW; override;
  end;

  TFHIRParameters4B = class (TFHIRParametersW)
  private
    function parameter : TFhirParameters;
  protected
    procedure populateList; override;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    procedure addParamBool(name : String; value : boolean); override;
    procedure addParamStr(name : String; value : string); override;
    procedure addParam(name : String; value : TFHIRObject); overload; override;
    procedure addParamCode(name : String; value : string); override;
    function addParam(name : String) : TFhirParametersParameterW; overload; override;
    function bool(name : String) : boolean; override;
    function str(name : String) : String; override;
    function has(name : String) : boolean; override;
    function obj(name : String) : TFHIRObject; override;
    function getParameter(name: String): TFhirParametersParameterW;  override;
  end;

  TFhirValueSetExpansionContains4B = class (TFhirValueSetExpansionContainsW)
  public
    function getSystem : String; override;
    function getCode : String; override;
    function getDisplay : String; override;
    procedure setCode(Value: String); override;
    procedure setDisplay(Value: String); override;
    procedure setSystem(Value: String); override;
    function contains : TFslList<TFhirValueSetExpansionContainsW>; override;
    procedure addDesignation(lang, use, value : String); override;
  end;

  TFhirValueSetExpansion4B = class (TFhirValueSetExpansionW)
  private
    function exp : TFhirValueSetExpansion;
  public
    procedure addParamStr(name, value : String); override;
    procedure addParamUri(name, value : String); override;
    procedure addParamBool(name : String; value : boolean); override;
    function hasParam(name : string) : boolean; overload; override;
    function hasParam(name, value : string) : boolean; overload; override;
    procedure copyParams(source : TFhirValueSetExpansionW); override;
    procedure addContains(item : TFhirValueSetExpansionContainsW); overload; override;
    function addContains : TFhirValueSetExpansionContainsW; overload; override;
    function makeContains : TFhirValueSetExpansionContainsW; overload; override;
    function contains : TFslList<TFhirValueSetExpansionContainsW>; override;
  end;

  TFhirValueSetComposeIncludeFilter4B = class (TFhirValueSetComposeIncludeFilterW)
  public
    function getProp : String; override;
    function getOp : TFilterOperator; override;
    function getValue : String; override;
    procedure setOp(Value: TFilterOperator); override;
    procedure setProp(Value: String); override;
    procedure setValue(Value: String); override;
  end;

  TFhirValueSetComposeIncludeConceptDesignation4B = class (TFhirValueSetComposeIncludeConceptDesignationW)
  public
    function language : String; override;
    function value : String; override;
  end;

  TFhirValueSetComposeIncludeConcept4B = class (TFhirValueSetComposeIncludeConceptW)
  public
    function getCode : String; override;
    function getDisplay : String; override;
    procedure setCode(Value: String); override;
    procedure setDisplay(Value: String); override;
    function designations : TFslList<TFhirValueSetComposeIncludeConceptDesignationW>; override;
  end;

  TFhirValueSetComposeInclude4B = class (TFhirValueSetComposeIncludeW)
  public
    function getSystem : String; override;
    procedure setSystem(Value: String); override;
    function getVersion : String; override;
    procedure setVersion(Value: String); override;

    function valueSets : TArray<String>; override;
    function hasConcepts : boolean; override;
    function concepts : TFslList<TFhirValueSetComposeIncludeConceptW>; override;
    function addConcept : TFhirValueSetComposeIncludeConceptW; override;
    function hasFilters : boolean; override;
    function hasValueSets : boolean; override;
    function filterCount : integer; override;
    function filters : TFslList<TFhirValueSetComposeIncludeFilterW>; override;
    function addFilter : TFhirValueSetComposeIncludeFilterW; override;
  end;

  TFHIRValueSet4B = class (TFHIRValueSetW)
  private
    FExp : TFhirValueSetExpansionW;
    function vs : TFhirValueSet;
  public
    destructor Destroy; override;
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function getURL : String; override;
    procedure setUrl(value : String); override;
    function getName : String; override;
    procedure setName(value : String); override;
    function getVersion : String; override;
    procedure setVersion(value : String); override;
    function getDescription : String; override;
    procedure setDescription(value : String); override;
    function checkCompose(place, role : String) : boolean; override;
    function imports : TArray<String>; override;
    function inlineCS : TFHIRValueSetCodeSystemW; override;
    function includes : TFslList<TFhirValueSetComposeIncludeW>; override;
    function excludes : TFslList<TFhirValueSetComposeIncludeW>; override;
    procedure clearDefinition; override;
    function hasExpansion : boolean; override;
    function expansion : TFhirValueSetExpansionW; override;
    function forceExpansion : TFhirValueSetExpansionW; override;

    function getStatus: TPublicationStatus; override;
    procedure setStatus(Value: TPublicationStatus); override;
    function getDate: TFslDateTime; override;
    procedure setDate(Value: TFslDateTime); override;
    function hasInlineCS : boolean; override;
    function addInclude : TFhirValueSetComposeIncludeW; override;
    function getContext: String; override;
    function getPublisher: String; override;
    procedure setPublisher(value : String); override;
    function source : String; override;
  end;

  TFHIRLookupOpRequest4B = class (TFHIRLookupOpRequestW)
  public
    procedure load(params : TFHIRResourceV); overload; override;
    procedure load(params : THTTPParameters); overload; override;
    function asParams : TFHIRResourceV; override;
    procedure loadCoding; override;
    function coding : TFHIRCodingW; override;
    function propList : TArray<String>; override;
    function displayLanguage : String; override;
  end;

  TFHIRLookupOpRespProperty4B = class (TFHIRLookupOpRespPropertyW)
  public
    function getDescription: string; override;
    procedure setDescription(Value: string); override;
    function getValue: TFHIRObject; override;
    procedure setValue(Value: TFHIRObject); override;
  end;

  TFHIRLookupOpRespDesignation4B = class (TFHIRLookupOpRespDesignationW)
  public
    function getUse: TFHIRObject; override;
    procedure setUse(Value: TFHIRObject); override;
  end;

  TFHIRLookupOpResponse4B = class (TFHIRLookupOpResponseW)
  public
    procedure load(params : TFHIRResourceV); overload; override;
    procedure load(params : THTTPParameters); overload; override;
    function asParams : TFHIRResourceV; override;
    function addProp(name : string) : TFHIRLookupOpRespPropertyW; override;
    function addDesignation(lang, system, code, display, value : string) : TFHIRLookupOpRespDesignationW; overload; override;
    function addDesignation(lang, value : string) : TFHIRLookupOpRespDesignationW; overload; override;
    function getVersion: String; override;
    procedure setVersion(Value: String); override;
    procedure addExtension(name, value : String); overload; override;
    procedure addExtension(name : String; value : boolean); overload; override;
    function getName: String; override;
    procedure setName(Value: String); override;
    function getDisplay: String; override;
    procedure setDisplay(Value: String); override;
  end;

  TFhirCodeSystemConceptProperty4B = class (TFhirCodeSystemConceptPropertyW)
  public
    function code : String; override;
    function value : TFHIRObject; override;
  end;

  TFhirCodeSystemConceptDesignation4B = class (TFhirCodeSystemConceptDesignationW)
  public
    function language : String; override;
    function useGen : String; override;
    function use : TFHIRObject; override;
    function value : String; override;
  end;

  TFhirCodeSystemConcept4B = class (TFhirCodeSystemConceptW)
  private
    function c : TFhirCodeSystemConcept;
  public
    function code : String; override;
    function display : String; override;
    function definition : String; override;
    function conceptList : TFhirCodeSystemConceptListW; override;
    function concept(ndx : integer) : TFhirCodeSystemConceptW; override;
    function conceptCount : integer; override;
    function hasConcept(c : TFhirCodeSystemConceptW) : boolean; override;
    function designationCount : integer; override;
    function designations : TFslList<TFhirCodeSystemConceptDesignationW>; override;
    function properties : TFslList<TFhirCodeSystemConceptPropertyW>; override;
    function displayTag(tag : String) : String; override;
    procedure setDisplayTag(tag, value : String); override;
    function getCode(code : String) : TFhirCodeSystemConceptW; override;
  end;


  TFhirCodeSystemProperty4B = class (TFhirCodeSystemPropertyW)
  public
    function code : String; override;
    function uri : String; override;
    function type_ : TFhirCodeSystemPropertyType; override;
  end;

  TFhirCodeSystem4B = class (TFhirCodeSystemW)
  private
    function cs : TFhirCodeSystem;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function getURL : String; override;
    function getName : String; override;
    function getVersion : String; override;
    function getDescription : String; override;
    procedure setDate(Value: TFslDateTime); override;
    procedure setDescription(Value: String); override;
    procedure setName(Value: String); override;
    procedure setStatus(Value: TPublicationStatus); override;
    procedure setUrl(Value: String); override;
    procedure setVersion(Value: String); override;
    function getContent: TFhirCodeSystemContentMode; override;
    procedure setContent(Value: TFhirCodeSystemContentMode); override;
    function getCount: integer; override;
    procedure setCount(Value: integer); override;

    function copyright : String; override;
    function language : String; override;
    function valueSet : String; override;
    function supplements : String; override;

    function properties : TFslList<TFhirCodeSystemPropertyW>;  override;
    // this is special because it's owned
    function conceptList : TFhirCodeSystemConceptListW; override;
    function concept(ndx : integer) : TFhirCodeSystemConceptW; override;
    function conceptCount : integer; override;
    function hasConcept(c : TFhirCodeSystemConceptW) : boolean; override;

    function isAbstract(c : TFhirCodeSystemConceptW) : boolean; override;
    function getParents(c : TFhirCodeSystemConceptW) : TFhirCodeSystemConceptListW; override;
    function getChildren(c : TFhirCodeSystemConceptW) : TFhirCodeSystemConceptListW; override;
    function getCode(code : String) : TFhirCodeSystemConceptW; override;

    function getDate: TFslDateTime; override;
    function getStatus: TPublicationStatus; override;
    function buildImplicitValueSet : TFHIRValueSetW; override;
    function getContext: String; override;
    function getPublisher: String; override;
    procedure setPublisher(Value: String); override;
  end;

  TFhirConceptMapGroupElementDependsOn4B = class (TFhirConceptMapGroupElementDependsOnW)
  public
    function property_ : String; override;
    function system_ : String; override;
    function value : String; override;
    function display : String; override;
  end;

  TFhirConceptMapGroupElementTarget4B = class (TFhirConceptMapGroupElementTargetW)
  public
    function code: String; override;
    function equivalence : TFHIRConceptEquivalence; override;
    function comments : String; override;
    function products : TFslList<TFhirConceptMapGroupElementDependsOnW>; override;
  end;

  TFhirConceptMapGroupElement4B = class (TFhirConceptMapGroupElementW)
  public
    function code: String; override;
    function targets : TFslList<TFhirConceptMapGroupElementTargetW>; override;
    function targetCount : integer; override;
    function addTarget(code : String; eq : TFHIRConceptEquivalence) : TFhirConceptMapGroupElementTargetW; override;
  end;

  TFhirConceptMapGroup4B = class (TFhirConceptMapGroupW)
  public
    function elements : TFslList<TFhirConceptMapGroupElementW>; override;
    function addElement(code : String) : TFhirConceptMapGroupElementW; override;
    function source : String; override;
    function target : String; override;
  end;

  TFhirConceptMap4B = class (TFhirConceptMapW)
  private
    function cm : TFhirConceptMap;
  protected
    function getVersion: String; override;
    procedure setVersion(Value: String); override;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function getURL: String; override;
    function getDate: TFslDateTime; override;
    function getDescription: String; override;
    function getName: String; override;
    function getStatus: TPublicationStatus; override;
    procedure setDate(Value: TFslDateTime); override;
    procedure setDescription(Value: String); override;
    procedure setName(Value: String); override;
    procedure setStatus(Value: TPublicationStatus); override;
    procedure setUrl(Value: String); override;
    function source : String; override;
    function target : String; override;
    function groups : TFslList<TFhirConceptMapGroupW>; override;
    function addGroup(source, target : String) : TFhirConceptMapGroupW; override;
    function getContext: String; override;
    function getPublisher: String; override;
    procedure setPublisher(Value: String); override;
    function sourceDesc : String; override;
    function targetDesc : String; override;
  end;

  TFHIRMeta4B = class (TFHIRMetaW)
  private
    FResource : TFHIRResource;
    procedure force;
    procedure setResource(value : TFHIRResource);
    function m : TFhirMeta;
  protected
    function NoElementOk : boolean; override;
    function sizeInBytesV(magic : integer) : cardinal; override;
  public
    destructor Destroy; override;
    property Resource : TFHIRResource read FResource write SetResource;
    function getVersionId: String; override;
    procedure setVersionId(Value: String); override;
    function getLastUpdated: TFslDateTime; override;
    procedure setLastUpdated(Value: TFslDateTime); override;
    function tags : TFslList<TFHIRCodingW>; override;
    function labels : TFslList<TFHIRCodingW>; override;
    function profiles : TArray<String>; override;
    function hasTag(system, code : String) : boolean; override;
    function hasLabel(system, code : String) : boolean; override;
    procedure addTag(system, code, display : String); override;
    procedure addLabel(system, code, display : String); override;
    procedure addProfile(uri : String); override;
    procedure clearTags; override;
    procedure clearLabels; override;
    procedure clearProfiles; override;
    procedure removeTag(system, code : String); override;
    procedure removeLabel(system, code : String); override;
    procedure removeProfile(uri : String); override;
  end;

  TFHIRAuditEvent4B = class (TFhirAuditEventW)
  private
    function ae : TFHIRAuditEvent;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    procedure success; override;
    procedure eventType(system, code, display : String); override;
    procedure eventSubType(system, code, display : String); override;
    procedure source(name, system, value : String); override;
    procedure sourceType(system, code, display : String); override;
    procedure participantIp(ip : String); override;
    procedure participantId(system, value, alt, name : String); override;
    function dateTime : TFslDateTime; override;
  end;

  TFHIRSubscription4B = class (TFHIRSubscriptionW)
  private
    function sub : TFhirSubscription;
  protected
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function getTopic: string; override;
    function getCriteria: String; override;
    function getDirect: boolean; override;
    function getEndpoint: String; override;
    function getError: String; override;
    function getMethod: TSubscriptionMethod; override;
    function getPayload: String; override;
    function getStatus: TSubscriptionStatus; override;
    function getSummary: String; override;
    function getHeaders: TArray<String>; override;
    procedure setCriteria(Value: String); override;
    procedure setDirect(Value: boolean); override;
    procedure setEndpoint(Value: String); override;
    procedure setError(Value: String); override;
    procedure setheaders(Value: TArray<String>); override;
    procedure setMethod(Value: TSubscriptionMethod); override;
    procedure setPayload(Value: String); override;
    procedure setStatus(Value: TSubscriptionStatus); override;
  end;

  TFhirObservationComponent4B = class (TFhirObservationComponentW)
  private
    function comp : TFhirObservationComponent;
  public
    function getValue: TFHIRObject; override;
    procedure setValue(Value: TFHIRObject); override;
    function codings : TFslList<TFHIRCodingW>; override;
    function valueW : TFHIRXVersionElementWrapper; override;
    function valueString : String; override;
    function dataAbsentReason : TFhirCodeableConceptW; override;
  end;

  TFhirObservation4B = class (TFhirObservationW)
  private
    function obs : TFHIRObservation;
  protected
    function getValue: TFHIRObject;  override;
    procedure setValue(Value: TFHIRObject); override;
    function GetDevice: String; override;
    procedure SetDevice(const Value: String); override;
    function GetDeviceName: String; override;
    procedure SetDeviceName(const Value: String); override;
    function GetSubject: String; override;
    procedure SetSubject(const Value: String); override;
    function GetIssued: TFslDateTime; override;
    procedure SetIssued(const Value: TFslDateTime); override;
    function GetEffective: TFHIRObject; override;
    function GetEffectiveDateTime: TFslDateTime; override;
    function GetEffectivePeriod: TFHIRPeriodW; override;
    procedure SetEffective(const Value: TFHIRObject); override;
    procedure SetEffectiveDateTime(const Value: TFslDateTime); override;
    procedure SetEffectivePeriod(const Value: TFHIRPeriodW); override;
    function GetCodeText: String; override;
    procedure SetCodeText(const Value: String); override;
    function GetComment: String; override;
    procedure SetComment(const Value: String); override;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function getStatus: TObservationStatus;  override;
    procedure setStatus(Value: TObservationStatus);  override;
    procedure setCode(c : TFHIRCodingW); overload; override;
    procedure setCode(system, code, display : String); overload; override;
    procedure setCode(text : String); overload; override;
    procedure addCategory(c : TFHIRCodingW); overload; override;
    procedure addCategory(system, code, display : String); overload; override;
    procedure setPeriod(start, finish : TDateTime); override;
    function addComp(system, code : String) : TFhirObservationComponentW; override;
    function codings : TFslList<TFHIRCodingW>; override;
    procedure getDates(var dt, dtMin, dtMax : TDateTime); override;
    function components : TFslList<TFhirObservationComponentW>; override;
    function valueW : TFHIRXVersionElementWrapper; override;
    function dataAbsentReason : TFhirCodeableConceptW; override;
    function categories : TFslList<TFHIRCodingW>; override;
    function hasTime : boolean; override;
    function method(force : boolean) : TFhirCodeableConceptW; override;
    function getComponent(system, code: String; var comp : TFhirObservationComponentW) : boolean; overload; override;
    function getComponent(system : String; var comp : TFhirObservationComponentW) : boolean; overload; override;
    function hasDevice : boolean; override;
    function hasIssued : boolean; override;
    function hasMethod : boolean; override;
    function hasSubject : boolean; override;
    function hasEffective : boolean; override;
  end;

  TFHIRQuantity4B = class (TFHIRQuantityW)
  private
    function qty : TFHIRQuantity;
  protected
    function getCode: String; override;
    function getSystem: String; override;
    function getUnit: String; override;
    function getValue: String; override;
    procedure setCode(Value: String); override;
    procedure setSystem(Value: String); override;
    procedure setUnit(Value: String); override;
    procedure setValue(Value: String); override;
  public
    function asDuration : TDateTime; override;
    function renderText : String; override;
  end;

  TFHIRPeriod4B = class (TFHIRPeriodW)
  private
    function period : TFHIRPeriod;
  protected
    function GetEnd: TFslDateTime; override;
    function GetStart: TFslDateTime; override;
    procedure SetEnd(const Value: TFslDateTime); override;
    procedure SetStart(const Value: TFslDateTime); override;
  public
    function renderText : String; override;
  end;

  TFHIRAttachment4B = class (TFHIRAttachmentW)
  private
    function att : TFhirAttachment;
  protected
    function GetContentType: String; override;
    function GetData: TBytes; override;
  public
    function renderText : String; override;
  end;


  TFHIRSubsumesOpRequest4B = class (TFHIRSubsumesOpRequestW)
  public
    procedure load(params : TFHIRResourceV); overload; override;
    procedure load(params : THTTPParameters); overload; override;
    function asParams : TFHIRResourceV; override;
    function systemUri : String; override;
    function codeA : String; override;
    function codeB : String; override;
    function version : String; override;
    function hasCodingA : boolean; override;
    function hasCodingB : boolean; override;
    function codingA : TFHIRCodingW; override;
    function codingB : TFHIRCodingW; override;
  end;

  TFHIRSubsumesOpResponse4B = class (TFHIRSubsumesOpResponseW)
  public
    procedure load(params : TFHIRResourceV); overload; override;
    procedure load(params : THTTPParameters); overload; override;
    function asParams : TFHIRResourceV; override;
    function getOutcome: String; override;
    procedure setOutcome(Value: String); override;
  end;

  TFHIRGroupCharacteristic4B = class (TFHIRGroupCharacteristicW)
  public
    function code : TFhirCodeableConceptW; override;
    function value : TFhirCodeableConceptW; override;
  end;

  TFHIRGroup4B = class (TFHIRGroupW)
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function name : String; override;
    function hasMembers : boolean; override;
    function hasCharacteristics : boolean; override;
    function characteristics : TFslList<TFHIRGroupCharacteristicW>; override;
  end;

  { TFhirPatient4B }

  TFhirPatient4B = class (TFhirPatientW)
  protected
    function pat : TFHIRPatient;
    function GetActive: boolean; override;
    procedure SetActive(const Value: boolean); override;
    function GetFamily: String; override;
    procedure SetFamily(const Value: String); override;
    function GetDob: String; override;
    procedure SetDob(const Value: String); override;
    function GetIdentifier(systemUri: String): String; override;
    procedure SetIdentifier(systemUri: String; const Value: String); override;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    procedure addGiven(name : String); override;
    function nameSummary : String; override;
    function activeStr : String; override;
    function gender : String; override;
    function identifierSummary : String; override;
    function contactSummary : String; override;
  end;

  TFhirEncounter4B = class (TFhirEncounterW)
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function patientId : String; override;
    function summary : String; override;
  end;

  TFHIRStatsOpResponse4B = class (TFHIRStatsOpResponseW)
  public
    procedure addObs(obs : TFHIRResourceV); override;
    procedure load(params : TFHIRResourceV); overload; override;
    procedure load(params : THTTPParameters); overload; override;
    function asParams : TFHIRResourceV; override;
  end;

  TFHIRNamingSystem4B = class (TFHIRNamingSystemW)
  private
    function nm : TFHIRNamingSystem;
  protected
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function getDate: TFslDateTime; override;
    function getDescription: String; override;
    function getName: String; override;
    function getStatus: TPublicationStatus; override;
    function getURL: String; override;
    procedure setDate(Value: TFslDateTime); override;
    procedure setDescription(Value: String); override;
    procedure setName(Value: String); override;
    procedure setStatus(Value: TPublicationStatus); override;
    procedure setUrl(Value: String); override;
    function getContext: String; override;
    function getPublisher: String; override;
    procedure setPublisher(Value: String); override;
    function getVersion: String; override;
    procedure setVersion(Value: String); override;
  public
    function getUri : String; override;
    function hasOid(oid : String) : boolean; override;
  end;

  TFHIRStructureMap4B = class (TFHIRStructureMapW)
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function url : String; override;
  end;

  TFHIRConsent4B = class (TFHIRConsentW)
  private
    function consent : TFHIRConsent;
  protected
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function GetActive: boolean; override;
    function GetPatient: String; override;
    function GetDateTime: TFslDateTime; override;
  public
    function listProvisions : TFslList<TFhirConsentProvisionW>; override;
  end;

  TFHIREventDefinition4B = class (TFHIREventDefinitionW)
  private
    function ed : TFHIREventDefinition;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function url : String;
    function language : String; override;
    function triggerType : TTriggerType; override;
    function expression : String; override;
    function dataType : String; override;
  end;

  TFhirTerminologyCapabilities4B = class (TFhirTerminologyCapabilitiesW)
  private
    function tc : TFhirTerminologyCapabilities;
  protected
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function getDate: TFslDateTime; override;
    function getDescription: String; override;
    function getName: String; override;
    function getStatus: TPublicationStatus; override;
    function getURL: String; override;
    procedure setDate(Value: TFslDateTime); override;
    procedure setDescription(Value: String); override;
    procedure setName(Value: String); override;
    procedure setStatus(Value: TPublicationStatus); override;
    procedure setUrl(Value: String); override;
    function getContext: String; override;
    procedure setContext(Value: String); override;
    function getPublisher: String; override;
    procedure setPublisher(Value: String); override;
    function getVersion: String; override;
    procedure setVersion(Value: String); override;
  public
    procedure contact(kind : TContactType; value : String); override;
    procedure systemUri(url : String); override;
    procedure addExpansionParameter(code, doco : String); override;
  end;

  TFHIRTestScript4B = class (TFHIRTestScriptW)
  private
    function ts : TFHIRTestScript;
  protected
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function getURL: String; override;
    function getName: String; override;
    function getStatus: TPublicationStatus; override;
    function getVersion: String; override;
    function getDescription: String; override;
    function getDate: TFslDateTime; override;
    function getPublisher: String; override;
    procedure setPublisher(Value: String); override;
    procedure setDate(Value: TFslDateTime); override;
    procedure setUrl(Value: String); override;
    procedure setVersion(Value: String); override;
    procedure setName(Value: String); override;
    procedure setStatus(Value: TPublicationStatus); override;
    procedure setDescription(Value: String); override;
    function getContext: String; override;
  end;

  TFhirProvenance4B = class (TFhirProvenanceW)
  private
    function p : TFhirProvenance;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    procedure clearTargets; override;
    procedure clearSignatures; override;
    procedure addTarget(url : String); override;
  end;

  TFhirImmunization4B = class (TFhirImmunizationW)
  private
    function imm : TFhirImmunization;
  protected
    function GetLotNumber: String; override;
    function GetPatient: String; override;
    function GetPerformerDisplay: String; override;
    function GetStatus: string; override;
    procedure SetLotNumber(const Value: String); override;
    procedure SetPatient(const Value: String); override;
    procedure SetPerformerDisplay(const Value: String); override;
    procedure SetStatus(const Value: string); override;
    function GetManufacturerIdSystem: String; override;
    function GetManufacturerIdValue: String; override;
    procedure SetManufacturerIdSystem(const Value: String); override;
    procedure SetManufacturerIdValue(const Value: String); override;
    function GetDate: TFslDateTime; override;
    procedure SetDate(const Value: TFslDateTime); override;
  public
    function GetLanguage: String; override;
    procedure SetLanguage(const Value: String); override;
    function code(systemUri : String) : String; override;
    function hasCode(systemUri, code : String) : boolean; override;
    procedure setCodeBySystem(systemUri : String; code : String); override;
  end;


implementation

uses
  fhir4b_utilities;

{ TFhirOperationOutcome4B }

procedure TFhirOperationOutcome4B.addIssue(issue: TFhirOperationOutcomeIssueW; free : boolean);
begin
  (Fres as TFhirOperationOutcome).issueList.Add((issue.Element as TFhirOperationOutcomeIssue).link);
  if free then
    issue.Free;
end;

function TFhirOperationOutcome4B.code: TFhirIssueType;
var
  a : TFhirIssueType;
  op : TFhirOperationOutcome;
begin
  op := Fres as TFhirOperationOutcome;
  result := itNull;
  if not op.issueList.IsEmpty then
    for a := low(TFhirIssueType) to High(TFhirIssueType) do
      if ExceptionTypeTranslations[a] = op.issueList[0].code then
       exit(a);
end;

function TFhirOperationOutcome4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFhirOperationOutcome4B.hasErrors: boolean;
begin
  result := (Fres as TFhirOperationOutcome).hasErrors;
end;

function TFhirOperationOutcome4B.hasIssues: boolean;
var
  op : TFhirOperationOutcome;
begin
  op := Fres as TFhirOperationOutcome;
  result := not op.issueList.IsEmpty;
end;

function TFhirOperationOutcome4B.hasText: boolean;
var
  op : TFhirOperationOutcome;
begin
  op := Fres as TFhirOperationOutcome;
  if (op.text <> nil) and (op.text.div_ <> nil) then
    result := true
  else if (op.issueList.Count > 0) and (op.issueList[0].diagnostics <> '') then
    result := true
  else
    result := false;
end;

function TFhirOperationOutcome4B.issueCount: integer;
begin
  result := (resource as TFhirOperationOutcome).issueList.Count;
end;

function TFhirOperationOutcome4B.issues: TFslList<TFhirOperationOutcomeIssueW>;
var
  iss : TFhirOperationOutcomeIssue;
begin
  result := TFslList<TFhirOperationOutcomeIssueW>.create;
  for iss in (resource as TFhirOperationOutcome).issueList do
    result.Add(TFHIROperationOutcomeIssue4B.Create(iss.Link));
end;

function TFhirOperationOutcome4B.rule(level: TIssueSeverity; source: String; typeCode: TFhirIssueType; path: string; test: boolean; msg: string): boolean;
begin
  result := (resource as TFhirOperationOutcome).rule(ISSUE_SEVERITY_MAP2[level], source, ExceptionTypeTranslations[typeCode], path, test, msg);
end;

procedure TFhirOperationOutcome4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

function TFhirOperationOutcome4B.severity: TIssueSeverity;
begin
  if (resource as TFhirOperationOutcome).issueList.Count > 0 then
    result := ISSUE_SEVERITY_MAP[(resource as TFhirOperationOutcome).issueList[0].severity]
  else
    result := isFatal;
end;

function TFhirOperationOutcome4B.text: String;
var
  op : TFhirOperationOutcome;
begin
  op := Fres as TFhirOperationOutcome;
  if (op.text <> nil) and (op.text.div_ <> nil) then
    result := op.text.div_.AsPlainText
  else if (op.issueList.Count > 0) and (op.issueList[0].diagnostics <> '') then
    result := op.issueList[0].diagnostics
  else
    result := '';
end;

{ TFHIRBundle4B }

procedure TFHIRBundle4B.addEntries(bnd: TFHIRResourceV);
var
  b : TFHIRBundle;
begin
  b := bnd as TFHIRBundle;
  bundle.entryList.AddAll(b.entryList);
end;

procedure TFHIRBundle4B.addEntry(bnd: TFhirBundleEntryW; first: boolean);
begin
  if first then
    bundle.entryList.InsertItem(0, bnd.element.link as TFHIRBundleEntry)
  else
    bundle.entryList.AddItem(bnd.element.link as TFHIRBundleEntry);
end;

procedure TFHIRBundle4B.addEntry(url: String; bnd: TFhirResourceV);
var
  e : TFHIRBundleEntry;
begin
  e := bundle.entryList.Append;
  e.fullUrl := url;
  e.resource := bnd as TFhirResource;
end;

function TFHIRBundle4B.addEntry: TFhirBundleEntryW;
begin
  result := TFhirBundleEntry4B.create(bundle.entryList.append.link);
end;

function TFHIRBundle4B.bundle: TFhirBundle;
begin
  result := resource as TFHIRBundle;
end;

procedure TFHIRBundle4B.clearLinks;
begin
  bundle.link_List.Clear;
end;

function TFHIRBundle4B.count(rtype: String): Integer;
var
  be : TFhirBundleEntry;
begin
  result := 0;
  for be in bundle.entryList do
    if (be.resource <> nil) and ((rtype = '') or (rtype = be.resource.fhirType)) then
      inc(result);
end;

function TFHIRBundle4B.entries: TFslList<TFhirBundleEntryW>;
var
  be : TFHIRBundleEntry;
begin
  result := TFslList<TFhirBundleEntryW>.create;
  try
    for be in bundle.entryList do
      result.Add(TFhirBundleEntry4B.create(be.Link));
    result.Link;
  finally
    result.Free;
  end;
end;

function TFHIRBundle4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFHIRBundle4B.GetLastUpdated: TFslDateTime;
begin
  if bundle.meta <> nil then
    result := TFslDateTime.makeNull
  else
    result := bundle.meta.lastUpdated;
end;

function TFHIRBundle4B.GetLink(rel: String): String;
begin
  result := bundle.Links[rel];
end;

procedure TFHIRBundle4B.listLinks(links: TFslStringDictionary);
var
  bl : TFhirBundleLink;
begin
  links.Clear;
  for bl in bundle.link_List do
    links.AddOrSetValue(bl.relation, bl.url);
end;

function TFHIRBundle4B.moveToFirst(res: TFhirResourceV): TFhirBundleEntryW;
var
  fu : String;
  i : integer;
begin
  for i := bundle.entryList.Count -1 downto 0 do
    if bundle.entryList[i].resource = res then
    begin
      fu := bundle.entryList[i].fullurl;
      bundle.entrylist.DeleteByIndex(i);
    end;
  bundle.entryList.Insert(0).resource := res.Link as TFHIRResource;
  bundle.entryList[0].fullurl := fu;
  result := TFHIRBundleEntry4B.Create(bundle.entryList[0].Link);
end;

function TFHIRBundle4B.next(bnd: TFHIRResourceV): String;
var
  b : TFHIRBundle;
begin
  b := bnd as TFHIRBundle;
  result := b.Links['next'];
end;

procedure TFHIRBundle4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

procedure TFHIRBundle4B.SetLastUpdated(Value: TFslDateTime);
begin
  if bundle.meta = nil then
    bundle.meta := TFHIRMeta.Create;
  bundle.meta.lastUpdated := value;
end;

procedure TFHIRBundle4B.SetLink(rel: String; const Value: String);
begin
  bundle.Links[rel] := value;
end;

procedure TFHIRBundle4B.SetTimestamp(Value: TFslDateTime);
begin
  bundle.timestamp := value;
end;

procedure TFHIRBundle4B.SetTotal(Value: integer);
begin
  bundle.total := inttostr(value);
end;

procedure TFHIRBundle4B.settype(value: TBundleType);
begin
  bundle.type_ := MAP_TFHIRBundleType[value];
end;

function TFHIRBundle4B.title: String;
begin
  result := BUNDLE_TYPE_TITLE[bundle.type_];
end;

function TFHIRBundle4B.GetTimestamp: TFslDateTime;
begin
  if bundle.timestampElement <> nil then
    result := bundle.timestamp
  else if bundle.meta <> nil then
    result := bundle.meta.lastUpdated
  else
    result := TFslDateTime.makeNull;
end;

function TFHIRBundle4B.gettotal: integer;
begin
  result := StrToIntDef(bundle.total, -1);
end;

function TFHIRBundle4B.gettype: TBundleType;
begin
  result := MAP_TFHIRBundleTypeR[bundle.type_];
end;

{ TFHIROperationOutcomeIssue4B }

function TFHIROperationOutcomeIssue4B.display: String;
var
  i : TFHIROperationOutcomeIssue;
begin
  i := issue;
  result := i.diagnostics;
  if (i.details <> nil) and (i.details.text <> '') then
    result := i.details.text;
end;

function TFHIROperationOutcomeIssue4B.issue: TFHIROperationOutcomeIssue;
begin
  result := Element as TFHIROperationOutcomeIssue;
end;

function TFHIROperationOutcomeIssue4B.severity: TIssueSeverity;
begin
  result := ISSUE_SEVERITY_MAP[issue.severity];
end;

function TFHIROperationOutcomeIssue4B.GetDiagnostics: String;
begin
  result := issue.diagnostics;
end;

procedure TFHIROperationOutcomeIssue4B.SetDiagnostics(Value: String);
begin
  issue.diagnostics := value;
end;


{ TFHIRCapabilityStatement4B }

procedure TFHIRCapabilityStatement4B.addInstantiates(url: String);
begin
  statement.instantiatesList.Append.value := url;
end;

procedure TFHIRCapabilityStatement4B.addOperation(name, url: String);
var
  t : TFhirCapabilityStatementRestResourceOperation;
begin
  t := statement.restList[0].operationList.append;
  t.name := name;
  t.definition := url;
end;

function TFHIRCapabilityStatement4B.addResource(code: String): TFhirCapabilityStatementRestResourceW;
begin
  result := TFhirCapabilityStatementRestResource4B.create(statement.restList[0].resourceList.append.link);
  result.code := code;
end;

procedure TFHIRCapabilityStatement4B.addSmartExtensions(authorize, token, register, manage: String; caps : Array of String);
var
  c: TFHIRCoding;
  ext: TFhirExtension;
  s : string;
begin
  if statement.restList.isEmpty then
    statement.restList.append.mode := RestfulCapabilityModeServer;

  if statement.restList[0].security = nil then
    statement.restList[0].security := TFhirCapabilityStatementRestSecurity.Create;
  statement.restList[0].security.cors := true;
  if authorize <> '' then
  begin
    c := statement.restList[0].security.serviceList.Append.codingList.Append;
    c.System := 'http://hl7.org/fhir/restful-security-service';
    c.code := 'SMART-on-FHIR';
    c.display := 'SMART-on-FHIR';
    statement.restList[0].security.description := 'This server implements OAuth2 for login using the Smart App Launch profile';

    ext := statement.restList[0].security.extensionList.Append;
    ext.url := 'http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris';
    // ext.addExtension('dscovery', TFhirUri.Create(ExcludeTrailingPathDelimiter(FServerContext.FormalURLSecure)+FAuthServer.AuthPath+'/discovery'));
    ext.addExtensionUri('register', register);
    ext.addExtensionUri('authorize', authorize);
    ext.addExtensionUri('token', token);
    ext.addExtensionUri('manage', manage);
    for s in caps do
      statement.restList[0].security.addExtension('http://fhir-registry.smarthealthit.org/StructureDefinition/capabilities', s);
  end;
end;

procedure TFHIRCapabilityStatement4B.contact(kind: TContactType; value: String);
var
  c : TFhirContactPoint;
  ct : TFhirConformanceContact;
begin
  ct := statement.contactList.Append;
  c := ct.telecomList.Append;
  c.system := MAP_TContactType[kind];
  c.value := 'http://healthintersections.com.au/';
end;

procedure TFHIRCapabilityStatement4B.defineFeatures(features: TFslList<TFHIRFeature>);
begin
end;

function TFHIRCapabilityStatement4B.getURL: String;
begin
  result := statement.url;
end;

function TFHIRCapabilityStatement4B.hasFormat(fmt: String): boolean;
begin
  result := statement.formatList.hasCode(fmt);
end;

function TFHIRCapabilityStatement4B.hasRest: boolean;
begin
  result := statement.restList.Count > 0;
end;

function TFHIRCapabilityStatement4B.hasSecurity(system, code: String): boolean;
var
  cs : TFHIRCapabilityStatement;
  cc : TFhirCodeableConcept;
begin
  cs := statement;
  result := false;
  if (cs.restList[0].security <> nil) then
    for cc in cs.restList[0].security.serviceList do
      if cc.hasCode(system, code) then
        exit(true);
end;

procedure TFHIRCapabilityStatement4B.impl(url, desc: String);
begin
  if statement.implementation_ = nil then
    statement.implementation_ := TFhirCapabilityStatementImplementation.Create;
  statement.implementation_.description := desc;
  statement.implementation_.url := url;
end;

procedure TFHIRCapabilityStatement4B.listSearchParams(name: String; list: TFslList<TFHIRSearchParamDefinitionW>);
var
  r : TFhirCapabilityStatementRest;
  rr : TFhirCapabilityStatementRestResource;
  sp : TFhirCapabilityStatementRestResourceSearchParam;
begin
  for r in statement.restList do
  begin
    if r.mode = RestfulCapabilityModeServer then
    begin
      if name = 'All Types' then
        for sp in r.searchParamList do
          list.Add(TFHIRSearchParamDefinition4B.create(sp.Link))
      else
      begin
        for rr in r.resourceList do
        begin
          if CODES_TFHIRResourceTypesEnum[rr.type_] = name then
            for sp in rr.searchParamList do
              list.Add(TFHIRSearchParamDefinition4B.create(sp.Link))
        end;
      end;
    end;
  end;
end;

procedure TFHIRCapabilityStatement4B.listTypes(interactions: TFHIRInteractions; names: TStrings);
var
  r : TFhirCapabilityStatementRest;
  it : TFhirCapabilityStatementRestInteraction;
  rr : TFhirCapabilityStatementRestResource;
  ok : boolean;
  int : TFhirCapabilityStatementRestResourceInteraction;
  i : TFHIRInteraction;
begin
  for r in statement.restList do
  begin
    if r.mode = RestfulCapabilityModeServer then
    begin
      ok := false;
      for it in r.interactionList do
        for i in ALL_INTERACTIONS do
          if (i in interactions) and (it.code = INTERACTION_MAP2[i]) then
            ok := true;
      if ok then
        names.Add('All Types');
      for rr in r.resourceList do
      begin
        ok := false;
        for int in rr.interactionList do
          for i in ALL_INTERACTIONS do
            if (i in interactions) and (int.code = INTERACTION_MAP[i]) then
              ok := true;
        if ok then
          names.Add(CODES_TFHIRResourceTypesEnum[rr.type_]);
      end;
    end;
  end;
end;

procedure TFHIRCapabilityStatement4B.readSmartExtension(var authorize, token, register: String);
var
  ex1, ex2 : TFhirExtension;
begin
  for ex1 in statement.restList[0].security.extensionList do
    if ex1.url = 'http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris' then
      for ex2 in ex1.extensionList do
        if ex2.url = 'authorize' then
          authorize := TFHIRUri(ex2.value).value
        else if ex2.url = 'token' then
          token := TFHIRUri(ex2.value).value
        else if ex2.url = 'register' then
          register := TFHIRUri(ex2.value).value;
end;

procedure TFHIRCapabilityStatement4B.SetUrl(Value: String);
begin
  statement.url := value;
end;

function TFHIRCapabilityStatement4B.getName : String;
begin
  result := statement.Name;
end;

procedure TFHIRCapabilityStatement4B.setName(value : String);
begin
  statement.Name := value;
end;

function TFHIRCapabilityStatement4B.getVersion : String;
begin
  result := statement.Version;
end;

procedure TFHIRCapabilityStatement4B.setVersion(value : String);
begin
  statement.Version := value;
end;

procedure TFHIRCapabilityStatement4B.software(name, version, release: String);
begin
  if statement.software = nil then
    statement.software := TFhirCapabilityStatementSoftware.Create;
  statement.software.name := name;
  statement.software.version := version;
  statement.software.releaseDate := TFslDateTime.fromHL7(release);
end;

function TFHIRCapabilityStatement4B.getDescription : String;
begin
  result := statement.Description;
end;

function TFHIRCapabilityStatement4B.GetFhirVersion: string;
begin
  result := CODES_TFhirFHIRVersionEnum[statement.fhirVersion];
end;

procedure TFHIRCapabilityStatement4B.setDescription(value : String);
begin
  statement.Description := value;
end;

procedure TFHIRCapabilityStatement4B.SetFhirVersion(Value: string);
begin
  statement.fhirVersion := TFhirFHIRVersionEnum(StringArrayIndexOfSensitive(CODES_TFhirFHIRVersionEnum, value));
end;

function TFHIRCapabilityStatement4B.GetStatus: TPublicationStatus;
begin
  result := MAP_TPublicationStatusR[statement.Status];
end;

procedure TFHIRCapabilityStatement4B.SetStatus(Value: TPublicationStatus);
begin
  statement.Status := MAP_TPublicationStatus[value];
end;

procedure TFHIRCapabilityStatement4B.fmt(mt: String);
begin
  statement.formatList.Append.value := mt;
end;

function TFHIRCapabilityStatement4B.GetDate: TFslDateTime;
begin
  result := statement.Date;
end;

procedure TFHIRCapabilityStatement4B.SetDate(Value: TFslDateTime);
begin
  statement.Date := value;
end;


procedure TFHIRCapabilityStatement4B.standardServer(ts, ws, pv, cv, iv: String; transactions, search, history : boolean);
//var
//  ext : TFhirExtension;
begin
  if statement.restList.isEmpty then
    statement.restList.append.mode := RestfulCapabilityModeServer;
  if (ws <> '') then
    statement.restList[0].addExtension('http://hl7.org/fhir/StructureDefinition/capabilitystatement-websocket', ws);
  if transactions then
    statement.restList[0].interactionList.Append.code := SystemRestfulInteractionTransaction;
  if search then
    statement.restList[0].interactionList.Append.code := SystemRestfulInteractionSearchSystem;
  if history then
    statement.restList[0].interactionList.Append.code := SystemRestfulInteractionHistorySystem;
  statement.text := TFhirNarrative.create;
  statement.text.status := NarrativeStatusGenerated;
  if (ts <> '') then
    statement.instantiatesList.AddItem(TFHIRCanonical.Create(ts));
  // commented out until we sort out cds-hooks
//  ext := statement.restList[0].addExtension('http://fhir-registry.smarthealthit.org/StructureDefinition/cds-activity');
//  ext.addExtension('name', 'Fetch Patient Alerts');
//  ext.addExtension('activity', pv);
//  ext.addExtension('preFetchOptional', 'Patient/{{Patient.id}}');
//  ext := statement.restList[0].addExtension('http://fhir-registry.smarthealthit.org/StructureDefinition/cds-activity');
//  ext.addExtension('name', 'Get Terminology Information');
//  ext.addExtension('activity', cv);
//  ext := statement.restList[0].addExtension('http://fhir-registry.smarthealthit.org/StructureDefinition/cds-activity');
//  ext.addExtension('name', 'Get identifier Information');
//  ext.addExtension('activity', iv);
end;

function TFHIRCapabilityStatement4B.statement: TFhirCapabilityStatement;
begin
  result := FRes as TFHIRCapabilityStatement;
end;

function TFHIRCapabilityStatement4B.supportsType(name: String; interaction: TFHIRInteraction): boolean;
var
  r : TFhirCapabilityStatementRest;
  it : TFhirCapabilityStatementRestInteraction;
  rr : TFhirCapabilityStatementRestResource;
  ok : boolean;
  int : TFhirCapabilityStatementRestResourceInteraction;
  i : TFHIRInteraction;
begin
  result := false;
  for r in statement.restList do
  begin
    if r.mode = RestfulCapabilityModeServer then
    begin
      if name = 'All Types' then
      begin
        ok := false;
        for it in r.interactionList do
          for i in ALL_INTERACTIONS do
            if (i = interaction) and (it.code = INTERACTION_MAP2[i]) then
              ok := true;
        exit(ok);
      end
      else
      begin
        for rr in r.resourceList do
        begin
          if CODES_TFHIRResourceTypesEnum[rr.type_] = name then
          begin
            ok := false;
            for int in rr.interactionList do
              for i in ALL_INTERACTIONS do
                if (i = interaction) and (int.code = INTERACTION_MAP[i]) then
                  ok := true;
            if ok then
              exit(ok);
          end;
        end;
      end;
    end;
  end;
end;

function TFHIRCapabilityStatement4B.getKind: TCapabilityStatementKind;
begin
  case statement.kind of
    CapabilityStatementKindInstance : result := cskInstance;
    CapabilityStatementKindCapability : result := cskCapability;
    CapabilityStatementKindRequirements : result := cskRequirements;
  else
    result := cskNull;
  end;
end;

function TFHIRCapabilityStatement4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

procedure TFHIRCapabilityStatement4B.setKind(Value: TCapabilityStatementKind);
begin
  case value of
    cskInstance : statement.kind := CapabilityStatementKindInstance;
    cskCapability : statement.kind := CapabilityStatementKindCapability;
    cskRequirements : statement.kind := CapabilityStatementKindRequirements;
  else
    statement.kind := CapabilityStatementKindNull;
  end;
end;

procedure TFHIRCapabilityStatement4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

function TFHIRCapabilityStatement4B.getAcceptUnknown: TCapabilityStatementAcceptUnknown;
begin
  result := csauNull;
end;

procedure TFHIRCapabilityStatement4B.setAcceptUnknown(const Value: TCapabilityStatementAcceptUnknown);
begin
end;


{ TFhirParametersParameter4B }

function TFhirParametersParameter4B.addParam(name: String): TFhirParametersParameterW;
begin
  result := TFhirParametersParameter4B.Create(parameter.partList.Append.link);
  TFhirParametersParameter4B(result).parameter.name := name;
  PartList.Add(result);
end;

procedure TFhirParametersParameter4B.addParam(name: String; value: TFHIRObject);
begin
  parameter.AddParameter(name).value := value as TFHIRDataType;
end;

procedure TFhirParametersParameter4B.addParamBool(name: String; value: boolean);
begin
  parameter.AddParameter(name).value := TFHIRBoolean.Create(value);
end;

procedure TFhirParametersParameter4B.addParamCode(name, value: string);
begin
  parameter.AddParameter(name).value := TFHIRCode.Create(value);
end;

procedure TFhirParametersParameter4B.addParamStr(name, value: string);
begin
  parameter.AddParameter(name).value := TFHIRString.Create(value);
end;

function TFhirParametersParameter4B.GetParameterParameter(name: String): TFhirParametersParameterW;
var
  t : TFhirParametersParameterW;
  s : String;
begin
  if FList = nil then
    populateList;
  result := nil;
  for t in FList do
    if t.name = name then
    begin
      result := t;
      break;
    end;
  s := result.asJson;
end;

function TFhirParametersParameter4B.GetResource: TFHIRResourceV;
begin
  result := parameter.resource;
end;

function TFhirParametersParameter4B.GetResourceParameter(name: String): TFHIRResourceV;
var
  t : TFhirParametersParameterW;
begin
  if FList = nil then
    populateList;
  result := nil;
  for t in FList do
    if t.name = name then
      exit(TFhirParametersParameter4B(t).parameter.resource);
end;

function TFhirParametersParameter4B.GetStringParameter(name: String): String;
var
  t : TFhirParametersParameterW;
begin
  if FList = nil then
    populateList;
  result := '';
  for t in FList do
    if t.name = name then
      exit(TFhirParametersParameter4B(t).parameter.value.primitiveValue);
end;

function TFhirParametersParameter4B.GetValue: TFHIRObject;
begin
  result := parameter.value;
end;

function TFhirParametersParameter4B.hasResource: boolean;
begin
  result := parameter.resource <> nil;
end;

function TFhirParametersParameter4B.hasValue: boolean;
begin
  result := parameter.value <> nil;
end;

function TFhirParametersParameter4B.name: String;
begin
  result := parameter.name;
end;

function TFhirParametersParameter4B.parameter: TFhirParametersParameter;
begin
  result := Element as TFhirParametersParameter;
end;

procedure TFhirParametersParameter4B.populateList;
var
  t : TFhirParametersParameter;
begin
  inherited;
  for t in parameter.partList do
    FList.Add(TFhirParametersParameter4B.Create(t.Link));
end;

procedure TFhirParametersParameter4B.SetResource(Value: TFHIRResourceV);
begin
  parameter.resource := value as TFhirResource;
end;

procedure TFhirParametersParameter4B.SetValue(Value: TFHIRObject);
begin
  parameter.value := value as TFHIRDataType;
end;

function TFhirParametersParameter4B.valueString: String;
begin
  if parameter.value = nil then
    result := ''
  else
    result := parameter.value.primitiveValue;
end;

{ TFHIRParameters4B }

function TFhirParameters4B.addParam(name: String): TFhirParametersParameterW;
begin
  result := TFhirParametersParameter4B.Create(parameter.parameterList.Append.link);
  TFhirParametersParameter4B(result).parameter.name := name;
  ParameterList.Add(result);
end;

procedure TFhirParameters4B.addParam(name: String; value: TFHIRObject);
begin
  parameter.AddParameter(name).value := value as TFHIRDataType;
end;

procedure TFhirParameters4B.addParamBool(name: String; value: boolean);
begin
  parameter.AddParameter(name).value := TFHIRBoolean.Create(value);
end;

procedure TFhirParameters4B.addParamCode(name, value: string);
begin
  parameter.AddParameter(name).value := TFHIRCode.Create(value);
end;

procedure TFhirParameters4B.addParamStr(name, value: string);
begin
  parameter.AddParameter(name).value := TFHIRString.Create(value);
end;

function TFHIRParameters4B.bool(name: String): boolean;
begin
  result := parameter.bool[name];
end;

function TFHIRParameters4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFHIRParameters4B.GetParameter(name: String): TFhirParametersParameterW;
var
  t : TFhirParametersParameterW;
begin
  if FList = nil then
    populateList;
  result := nil;
  for t in FList do
    if t.name = name then
      exit(t);
end;

function TFHIRParameters4B.has(name: String): boolean;
begin
  result := parameter.hasParameter(name);
end;

function TFHIRParameters4B.obj(name: String): TFHIRObject;
var
  p : TFhirParametersParameter;
begin
  if has(name) then
  begin
    p := parameter.param[name];
    if p.resource <> nil then
      result := p.resource
    else
      result := p.value;
  end
  else
    result := nil;
end;

function TFHIRParameters4B.parameter: TFhirParameters;
begin
  result := Resource as TFhirParameters;
end;

procedure TFHIRParameters4B.populateList;
var
  t : TFhirParametersParameter;
begin
  inherited;
  for t in parameter.parameterList do
    FList.Add(TFhirParametersParameter4B.Create(t.Link));
end;

procedure TFHIRParameters4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

function TFHIRParameters4B.str(name: String): String;
begin
  result := parameter.str[name];
end;

{ TFHIRStructureDefinition4B }

function TFHIRStructureDefinition4B.elements: TFslList<TFHIRElementDefinitionW>;
var
  ed : TFhirElementDefinition;
begin
  result := TFslList<TFHIRElementDefinitionW>.create;
  try
    for ed in sd.snapshot.elementList do
      result.Add(TFhirElementDefinition4B.create(ed.Link));
    result.link;
  finally
    result.Free;
  end;
end;

function TFHIRStructureDefinition4B.getDefinition(id: String; source: TElementDefinitionSourceOption): TFHIRElementDefinitionW;
var
  ed : TFhirElementDefinition;
begin
  result := nil;
  if (source in [edsSNAPSHOT, edsEITHER]) and (sd.snapshot <> nil) then
    for ed in sd.snapshot.elementList do
      if ed.id = id then
        exit(TFHIRElementDefinition4B.Create(ed.Link));

  if (source in [edsDIFF, edsEITHER]) and (sd.differential <> nil) then
    for ed in sd.differential.elementList do
      if ed.id = id then
        exit(TFHIRElementDefinition4B.Create(ed.Link));
end;

function TFHIRStructureDefinition4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFHIRStructureDefinition4B.kind: TStructureDefinitionKind;
begin
  case sd.kind of
    StructureDefinitionKindPrimitiveType : result := sdkPrimitive;
    StructureDefinitionKindComplexType :
      if type_ = 'Extension' then
          result := sdkExtension
        else
          result := sdkDataType;
    StructureDefinitionKindResource : result := sdkResource;
    StructureDefinitionKindLogical : result := sdkResource;
  else
    raise EFHIRException.create('unhandled value');
  end;
end;

function TFHIRStructureDefinition4B.name: String;
begin
  result := sd.name;
end;

function TFHIRStructureDefinition4B.sd: TFhirStructureDefinition;
begin
  result := resource as TFhirStructureDefinition;
end;

procedure TFHIRStructureDefinition4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

function TFHIRStructureDefinition4B.type_: String;
begin
  result := sd.type_;
end;

function TFHIRStructureDefinition4B.url: String;
begin
  result := sd.url;
end;

{ TFHIRSearchParamDefinition4B }

function TFHIRSearchParamDefinition4B.documentation: String;
begin
  result := param.documentation;
end;

function TFHIRSearchParamDefinition4B.name: String;
begin
  result := param.name;
end;

function TFHIRSearchParamDefinition4B.param: TFhirCapabilityStatementRestResourceSearchParam;
begin
  result := FElement as TFhirCapabilityStatementRestResourceSearchParam;
end;

function TFHIRSearchParamDefinition4B.type_: TFHIRSearchParamType;
begin
  result := MAP_SearchParamType[param.type_];
end;

{ TFhirElementDefinition4B }

function TFhirElementDefinition4B.binding: TElementDefinitionBinding;
var
  b : TFhirElementDefinitionBinding;
begin
  b := edefn.binding;
  if b = nil then
    result := edbNone
  else
    result := MAP_ELEMENT_DEFINITION_BINDING[b.strength];
end;

function TFhirElementDefinition4B.defn: String;
begin
  result := edefn.definition;
end;

function TFhirElementDefinition4B.edefn: TFhirElementDefinition;
begin
  result := element as TFhirElementDefinition;
end;

function TFhirElementDefinition4B.explicitTypeName: String;
begin
  result := edefn.getExtensionString('http://hl7.org/fhir/StructureDefinition/structuredefinition-explicit-type-name');
end;

function TFhirElementDefinition4B.isSummary: boolean;
begin
  result := edefn.isSummary;
end;

function TFhirElementDefinition4B.max: integer;
begin
  if edefn.max = '*' then
    result := MaxInt
  else
    result := StrToInt(edefn.max);
end;

function TFhirElementDefinition4B.min: integer;
begin
  result := StrToInt(edefn.min);
end;

function TFhirElementDefinition4B.path: String;
begin
  result := edefn.path;
end;

function TFhirElementDefinition4B.typeList: TArray<String>;
var
  ed : TFhirElementDefinition;
  i : integer;
begin
  ed := edefn;
  Setlength(result, ed.type_List.Count);
  for i := 0 to ed.type_List.Count - 1 do
    result[i] := ed.type_List[i].code;
end;

function TFhirElementDefinition4B.types: String;
var
  t : TFhirElementDefinitionType;
begin
  result := '';
  for t in edefn.type_List do
  begin
    if result <> '' then
      result := result+'|';
    result := result + t.code;
  end;
end;

function TFhirElementDefinition4B.valueSet: String;
var
  b : TFhirElementDefinitionBinding;
begin
  b := edefn.binding;
  if b <> nil then
    result := b.valueSet
  else
    result := '';
end;

{ TFHIRBundleEntry4B }

function TFHIRBundleEntry4B.entry: TFhirBundleEntry;
begin
  result := element as TFhirBundleEntry;
end;

function TFHIRBundleEntry4B.getRequestMethod: String;
begin
  if entry.request = nil then
    result := ''
  else
    result := CODES_TFhirHttpVerbEnum[entry.request.method];
end;

function TFHIRBundleEntry4B.getRequestUrl: String;
begin
  if entry.request = nil then
    result := ''
  else
    result :=  entry.request.url;
end;

function TFHIRBundleEntry4B.getResource: TFHIRResourceV;
begin
  result := entry.resource;
end;

function TFHIRBundleEntry4B.GetResponseDate: TFslDateTime;
begin
  if entry.response = nil then
    result := TFslDateTime.makeNull
  else
    result := entry.response.lastModified;
end;

function TFHIRBundleEntry4B.GetResponseStatus: String;
begin
  if entry.response = nil then
    result := ''
  else
    result := entry.response.status;
end;

function TFHIRBundleEntry4B.getSearchMode: TFHIRBundleEntrySearchMode;
begin
  if entry.search = nil then
    result := smUnknown
  else
    result := MAP_SEARCH_MODE[entry.search.mode];
end;

function TFHIRBundleEntry4B.getSearchMpiMatch: String;
begin
  if entry.search = nil then
    result := ''
  else
    result := entry.search.getExtensionString('http://hl7.org/fhir/StructureDefinition/patient-mpi-match')
end;

function TFHIRBundleEntry4B.getSearchScore: String;
begin
  if entry.search = nil then
    result := ''
  else
    result := entry.search.score;
end;

function TFHIRBundleEntry4B.getURL: String;
begin
  result := entry.fullUrl;
end;

procedure TFHIRBundleEntry4B.SetRequestMethod(Value: String);
begin
  if entry.request = nil then
    entry.request := TFHIRBundleEntryRequest.create;
  entry.request.method := TFhirHttpVerbEnum(ord(StringArrayIndexOfSensitive(CODES_TFhirHttpVerbEnum, value)));
end;

procedure TFHIRBundleEntry4B.SetRequestUrl(Value: String);
begin
  if entry.request = nil then
    entry.request := TFHIRBundleEntryRequest.create;
  entry.request.url := value;
end;

procedure TFHIRBundleEntry4B.SetResource(Value: TFHIRResourceV);
begin
  entry.resource := value as TFHIRResource;
end;

procedure TFHIRBundleEntry4B.SetResponseDate(Value: TFslDateTime);
begin
  if entry.response = nil then
    entry.response := TFHIRBundleEntryResponse.create;
  entry.response.lastModified := value;
end;

procedure TFHIRBundleEntry4B.SetResponseStatus(Value: String);
begin
  if entry.response = nil then
    entry.response := TFHIRBundleEntryResponse.create;
  entry.response.status := value;
end;

procedure TFHIRBundleEntry4B.SetSearchMode(Value: TFHIRBundleEntrySearchMode);
begin
  if entry.search = nil then
    entry.search := TFHIRBundleEntrySearch.create;
  entry.search.mode := MAP_SEARCH_MODE2[value];
end;

procedure TFHIRBundleEntry4B.SetSearchMpiMatch(Value: String);
begin
  if entry.search = nil then
    entry.search := TFHIRBundleEntrySearch.create;
  entry.search.setExtensionString('http://hl7.org/fhir/StructureDefinition/patient-mpi-match', value)
end;

procedure TFHIRBundleEntry4B.SetSearchScore(Value: String);
begin
  if entry.search = nil then
    entry.search := TFHIRBundleEntrySearch.create;
  entry.search.score := value;
end;

procedure TFHIRBundleEntry4B.SetUrl(Value: String);
begin
  entry.fullUrl := value;
end;

function TFHIRBundleEntry4B.GetLink(rel: String): String;
begin
  result := entry.Links[rel];
end;

procedure TFHIRBundleEntry4B.SetLink(rel: String; const Value: String);
begin
  entry.Links[rel] := value;
end;

function TFHIRBundleEntry4B.GetrequestIfNoneExist: String;
begin
  if entry.request = nil then
    result := ''
  else
    result := entry.request.ifNoneExist;
end;

procedure TFHIRBundleEntry4B.SetrequestIfNoneExist(Value: String);
begin
  if entry.request = nil then
    entry.request := TFhirBundleEntryRequest.create;
  entry.request.ifNoneExist := value;
end;

function TFHIRBundleEntry4B.GetrequestIfMatch: String;
begin
  if entry.request = nil then
    result := ''
  else
    result := entry.request.IfMatch;
end;

function TFHIRBundleEntry4B.GetrequestIfModifiedSince: TFslDateTime;
begin
  if entry.request = nil then
    result := TFslDateTime.makeNull
  else
    result := entry.request.ifModifiedSince;
end;

procedure TFHIRBundleEntry4B.SetrequestIfMatch(Value: String);
begin
  if entry.request = nil then
    entry.request := TFhirBundleEntryRequest.create;
  entry.request.IfMatch := value;
end;

procedure TFHIRBundleEntry4B.SetrequestIfModifiedSince(Value: TFslDateTime);
begin
  if entry.request = nil then
    entry.request := TFhirBundleEntryRequest.create;
  entry.request.ifModifiedSince := value;
end;

function TFHIRBundleEntry4B.GetrequestIfNoneMatch: String;
begin
  if entry.request = nil then
    result := ''
  else
    result := entry.request.IfNoneMatch;
end;

procedure TFHIRBundleEntry4B.SetrequestIfNoneMatch(Value: String);
begin
  if entry.request = nil then
    entry.request := TFhirBundleEntryRequest.create;
  entry.request.IfNoneMatch := value;
end;

function TFHIRBundleEntry4B.GetResponseETag: string;
begin
  if entry.response = nil then
    result := ''
  else
    result := entry.response.etag;
end;

procedure TFHIRBundleEntry4B.SetResponseETag(Value: string);
begin
  if entry.response = nil then
    entry.response := TFHIRBundleEntryResponse.create;
  entry.response.ETag := value;
end;

function TFHIRBundleEntry4B.GetResponseLocation: string;
begin
  if entry.response = nil then
    result := ''
  else
    result := entry.response.Location;
end;

procedure TFHIRBundleEntry4B.SetResponseLocation(Value: string);
begin
  if entry.response = nil then
    entry.response := TFHIRBundleEntryResponse.create;
  entry.response.Location := value;
end;

{ TFHIRValueSet4B }

function TFHIRValueSet4B.addInclude: TFhirValueSetComposeIncludeW;
begin
  if vs.compose = nil then
    vs.compose := TFhirValueSetCompose.Create;
  result := TFhirValueSetComposeInclude4B.Create(vs.compose.includeList.Append.Link);
end;

function TFHIRValueSet4B.checkCompose(place, role: String): boolean;
begin
  result := vs.compose <> nil;
  if result then
    vs.compose.checkNoModifiers(place, role, []);
end;

procedure TFHIRValueSet4B.clearDefinition;
begin
  vs.purpose := '';
  vs.compose := nil;
  vs.description := '';
  vs.contactList.Clear;
  vs.copyright := '';
  vs.publisher := '';
  vs.extensionList.Clear;
  vs.text := nil;
end;

destructor TFHIRValueSet4B.Destroy;
begin
  FExp.Free;
  inherited;
end;

function TFHIRValueSet4B.excludes: TFslList<TFhirValueSetComposeIncludeW>;
var
  c : TFhirValueSetComposeInclude;
begin
  if vs.compose = nil then
    result := TFslList<TFhirValueSetComposeIncludeW>.create
  else
  begin
    result := TFslList<TFhirValueSetComposeIncludeW>.create(vs.compose.excludeList.Count);
    for c in vs.compose.excludeList do
      result.Add(TFhirValueSetComposeInclude4B.Create(c.Link));
  end;
end;

function TFHIRValueSet4B.expansion: TFhirValueSetExpansionW;
begin
  if (FExp = nil) and (vs.expansion <> nil) then
    FExp := TFhirValueSetExpansion4B.create(vs.expansion.Link);
  result := FExp;
end;

function TFHIRValueSet4B.forceExpansion: TFhirValueSetExpansionW;
begin
  if (vs.expansion = nil) then
    vs.expansion := TFhirValueSetExpansion.create;
  vs.expansion.timestamp := TFslDateTime.makeUTC;
  vs.expansion.identifier := NewGuidURN;
  vs.expansion.parameterList.Clear;
  vs.expansion.containsList.Clear;
  result := expansion;
end;

function TFHIRValueSet4B.getContext: String;
begin
  result := vs.context;
end;

function TFHIRValueSet4B.GetDate: TFslDateTime;
begin
  result := vs.date;
end;

function TFHIRValueSet4B.hasExpansion: boolean;
begin
  result := vs.expansion <> nil;
end;

function TFHIRValueSet4B.hasInlineCS: boolean;
begin
  result := false;
end;

function TFHIRValueSet4B.imports: TArray<String>;
begin
  SetLength(result, 0);
end;

function TFHIRValueSet4B.includes: TFslList<TFhirValueSetComposeIncludeW>;
var
  c : TFhirValueSetComposeInclude;
begin
  if vs.compose = nil then
    result := TFslList<TFhirValueSetComposeIncludeW>.create
  else
  begin
    result := TFslList<TFhirValueSetComposeIncludeW>.create(vs.compose.includeList.Count);
    for c in vs.compose.includeList do
      result.Add(TFhirValueSetComposeInclude4B.Create(c.Link));
  end;
end;

function TFHIRValueSet4B.inlineCS: TFHIRValueSetCodeSystemW;
begin
  result := nil;
end;

procedure TFHIRValueSet4B.SetDate(Value: TFslDateTime);
begin
  vs.date := value;
end;

procedure TFHIRValueSet4B.setUrl(value: String);
begin
  vs.url := value;
end;

function TFHIRValueSet4B.getURL: String;
begin
  result := vs.url;
end;

procedure TFHIRValueSet4B.setName(value: String);
begin
  vs.Name := value;
end;

procedure TFHIRValueSet4B.SetPublisher(Value: String);
begin
  vs.publisher := value;
end;

procedure TFHIRValueSet4B.SetStatus(Value: TPublicationStatus);
begin
  vs.status := MAP_TPublicationStatus[value];
end;

function TFHIRValueSet4B.getName: String;
begin
  result := vs.Name;
end;

function TFHIRValueSet4B.GetPublisher: String;
begin
  result := vs.publisher;
end;

function TFHIRValueSet4B.GetStatus: TPublicationStatus;
begin
  result := MAP_TPublicationStatusR[vs.status];
end;

procedure TFHIRValueSet4B.setDescription(value: String);
begin
  vs.Description := value;
end;

procedure TFHIRValueSet4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

function TFHIRValueSet4B.getDescription: String;
begin
  result := vs.Description;
end;

function TFHIRValueSet4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

procedure TFHIRValueSet4B.setVersion(value: String);
begin
  vs.Version := value;
end;

function TFHIRValueSet4B.source: String;
begin
  result := vs.source;
end;

function TFHIRValueSet4B.getVersion: String;
begin
  result := vs.Version;
end;

function TFHIRValueSet4B.vs: TFhirValueSet;
begin
  result := Resource as TFHIRValueSet;
end;


{ TFhirValueSetComposeInclude4B }

function TFhirValueSetComposeInclude4B.addConcept: TFhirValueSetComposeIncludeConceptW;
begin
  result := TFhirValueSetComposeIncludeConcept4B.Create((Element as TFhirValueSetComposeInclude).ConceptList.Append.Link);
end;

function TFhirValueSetComposeInclude4B.addFilter: TFhirValueSetComposeIncludeFilterW;
begin
  result := TFhirValueSetComposeIncludeFilter4B.Create((Element as TFhirValueSetComposeInclude).FilterList.Append.Link);
end;

function TFhirValueSetComposeInclude4B.concepts: TFslList<TFhirValueSetComposeIncludeConceptW>;
var
  i : TFhirValueSetComposeIncludeConcept;
begin
  result := TFslList<TFhirValueSetComposeIncludeConceptW>.create((Element as TFhirValueSetComposeInclude).ConceptList.Count);
  for i in (Element as TFhirValueSetComposeInclude).ConceptList do
    result.Add(TFhirValueSetComposeIncludeConcept4B.Create(i.Link));
end;

function TFhirValueSetComposeInclude4B.filterCount: integer;
begin
  result := (Element as TFhirValueSetComposeInclude).filterList.Count;
end;

function TFhirValueSetComposeInclude4B.filters: TFslList<TFhirValueSetComposeIncludeFilterW>;
var
  i : TFhirValueSetComposeIncludeFilter;
begin
  result := TFslList<TFhirValueSetComposeIncludeFilterW>.create((Element as TFhirValueSetComposeInclude).filterList.Count);
  for i in (Element as TFhirValueSetComposeInclude).filterList do
    result.Add(TFhirValueSetComposeIncludeFilter4B.Create(i.Link));
end;

function TFhirValueSetComposeInclude4B.hasConcepts: boolean;
begin
  result := (Element as TFhirValueSetComposeInclude).conceptList.Count > 0;
end;

function TFhirValueSetComposeInclude4B.hasFilters: boolean;
begin
  result := (Element as TFhirValueSetComposeInclude).filterList.Count > 0;
end;

function TFhirValueSetComposeInclude4B.hasValueSets: boolean;
begin
  result := (Element as TFhirValueSetComposeInclude).valueSetList.Count > 0;
end;

procedure TFhirValueSetComposeInclude4B.SetSystem(Value: String);
begin
  (Element as TFhirValueSetComposeInclude).system := value;
end;

procedure TFhirValueSetComposeInclude4B.SetVersion(Value: String);
begin
  (Element as TFhirValueSetComposeInclude).version := value;
end;

function TFhirValueSetComposeInclude4B.getSystem: String;
begin
  result := (Element as TFhirValueSetComposeInclude).system;
end;

function TFhirValueSetComposeInclude4B.valueSets: TArray<String>;
var
  i : integer;
begin
  SetLength(result, TFhirValueSetComposeInclude(element).valueSetList.count);
  for i := 0 to TFhirValueSetComposeInclude(element).valueSetList.count - 1 do
    result[i] :=  TFhirValueSetComposeInclude(element).valueSetList[i].value;
end;

function TFhirValueSetComposeInclude4B.getVersion: String;
begin
  result := (Element as TFhirValueSetComposeInclude).version;
end;

{ TFhirValueSetComposeIncludeFilter4B }

function TFhirValueSetComposeIncludeFilter4B.getop: TFilterOperator;
begin
  result := MAP_TFilterOperator[(Element as TFhirValueSetComposeIncludeFilter).op];
end;

function TFhirValueSetComposeIncludeFilter4B.getprop: String;
begin
  result := (Element as TFhirValueSetComposeIncludeFilter).property_;
end;

function TFhirValueSetComposeIncludeFilter4B.getvalue: String;
begin
  result := (Element as TFhirValueSetComposeIncludeFilter).value;
end;

procedure TFhirValueSetComposeIncludeFilter4B.SetOp(Value: TFilterOperator);
begin
  (Element as TFhirValueSetComposeIncludeFilter).op := MAP_TFilterOperatorR[Value];

end;

procedure TFhirValueSetComposeIncludeFilter4B.SetProp(Value: String);
begin
  (Element as TFhirValueSetComposeIncludeFilter).property_ := value;
end;

procedure TFhirValueSetComposeIncludeFilter4B.SetValue(Value: String);
begin
  (Element as TFhirValueSetComposeIncludeFilter).value := value;
end;

{ TFhirValueSetComposeIncludeConcept4B }

function TFhirValueSetComposeIncludeConcept4B.getCode: String;
begin
  result := (Element as TFhirValueSetComposeIncludeConcept).code;
end;

function TFhirValueSetComposeIncludeConcept4B.designations: TFslList<TFhirValueSetComposeIncludeConceptDesignationW>;
var
  item : TFhirValueSetComposeIncludeConceptDesignation;
begin
  result := TFslList<TFhirValueSetComposeIncludeConceptDesignationW>.create;
  for item in (Element as TFhirValueSetComposeIncludeConcept).designationList do
    result.Add(TFhirValueSetComposeIncludeConceptDesignation4B.create(item.Link));
end;

function TFhirValueSetComposeIncludeConcept4B.getDisplay: String;
begin
  result := (Element as TFhirValueSetComposeIncludeConcept).display;
end;

procedure TFhirValueSetComposeIncludeConcept4B.SetCode(Value: String);
begin
  (Element as TFhirValueSetComposeIncludeConcept).code := Value;
end;

procedure TFhirValueSetComposeIncludeConcept4B.SetDisplay(Value: String);
begin
  (Element as TFhirValueSetComposeIncludeConcept).display := Value;
end;

{ TFHIRLookupOpResponse4B }

function TFHIRLookupOpResponse4B.addDesignation(lang, system, code, display, value: string): TFHIRLookupOpRespDesignationW;
var
  p : TFHIRLookupOpRespDesignation;
begin
  p := TFHIRLookupOpRespDesignation.create;
  try
    p.use := TFHIRCoding.Create;
    p.use.system := system;
    p.use.display := display;
    p.use.code := code;
    p.language := lang;
    p.value := value;
    (op as TFHIRLookupOpResponse).designationList.Add(p.link as TFHIRLookupOpRespDesignation);
    result := TFHIRLookupOpRespDesignation4B.create(p.Link);
  finally
    p.free;
  end;
end;

function TFHIRLookupOpResponse4B.addDesignation(lang, value: string): TFHIRLookupOpRespDesignationW;
var
  p : TFHIRLookupOpRespDesignation;
begin
  p := TFHIRLookupOpRespDesignation.create;
  try
    p.language := lang;
    p.value := value;
    (op as TFHIRLookupOpResponse).designationList.Add(p.link as TFHIRLookupOpRespDesignation);
    result := TFHIRLookupOpRespDesignation4B.create(p.Link);
  finally
    p.free;
  end;
end;

procedure TFHIRLookupOpResponse4B.addExtension(name: String; value: boolean);
begin
  (op as TFHIRLookupOpResponse).addExtension(name, value);
end;

procedure TFHIRLookupOpResponse4B.addExtension(name, value: String);
begin
  (op as TFHIRLookupOpResponse).addExtension(name, value);
end;

function TFHIRLookupOpResponse4B.addProp(name: string): TFHIRLookupOpRespPropertyW;
var
  p : TFHIRLookupOpRespProperty_;
begin
  p := TFHIRLookupOpRespProperty_.create;
  try
    p.code := name;
    (op as TFHIRLookupOpResponse).property_List.Add(p.link as TFHIRLookupOpRespProperty_);
    result := TFHIRLookupOpRespProperty4B.create(p.Link);
  finally
    p.Free;
  end;
end;

function TFHIRLookupOpResponse4B.asParams: TFHIRResourceV;
begin
  result := (op as TFHIROperationResponse).asParams;
end;

function TFHIRLookupOpResponse4B.GetDisplay: String;
begin
  result := (op as TFHIRLookupOpResponse).display;
end;

function TFHIRLookupOpResponse4B.GetName: String;
begin
  result := (op as TFHIRLookupOpResponse).name;
end;

function TFHIRLookupOpResponse4B.GetVersion: String;
begin
  result := (op as TFHIRLookupOpResponse).version;
end;

procedure TFHIRLookupOpResponse4B.load(params: THTTPParameters);
begin
  (op as TFHIRLookupOpResponse).load(params);
end;

procedure TFHIRLookupOpResponse4B.load(params: TFHIRResourceV);
begin
  (op as TFHIRLookupOpResponse).load(params as TFhirParameters);
end;

procedure TFHIRLookupOpResponse4B.SetDisplay(Value: String);
begin
  (op as TFHIRLookupOpResponse).display := value;
end;

procedure TFHIRLookupOpResponse4B.SetName(Value: String);
begin
  (op as TFHIRLookupOpResponse).name := value;
end;

procedure TFHIRLookupOpResponse4B.SetVersion(Value: String);
begin
  (op as TFHIRLookupOpResponse).version := value;
end;

{ TFHIRLookupOpRespDesignation4B }

function TFHIRLookupOpRespDesignation4B.GetUse: TFHIRObject;
begin
  result := (obj as TFHIRLookupOpRespDesignation).use;
end;

procedure TFHIRLookupOpRespDesignation4B.SetUse(Value: TFHIRObject);
begin
  (obj as TFHIRLookupOpRespDesignation).use := value as TFhirCoding;
end;

{ TFHIRLookupOpRespProperty4B }

function TFHIRLookupOpRespProperty4B.GetDescription: string;
begin
  result := (obj as TFHIRLookupOpRespProperty_).description;
end;

function TFHIRLookupOpRespProperty4B.GetValue: TFHIRObject;
begin
  result := (obj as TFHIRLookupOpRespProperty_).value;
end;

procedure TFHIRLookupOpRespProperty4B.SetDescription(Value: string);
begin
  (obj as TFHIRLookupOpRespProperty_).description := value;
end;

procedure TFHIRLookupOpRespProperty4B.SetValue(Value: TFHIRObject);
begin
  (obj as TFHIRLookupOpRespProperty_).value := value as TFHIRDataType;
end;

{ TFHIRExtension4B }

function TFHIRExtension4B.renderText: String;
begin
  result := gen(element as TFhirExtension);
end;

function TFHIRExtension4B.url: String;
begin
  result := (Element as TFHIRExtension).url;
end;

function TFHIRExtension4B.value: TFHIRObject;
begin
  result := (Element as TFHIRExtension).value;
end;

{ TFHIRCoding4B }

function TFHIRCoding4B.GetCode: String;
begin
  result := (element as TFHIRCoding).code;
end;

function TFHIRCoding4B.GetDisplay: String;
begin
  result := (element as TFHIRCoding).display;
end;

function TFHIRCoding4B.GetSystem: String;
begin
  result := (element as TFHIRCoding).system;
end;

function TFHIRCoding4B.GetVersion: String;
begin
  result := (element as TFHIRCoding).version;
end;

function TFHIRCoding4B.renderText: String;
begin
  result := gen(element as TFhirCoding);
end;

procedure TFHIRCoding4B.SetCode(Value: String);
begin
  (element as TFHIRCoding).code := value;
end;

procedure TFHIRCoding4B.SetDisplay(Value: String);
begin
  (element as TFHIRCoding).display := value;
end;

procedure TFHIRCoding4B.SetSystem(Value: String);
begin
    (element as TFHIRCoding).system := value;
end;

procedure TFHIRCoding4B.SetVersion(Value: String);
begin
  (element as TFHIRCoding).version := value;
end;

{ TFhirCodeSystemProperty4B }

function TFhirCodeSystemProperty4B.code: String;
begin
  result := (Element as TFhirCodeSystemProperty).code;
end;

function TFhirCodeSystemProperty4B.type_: TFhirCodeSystemPropertyType;
begin
  result := MAP_TFhirConceptPropertyTypeEnum[(Element as TFhirCodeSystemProperty).type_];
end;

function TFhirCodeSystemProperty4B.uri: String;
begin
  result := (Element as TFhirCodeSystemProperty).uri;
end;

{ TFhirCodeSystemConceptProperty4B }

function TFhirCodeSystemConceptProperty4B.code: String;
begin
  result := (Element as TFhirCodeSystemConceptProperty).code;
end;

function TFhirCodeSystemConceptProperty4B.value: TFHIRObject;
begin
  result := (Element as TFhirCodeSystemConceptProperty).value;
end;

{ TFhirCodeSystemConceptDesignation4B }

function TFhirCodeSystemConceptDesignation4B.language: String;
begin
  result := (Element as TFhirCodeSystemConceptDesignation).language;
end;

function TFhirCodeSystemConceptDesignation4B.use: TFHIRObject;
begin
  result := (Element as TFhirCodeSystemConceptDesignation).use;
end;

function TFhirCodeSystemConceptDesignation4B.useGen: String;
begin
  result := gen((Element as TFhirCodeSystemConceptDesignation).use)
end;

function TFhirCodeSystemConceptDesignation4B.value: String;
begin
  result := (Element as TFhirCodeSystemConceptDesignation).value;
end;

{ TFhirCodeSystemConcept4B }

function TFhirCodeSystemConcept4B.c: TFhirCodeSystemConcept;
begin
  result := Element as TFhirCodeSystemConcept;
end;

function TFhirCodeSystemConcept4B.code: String;
begin
  result := c.code;
end;

function TFhirCodeSystemConcept4B.concept(ndx: integer): TFhirCodeSystemConceptW;
begin
  result := TFhirCodeSystemConcept4B.create((element as TFhirCodeSystemConcept).conceptList[ndx].Link);
end;

function TFhirCodeSystemConcept4B.conceptCount: integer;
begin
  result := c.conceptList.Count;
end;

function TFhirCodeSystemConcept4B.conceptList: TFhirCodeSystemConceptListW;
var
  i : TFHIRCodeSystemConcept;
begin
  if FConceptList = nil then
  begin
    FConceptList := TFhirCodeSystemConceptListW.create;
    for i in (element as TFhirCodeSystemConcept).conceptList do
      FConceptList.Add(TFhirCodeSystemConcept4B.create(i.Link));
  end;
  result := FConceptList;
end;

function TFhirCodeSystemConcept4B.definition: String;
begin
  result := c.definition;
end;

function TFhirCodeSystemConcept4B.designationCount: integer;
begin
  result := c.designationList.Count;
end;

function TFhirCodeSystemConcept4B.designations: TFslList<TFhirCodeSystemConceptDesignationW>;
var
  i : TFhirCodeSystemConceptDesignation;
begin
  result := TFslList<TFhirCodeSystemConceptDesignationW>.create;
  for i in c.designationList do
    result.Add(TFhirCodeSystemConceptDesignation4B.Create(i.Link));
end;

function TFhirCodeSystemConcept4B.display: String;
begin
  result := c.display;
end;

function TFhirCodeSystemConcept4B.displayTag(tag: String): String;
begin
  result := c.displayElement.Tags[tag];
end;

function getCodeWrapper(list : TFhirCodeSystemConceptList; code : String) : TFhirCodeSystemConceptW;
var
  cc : TFhirCodeSystemConcept;
begin
  result := nil;
  for cc in list do
  begin
    if cc.code = code then
      result := TFhirCodeSystemConcept4B.Create(cc.Link);
    if cc.hasConceptList then
    begin
      result := getCodeWrapper(cc.conceptList, code);
      if result <> nil then
        exit;
    end;
  end;
end;

function TFhirCodeSystemConcept4B.getCode(code: String): TFhirCodeSystemConceptW;
begin
  if (code = c.Code) then
    result := self.link
  else
    result := getCodeWrapper(c.conceptList, code);
end;

function TFhirCodeSystemConcept4B.hasConcept(c: TFhirCodeSystemConceptW): boolean;
var
  i : TFHIRCodeSystemConcept;
begin
  result := false;
  for i in (element as TFhirCodeSystemConcept).conceptList do
      if i.code = c.code then
        exit(true);
end;

function TFhirCodeSystemConcept4B.properties: TFslList<TFhirCodeSystemConceptPropertyW>;
var
  i : TFhirCodeSystemConceptProperty;
begin
  result := TFslList<TFhirCodeSystemConceptPropertyW>.create;
  for i in c.property_List do
    result.Add(TFhirCodeSystemConceptProperty4B.Create(i.Link));
end;

procedure TFhirCodeSystemConcept4B.setDisplayTag(tag, value: String);
begin
  c.displayElement.Tags[tag] := value;
end;

{ TFhirCodeSystem4B }

function TFhirCodeSystem4B.buildImplicitValueSet: TFHIRValueSetW;
begin
  result := TFHIRValueSet4B.Create(cs.buildImplicitValueSet);
end;

function TFhirCodeSystem4B.concept(ndx: integer): TFhirCodeSystemConceptW;
begin
  result := TFhirCodeSystemConcept4B.create(cs.conceptList[ndx].Link);
end;

function TFhirCodeSystem4B.conceptCount: integer;
begin
  result := cs.conceptList.Count;
end;

function TFhirCodeSystem4B.conceptList: TFhirCodeSystemConceptListW;
var
  i : TFHIRCodeSystemConcept;
begin
  if FConceptList = nil then
  begin
    FConceptList := TFhirCodeSystemConceptListW.create;
    for i in (resource as TFhirCodeSystem).conceptList do
      FConceptList.Add(TFhirCodeSystemConcept4B.create(i.Link));
  end;
  result := FConceptList;
end;

function TFhirCodeSystem4B.copyright: String;
begin
  result := cs.copyright;
end;

function TFhirCodeSystem4B.cs: TFhirCodeSystem;
begin
  result := Resource as TFhirCodeSystem;
end;

function TFhirCodeSystem4B.GetCount: integer;
begin
  result := StrToInt(cs.count);
end;

function TFhirCodeSystem4B.GetDate: TFslDateTime;
begin
  result := cs.date;
end;

function TFhirCodeSystem4B.GetDescription: String;
begin
  result := cs.description;
end;

function TFhirCodeSystem4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFhirCodeSystem4B.getChildren(c: TFhirCodeSystemConceptW): TFhirCodeSystemConceptListW;
var
  list : TFhirCodeSystemConceptList;
  i :  TFhirCodeSystemConcept;
begin
  list := cs.getChildren(c.element as TFhirCodeSystemConcept);
  try
    result := TFhirCodeSystemConceptListW.create;
    try
      for i in list do
        result.Add(TFhirCodeSystemConcept4B.Create(i.Link));
      result.link;
    finally
      result.Free;
    end;
  finally
    c.free;
  end;
end;

function TFhirCodeSystem4B.getCode(code: String): TFhirCodeSystemConceptW;
begin
  result := getCodeWrapper(cs.conceptList, code);
end;

function TFhirCodeSystem4B.getContent: TFhirCodeSystemContentMode;
begin
  result := MAP_TFhirCodeSystemContentModeR[cs.content];
end;


function TFhirCodeSystem4B.getContext: String;
begin
  result := cs.context;
end;

function TFhirCodeSystem4B.getParents(c: TFhirCodeSystemConceptW): TFhirCodeSystemConceptListW;
var
  list : TFhirCodeSystemConceptList;
  i :  TFhirCodeSystemConcept;
begin
  list := cs.getParents(c.element as TFhirCodeSystemConcept);
  try
    result := TFhirCodeSystemConceptListW.create;
    try
      for i in list do
        result.Add(TFhirCodeSystemConcept4B.Create(i.Link));
      result.link;
    finally
      result.Free;
    end;
  finally
    c.free;
  end;
end;

function TFhirCodeSystem4B.hasConcept(c: TFhirCodeSystemConceptW): boolean;
var
  i : TFHIRCodeSystemConcept;
begin
  result := false;
  for i in (resource as TFhirCodeSystem).conceptList do
      if i.code = c.code then
        exit(true);
end;

function TFhirCodeSystem4B.isAbstract(c: TFhirCodeSystemConceptW): boolean;
begin
  result := cs.isAbstract(c.Element as TFhirCodeSystemConcept);
end;

function TFhirCodeSystem4B.language: String;
begin
  result := cs.language;
end;

function TFhirCodeSystem4B.GetName: String;
begin
  result := cs.name;
end;

function TFhirCodeSystem4B.properties: TFslList<TFhirCodeSystemPropertyW>;
var
  i : TFhirCodeSystemProperty;
begin
  result := TFslList<TFhirCodeSystemPropertyW>.create;
  for i in cs.property_List do
    result.Add(TFhirCodeSystemProperty4B.Create(i.Link));
end;

procedure TFhirCodeSystem4B.SetContent(Value: TFhirCodeSystemContentMode);
begin
  cs.content := MAP_TFhirCodeSystemContentMode[value];
end;

procedure TFhirCodeSystem4B.SetCount(Value: integer);
begin
  cs.count := inttostr(value);
end;

procedure TFhirCodeSystem4B.SetDate(Value: TFslDateTime);
begin
  cs.date := value;
end;

procedure TFhirCodeSystem4B.SetDescription(Value: String);
begin
  cs.description := value;
end;

procedure TFhirCodeSystem4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

procedure TFhirCodeSystem4B.SetName(Value: String);
begin
  cs.name := value;
end;

procedure TFhirCodeSystem4B.SetPublisher(Value: String);
begin
  cs.publisher := value;
end;

procedure TFhirCodeSystem4B.SetStatus(Value: TPublicationStatus);
begin
  cs.status := MAP_TPublicationStatus[value];
end;

procedure TFhirCodeSystem4B.SetUrl(Value: String);
begin
  cs.url := value;
end;

procedure TFhirCodeSystem4B.SetVersion(Value: String);
begin
  cs.version := value;
end;

function TFhirCodeSystem4B.supplements: String;
begin
  result := cs.supplements;
end;

function TFhirCodeSystem4B.valueSet: String;
begin
  result := cs.valueset;
end;

function TFhirCodeSystem4B.GetPublisher: String;
begin
  result := cs.publisher;
end;

function TFhirCodeSystem4B.GetStatus: TPublicationStatus;
begin
  result := MAP_TPublicationStatusR[cs.status];
end;

function TFhirCodeSystem4B.getURL: String;
begin
  result := cs.url;
end;

function TFhirCodeSystem4B.GetVersion: String;
begin
  result := cs.version;
end;

{ TFhirValueSetExpansion4B }

procedure TFhirValueSetExpansion4B.addContains(item: TFhirValueSetExpansionContainsW);
begin
  exp.containsList.Add((item.Element as TFhirValueSetExpansionContains).link);
end;

function TFhirValueSetExpansion4B.addContains: TFhirValueSetExpansionContainsW;
begin
  result := TFhirValueSetExpansionContains4B.Create((element as TFhirValueSetExpansion).containsList.Append.Link);
end;

procedure TFhirValueSetExpansion4B.addParamBool(name: String; value: boolean);
begin
  exp.addParamBool(name, value);
end;

procedure TFhirValueSetExpansion4B.addParamStr(name, value: String);
begin
  exp.addParamStr(name, value);
end;

procedure TFhirValueSetExpansion4B.addParamUri(name, value: String);
begin
  exp.addParamUri(name, value);
end;

function TFhirValueSetExpansion4B.contains: TFslList<TFhirValueSetExpansionContainsW>;
var
  item : TFhirValueSetExpansionContains;
begin
  result := TFslList<TFhirValueSetExpansionContainsW>.create;
  for item in (Element as TFhirValueSetExpansion).containsList do
    result.Add(TFhirValueSetExpansionContains4B.Create(item.Link));
end;

procedure TFhirValueSetExpansion4B.copyParams(source: TFhirValueSetExpansionW);
var
  param : TFhirValueSetExpansionParameter;
begin
  for param in (source.Element as TFhirValueSetExpansion).parameterList do
    (Element as TFhirValueSetExpansion).parameterList.Add(param.Link);
end;

function TFhirValueSetExpansion4B.exp: TFhirValueSetExpansion;
begin
  result := element as TFhirValueSetExpansion;
end;

function TFhirValueSetExpansion4B.hasParam(name, value: string): boolean;
var
  param : TFhirValueSetExpansionParameter;
begin
  result := false;
  for param in (Element as TFhirValueSetExpansion).parameterList do
    if (param.name = name) and (param.value.primitiveValue = value) then
      exit(true);
end;

function TFhirValueSetExpansion4B.makeContains: TFhirValueSetExpansionContainsW;
begin
  result := TFhirValueSetExpansionContains4B.Create(TFhirValueSetExpansionContains.create);
end;

function TFhirValueSetExpansion4B.hasParam(name: string): boolean;
var
  param : TFhirValueSetExpansionParameter;
begin
  result := false;
  for param in (Element as TFhirValueSetExpansion).parameterList do
    if (param.name = name) then
      exit(true);
end;

{ TFhirValueSetExpansionContains4B }

function TFhirValueSetExpansionContains4B.getcode: String;
begin
  result := (Element as TFhirValueSetExpansionContains).code;
end;

procedure TFhirValueSetExpansionContains4B.addDesignation(lang, use, value: String);
var
  d : TFhirValueSetComposeIncludeConceptDesignation;
  l,r : String;
begin
  d := (Element as TFhirValueSetExpansionContains).designationList.Append;
  d.language := lang;
  d.value := value;
  if use <> '' then
  begin
    StringSplit(use, '#', l, r);
    d.use := TFHIRCoding.Create(l, r);
  end;
end;

function TFhirValueSetExpansionContains4B.contains: TFslList<TFhirValueSetExpansionContainsW>;
var
  item : TFhirValueSetExpansionContains;
begin
  result := TFslList<TFhirValueSetExpansionContainsW>.create;
  for item in (Element as TFhirValueSetExpansionContains).containsList do
    result.Add(TFhirValueSetExpansionContains4B.Create(item.Link));
end;

function TFhirValueSetExpansionContains4B.getdisplay: String;
begin
  result := (Element as TFhirValueSetExpansionContains).display;
end;

function TFhirValueSetExpansionContains4B.getsystem: String;
begin
  result := (Element as TFhirValueSetExpansionContains).system;
end;

procedure TFhirValueSetExpansionContains4B.SetCode(Value: String);
begin
  (Element as TFhirValueSetExpansionContains).code := value;
end;

procedure TFhirValueSetExpansionContains4B.SetDisplay(Value: String);
begin
  (Element as TFhirValueSetExpansionContains).display := value;
end;

procedure TFhirValueSetExpansionContains4B.SetSystem(Value: String);
begin
  (Element as TFhirValueSetExpansionContains).system := value;
end;

{ TFhirValueSetComposeIncludeConceptDesignation4B }

function TFhirValueSetComposeIncludeConceptDesignation4B.language: String;
begin
  result := (element as TFhirValueSetComposeIncludeConceptDesignation).language;
end;

function TFhirValueSetComposeIncludeConceptDesignation4B.value: String;
begin
  result := (element as TFhirValueSetComposeIncludeConceptDesignation).value;
end;

{ TFhirConceptMap4B }

function TFhirConceptMap4B.addGroup(source, target: String): TFhirConceptMapGroupW;
var
  g : TFhirConceptMapGroup;
begin
  g := cm.groupList.Append;
  g.source := source;
  g.target := target;
  result := TFhirConceptMapGroup4B.create(g.Link);
end;

function TFhirConceptMap4B.cm: TFhirConceptMap;
begin
  result := Resource as TFhirConceptMap;
end;

function TFhirConceptMap4B.GetVersion: String;
begin
  result := cm.version;
end;

function TFhirConceptMap4B.groups: TFslList<TFhirConceptMapGroupW>;
var
  g : TFhirConceptMapGroup;
begin
  result := TFslList<TFhirConceptMapGroupW>.create;
  for g in cm.groupList do
    result.Add(TFhirConceptMapGroup4B.create(g.Link))
end;

procedure TFhirConceptMap4B.SetVersion(Value: String);
begin
  cm.version := value;
end;

function TFhirConceptMap4B.source: String;
begin
  if (cm.source is TFhirReference) then
    result := (cm.source as TFhirReference).reference
  else if cm.source <> nil then
    result := cm.source.primitiveValue;
end;

function TFhirConceptMap4B.sourceDesc: String;
begin
  result := cm.sourceDesc;
end;

function TFhirConceptMap4B.target: String;
begin
  if (cm.target is TFhirReference) then
    result := (cm.target as TFhirReference).reference
  else if cm.target <> nil then
    result := cm.target.primitiveValue;
end;

function TFhirConceptMap4B.targetDesc: String;
begin
  result := cm.targetDesc;
end;

function TFhirConceptMap4B.getURL: String;
begin
  result := cm.url;
end;

function TFhirConceptMap4B.GetDate: TFslDateTime;
begin
  result := cm.Date;
end;

function TFhirConceptMap4B.GetDescription: String;
begin
  result := cm.Description;
end;

function TFhirConceptMap4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFhirConceptMap4B.GetName: String;
begin
  result := cm.Name;
end;

function TFhirConceptMap4B.GetStatus: TPublicationStatus;
begin
  result := MAP_TPublicationStatusR[cm.Status];
end;

procedure TFhirConceptMap4B.SetDate(Value: TFslDateTime);
begin
  cm.Date := value;
end;

procedure TFhirConceptMap4B.SetDescription(Value: String);
begin
  cm.Description := value;
end;

procedure TFhirConceptMap4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

procedure TFhirConceptMap4B.SetName(Value: String);
begin
  cm.Name := value;
end;

procedure TFhirConceptMap4B.SetStatus(Value: TPublicationStatus);
begin
  cm.Status := MAP_TPublicationStatus[value];
end;

procedure TFhirConceptMap4B.SetUrl(Value: String);
begin
  cm.Url := value;
end;

procedure TFhirConceptMap4B.SetPublisher(Value: String);
begin
  cm.publisher := value;
end;

function TFhirConceptMap4B.getContext: String;
begin
  result := cm.context;
end;

function TFhirConceptMap4B.GetPublisher: String;
begin
  result := cm.publisher;
end;

{ TFhirConceptMapGroupElementTarget4B }

function TFhirConceptMapGroupElementTarget4B.code: String;
begin
  result := (Element as TFhirConceptMapGroupElementTarget).code;
end;

function TFhirConceptMapGroupElementTarget4B.comments: String;
begin
  result := (Element as TFhirConceptMapGroupElementTarget).comment;
end;

function TFhirConceptMapGroupElementTarget4B.equivalence: TFHIRConceptEquivalence;
begin
  result := MAP_TFHIRConceptEquivalence[(Element as TFhirConceptMapGroupElementTarget).equivalence];
end;

function TFhirConceptMapGroupElementTarget4B.products: TFslList<TFhirConceptMapGroupElementDependsOnW>;
var
  i : TFhirConceptMapGroupElementTargetDependsOn;
begin
  result := TFslList<TFhirConceptMapGroupElementDependsOnW>.create;
  for i in (Element as TFhirConceptMapGroupElementTarget).productList do
    result.Add(TFhirConceptMapGroupElementDependsOn4B.Create(i.link));
end;

{ TFhirConceptMapGroupElement4B }

function TFhirConceptMapGroupElement4B.addTarget(code: String; eq: TFHIRConceptEquivalence): TFhirConceptMapGroupElementTargetW;
var
  t : TFhirConceptMapGroupElementTarget;
begin
  t := (Element as TFhirConceptMapGroupElement).targetList.Append;
  t.code := code;
  t.equivalence := MAP_TFHIRConceptEquivalenceR[eq];
  result := TFhirConceptMapGroupElementTarget4B.Create(t.link);
end;

function TFhirConceptMapGroupElement4B.code: String;
begin
  result := (Element as TFhirConceptMapGroupElement).code;
end;

function TFhirConceptMapGroupElement4B.targetCount: integer;
begin
  result := (Element as TFhirConceptMapGroupElement).targetList.Count;
end;

function TFhirConceptMapGroupElement4B.targets: TFslList<TFhirConceptMapGroupElementTargetW>;
var
  i : TFhirConceptMapGroupElementTarget;
begin
  result := TFslList<TFhirConceptMapGroupElementTargetW>.create;
  for i in (Element as TFhirConceptMapGroupElement).targetList do
    result.Add(TFhirConceptMapGroupElementTarget4B.Create(i.link));
end;


{ TFhirConceptMapGroup4B }

function TFhirConceptMapGroup4B.addElement(code: String): TFhirConceptMapGroupElementW;
var
  t : TFhirConceptMapGroupElement;
begin
  t := (Element as TFhirConceptMapGroup).elementList.Append;
  t.code := code;
  result := TFhirConceptMapGroupElement4B.Create(t.link);
end;

function TFhirConceptMapGroup4B.elements: TFslList<TFhirConceptMapGroupElementW>;
var
  t : TFhirConceptMapGroupElement;
begin
  result := TFslList<TFhirConceptMapGroupElementW>.create;
  for t in (Element as TFhirConceptMapGroup).elementList do
    result.Add(TFhirConceptMapGroupElement4B.Create(t.link))
end;

function TFhirConceptMapGroup4B.source: String;
begin
  result := (Element as TFhirConceptMapGroup).source;
end;

function TFhirConceptMapGroup4B.target: String;
begin
  result := (Element as TFhirConceptMapGroup).target;
end;

{ TFHIRMeta4B }


procedure TFHIRMeta4B.addLabel(system, code, display: String);
var
  c : TFHIRCoding;
begin
  force;
  c := TFHIRCoding.create;
  try
    c.system := system;
    c.code := code;
    c.display := display;
    m.securityList.Add(c.link);
  finally
    c.Free;
  end;
end;

procedure TFHIRMeta4B.addProfile(uri: String);
begin
  force;
  m.profileList.Add(TFhirCanonical.Create(uri));
end;

procedure TFHIRMeta4B.addTag(system, code, display: String);
var
  c : TFHIRCoding;
begin
  force;
  c := TFHIRCoding.create;
  try
    c.system := system;
    c.code := code;
    c.display := display;
    m.tagList.Add(c.link);
  finally
    c.Free;
  end;
end;

procedure TFHIRMeta4B.clearLabels;
begin
  if Element <> nil then
    m.securityList.Clear;
end;

procedure TFHIRMeta4B.clearProfiles;
begin
  if Element <> nil then
    m.profileList.Clear;
end;

procedure TFHIRMeta4B.clearTags;
begin
  if Element <> nil then
    m.tagList.Clear;
end;

destructor TFHIRMeta4B.destroy;
begin
  FResource.Free;
  inherited;
end;

procedure TFHIRMeta4B.force;
begin
  if Element = nil then
  begin
    FElement := TFHIRMeta.Create;
    Resource.meta := m.Link;
  end;
end;

function TFHIRMeta4B.GetLastUpdated: TFslDateTime;
begin
  if Element = nil then
    result := TFslDateTime.makeNull
  else
    result := m.lastUpdated;
end;

function TFHIRMeta4B.GetVersionId: String;
begin
  if Element = nil then
    result := ''
  else
    result := m.versionId;
end;

function TFHIRMeta4B.hasLabel(system, code: String): boolean;
var
  c : TFhirCoding;
begin
  result := false;
  if Element <> nil then
    for c in m.securityList do
      if (c.system = system) and (c.code = code) then
        exit(true);
end;

function TFHIRMeta4B.hasTag(system, code: String): boolean;
var
  c : TFhirCoding;
begin
  result := false;
  if Element <> nil then
    for c in m.tagList do
       if (c.system = system) and (c.code = code) then
        exit(true);
end;

function TFHIRMeta4B.labels: TFslList<TFHIRCodingW>;
var
  i : TFHIRCoding;
begin
  result := TFslList<TFHIRCodingW>.create;
  if Element <> nil then
    for i in m.securityList do
      result.Add(TFHIRCoding4B.create(i.Link));
end;

function TFHIRMeta4B.m: TFhirMeta;
begin
  result := Element as TFHIRMeta;
end;

function TFHIRMeta4B.NoElementOk: boolean;
begin
  result := true;
end;

function TFHIRMeta4B.profiles: TArray<String>;
var
  i : integer;
begin
  if Element <> nil then
  begin
    SetLength(result, m.profileList.Count);
    for i := 0 to m.profileList.Count - 1 do
      result[i] := m.profileList[i].value;
  end
  else
    SetLength(result, 0);
end;

procedure TFHIRMeta4B.removeLabel(system, code: String);
begin
  if Element <> nil then
    m.removeLabel(system, code);
end;

procedure TFHIRMeta4B.removeProfile(uri: String);
begin
  if Element <> nil then
    m.profileList.removeUri(uri);
end;

procedure TFHIRMeta4B.removeTag(system, code: String);
begin
  if Element <> nil then
    m.removeTag(system, code);
end;

procedure TFHIRMeta4B.SetLastUpdated(Value: TFslDateTime);
begin
  force;
  m.lastUpdated := value;
end;

procedure TFHIRMeta4B.setResource(value: TFHIRResource);
begin
  FResource.Free;
  FResource := value;
end;

procedure TFHIRMeta4B.SetVersionId(Value: String);
begin
  force;
  m.versionId := value;
end;

function TFHIRMeta4B.tags: TFslList<TFHIRCodingW>;
var
  i : TFHIRCoding;
begin
  result := TFslList<TFHIRCodingW>.create;
  if Element <> nil then
    for i in m.tagList do
      result.Add(TFHIRCoding4B.create(i.Link));
end;


function TFHIRMeta4B.sizeInBytesV(magic : integer) : cardinal;
begin
  result := inherited sizeInBytesV(magic);
  inc(result, FResource.sizeInBytes(magic));
end;

{ TFHIRAuditEvent4B }

function TFHIRAuditEvent4B.ae: TFHIRAuditEvent;
begin
  result := Resource as TFhirAuditEvent;
end;

function TFHIRAuditEvent4B.dateTime: TFslDateTime;
begin
  result := ae.event.dateTime;
end;

procedure TFHIRAuditEvent4B.eventSubType(system, code, display: String);
var
  c : TFHIRCoding;
begin
  if ae.event = nil then
    ae.event := TFhirAuditEventEvent.Create;
  c := ae.event.subtypeList.Append;;
  c.code := code;
  c.system := system;
  c.Display := display;
end;

procedure TFHIRAuditEvent4B.eventType(system, code, display: String);
var
  c : TFHIRCoding;
begin
  if ae.event = nil then
    ae.event := TFhirAuditEventEvent.Create;
  c := TFHIRCoding.Create;
  ae.event.type_ := c;
  c.code := code;
  c.system := system;
  c.Display := display;
end;

function TFHIRAuditEvent4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

procedure TFHIRAuditEvent4B.participantId(system, value, alt, name: String);
var
  p: TFhirAuditEventParticipant;
begin
  p := ae.participantList.append;
  p.who := TFhirReference.Create;
  p.who.identifier := TFhirIdentifier.Create;
  p.who.identifier.system := system;
  p.who.identifier.value := value;
  p.altId := alt;
  p.name := name;
end;

procedure TFHIRAuditEvent4B.participantIp(ip: String);
var
  p: TFhirAuditEventParticipant;
begin
  p := ae.participantList.append;
  p.network := TFhirAuditEventParticipantNetwork.Create;
  p.network.address := ip;
  p.network.type_ := AuditEventAgentNetworkType2;
end;

procedure TFHIRAuditEvent4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

procedure TFHIRAuditEvent4B.source(name, system, value: String);
begin
  if ae.source = nil then
    ae.source := TFhirAuditEventSource.Create;
  ae.source.site := name;
  ae.source.observer := TFhirReference.Create();
  ae.source.observer.identifier := TFhirIdentifier.Create;
  ae.source.observer.identifier.system := system;
  ae.source.observer.identifier.value := value;
end;

procedure TFHIRAuditEvent4B.sourceType(system, code, display: String);
var
  c : TFHIRCoding;
begin
  if ae.source = nil then
    ae.source := TFhirAuditEventSource.Create;
  c := ae.source.type_List.Append;
  c.code := code;
  c.system := system;
  c.Display := display;
end;

procedure TFHIRAuditEvent4B.success;
begin
  if ae.event = nil then
    ae.event := TFhirAuditEventEvent.Create;
  ae.event.action := AuditEventActionE;
  ae.event.outcome := AuditEventOutcome0;
  ae.event.dateTime := TFslDateTime.makeUTC;
end;

{ TFhirCapabilityStatementRestResource4B }

procedure TFhirCapabilityStatementRestResource4B.addParam(html, n, url, d: String; t: TFHIRSearchParamType; tgts: array of String);
var
  param : TFhirCapabilityStatementRestResourceSearchParam;
begin
  param := TFhirCapabilityStatementRestResourceSearchParam.create;
  try
    param.name := n;
    param.definition := url;
    param.documentation := d;
    param.type_ := MAP_TFHIRSearchParamType2[t];
    (Element as TFhirCapabilityStatementRestResource).searchParamList.add(param.link);
  finally
    param.free;
  end;
//  html.append('<li>'+n+' : '+FormatTextToHTML(d)+'</li>');
end;

function TFhirCapabilityStatementRestResource4B.GetCode: String;
begin
  result := CODES_TFhirResourceTypesEnum[(Element as TFhirCapabilityStatementRestResource).type_];
end;

procedure TFhirCapabilityStatementRestResource4B.SetCode(Value: String);
begin
  (Element as TFhirCapabilityStatementRestResource).type_Element := TFhirEnum.create('http://hl7.org/fhir/resource-types', value);
end;

function TFhirCapabilityStatementRestResource4B.GetProfile: String;
begin
  result := (Element as TFhirCapabilityStatementRestResource).profile;
end;

procedure TFhirCapabilityStatementRestResource4B.SetProfile(Value: String);
begin
  (Element as TFhirCapabilityStatementRestResource).profile := value;
end;

procedure TFhirCapabilityStatementRestResource4B.addInteraction(code: String);
begin
  (Element as TFhirCapabilityStatementRestResource).interactionList.Append.codeElement := TFhirEnum.create('http://hl7.org/fhir/ValueSet/type-restful-interaction', code);
end;

function TFhirCapabilityStatementRestResource4B.GetReadHistory: boolean;
begin
  result := (Element as TFhirCapabilityStatementRestResource).readHistory;
end;

function TFhirCapabilityStatementRestResource4B.hasInteraction: boolean;
begin
  result := (Element as TFhirCapabilityStatementRestResource).interactionList.Count > 0;
end;

procedure TFhirCapabilityStatementRestResource4B.SetReadHistory(Value: boolean);
begin
  (Element as TFhirCapabilityStatementRestResource).readHistory := Value;
end;


{ TFHIRSubscription4B }

function TFHIRSubscription4B.GetCriteria: String;
begin
  result := sub.criteria;
end;

function TFHIRSubscription4B.GetDirect: boolean;
begin
  result := sub.channel.endpointElement.hasExtension('http://hl7.org/fhir/us/core/StructureDefinition/us-core-direct')
    and (sub.channel.endpointElement.getExtensionString('http://hl7.org/fhir/us/core/StructureDefinition/us-core-direct') = 'true');
end;

function TFHIRSubscription4B.GetEndpoint: String;
begin
  result := sub.channel.endpoint;
end;

function TFHIRSubscription4B.GetError: String;
begin
  result := sub.error;
end;

function TFHIRSubscription4B.GetHeaders: TArray<String>;
var
  i : integer;
begin
  setLength(result, sub.channel.headerList.Count);
  for i := 0 to sub.channel.headerList.Count - 1 do
    result[i] := sub.channel.headerList[i].value;
end;

function TFHIRSubscription4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFHIRSubscription4B.GetMethod: TSubscriptionMethod;
begin
  result := MAP_TSubscriptionMethod[sub.channel.type_];
end;

function TFHIRSubscription4B.GetPayload: String;
begin
  result := sub.channel.payload;
end;

function TFHIRSubscription4B.GetStatus: TSubscriptionStatus;
begin
  result := MAP_TSubscriptionStatus[sub.status];
end;

function TFHIRSubscription4B.GetSummary: String;
var
  s : TFhirString;
begin
  result := sub.channel.type_Element.value+#1+sub.channel.endpoint+#1+sub.channel.payload;
  for s in sub.channel.headerList do
    result := result+#0+s.value;
//  result := result+#0+subst.channel.header;
end;

function TFHIRSubscription4B.getTopic: string;
begin
  result := sub.getExtensionString('http://hl7.org/fhir/uv/subscriptions-backport/StructureDefinition/backport-topic-canonical');
end;

procedure TFHIRSubscription4B.SetCriteria(Value: String);
begin
  sub.criteria := value;
end;

procedure TFHIRSubscription4B.SetDirect(Value: boolean);
begin
  if value then
    sub.channel.endpointElement.setExtensionBoolean('http://hl7.org/fhir/us/core/StructureDefinition/us-core-direct', 'true')
  else
    sub.channel.endpointElement.removeExtension('http://hl7.org/fhir/us/core/StructureDefinition/us-core-direct');
end;

procedure TFHIRSubscription4B.SetEndpoint(Value: String);
begin
  sub.channel.endpoint := value;
end;

procedure TFHIRSubscription4B.SetError(Value: String);
begin
  sub.error := value;
end;

procedure TFHIRSubscription4B.Setheaders(Value: TArray<String>);
var
  s : String;
begin
  sub.channel.headerList.Clear;
  for s in value do
    sub.channel.headerList.Append.value := s;
end;

procedure TFHIRSubscription4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

procedure TFHIRSubscription4B.SetMethod(Value: TSubscriptionMethod);
begin
  sub.channel.type_ := MAP_TSubscriptionMethod2[value];
end;

procedure TFHIRSubscription4B.SetPayload(Value: String);
begin
  sub.channel.payload := value;
end;

procedure TFHIRSubscription4B.SetStatus(Value: TSubscriptionStatus);
begin
  sub.status := MAP_TSubscriptionStatus2[value];
end;

function TFHIRSubscription4B.sub: TFhirSubscription;
begin
  result := resource as TFhirSubscription;
end;

{ TFhirBinary4B }

function TFhirBinary4B.content: TBytes;
begin
  result := (resource as TFHIRBinary).data;
end;

function TFhirBinary4B.ContentType: String;
begin
  result := (resource as TFHIRBinary).contentType;
end;

function TFhirBinary4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

procedure TFhirBinary4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

{ TFhirObservationComponent4B }

function TFhirObservationComponent4B.codings: TFslList<TFHIRCodingW>;
var
  c : TFHIRCoding;
begin
  result := TFslList<TFHIRCodingW>.create;
  if comp.code <> nil then
    for c in comp.code.codingList do
      result.Add(TFHIRCoding4B.Create(c.Link));
end;

function TFhirObservationComponent4B.comp: TFhirObservationComponent;
begin
  result := (Element as TFhirObservationComponent);
end;

function TFhirObservationComponent4B.dataAbsentReason: TFhirCodeableConceptW;
begin
  if comp.dataAbsentReason = nil then
    result := nil
  else
    result := TFhirCodeableConcept4B.Create(comp.dataAbsentReason.link);
end;

function TFhirObservationComponent4B.GetValue: TFHIRObject;
begin
  result := comp.value;
end;

procedure TFhirObservationComponent4B.SetValue(Value: TFHIRObject);
begin
  comp.value := value as TFHIRDataType;
end;

function TFhirObservationComponent4B.valueString: String;
begin
  if (comp.value <> nil) and (comp.value.isPrimitive) then
    result := comp.value.primitiveValue
  else
    result := '';
end;

function TFhirObservationComponent4B.valueW: TFHIRXVersionElementWrapper;
begin
  if comp.value is TFhirCodeableConcept then
    result := TFhirCodeableConcept4B.Create(comp.value.Link)
  else if comp.value is TFHIRQuantity then
    result := TFHIRQuantity4B.Create(comp.value.Link)
  else
    result := nil;
end;

{ TFhirObservation4B }

procedure TFhirObservation4B.SetCode(c: TFHIRCodingW);
begin
  if obs.code = nil then
    obs.code := TFhirCodeableConcept.Create;
  obs.code.codingList.add((c.Element as TFHIRCoding).Link);
end;

function TFhirObservation4B.addComp(system, code: String): TFhirObservationComponentW;
var
  c : TFhirObservationComponent;
begin
  c := TFhirObservationComponent.Create;
  c.code := TFhirCodeableConcept.Create;
  c.code.codingList.add(TFhirCoding.Create(system, code));
  result := TFhirObservationComponent4B.Create(c.link);
end;

function TFhirObservation4B.GetStatus: TObservationStatus;
begin
  result := MAP_TObservationStatus2[obs.status];
end;

function TFhirObservation4B.obs: TFHIRObservation;
begin
  result := resource as TFhirObservation;
end;

procedure TFhirObservation4B.setPeriod(start, finish: TDateTime);
begin
  obs.effective := TFhirPeriod.Create;
  TFhirPeriod(obs.effective).start := TFslDateTime.makeUTC(start);
  TFhirPeriod(obs.effective).end_ := TFslDateTime.makeUTC(finish);
end;

procedure TFhirObservation4B.SetStatus(Value: TObservationStatus);
begin
  obs.status := MAP_TObservationStatus[value];
end;

function TFhirObservation4B.codings: TFslList<TFHIRCodingW>;
var
  c : TFHIRCoding;
begin
  result := TFslList<TFHIRCodingW>.create;
  if obs.code <> nil then
    for c in obs.code.codingList do
      result.Add(TFHIRCoding4B.Create(c.Link));
end;

function TFhirObservation4B.components: TFslList<TFhirObservationComponentW>;
var
  c : TFhirObservationComponent;
begin
  result := TFslList<TFhirObservationComponentW>.create;
  for c in obs.componentList do
    result.Add(TFhirObservationComponent4B.Create(c.Link));
end;

function TFhirObservation4B.dataAbsentReason: TFhirCodeableConceptW;
begin
  if obs.dataAbsentReason = nil then
    result := nil
  else
    result := TFhirCodeableConcept4B.Create(obs.dataAbsentReason.link);
end;

procedure TFhirObservation4B.getDates(var dt, dtMin, dtMax: TDateTime);
begin
  if obs.effective is TFHIRDateTime then
  begin
    dt := (obs.effective as TFHIRDateTime).value.UTC.DateTime;
    dtMin := (obs.effective as TFHIRDateTime).value.Min.UTC.DateTime;
    dtMax := (obs.effective as TFHIRDateTime).value.Max.UTC.DateTime;
  end
  else
  begin
    dt := 0;
    if (obs.effective as TFHIRPeriod).start.null then
      dtMin := 0
    else
      dtMin := (obs.effective as TFHIRPeriod).start.Min.UTC.DateTime;
    if (obs.effective as TFHIRPeriod).end_.null then
      // nothing;
    else
      dtMax := (obs.effective as TFHIRPeriod).end_.Max.UTC.DateTime;
  end;
end;

function TFhirObservation4B.GetValue: TFHIRObject;
begin
  result := obs.value;
end;

procedure TFhirObservation4B.SetValue(Value: TFHIRObject);
begin
  obs.value := value as TFHIRDataType;
end;

function TFhirObservation4B.valueW: TFHIRXVersionElementWrapper;
begin
  if obs.value is TFhirCodeableConcept then
    result := TFhirCodeableConcept4B.Create(obs.value.Link)
  else if obs.value is TFHIRQuantity then
    result := TFHIRQuantity4B.Create(obs.value.Link)
  else
    result := nil;
end;

function TFhirObservation4B.hasTime: boolean;
begin
  result := obs.effective <> nil;
end;

function TFhirObservation4B.categories: TFslList<TFHIRCodingW>;
var
  cc : TFHIRCodeableConcept;
  c : TFHIRCoding;
begin
  result := TFslList<TFHIRCodingW>.create;
  for cc in obs.categoryList do
    for c in cc.codingList do
      result.Add(TFHIRCoding4B.Create(c.Link));
end;

procedure TFhirObservation4B.setCode(system, code, display: String);
begin
  if obs.code = nil then
    obs.code := TFhirCodeableConcept.Create;
  obs.code.codingList.add(TFHIRCoding.Create(system, code, display));
end;

procedure TFhirObservation4B.SetCodeText(const Value: String);
begin
  if value <> '' then
  begin
    if obs.code = nil then
      obs.code := TFhirCodeableConcept.create;
    obs.code.text := Value
  end
  else if (obs.code <> nil) and not obs.code.hasCoding then
    obs.code := nil;
end;

procedure TFhirObservation4B.SetComment(const Value: String);
begin
  obs.noteList.Append.text := value;
end;

procedure TFhirObservation4B.SetDevice(const Value: String);
begin
  if (value = '') then
  begin
    if (obs.device <> nil) and (obs.device.display <> '') then
      obs.device.reference := ''
    else
      obs.device := nil
  end
  else
  begin
    if obs.device = nil then
      obs.device := TFhirReference.Create;
    obs.device.reference := value;
  end;
end;

procedure TFhirObservation4B.SetDeviceName(const Value: String);
begin
  if (value = '') then
  begin
    if (obs.device <> nil) and (obs.device.reference <> '') then
      obs.device.display := ''
    else
      obs.device := nil
  end
  else
  begin
    if obs.device = nil then
      obs.device := TFhirReference.Create;
    obs.device.display := value;
  end;
end;

procedure TFhirObservation4B.SetEffective(const Value: TFHIRObject);
begin
  obs.effective := Value as TFHIRDataType;
end;

procedure TFhirObservation4B.SetEffectiveDateTime(const Value: TFslDateTime);
begin
  SetEffective(TFhirDateTime.Create(value));
end;

procedure TFhirObservation4B.SetEffectivePeriod(const Value: TFHIRPeriodW);
begin
  obs.effective := (value.Element as TFHIRDataType).Link;
end;

procedure TFhirObservation4B.SetIssued(const Value: TFslDateTime);
begin
  obs.issued := Value;
end;

procedure TFhirObservation4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

procedure TFhirObservation4B.SetSubject(const Value: String);
begin
  if value = '' then
    obs.subject := nil
  else
  begin
    if obs.subject = nil then
      obs.subject := TFhirReference.Create;
    obs.subject.reference := value;
  end;
end;

function TFhirObservation4B.GetCodeText: String;
begin
  if obs.code = nil then
    result := ''
  else
    result := obs.code.text;
end;

function TFhirObservation4B.GetComment: String;
begin
  if obs.noteList.Count = 0 then
    result := ''
  else
    result := obs.noteList[0].text;
end;

function TFhirObservation4B.getComponent(system, code: String; var comp: TFhirObservationComponentW): boolean;
var
  c : TFHIRObservationComponent;
begin
  comp := nil;
  result := obs.getComponent(system, code, c);
  if result then
    comp := TFHIRObservationComponent4B.create(c.link);
end;

function TFhirObservation4B.getComponent(system: String; var comp: TFhirObservationComponentW): boolean;
var
  c : TFHIRObservationComponent;
begin
  comp := nil;
  result := obs.getComponent(system, c);
  if result then
    comp := TFHIRObservationComponent4B.create(c.link);
end;

function TFhirObservation4B.GetDevice: String;
begin
  if obs.device <> nil then
    result := obs.device.reference
  else
    result := '';
end;

function TFhirObservation4B.GetDeviceName: String;
begin
  if obs.device <> nil then
    result := obs.device.display
  else
    result := '';
end;

function TFhirObservation4B.GetEffective: TFHIRObject;
begin
  result := obs.effective;
end;

function TFhirObservation4B.GetEffectiveDateTime: TFslDateTime;
begin
  if obs.effective is TFhirDateTime then
    result := (obs.effective as TFhirDateTime).value
  else
    result := TFslDateTime.makeNull;
end;

function TFhirObservation4B.GetEffectivePeriod: TFHIRPeriodW;
begin
  if obs.effective is TFhirPeriod then
    result := TFHIRPeriod4B.create(obs.effective.Link)
  else
    result := nil;
end;

function TFhirObservation4B.GetIssued: TFslDateTime;
begin
  result := obs.issued;
end;

function TFhirObservation4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFhirObservation4B.hasDevice: boolean;
begin
  result := obs.Device <> nil;
end;

function TFhirObservation4B.hasEffective: boolean;
begin
  result := obs.Effective <> nil;
end;

function TFhirObservation4B.hasIssued: boolean;
begin
  result := obs.IssuedElement <> nil;
end;

function TFhirObservation4B.hasMethod: boolean;
begin
  result := obs.Method <> nil;
end;

function TFhirObservation4B.hasSubject: boolean;
begin
  result := obs.Subject <> nil;
end;

function TFhirObservation4B.method(force : boolean) : TFhirCodeableConceptW;
begin
  if (obs.method = nil) and force then
    obs.method := TFhirCodeableConcept.Create;

  if obs.method = nil then
    result := nil
  else
    result := TFhirCodeableConcept4B.Create(obs.method.link);
end;

function TFhirObservation4B.GetSubject: String;
begin
  if obs.subject <> nil then
    result := obs.subject.reference
  else
    result := '';
end;

procedure TFhirObservation4B.addCategory(c: TFHIRCodingW);
begin
  obs.categoryList.Append.codingList.add((c.Element as TFHIRCoding).Link);
end;

procedure TFhirObservation4B.addCategory(system, code, display: String);
begin
  obs.categoryList.Append.codingList.add(TFHIRCoding.Create(system, code, display));
end;

procedure TFhirObservation4B.setCode(text: String);
begin
  if obs.code = nil then
    obs.code := TFhirCodeableConcept.Create;
  obs.code.text := text;
end;

{ TFHIRQuantity4B }

function TFHIRQuantity4B.asDuration: TDateTime;
begin
  result := qty.asDuration;
end;

function TFHIRQuantity4B.GetCode: String;
begin
  result := qty.code;
end;

function TFHIRQuantity4B.GetSystem: String;
begin
  result := qty.system;
end;

function TFHIRQuantity4B.GetUnit: String;
begin
  result := qty.unit_;
end;

function TFHIRQuantity4B.GetValue: String;
begin
  result := qty.value;
end;

function TFHIRQuantity4B.qty: TFHIRQuantity;
begin
  result := Element as TFHIRQuantity;
end;

function TFHIRQuantity4B.renderText: String;
begin
  result := gen(element as TFhirQuantity);
end;

procedure TFHIRQuantity4B.SetCode(Value: String);
begin
  qty.code := Value;
end;

procedure TFHIRQuantity4B.SetSystem(Value: String);
begin
  qty.system := Value;
end;

procedure TFHIRQuantity4B.SetUnit(Value: String);
begin
  qty.unit_ := Value;
end;

procedure TFHIRQuantity4B.SetValue(Value: String);
begin
  qty.value := Value;
end;

{ TFHIRLookupOpRequest4B }

function TFHIRLookupOpRequest4B.asParams: TFHIRResourceV;
begin
  result := (op as TFHIROperationRequest).asParams;
end;

function TFHIRLookupOpRequest4B.coding: TFHIRCodingW;
begin
  result := TFHIRCoding4B.Create((op as TFHIRLookupOpRequest).coding.Link);
end;

function TFHIRLookupOpRequest4B.displayLanguage: String;
begin
  result := (op as TFHIRLookupOpRequest).displayLanguage;
end;

procedure TFHIRLookupOpRequest4B.load(params: THTTPParameters);
begin
  (op as TFHIRLookupOpRequest).load(params);
end;

procedure TFHIRLookupOpRequest4B.loadCoding;
var
  req : TFHIRLookupOpRequest;
begin
  req := (Op as TFHIRLookupOpRequest);
  if (req.coding = nil) and (req.system <> '') then
  begin
    req.coding := TFhirCoding.Create;
    req.coding.system := req.system;
    req.coding.code := req.code;
    req.coding.version := req.version;
  end;
  if req.coding = nil then
    raise ETerminologyError.create('Unable to find a code to lookup (need coding or system/code)');
end;

function TFHIRLookupOpRequest4B.propList: TArray<String>;
var
  i : integer;
begin
  SetLength(result, (op as TFHIRLookupOpRequest).property_List.Count);
  for i := 0 to (op as TFHIRLookupOpRequest).property_List.Count -1 do
    result[i] := (op as TFHIRLookupOpRequest).property_List[i];
end;

procedure TFHIRLookupOpRequest4B.load(params: TFHIRResourceV);
begin
  (op as TFHIRLookupOpRequest).load(params as TFhirParameters);
end;

{ TFHIRSubsumesOpRequest4B }

function TFHIRSubsumesOpRequest4B.asParams: TFHIRResourceV;
begin
  result := (op as TFHIRSubsumesOpRequest).asParams;
end;

procedure TFHIRSubsumesOpRequest4B.load(params: TFHIRResourceV);
begin
  (op as TFHIRSubsumesOpRequest).load(params as TFHIRParameters);
end;

function TFHIRSubsumesOpRequest4B.codeA: String;
begin
  result := (op as TFHIRSubsumesOpRequest).codeA;
end;

function TFHIRSubsumesOpRequest4B.codeB: String;
begin
  result := (op as TFHIRSubsumesOpRequest).codeB;
end;

function TFHIRSubsumesOpRequest4B.codingA: TFHIRCodingW;
begin
  result := TFHIRCoding4B.Create((op as TFHIRSubsumesOpRequest).codingA);
end;

function TFHIRSubsumesOpRequest4B.codingB: TFHIRCodingW;
begin
  result := TFHIRCoding4B.Create((op as TFHIRSubsumesOpRequest).codingB);
end;

function TFHIRSubsumesOpRequest4B.hasCodingA: boolean;
begin
  result := (op as TFHIRSubsumesOpRequest).codingA <> nil;
end;

function TFHIRSubsumesOpRequest4B.hasCodingB: boolean;
begin
  result := (op as TFHIRSubsumesOpRequest).codingB <> nil;
end;

function TFHIRSubsumesOpRequest4B.version: String;
begin
  result := (op as TFHIRSubsumesOpRequest).version;
end;

procedure TFHIRSubsumesOpRequest4B.load(params: THTTPParameters);
begin
  (op as TFHIRSubsumesOpRequest).load(params);
end;

function TFHIRSubsumesOpRequest4B.systemUri: String;
begin
  result := (op as TFHIRSubsumesOpRequest).system;
end;

{ TFHIRSubsumesOpResponse4B }

function TFHIRSubsumesOpResponse4B.asParams: TFHIRResourceV;
begin
  result := (op as TFHIRSubsumesOpResponse).asParams;
end;

procedure TFHIRSubsumesOpResponse4B.load(params: TFHIRResourceV);
begin
  (op as TFHIRSubsumesOpResponse).load(params as TFHIRParameters);
end;

function TFHIRSubsumesOpResponse4B.GetOutcome: String;
begin
  result := (op as TFHIRSubsumesOpResponse).outcome;
end;

procedure TFHIRSubsumesOpResponse4B.load(params: THTTPParameters);
begin
  (op as TFHIRSubsumesOpResponse).load(params);
end;

procedure TFHIRSubsumesOpResponse4B.SetOutcome(Value: String);
begin
  (op as TFHIRSubsumesOpResponse).outcome := value;
end;

{ TFhirCodeableConcept4B }

procedure TFhirCodeableConcept4B.addCoding(coding: TFHIRCodingW);
var
  list : TFHIRCodingList;
  c : TFHIRCoding;
begin
  list := (Element as TFhirCodeableConcept).codingList;
  c := (coding.Element as TFHIRCoding).link;
  list.Add(c);
end;

function TFhirCodeableConcept4B.addCoding: TFHIRCodingW;
begin
  result := TFHIRCoding4B.create((Element as TFhirCodeableConcept).codingList.Append.link);
end;

function TFhirCodeableConcept4B.codingCount: integer;
begin
  result := (Element as TFhirCodeableConcept).codingList.Count;
end;

function TFhirCodeableConcept4B.codings: TFslList<TFhirCodingW>;
var
  c : TFHIRCoding;
begin
  result := TFslList<TFhirCodingW>.create;
  for c in (Element as TFhirCodeableConcept).codingList do
    result.Add(TFHIRCoding4B.Create(c.Link));
end;

function TFhirCodeableConcept4B.fromSystem(Systems: TArray<String>; required: boolean): String;
begin
  result := (Element as TFhirCodeableConcept).fromSystem(Systems, required);
end;

function TFhirCodeableConcept4B.GetText: String;
begin
  result := (Element as TFhirCodeableConcept).text;
end;

function TFhirCodeableConcept4B.renderText: String;
begin
  result := gen(element as TFhirCodeableConcept);
end;

procedure TFhirCodeableConcept4B.SetText(const Value: String);
begin
  (Element as TFhirCodeableConcept).text := value;
end;

function TFhirCodeableConcept4B.fromSystem(System: String; required: boolean): String;
begin
  result := (Element as TFhirCodeableConcept).fromSystem(System, required);
end;

function TFhirCodeableConcept4B.summary: String;
begin
  result := summarise(Element as TFhirCodeableConcept);
end;

{ TFHIRGroup4B }

function TFHIRGroup4B.characteristics: TFslList<TFHIRGroupCharacteristicW>;
var
  gc : TFHIRGroupCharacteristic;
begin
  result := TFslList<TFHIRGroupCharacteristicW>.create;
  for gc in (Resource as TFHIRGroup).characteristicList do
    result.add(TFHIRGroupCharacteristic4B.create(gc.link));
end;

function TFHIRGroup4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFHIRGroup4B.hasCharacteristics: boolean;
begin
  result := (Resource as TFHIRGroup).characteristicList.count > 0;
end;

function TFHIRGroup4B.hasMembers: boolean;
begin
  result := (Resource as TFHIRGroup).memberList.count > 0;
end;

function TFHIRGroup4B.name: String;
begin
  result := (Resource as TFHIRGroup).name;
end;

procedure TFHIRGroup4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

{ TFHIRGroupCharacteristic4B }

function TFHIRGroupCharacteristic4B.code: TFhirCodeableConceptW;
begin
  result := TFhirCodeableConcept4B.Create((element as TFHIRGroupCharacteristic).code);
end;

function TFHIRGroupCharacteristic4B.value: TFhirCodeableConceptW;
begin
  result := TFhirCodeableConcept4B.Create((element as TFHIRGroupCharacteristic).value);
end;

{ TFHIRStatsOpResponse4B }

procedure TFHIRStatsOpResponse4B.addObs(obs: TFHIRResourceV);
begin
  (Op as TFHIRStatsOpResponse).sourceList.Add(obs as TFhirObservation);
end;

function TFHIRStatsOpResponse4B.asParams: TFHIRResourceV;
begin
  result := (op as TFHIRLookupOpResponse).asParams;
end;

procedure TFHIRStatsOpResponse4B.load(params: THTTPParameters);
begin
  (op as TFHIRLookupOpResponse).load(params);
end;

procedure TFHIRStatsOpResponse4B.load(params: TFHIRResourceV);
begin
  (op as TFHIRLookupOpResponse).load(params as TFHIRParameters);
end;

{ TFHIRNamingSystem4B }

function TFHIRNamingSystem4B.getContext: String;
begin
  result := '';
end;

function TFHIRNamingSystem4B.getDate: TFslDateTime;
begin
  result := nm.date;
end;

function TFHIRNamingSystem4B.getDescription: String;
begin
  result := nm.description;
end;

function TFHIRNamingSystem4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFHIRNamingSystem4B.getName: String;
begin
  result := nm.name;
end;

function TFHIRNamingSystem4B.getPublisher: String;
begin
  result := nm.publisher;
end;

function TFHIRNamingSystem4B.getStatus: TPublicationStatus;
begin
  result := MAP_TPublicationStatusR[nm.status];
end;

function TFHIRNamingSystem4B.getUri: String;
begin
  result := nm.getUri;
end;

function TFHIRNamingSystem4B.getURL: String;
begin
  result := '';
end;

function TFHIRNamingSystem4B.getVersion: String;
begin
  result := '';
end;

function TFHIRNamingSystem4B.hasOid(oid: String): boolean;
begin
  result := nm.hasOid(oid);
end;

function TFHIRNamingSystem4B.nm: TFHIRNamingSystem;
begin
  result := (resource as TFHIRNamingSystem);
end;

procedure TFHIRNamingSystem4B.setDate(Value: TFslDateTime);
begin
  nm.date := value;
end;

procedure TFHIRNamingSystem4B.setDescription(Value: String);
begin
  nm.description := value;
end;

procedure TFHIRNamingSystem4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

procedure TFHIRNamingSystem4B.setName(Value: String);
begin
  nm.name := value;
end;

procedure TFHIRNamingSystem4B.setPublisher(Value: String);
begin
  nm.publisher := value;
end;

procedure TFHIRNamingSystem4B.setStatus(Value: TPublicationStatus);
begin
  nm.status := MAP_TPublicationStatus[value];
end;

procedure TFHIRNamingSystem4B.setUrl(Value: String);
begin
  // nothing
end;

procedure TFHIRNamingSystem4B.setVersion(Value: String);
begin
  // nothing
end;


{ TFHIRStructureMap4B }

function TFHIRStructureMap4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

procedure TFHIRStructureMap4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

function TFHIRStructureMap4B.url: String;
begin
  result := (Resource as TFHIRStructureMap).url;
end;

{ TFHIREventDefinition4B }

function TFHIREventDefinition4B.dataType: String;
begin
  if ed.triggerList.Count = 0 then
    result := ''
  else if ed.triggerList[0].dataList.Count = 0 then
    result := ''
  else
    result := CODES_TFhirAllTypesEnum[ed.triggerList[0].dataList[0].type_];
end;

function TFHIREventDefinition4B.ed: TFHIREventDefinition;
begin
  result := resource as TFHIREventDefinition;
end;

function TFHIREventDefinition4B.expression: String;
begin
  if ed.triggerList.Count = 0 then
    result := ''
  else if ed.triggerList[0].condition = nil then
    result := ''
  else
    result := ed.triggerList[0].condition.expression;
end;

function TFHIREventDefinition4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFHIREventDefinition4B.language: String;
begin
  if ed.triggerList.Count = 0 then
    result := ''
  else if ed.triggerList[0].condition = nil then
    result := ''
  else
    result := ed.triggerList[0].condition.language;
end;

procedure TFHIREventDefinition4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

//const
//  MAP_TTriggerType : array [TFhirTriggerTypeEnum] of TTriggerType = (ttNull, ttNamedEvent, ttPeriodic, ttDataChanged, ttDataAdded, ttDataModified, ttDataRemoved, ttDataAccessed, ttDataAccessEnded);

function TFHIREventDefinition4B.triggerType: TTriggerType;
begin
//  result := MAP_TTriggerType[ed.trigger.type_];
  result := ttNull;
end;

function TFHIREventDefinition4B.url: String;
begin
  result := ed.url;
end;

{ TFhirPatient4B }

function TFhirPatient4B.pat : TFhirPatient;
begin
  result := resource as TFhirPatient;
end;

function TFhirPatient4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFhirPatient4B.nameSummary: String;
begin
  result := HumanNamesAsText(pat.nameList);
end;

function TFhirPatient4B.activeStr: String;
begin
  if pat.activeElement = nil then
    result := ''
  else if pat.active then
    result := 'true'
  else
    result := 'false';
end;

function TFhirPatient4B.getActive: boolean;
begin
  result := pat.active;
end;

procedure TFhirPatient4B.setActive(const value : boolean);
begin
  pat.active := value;
end;

function TFhirPatient4B.gender: String;
begin
  result := CODES_TFhirAdministrativeGenderEnum[pat.gender];
end;

function TFhirPatient4B.GetFamily: String;
var
  n : TFhirHumanName;
begin
  result := '';
  for n in pat.nameList do
    if (n.use = NameUseNull) and (n.family <> '') then
      exit(n.family);
  for n in pat.nameList do
    if (n.use = NameUseUsual) and (n.family <> '') then
      exit(n.family);
  for n in pat.nameList do
    if (n.use = NameUseOfficial) and (n.family <> '') then
      exit(n.family);
  for n in pat.nameList do
    if (n.family <> '') then
      exit(n.family);
end;

procedure TFhirPatient4B.SetFamily(const Value: String);
var
  n : TFhirHumanName;
begin
  for n in pat.nameList do
    if (n.use = NameUseNull) then
    begin
      n.family := value;
      exit();
    end;
  for n in pat.nameList do
    if (n.use = NameUseUsual) then
    begin
      n.family := value;
      exit();
    end;
  for n in pat.nameList do
    if (n.use = NameUseOfficial) then
    begin
      n.family := value;
      exit();
    end;
  pat.nameList.append.family := value;
end;
function TFhirPatient4B.getdob: String;
begin
  result := pat.birthDate.toXML;
end;

procedure TFhirPatient4B.setdob(const value : String);
begin
  pat.birthDate := TFslDateTime.fromXML(value);
end;

function TFhirPatient4B.GetIdentifier(systemUri: String): String;
var
  id : TFhirIdentifier;
begin
  result := '';
  for id in pat.identifierList do
    if id.system = systemUri then
      exit(id.value);
end;

procedure TFhirPatient4B.SetIdentifier(systemUri: String; const Value: String);
var
  id : TFhirIdentifier;
begin
  for id in pat.identifierList do
    if id.system = systemUri then
    begin
      id.value := value;
      exit();
    end;
  id := pat.identifierList.Append;
  id.system := systemUri;
  id.value := Value;
end;

function TFhirPatient4B.identifierSummary: String;
begin
  result := IdentifiersAsText(pat.identifierList);
end;

procedure TFhirPatient4B.addGiven(name: String);
var
  n : TFhirHumanName;
begin
  for n in pat.nameList do
    if (n.use = NameUseNull) then
    begin
      n.givenList.add(name);
      exit();
    end;
  for n in pat.nameList do
    if (n.use = NameUseUsual) then
    begin
      n.givenList.add(name);
      exit();
    end;
  for n in pat.nameList do
    if (n.use = NameUseOfficial) then
    begin
      n.givenList.add(name);
      exit();
    end;
  n := pat.nameList.Append;
  n.givenList.add(name);
end;

function TFhirPatient4B.contactSummary: String;
begin
  result := ContactsAsText(pat.telecomList);
end;

procedure TFhirPatient4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

{ TFhirTerminologyCapabilities4B }

procedure TFhirTerminologyCapabilities4B.addExpansionParameter(code, doco: String);
begin
  if (tc.expansion = nil) then
    tc.expansion := TFhirTerminologyCapabilitiesExpansion.Create;
  with tc.expansion.parameterList.Append do
  begin
    name := code;
    documentation := doco;
  end;
end;

procedure TFhirTerminologyCapabilities4B.contact(kind: TContactType; value: String);
var
  c : TFhirContactPoint;
  ct : TFhirConformanceContact;
begin
  ct := tc.contactList.Append;
  c := ct.telecomList.Append;
  c.system := MAP_TContactType[kind];
  c.value := 'http://healthintersections.com.au/';
end;

function TFhirTerminologyCapabilities4B.getContext: String;
begin
  result := tc.context;
end;

function TFhirTerminologyCapabilities4B.getDate: TFslDateTime;
begin
  result := tc.date;
end;

function TFhirTerminologyCapabilities4B.getDescription: String;
begin
  result := tc.description;
end;

function TFhirTerminologyCapabilities4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFhirTerminologyCapabilities4B.getName: String;
begin
  result := tc.name;
end;

function TFhirTerminologyCapabilities4B.getPublisher: String;
begin
  result := tc.publisher;
end;

function TFhirTerminologyCapabilities4B.getStatus: TPublicationStatus;
begin
  result := MAP_TPublicationStatusR[tc.Status];
end;

function TFhirTerminologyCapabilities4B.getURL: String;
begin
  result := tc.url;
end;

function TFhirTerminologyCapabilities4B.getVersion: String;
begin
  result := tc.version;
end;


procedure TFhirTerminologyCapabilities4B.setContext(Value: String);
begin
end;


procedure TFhirTerminologyCapabilities4B.setDate(Value: TFslDateTime);
begin
  tc.date := value;
end;


procedure TFhirTerminologyCapabilities4B.setDescription(Value: String);
begin
  tc.description := value;
end;


procedure TFhirTerminologyCapabilities4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

procedure TFhirTerminologyCapabilities4B.setName(Value: String);
begin
  tc.name := value;
end;


procedure TFhirTerminologyCapabilities4B.setPublisher(Value: String);
begin
  tc.publisher := value;
end;


procedure TFhirTerminologyCapabilities4B.setStatus(Value: TPublicationStatus);
begin
  tc.Status := MAP_TPublicationStatus[Value];
end;


procedure TFhirTerminologyCapabilities4B.setUrl(Value: String);
begin
  tc.url := value;
end;


procedure TFhirTerminologyCapabilities4B.setVersion(Value: String);
begin
  tc.version := value;
end;


procedure TFhirTerminologyCapabilities4B.systemUri(url: String);
begin
  tc.codeSystemList.Append.uri := url;
end;

function TFhirTerminologyCapabilities4B.tc: TFhirTerminologyCapabilities;
begin
  result := (Fres as TFhirTerminologyCapabilities);
end;


{ TFHIRPeriod4B }

function TFHIRPeriod4B.GetEnd: TFslDateTime;
begin
  result := period.end_;
end;

function TFHIRPeriod4B.GetStart: TFslDateTime;
begin
  result := period.start;
end;

function TFHIRPeriod4B.period: TFHIRPeriod;
begin
  result := Element as TFHIRPeriod;
end;

function TFHIRPeriod4B.renderText: String;
begin
  result := gen(element as TFhirPeriod);
end;

procedure TFHIRPeriod4B.SetEnd(const Value: TFslDateTime);

begin
  period.end_ := value;
end;

procedure TFHIRPeriod4B.SetStart(const Value: TFslDateTime);

begin
  period.start := value;
end;

{ TFHIRConsent4B }

function TFHIRConsent4B.consent: TFHIRConsent;
begin
  result := resource as TFHIRConsent;
end;

function TFHIRConsent4B.GetActive: boolean;
begin
  result := consent.status = ConsentStateActive;
end;

function TFHIRConsent4B.GetDateTime: TFslDateTime;
begin
  result := consent.dateTime;
end;

function TFHIRConsent4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFHIRConsent4B.GetPatient: String;
begin
  if consent.patient <> nil then
    result := consent.patient.reference
  else
    result := '';
end;

function TFHIRConsent4B.listProvisions: TFslList<TFhirConsentProvisionW>;
begin
  result := nil; // for now
end;

procedure TFHIRConsent4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

{ TFhirEncounter4B }

function TFhirEncounter4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFhirEncounter4B.patientId: String;
begin
  result := (FRes as TFHIREncounter).subject.getId;
end;

procedure TFhirEncounter4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

function TFhirEncounter4B.summary: String;
begin
  result := CODES_TFhirEncounterStatusEnum[(FRes as TFHIREncounter).status];
end;

{ TFhirTestScript4B }

function TFHIRTestScript4B.getContext: String;
begin
  result := '';
end;

function TFhirTestScript4B.getDate: TFslDateTime;
begin
  result := ts.date;
end;

function TFhirTestScript4B.getDescription: String;
begin
  result := ts.description;
end;

function TFHIRTestScript4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFhirTestScript4B.getName: String;
begin
  result := ts.name;
end;

function TFhirTestScript4B.getPublisher: String;
begin
  result := ts.publisher;
end;

function TFhirTestScript4B.getStatus: TPublicationStatus;
begin
  result := MAP_TPublicationStatusR[ts.Status];
end;

function TFhirTestScript4B.getURL: String;
begin
  result := ts.url;
end;

function TFhirTestScript4B.getVersion: String;
begin
  result := ts.version;
end;

procedure TFhirTestScript4B.setDate(Value: TFslDateTime);
begin
  ts.date := value;
end;


procedure TFhirTestScript4B.setDescription(Value: String);
begin
  ts.description := value;
end;


procedure TFHIRTestScript4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

procedure TFhirTestScript4B.setName(Value: String);
begin
  ts.name := value;
end;


procedure TFhirTestScript4B.setPublisher(Value: String);
begin
  ts.publisher := value;
end;


procedure TFhirTestScript4B.setStatus(Value: TPublicationStatus);
begin
  ts.Status := MAP_TPublicationStatus[Value];
end;


procedure TFhirTestScript4B.setUrl(Value: String);
begin
  ts.url := value;
end;

procedure TFhirTestScript4B.setVersion(Value: String);
begin
  ts.version := value;
end;

function TFhirTestScript4B.ts : TFhirTestScript;
begin
  result := (Fres as TFhirTestScript);
end;


{ TFhirProvenance4B }

procedure TFhirProvenance4B.addTarget(url: String);
begin
  p.targetList.Append.reference := url;
end;

procedure TFhirProvenance4B.clearSignatures;
begin
  p.signatureList.Clear;
end;

procedure TFhirProvenance4B.clearTargets;
begin
  p.targetList.Clear;
end;

function TFhirProvenance4B.GetLanguage: String;
begin
  result := (resource as TFHIRResource).language;
end;

function TFhirProvenance4B.p: TFhirProvenance;
begin
  result := (Fres as TFhirProvenance);
end;

procedure TFhirProvenance4B.SetLanguage(const Value: String);
begin
  (resource as TFHIRResource).language := value;
end;

{ TFhirConceptMapGroupElementDependsOn4B }

function TFhirConceptMapGroupElementDependsOn4B.display: String;
begin
  result := (Element as TFhirConceptMapGroupElementTargetDependsOn).display;
end;

function TFhirConceptMapGroupElementDependsOn4B.property_: String;
begin
  result := (Element as TFhirConceptMapGroupElementTargetDependsOn).property_;
end;

function TFhirConceptMapGroupElementDependsOn4B.system_: String;
begin
  result := (Element as TFhirConceptMapGroupElementTargetDependsOn).system;
end;

function TFhirConceptMapGroupElementDependsOn4B.value: String;
begin
  result := (Element as TFhirConceptMapGroupElementTargetDependsOn).code;
end;


{ TFHIRAttachment4B }

function TFHIRAttachment4B.att: TFhirAttachment;
begin
  result := Element as TFhirAttachment;
end;

function TFHIRAttachment4B.GetContentType: String;
begin
  result := att.contentType;
end;

function TFHIRAttachment4B.GetData: TBytes;
begin
  result := att.data;
end;

function TFHIRAttachment4B.renderText: String;
begin
  result := '??';
end;

{ TFhirImmunization4B }

function TFhirImmunization4B.code(systemUri: String): String;
var
  c : TFHIRCoding;
begin
  result := '';
  if imm.vaccineCode <> nil then
    for c in imm.vaccineCode.codingList do
      if (c.system = systemUri) then
        exit(c.code);
end;

function TFhirImmunization4B.GetDate: TFslDateTime;
begin
  if imm.occurrence is TFhirDateTime then
    result := (imm.occurrence as TFhirDateTime).value
  else
    result := TFslDateTime.makeNull;
end;

function TFhirImmunization4B.GetLanguage: String;
begin
  result := imm.language;
end;

function TFhirImmunization4B.GetLotNumber: String;
begin
  result := imm.lotNumber;
end;

function TFhirImmunization4B.GetManufacturerIdSystem: String;
begin
  if (imm.manufacturer <> nil) and (imm.manufacturer.identifier <> nil) then
    result := imm.manufacturer.identifier.system
  else
    result := '';
end;

function TFhirImmunization4B.GetManufacturerIdValue: String;
begin
  if (imm.manufacturer <> nil) and (imm.manufacturer.identifier <> nil) then
    result := imm.manufacturer.identifier.value
  else
    result := '';
end;

function TFhirImmunization4B.GetPatient: String;
begin
  if imm.patient = nil then
    result := ''
  else
    result := imm.patient.reference;
end;

function TFhirImmunization4B.GetPerformerDisplay: String;
begin
  result := '';
  if (imm.performerList.Count > 0) and (imm.performerList[0].actor <> nil) then
    result := imm.performerList[0].actor.display;
end;

function TFhirImmunization4B.GetStatus: string;
begin
  result := imm.statusElement.value;
end;

function TFhirImmunization4B.hasCode(systemUri, code: String): boolean;
var
  c : TFHIRCoding;
begin
  result := false;
  if imm.vaccineCode <> nil then
    for c in imm.vaccineCode.codingList do
      if (c.system = systemUri) and (c.code = code) then
        exit(true);
end;

function TFhirImmunization4B.imm: TFhirImmunization;
begin
  result := resource as TFhirImmunization;
end;

procedure TFhirImmunization4B.setCodeBySystem(systemUri, code: String);
var
  c : TFHIRCoding;
begin
  if imm.vaccineCode = nil then
    imm.vaccineCode := TFhirCodeableConcept.Create;
  for c in imm.vaccineCode.codingList do
    if (c.system = systemUri) then
    begin
      c.code := code;
      exit;
    end;
  c := imm.vaccineCode.codingList.Append;
  c.system := systemUri;
  c.code := code;
end;

procedure TFhirImmunization4B.SetDate(const Value: TFslDateTime);
begin
  imm.occurrence := TFHIRDateTime.create(value);
end;

procedure TFhirImmunization4B.SetLanguage(const Value: String);
begin
  imm.language := value;
end;

procedure TFhirImmunization4B.SetLotNumber(const Value: String);
begin
  imm.lotNumber := value;
end;

procedure TFhirImmunization4B.SetManufacturerIdSystem(const Value: String);
begin
  if imm.manufacturer = nil then
    imm.manufacturer := TFhirReference.Create;
  if imm.manufacturer.identifier = nil then
    imm.manufacturer.identifier := TFhirIdentifier.Create;
  imm.manufacturer.identifier.system := value;
end;

procedure TFhirImmunization4B.SetManufacturerIdValue(const Value: String);
begin
  if imm.manufacturer = nil then
    imm.manufacturer := TFhirReference.Create;
  if imm.manufacturer.identifier = nil then
    imm.manufacturer.identifier := TFhirIdentifier.Create;
  imm.manufacturer.identifier.value := value;
end;

procedure TFhirImmunization4B.SetPatient(const Value: String);
begin
  if (imm.patient = nil) then
    imm.patient := TFhirReference.Create;
  imm.patient.reference := value;
end;

procedure TFhirImmunization4B.SetPerformerDisplay(const Value: String);
var
  p : TFhirImmunizationPerformer;
begin
  if imm.performerList.Count > 0 then
    p := imm.performerList[0]
  else
    p := imm.performerList.Append;
  if p.actor = nil then
    p.actor := TFhirReference.Create;
  p.actor.display := value;
end;

procedure TFhirImmunization4B.SetStatus(const Value: string);
begin
  if imm.statusElement = nil then
    imm.status := ImmunizationStatusCodesCompleted; // force it to exist
  imm.statusElement.value := value;
end;

{ TFhirIdentifier4B }

function TFhirIdentifier4B.id: TFHIRIdentifier;
begin
  result := FElement as TFHIRIdentifier;
end;

function TFhirIdentifier4B.renderText: String;
begin
  result := gen(element as TFhirIdentifier);
end;

function TFhirIdentifier4B.GetSystem: String;
begin
  result := id.system;
end;

function TFhirIdentifier4B.GetValue: String;
begin
  result := id.value;
end;

procedure TFhirIdentifier4B.SetSystem(const Value: String);
begin
  id.system := value;
end;

procedure TFhirIdentifier4B.SetValue(const Value: String);
begin
  id.value := value;
end;

const
  identifier_use_version_to_general : array [TFhirIdentifierUseEnum] of TIdentifierUse = (iuNull, iuUsual, iuOfficial, iuTemp, iuSecondary, iuOld);
  identifier_use_general_to_version : array [TIdentifierUse] of TFhirIdentifierUseEnum = (IdentifierUseNull, IdentifierUseUsual, IdentifierUseOfficial, IdentifierUseTemp, IdentifierUseSecondary, IdentifierUseOld);

function TFhirIdentifier4B.GetUse: TIdentifierUse;
begin
  result := identifier_use_version_to_general[id.use];
end;

procedure TFhirIdentifier4B.SetUse(const Value: TIdentifierUse);
begin
  id.use := identifier_use_general_to_version[value];
end;

function TFhirIdentifier4B.GetTypeV: TFhirCodeableConceptW;
begin
  if id.type_ = nil then
    result := nil
  else
    result := TFhirCodeableConcept4B.Create(id.type_.Link);
end;

procedure TFhirIdentifier4B.SetTypeV(const Value: TFhirCodeableConceptW);
begin
  if value = nil then
    id.type_ := nil
  else
    id.type_ := ((Value as TFhirCodeableConcept4B).FElement as TFhirCodeableConcept).link;
end;

end.