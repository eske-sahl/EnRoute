import { Router } from 'express';
import busController from '../controllers/bus.controller';
import { authenticateJWT } from '../middlewares/auth.middleware';
import { requireRole } from '../middlewares/role.middleware';
import { Role } from '@prisma/client';

const router = Router();

/**
 * @route   GET /api/buses
 * @desc    Get all active buses in the system
 * @access  Public
 */
router.get('/', busController.getAllBuses);

/**
 * @route   GET /api/buses/my-fleet
 * @desc    Get buses registered by the authenticated owner
 * @access  Private (ROLE_OWNER)
 */
router.get(
  '/my-fleet',
  authenticateJWT,
  requireRole([Role.ROLE_OWNER, Role.ROLE_ADMIN]),
  busController.getMyBuses
);

/**
 * @route   POST /api/buses
 * @desc    Register a new bus into the fleet
 * @access  Private (ROLE_OWNER)
 */
router.post(
  '/',
  authenticateJWT,
  requireRole([Role.ROLE_OWNER, Role.ROLE_ADMIN]),
  busController.registerBus
);

/**
 * @route   GET /api/buses/:id
 * @desc    Get detailed bus information
 * @access  Public
 */
router.get('/:id', busController.getBusDetails);

export default router;
