````markdown
# Security Matrix

## Purpose
This document defines the security model for the entire application, ensuring proper access control at every layer.

## Salesforce Security Layers

### 1. Organization-Wide Defaults (OWD)
Define baseline record access for each object.

| Object | OWD Setting | Rationale |
|--------|-------------|-----------|
| Account | Private | Sales users should only see their accounts |
| Contact | Controlled by Parent | Inherit from Account |
| CustomObject__c | Public Read Only | All users can view, only owners can edit |
| OpportunityLineItem | Controlled by Parent | Inherit from Opportunity |

### 2. Role Hierarchy
Document the role hierarchy and how it affects record access.

```
CEO
├── VP Sales
│   ├── Sales Manager West
│   │   └── Sales Rep West
│   └── Sales Manager East
│       └── Sales Rep East
└── VP Operations
    └── Operations Manager
        └── Operations Specialist
```

### 3. Profiles
Define what each profile can do (object permissions, field permissions, system permissions).

| Profile | License Type | Purpose | Key Permissions |
|---------|--------------|---------|-----------------|
| System Administrator | Salesforce | Full system access | All objects, Modify All Data |
| Sales User | Salesforce | Standard sales functionality | Read/Create/Edit opportunities |
| Custom Profile | Salesforce | Specific use case | Limited object access |

### 4. Permission Sets
Group additional permissions that can be assigned to users beyond their profile.

| Permission Set | Purpose | Permissions Granted | Assigned To |
|----------------|---------|---------------------|-------------|
| Advanced_Reporting | Access to sensitive reports | View All Data, Manage Reports | Report Admins |
| API_Integration_User | External system integration | API Enabled, View All Data | Integration Users |

### 5. Permission Set Groups
Collections of permission sets for easier management.

| Permission Set Group | Included Permission Sets | Purpose |
|----------------------|-------------------------|---------|
| Sales_Leadership | Advanced_Reporting, Forecast_Override | Sales managers and above |

### 6. Sharing Rules
Extend record access beyond OWD settings.

| Object | Sharing Rule Name | Type | Criteria | Shared With | Access Level |
|--------|-------------------|------|----------|-------------|--------------|
| Account | Share_Partner_Accounts | Criteria-Based | Type = 'Partner' | Partner Users | Read/Write |
| CustomObject__c | Share_With_Support | Ownership-Based | Owned by Sales Team | Support Team | Read Only |

### 7. Field-Level Security (FLS)
Control access to specific fields.

| Object | Field | Read Access | Edit Access | Restricted From |
|--------|-------|-------------|-------------|-----------------|
| Account | Revenue__c | Sales, Finance | Finance Only | Support, Marketing |
| Contact | SSN__c | Finance Only | Finance Only | All others |

### 8. Apex Sharing
Document programmatic sharing implemented in Apex.

| Object | Apex Class | Sharing Reason | Logic |
|--------|------------|----------------|-------|
| CustomObject__c | CustomObjectSharingService | Custom_Access__c | Share records with manager's team |

---

## Security Implementation in Code

### Apex Security Best Practices

#### 1. Sharing Keywords
```apex
// Enforce sharing rules (default for most classes)
public with sharing class SecureController {
    // This class respects user's record access
}

// Bypass sharing rules (use carefully)
public without sharing class AdminController {
    // This class ignores sharing rules
}

// Inherit sharing from caller
public inherited sharing class FlexibleController {
    // Respects sharing if called from 'with sharing' context
}
```

#### 2. SOQL Injection Prevention
```apex
// BAD - Vulnerable to SOQL injection
String query = 'SELECT Id FROM Account WHERE Name = \'' + userInput + '\'';
List<Account> accounts = Database.query(query);

// GOOD - Use binding variables
String accountName = userInput;
List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
```

#### 3. CRUD/FLS Enforcement
```apex
// Check object permissions before DML
if (Schema.sObjectType.Account.isCreateable()) {
    insert new Account(Name = 'New Account');
}

// Check field permissions before query
if (Schema.sObjectType.Account.fields.Revenue__c.isAccessible()) {
    List<Account> accounts = [SELECT Id, Revenue__c FROM Account];
}

// Use Security.stripInaccessible() for queries
SObjectAccessDecision decision = Security.stripInaccessible(
    AccessType.READABLE,
    [SELECT Id, Name, Revenue__c FROM Account]
);
List<Account> accounts = decision.getRecords();
```

#### 4. User Context Testing
```apex
@isTest
public class SecureControllerTest {
    @isTest
    static void testWithRestrictedUser() {
        User restrictedUser = TestDataFactory.createStandardUser();
        
        System.runAs(restrictedUser) {
            // Test that user can only access their records
            Test.startTest();
            List<Account> accounts = SecureController.getAccounts();
            Test.stopTest();
            
            // Assert proper record access
            System.assertEquals(5, accounts.size(), 'User should see only their accounts');
        }
    }
}
```

---

## Security Audit Checklist

- [ ] OWD settings reviewed and documented
- [ ] Role hierarchy aligns with business structure
- [ ] Profiles have minimum required permissions (Principle of Least Privilege)
- [ ] Permission Sets used for additional access instead of creating multiple profiles
- [ ] Sharing Rules tested with different user contexts
- [ ] Field-Level Security configured for sensitive fields
- [ ] All Apex classes use appropriate sharing keywords (`with sharing`, `without sharing`, `inherited sharing`)
- [ ] SOQL injection prevention verified (binding variables used)
- [ ] CRUD/FLS checks implemented in Apex code
- [ ] Test classes validate security using `System.runAs()`
- [ ] External integrations use dedicated integration users with minimal permissions
- [ ] Named Credentials used for external callouts (no hardcoded credentials)

---

## Security Review Schedule

| Review Type | Frequency | Owner | Last Reviewed |
|-------------|-----------|-------|---------------|
| Permission Audit | Quarterly | Security Team | |
| Profile Review | Bi-annually | System Admin | |
| Apex Security Scan | Per Release | Dev Team | |
| Penetration Testing | Annually | External Auditor | |

---
*This document follows The Colt Protocol - Stage 4: Data Modeling & ERD (Security First)*

````