# Intergalactic Freight & Trade Corp - Complete Implementation Plan

## Executive Summary

This document outlines the complete implementation strategy for the IFTC Salesforce transformation. The plan follows a **foundation-first, complexity-last** approach, ensuring each component builds upon a stable base.

**Core Principle:** "You cannot automate chaos. First, we structure the data. Then, we control access. Then, we automate. Then, we optimize."

---

## Phase 0: Project Setup & Foundation (Week 1)

### Objective
Establish the technical infrastructure and project governance framework before any development begins.

### Steps

#### 0.1 Environment Setup ✓ (COMPLETED)
- [x] Salesforce org authorized: `IntergalacticFreight`
- [x] SFDX project initialized with `sfdx-project.json`
- [x] Git repository connected: `github.com/ndinanii/salesforce-intergalactic-freight-app`
- [x] Backend API structure created (Node.js + Express)
- [x] Frontend structure created (React + Vite)
- [x] Org cleaned and ready for fresh start

#### 0.2 Documentation Framework Setup (NOW)
**Deliverable:** Create project documentation structure

**Action Items:**
1. Create `/docs` folder structure:
   ```
   docs/
   ├── architecture/
   │   ├── ERD.md (Entity Relationship Diagram)
   │   ├── data-dictionary.md
   │   └── security-model.md
   ├── automation/
   │   ├── flow-diagrams.md
   │   └── apex-logic.md
   ├── deployment/
   │   ├── deployment-plan.md
   │   └── test-strategy.md
   └── user-guides/
       ├── agent-guide.md
       └── manager-guide.md
   ```

2. Create project tracking document: `PROJECT_TRACKER.md`
   - Use checkbox format for each requirement
   - Map to assessment sections
   - Track completion status

---

## Phase 1: Data Architecture (Week 1-2)

### Objective
Design and implement the foundational data model that represents IFTC's business operations.

**Strategic Note:** The data model IS your business logic. Get this right, and everything else becomes easier.

### Section 1.1: Entity Relationship Design

**Deliverable:** Complete ERD diagram with all objects, fields, and relationships

**Action Items:**

1. **Design Core Objects Schema**
   
   **Object: Shipment__c (The "Order")**
   - Purpose: Central record tracking a cargo delivery from origin to destination
   - Fields to design:
     - Name (Auto-number: SHIP-{0000})
     - Origin_Planet__c (Text)
     - Destination_Planet__c (Text)
     - Status__c (Picklist: New, In Transit, In Customs, Delayed, Delivered, Cancelled)
     - Shipping_Method__c (Picklist: Hyperspace Express, Standard Warp, Cargo Freighter)
     - Departure_Date__c (Date)
     - ETA__c (Date/Time)
     - Actual_Delivery_Date__c (Date)
     - Distance_Light_Years__c (Number - for fuel calculation)
     - Total_Weight__c (Rollup Summary from Cargo)
     - Discount__c (Percent - triggers approval if > 20%)
     - Approval_Status__c (Picklist: Pending, Approved, Rejected)
   - Relationships:
     - Account__c (Lookup to Account) - the customer
     - Contact__c (Lookup to Contact) - customer contact person
     - Opportunity__c (Lookup to Opportunity) - if from a sales deal
     - Assigned_Agent__c (Lookup to User) - the agent handling it
   
   **Object: Cargo__c (The "Line Items")**
   - Purpose: Individual items being shipped in a Shipment
   - Fields:
     - Name (Auto-number: CARGO-{0000})
     - Shipment__c (Master-Detail to Shipment__c) **CRITICAL: Master-Detail for rollup**
     - Category__c (Picklist: Electronics, Perishables, Hazardous Materials, Raw Materials, Manufactured Goods)
     - Description__c (Long Text Area)
     - Weight__c (Number - in metric tons)
     - Value__c (Currency)
     - Special_Handling__c (Checkbox)
   
   **Object: Customs_Document__c (The "Junction")**
   - Purpose: Tracks customs clearance status for specific cargo in specific shipments
   - This is a **junction object** connecting Shipment and Cargo
   - Fields:
     - Name (Auto-number: CD-{0000})
     - Shipment__c (Master-Detail to Shipment__c)
     - Cargo__c (Master-Detail to Cargo__c)
     - Document_Type__c (Picklist: Import License, Export Declaration, Hazmat Certificate, Inspection Report)
     - Status__c (Picklist: Pending, Approved, Rejected, Expired)
     - Submitted_Date__c (Date)
     - Approval_Date__c (Date)
     - Customs_Officer__c (Text - external officer name)
     - Notes__c (Long Text Area)
   
   **Object: Agent__c (Optional Custom - or use User)**
   - **Design Decision:** You could use the standard User object for agents
   - If creating custom Agent__c:
     - Name (Text)
     - User__c (Lookup to User)
     - Region__c (Picklist: Alpha Quadrant, Beta Quadrant, Gamma Quadrant, Delta Quadrant)
     - Active__c (Checkbox)
     - Max_Concurrent_Shipments__c (Number)
     - Current_Shipment_Count__c (Rollup Summary)

