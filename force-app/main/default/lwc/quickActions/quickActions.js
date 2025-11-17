import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class QuickActions extends NavigationMixin(LightningElement) {
    quickActions = [
        {
            id: 'new-shipment',
            label: 'New Shipment',
            icon: 'action:new',
            objectApiName: 'Shipment__c',
            description: 'Create a new shipment'
        },
        {
            id: 'add-cargo',
            label: 'Add Cargo',
            icon: 'action:new_custom48',
            objectApiName: 'Cargo__c',
            description: 'Add cargo to a shipment'
        },
        {
            id: 'upload-document',
            label: 'Upload Document',
            icon: 'action:upload',
            objectApiName: 'Customs_Document__c',
            description: 'Upload customs documentation'
        }
    ];

    handleQuickAction(event) {
        const objectApiName = event.currentTarget.dataset.object;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectApiName,
                actionName: 'new'
            }
        });
    }
}