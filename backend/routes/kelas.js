const express = require('express');
const router = express.Router();
const kelasController = require('../controllers/kelasController');
const authMiddleware = require('../middleware/auth');

// Get all kelas
router.get('/', authMiddleware, kelasController.getAllKelas);

// Get kelas statistics
router.get('/stats/overview', authMiddleware, kelasController.getKelasStats);

// Get available kelas (for dropdown)
router.get('/dropdown/available', authMiddleware, kelasController.getAvailableKelas);

// Get kelas by ID
router.get('/:id', authMiddleware, kelasController.getKelasById);

// Create kelas
router.post('/', authMiddleware, kelasController.createKelas);

// Update kelas
router.put('/:id', authMiddleware, kelasController.updateKelas);

// Delete kelas
router.delete('/:id', authMiddleware, kelasController.deleteKelas);

module.exports = router;
