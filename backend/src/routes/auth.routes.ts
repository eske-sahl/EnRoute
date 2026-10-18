import { Router } from 'express';
import authController from '../controllers/auth.controller';
import { authenticateJWT } from '../middlewares/auth.middleware';

const router = Router();

/**
 * @route   POST /api/auth/register
 * @desc    Register a new Passenger or Owner
 * @access  Public
 */
router.post('/register', authController.register);

/**
 * @route   POST /api/auth/login
 * @desc    Authenticate user & return JWT token
 * @access  Public
 */
router.post('/login', authController.login);

/**
 * @route   GET /api/auth/me
 * @desc    Get profile of the currently authenticated user
 * @access  Private (Bearer JWT)
 */
router.get('/me', authenticateJWT, authController.getCurrentUser);

export default router;
