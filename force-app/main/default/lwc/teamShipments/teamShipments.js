import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTeamShipments from '@salesforce/apex/OperationsManagerController.getTeamShipments';

export default class TeamShipments extends NavigationMixin(LightningElement) {
    shipments = [];
    error;
    isLoading = true;
    selectedFilter = 'all';

    @wire(getTeamShipments, { statusFilter: '$selectedFilter', limitCount: 10 })
    wiredShipments({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.shipments = data.map(shipment => {
                return {
                    ...shipment,
                    statusClass: this.getStatusClass(shipment.Status__c),
                    formattedDate: this.formatDate(shipment.Departure_Date__c),
                    formattedETA: this.formatDate(shipment.ETA__c),
                    agentName: shipment.Assigned_Agent__r ? shipment.Assigned_Agent__r.Name : 'Unassigned'
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.shipments = [];
        }
    }

    get filterOptions() {
        return [
            { label: 'All Shipments', value: 'all' },
            { label: 'Pending', value: 'Pending' },
            { label: 'In Transit', value: 'In Transit' },
            { label: 'At Customs', value: 'At Customs' },
            { label: 'Delivered', value: 'Delivered' }
        ];
    }

    getStatusClass(status) {
        const statusMap = {
            'Pending': 'slds-badge slds-theme_warning',
            'In Transit': 'slds-badge slds-theme_info',
            'At Customs': 'slds-badge slds-theme_alert-texture',
            'Delivered': 'slds-badge slds-theme_success',
            'Cancelled': 'slds-badge slds-theme_error'
        };
        return statusMap[status] || 'slds-badge';
    }

    formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        return date.toLocaleDateString('en-US', { 
            month: 'short', 
            day: 'numeric', 
            year: 'numeric' 
        });
    }

    handleFilterChange(event) {
        this.selectedFilter = event.detail.value;
        this.isLoading = true;
    }

    handleViewShipment(event) {
        const shipmentId = event.currentTarget.dataset.id;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: shipmentId,
                objectApiName: 'Shipment__c',
                actionName: 'view'
            }
        });
    }

    handleViewAll() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Shipment__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    get hasShipments() {
        return this.shipments && this.shipments.length > 0;
    }
}