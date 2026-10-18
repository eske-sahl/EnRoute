import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import busService from '../services/bus.service';
import prisma from '../config/prisma';
import { AppError } from '../middlewares/error.middleware';

const registerBusSchema = z.object({
  regNumber: z.string().min(5, 'Registration number is required (e.g. KL 07 CD 4589)'),
  busName: z.string().min(2, 'Bus name is required'),
  busType: z.enum(['ORDINARY', 'LSFP', 'FAST_PASSENGER']).optional(),
  seatingCapacity: z.number().int().positive().optional(),
});

export class BusController {
  async registerBus(req: Request, res: Response, next: NextFunction) {
    try {
      const validatedData = registerBusSchema.parse(req.body);
      const userId = req.user!.userId;

      // Find owner profile for this user
      const ownerProfile = await prisma.ownerProfile.findUnique({
        where: { userId },
      });

      if (!ownerProfile) {
        throw new AppError('Bus Owner profile not found for this account.', 404);
      }

      const bus = await busService.registerBus({
        ownerId: ownerProfile.id,
        ...validatedData,
      });

      res.status(201).json({
        status: 'success',
        message: 'Bus registered successfully',
        data: { bus },
      });
    } catch (error) {
      next(error);
    }
  }

  async getMyBuses(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.userId;
      const ownerProfile = await prisma.ownerProfile.findUnique({
        where: { userId },
      });

      if (!ownerProfile) {
        throw new AppError('Owner profile not found.', 404);
      }

      const buses = await busService.getBusesByOwner(ownerProfile.id);
      res.status(200).json({
        status: 'success',
        data: { buses },
      });
    } catch (error) {
      next(error);
    }
  }

  async getAllBuses(req: Request, res: Response, next: NextFunction) {
    try {
      const buses = await busService.getAllActiveBuses();
      res.status(200).json({
        status: 'success',
        data: { buses },
      });
    } catch (error) {
      next(error);
    }
  }

  async getBusDetails(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const bus = await busService.getBusById(id);
      res.status(200).json({
        status: 'success',
        data: { bus },
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new BusController();
