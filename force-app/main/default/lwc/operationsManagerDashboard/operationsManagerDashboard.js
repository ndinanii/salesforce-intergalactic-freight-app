import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getShipmentStats from '@salesforce/apex/OperationsManagerController.getShipmentStats';

export default class OperationsManagerDashboard extends NavigationMixin(LightningElement) {
    stats = {};
    error;
    isLoading = true;

    // Dashboard metrics
    @wire(getShipmentStats)
    wiredStats({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.stats = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.stats = {};
        }
    }

    get totalShipments() {
        return this.stats.total || 0;
    }

    get activeShipments() {
        return this.stats.active || 0;
    }

    get pendingReview() {
        return this.stats.pendingReview || 0;
    }

    get deliveredThisMonth() {
        return this.stats.deliveredThisMonth || 0;
    }

    // Navigation cards for managers
    navigationCards = [
        {
            id: 'all-shipments',
            title: 'All Shipments',
            description: 'View and manage all team shipments',
            icon: 'custom:custom18',
            count: 0,
            objectApiName: 'Shipment__c'
        },
        {
            id: 'team-agents',
            title: 'Team Agents',
            description: 'Manage freight agents and assignments',
            icon: 'custom:custom96',
            count: 0,
            objectApiName: 'Agent__c'
        },
        {
            id: 'customs-review',
            title: 'Customs Review',
            description: 'Review and approve customs documents',
            icon: 'custom:custom85',
            count: 0,
            objectApiName: 'Customs_Document__c'
        }
    ];

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

    handleViewReports() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Report',
                actionName: 'home'
            }
        });
    }
}