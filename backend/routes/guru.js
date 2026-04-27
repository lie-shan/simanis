const express = require('express');
const router = express.Router();
const guruController = require('../controllers/guruController');
const authMiddleware = require('../middleware/auth');

// Get all guru
router.get('/', authMiddleware, guruController.getAllGuru);

// Get available guru (for dropdown)
router.get('/dropdown/available', authMiddleware, guruController.getAvailableGuru);

// Get guru by ID
router.get('/:id', authMiddleware, guruController.getGuruById);

// Create guru (auto-create user account if email provided)
router.post('/', authMiddleware, guruController.createGuru);

// Update guru
router.put('/:id', authMiddleware, guruController.updateGuru);

// Delete guru (with related user account)
router.delete('/:id', authMiddleware, guruController.deleteGuru);

module.exports = router;
