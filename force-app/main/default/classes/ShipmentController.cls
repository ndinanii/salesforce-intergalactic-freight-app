public with sharing class ShipmentController {
    
    /**
     * Get recent shipments assigned to the current user
     * @param userId - User ID to filter shipments
     * @param limitCount - Number of records to return
     * @return List of Shipment records
     */
    @AuraEnabled(cacheable=true)
    public static List<Shipment__c> getRecentShipments(Id userId, Integer limitCount) {
        try {
            return [
                SELECT Id, Name, Status__c, Departure_Date__c, ETA__c, 
                       Shipping_Method__c, Account__r.Name, Contact__r.Name
                FROM Shipment__c
                WHERE Assigned_Agent__c = :userId
                ORDER BY CreatedDate DESC
                LIMIT :limitCount
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving shipments: ' + e.getMessage());
        }
    }
    
    /**
     * Get shipment statistics for the dashboard
     * @param userId - User ID to filter shipments
     * @return Map of statistics
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getShipmentStats(Id userId) {
        Map<String, Integer> stats = new Map<String, Integer>();
        
        try {
            // Get total shipments
            Integer totalShipments = [
                SELECT COUNT() 
                FROM Shipment__c 
                WHERE Assigned_Agent__c = :userId
            ];
            stats.put('total', totalShipments);
            
            // Get in-transit shipments
            Integer inTransit = [
                SELECT COUNT() 
                FROM Shipment__c 
                WHERE Assigned_Agent__c = :userId 
                AND Status__c = 'In Transit'
            ];
            stats.put('inTransit', inTransit);
            
            // Get pending shipments
            Integer pending = [
                SELECT COUNT() 
                FROM Shipment__c 
                WHERE Assigned_Agent__c = :userId 
                AND Status__c = 'Pending'
            ];
            stats.put('pending', pending);
            
            // Get delivered shipments (this month)
            Integer delivered = [
                SELECT COUNT() 
                FROM Shipment__c 
                WHERE Assigned_Agent__c = :userId 
                AND Status__c = 'Delivered'
                AND ETA__c = THIS_MONTH
            ];
            stats.put('delivered', delivered);
            
            return stats;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving statistics: ' + e.getMessage());
        }
    }
}