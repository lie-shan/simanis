const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');
const authMiddleware = require('../middleware/auth');

// Get dashboard overview
router.get('/overview', authMiddleware, dashboardController.getDashboardOverview);

// Get academic statistics
router.get('/stats/academic', authMiddleware, dashboardController.getAcademicStats);

// Get financial statistics
router.get('/stats/financial', authMiddleware, dashboardController.getFinancialStats);

// Get attendance statistics
router.get('/stats/attendance', authMiddleware, dashboardController.getAttendanceStats);

module.exports = router;
