import prisma from '../config/prisma';
import { AppError } from '../middlewares/error.middleware';

export class WalletService {
  async getWalletByUserId(userId: string) {
    const wallet = await prisma.wallet.findUnique({
      where: { userId },
      include: {
        transactions: {
          orderBy: { createdAt: 'desc' },
          take: 20,
        },
      },
    });

    if (!wallet) {
      throw new AppError('Wallet not found for this user.', 404);
    }

    return wallet;
  }

  async rechargeDemoWallet(userId: string, amount: number) {
    if (amount <= 0) {
      throw new AppError('Recharge amount must be greater than zero.', 400);
    }

    const wallet = await prisma.wallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      throw new AppError('Wallet not found for this user.', 404);
    }

    // Atomic recharge & ledger record
    const result = await prisma.$transaction(async (tx) => {
      const updatedWallet = await tx.wallet.update({
        where: { userId },
        data: { balance: { increment: amount } },
      });

      const txRecord = await tx.transaction.create({
        data: {
          walletId: wallet.id,
          amount,
          type: 'CREDIT_RECHARGE',
          description: `Demo Wallet Top-Up of ₹${amount.toFixed(2)}`,
        },
      });

      return {
        wallet: updatedWallet,
        transaction: txRecord,
      };
    });

    return result;
  }

  async getTransactionHistory(userId: string) {
    const wallet = await prisma.wallet.findUnique({
      where: { userId },
    });

    if (!wallet) {
      throw new AppError('Wallet not found for this user.', 404);
    }

    return prisma.transaction.findMany({
      where: { walletId: wallet.id },
      orderBy: { createdAt: 'desc' },
    });
  }
}

export default new WalletService();
