const express = require('express');
const router = express.Router();
const pengumumanController = require('../controllers/pengumumanController');
const authMiddleware = require('../middleware/auth');

// Get all pengumuman
router.get('/', authMiddleware, pengumumanController.getAllPengumuman);

// Get active pengumuman (public, no auth required)
router.get('/public/active', pengumumanController.getActivePengumuman);

// Get pengumuman statistics
router.get('/stats/overview', authMiddleware, pengumumanController.getPengumumanStats);

// Get pengumuman by ID
router.get('/:id', authMiddleware, pengumumanController.getPengumumanById);

// Create pengumuman
router.post('/', authMiddleware, pengumumanController.createPengumuman);

// Update pengumuman
router.put('/:id', authMiddleware, pengumumanController.updatePengumuman);

// Delete pengumuman
router.delete('/:id', authMiddleware, pengumumanController.deletePengumuman);

module.exports = router;
