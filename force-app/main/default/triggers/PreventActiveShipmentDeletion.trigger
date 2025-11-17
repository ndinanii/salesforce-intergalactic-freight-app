trigger PreventActiveShipmentDeletion on Shipment__c (before delete) {
    for (Shipment__c shipment : Trigger.old) {
        // Prevent deletion if shipment is active (In Transit or At Customs)
        if (shipment.Status__c == 'In Transit' || shipment.Status__c == 'At Customs') {
            shipment.addError('Cannot delete active shipments. Only shipments with status "Pending", "Delivered", or "Cancelled" can be deleted.');
        }
    }
}