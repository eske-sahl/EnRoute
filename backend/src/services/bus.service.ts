import prisma from '../config/prisma';
import { AppError } from '../middlewares/error.middleware';

export interface CreateBusDTO {
  ownerId: string; // OwnerProfile ID
  regNumber: string; // e.g. "KL 07 CD 4589"
  busName: string;
  busType?: string;
  seatingCapacity?: number;
}

export class BusService {
  /**
   * Normalizes Kerala vehicle registration plate to standard uppercase without spaces.
   * Example: "kl 07 cd 4589" -> "KL07CD4589"
   */
  normalizePlateNumber(plate: string): string {
    return plate.replace(/[\s-]/g, '').toUpperCase();
  }

  async registerBus(data: CreateBusDTO) {
    const normalizedReg = this.normalizePlateNumber(data.regNumber);

    // Validate registration pattern (e.g., KL07CD4589 or KL7CD4589)
    const keralaPlateRegex = /^KL[0-9]{1,2}[A-Z]{1,3}[0-9]{1,4}$/;
    if (!keralaPlateRegex.test(normalizedReg)) {
      throw new AppError(
        `Invalid Kerala vehicle registration number format: '${data.regNumber}'. Example: KL 07 CD 4589`,
        400
      );
    }

    // Check duplicate registration
    const existingBus = await prisma.bus.findUnique({
      where: { regNumber: normalizedReg },
    });
    if (existingBus) {
      throw new AppError(`A bus with registration number '${normalizedReg}' is already registered.`, 409);
    }

    const bus = await prisma.bus.create({
      data: {
        ownerId: data.ownerId,
        regNumber: normalizedReg,
        busName: data.busName,
        busType: data.busType || 'ORDINARY',
        seatingCapacity: data.seatingCapacity || 48,
      },
    });

    return bus;
  }

  async getBusesByOwner(ownerId: string) {
    return prisma.bus.findMany({
      where: { ownerId },
      include: {
        trips: {
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getAllActiveBuses() {
    return prisma.bus.findMany({
      include: {
        owner: {
          select: { operatorName: true, isVerified: true },
        },
      },
      orderBy: { busName: 'asc' },
    });
  }

  async getBusById(busId: string) {
    const bus = await prisma.bus.findUnique({
      where: { id: busId },
      include: {
        owner: true,
        trips: {
          orderBy: { createdAt: 'desc' },
          take: 5,
        },
      },
    });

    if (!bus) {
      throw new AppError('Bus not found.', 404);
    }

    return bus;
  }
}

export default new BusService();
