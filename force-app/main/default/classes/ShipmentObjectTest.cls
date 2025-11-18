/**
 * @description Test class for Shipment__c custom object
 * Tests object creation, field validation, and relationship functionality
 * @author Wonga Myendeki
 * @date 2025-11-18
 */
@isTest
private class ShipmentObjectTest {
    
    /**
     * @description Test data setup method
     */
    @TestSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Galactic Trading Co.',
            BillingCity = 'New York',
            BillingCountry = 'United States'
        );
        insert testAccount;
        
        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Stellar',
            Email = 'john.stellar@galactictrade.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Create test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Q4 Freight Deal',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
    }
    
    /**
     * @description Test basic shipment creation with required fields
     */
    @isTest
    static void testShipmentCreation_BasicFields() {
        // Arrange
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'New',
            Shipping_Method__c = 'Standard Warp'
        );
        
        // Act
        Test.startTest();
        insert shipment;
        Test.stopTest();
        
        // Assert
        Shipment__c insertedShipment = [
            SELECT Id, Name, Origin_Planet__c, Destination_Planet__c, 
                   Status__c, Shipping_Method__c
            FROM Shipment__c 
            WHERE Id = :shipment.Id
        ];
        
        System.assertNotEquals(null, insertedShipment.Id, 'Shipment should be created');
        System.assert(insertedShipment.Name.startsWith('SHIP-'), 'Auto-number should start with SHIP-');
        System.assertEquals('Earth', insertedShipment.Origin_Planet__c, 'Origin planet should match');
        System.assertEquals('Mars', insertedShipment.Destination_Planet__c, 'Destination planet should match');
        System.assertEquals('New', insertedShipment.Status__c, 'Status should be New');
        System.assertEquals('Standard Warp', insertedShipment.Shipping_Method__c, 'Shipping method should match');
    }
    
    /**
     * @description Test shipment creation with all fields populated
     */
    @isTest
    static void testShipmentCreation_AllFields() {
        // Arrange
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Venus',
            Destination_Planet__c = 'Jupiter',
            Status__c = 'In Transit',
            Shipping_Method__c = 'Hyperspace Express',
            Departure_Date__c = Date.today(),
            ETA__c = DateTime.now().addDays(5),
            Distance_Light_Years__c = 4.5,
            Discount__c = 15.00,
            Approval_Status__c = 'Approved',
            Account__c = acc.Id,
            Contact__c = con.Id,
            Opportunity__c = opp.Id,
            Assigned_Agent__c = currentUser.Id
        );
        
        // Act
        Test.startTest();
        insert shipment;
        Test.stopTest();
        
        // Assert
        Shipment__c insertedShipment = [
            SELECT Id, Origin_Planet__c, Destination_Planet__c, Status__c,
                   Shipping_Method__c, Departure_Date__c, ETA__c,
                   Distance_Light_Years__c, Discount__c, Approval_Status__c,
                   Account__c, Contact__c, Opportunity__c, Assigned_Agent__c
            FROM Shipment__c 
            WHERE Id = :shipment.Id
        ];
        
        System.assertEquals('Venus', insertedShipment.Origin_Planet__c, 'Origin should match');
        System.assertEquals('Jupiter', insertedShipment.Destination_Planet__c, 'Destination should match');
        System.assertEquals('In Transit', insertedShipment.Status__c, 'Status should match');
        System.assertEquals('Hyperspace Express', insertedShipment.Shipping_Method__c, 'Method should match');
        System.assertEquals(Date.today(), insertedShipment.Departure_Date__c, 'Departure date should match');
        System.assertEquals(4.5, insertedShipment.Distance_Light_Years__c, 'Distance should match');
        System.assertEquals(15.00, insertedShipment.Discount__c, 'Discount should match');
        System.assertEquals('Approved', insertedShipment.Approval_Status__c, 'Approval status should match');
        System.assertEquals(acc.Id, insertedShipment.Account__c, 'Account relationship should be set');
        System.assertEquals(con.Id, insertedShipment.Contact__c, 'Contact relationship should be set');
        System.assertEquals(opp.Id, insertedShipment.Opportunity__c, 'Opportunity relationship should be set');
        System.assertEquals(currentUser.Id, insertedShipment.Assigned_Agent__c, 'Agent should be assigned');
    }
    
    /**
     * @description Test relationship integrity with Account
     */
    @isTest
    static void testShipmentAccountRelationship() {
        // Arrange
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Saturn',
            Destination_Planet__c = 'Neptune',
            Status__c = 'New',
            Shipping_Method__c = 'Cargo Freighter',
            Account__c = acc.Id
        );
        insert shipment;
        
        // Act
        Test.startTest();
        List<Shipment__c> accountShipments = [
            SELECT Id, Account__c 
            FROM Shipment__c 
            WHERE Account__c = :acc.Id
        ];
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, accountShipments.size(), 'Should find one shipment for account');
        System.assertEquals(acc.Id, accountShipments[0].Account__c, 'Account relationship should persist');
    }
    
    /**
     * @description Test shipment update functionality
     */
    @isTest
    static void testShipmentUpdate() {
        // Arrange
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Mercury',
            Destination_Planet__c = 'Pluto',
            Status__c = 'New',
            Shipping_Method__c = 'Standard Warp'
        );
        insert shipment;
        
        // Act
        Test.startTest();
        shipment.Status__c = 'Delivered';
        shipment.Actual_Delivery_Date__c = Date.today();
        update shipment;
        Test.stopTest();
        
        // Assert
        Shipment__c updatedShipment = [
            SELECT Id, Status__c, Actual_Delivery_Date__c 
            FROM Shipment__c 
            WHERE Id = :shipment.Id
        ];
        
        System.assertEquals('Delivered', updatedShipment.Status__c, 'Status should be updated');
        System.assertEquals(Date.today(), updatedShipment.Actual_Delivery_Date__c, 'Delivery date should be set');
    }
    
    /**
     * @description Test bulk shipment creation
     */
    @isTest
    static void testBulkShipmentCreation() {
        // Arrange
        List<Shipment__c> shipments = new List<Shipment__c>();
        for (Integer i = 0; i < 200; i++) {
            shipments.add(new Shipment__c(
                Origin_Planet__c = 'Earth',
                Destination_Planet__c = 'Planet-' + i,
                Status__c = 'New',
                Shipping_Method__c = 'Cargo Freighter',
                Distance_Light_Years__c = Math.random() * 100
            ));
        }
        
        // Act
        Test.startTest();
        insert shipments;
        Test.stopTest();
        
        // Assert
        List<Shipment__c> insertedShipments = [
            SELECT Id 
            FROM Shipment__c
        ];
        
        System.assertEquals(200, insertedShipments.size(), 'Should insert 200 shipments');
    }
    
    /**
     * @description Test shipment deletion
     */
    @isTest
    static void testShipmentDeletion() {
        // Arrange
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Uranus',
            Destination_Planet__c = 'Neptune',
            Status__c = 'Cancelled',
            Shipping_Method__c = 'Standard Warp'
        );
        insert shipment;
        
        // Act
        Test.startTest();
        delete shipment;
        Test.stopTest();
        
        // Assert
        List<Shipment__c> remainingShipments = [
            SELECT Id 
            FROM Shipment__c 
            WHERE Id = :shipment.Id
        ];
        
        System.assertEquals(0, remainingShipments.size(), 'Shipment should be deleted');
    }
    
    /**
     * @description Test picklist value assignments
     */
    @isTest
    static void testPicklistValues() {
        // Test all Status picklist values
        List<String> statusValues = new List<String>{
            'New', 'In Transit', 'In Customs', 'Delayed', 'Delivered', 'Cancelled'
        };
        
        List<Shipment__c> shipments = new List<Shipment__c>();
        for (String status : statusValues) {
            shipments.add(new Shipment__c(
                Origin_Planet__c = 'Earth',
                Destination_Planet__c = 'Mars',
                Status__c = status,
                Shipping_Method__c = 'Standard Warp'
            ));
        }
        
        // Act
        Test.startTest();
        insert shipments;
        Test.stopTest();
        
        // Assert
        System.assertEquals(6, shipments.size(), 'Should create shipments with all status values');
        
        // Test all Shipping Method picklist values
        List<String> shippingMethods = new List<String>{
            'Hyperspace Express', 'Standard Warp', 'Cargo Freighter'
        };
        
        for (String method : shippingMethods) {
            Shipment__c testShipment = new Shipment__c(
                Origin_Planet__c = 'Venus',
                Destination_Planet__c = 'Jupiter',
                Status__c = 'New',
                Shipping_Method__c = method
            );
            insert testShipment;
            
            Shipment__c inserted = [
                SELECT Shipping_Method__c 
                FROM Shipment__c 
                WHERE Id = :testShipment.Id
            ];
            System.assertEquals(method, inserted.Shipping_Method__c, 'Shipping method should be set correctly');
        }
    }
    
    /**
     * @description Test field data types and limits
     */
    @isTest
    static void testFieldDataTypes() {
        // Arrange
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'New',
            Shipping_Method__c = 'Hyperspace Express',
            Distance_Light_Years__c = 999999.99, // Test max precision
            Discount__c = 99.99 // Test percentage field
        );
        
        // Act
        Test.startTest();
        insert shipment;
        Test.stopTest();
        
        // Assert
        Shipment__c inserted = [
            SELECT Distance_Light_Years__c, Discount__c 
            FROM Shipment__c 
            WHERE Id = :shipment.Id
        ];
        
        System.assertEquals(999999.99, inserted.Distance_Light_Years__c, 'Distance should handle large numbers');
        System.assertEquals(99.99, inserted.Discount__c, 'Discount percentage should be stored correctly');
    }
    
    /**
     * @description Test rollup summary fields - Total_Weight__c and Cargo_Count__c
     */
    @isTest
    static void testRollupSummaryFields() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Earth',
            Destination_Planet__c = 'Mars',
            Status__c = 'New'
        );
        insert shipment;
        
        // Verify initial rollup values are 0
        Shipment__c initialShipment = [
            SELECT Total_Weight__c, Cargo_Count__c 
            FROM Shipment__c 
            WHERE Id = :shipment.Id
        ];
        System.assertEquals(0, initialShipment.Total_Weight__c, 'Initial total weight should be 0');
        System.assertEquals(0, initialShipment.Cargo_Count__c, 'Initial cargo count should be 0');
        
        // Create multiple cargo items
        List<Cargo__c> cargoList = new List<Cargo__c>{
            new Cargo__c(
                Shipment__c = shipment.Id,
                Category__c = 'Electronics',
                Weight__c = 10.5
            ),
            new Cargo__c(
                Shipment__c = shipment.Id,
                Category__c = 'Perishables',
                Weight__c = 25.75
            ),
            new Cargo__c(
                Shipment__c = shipment.Id,
                Category__c = 'Raw Materials',
                Weight__c = 50.0
            )
        };
        
        Test.startTest();
        insert cargoList;
        Test.stopTest();
        
        // Verify rollup calculations
        Shipment__c updatedShipment = [
            SELECT Total_Weight__c, Cargo_Count__c 
            FROM Shipment__c 
            WHERE Id = :shipment.Id
        ];
        
        System.assertEquals(86.25, updatedShipment.Total_Weight__c, 'Total weight should be sum of all cargo weights (10.5 + 25.75 + 50.0)');
        System.assertEquals(3, updatedShipment.Cargo_Count__c, 'Cargo count should be 3');
    }
    
    /**
     * @description Test rollup summary updates when cargo is deleted
     */
    @isTest
    static void testRollupSummaryOnCargoDelete() {
        // Create parent Shipment
        Shipment__c shipment = new Shipment__c(
            Origin_Planet__c = 'Venus',
            Destination_Planet__c = 'Jupiter',
            Status__c = 'In Transit'
        );
        insert shipment;
        
        // Create cargo items
        List<Cargo__c> cargoList = new List<Cargo__c>{
            new Cargo__c(
                Shipment__c = shipment.Id,
                Category__c = 'Hazardous Materials',
                Weight__c = 15.0
            ),
            new Cargo__c(
                Shipment__c = shipment.Id,
                Category__c = 'Manufactured Goods',
                Weight__c = 35.0
            )
        };
        insert cargoList;
        
        // Verify initial rollup
        Shipment__c shipmentBefore = [
            SELECT Total_Weight__c, Cargo_Count__c 
            FROM Shipment__c 
            WHERE Id = :shipment.Id
        ];
        System.assertEquals(50.0, shipmentBefore.Total_Weight__c, 'Initial total weight should be 50.0');
        System.assertEquals(2, shipmentBefore.Cargo_Count__c, 'Initial cargo count should be 2');
        
        // Delete one cargo item
        Test.startTest();
        delete cargoList[0];
        Test.stopTest();
        
        // Verify rollup recalculated
        Shipment__c shipmentAfter = [
            SELECT Total_Weight__c, Cargo_Count__c 
            FROM Shipment__c 
            WHERE Id = :shipment.Id
        ];
        
        System.assertEquals(35.0, shipmentAfter.Total_Weight__c, 'Total weight should be updated to 35.0');
        System.assertEquals(1, shipmentAfter.Cargo_Count__c, 'Cargo count should be updated to 1');
    }
}

