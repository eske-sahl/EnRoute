import { Router } from 'express';
import ticketController from '../controllers/ticket.controller';
import { authenticateJWT } from '../middlewares/auth.middleware';
import { requireRole } from '../middlewares/role.middleware';
import { Role } from '@prisma/client';

const router = Router();

/**
 * @route   POST /api/tickets/issue
 * @desc    Conductor issues a digital ticket during an active trip
 * @access  Private (ROLE_CONDUCTOR, ROLE_ADMIN)
 */
router.post(
  '/issue',
  authenticateJWT,
  requireRole([Role.ROLE_CONDUCTOR, Role.ROLE_ADMIN]),
  ticketController.issueTicket
);

/**
 * @route   GET /api/tickets/my-tickets
 * @desc    Get ticket purchase history for the logged-in passenger
 * @access  Private (ROLE_PASSENGER)
 */
router.get(
  '/my-tickets',
  authenticateJWT,
  requireRole([Role.ROLE_PASSENGER]),
  ticketController.getMyTickets
);

/**
 * @route   GET /api/tickets/trip/:tripId
 * @desc    Get all tickets issued for a particular trip
 * @access  Private (ROLE_CONDUCTOR, ROLE_OWNER, ROLE_ADMIN)
 */
router.get(
  '/trip/:tripId',
  authenticateJWT,
  requireRole([Role.ROLE_CONDUCTOR, Role.ROLE_OWNER, Role.ROLE_ADMIN]),
  ticketController.getTripTickets
);

/**
 * @route   GET /api/tickets/verify/:ticketNumber
 * @desc    Verify ticket authenticity by ticket reference number
 * @access  Public
 */
router.get('/verify/:ticketNumber', ticketController.verifyTicket);

export default router;
