({
    loadData: function(component) {
        component.set("v.isLoading", true);
        
        var action = component.get("c.getAssignmentData");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.shipments", result.shipments);
                component.set("v.cargoItems", result.cargoItems);
            } else {
                var errors = response.getError();
                var message = 'Unknown error';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                component.set("v.message", "Error loading data: " + message);
                component.set("v.messageType", "error");
            }
            component.set("v.isLoading", false);
        });
        
        $A.enqueueAction(action);
    },
    
    assignCargo: function(component, shipmentId, cargoId) {
        component.set("v.isLoading", true);
        
        var action = component.get("c.assignCargoToShipment");
        action.setParams({
            shipmentId: shipmentId,
            cargoId: cargoId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.message", "Cargo successfully assigned to shipment!");
                component.set("v.messageType", "success");
                component.set("v.selectedShipment", "");
                component.set("v.selectedCargo", "");
                
                // Reload data
                this.loadData(component);
                
                // Clear message after 3 seconds
                setTimeout(function() {
                    component.set("v.message", "");
                }, 3000);
            } else {
                var errors = response.getError();
                var message = 'Unknown error';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                component.set("v.message", "Error assigning cargo: " + message);
                component.set("v.messageType", "error");
                component.set("v.isLoading", false);
            }
        });
        
        $A.enqueueAction(action);
    }
})