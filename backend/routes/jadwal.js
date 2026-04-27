const express = require('express');
const router = express.Router();
const jadwalController = require('../controllers/jadwalController');
const authMiddleware = require('../middleware/auth');

// Get all jadwal
router.get('/', authMiddleware, jadwalController.getAllJadwal);

// Get jadwal by kelas
router.get('/kelas/:kelas_id', authMiddleware, jadwalController.getJadwalByKelas);

// Get guru schedule
router.get('/guru/:guru_id/schedule', authMiddleware, jadwalController.getGuruSchedule);

// Create jadwal
router.post('/', authMiddleware, jadwalController.createJadwal);

// Update jadwal
router.put('/:id', authMiddleware, jadwalController.updateJadwal);

// Delete jadwal
router.delete('/:id', authMiddleware, jadwalController.deleteJadwal);

module.exports = router;
