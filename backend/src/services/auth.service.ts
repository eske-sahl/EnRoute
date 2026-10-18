import prisma from '../config/prisma';
import { hashPassword, comparePassword } from '../utils/password';
import { signToken } from '../utils/jwt';
import { AppError } from '../middlewares/error.middleware';
import { Role, AccountStatus } from '@prisma/client';

export interface RegisterDTO {
  email: string;
  password: string;
  fullName: string;
  phoneNumber: string;
  role?: Role;
  operatorName?: string; // If registering as an owner
}

export interface LoginDTO {
  email: string;
  password: string;
}

export class AuthService {
  async register(data: RegisterDTO) {
    const existingEmail = await prisma.user.findUnique({ where: { email: data.email } });
    if (existingEmail) {
      throw new AppError('An account with this email already exists.', 409);
    }

    const existingPhone = await prisma.user.findUnique({ where: { phoneNumber: data.phoneNumber } });
    if (existingPhone) {
      throw new AppError('An account with this phone number already exists.', 409);
    }

    const passwordHash = await hashPassword(data.password);
    const requestedRole = data.role || Role.ROLE_PASSENGER;

    // Conductor accounts cannot self-register; they are created by owners.
    // Admin accounts are seeded.
    if (requestedRole === Role.ROLE_ADMIN || requestedRole === Role.ROLE_CONDUCTOR) {
      throw new AppError('Direct registration for this role is not permitted.', 403);
    }

    const initialStatus =
      requestedRole === Role.ROLE_OWNER
        ? AccountStatus.PENDING_VERIFICATION
        : AccountStatus.ACTIVE;

    // Use transaction to create user and associated role records atomically
    const user = await prisma.$transaction(async (tx) => {
      const newUser = await tx.user.create({
        data: {
          email: data.email,
          passwordHash,
          fullName: data.fullName,
          phoneNumber: data.phoneNumber,
          role: requestedRole,
          status: initialStatus,
        },
      });

      // Automatically provision demonstration wallet for passengers
      if (requestedRole === Role.ROLE_PASSENGER) {
        await tx.wallet.create({
          data: {
            userId: newUser.id,
            balance: 250.0, // Default demo credit
          },
        });
      }

      // Provision owner profile if registering as bus owner
      if (requestedRole === Role.ROLE_OWNER) {
        await tx.ownerProfile.create({
          data: {
            userId: newUser.id,
            operatorName: data.operatorName || `${data.fullName}'s Bus Lines`,
            isVerified: false,
          },
        });
      }

      return newUser;
    });

    const token = signToken({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    return {
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        role: user.role,
        status: user.status,
        createdAt: user.createdAt,
      },
      token,
    };
  }

  async login(data: LoginDTO) {
    const user = await prisma.user.findUnique({
      where: { email: data.email },
      include: {
        wallet: true,
        ownerProfile: true,
      },
    });

    if (!user) {
      throw new AppError('Invalid email or password.', 401);
    }

    const isPasswordValid = await comparePassword(data.password, user.passwordHash);
    if (!isPasswordValid) {
      throw new AppError('Invalid email or password.', 401);
    }

    if (user.status === AccountStatus.SUSPENDED) {
      throw new AppError('Your account has been suspended. Please contact platform administration.', 403);
    }

    const token = signToken({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    return {
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        role: user.role,
        status: user.status,
        walletBalance: user.wallet?.balance ?? null,
        ownerVerified: user.ownerProfile?.isVerified ?? null,
        createdAt: user.createdAt,
      },
      token,
    };
  }

  async getCurrentUser(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        wallet: {
          select: { balance: true, updatedAt: true },
        },
        ownerProfile: true,
      },
    });

    if (!user) {
      throw new AppError('User not found.', 404);
    }

    return {
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      role: user.role,
      status: user.status,
      walletBalance: user.wallet?.balance ?? null,
      ownerProfile: user.ownerProfile
        ? {
            operatorName: user.ownerProfile.operatorName,
            isVerified: user.ownerProfile.isVerified,
            idProofUrl: user.ownerProfile.idProofUrl,
            permitDocUrl: user.ownerProfile.permitDocUrl,
          }
        : null,
      createdAt: user.createdAt,
    };
  }
}

export default new AuthService();
