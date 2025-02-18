unit fhir4b_authmap;

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
  fhir_common,
  fhir4b_resources;

// categories for web login
// tcClinical, tcData, tcMeds, tcSchedule, tcAudit, tcDocuments, tcFinancial, tcOther

const
  RESOURCE_CATEGORY : array [TFHIRResourceType] of TTokenCategory =
    (
    tcOther, // frtNull
    tcFinancial, // frtAccount
    tcOther, // frtActivityDefinition
    tcMedicationDefinition, // frtAdministrableProductDefinition
    tcClinical, // frtAdverseEvent
    tcClinical, // frtAllergyIntolerance
    tcSchedule, // frtAppointment
    tcSchedule, // frtAppointmentResponse
    tcAudit, // frtAuditEvent
    tcClinical, // frtBasic
    tcDocuments, // frtBinary
    tcMedicationDefinition, // frtBiologicallyDerivedProduct
    tcClinical, // frtBodyStructure
    tcDocuments, // frtBundle
    tcOther, // frtCapabilityStatement
    tcClinical, // frtCarePlan
    tcClinical, // frtCareTeam
    tcOther,
    tcFinancial, // frtChargeItem
    tcFinancial, // frtChargeItemDefinition
    tcOther, // frtCitation
    tcFinancial, // frtClaim
    tcFinancial, // frtClaimResponse
    tcClinical, // frtClinicalImpression
    tcClinical, // frtClinicalUseDefinition
    tcOther, // frtCodeSystem
    tcDocuments, // frtCommunication
    tcDocuments, // frtCommunicationRequest
    tcOther, // frtCompartmentDefinition
    tcDocuments, // frtComposition
    tcOther, // frtConceptMap
    tcClinical, // frtCondition
    tcData, // frtConsent
    tcDocuments, // frtContract
    tcFinancial, // frtCoverage
    tcFinancial, // frtCoverageEligibilityRequest
    tcFinancial, // frtCoverageEligibilityResponse
    tcClinical, // frtDetectedIssue
    tcData, // frtDevice
    tcOther, // frtDeviceDefinition
    tcData, // frtDeviceMetric
    tcClinical, // frtDeviceRequest
    tcClinical, // frtDeviceUseStatement
    tcClinical, // frtDiagnosticReport
    tcDocuments, // frtDocumentManifest
    tcDocuments, // frtDocumentReference
    tcSchedule, // frtEncounter
    tcData, // frtEndpoint
    tcFinancial, // frtEnrollmentRequest
    tcFinancial, // frtEnrollmentResponse
    tcSchedule, // frtEpisodeOfCare
    tcOther, // frtEventDefinition
    tcOther, // frtEvidence
    tcOther, // frtEvidenceReport
    tcOther, // frtEvidenceVariable
    tcOther, // frtExampleScenario
    tcFinancial, // frtExplanationOfBenefit
    tcClinical, // frtFamilyMemberHistory
    tcClinical, // frtFlag
    tcClinical, // frtGoal
    tcOther, // frtGraphDefinition
    tcData, // frtGroup
    tcClinical, // frtGuidanceResponse
    tcData, // frtHealthcareService
    tcClinical, // frtImagingStudy
    tcClinical, // frtImmunization
    tcClinical, // frtImmunizationEvaluation
    tcClinical, // frtImmunizationRecommendation
    tcOther, // frtImplementationGuide
    tcMedicationDefinition, // frtIngredient
    tcFinancial, // frtInsurancePlan
    tcFinancial, // frtInvoice
    tcOther, // frtLibrary
    tcData, // frtLinkage
    tcDocuments, // frtList
    tcData, // frtLocation
    tcMedicationDefinition, // frtManufacturedItemDefinition
    tcOther, // frtMeasure
    tcData, // frtMeasureReport
    tcDocuments, // frtMedia
    tcMeds, // frtMedication
    tcMeds, // frtMedicationAdministration
    tcMeds, // frtMedicationDispense
    tcMedicationDefinition, // frtMedicationKnowledge
    tcMeds, // frtMedicationRequest
    tcMeds, // frtMedicationStatement
    tcMedicationDefinition, // frtMedicinalProductDefinition
    tcOther, // frtMessageDefinition
    tcData, // frtMessageHeader
    tcClinical, // frtSequence
    tcOther, // frtNamingSystem
    tcClinical, // frtNutritionOrder
    tcClinical, // frtNutritionProduct
    tcClinical, // frtObservation
    tcOther, // frtObservationDefinition
    tcOther, // frtOperationDefinition
    tcData, // frtOperationOutcome
    tcData, // frtOrganization
    tcData, // frtOrganizationAffiliation
    tcMedicationDefinition, // frtPackagedProductDefinition
    tcData, // frtParameters
    tcData, // frtPatient
    tcFinancial, // frtPaymentNotice
    tcFinancial, // frtPaymentReconciliation
    tcData, // frtPerson
    tcOther, // frtPlanDefinition
    tcData, // frtPractitioner
    tcData, // frtPractitionerRole
    tcClinical, // frtProcedure
    tcAudit, // frtProvenance
    tcOther, // frtQuestionnaire
    tcClinical, // frtQuestionnaireResponse
    tcMedicationDefinition, // frtRegulatedAuthorization
    tcData, // frtRelatedPerson
    tcOther, // frtRequestGroup
    tcData, // frtResearchDefinition
    tcData, // frtResearchELementDefinition
    tcData, // frtResearchStudy
    tcData, // frtResearchSubject
    tcClinical, // frtRiskAssessment
    tcSchedule, // frtSchedule
    tcOther, // frtSearchParameter
    tcClinical, // frtServiceRequest
    tcSchedule, // frtSlot
    tcClinical, // frtSpecimen
    tcOther, // frtSpecimenDefinition
    tcOther, // frtStructureDefinition
    tcOther, // frtStructureMap
    tcData, // frtSubscription
    tcData, // frtSubscriptionStatus
    tcData, // frtSubscriptionTopic
    tcData, // frtSubstance
    tcMedicationDefinition, // frtSubstanceDefinition
    tcData, // frtSupplyDelivery
    tcData, // frtSupplyRequest
    tcData, // frtTask
    tcOther, // frtTerminologyCapabilities
    tcOther, // frtTestReport
    tcOther, // frtTestScript
    tcOther, // frtValueSet
    tcMedicationDefinition, // frtVerificationResult
    tcClinical, // frtVisionPrescription
    tcOther); // frtCustom)


implementation

end.
