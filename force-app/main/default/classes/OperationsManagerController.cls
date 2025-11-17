public with sharing class OperationsManagerController {
    
    /**
     * Get overall shipment statistics for operations dashboard
     * @return Map of statistics
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getShipmentStats() {
        Map<String, Integer> stats = new Map<String, Integer>();
        
        try {
            // Total shipments in the system
            Integer total = [SELECT COUNT() FROM Shipment__c];
            stats.put('total', total);
            
            // Active shipments (In Transit or At Customs)
            Integer active = [
                SELECT COUNT() 
                FROM Shipment__c 
                WHERE Status__c IN ('In Transit', 'At Customs')
            ];
            stats.put('active', active);
            
            // Pending review (At Customs status)
            Integer pendingReview = [
                SELECT COUNT() 
                FROM Shipment__c 
                WHERE Status__c = 'At Customs'
            ];
            stats.put('pendingReview', pendingReview);
            
            // Delivered this month
            Integer deliveredThisMonth = [
                SELECT COUNT() 
                FROM Shipment__c 
                WHERE Status__c = 'Delivered'
                AND ETA__c = THIS_MONTH
            ];
            stats.put('deliveredThisMonth', deliveredThisMonth);
            
            return stats;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving statistics: ' + e.getMessage());
        }
    }
    
    /**
     * Get team shipments with optional status filter
     * @param statusFilter - Filter by status (optional)
     * @param limitCount - Number of records to return
     * @return List of Shipment records
     */
    @AuraEnabled(cacheable=true)
    public static List<Shipment__c> getTeamShipments(String statusFilter, Integer limitCount) {
        try {
            String query = 'SELECT Id, Name, Status__c, Departure_Date__c, ETA__c, ' +
                          'Shipping_Method__c, Account__r.Name, Contact__r.Name, ' +
                          'Assigned_Agent__r.Name, Discount__c ' +
                          'FROM Shipment__c ';
            
            if (String.isNotBlank(statusFilter) && statusFilter != 'all') {
                query += 'WHERE Status__c = :statusFilter ';
            }
            
            query += 'ORDER BY CreatedDate DESC LIMIT :limitCount';
            
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving team shipments: ' + e.getMessage());
        }
    }
    
    /**
     * Get agent performance metrics
     * @return List of agent performance data
     */
    @AuraEnabled(cacheable=true)
    public static List<AgentPerformance> getAgentPerformance() {
        List<AgentPerformance> performanceList = new List<AgentPerformance>();
        
        try {
            // Get all agents with User lookup
            List<Agent__c> agents = [
                SELECT Id, Name, User__c, User__r.Name, Active__c, Region__c
                FROM Agent__c
                WHERE Active__c = true
                ORDER BY Name
            ];
            
            for (Agent__c agent : agents) {
                if (agent.User__c != null) {
                    AgentPerformance perf = new AgentPerformance();
                    perf.agentId = agent.Id;
                    perf.agentName = agent.Name;
                    perf.region = agent.Region__c;
                    
                    // Count total shipments
                    perf.totalShipments = [
                        SELECT COUNT() 
                        FROM Shipment__c 
                        WHERE Assigned_Agent__c = :agent.User__c
                    ];
                    
                    // Count active shipments
                    perf.activeShipments = [
                        SELECT COUNT() 
                        FROM Shipment__c 
                        WHERE Assigned_Agent__c = :agent.User__c
                        AND Status__c IN ('Pending', 'In Transit', 'At Customs')
                    ];
                    
                    // Count delivered this month
                    perf.deliveredThisMonth = [
                        SELECT COUNT() 
                        FROM Shipment__c 
                        WHERE Assigned_Agent__c = :agent.User__c
                        AND Status__c = 'Delivered'
                        AND ETA__c = THIS_MONTH
                    ];
                    
                    performanceList.add(perf);
                }
            }
            
            return performanceList;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving agent performance: ' + e.getMessage());
        }
    }
    
    /**
     * Wrapper class for agent performance data
     */
    public class AgentPerformance {
        @AuraEnabled public String agentId;
        @AuraEnabled public String agentName;
        @AuraEnabled public String region;
        @AuraEnabled public Integer totalShipments;
        @AuraEnabled public Integer activeShipments;
        @AuraEnabled public Integer deliveredThisMonth;
    }
}