import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ManagerQuickActions extends NavigationMixin(LightningElement) {
    quickActions = [
        {
            id: 'assign-shipment',
            label: 'Assign Shipment',
            icon: 'action:share_post',
            description: 'Assign shipments to agents',
            objectApiName: 'Shipment__c'
        },
        {
            id: 'review-customs',
            label: 'Review Documents',
            icon: 'action:approval',
            description: 'Review customs documents',
            objectApiName: 'Customs_Document__c'
        },
        {
            id: 'create-report',
            label: 'Generate Report',
            icon: 'action:new_note',
            description: 'Create performance reports',
            action: 'reports'
        },
        {
            id: 'bulk-update',
            label: 'Bulk Update',
            icon: 'action:update',
            description: 'Update multiple records',
            objectApiName: 'Shipment__c'
        }
    ];

    handleQuickAction(event) {
        const actionId = event.currentTarget.dataset.id;
        const action = this.quickActions.find(a => a.id === actionId);
        
        if (action.action === 'reports') {
            this.navigateToReports();
        } else if (action.objectApiName) {
            this.navigateToListView(action.objectApiName);
        }
    }

    navigateToListView(objectApiName) {
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

    navigateToReports() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Report',
                actionName: 'home'
            }
        });
    }
}