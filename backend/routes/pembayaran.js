const express = require('express');
const router = express.Router();
const pembayaranController = require('../controllers/pembayaranController');
const authMiddleware = require('../middleware/auth');

// Get all pembayaran
router.get('/', authMiddleware, pembayaranController.getAllPembayaran);

// Get pembayaran statistics
router.get('/stats/overview', authMiddleware, pembayaranController.getPembayaranStats);

// Get jenis pembayaran options
router.get('/options/jenis', authMiddleware, pembayaranController.getJenisPembayaran);

// Get pembayaran by siswa
router.get('/siswa/:siswa_id', authMiddleware, pembayaranController.getPembayaranBySiswa);

// Get pembayaran by ID
router.get('/:id', authMiddleware, pembayaranController.getPembayaranById);

// Create pembayaran
router.post('/', authMiddleware, pembayaranController.createPembayaran);

// Bulk create pembayaran (for a class)
router.post('/bulk', authMiddleware, pembayaranController.createBulkPembayaran);

// Update pembayaran (edit tagihan)
router.put('/:id', authMiddleware, pembayaranController.updatePembayaran);

// Process payment (bayar)
router.put('/:id/bayar', authMiddleware, pembayaranController.processPayment);

// Cancel payment
router.put('/:id/batal', authMiddleware, pembayaranController.cancelPayment);

// Delete pembayaran
router.delete('/:id', authMiddleware, pembayaranController.deletePembayaran);

module.exports = router;
