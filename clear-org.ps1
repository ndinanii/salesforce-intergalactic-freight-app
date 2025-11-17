# Script to clear all custom metadata from the Salesforce org
# This will delete all custom objects, Apex classes, triggers, LWC components, etc.

Write-Host "WARNING: This script will delete ALL custom metadata from your Salesforce org!" -ForegroundColor Red
Write-Host "Custom Objects to be deleted: Agent__c, Cargo__c, Customs_Document__c, Shipment__c" -ForegroundColor Yellow
Write-Host ""
$confirmation = Read-Host "Are you sure you want to proceed? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "Operation cancelled." -ForegroundColor Green
    exit
}

Write-Host "`nDeploying destructive changes to org..." -ForegroundColor Cyan

# Deploy the destructive changes
sf project deploy start --manifest manifest/package-empty.xml --post-destructive-changes manifest/destructiveChanges.xml

Write-Host "`nDestructive changes deployed. Your org is now clean!" -ForegroundColor Green
