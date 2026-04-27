const express = require('express');
const router = express.Router();
const mapelController = require('../controllers/mapelController');
const authMiddleware = require('../middleware/auth');

// Get all mata pelajaran
router.get('/', authMiddleware, mapelController.getAllMapel);

// Get available mapel (for dropdown)
router.get('/dropdown/available', authMiddleware, mapelController.getAvailableMapel);

// Get mata pelajaran by ID
router.get('/:id', authMiddleware, mapelController.getMapelById);

// Create mata pelajaran
router.post('/', authMiddleware, mapelController.createMapel);

// Update mata pelajaran
router.put('/:id', authMiddleware, mapelController.updateMapel);

// Delete mata pelajaran
router.delete('/:id', authMiddleware, mapelController.deleteMapel);

module.exports = router;
