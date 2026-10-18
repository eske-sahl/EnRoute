import { Router } from 'express';
import tripController from '../controllers/trip.controller';
import { authenticateJWT } from '../middlewares/auth.middleware';
import { requireRole } from '../middlewares/role.middleware';
import { Role } from '@prisma/client';

const router = Router();

/**
 * @route   GET /api/trips/active
 * @desc    Get all buses currently in transit with real-time GPS coordinates
 * @access  Public (for Passenger Live Radar)
 */
router.get('/active', tripController.getActiveTrips);

/**
 * @route   POST /api/trips/start
 * @desc    Conductor starts an active trip
 * @access  Private (ROLE_CONDUCTOR)
 */
router.post(
  '/start',
  authenticateJWT,
  requireRole([Role.ROLE_CONDUCTOR, Role.ROLE_ADMIN]),
  tripController.startTrip
);

/**
 * @route   POST /api/trips/location
 * @desc    Conductor streams current GPS coordinates
 * @access  Private (ROLE_CONDUCTOR)
 */
router.post(
  '/location',
  authenticateJWT,
  requireRole([Role.ROLE_CONDUCTOR, Role.ROLE_ADMIN]),
  tripController.updateLocation
);

/**
 * @route   POST /api/trips/:id/end
 * @desc    Conductor concludes the trip
 * @access  Private (ROLE_CONDUCTOR)
 */
router.post(
  '/:id/end',
  authenticateJWT,
  requireRole([Role.ROLE_CONDUCTOR, Role.ROLE_ADMIN]),
  tripController.endTrip
);

/**
 * @route   GET /api/trips/:id
 * @desc    Get details, route, stops, and tickets for a trip
 * @access  Public
 */
router.get('/:id', tripController.getTripDetails);

export default router;
