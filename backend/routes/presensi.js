const express = require('express');
const router = express.Router();
const presensiController = require('../controllers/presensiController');
const authMiddleware = require('../middleware/auth');

// Get all presensi
router.get('/', authMiddleware, presensiController.getAllPresensi);

// Get presensi statistics
router.get('/stats/overview', authMiddleware, presensiController.getPresensiStats);

// Get presensi by kelas on specific date
router.get('/kelas/:kelas_id', authMiddleware, presensiController.getPresensiByKelas);

// Get presensi by siswa
router.get('/siswa/:siswa_id', authMiddleware, presensiController.getPresensiBySiswa);

// Create presensi
router.post('/', authMiddleware, presensiController.createPresensi);

// Bulk create presensi (for a class)
router.post('/bulk', authMiddleware, presensiController.createBulkPresensi);

// Update presensi
router.put('/:id', authMiddleware, presensiController.updatePresensi);

// Delete presensi
router.delete('/:id', authMiddleware, presensiController.deletePresensi);

module.exports = router;
