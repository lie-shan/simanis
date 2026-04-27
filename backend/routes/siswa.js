const express = require('express');
const router = express.Router();
const siswaController = require('../controllers/siswaController');
const authMiddleware = require('../middleware/auth');

// Get all siswa
router.get('/', authMiddleware, siswaController.getAllSiswa);

// Get siswa count by kelas
router.get('/stats/count-by-kelas', authMiddleware, siswaController.getSiswaCountByKelas);

// Get siswa by ID
router.get('/:id', authMiddleware, siswaController.getSiswaById);

// Create siswa (auto-create user account if email provided)
router.post('/', authMiddleware, siswaController.createSiswa);

// Update siswa
router.put('/:id', authMiddleware, siswaController.updateSiswa);

// Delete siswa (with related user account)
router.delete('/:id', authMiddleware, siswaController.deleteSiswa);

module.exports = router;
