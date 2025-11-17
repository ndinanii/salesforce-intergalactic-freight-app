public with sharing class ShipmentSummaryController {
    
    public Integer totalShipments { get; set; }
    public Integer inTransitCount { get; set; }
    public Integer pendingCount { get; set; }
    public Integer deliveredThisMonth { get; set; }
    public List<Shipment__c> recentShipments { get; set; }
    public List<StatusBreakdown> statusBreakdown { get; set; }
    
    public ShipmentSummaryController() {
        loadData();
    }
    
    public void loadData() {
        // Get summary statistics
        totalShipments = [SELECT COUNT() FROM Shipment__c];
        
        inTransitCount = [
            SELECT COUNT() 
            FROM Shipment__c 
            WHERE Status__c = 'In Transit'
        ];
        
        pendingCount = [
            SELECT COUNT() 
            FROM Shipment__c 
            WHERE Status__c = 'Pending'
        ];
        
        deliveredThisMonth = [
            SELECT COUNT() 
            FROM Shipment__c 
            WHERE Status__c = 'Delivered' 
            AND ETA__c = THIS_MONTH
        ];
        
        // Get recent shipments
        recentShipments = [
            SELECT Id, Name, Status__c, Departure_Date__c, ETA__c, 
                   Shipping_Method__c, Account__r.Name, 
                   Assigned_Agent__r.Name
            FROM Shipment__c
            ORDER BY CreatedDate DESC
            LIMIT 20
        ];
        
        // Get status breakdown
        statusBreakdown = new List<StatusBreakdown>();
        
        AggregateResult[] groupedResults = [
            SELECT Status__c status, COUNT(Id) total
            FROM Shipment__c
            GROUP BY Status__c
        ];
        
        for (AggregateResult ar : groupedResults) {
            StatusBreakdown sb = new StatusBreakdown();
            sb.status = String.valueOf(ar.get('status'));
            sb.count = Integer.valueOf(ar.get('total'));
            statusBreakdown.add(sb);
        }
    }
    
    public PageReference refreshData() {
        loadData();
        return null;
    }
    
    public class StatusBreakdown {
        public String status { get; set; }
        public Integer count { get; set; }
    }
}