2. **Create ERD Diagram**
   - Tool: Use Lucidchart, Draw.io, or even PowerPoint
   - Show all objects as boxes
   - Show fields within boxes
   - Show relationships with labeled lines (Lookup vs Master-Detail)
   - Save as image: `docs/architecture/ERD.png`
   - Document in `docs/architecture/ERD.md`

3. **Write Data Dictionary**
   - Create `docs/architecture/data-dictionary.md`
   - For each object:
     - Object API Name
     - Purpose
     - Key relationships
   - For each field:
     - API Name
     - Type
     - Purpose
     - Business rule
   - Example format:
     ```markdown
     ## Shipment__c
     
     **Purpose:** Central record for tracking cargo delivery
     
     ### Fields
     
     | API Name | Type | Purpose | Rules |
     |----------|------|---------|-------|
     | Status__c | Picklist | Current shipment state | Required; Default: New |
     | ETA__c | DateTime | Expected arrival | Must be after Departure_Date__c |
     ```

### Section 1.2: Object Implementation

**Deliverable:** All custom objects created in Salesforce org

**Action Items:**

1. **Create Objects in Order:**
   ```bash
   # Use SFDX or UI - I recommend UI first for learning, then capture with SFDX
   
   # Order matters due to dependencies:
   # 1. Agent__c (if using custom object) - no dependencies
   # 2. Shipment__c - depends on standard objects only
   # 3. Cargo__c - depends on Shipment__c
   # 4. Customs_Document__c - depends on both Shipment__c and Cargo__c
   ```

2. **Configure Relationship Behaviors:**
   - **Master-Detail considerations:**
     - Cargo__c → Shipment__c: Cascade delete (if Shipment deleted, Cargo deleted)
     - Customs_Document__c → Shipment__c: Cascade delete
     - Customs_Document__c → Cargo__c: Cascade delete
   - **Lookup considerations:**
     - Shipment__c → Account__c: Don't delete (preserve history)
     - Shipment__c → User (Agent): Don't delete

3. **Create Rollup Summary Fields:**
   - On Shipment__c:
     - Total_Weight__c = SUM(Cargo__c.Weight__c)
     - Cargo_Count__c = COUNT(Cargo__c)
   - On Agent__c (if custom):
     - Current_Shipment_Count__c = COUNT(Shipment__c WHERE Status != 'Delivered')

4. **Pull Metadata to Local:**
   ```bash
   sf project retrieve start --metadata CustomObject
   ```

5. **Commit to Git:**
   ```bash
   git add force-app/main/default/objects/
   git commit -m "feat: Implement core data model - Shipment, Cargo, Customs Document, Agent objects"
   git push
   ```

### Section 1.3: Data Quality Controls

**Deliverable:** Duplicate rules and data integrity measures

**Action Items:**

