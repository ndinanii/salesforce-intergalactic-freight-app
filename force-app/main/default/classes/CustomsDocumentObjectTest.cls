/**
 * @description Comprehensive test class for Customs_Document__c junction object
 * Tests CRUD operations, dual Master-Detail relationships, picklist values, and junction functionality
 */
@isTest
private class CustomsDocumentObjectTest {
    
    /**
     * Test basic customs document creation with required fields
     */
    @isTest
    static void testCustomsDocumentCreation_BasicFields() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'In Customs'
        );
        insert shipment;
        
        // Create Cargo
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Hazardous Materials',
            Weight__c = 10.0
        );
        insert cargo;
        
        // Create Customs Document with required fields
        Customs_Document__c customsDoc = new Customs_Document__c(
            Shipment__c = shipment.Id,
            Cargo__c = cargo.Id,
            Document_Type__c = 'Hazmat Certificate',
            Status__c = 'Pending'
        );
        
        Test.startTest();
        insert customsDoc;
        Test.stopTest();
        
        // Verify customs document was created correctly
        Customs_Document__c insertedDoc = [
            SELECT Name, Shipment__c, Cargo__c, Document_Type__c, Status__c
            FROM Customs_Document__c
            WHERE Id = :customsDoc.Id
        ];
        
        System.assertNotEquals(null, insertedDoc.Name, 'Document auto-number should be generated');
        System.assert(insertedDoc.Name.startsWith('CD-'), 'Document number should start with CD-');
        System.assertEquals(shipment.Id, insertedDoc.Shipment__c, 'Shipment relationship should match');
        System.assertEquals(cargo.Id, insertedDoc.Cargo__c, 'Cargo relationship should match');
        System.assertEquals('Hazmat Certificate', insertedDoc.Document_Type__c);
        System.assertEquals('Pending', insertedDoc.Status__c);
    }
    
    /**
     * Test customs document creation with all fields populated
     */
    @isTest
    static void testCustomsDocumentCreation_AllFields() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Venus',
            Destination_Planet__c = 'Jupiter',
            Status__c = 'In Customs'
        );
        insert shipment;
        
        // Create Cargo
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Electronics',
            Weight__c = 5.0,
            Value__c = 100000.00
        );
        insert cargo;
        
        // Create Customs Document with all fields
        Customs_Document__c customsDoc = new Customs_Document__c(
            Shipment__c = shipment.Id,
            Cargo__c = cargo.Id,
            Document_Type__c = 'Import License',
            Status__c = 'Approved',
            Submitted_Date__c = Date.today().addDays(-5),
            Approval_Date__c = Date.today(),
            Customs_Officer__c = 'Officer Jane Smith',
            Notes__c = 'All documentation verified and approved for import clearance'
        );
        
        Test.startTest();
        insert customsDoc;
        Test.stopTest();
        
        // Verify all fields
        Customs_Document__c insertedDoc = [
            SELECT Name, Document_Type__c, Status__c, Submitted_Date__c, 
                   Approval_Date__c, Customs_Officer__c, Notes__c
            FROM Customs_Document__c
            WHERE Id = :customsDoc.Id
        ];
        
        System.assertEquals('Import License', insertedDoc.Document_Type__c);
        System.assertEquals('Approved', insertedDoc.Status__c);
        System.assertEquals(Date.today().addDays(-5), insertedDoc.Submitted_Date__c);
        System.assertEquals(Date.today(), insertedDoc.Approval_Date__c);
        System.assertEquals('Officer Jane Smith', insertedDoc.Customs_Officer__c);
        System.assertEquals('All documentation verified and approved for import clearance', insertedDoc.Notes__c);
    }
    
    /**
     * Test junction object relationship - multiple documents for one shipment/cargo
     */
    @isTest
    static void testJunctionObjectRelationship() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Mars',
            Destination_Planet__c = 'Earth',
            Status__c = 'In Customs'
        );
        insert shipment;
        
        // Create Cargo
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Hazardous Materials',
            Weight__c = 15.0
        );
        insert cargo;
        
        // Create multiple customs documents for the same shipment/cargo
        List<Customs_Document__c> docList = new List<Customs_Document__c>{
            new Customs_Document__c(
                Shipment__c = shipment.Id,
                Cargo__c = cargo.Id,
                Document_Type__c = 'Import License',
                Status__c = 'Approved'
            ),
            new Customs_Document__c(
                Shipment__c = shipment.Id,
                Cargo__c = cargo.Id,
                Document_Type__c = 'Hazmat Certificate',
                Status__c = 'Approved'
            ),
            new Customs_Document__c(
                Shipment__c = shipment.Id,
                Cargo__c = cargo.Id,
                Document_Type__c = 'Inspection Report',
                Status__c = 'Pending'
            )
        };
        
        Test.startTest();
        insert docList;
        Test.stopTest();
        
        // Verify all documents were created for the same cargo
        List<Customs_Document__c> insertedDocs = [
            SELECT Document_Type__c, Status__c
            FROM Customs_Document__c
            WHERE Cargo__c = :cargo.Id
        ];
        
        System.assertEquals(3, insertedDocs.size(), 'Should have 3 documents for one cargo');
        
        // Verify all document types are present
        Set<String> docTypes = new Set<String>();
        for (Customs_Document__c doc : insertedDocs) {
            docTypes.add(doc.Document_Type__c);
        }
        System.assert(docTypes.contains('Hazmat Certificate'), 'Should have Hazmat Certificate');
        System.assert(docTypes.contains('Import License'), 'Should have Import License');
        System.assert(docTypes.contains('Inspection Report'), 'Should have Inspection Report');
    }
    
    /**
     * Test Master-Detail cascade delete from Shipment
     */
    @isTest
    static void testCascadeDelete_FromShipment() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Saturn',
            Destination_Planet__c = 'Neptune',
            Status__c = 'New'
        );
        insert shipment;
        
        // Create Cargo
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Electronics',
            Weight__c = 3.0
        );
        insert cargo;
        
        // Create Customs Documents
        List<Customs_Document__c> docList = new List<Customs_Document__c>{
            new Customs_Document__c(
                Shipment__c = shipment.Id,
                Cargo__c = cargo.Id,
                Document_Type__c = 'Import License',
                Status__c = 'Pending'
            ),
            new Customs_Document__c(
                Shipment__c = shipment.Id,
                Cargo__c = cargo.Id,
                Document_Type__c = 'Export Declaration',
                Status__c = 'Pending'
            )
        };
        insert docList;
        
        // Verify documents exist
        Integer docCount = [SELECT COUNT() FROM Customs_Document__c WHERE Shipment__c = :shipment.Id];
        System.assertEquals(2, docCount, 'Should have 2 customs documents');
        
        Test.startTest();
        // Delete parent Shipment - should cascade delete Cargo and all Customs Documents
        delete shipment;
        Test.stopTest();
        
        // Verify all customs documents were deleted
        docCount = [SELECT COUNT() FROM Customs_Document__c WHERE Id IN :docList];
        System.assertEquals(0, docCount, 'All customs documents should be deleted when shipment is deleted');
    }
    
    /**
     * Test Master-Detail cascade delete from Cargo
     */
    @isTest
    static void testCascadeDelete_FromCargo() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Mercury',
            Destination_Planet__c = 'Pluto',
            Status__c = 'In Transit'
        );
        insert shipment;
        
        // Create Cargo
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Perishables',
            Weight__c = 20.0
        );
        insert cargo;
        
        // Create Customs Documents
        List<Customs_Document__c> docList = new List<Customs_Document__c>{
            new Customs_Document__c(
                Shipment__c = shipment.Id,
                Cargo__c = cargo.Id,
                Document_Type__c = 'Inspection Report',
                Status__c = 'Approved'
            )
        };
        insert docList;
        
        Test.startTest();
        // Delete Cargo - should cascade delete all associated Customs Documents
        delete cargo;
        Test.stopTest();
        
        // Verify customs documents were deleted
        Integer docCount = [SELECT COUNT() FROM Customs_Document__c WHERE Id IN :docList];
        System.assertEquals(0, docCount, 'Customs documents should be deleted when cargo is deleted');
    }
    
    /**
     * Test updating customs document status workflow
     */
    @isTest
    static void testStatusWorkflow() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'In Customs'
        );
        insert shipment;
        
        // Create Cargo
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Raw Materials',
            Weight__c = 100.0
        );
        insert cargo;
        
        // Create Customs Document
        Customs_Document__c customsDoc = new Customs_Document__c(
            Shipment__c = shipment.Id,
            Cargo__c = cargo.Id,
            Document_Type__c = 'Import License',
            Status__c = 'Pending',
            Submitted_Date__c = Date.today()
        );
        insert customsDoc;
        
        // Update status to Approved
        customsDoc.Status__c = 'Approved';
        customsDoc.Approval_Date__c = Date.today();
        customsDoc.Customs_Officer__c = 'Officer John Doe';
        customsDoc.Notes__c = 'Approved after verification';
        
        Test.startTest();
        update customsDoc;
        Test.stopTest();
        
        // Verify updates
        Customs_Document__c updatedDoc = [
            SELECT Status__c, Approval_Date__c, Customs_Officer__c, Notes__c
            FROM Customs_Document__c
            WHERE Id = :customsDoc.Id
        ];
        
        System.assertEquals('Approved', updatedDoc.Status__c);
        System.assertEquals(Date.today(), updatedDoc.Approval_Date__c);
        System.assertEquals('Officer John Doe', updatedDoc.Customs_Officer__c);
        System.assertEquals('Approved after verification', updatedDoc.Notes__c);
    }
    
    /**
     * Test all picklist values for Document_Type and Status
     */
    @isTest
    static void testPicklistValues() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'In Customs'
        );
        insert shipment;
        
        // Create Cargo
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Hazardous Materials',
            Weight__c = 10.0
        );
        insert cargo;
        
        // Test all Document_Type values
        List<Customs_Document__c> docList = new List<Customs_Document__c>{
            new Customs_Document__c(
                Shipment__c = shipment.Id,
                Cargo__c = cargo.Id,
                Document_Type__c = 'Import License',
                Status__c = 'Pending'
            ),
            new Customs_Document__c(
                Shipment__c = shipment.Id,
                Cargo__c = cargo.Id,
                Document_Type__c = 'Export Declaration',
                Status__c = 'Approved'
            ),
            new Customs_Document__c(
                Shipment__c = shipment.Id,
                Cargo__c = cargo.Id,
                Document_Type__c = 'Hazmat Certificate',
                Status__c = 'Rejected'
            ),
            new Customs_Document__c(
                Shipment__c = shipment.Id,
                Cargo__c = cargo.Id,
                Document_Type__c = 'Inspection Report',
                Status__c = 'Expired'
            )
        };
        
        Test.startTest();
        insert docList;
        Test.stopTest();
        
        // Verify all picklist values were saved correctly
        List<Customs_Document__c> insertedDocs = [
            SELECT Document_Type__c, Status__c 
            FROM Customs_Document__c 
            WHERE Cargo__c = :cargo.Id
        ];
        
        System.assertEquals(4, insertedDocs.size());
        
        // Create maps to verify all values are present
        Map<String, String> docTypeToStatus = new Map<String, String>();
        for (Customs_Document__c doc : insertedDocs) {
            docTypeToStatus.put(doc.Document_Type__c, doc.Status__c);
        }
        
        System.assertEquals('Pending', docTypeToStatus.get('Import License'));
        System.assertEquals('Approved', docTypeToStatus.get('Export Declaration'));
        System.assertEquals('Rejected', docTypeToStatus.get('Hazmat Certificate'));
        System.assertEquals('Expired', docTypeToStatus.get('Inspection Report'));
    }
    
    /**
     * Test bulk customs document creation
     */
    @isTest
    static void testBulkCustomsDocumentCreation() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'In Customs'
        );
        insert shipment;
        
        // Create multiple Cargo items
        List<Cargo__c> cargoList = new List<Cargo__c>();
        for (Integer i = 0; i < 50; i++) {
            cargoList.add(new Cargo__c(
                Shipment__c = shipment.Id,
                Category__c = 'Electronics',
                Weight__c = 1.0 + i
            ));
        }
        insert cargoList;
        
        // Create customs documents for each cargo (2 docs per cargo = 100 total)
        List<Customs_Document__c> docList = new List<Customs_Document__c>();
        String[] docTypes = new String[]{'Import License', 'Export Declaration', 'Hazmat Certificate', 'Inspection Report'};
        String[] statuses = new String[]{'Pending', 'Approved', 'Rejected', 'Expired'};
        
        for (Integer i = 0; i < cargoList.size(); i++) {
            for (Integer j = 0; j < 2; j++) {
                docList.add(new Customs_Document__c(
                    Shipment__c = shipment.Id,
                    Cargo__c = cargoList[i].Id,
                    Document_Type__c = docTypes[Math.mod(i + j, 4)],
                    Status__c = statuses[Math.mod(i + j, 4)]
                ));
            }
        }
        
        Test.startTest();
        insert docList;
        Test.stopTest();
        
        // Verify all records were inserted
        Integer docCount = [SELECT COUNT() FROM Customs_Document__c WHERE Shipment__c = :shipment.Id];
        System.assertEquals(100, docCount, 'Should have 100 customs documents');
        
        // Verify documents are distributed across cargo items
        Integer docsForFirstCargo = [SELECT COUNT() FROM Customs_Document__c WHERE Cargo__c = :cargoList[0].Id];
        System.assertEquals(2, docsForFirstCargo, 'Each cargo should have 2 documents');
    }
    
    /**
     * Test querying customs document with related shipment and cargo data
     */
    @isTest
    static void testCustomsDocumentWithRelatedDataQuery() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'In Customs',
            Departure_Date__c = Date.today().addDays(-10)
        );
        insert shipment;
        
        // Create Cargo
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Hazardous Materials',
            Weight__c = 25.0,
            Value__c = 250000.00
        );
        insert cargo;
        
        // Create Customs Document
        Customs_Document__c customsDoc = new Customs_Document__c(
            Shipment__c = shipment.Id,
            Cargo__c = cargo.Id,
            Document_Type__c = 'Hazmat Certificate',
            Status__c = 'Approved',
            Customs_Officer__c = 'Officer Maria Garcia'
        );
        insert customsDoc;
        
        Test.startTest();
        // Query with related data
        Customs_Document__c queriedDoc = [
            SELECT Id, Name, Document_Type__c, Status__c, Customs_Officer__c,
                   Shipment__r.Name, Shipment__r.Origin_Planet__c, Shipment__r.Destination_Planet__c,
                   Cargo__r.Name, Cargo__r.Category__c, Cargo__r.Weight__c
            FROM Customs_Document__c
            WHERE Id = :customsDoc.Id
        ];
        Test.stopTest();
        
        // Verify relationship queries
        System.assertEquals('Earth', queriedDoc.Shipment__r.Origin_Planet__c);
        System.assertEquals('Mars', queriedDoc.Shipment__r.Destination_Planet__c);
        System.assertEquals('Hazardous Materials', queriedDoc.Cargo__r.Category__c);
        System.assertEquals(25.0, queriedDoc.Cargo__r.Weight__c);
        System.assertNotEquals(null, queriedDoc.Shipment__r.Name);
        System.assertNotEquals(null, queriedDoc.Cargo__r.Name);
    }
}
