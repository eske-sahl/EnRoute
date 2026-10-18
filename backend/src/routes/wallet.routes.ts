import { Router } from 'express';
import walletController from '../controllers/wallet.controller';
import { authenticateJWT } from '../middlewares/auth.middleware';
import { requireRole } from '../middlewares/role.middleware';
import { Role } from '@prisma/client';

const router = Router();

/**
 * @route   GET /api/wallet
 * @desc    Get passenger's wallet balance and recent transactions
 * @access  Private (ROLE_PASSENGER)
 */
router.get(
  '/',
  authenticateJWT,
  requireRole([Role.ROLE_PASSENGER]),
  walletController.getMyWallet
);

/**
 * @route   POST /api/wallet/recharge
 * @desc    Top up demo wallet balance
 * @access  Private (ROLE_PASSENGER)
 */
router.post(
  '/recharge',
  authenticateJWT,
  requireRole([Role.ROLE_PASSENGER]),
  walletController.rechargeWallet
);

/**
 * @route   GET /api/wallet/transactions
 * @desc    Get complete transaction history for passenger
 * @access  Private (ROLE_PASSENGER)
 */
router.get(
  '/transactions',
  authenticateJWT,
  requireRole([Role.ROLE_PASSENGER]),
  walletController.getMyTransactions
);

export default router;
