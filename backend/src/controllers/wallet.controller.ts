import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import walletService from '../services/wallet.service';

const rechargeSchema = z.object({
  amount: z.number().positive('Recharge amount must be positive'),
});

export class WalletController {
  async getMyWallet(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const wallet = await walletService.getWalletByUserId(userId);

      res.status(200).json({
        status: 'success',
        data: { wallet },
      });
    } catch (error) {
      next(error);
    }
  }

  async rechargeWallet(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const { amount } = rechargeSchema.parse(req.body);

      const result = await walletService.rechargeDemoWallet(userId, amount);

      res.status(200).json({
        status: 'success',
        message: `Successfully credited ₹${amount} to demo wallet`,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  async getMyTransactions(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const transactions = await walletService.getTransactionHistory(userId);

      res.status(200).json({
        status: 'success',
        data: { transactions },
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new WalletController();
