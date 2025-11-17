const salesforceService = require('../services/salesforce.service');

class ShipmentService {
  async getAllShipments() {
    const query = `
      SELECT Id, Name, Origin__c, Destination__c, Departure_Date__c, 
             ETA__c, Status__c, Total_Weight__c, Agent__r.Name
      FROM Shipment__c
      ORDER BY CreatedDate DESC
      LIMIT 100
    `;
    return salesforceService.query(query);
  }

  async getShipmentById(id) {
    return salesforceService.retrieve('Shipment__c', id);
  }

  async createShipment(shipmentData) {
    return salesforceService.create('Shipment__c', shipmentData);
  }

  async updateShipment(id, shipmentData) {
    return salesforceService.update('Shipment__c', { Id: id, ...shipmentData });
  }

  async deleteShipment(id) {
    return salesforceService.delete('Shipment__c', id);
  }

  async getShipmentsByStatus(status) {
    const query = `
      SELECT Id, Name, Origin__c, Destination__c, Status__c, ETA__c
      FROM Shipment__c
      WHERE Status__c = '${status}'
      ORDER BY ETA__c ASC
    `;
    return salesforceService.query(query);
  }

  async getActiveShipments() {
    const query = `
      SELECT Id, Name, Origin__c, Destination__c, Status__c, ETA__c, Agent__r.Name
      FROM Shipment__c
      WHERE Status__c IN ('In Transit', 'Pending', 'In Customs')
      ORDER BY ETA__c ASC
    `;
    return salesforceService.query(query);
  }
}

module.exports = new ShipmentService();
