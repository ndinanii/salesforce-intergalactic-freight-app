/**
 * @description Comprehensive test class for Agent__c custom object
 * Tests CRUD operations, User lookup, picklist values, rollup summary, and bulk operations
 */
@isTest
private class AgentObjectTest {
    
    /**
     * Test basic agent creation with required fields
     */
    @isTest
    static void testAgentCreation_BasicFields() {
        // Create Agent with required fields
        Agent__c agent = new Agent__c(
            Name = 'Commander Shepard',
            Region__c = 'Alpha Quadrant',
            Active__c = true
        );
        
        Test.startTest();
        insert agent;
        Test.stopTest();
        
        // Verify agent was created correctly
        Agent__c insertedAgent = [
            SELECT Name, Region__c, Active__c
            FROM Agent__c
            WHERE Id = :agent.Id
        ];
        
        System.assertEquals('Commander Shepard', insertedAgent.Name, 'Name should match');
        System.assertEquals('Alpha Quadrant', insertedAgent.Region__c, 'Region should match');
        System.assertEquals(true, insertedAgent.Active__c, 'Active should be true');
    }
    
    /**
     * Test agent creation with all fields populated
     */
    @isTest
    static void testAgentCreation_AllFields() {
        // Get current user for lookup
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        // Create Agent with all fields
        Agent__c agent = new Agent__c(
            Name = 'Captain Kirk',
            User__c = currentUser.Id,
            Region__c = 'Beta Quadrant',
            Active__c = true,
            Max_Concurrent_Shipments__c = 25
        );
        
        Test.startTest();
        insert agent;
        Test.stopTest();
        
        // Verify all fields
        Agent__c insertedAgent = [
            SELECT Name, User__c, Region__c, Active__c, Max_Concurrent_Shipments__c
            FROM Agent__c
            WHERE Id = :agent.Id
        ];
        
        System.assertEquals('Captain Kirk', insertedAgent.Name);
        System.assertEquals(currentUser.Id, insertedAgent.User__c);
        System.assertEquals('Beta Quadrant', insertedAgent.Region__c);
        System.assertEquals(true, insertedAgent.Active__c);
        System.assertEquals(25, insertedAgent.Max_Concurrent_Shipments__c);
    }
    
    /**
     * Test User lookup relationship
     */
    @isTest
    static void testUserLookupRelationship() {
        // Get current user
        User currentUser = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        // Create Agent with User lookup
        Agent__c agent = new Agent__c(
            Name = 'Agent Smith',
            User__c = currentUser.Id,
            Region__c = 'Gamma Quadrant',
            Active__c = true
        );
        insert agent;
        
        Test.startTest();
        // Query agent with user relationship data
        Agent__c queriedAgent = [
            SELECT Id, Name, User__r.Name, User__r.Id
            FROM Agent__c
            WHERE Id = :agent.Id
        ];
        Test.stopTest();
        
        // Verify relationship query
        System.assertEquals(currentUser.Id, queriedAgent.User__r.Id);
        System.assertEquals(currentUser.Name, queriedAgent.User__r.Name);
    }
    
    /**
     * Test updating agent fields
     */
    @isTest
    static void testAgentUpdate() {
        // Create Agent
        Agent__c agent = new Agent__c(
            Name = 'Agent Brown',
            Region__c = 'Alpha Quadrant',
            Active__c = true,
            Max_Concurrent_Shipments__c = 15
        );
        insert agent;
        
        // Update agent
        agent.Name = 'Senior Agent Brown';
        agent.Region__c = 'Beta Quadrant';
        agent.Active__c = false;
        agent.Max_Concurrent_Shipments__c = 30;
        
        Test.startTest();
        update agent;
        Test.stopTest();
        
        // Verify updates
        Agent__c updatedAgent = [
            SELECT Name, Region__c, Active__c, Max_Concurrent_Shipments__c
            FROM Agent__c
            WHERE Id = :agent.Id
        ];
        
        System.assertEquals('Senior Agent Brown', updatedAgent.Name);
        System.assertEquals('Beta Quadrant', updatedAgent.Region__c);
        System.assertEquals(false, updatedAgent.Active__c);
        System.assertEquals(30, updatedAgent.Max_Concurrent_Shipments__c);
    }
    
