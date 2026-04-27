const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Login
router.post('/login', authController.login);

// Logout
router.post('/logout', authController.logout);

// Forgot password (send via WhatsApp)
router.post('/forgot-password', authController.forgotPassword);

// Reset password
router.post('/reset-password', authController.resetPassword);

// Verify token
router.get('/verify', authController.verifyToken);

module.exports = router;
