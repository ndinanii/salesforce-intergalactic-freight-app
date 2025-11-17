public with sharing class CustomsClearanceValidator {
    
    // Required documents by destination region
    private static final Map<String, Set<String>> REQUIRED_DOCUMENTS = new Map<String, Set<String>>{
        'Earth' => new Set<String>{'Commercial Invoice', 'Bill of Lading', 'Certificate of Origin'},
        'Mars' => new Set<String>{'Commercial Invoice', 'Bill of Lading', 'Phytosanitary Certificate'},
        'Jupiter' => new Set<String>{'Commercial Invoice', 'Bill of Lading', 'Safety Data Sheet', 'Gas Giant Transit Permit'},
        'Venus' => new Set<String>{'Commercial Invoice', 'Bill of Lading', 'Heat Resistance Certificate'},
        'Saturn' => new Set<String>{'Commercial Invoice', 'Bill of Lading', 'Ring Zone Navigation Permit'},
        'Neptune' => new Set<String>{'Commercial Invoice', 'Bill of Lading', 'Deep Space Transit License'}
    };
    
    // Restricted cargo types by destination
    private static final Map<String, Set<String>> RESTRICTED_CARGO = new Map<String, Set<String>>{
        'Mars' => new Set<String>{'Biological Materials', 'Water'},
        'Jupiter' => new Set<String>{'Flammable Materials', 'Pressurized Containers'},
        'Venus' => new Set<String>{'Electronics', 'Organic Materials'}
    };
    
    /**
     * Validate customs clearance for a shipment
     * @param shipmentId Shipment Id
     * @return ValidationResult with isValid flag and list of issues
     */
    public static ValidationResult validateShipment(Id shipmentId) {
        ValidationResult result = new ValidationResult();
        result.isValid = true;
        result.issues = new List<String>();
        
        // Get shipment details
        Shipment__c shipment = getShipmentDetails(shipmentId);
        
        if (shipment == null) {
            result.isValid = false;
            result.issues.add('Shipment not found');
            return result;
        }
        
        // Validate required documents
        validateDocuments(shipment, result);
        
        // Validate cargo restrictions
        validateCargoRestrictions(shipment, result);
        
        // Validate customs document status
        validateDocumentStatus(shipment, result);
        
        return result;
    }
    
    /**
     * Validate multiple shipments
     * @param shipmentIds Set of Shipment Ids
     * @return Map of Shipment Id to ValidationResult
     */
    public static Map<Id, ValidationResult> validateBulkShipments(Set<Id> shipmentIds) {
        Map<Id, ValidationResult> resultsMap = new Map<Id, ValidationResult>();
        
        for (Id shipmentId : shipmentIds) {
            resultsMap.put(shipmentId, validateShipment(shipmentId));
        }
        
        return resultsMap;
    }
    
    /**
     * Check if shipment is ready for customs clearance
     * @param shipmentId Shipment Id
     * @return Boolean true if ready, false otherwise
     */
    public static Boolean isReadyForClearance(Id shipmentId) {
        ValidationResult result = validateShipment(shipmentId);
        return result.isValid;
    }
    
    /**
     * Get shipment details with related records
     */
    private static Shipment__c getShipmentDetails(Id shipmentId) {
        List<Shipment__c> shipments = [
            SELECT Id, Shipping_Method__c, Status__c,
                   (SELECT Id, Document_Type__c, Status__c FROM Customs_Documents__r),
                   (SELECT Id, Category__c, Weight__c FROM Cargo__r)
            FROM Shipment__c
            WHERE Id = :shipmentId
            LIMIT 1
        ];
        
        return shipments.isEmpty() ? null : shipments[0];
    }
    
    /**
     * Validate required documents are present
     */
    private static void validateDocuments(Shipment__c shipment, ValidationResult result) {
        String destination = getDestinationFromShippingMethod(shipment.Shipping_Method__c);
        
        if (!REQUIRED_DOCUMENTS.containsKey(destination)) {
            result.issues.add('Unknown destination: ' + destination);
            result.isValid = false;
            return;
        }
        
        Set<String> requiredDocs = REQUIRED_DOCUMENTS.get(destination);
        Set<String> existingDocs = new Set<String>();
        
        for (Customs_Document__c doc : shipment.Customs_Documents__r) {
            existingDocs.add(doc.Document_Type__c);
        }
        
        for (String requiredDoc : requiredDocs) {
            if (!existingDocs.contains(requiredDoc)) {
                result.issues.add('Missing required document: ' + requiredDoc);
                result.isValid = false;
            }
        }
    }
    
    /**
     * Validate cargo against destination restrictions
     */
    private static void validateCargoRestrictions(Shipment__c shipment, ValidationResult result) {
        String destination = getDestinationFromShippingMethod(shipment.Shipping_Method__c);
        
        if (!RESTRICTED_CARGO.containsKey(destination)) {
            return; // No restrictions for this destination
        }
        
        Set<String> restrictedTypes = RESTRICTED_CARGO.get(destination);
        
        for (Cargo__c cargo : shipment.Cargo__r) {
            if (restrictedTypes.contains(cargo.Category__c)) {
                result.issues.add('Restricted cargo category for ' + destination + ': ' + cargo.Category__c);
                result.isValid = false;
            }
        }
    }
    
    /**
     * Validate customs document statuses
     */
    private static void validateDocumentStatus(Shipment__c shipment, ValidationResult result) {
        for (Customs_Document__c doc : shipment.Customs_Documents__r) {
            if (doc.Status__c == 'Rejected' || doc.Status__c == 'Expired') {
                result.issues.add('Document ' + doc.Document_Type__c + ' has invalid status: ' + doc.Status__c);
                result.isValid = false;
            }
        }
    }
    
    /**
     * Get required documents for a destination
     * @param destination Destination planet
     * @return Set of required document types
     */
    public static Set<String> getRequiredDocuments(String destination) {
        if (REQUIRED_DOCUMENTS.containsKey(destination)) {
            return REQUIRED_DOCUMENTS.get(destination);
        }
        return new Set<String>();
    }
    
    /**
     * Get restricted cargo types for a destination
     * @param destination Destination planet
     * @return Set of restricted cargo types
     */
    public static Set<String> getRestrictedCargo(String destination) {
        if (RESTRICTED_CARGO.containsKey(destination)) {
            return RESTRICTED_CARGO.get(destination);
        }
        return new Set<String>();
    }
    
    /**
     * Helper method to extract destination from shipping method
     * @param shippingMethod The shipping method field value
     * @return Destination planet name
     */
    private static String getDestinationFromShippingMethod(String shippingMethod) {
        if (String.isBlank(shippingMethod)) {
            return 'Unknown';
        }
        // Assumes shipping method contains destination (e.g., "Express to Mars")
        // Adjust logic based on actual Shipping_Method__c picklist values
        String method = shippingMethod.toLowerCase();
        if (method.contains('mars')) return 'Mars';
        if (method.contains('jupiter')) return 'Jupiter';
        if (method.contains('saturn')) return 'Saturn';
        if (method.contains('venus')) return 'Venus';
        if (method.contains('neptune')) return 'Neptune';
        if (method.contains('earth')) return 'Earth';
        return 'Unknown';
    }
    
    /**
     * Wrapper class for validation results
     */
    public class ValidationResult {
        public Boolean isValid { get; set; }
        public List<String> issues { get; set; }
        
        public ValidationResult() {
            this.isValid = true;
            this.issues = new List<String>();
        }
        
        public String getIssuesAsString() {
            return String.join(issues, '; ');
        }
    }
}