    /**
     * Test all picklist values for Region
     */
    @isTest
    static void testRegionPicklistValues() {
        // Test each region value
        List<Agent__c> agents = new List<Agent__c>{
            new Agent__c(Name = 'Agent Alpha', Region__c = 'Alpha Quadrant', Active__c = true),
            new Agent__c(Name = 'Agent Beta', Region__c = 'Beta Quadrant', Active__c = true),
            new Agent__c(Name = 'Agent Gamma', Region__c = 'Gamma Quadrant', Active__c = true),
            new Agent__c(Name = 'Agent Delta', Region__c = 'Delta Quadrant', Active__c = true)
        };
        
        Test.startTest();
        insert agents;
        Test.stopTest();
        
        // Verify all regions were saved correctly
        List<Agent__c> insertedAgents = [
            SELECT Name, Region__c 
            FROM Agent__c 
            WHERE Id IN :agents
            ORDER BY Name
        ];
        
        System.assertEquals(4, insertedAgents.size());
        System.assertEquals('Alpha Quadrant', insertedAgents[0].Region__c);
        System.assertEquals('Beta Quadrant', insertedAgents[1].Region__c);
        System.assertEquals('Delta Quadrant', insertedAgents[2].Region__c);
        System.assertEquals('Gamma Quadrant', insertedAgents[3].Region__c);
    }
    
    /**
     * Test bulk agent creation
     */
    @isTest
    static void testBulkAgentCreation() {
        // Create 200 agents
        List<Agent__c> agents = new List<Agent__c>();
        String[] regions = new String[]{'Alpha Quadrant', 'Beta Quadrant', 'Gamma Quadrant', 'Delta Quadrant'};
        
        for (Integer i = 0; i < 200; i++) {
            agents.add(new Agent__c(
                Name = 'Agent ' + i,
                Region__c = regions[Math.mod(i, 4)],
                Active__c = Math.mod(i, 2) == 0,
                Max_Concurrent_Shipments__c = 10 + i
            ));
        }
        
        Test.startTest();
        insert agents;
        Test.stopTest();
        
        // Verify all records were inserted
        Integer agentCount = [SELECT COUNT() FROM Agent__c];
        System.assertEquals(200, agentCount, 'Should have 200 agents');
        
        // Verify region distribution
        Integer alphaCount = [SELECT COUNT() FROM Agent__c WHERE Region__c = 'Alpha Quadrant'];
        System.assertEquals(50, alphaCount, 'Should have 50 agents in Alpha Quadrant');
        
        // Verify active count
        Integer activeCount = [SELECT COUNT() FROM Agent__c WHERE Active__c = true];
        System.assertEquals(100, activeCount, 'Should have 100 active agents');
    }
    
    /**
     * Test required field validation
     */
    @isTest
    static void testRequiredFieldValidation() {
        // Try to create Agent without required Name field
        Agent__c agent = new Agent__c(
            Region__c = 'Alpha Quadrant',
            Active__c = true
            // Name is required by standard Name field configuration
        );
        
        Test.startTest();
        try {
            insert agent;
            // Name is auto-populated if not provided, so verify it was created
            Agent__c insertedAgent = [SELECT Name, Region__c FROM Agent__c WHERE Id = :agent.Id];
            System.assertNotEquals(null, insertedAgent.Name, 'Name should be auto-populated');
            System.assertEquals('Alpha Quadrant', insertedAgent.Region__c);
        } catch (DmlException e) {
            // If exception occurs, verify it's for required field
            System.assert(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 
                         'Exception should be for missing required field');
        }
        Test.stopTest();
    }
    