1. **Create Duplicate Rules (Assessment Requirement):**
   - **Account Duplicate Rule:**
     - Matching Rule: Account Name + Billing State/Province
     - Action: Alert (don't block - allow override)
   - **Contact Duplicate Rule:**
     - Matching Rule: First Name + Last Name + Email
     - Action: Alert

2. **Document:**
   - Create `docs/architecture/data-quality-rules.md`
   - Explain why these rules (business justification)

---

## Phase 2: Security Architecture (Week 2)

### Objective
Implement a secure, role-based access control model before building automation.

**Strategic Note:** "Security by design, not as an afterthought."

### Section 2.1: User & Role Design

**Deliverable:** Security model documentation and implementation

**Action Items:**

1. **Design Role Hierarchy:**
   ```
   CEO
   ├── Operations Manager
   │   ├── Freight Agent
   │   └── Freight Agent
   └── Customer Service Manager
       └── Customer Service Rep
   ```
   - Document in `docs/architecture/security-model.md`

2. **Create Profiles (if needed) or Clone Standard Profiles:**
   - **Freight Agent Profile:**
     - Clone "Standard User"
     - Object permissions: Shipment (CRUD), Cargo (CRUD), Customs Doc (Read/Edit)
   - **Operations Manager Profile:**
     - Clone "Standard User"
     - Object permissions: All objects (Read all, Edit all)
     - App permissions: Can view reports/dashboards

3. **Create Permission Sets (Recommended Approach):**
   - **Freight_Agent_Base:**
     - Shipment__c: Create, Read, Edit
     - Cargo__c: Create, Read, Edit
     - Customs_Document__c: Read, Edit
   - **Operations_Manager_Permissions:**
     - Shipment__c: View All, Modify All
     - Reports & Dashboards: Manage
     - Approval: Approve/Reject
   - **Developer_Access:**
     - API Enabled
     - View Setup and Configuration

4. **Assign Test Users:**
   - Create 2 test users:
     - freight.agent@iftc.demo (Freight Agent profile + permission set)
     - ops.manager@iftc.demo (Manager profile + permission set)

### Section 2.2: Sharing Rules

**Action Items:**

1. **Configure Org-Wide Defaults:**
   - Shipment__c: Private
   - Cargo__c: Controlled by Parent
   - Customs_Document__c: Controlled by Parent
   - Account: Public Read Only
   - Contact: Public Read Only

2. **Create Sharing Rules:**
   - **Rule: Agents Share with Manager**
     - Based on: Owner Role = Freight Agent
     - Share with: Operations Manager Role
     - Access: Read/Write

3. **Document Security Decisions:**
   - In `docs/architecture/security-model.md`
   - Explain OWD choices
   - Explain sharing rule rationale

---

## Phase 3: Business Logic Foundation (Week 3)

### Objective
Implement validation rules and data integrity controls.

### Section 3.1: Validation Rules

**Deliverable:** 2+ validation rules enforcing business logic

**Action Items:**

1. **Shipment__c Validation Rules:**
   
   **Rule 1: ETA Must Be After Departure Date**
   ```
   Rule Name: ETA_Must_Be_After_Departure_Date
   Error Condition Formula:
   AND(
     NOT(ISBLANK(Departure_Date__c)),
     NOT(ISBLANK(ETA__c)),
     ETA__c < Departure_Date__c
   )
   Error Message: "ETA must be after the Departure Date"
   Error Location: ETA__c
   ```

   **Rule 2: Discount Requires Approval Status**
   ```
   Rule Name: Discount_Requires_Approval
   Error Condition Formula:
   AND(
     Discount__c > 0.20,
     ISPICKVAL(Approval_Status__c, "")
   )
   Error Message: "Discounts above 20% require approval. Please submit for approval."
   Error Location: Discount__c
   ```

2. **Cargo__c Validation Rules:**
   
   **Rule 3: Cargo Weight Must Be Positive**
   ```
   Rule Name: Cargo_Weight_Must_Be_Positive
   Error Condition Formula:
   Weight__c <= 0
   Error Message: "Cargo weight must be greater than zero"
   Error Location: Weight__c
   ```

3. **Test Validation Rules:**
   - Try to create invalid records
   - Document test cases in `docs/deployment/test-strategy.md`

4. **Commit:**
   ```bash
   git add force-app/main/default/objects/
   git commit -m "feat: Add validation rules for data integrity"
   git push
   ```

---

## Phase 4: Process Automation - Approval Process (Week 3)

### Objective
Implement approval automation for discount management.

### Section 4.1: Approval Process Design

**Deliverable:** Working approval process for shipment discounts

**Action Items:**

1. **Create Approval Process:**
   - **Object:** Shipment__c
   - **Name:** Discount_Approval_Process
   - **Entry Criteria:** `Discount__c > 0.20 AND ISPICKVAL(Approval_Status__c, "Pending")`
   - **Approver:** Operations Manager (Role: Operations Manager)
   - **Email Template:** Create custom email template

2. **Configure Steps:**
   - **Initial Submission Actions:**
     - Field Update: `Approval_Status__c = "Pending"`
     - Email Alert: Notify approver
   - **Final Approval Actions:**
     - Field Update: `Approval_Status__c = "Approved"`
     - Email Alert: Notify submitter
   - **Final Rejection Actions:**
     - Field Update: `Approval_Status__c = "Rejected"`
     - Field Update: `Discount__c = 0`
     - Email Alert: Notify submitter
   - **Recall Actions:**
     - Field Update: `Approval_Status__c = ""`

3. **Create Email Templates:**
   - Template 1: Discount Approval Request
   - Template 2: Discount Approved
   - Template 3: Discount Rejected

4. **Test:**
   - Create Shipment with 25% discount as Agent
   - Submit for approval
   - Log in as Manager
   - Approve/Reject
   - Verify field updates

5. **Document:**
   - In `docs/automation/approval-process.md`
   - Include flowchart if helpful
   - Explain business justification

---

## Phase 5: Process Automation - Record-Triggered Flow (Week 4)

### Objective
Implement automated shipment assignment and delay notifications.

### Section 5.1: Flow Design & Documentation

**Deliverable:** Working Record-Triggered Flow

**Before You Build - Document Your Logic:**

Create `docs/automation/flow-design.md`:

```markdown
# Record-Triggered Flow: Shipment Assignment & Delay Notification

## Business Requirements
1. Auto-assign new shipments to available agents
2. Send notifications when shipments are delayed

## Flow: Auto_Assign_Shipment

**Trigger:** After Create on Shipment__c
**Entry Criteria:** Assigned_Agent__c IS NULL

**Logic:**
1. Get Records: Query Agent__c WHERE Active__c = TRUE AND Current_Shipment_Count__c < Max_Concurrent_Shipments__c
2. Decision: Are there available agents?
   - YES:
     - Assignment: Use Round-robin logic (Formula: MOD(Shipment__c.ShipmentNumber, AgentCount))
     - Update Record: Set Assigned_Agent__c
     - Send Email: Notify assigned agent
   - NO:
     - Send Email: Alert Operations Manager (no agents available)

## Flow: Shipment_Delay_Notification

**Trigger:** After Update on Shipment__c
**Entry Criteria:** Status__c = "Delayed" AND ISCHANGED(Status__c)

**Logic:**
1. Get Records: Get related Account and Contact
2. Send Email:
   - To: Contact__c.Email
   - CC: Account Owner
   - Template: Shipment_Delayed_Notification
3. Create Task:
   - Assigned to: Assigned_Agent__c
   - Subject: "Follow up on delayed shipment {Name}"
   - Priority: High
```

### Section 5.2: Flow Implementation

**Action Items:**

1. **Build Flow 1: Auto_Assign_Shipment**
   - Setup → Flows → New Flow → Record-Triggered Flow
   - Follow design doc
   - Test with 3-5 shipments
   - Activate

2. **Build Flow 2: Shipment_Delay_Notification**
   - Setup → Flows → New Flow → Record-Triggered Flow
   - Follow design doc
   - Test by changing Status to "Delayed"
   - Activate

3. **Capture Metadata:**
   ```bash
   sf project retrieve start --metadata Flow
   ```

4. **Commit:**
   ```bash
   git add force-app/main/default/flows/
   git add docs/automation/
   git commit -m "feat: Implement Flows for shipment assignment and delay notification"
   git push
   ```

5. **Document Why Flow (Not Apex or Process Builder):**
   
   Create `docs/automation/flow-justification.md`:
   ```markdown
   # Why Flow Over Other Automation Tools
   
   ## Assessment Requirement
   "Document why you chose Flow instead of other automation tools."
   
   ## Decision Matrix
   
   | Tool | Pros | Cons | Use Case |
   |------|------|------|----------|
   | Workflow Rules | Simple, legacy | DEPRECATED, limited | None - avoid |
   | Process Builder | Visual, familiar | DEPRECATED | None - migrate to Flow |
   | Flow | Modern, powerful, supported | Learning curve | ✅ All new automation |
   | Apex Trigger | Performance, complex logic | Code, maintenance | Complex calculations only |
   
   ## Our Decision: Flow
   
   **For Shipment Assignment:**
   - Declarative (no code) = maintainable by admins
   - Native "Get Records" handles agent queries efficiently
   - Decision logic is visual and auditable
   - Easy to modify rules (e.g., change assignment algorithm)
   
   **For Delay Notification:**
   - Simple trigger logic
   - No complex calculations needed
   - Email templates are reusable
   - Admin can edit without developer
   
   **When We'll Use Apex Instead:**
   - Complex fuel cost calculations (needs precision math)
   - Before delete trigger (Flow can't handle before context)
   - Bulk processing (async Apex for performance)
   - Custom API integrations
   
   **Strategic Principle:** "Use the right tool for the job. Flow for business logic, Apex for technical logic."
   ```

---

## Phase 6: Apex Development - Business Logic (Week 4-5)

### Objective
Implement complex calculations and business rules that require code.

### Section 6.1: Apex Class 1 - Fuel Cost Calculator

**Deliverable:** Apex class with formula-based calculations

**Action Items:**

1. **Design the Logic (Document First):**
   
   Create `docs/automation/apex-logic.md`:
   ```markdown
   # Apex Business Logic Design
   
   ## Class: InterplanetaryFuelCalculator
   
   **Purpose:** Calculate fuel costs for interplanetary shipments
   
   **Formula:**
   ```
   Fuel Cost = (Base Rate × Distance) × (1 + Weight Factor) × Shipping Method Multiplier
   
   Where:
   - Base Rate = 100 credits per light-year
   - Weight Factor = (Total Weight / 1000) ^ 0.5
   - Shipping Method Multiplier:
     - Hyperspace Express: 2.5x
     - Standard Warp: 1.5x
     - Cargo Freighter: 1.0x
   ```
   
   **Method Signature:**
   ```apex
   public static Decimal calculateFuelCost(Decimal distance, Decimal weight, String shippingMethod)
   ```
   ```

2. **Implement the Class:**
   
   Create `force-app/main/default/classes/InterplanetaryFuelCalculator.cls`:
   ```apex
   /**
    * @description Calculates fuel costs for interplanetary shipments
    * @author Your Name
    * @date 2025-11-18
    */
   public with sharing class InterplanetaryFuelCalculator {
       
       // Constants
       private static final Decimal BASE_RATE = 100.0; // Credits per light-year
       private static final Map<String, Decimal> SHIPPING_MULTIPLIERS = new Map<String, Decimal>{
           'Hyperspace Express' => 2.5,
           'Standard Warp' => 1.5,
           'Cargo Freighter' => 1.0
       };
       
       /**
        * @description Calculate fuel cost based on distance, weight, and shipping method
        * @param distance Distance in light-years
        * @param weight Total cargo weight in metric tons
        * @param shippingMethod The shipping method picklist value
        * @return Fuel cost in credits
        */
       public static Decimal calculateFuelCost(Decimal distance, Decimal weight, String shippingMethod) {
           // Input validation
           if (distance == null || distance <= 0) {
               throw new IllegalArgumentException('Distance must be positive');
           }
           if (weight == null || weight <= 0) {
               throw new IllegalArgumentException('Weight must be positive');
           }
           if (String.isBlank(shippingMethod) || !SHIPPING_MULTIPLIERS.containsKey(shippingMethod)) {
               throw new IllegalArgumentException('Invalid shipping method: ' + shippingMethod);
           }
           
           // Calculate weight factor (square root scaling)
           Decimal weightFactor = Math.sqrt(weight / 1000.0);
           
           // Get shipping multiplier
           Decimal shippingMultiplier = SHIPPING_MULTIPLIERS.get(shippingMethod);
           
           // Calculate total fuel cost
           Decimal fuelCost = BASE_RATE * distance * (1 + weightFactor) * shippingMultiplier;
           
           // Round to 2 decimal places
           return fuelCost.setScale(2);
       }
       
       /**
        * @description Bulk calculate fuel costs for multiple shipments
        * @param shipments List of Shipment__c records
        * @return Map of Shipment Id to calculated fuel cost
        */
       public static Map<Id, Decimal> calculateBulkFuelCosts(List<Shipment__c> shipments) {
           Map<Id, Decimal> results = new Map<Id, Decimal>();
           
           for (Shipment__c shipment : shipments) {
               try {
                   Decimal cost = calculateFuelCost(
                       shipment.Distance_Light_Years__c,
                       shipment.Total_Weight__c,
                       shipment.Shipping_Method__c
                   );
                   results.put(shipment.Id, cost);
               } catch (Exception e) {
                   System.debug('Error calculating fuel for Shipment ' + shipment.Id + ': ' + e.getMessage());
                   // Continue processing other shipments
               }
           }
           
           return results;
       }
   }
   ```

3. **Write Test Class (REQUIRED - 75% Coverage):**
   
   Create `force-app/main/default/classes/InterplanetaryFuelCalculatorTest.cls`:
   ```apex
   @isTest
   private class InterplanetaryFuelCalculatorTest {
       
       @isTest
       static void testCalculateFuelCost_HyperspaceExpress() {
           // Arrange
           Decimal distance = 100.0; // light-years
           Decimal weight = 1000.0; // metric tons
           String method = 'Hyperspace Express';
           
           // Act
           Test.startTest();
           Decimal result = InterplanetaryFuelCalculator.calculateFuelCost(distance, weight, method);
           Test.stopTest();
           
           // Assert
           // Expected: 100 * 100 * (1 + sqrt(1000/1000)) * 2.5 = 10000 * 2 * 2.5 = 50000
           System.assertEquals(50000.00, result, 'Fuel cost calculation incorrect');
       }
       
       @isTest
       static void testCalculateFuelCost_StandardWarp() {
           Decimal result = InterplanetaryFuelCalculator.calculateFuelCost(50.0, 500.0, 'Standard Warp');
           // Expected: 100 * 50 * (1 + sqrt(500/1000)) * 1.5 ≈ 5000 * 1.707 * 1.5 ≈ 12802.50
           System.assert(result > 10000 && result < 15000, 'Fuel cost out of expected range');
       }
       
       @isTest
       static void testCalculateFuelCost_InvalidDistance() {
           try {
               InterplanetaryFuelCalculator.calculateFuelCost(-10, 1000, 'Cargo Freighter');
               System.assert(false, 'Should have thrown exception');
           } catch (IllegalArgumentException e) {
               System.assert(e.getMessage().contains('Distance'), 'Wrong exception message');
           }
       }
       
       @isTest
       static void testCalculateFuelCost_InvalidWeight() {
           try {
               InterplanetaryFuelCalculator.calculateFuelCost(100, 0, 'Cargo Freighter');
               System.assert(false, 'Should have thrown exception');
           } catch (IllegalArgumentException e) {
               System.assert(e.getMessage().contains('Weight'), 'Wrong exception message');
           }
       }
       
       @isTest
       static void testCalculateFuelCost_InvalidMethod() {
           try {
               InterplanetaryFuelCalculator.calculateFuelCost(100, 1000, 'Teleportation');
               System.assert(false, 'Should have thrown exception');
           } catch (IllegalArgumentException e) {
               System.assert(e.getMessage().contains('shipping method'), 'Wrong exception message');
           }
       }
       
       @isTest
       static void testCalculateBulkFuelCosts() {
           // Arrange
           List<Shipment__c> shipments = new List<Shipment__c>();
           for (Integer i = 0; i < 5; i++) {
               shipments.add(new Shipment__c(
                   Distance_Light_Years__c = 100 + (i * 10),
                   Total_Weight__c = 1000,
                   Shipping_Method__c = 'Cargo Freighter'
               ));
           }
           insert shipments;
           
           // Act
           Test.startTest();
           Map<Id, Decimal> results = InterplanetaryFuelCalculator.calculateBulkFuelCosts(shipments);
           Test.stopTest();
           
           // Assert
           System.assertEquals(5, results.size(), 'Should calculate for all shipments');
           for (Id shipmentId : results.keySet()) {
               System.assert(results.get(shipmentId) > 0, 'Fuel cost should be positive');
           }
       }
   }
   ```

4. **Run Tests:**
   ```bash
   sf apex run test --class-names InterplanetaryFuelCalculatorTest --result-format human --code-coverage
   ```

5. **Commit:**
   ```bash
   git add force-app/main/default/classes/
   git commit -m "feat: Add InterplanetaryFuelCalculator with 100% test coverage"
   git push
   ```

### Section 6.2: Apex Class 2 - Customs Validator

**Action Items:**

1. **Document Logic:**
   - Add to `docs/automation/apex-logic.md`
   - Define customs rules (e.g., Hazmat requires certificate, Electronics need import license)

2. **Implement:**
   ```apex
   public with sharing class CustomsClearanceValidator {
       
       public class ValidationResult {
           @AuraEnabled public Boolean isValid { get; set; }
           @AuraEnabled public List<String> errors { get; set; }
           
           public ValidationResult() {
               this.isValid = true;
               this.errors = new List<String>();
           }
       }
       
       public static ValidationResult validateShipment(Id shipmentId) {
           ValidationResult result = new ValidationResult();
           
           // Query shipment with related cargo and customs documents
           Shipment__c shipment = [
               SELECT Id, Destination_Planet__c,
                      (SELECT Id, Category__c FROM Cargos__r),
                      (SELECT Id, Cargo__c, Status__c, Document_Type__c FROM Customs_Documents__r)
               FROM Shipment__c
               WHERE Id = :shipmentId
           ];
           
           // Validation logic here
           // Check each cargo has required customs documents based on category
           
           return result;
       }
   }
   ```

3. **Write Tests** (achieve 75%+ coverage)

4. **Commit**

---

## Phase 7: Apex Triggers (Week 5)

### Objective
Implement event-driven automation that requires code.

### Section 7.1: Trigger 1 - Prevent Deletion

**Action Items:**

1. **Implement:**
   ```apex
   /**
    * @description Prevent deletion of active shipments
    */
   trigger PreventActiveShipmentDeletion on Shipment__c (before delete) {
       for (Shipment__c shipment : Trigger.old) {
           if (shipment.Status__c == 'In Transit' || 
               shipment.Status__c == 'In Customs' || 
               shipment.Status__c == 'Delayed') {
               shipment.addError('Cannot delete active shipments. Please cancel the shipment first.');
           }
       }
   }
   ```

2. **Test Class:**
   ```apex
   @isTest
   private class PreventActiveShipmentDeletionTest {
       @isTest
       static void testPreventDeleteInTransit() {
           // Test deletion is blocked for active shipments
       }
       
       @isTest
       static void testAllowDeleteDelivered() {
           // Test deletion is allowed for delivered shipments
       }
   }
   ```

### Section 7.2: Trigger 2 - Auto-Generate Customs Document

**Action Items:**

1. **Implement:**
   ```apex
   /**
    * @description Auto-generate Customs Document when Shipment is created
    */
   trigger AutoGenerateCustomsDocument on Shipment__c (after insert) {
       List<Customs_Document__c> docsToInsert = new List<Customs_Document__c>();
       
       // Query related cargo for each shipment
       Map<Id, List<Cargo__c>> shipmentCargoMap = new Map<Id, List<Cargo__c>>();
       for (Cargo__c cargo : [
           SELECT Id, Shipment__c, Category__c 
           FROM Cargo__c 
           WHERE Shipment__c IN :Trigger.newMap.keySet()
       ]) {
           if (!shipmentCargoMap.containsKey(cargo.Shipment__c)) {
               shipmentCargoMap.put(cargo.Shipment__c, new List<Cargo__c>());
           }
           shipmentCargoMap.get(cargo.Shipment__c).add(cargo);
       }
       
       // Create customs documents based on cargo categories
       for (Shipment__c shipment : Trigger.new) {
           if (shipmentCargoMap.containsKey(shipment.Id)) {
               for (Cargo__c cargo : shipmentCargoMap.get(shipment.Id)) {
                   Customs_Document__c doc = new Customs_Document__c(
                       Shipment__c = shipment.Id,
                       Cargo__c = cargo.Id,
                       Document_Type__c = getRequiredDocType(cargo.Category__c),
                       Status__c = 'Pending'
                   );
                   docsToInsert.add(doc);
               }
           }
       }
       
       if (!docsToInsert.isEmpty()) {
           insert docsToInsert;
       }
   }
   
   private static String getRequiredDocType(String cargoCategory) {
       // Business logic for document type based on cargo category
       if (cargoCategory == 'Hazardous Materials') {
           return 'Hazmat Certificate';
       } else if (cargoCategory == 'Electronics') {
           return 'Import License';
       }
       return 'Import License';
   }
   ```

2. **Write Test** (75%+ coverage)

3. **Commit All Triggers**

---

## Phase 8: User Interface - Lightning Experience (Week 6)

### Objective
Customize the user experience for different personas.

### Section 8.1: Lightning App Builder

**Action Items:**

1. **Create Lightning App: "IFTC Operations"**
   - Setup → App Manager → New Lightning App
   - App Name: IFTC_Operations
   - Add objects: Shipments, Cargo, Customs Documents, Accounts, Contacts

2. **Create Lightning Pages:**
   
   **Page 1: Freight Agent Home**
   - Template: 3 columns
   - Components:
     - My Assigned Shipments (List View)
     - Recent Cargo (Related List)
     - Quick Actions component
   
   **Page 2: Operations Manager Home**
   - Template: Dashboard-style
   - Components:
     - Key Metrics (Formula fields displayed as cards)
     - All Active Shipments
     - Approval Requests
     - Embedded Dashboard

3. **Assign Apps to Profiles:**
   - Freight Agent → IFTC Operations app by default
   - Operations Manager → IFTC Operations app

4. **Document:**
   - Screenshot each page
   - Save in `docs/user-guides/`

---

## Phase 9: User Interface - Custom Components (Week 6-7)

### Section 9.1: Visualforce Page

**Deliverable:** Shipment summary page (printable)

**Action Items:**

1. **Create Visualforce Page:**
   ```apex
   <apex:page standardController="Shipment__c" extensions="ShipmentSummaryController">
       <apex:sectionHeader title="Shipment Summary" subtitle="{!Shipment__c.Name}"/>
       <apex:pageBlock title="Shipment Details">
           <apex:pageBlockSection columns="2">
               <apex:outputField value="{!Shipment__c.Origin_Planet__c}"/>
               <apex:outputField value="{!Shipment__c.Destination_Planet__c}"/>
               <apex:outputField value="{!Shipment__c.Status__c}"/>
               <apex:outputField value="{!Shipment__c.ETA__c}"/>
           </apex:pageBlockSection>
       </apex:pageBlock>
       
       <apex:pageBlock title="Cargo Manifest">
           <apex:pageBlockTable value="{!relatedCargo}" var="cargo">
               <apex:column value="{!cargo.Name}"/>
               <apex:column value="{!cargo.Category__c}"/>
               <apex:column value="{!cargo.Weight__c}"/>
           </apex:pageBlockTable>
       </apex:pageBlock>
   </apex:page>
   ```

2. **Create Controller Extension:**
   ```apex
   public with sharing class ShipmentSummaryController {
       public List<Cargo__c> relatedCargo { get; set; }
       
       public ShipmentSummaryController(ApexPages.StandardController controller) {
           Id shipmentId = controller.getId();
           relatedCargo = [
               SELECT Id, Name, Category__c, Weight__c
               FROM Cargo__c
               WHERE Shipment__c = :shipmentId
           ];
       }
   }
   ```

3. **Test & Commit**

### Section 9.2: Lightning Web Component (LWC)

**Deliverable:** Real-time tracking component (mock)

**Action Items:**

1. **Create LWC:**
   ```bash
   sf lightning generate component -n realtimeTracking -d force-app/main/default/lwc
   ```

2. **Implement (see continuation in next section)**

---

## Phase 10-15: [Continued in IMPLEMENTATION_PLAN_PART2.md]

Due to length, the remaining phases are in Part 2:
- Phase 10: Aura Component
- Phase 11: Async Apex
- Phase 12: Testing & Debugging
- Phase 13: AppExchange & Reports
- Phase 14: Agentforce AI
- Phase 15: Final Deployment & Documentation

---

## Summary Checklist

### Week 1-2: Foundation
- [ ] Phase 0: Project setup (COMPLETED)
- [ ] Phase 1: Data model design & implementation
- [ ] Phase 2: Security architecture

### Week 3-4: Automation
- [ ] Phase 3: Validation rules
- [ ] Phase 4: Approval process
- [ ] Phase 5: Record-Triggered Flows
- [ ] Phase 6: Apex classes (business logic)

### Week 5-6: Advanced Logic & UI
- [ ] Phase 7: Apex triggers
- [ ] Phase 8: Lightning Experience customization
- [ ] Phase 9: Custom components (VF, LWC, Aura)

### Week 7-8: Advanced Features & Deployment
- [ ] Phase 10-15: See Part 2

**Next Immediate Action:** Begin Phase 1 - Data Architecture Design (ERD creation)
