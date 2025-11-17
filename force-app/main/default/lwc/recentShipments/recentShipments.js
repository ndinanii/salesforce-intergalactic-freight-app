import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRecentShipments from '@salesforce/apex/ShipmentController.getRecentShipments';
import USER_ID from '@salesforce/user/Id';

export default class RecentShipments extends NavigationMixin(LightningElement) {
    userId = USER_ID;
    shipments = [];
    error;
    isLoading = true;

    @wire(getRecentShipments, { userId: '$userId', limitCount: 5 })
    wiredShipments({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.shipments = data.map(shipment => {
                return {
                    ...shipment,
                    statusClass: this.getStatusClass(shipment.Status__c),
                    formattedDate: this.formatDate(shipment.Departure_Date__c),
                    formattedETA: this.formatDate(shipment.ETA__c)
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.shipments = [];
        }
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

    get emptyMessage() {
        return 'No recent shipments assigned to you';
    }
}