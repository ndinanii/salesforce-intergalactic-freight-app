import { LightningElement, track } from 'lwc';

export default class RealtimeTracking extends LightningElement {
    @track shipments = [];
    @track isLoading = true;
    intervalId;
    
    connectedCallback() {
        this.loadShipments();
        // Simulate real-time updates every 10 seconds
        this.intervalId = setInterval(() => {
            this.updateShipmentStatuses();
        }, 10000);
    }
    
    disconnectedCallback() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
        }
    }
    
    loadShipments() {
        // Mock API call - in production, this would be an Apex call
        this.isLoading = true;
        
        setTimeout(() => {
            this.shipments = [
                {
                    id: '1',
                    name: 'SH-001',
                    status: 'In Transit',
                    currentLocation: 'Mars Orbit Station',
                    destination: 'Jupiter Colony',
                    progress: 45,
                    eta: '2024-02-15',
                    lastUpdate: new Date().toLocaleTimeString()
                },
                {
                    id: '2',
                    name: 'SH-002',
                    status: 'Loading',
                    currentLocation: 'Earth Port Alpha',
                    destination: 'Venus Base',
                    progress: 15,
                    eta: '2024-02-20',
                    lastUpdate: new Date().toLocaleTimeString()
                },
                {
                    id: '3',
                    name: 'SH-003',
                    status: 'In Transit',
                    currentLocation: 'Asteroid Belt Waypoint',
                    destination: 'Saturn Mining Colony',
                    progress: 78,
                    eta: '2024-02-12',
                    lastUpdate: new Date().toLocaleTimeString()
                },
                {
                    id: '4',
                    name: 'SH-004',
                    status: 'Customs',
                    currentLocation: 'Europa Customs Station',
                    destination: 'Titan Outpost',
                    progress: 92,
                    eta: '2024-02-14',
                    lastUpdate: new Date().toLocaleTimeString()
                }
            ];
            this.isLoading = false;
        }, 1000);
    }
    
    updateShipmentStatuses() {
        // Simulate real-time status updates
        this.shipments = this.shipments.map(shipment => {
            if (shipment.status === 'In Transit' && shipment.progress < 95) {
                return {
                    ...shipment,
                    progress: Math.min(shipment.progress + Math.floor(Math.random() * 5), 100),
                    lastUpdate: new Date().toLocaleTimeString()
                };
            }
            return shipment;
        });
    }
    
    handleRefresh() {
        this.loadShipments();
    }
    
    get statusClass() {
        return 'slds-badge';
    }
    
    getStatusVariant(status) {
        const variants = {
            'In Transit': 'slds-theme_success',
            'Loading': 'slds-theme_warning',
            'Customs': 'slds-theme_info',
            'Delivered': 'slds-theme_inverse'
        };
        return variants[status] || '';
    }
}