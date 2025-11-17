const express = require('express');
const router = express.Router();
const shipmentService = require('../services/shipment.service');

// GET all shipments
router.get('/', async (req, res, next) => {
  try {
    const result = await shipmentService.getAllShipments();
    res.json({
      success: true,
      data: result.records,
      totalSize: result.totalSize
    });
  } catch (error) {
    next(error);
  }
});

// GET shipment by ID
router.get('/:id', async (req, res, next) => {
  try {
    const shipment = await shipmentService.getShipmentById(req.params.id);
    res.json({
      success: true,
      data: shipment
    });
  } catch (error) {
    next(error);
  }
});

// GET active shipments
router.get('/status/active', async (req, res, next) => {
  try {
    const result = await shipmentService.getActiveShipments();
    res.json({
      success: true,
      data: result.records,
      totalSize: result.totalSize
    });
  } catch (error) {
    next(error);
  }
});

// POST create new shipment
router.post('/', async (req, res, next) => {
  try {
    const result = await shipmentService.createShipment(req.body);
    res.status(201).json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
});

// PUT update shipment
router.put('/:id', async (req, res, next) => {
  try {
    const result = await shipmentService.updateShipment(req.params.id, req.body);
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
});

// DELETE shipment
router.delete('/:id', async (req, res, next) => {
  try {
    const result = await shipmentService.deleteShipment(req.params.id);
    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
