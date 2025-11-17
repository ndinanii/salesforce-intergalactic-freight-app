({
    doInit: function(component, event, helper) {
        helper.loadData(component);
    },
    
    handleShipmentChange: function(component, event, helper) {
        var selectedValue = event.getSource().get("v.value");
        component.set("v.selectedShipment", selectedValue);
        component.set("v.message", "");
    },
    
    handleCargoChange: function(component, event, helper) {
        var selectedValue = event.getSource().get("v.value");
        component.set("v.selectedCargo", selectedValue);
        component.set("v.message", "");
    },
    
    handleAssignment: function(component, event, helper) {
        var shipmentId = component.get("v.selectedShipment");
        var cargoId = component.get("v.selectedCargo");
        
        if (shipmentId && cargoId) {
            helper.assignCargo(component, shipmentId, cargoId);
        }
    }
})