    /**
     * Test agent with regional assignment
     */
    @isTest
    static void testRegionalAssignment() {
        // Create agents for different regions
        List<Agent__c> agents = new List<Agent__c>{
            new Agent__c(
                Name = 'Alpha Region Agent',
                Region__c = 'Alpha Quadrant',
                Active__c = true,
                Max_Concurrent_Shipments__c = 10
            ),
            new Agent__c(
                Name = 'Beta Region Agent',
                Region__c = 'Beta Quadrant',
                Active__c = true,
                Max_Concurrent_Shipments__c = 15
            )
        };
        
        Test.startTest();
        insert agents;
        Test.stopTest();
        
        // Query agents by region
        List<Agent__c> alphaAgents = [
            SELECT Name, Region__c, Max_Concurrent_Shipments__c
            FROM Agent__c
            WHERE Region__c = 'Alpha Quadrant'
        ];
        
        System.assertEquals(1, alphaAgents.size(), 'Should have 1 agent in Alpha Quadrant');
        System.assertEquals('Alpha Region Agent', alphaAgents[0].Name);
        System.assertEquals(10, alphaAgents[0].Max_Concurrent_Shipments__c);
    }
    
    /**
     * Test Current_Shipment_Count__c rollup summary field
     */
    @isTest
    static void testCurrentShipmentCountRollup() {
        // Create test agent
        Agent__c agent = new Agent__c(
            Name = 'Test Agent',
            Region__c = 'Alpha Quadrant',
            Active__c = true,
            Max_Concurrent_Shipments__c = 20
        );
        insert agent;
        
        // Create test shipments
        List<Shipment__c> shipments = new List<Shipment__c>{
            new Shipment__c(
                Assigned_Agent__c = agent.Id,
                Origin_Planet__c = 'Earth',
                Destination_Planet__c = 'Mars',
                Status__c = 'New',
                Shipping_Method__c = 'Cargo Freighter'
            ),
            new Shipment__c(
                Assigned_Agent__c = agent.Id,
                Origin_Planet__c = 'Venus',
                Destination_Planet__c = 'Jupiter',
                Status__c = 'In Transit',
                Shipping_Method__c = 'Hyperspace Express'
            ),
            new Shipment__c(
                Assigned_Agent__c = agent.Id,
                Origin_Planet__c = 'Mars',
                Destination_Planet__c = 'Saturn',
                Status__c = 'New',
                Shipping_Method__c = 'Standard Warp'
            )
        };
        
        Test.startTest();
        insert shipments;
        Test.stopTest();
        
        // Verify rollup count
        Agent__c agentWithCount = [
            SELECT Current_Shipment_Count__c
            FROM Agent__c
            WHERE Id = :agent.Id
        ];
        
        System.assertEquals(3, agentWithCount.Current_Shipment_Count__c, 
                          'Should have 3 shipments assigned');
    }
    
    /**
     * Test rollup summary recalculates when shipment deleted
     */
    @isTest
    static void testRollupRecalculatesOnShipmentDelete() {
        // Create test agent
        Agent__c agent = new Agent__c(
            Name = 'Test Agent 2',
            Region__c = 'Beta Quadrant',
            Active__c = true
        );
        insert agent;
        
        // Create 5 shipments
        List<Shipment__c> shipments = new List<Shipment__c>();
        for (Integer i = 0; i < 5; i++) {
            shipments.add(new Shipment__c(
                Assigned_Agent__c = agent.Id,
                Origin_Planet__c = 'Planet ' + i,
                Destination_Planet__c = 'Destination ' + i,
                Status__c = 'New',
                Shipping_Method__c = 'Standard Warp'
            ));
        }
        insert shipments;
        
        // Verify initial count
        Agent__c agentBefore = [SELECT Current_Shipment_Count__c FROM Agent__c WHERE Id = :agent.Id];
        System.assertEquals(5, agentBefore.Current_Shipment_Count__c, 'Should have 5 shipments');
        
        Test.startTest();
        // Delete 2 shipments
        delete new List<Shipment__c>{shipments[0], shipments[1]};
        Test.stopTest();
        
        // Verify count updated
        Agent__c agentAfter = [SELECT Current_Shipment_Count__c FROM Agent__c WHERE Id = :agent.Id];
        System.assertEquals(3, agentAfter.Current_Shipment_Count__c, 
                          'Should have 3 shipments after deletion');
    }
}
