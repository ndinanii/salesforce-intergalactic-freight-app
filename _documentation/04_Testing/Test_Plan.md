````markdown
# Test Plan

## Purpose
This document defines the comprehensive testing strategy for the project, ensuring quality, security, and performance standards are met.

---

## Testing Philosophy: Test-Driven Development (TDD)

We embrace TDD as our core methodology:
1. **Write Tests First:** Define expected behavior before implementation
2. **Minimum 85% Coverage:** Exceed Salesforce's 75% requirement
3. **Meaningful Assertions:** Tests verify data integrity, not just coverage
4. **User Context Testing:** Validate security model with `System.runAs()`

---

## Test Levels

### 1. Unit Testing
**Purpose:** Test individual methods and classes in isolation.

| Test Type | Coverage Target | Responsibility |
|-----------|----------------|----------------|
| Apex Unit Tests | 85%+ per class | Developers |
| LWC Jest Tests | 85%+ per component | Developers |
| Flow Tests | All paths covered | Admins/Developers |

**Apex Unit Test Standards:**
```apex
@isTest
private class AccountServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test data once for all test methods
        Account testAccount = TestDataFactory.createAccount('Test Account');
        insert testAccount;
    }
    
    @isTest
    static void testPositiveScenario() {
        // Given: Setup preconditions
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // When: Execute the method under test
        Test.startTest();
        Boolean result = AccountService.performOperation(acc.Id);
        Test.stopTest();
        
        // Then: Assert expected outcomes
        System.assertEquals(true, result, 'Operation should succeed');
        
        // Verify data integrity
        Account updatedAcc = [SELECT Status__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Active', updatedAcc.Status__c, 'Status should be Active');
    }
    
    @isTest
    static void testNegativeScenario() {
        // Test error handling and edge cases
        Test.startTest();
        try {
            AccountService.performOperation(null);
            System.assert(false, 'Should throw exception for null input');
        } catch (IllegalArgumentException e) {
            System.assert(true, 'Expected exception thrown');
        }
        Test.stopTest();
    }
}
```

**Governor Limits Testing:**
```apex
@isTest
static void testBulkOperation() {
    // Test with 200 records to ensure bulkification
    List<Account> accounts = TestDataFactory.createAccounts(200);
    insert accounts;
    
    Test.startTest();
    AccountService.bulkUpdate(accounts);
    Test.stopTest();
    
    // Verify all records processed successfully
    List<Account> updated = [SELECT Id, Status__c FROM Account WHERE Id IN :accounts];
    System.assertEquals(200, updated.size(), 'All records should be processed');
}
```

### 2. Integration Testing
**Purpose:** Test interactions between components, APIs, and external systems.

| Integration Type | Testing Approach | Tools |
|------------------|------------------|-------|
| API Callouts | Mock HTTP responses with `HttpCalloutMock` | Apex Test Framework |
| Platform Events | Test event publishing and subscription | Apex Test Framework |
| External Systems | Use mock services or test environments | Postman, Workbench |

**API Callout Testing:**
```apex
@isTest
static void testExternalApiCallout() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    
    Test.startTest();
    HttpResponse response = ExternalApiService.callExternalSystem();
    Test.stopTest();
    
    System.assertEquals(200, response.getStatusCode(), 'Should return success');
    System.assertNotEquals(null, response.getBody(), 'Response should contain data');
}
```

### 3. Security Testing
**Purpose:** Verify row-level security, field-level security, and sharing rules.

```apex
@isTest
static void testRecordAccessWithRestrictedUser() {
    User standardUser = TestDataFactory.createStandardUser();
    User adminUser = TestDataFactory.createAdminUser();
    
    Account privateAccount;
    System.runAs(adminUser) {
        privateAccount = TestDataFactory.createAccount('Private Account');
        insert privateAccount;
    }
    
    System.runAs(standardUser) {
        Test.startTest();
        List<Account> visibleAccounts = [SELECT Id FROM Account WHERE Id = :privateAccount.Id];
        Test.stopTest();
        
        // Standard user should NOT see admin's private account
        System.assertEquals(0, visibleAccounts.size(), 'User should not access private records');
    }
}
```

### 4. User Acceptance Testing (UAT)
**Purpose:** Validate that the solution meets business requirements.

