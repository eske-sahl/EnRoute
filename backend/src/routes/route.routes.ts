import { Router } from 'express';
import routeController from '../controllers/route.controller';
import { authenticateJWT } from '../middlewares/auth.middleware';
import { requireRole } from '../middlewares/role.middleware';
import { Role } from '@prisma/client';

const router = Router();

/**
 * @route   GET /api/routes
 * @desc    Get all active bus routes with ordered stops
 * @access  Public
 */
router.get('/', routeController.getAllRoutes);

/**
 * @route   POST /api/routes
 * @desc    Create a new bus route with ordered stage stops
 * @access  Private (ROLE_ADMIN, ROLE_OWNER)
 */
router.post(
  '/',
  authenticateJWT,
  requireRole([Role.ROLE_ADMIN, Role.ROLE_OWNER]),
  routeController.createRoute
);

/**
 * @route   POST /api/routes/calculate-fare
 * @desc    Calculate authoritative Kerala stage fare between stops
 * @access  Public
 */
router.post('/calculate-fare', routeController.calculateFare);

/**
 * @route   GET /api/routes/:id
 * @desc    Get details and ordered stops of a specific route
 * @access  Public
 */
router.get('/:id', routeController.getRouteById);

export default router;
