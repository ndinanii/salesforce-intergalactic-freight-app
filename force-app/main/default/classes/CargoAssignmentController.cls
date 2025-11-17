public with sharing class CargoAssignmentController {
    
    @AuraEnabled
    public static AssignmentData getAssignmentData() {
        AssignmentData data = new AssignmentData();
        
        // Get active shipments with available capacity
        data.shipments = [
            SELECT Id, Name, Status__c, Departure_Date__c, ETA__c
            FROM Shipment__c
            WHERE Status__c IN ('Pending', 'Loading')
            ORDER BY Departure_Date__c ASC
            LIMIT 50
        ];
        
        // Get unassigned cargo
        data.cargoItems = [
            SELECT Id, Name, Weight__c, Shipment__c
            FROM Cargo__c
            WHERE Shipment__c = NULL
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
        
        return data;
    }
    
    @AuraEnabled
    public static void assignCargoToShipment(String shipmentId, String cargoId) {
        try {
            if (String.isBlank(shipmentId) || String.isBlank(cargoId)) {
                throw new AuraHandledException('Shipment ID and Cargo ID are required');
            }
            
            // Validate shipment exists and is in valid status
            Shipment__c shipment = [
                SELECT Id, Status__c 
                FROM Shipment__c 
                WHERE Id = :shipmentId 
                LIMIT 1
            ];
            
            if (shipment.Status__c != 'Pending' && shipment.Status__c != 'Loading') {
                throw new AuraHandledException('Shipment must be in Pending or Loading status');
            }
            
            // Validate cargo exists and is unassigned
            Cargo__c cargo = [
                SELECT Id, Shipment__c 
                FROM Cargo__c 
                WHERE Id = :cargoId 
                LIMIT 1
            ];
            
            if (cargo.Shipment__c != null) {
                throw new AuraHandledException('This cargo is already assigned to a shipment');
            }
            
            // Perform assignment
            cargo.Shipment__c = shipmentId;
            update cargo;
            
        } catch (QueryException e) {
            throw new AuraHandledException('Invalid Shipment or Cargo ID: ' + e.getMessage());
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating cargo: ' + e.getMessage());
        }
    }
    
    public class AssignmentData {
        @AuraEnabled
        public List<Shipment__c> shipments { get; set; }
        
        @AuraEnabled
        public List<Cargo__c> cargoItems { get; set; }
        
        public AssignmentData() {
            this.shipments = new List<Shipment__c>();
            this.cargoItems = new List<Cargo__c>();
        }
    }
}