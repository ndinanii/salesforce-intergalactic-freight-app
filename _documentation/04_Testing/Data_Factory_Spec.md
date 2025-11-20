````markdown
# Test Data Factory Specification

## Purpose
This document defines the standards and specifications for creating test data in a consistent, reusable, and maintainable way.

---

## Test Data Factory Principles

1. **Centralized Creation:** All test data created through factory methods
2. **Realistic Data:** Mimic production data patterns
3. **Minimal Dependencies:** Create only required fields, allow optional overrides
4. **Relationship Handling:** Support parent-child record creation
5. **No DML in Factory:** Return objects, let tests decide when to insert
6. **Bulk Support:** Methods should support single and bulk record creation

---

## Test Data Factory Class Structure

```apex
@isTest
public class TestDataFactory {
    
    // ============================================
    // ACCOUNT METHODS
    // ============================================
    
    /**
     * Create a single Account with default values
     * @param name The account name
     * @return Account (not inserted)
     */
    public static Account createAccount(String name) {
        return new Account(
            Name = name,
            Industry = 'Technology',
            Type = 'Customer',
            BillingStreet = '123 Test St',
            BillingCity = 'San Francisco',
            BillingState = 'CA',
            BillingPostalCode = '94105',
            BillingCountry = 'USA',
            Phone = '555-0100',
            Website = 'www.example.com'
        );
    }
    
    /**
     * Create multiple Accounts with default values
     * @param count Number of accounts to create
     * @return List<Account> (not inserted)
     */
    public static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(createAccount('Test Account ' + i));
        }
        return accounts;
    }
    
    /**
     * Create an Account with custom field values
     * @param name The account name
     * @param fieldValues Map of field API names to values
     * @return Account (not inserted)
     */
    public static Account createAccountWithFields(String name, Map<String, Object> fieldValues) {
        Account acc = createAccount(name);
        for (String fieldName : fieldValues.keySet()) {
            acc.put(fieldName, fieldValues.get(fieldName));
        }
        return acc;
    }
    
    // ============================================
    // CONTACT METHODS
    // ============================================
    
    public static Contact createContact(String firstName, String lastName, Id accountId) {
        return new Contact(
            FirstName = firstName,
            LastName = lastName,
            AccountId = accountId,
            Email = firstName.toLowerCase() + '.' + lastName.toLowerCase() + '@example.com',
            Phone = '555-0200',
            Title = 'Test Title',
            Department = 'Sales'
        );
    }
    
    public static List<Contact> createContacts(Integer count, Id accountId) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < count; i++) {
            contacts.add(createContact('FirstName' + i, 'LastName' + i, accountId));
        }
        return contacts;
    }
    
    // ============================================
    // OPPORTUNITY METHODS
    // ============================================
    
    public static Opportunity createOpportunity(String name, Id accountId, Date closeDate) {
        return new Opportunity(
            Name = name,
            AccountId = accountId,
            StageName = 'Prospecting',
            CloseDate = closeDate,
            Amount = 100000,
            Probability = 10,
            Type = 'New Business',
            LeadSource = 'Web'
        );
    }
    
    public static List<Opportunity> createOpportunities(Integer count, Id accountId) {
        List<Opportunity> opps = new List<Opportunity>();
        Date closeDate = Date.today().addDays(30);
        for (Integer i = 0; i < count; i++) {
            opps.add(createOpportunity('Test Opp ' + i, accountId, closeDate));
        }
        return opps;
    }
    
    // ============================================
    // USER METHODS
    // ============================================
    
    /**
     * Create a test user with specified profile
     * @param profileName The profile name
     * @return User (inserted)
     */
    public static User createUser(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        
        String uniqueId = String.valueOf(DateTime.now().getTime());
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + uniqueId + '@example.com.test',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert u;
        return u;
    }
    
    public static User createStandardUser() {
        return createUser('Standard User');
    }
    
    public static User createSystemAdmin() {
        return createUser('System Administrator');
    }
    
    // ============================================
    // CUSTOM OBJECT METHODS
    // ============================================
    
    // Add factory methods for custom objects here
    // Follow the same pattern as standard objects
    
    // Example:
    // public static CustomObject__c createCustomObject(String name) {
    //     return new CustomObject__c(
    //         Name = name,
    //         // Add required fields
    //     );
    // }
    
    // ============================================
    // RELATIONSHIP HELPERS
    // ============================================
    
    /**
     * Create a complete Account hierarchy with related records
     * @param includeContacts Number of contacts to create
     * @param includeOpportunities Number of opportunities to create
     * @return Account with related records (all inserted)
     */
    public static Account createAccountHierarchy(Integer includeContacts, Integer includeOpportunities) {
        Account acc = createAccount('Hierarchy Test Account');
        insert acc;
        
        if (includeContacts > 0) {
            List<Contact> contacts = createContacts(includeContacts, acc.Id);
            insert contacts;
        }
        
        if (includeOpportunities > 0) {
            List<Opportunity> opps = createOpportunities(includeOpportunities, acc.Id);
            insert opps;
        }
        
        return acc;
    }
    
    // ============================================
    // BULK DATA HELPERS
    // ============================================
    
    /**
     * Create large datasets for governor limit testing
     * Supports up to 200 records per transaction
     */
    public static List<Account> createBulkAccounts(Integer count) {
        if (count > 200) {
            throw new IllegalArgumentException('Cannot create more than 200 records in test context');
        }
        return createAccounts(count);
    }
}
```

