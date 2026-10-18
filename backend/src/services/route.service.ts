import prisma from '../config/prisma';
import { AppError } from '../middlewares/error.middleware';

export interface CreateStopDTO {
  stopName: string;
  stageIndex: number; // 1-indexed
  latitude: number;
  longitude: number;
}

export interface CreateRouteDTO {
  routeNumber: string;
  sourceName: string;
  destName: string;
  baseFare?: number;
  farePerStage?: number;
  stops: CreateStopDTO[];
}

export class RouteService {
  async createRoute(data: CreateRouteDTO) {
    if (!data.stops || data.stops.length < 2) {
      throw new AppError('A bus route must have at least 2 stops (source and destination).', 400);
    }

    // Sort stops sequentially by stageIndex
    const sortedStops = [...data.stops].sort((a, b) => a.stageIndex - b.stageIndex);

    // Verify stage indices are unique and sequential
    const stageIndices = sortedStops.map((s) => s.stageIndex);
    const hasDuplicates = new Set(stageIndices).size !== stageIndices.length;
    if (hasDuplicates) {
      throw new AppError('Route stops cannot have duplicate stage indices.', 400);
    }

    const route = await prisma.route.create({
      data: {
        routeNumber: data.routeNumber,
        sourceName: data.sourceName,
        destName: data.destName,
        baseFare: data.baseFare ?? 10.0,
        farePerStage: data.farePerStage ?? 1.5,
        stops: {
          create: sortedStops.map((stop) => ({
            stopName: stop.stopName,
            stageIndex: stop.stageIndex,
            latitude: stop.latitude,
            longitude: stop.longitude,
          })),
        },
      },
      include: {
        stops: {
          orderBy: { stageIndex: 'asc' },
        },
      },
    });

    return route;
  }

  async getAllRoutes() {
    return prisma.route.findMany({
      where: { isActive: true },
      include: {
        stops: {
          orderBy: { stageIndex: 'asc' },
        },
      },
      orderBy: { routeNumber: 'asc' },
    });
  }

  async getRouteById(routeId: string) {
    const route = await prisma.route.findUnique({
      where: { id: routeId },
      include: {
        stops: {
          orderBy: { stageIndex: 'asc' },
        },
      },
    });

    if (!route) {
      throw new AppError('Route not found.', 404);
    }

    return route;
  }

  /**
   * Authoritative Kerala MVD Stage Fare Calculation Engine
   * Validates that destination stage index > boarding stage index.
   */
  async calculateFare(routeId: string, boardingStopName: string, destinationStopName: string) {
    const route = await this.getRouteById(routeId);

    const boardingStop = route.stops.find(
      (s) => s.stopName.toLowerCase() === boardingStopName.toLowerCase()
    );
    const destStop = route.stops.find(
      (s) => s.stopName.toLowerCase() === destinationStopName.toLowerCase()
    );

    if (!boardingStop) {
      throw new AppError(`Boarding stop '${boardingStopName}' does not exist on route ${route.routeNumber}.`, 404);
    }
    if (!destStop) {
      throw new AppError(`Destination stop '${destinationStopName}' does not exist on route ${route.routeNumber}.`, 404);
    }

    if (destStop.stageIndex <= boardingStop.stageIndex) {
      throw new AppError(
        `Destination '${destStop.stopName}' (Stage ${destStop.stageIndex}) must follow Boarding '${boardingStop.stopName}' (Stage ${boardingStop.stageIndex}).`,
        400
      );
    }

    const stagesTraveled = destStop.stageIndex - boardingStop.stageIndex;
    const baseStages = 2; // Minimum fare covers first 2 stages in Kerala
    const baseFare = route.baseFare; // e.g. ₹10.00
    const farePerStage = route.farePerStage; // e.g. ₹1.50

    let calculatedFare = baseFare;
    if (stagesTraveled > baseStages) {
      calculatedFare = baseFare + (stagesTraveled - baseStages) * farePerStage;
    }

    return {
      routeId: route.id,
      routeNumber: route.routeNumber,
      boardingStop: {
        name: boardingStop.stopName,
        stage: boardingStop.stageIndex,
      },
      destinationStop: {
        name: destStop.stopName,
        stage: destStop.stageIndex,
      },
      stagesTraveled,
      baseFare,
      ratePerStage: farePerStage,
      authoritativeFare: Math.round(calculatedFare * 10) / 10, // Round to 1 decimal place
    };
  }
}

export default new RouteService();
