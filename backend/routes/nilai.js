const express = require('express');
const router = express.Router();
const nilaiController = require('../controllers/nilaiController');
const authMiddleware = require('../middleware/auth');

// Get all nilai
router.get('/', authMiddleware, nilaiController.getAllNilai);

// Get nilai by siswa
router.get('/siswa/:siswa_id', authMiddleware, nilaiController.getNilaiBySiswa);

// Get nilai by mapel
router.get('/mapel/:mapel_id', authMiddleware, nilaiController.getNilaiByMapel);

// Get nilai by kelas
router.get('/kelas/:kelas_id', authMiddleware, nilaiController.getNilaiByKelas);

// Get single nilai
router.get('/:id', authMiddleware, nilaiController.getNilaiById);

// Create nilai
router.post('/', authMiddleware, nilaiController.createNilai);

// Update nilai
router.put('/:id', authMiddleware, nilaiController.updateNilai);

// Delete nilai
router.delete('/:id', authMiddleware, nilaiController.deleteNilai);

module.exports = router;
