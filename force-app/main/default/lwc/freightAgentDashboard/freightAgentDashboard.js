import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FreightAgentDashboard extends NavigationMixin(LightningElement) {
    // KPI Metrics - These could be wired to Apex in the future
    myShipmentsCount = 12;
    cargoCount = 34;
    customsCount = 8;

    // Navigation card data
    navigationCards = [
        {
            id: 'shipments',
            title: 'My Shipments',
            description: 'View and manage your assigned shipments',
            icon: 'custom:custom18',
            objectApiName: 'Shipment__c'
        },
        {
            id: 'cargo',
            title: 'Cargo Items',
            description: 'Track cargo within your shipments',
            icon: 'custom:custom48',
            objectApiName: 'Cargo__c'
        },
        {
            id: 'customs',
            title: 'Customs Documents',
            description: 'Manage customs documentation',
            icon: 'custom:custom85',
            objectApiName: 'Customs_Document__c'
        }
    ];

    // Navigate to object list view
    handleNavigate(event) {
        const objectApiName = event.currentTarget.dataset.object;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectApiName,
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }
}