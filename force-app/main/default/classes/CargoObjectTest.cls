/**
 * @description Comprehensive test class for Cargo__c custom object
 * Tests CRUD operations, Master-Detail relationship, picklist values, and bulk operations
 */
@isTest
private class CargoObjectTest {
    
    /**
     * Test basic cargo creation with required fields
     */
    @isTest
    static void testCargoCreation_BasicFields() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'New'
        );
        insert shipment;
        
        // Create Cargo with required fields
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Electronics',
            Weight__c = 5.50
        );
        
        Test.startTest();
        insert cargo;
        Test.stopTest();
        
        // Verify cargo was created correctly
        Cargo__c insertedCargo = [
            SELECT Name, Shipment__c, Category__c, Weight__c, Special_Handling__c
            FROM Cargo__c
            WHERE Id = :cargo.Id
        ];
        
        System.assertNotEquals(null, insertedCargo.Name, 'Cargo auto-number should be generated');
        System.assert(insertedCargo.Name.startsWith('CARGO-'), 'Cargo number should start with CARGO-');
        System.assertEquals(shipment.Id, insertedCargo.Shipment__c, 'Shipment relationship should match');
        System.assertEquals('Electronics', insertedCargo.Category__c, 'Category should match');
        System.assertEquals(5.50, insertedCargo.Weight__c, 'Weight should match');
        System.assertEquals(false, insertedCargo.Special_Handling__c, 'Special Handling should default to false');
    }
    
    /**
     * Test cargo creation with all fields populated
     */
    @isTest
    static void testCargoCreation_AllFields() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Venus',
            Destination_Planet__c = 'Jupiter',
            Status__c = 'In Transit'
        );
        insert shipment;
        
        // Create Cargo with all fields
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Hazardous Materials',
            Description__c = 'Radioactive isotopes for medical research',
            Weight__c = 12.75,
            Value__c = 500000.00,
            Special_Handling__c = true
        );
        
        Test.startTest();
        insert cargo;
        Test.stopTest();
        
        // Verify all fields
        Cargo__c insertedCargo = [
            SELECT Name, Shipment__c, Category__c, Description__c, Weight__c, 
                   Value__c, Special_Handling__c
            FROM Cargo__c
            WHERE Id = :cargo.Id
        ];
        
        System.assertEquals('Hazardous Materials', insertedCargo.Category__c);
        System.assertEquals('Radioactive isotopes for medical research', insertedCargo.Description__c);
        System.assertEquals(12.75, insertedCargo.Weight__c);
        System.assertEquals(500000.00, insertedCargo.Value__c);
        System.assertEquals(true, insertedCargo.Special_Handling__c);
    }
    
    /**
     * Test Master-Detail relationship cascade delete
     */
    @isTest
    static void testMasterDetailRelationship_CascadeDelete() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Saturn',
            Destination_Planet__c = 'Neptune',
            Status__c = 'New'
        );
        insert shipment;
        
        // Create multiple Cargo records
        List<Cargo__c> cargoList = new List<Cargo__c>{
            new Cargo__c(Shipment__c = shipment.Id, Category__c = 'Electronics', Weight__c = 2.5),
            new Cargo__c(Shipment__c = shipment.Id, Category__c = 'Perishables', Weight__c = 10.0),
            new Cargo__c(Shipment__c = shipment.Id, Category__c = 'Raw Materials', Weight__c = 50.0)
        };
        insert cargoList;
        
        // Verify cargo records exist
        Integer cargoCount = [SELECT COUNT() FROM Cargo__c WHERE Shipment__c = :shipment.Id];
        System.assertEquals(3, cargoCount, 'Should have 3 cargo records');
        
        Test.startTest();
        // Delete parent Shipment - should cascade delete all Cargo
        delete shipment;
        Test.stopTest();
        
        // Verify all cargo records were deleted
        cargoCount = [SELECT COUNT() FROM Cargo__c WHERE Id IN :cargoList];
        System.assertEquals(0, cargoCount, 'All cargo should be deleted when parent shipment is deleted');
    }
    
    /**
     * Test updating cargo fields
     */
    @isTest
    static void testCargoUpdate() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Mercury',
            Destination_Planet__c = 'Pluto',
            Status__c = 'New'
        );
        insert shipment;
        
        // Create Cargo
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Raw Materials',
            Weight__c = 100.0,
            Value__c = 10000.00,
            Special_Handling__c = false
        );
        insert cargo;
        
        // Update cargo
        cargo.Category__c = 'Hazardous Materials';
        cargo.Weight__c = 95.5;
        cargo.Special_Handling__c = true;
        cargo.Description__c = 'Upgraded to hazmat handling';
        
        Test.startTest();
        update cargo;
        Test.stopTest();
        
        // Verify updates
        Cargo__c updatedCargo = [
            SELECT Category__c, Weight__c, Special_Handling__c, Description__c
            FROM Cargo__c
            WHERE Id = :cargo.Id
        ];
        
        System.assertEquals('Hazardous Materials', updatedCargo.Category__c);
        System.assertEquals(95.5, updatedCargo.Weight__c);
        System.assertEquals(true, updatedCargo.Special_Handling__c);
        System.assertEquals('Upgraded to hazmat handling', updatedCargo.Description__c);
    }
    
    /**
     * Test bulk cargo creation
     */
    @isTest
    static void testBulkCargoCreation() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'New'
        );
        insert shipment;
        
        // Create 200 cargo records
        List<Cargo__c> cargoList = new List<Cargo__c>();
        String[] categories = new String[]{'Electronics', 'Perishables', 'Hazardous Materials', 'Raw Materials', 'Manufactured Goods'};
        
        for (Integer i = 0; i < 200; i++) {
            cargoList.add(new Cargo__c(
                Shipment__c = shipment.Id,
                Category__c = categories[Math.mod(i, 5)],
                Weight__c = 1.0 + i,
                Value__c = 1000.0 * i,
                Special_Handling__c = Math.mod(i, 2) == 0
            ));
        }
        
        Test.startTest();
        insert cargoList;
        Test.stopTest();
        
        // Verify all records were inserted
        Integer cargoCount = [SELECT COUNT() FROM Cargo__c WHERE Shipment__c = :shipment.Id];
        System.assertEquals(200, cargoCount, 'Should have 200 cargo records');
        
        // Verify category distribution
        Integer electronicsCount = [SELECT COUNT() FROM Cargo__c WHERE Category__c = 'Electronics' AND Shipment__c = :shipment.Id];
        System.assertEquals(40, electronicsCount, 'Should have 40 Electronics records');
    }
    
    /**
     * Test all picklist values for Category
     */
    @isTest
    static void testCategoryPicklistValues() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'New'
        );
        insert shipment;
        
        // Test each category value
        List<Cargo__c> cargoList = new List<Cargo__c>{
            new Cargo__c(Shipment__c = shipment.Id, Category__c = 'Electronics', Weight__c = 1.0),
            new Cargo__c(Shipment__c = shipment.Id, Category__c = 'Perishables', Weight__c = 2.0),
            new Cargo__c(Shipment__c = shipment.Id, Category__c = 'Hazardous Materials', Weight__c = 3.0),
            new Cargo__c(Shipment__c = shipment.Id, Category__c = 'Raw Materials', Weight__c = 4.0),
            new Cargo__c(Shipment__c = shipment.Id, Category__c = 'Manufactured Goods', Weight__c = 5.0)
        };
        
        Test.startTest();
        insert cargoList;
        Test.stopTest();
        
        // Verify all categories were saved correctly
        List<Cargo__c> insertedCargo = [
            SELECT Category__c 
            FROM Cargo__c 
            WHERE Shipment__c = :shipment.Id 
            ORDER BY Weight__c
        ];
        
        System.assertEquals(5, insertedCargo.size());
        System.assertEquals('Electronics', insertedCargo[0].Category__c);
        System.assertEquals('Perishables', insertedCargo[1].Category__c);
        System.assertEquals('Hazardous Materials', insertedCargo[2].Category__c);
        System.assertEquals('Raw Materials', insertedCargo[3].Category__c);
        System.assertEquals('Manufactured Goods', insertedCargo[4].Category__c);
    }
    
    /**
     * Test required field validation
     */
    @isTest
    static void testRequiredFieldValidation() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'New'
        );
        insert shipment;
        
        // Try to create Cargo without required Weight field
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Electronics'
            // Weight__c is required but missing
        );
        
        Test.startTest();
        try {
            insert cargo;
            System.assert(false, 'Should have thrown an exception for missing required field');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 
                         'Exception should be for missing required field');
        }
        Test.stopTest();
    }
    
    /**
     * Test querying cargo with related shipment data
     */
    @isTest
    static void testCargoWithShipmentQuery() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'In Transit',
            Departure_Date__c = Date.today()
        );
        insert shipment;
        
        // Create Cargo
        Cargo__c cargo = new Cargo__c(
            Shipment__c = shipment.Id,
            Category__c = 'Electronics',
            Weight__c = 10.0,
            Value__c = 50000.00
        );
        insert cargo;
        
        Test.startTest();
        // Query cargo with parent shipment data
        Cargo__c queriedCargo = [
            SELECT Id, Name, Category__c, Weight__c, Value__c,
                   Shipment__r.Name, Shipment__r.Origin_Planet__c, 
                   Shipment__r.Destination_Planet__c, Shipment__r.Status__c
            FROM Cargo__c
            WHERE Id = :cargo.Id
        ];
        Test.stopTest();
        
        // Verify relationship query
        System.assertEquals('Earth', queriedCargo.Shipment__r.Origin_Planet__c);
        System.assertEquals('Mars', queriedCargo.Shipment__r.Destination_Planet__c);
        System.assertEquals('In Transit', queriedCargo.Shipment__r.Status__c);
        System.assertNotEquals(null, queriedCargo.Shipment__r.Name);
    }
}
