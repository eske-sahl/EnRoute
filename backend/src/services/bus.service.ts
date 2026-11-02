import prisma from '../config/prisma';
import { AppError } from '../middlewares/error.middleware';
import fs from 'fs';
import path from 'path';

function getFallbackBuses(): any[] {
  try {
    const dataPath = path.join(__dirname, '../../../data/smartbus_state.json');
    const altPath = path.join(__dirname, '../../data/smartbus_state.json');
    const targetPath = fs.existsSync(dataPath) ? dataPath : altPath;
    if (fs.existsSync(targetPath)) {
      const parsed = JSON.parse(fs.readFileSync(targetPath, 'utf-8'));
      return parsed.buses || [];
    }
  } catch (e) {
    console.warn('Error reading fallback buses from JSON store:', e);
  }
  return [];
}

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

    try {
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
    } catch (err: any) {
      if (err instanceof AppError) throw err;
      // Fallback response for offline development
      return {
        id: `BUS-${Date.now()}`,
        regNumber: normalizedReg,
        busName: data.busName,
        busType: data.busType || 'ORDINARY',
        seatingCapacity: data.seatingCapacity || 48,
        ownerId: data.ownerId,
        createdAt: new Date(),
      };
    }
  }

  async getBusesByOwner(ownerId: string) {
    try {
      return await prisma.bus.findMany({
        where: { ownerId },
        include: {
          trips: {
            orderBy: { createdAt: 'desc' },
            take: 1,
          },
        },
        orderBy: { createdAt: 'desc' },
      });
    } catch {
      const fallback = getFallbackBuses();
      return fallback.map((b) => ({
        ...b,
        trips: [],
      }));
    }
  }

  async getAllActiveBuses() {
    try {
      return await prisma.bus.findMany({
        include: {
          owner: {
            select: { operatorName: true, isVerified: true },
          },
        },
        orderBy: { busName: 'asc' },
      });
    } catch {
      const fallback = getFallbackBuses();
      return fallback.map((b) => ({
        id: b.id,
        regNumber: b.regNumber,
        busName: b.busName,
        busType: b.busType || 'ORDINARY',
        seatingCapacity: b.seatingCapacity || 48,
        status: b.status || 'ACTIVE',
        owner: {
          operatorName: b.operatorName || 'St. George Motors Ernakulam',
          isVerified: true,
        },
      }));
    }
  }

  async getBusById(busId: string) {
    try {
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
    } catch (err) {
      if (err instanceof AppError) throw err;
      const fallback = getFallbackBuses();
      const bus = fallback.find((b) => b.id === busId || b.regNumber === busId);
      if (!bus) {
        throw new AppError('Bus not found.', 404);
      }
      return {
        ...bus,
        trips: [],
      };
    }
  }
}

export default new BusService();
