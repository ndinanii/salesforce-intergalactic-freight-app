# Manual Org Cleanup Guide

The automated destructive changes deployment failed due to component dependencies. Here's the step-by-step manual cleanup process:

## 🚨 Important: Delete in This Exact Order

### Step 1: Delete Lightning Pages
These pages reference LWC components and must be deleted first.

1. Go to Setup → Lightning App Builder
2. Delete these pages:
   - `Freight Agent Home`
   - `Agent Home`
   - `Operations Manager Home`
   - `Home` (if it contains freight components)

**OR** Search for "Lightning Pages" in Setup and delete them there.

### Step 2: Delete Flows
Flows reference custom objects and fields.

1. Go to Setup → Flows
2. Deactivate and then delete:
   - `Shipment_Assignment_and_Delay_Notification`
   - `Send_Custom_Notification`

### Step 3: Delete Approval Processes
1. Go to Setup → Approval Processes
2. Delete any approval processes on `Shipment__c`

### Step 4: Remove Permission Set Assignments
1. Go to Setup → Users → Permission Sets
2. Click on `System_Admin_Full_Access`
3. Go to "Manage Assignments"
4. Remove all user assignments
5. Now you can delete the permission set

### Step 5: Delete Visualforce Pages
1. Go to Setup → Visualforce Pages
2. Delete: `ShipmentSummary`

### Step 6: Delete Aura Components
1. Go to Setup → Aura Components
2. Delete: `quickCargoAssignment`

### Step 7: Delete Custom Applications
1. Go to Setup → App Manager
2. Delete these apps:
   - `Agent_Console`
   - `IGFTC_Operations`
   - `Operations_Manager`

### Step 8: Delete Custom Tabs
1. Go to Setup → Tabs
2. Delete all custom tabs:
   - Agent
   - Cargo
   - Customs Document
   - Shipment
   - Freight Agent Home
   - Operations Manager Home
   - QuickCargoAssignment
   - RealtimeTracking
   - ShipmentSummary

### Step 9: Delete Apex Triggers
1. Go to Setup → Apex Triggers
2. Delete:
   - `AutoGenerateCustomsDocument`
   - `PreventActiveShipmentDeletion`

### Step 10: Delete Apex Classes
1. Go to Setup → Apex Classes
2. Delete:
   - `CargoAssignmentController`
   - `CustomsClearanceValidator`
   - `InterplanetaryFuelCalculator`
   - `OperationsManagerController`
   - `ShipmentController`
   - `ShipmentSummaryController`

### Step 11: Delete Lightning Web Components
1. Go to Setup → Lightning Components
2. Delete:
   - `freightAgentDashboard`
   - `managerQuickActions`
   - `operationsManagerDashboard`
   - `quickActions`
   - `realtimeTracking`
   - `recentShipments`
   - `teamShipments`

### Step 12: Delete Custom Objects
Finally, delete the custom objects in this order:

1. Go to Setup → Object Manager
2. Delete in this order:
   - `Customs_Document__c`
   - `Cargo__c`
   - `Agent__c`
   - `Shipment__c` (delete last as it has the most dependencies)

### Step 13: Delete Remaining Permission Sets
1. Go to Setup → Permission Sets
2. Delete:
   - `Freight_Agent_Permissions`
   - `IFTC_Developer_Access`
   - `Operations_Manager_Permissions`

### Step 14: Delete Profiles (if custom)
1. Go to Setup → Profiles
2. If you created custom profiles:
   - `Freight Agent`
   - `Operations Manager`
   Delete them (standard profiles cannot be deleted)

## ✅ Verification

After completing all steps, verify your org is clean:

1. Go to Setup → Object Manager
   - Should only see standard Salesforce objects
   
2. Go to Setup → Apex Classes
   - Should only see standard/managed classes
   
3. Go to Setup → Lightning Components
   - Should only see standard/managed components

4. Go to App Launcher
   - Should only see standard Salesforce apps

## 🔄 Alternative: Use Workbench for Bulk Delete

If you prefer a faster approach:

1. Go to https://workbench.developerforce.com/
2. Login with your org credentials
3. Use "Metadata Types & Components" to delete multiple items at once
4. Select metadata type and delete in the order specified above

## ⚡ Quick Script Alternative

If you're comfortable with the Salesforce CLI, you can try this approach:

```powershell
# Delete Lightning Pages first (manually in UI)
# Then run these commands one at a time

sf project delete source --metadata Flow:Send_Custom_Notification --target-org IntergalacticFreight
sf project delete source --metadata Flow:Shipment_Assignment_and_Delay_Notification --target-org IntergalacticFreight

sf project delete source --metadata ApexPage:ShipmentSummary --target-org IntergalacticFreight

sf project delete source --metadata AuraDefinitionBundle:quickCargoAssignment --target-org IntergalacticFreight

# Continue with other components...
```

## 🆘 If You Get Stuck

Some components might have hidden dependencies. Use these techniques:

1. **Check Where Used**
   - In Setup, click on any component
   - Look for "Where is this used?" link
   - Delete all references first

2. **Use Dependency API**
   - Developer Console → Execute Anonymous
   ```apex
   ToolingAPI.MetadataComponentDependency[] deps = 
       [SELECT RefMetadataComponentId, RefMetadataComponentName, MetadataComponentName 
        FROM MetadataComponentDependency 
        WHERE RefMetadataComponentName = 'YourComponentName'];
   System.debug(deps);
   ```

3. **Delete in Sandbox First**
   - If you have a sandbox, practice there first
   - Document the exact order that works

## ⏱️ Estimated Time

- With UI: 30-45 minutes
- With Workbench: 15-20 minutes
- Manual careful approach: 1 hour

## 📝 Checklist

- [ ] Step 1: Lightning Pages deleted
- [ ] Step 2: Flows deleted
- [ ] Step 3: Approval Processes deleted
- [ ] Step 4: Permission Set assignments removed
- [ ] Step 5: Visualforce Pages deleted
- [ ] Step 6: Aura Components deleted
- [ ] Step 7: Custom Applications deleted
- [ ] Step 8: Custom Tabs deleted
- [ ] Step 9: Apex Triggers deleted
- [ ] Step 10: Apex Classes deleted
- [ ] Step 11: Lightning Web Components deleted
- [ ] Step 12: Custom Objects deleted
- [ ] Step 13: Permission Sets deleted
- [ ] Step 14: Custom Profiles deleted
- [ ] ✅ Org verified clean

Once complete, you'll have a completely clean org ready to start fresh! 🎉