---

## Usage Examples

### Example 1: Simple Test with Single Record
```apex
@isTest
static void testAccountCreation() {
    // Given
    Account testAccount = TestDataFactory.createAccount('Test Account');
    
    // When
    Test.startTest();
    insert testAccount;
    Test.stopTest();
    
    // Then
    Account inserted = [SELECT Id, Name FROM Account WHERE Id = :testAccount.Id];
    System.assertEquals('Test Account', inserted.Name);
}
```

### Example 2: Bulk Testing (200 records)
```apex
@isTest
static void testBulkProcessing() {
    // Given
    List<Account> accounts = TestDataFactory.createAccounts(200);
    insert accounts;
    
    // When
    Test.startTest();
    MyBulkProcessor.processAccounts(accounts);
    Test.stopTest();
    
    // Then
    List<Account> processed = [SELECT Id, Status__c FROM Account WHERE Id IN :accounts];
    System.assertEquals(200, processed.size());
}
```

### Example 3: Custom Field Values
```apex
@isTest
static void testCustomFields() {
    // Given
    Map<String, Object> customFields = new Map<String, Object>{
        'AnnualRevenue' => 5000000,
        'Rating' => 'Hot',
        'CustomField__c' => 'Custom Value'
    };
    Account acc = TestDataFactory.createAccountWithFields('Custom Account', customFields);
    insert acc;
    
    // When/Then
    Account retrieved = [SELECT Id, AnnualRevenue, Rating FROM Account WHERE Id = :acc.Id];
    System.assertEquals(5000000, retrieved.AnnualRevenue);
}
```

### Example 4: Relationship Testing
```apex
@TestSetup
static void setupCompleteDataModel() {
    // Create account with 10 contacts and 5 opportunities
    Account acc = TestDataFactory.createAccountHierarchy(10, 5);
    
    // Data is now available for all test methods in this class
}

@isTest
static void testWithSetupData() {
    // Query the data created in @TestSetup
    List<Account> accounts = [SELECT Id, (SELECT Id FROM Contacts), (SELECT Id FROM Opportunities) FROM Account];
    System.assertEquals(1, accounts.size());
    System.assertEquals(10, accounts[0].Contacts.size());
    System.assertEquals(5, accounts[0].Opportunities.size());
}
```

### Example 5: User Context Testing
```apex
@isTest
static void testWithDifferentUsers() {
    User adminUser = TestDataFactory.createSystemAdmin();
    User standardUser = TestDataFactory.createStandardUser();
    
    Account testAccount;
    System.runAs(adminUser) {
        testAccount = TestDataFactory.createAccount('Admin Account');
        insert testAccount;
    }
    
    System.runAs(standardUser) {
        // Test that standard user cannot access admin's private account
        List<Account> visibleAccounts = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(0, visibleAccounts.size());
    }
}
```

---

## Test Data Factory Maintenance

### Adding New Object Support
When creating factory methods for new objects:

1. Follow the naming convention: `create{ObjectName}()`
2. Include all required fields with sensible defaults
3. Create both single and bulk creation methods
4. Add a method for custom field values if needed
5. Document parameters with ApexDoc comments

### Version Control
- **Review Frequency:** Quarterly or when schema changes
- **Owner:** Development Team Lead
- **Documentation:** Update this spec when factory methods change

---

## Mock Data Generation for Integration Testing

### HTTP Callout Mocks
```apex
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success","data":{}}');
        res.setStatusCode(200);
        return res;
    }
}
```

### Platform Event Mocks
```apex
@isTest
static void testPlatformEventPublish() {
    Test.startTest();
    EventBus.publish(new CustomEvent__e(Message__c = 'Test'));
    Test.stopTest();
    
    // Platform events are not deliverable in test context
    // Verify the publishing logic, not the subscription
}
```

---
*This document follows The Colt Protocol - Stage 5: Defining Testable Criteria*

````