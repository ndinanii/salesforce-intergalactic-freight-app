/**
 * @description Trigger to maintain Current_Shipment_Count__c on Agent__c
 * Updates count whenever Shipments are inserted, updated, or deleted
 */
trigger ShipmentAgentCounter on Shipment__c (after insert, after update, after delete, after undelete) {
    Set<Id> agentIds = new Set<Id>();
    
    // Collect agent IDs from trigger context
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Shipment__c shipment : Trigger.new) {
            if (shipment.Assigned_Agent__c != null) {
                agentIds.add(shipment.Assigned_Agent__c);
            }
        }
    }
    
    if (Trigger.isUpdate || Trigger.isDelete) {
        for (Shipment__c shipment : Trigger.old) {
            if (shipment.Assigned_Agent__c != null) {
                agentIds.add(shipment.Assigned_Agent__c);
            }
        }
    }
    
    // Update counts for affected agents
    if (!agentIds.isEmpty()) {
        List<Agent__c> agentsToUpdate = new List<Agent__c>();
        
        // Query shipment counts for each agent
        for (AggregateResult ar : [
            SELECT Assigned_Agent__c, COUNT(Id) shipmentCount
            FROM Shipment__c
            WHERE Assigned_Agent__c IN :agentIds
            GROUP BY Assigned_Agent__c
        ]) {
            agentsToUpdate.add(new Agent__c(
                Id = (Id)ar.get('Assigned_Agent__c'),
                Current_Shipment_Count__c = (Decimal)ar.get('shipmentCount')
            ));
        }
        
        // Also handle agents that now have zero shipments
        Set<Id> agentsWithShipments = new Set<Id>();
        for (Agent__c agent : agentsToUpdate) {
            agentsWithShipments.add(agent.Id);
        }
        
        for (Id agentId : agentIds) {
            if (!agentsWithShipments.contains(agentId)) {
                agentsToUpdate.add(new Agent__c(
                    Id = agentId,
                    Current_Shipment_Count__c = 0
                ));
            }
        }
        
        update agentsToUpdate;
    }
}
