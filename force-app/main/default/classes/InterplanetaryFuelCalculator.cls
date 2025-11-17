public with sharing class InterplanetaryFuelCalculator {
    
    // Fuel cost per kg per million km (in credits)
    private static final Decimal BASE_FUEL_RATE = 0.15;
    
    // Distance matrix (in million km) - simplified interplanetary distances
    private static final Map<String, Decimal> DISTANCE_MAP = new Map<String, Decimal>{
        'Earth-Mars' => 78.0,
        'Mars-Earth' => 78.0,
        'Earth-Jupiter' => 628.0,
        'Jupiter-Earth' => 628.0,
        'Earth-Venus' => 41.0,
        'Venus-Earth' => 41.0,
        'Mars-Jupiter' => 550.0,
        'Jupiter-Mars' => 550.0,
        'Earth-Saturn' => 1275.0,
        'Saturn-Earth' => 1275.0,
        'Mars-Saturn' => 1197.0,
        'Saturn-Mars' => 1197.0,
        'Jupiter-Saturn' => 647.0,
        'Saturn-Jupiter' => 647.0,
        'Venus-Mars' => 119.0,
        'Mars-Venus' => 119.0,
        'Earth-Neptune' => 4350.0,
        'Neptune-Earth' => 4350.0
    };
    
    /**
     * Calculate fuel cost for a single shipment
     * @param cargoWeight Total cargo weight in kg
     * @param origin Origin planet
     * @param destination Destination planet
     * @return Decimal fuel cost in credits
     */
    public static Decimal calculateFuelCost(Decimal cargoWeight, String origin, String destination) {
        if (cargoWeight == null || cargoWeight <= 0) {
            throw new FuelCalculatorException('Cargo weight must be greater than zero');
        }
        
        if (String.isBlank(origin) || String.isBlank(destination)) {
            throw new FuelCalculatorException('Origin and destination are required');
        }
        
        Decimal distance = getDistance(origin, destination);
        
        // Formula: Fuel Cost = (Cargo Weight * Distance * Base Rate)
        Decimal fuelCost = cargoWeight * distance * BASE_FUEL_RATE;
        
        // Round to 2 decimal places
        return fuelCost.setScale(2, RoundingMode.HALF_UP);
    }
    
    /**
     * Calculate fuel cost for multiple shipments
     * @param shipments List of Shipment records with Origin and Destination (external data)
     * @param originDestinationMap Map of Shipment Id to Origin-Destination string (e.g., 'Earth-Mars')
     * @return Map of Shipment Id to fuel cost
     */
    public static Map<Id, Decimal> calculateBulkFuelCosts(Map<Id, String> originDestinationMap) {
        Map<Id, Decimal> fuelCostMap = new Map<Id, Decimal>();
        
        for (Id shipmentId : originDestinationMap.keySet()) {
            try {
                // Get total cargo weight for this shipment
                Decimal totalWeight = getTotalCargoWeight(shipmentId);
                
                if (totalWeight > 0) {
                    String[] locations = originDestinationMap.get(shipmentId).split('-');
                    if (locations.size() == 2) {
                        Decimal fuelCost = calculateFuelCost(totalWeight, locations[0], locations[1]);
                        fuelCostMap.put(shipmentId, fuelCost);
                    }
                }
            } catch (Exception e) {
                System.debug('Error calculating fuel for shipment ' + shipmentId + ': ' + e.getMessage());
                fuelCostMap.put(shipmentId, 0);
            }
        }
        
        return fuelCostMap;
    }
    
    /**
     * Get distance between two planets
     * @param origin Origin planet
     * @param destination Destination planet
     * @return Decimal distance in million km
     */
    private static Decimal getDistance(String origin, String destination) {
        String routeKey = origin + '-' + destination;
        
        if (DISTANCE_MAP.containsKey(routeKey)) {
            return DISTANCE_MAP.get(routeKey);
        }
        
        // Default distance if route not found
        System.debug('Route ' + routeKey + ' not found in distance map. Using default distance.');
        return 100.0; // Default 100 million km
    }
    
    /**
     * Get total cargo weight for a shipment
     * @param shipmentId Shipment Id
     * @return Decimal total weight in kg
     */
    private static Decimal getTotalCargoWeight(Id shipmentId) {
        AggregateResult[] results = [
            SELECT SUM(Weight__c) totalWeight
            FROM Cargo__c
            WHERE Shipment__c = :shipmentId
        ];
        
        if (results.size() > 0 && results[0].get('totalWeight') != null) {
            return (Decimal)results[0].get('totalWeight');
        }
        
        return 0;
    }
    
    /**
     * Calculate fuel costs and return for external processing
     * Note: Shipment object doesn't have Origin__c, Destination__c, or Fuel_Cost__c fields
     * This method can be used when those fields are added or for external calculations
     * @param originDestinationMap Map of Shipment Id to 'Origin-Destination' route
     * @return Map of Shipment Id to fuel cost
     */
    public static Map<Id, Decimal> calculateFuelCostsForShipments(Map<Id, String> originDestinationMap) {
        Map<Id, Decimal> fuelCostMap = new Map<Id, Decimal>();
        
        for (Id shipmentId : originDestinationMap.keySet()) {
            try {
                Decimal totalWeight = getTotalCargoWeight(shipmentId);
                if (totalWeight > 0) {
                    String[] locations = originDestinationMap.get(shipmentId).split('-');
                    if (locations.size() == 2) {
                        Decimal fuelCost = calculateFuelCost(totalWeight, locations[0], locations[1]);
                        fuelCostMap.put(shipmentId, fuelCost);
                    }
                }
            } catch (Exception e) {
                System.debug('Error: ' + e.getMessage());
            }
        }
        
        return fuelCostMap;
    }
    
    /**
     * Custom exception class
     */
    public class FuelCalculatorException extends Exception {}
}