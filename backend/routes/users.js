const express = require('express');
const router = express.Router();
const usersController = require('../controllers/usersController');
const authMiddleware = require('../middleware/auth');

// Get all users
router.get('/', authMiddleware, usersController.getAllUsers);

// Get user by ID
router.get('/:id', authMiddleware, usersController.getUserById);

// Create user
router.post('/', authMiddleware, usersController.createUser);

// Update user
router.put('/:id', authMiddleware, usersController.updateUser);

// Delete user
router.delete('/:id', authMiddleware, usersController.deleteUser);

// Change password
router.put('/:id/change-password', authMiddleware, usersController.changePassword);

module.exports = router;
