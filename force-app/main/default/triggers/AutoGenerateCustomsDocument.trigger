trigger AutoGenerateCustomsDocument on Shipment__c (after insert) {
    List<Customs_Document__c> customsDocsToInsert = new List<Customs_Document__c>();
    
    for (Shipment__c shipment : Trigger.new) {
        // Auto-generate a Customs Document for each new shipment
        Customs_Document__c customsDoc = new Customs_Document__c();
        customsDoc.Shipment__c = shipment.Id;
        customsDoc.Status__c = 'Pending';
        customsDoc.Document_Type__c = 'Commercial Invoice';
        
        customsDocsToInsert.add(customsDoc);
    }
    
    if (!customsDocsToInsert.isEmpty()) {
        try {
            insert customsDocsToInsert;
        } catch (DmlException e) {
            System.debug('Error creating Customs Documents: ' + e.getMessage());
        }
    }
}