| Activity | Participants | Deliverable |
|----------|--------------|-------------|
| Test Script Creation | BA, QA Team | UAT Scripts (see 04_Testing/UAT_Scripts/) |
| Test Execution | End Users, Product Owner | Test Results Document |
| Defect Logging | QA Team | Defect Tracker Entries |
| Sign-off | Product Owner, Stakeholders | UAT Sign-off Form |

### 5. Performance Testing
**Purpose:** Ensure the solution performs under expected load.

| Scenario | Tool | Success Criteria |
|----------|------|------------------|
| Batch Job Processing | Apex Test (Test.startTest/stopTest) | Process 10,000 records < 5 minutes |
| Lightning Page Load | Browser Dev Tools | Load time < 3 seconds |
| API Response Time | Postman/JMeter | Response < 2 seconds |

---

## Test Data Strategy

### Test Data Factory
Centralize test data creation in a utility class:

```apex
@isTest
public class TestDataFactory {
    
    public static Account createAccount(String name) {
        return new Account(
            Name = name,
            Industry = 'Technology',
            BillingCountry = 'USA'
        );
    }
    
    public static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < count; i++) {
            accounts.add(createAccount('Test Account ' + i));
        }
        return accounts;
    }
    
    public static User createStandardUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert u;
        return u;
    }
}
```

### @TestSetup Method
Use `@TestSetup` to create data once for all test methods in a class:

```apex
@TestSetup
static void setupTestData() {
    List<Account> accounts = TestDataFactory.createAccounts(50);
    insert accounts;
    
    List<Contact> contacts = new List<Contact>();
    for (Account acc : accounts) {
        contacts.add(new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id
        ));
    }
    insert contacts;
}
```

---

## Test Execution

### Manual Testing Checklist
- [ ] Create test org/sandbox from production
- [ ] Deploy all metadata components
- [ ] Execute all Apex test classes
- [ ] Run UAT scripts with end users
- [ ] Verify sharing rules with different user profiles
- [ ] Test on multiple browsers (Chrome, Firefox, Safari, Edge)
- [ ] Test on mobile devices (Salesforce Mobile App)
- [ ] Performance testing under load

### Automated Testing
- **CI/CD Pipeline:** Automate test execution on every commit
- **Scheduled Test Runs:** Nightly regression tests
- **Code Coverage Reports:** Generate coverage reports in CI/CD

---

## Test Metrics

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Apex Code Coverage | 85% | % | |
| LWC Test Coverage | 85% | % | |
| Defect Density | < 5 per 1000 LOC | | |
| UAT Pass Rate | > 95% | % | |
| Performance (Page Load) | < 3 seconds | seconds | |

---

## Defect Management

### Defect Severity Levels

| Severity | Description | Example | Response Time |
|----------|-------------|---------|---------------|
| Critical | System unusable, data loss | Production data corruption | Immediate |
| High | Major functionality broken | Unable to create records | 24 hours |
| Medium | Functionality impaired | Validation rule incorrect | 3 days |
| Low | Minor issue, workaround available | UI alignment issue | Next sprint |

### Defect Tracking
- **Tool:** Jira / Azure DevOps / GitHub Issues
- **Required Fields:** Severity, Steps to Reproduce, Expected vs. Actual, Environment
- **Workflow:** New → In Progress → Code Review → Testing → Closed

---

## Test Environment Strategy

| Environment | Purpose | Refresh Frequency | Access |
|-------------|---------|-------------------|--------|
| Developer Sandbox | Individual development | Weekly | Developers |
| QA Sandbox | Integration testing | Bi-weekly | QA Team, Developers |
| UAT Sandbox | User acceptance testing | Monthly | End Users, BA |
| Staging | Pre-production validation | On-demand | Limited |
| Production | Live system | N/A | End Users |

---

## Test Documentation

### Required Documents
- [ ] Test Plan (this document)
- [ ] Test Cases/Scripts (in UAT_Scripts/)
- [ ] Test Data Requirements (in Data_Factory_Spec.md)
- [ ] Test Execution Reports
- [ ] Defect Reports
- [ ] Test Sign-off Document

---
*This document follows The Colt Protocol - Stage 5: Defining Testable Criteria*

````