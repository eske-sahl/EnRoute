import prisma from '../config/prisma';
import { AppError } from '../middlewares/error.middleware';
import { TripStatus } from '@prisma/client';

export interface StartTripDTO {
  busId: string;
  routeId: string;
  conductorId: string;
}

export interface UpdateTripGpsDTO {
  tripId: string;
  latitude: number;
  longitude: number;
  bearing?: number;
}

export class TripService {
  async startTrip(data: StartTripDTO) {
    // Check if bus already has an active trip in progress
    const activeTrip = await prisma.trip.findFirst({
      where: {
        busId: data.busId,
        status: TripStatus.IN_TRANSIT,
      },
    });

    if (activeTrip) {
      throw new AppError(
        `This bus is already on an active trip (Trip ID: ${activeTrip.id}). Please end that trip before starting a new one.`,
        400
      );
    }

    const trip = await prisma.trip.create({
      data: {
        busId: data.busId,
        routeId: data.routeId,
        conductorId: data.conductorId,
        status: TripStatus.IN_TRANSIT,
        startedAt: new Date(),
      },
      include: {
        bus: true,
        route: {
          include: { stops: { orderBy: { stageIndex: 'asc' } } },
        },
      },
    });

    return trip;
  }

  async updateLocation(data: UpdateTripGpsDTO) {
    const trip = await prisma.trip.findUnique({
      where: { id: data.tripId },
    });

    if (!trip) {
      throw new AppError('Trip not found.', 404);
    }

    if (trip.status !== TripStatus.IN_TRANSIT) {
      throw new AppError('Location updates are only accepted for active (IN_TRANSIT) trips.', 400);
    }

    const updated = await prisma.trip.update({
      where: { id: data.tripId },
      data: {
        currentLatitude: data.latitude,
        currentLongitude: data.longitude,
        currentBearing: data.bearing || 0,
        lastGpsPing: new Date(),
      },
    });

    return updated;
  }

  async endTrip(tripId: string, conductorId: string) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      include: {
        tickets: true,
      },
    });

    if (!trip) {
      throw new AppError('Trip not found.', 404);
    }

    if (trip.status === TripStatus.COMPLETED) {
      throw new AppError('Trip is already completed.', 400);
    }

    const totalTicketsCount = trip.tickets.length;
    const totalRevenue = trip.tickets.reduce((sum, t) => sum + t.fareAmount, 0);

    const completedTrip = await prisma.trip.update({
      where: { id: tripId },
      data: {
        status: TripStatus.COMPLETED,
        completedAt: new Date(),
      },
      include: {
        bus: true,
        route: true,
      },
    });

    return {
      trip: completedTrip,
      summary: {
        totalTicketsCount,
        totalRevenue,
      },
    };
  }

  async getActiveTrips() {
    return prisma.trip.findMany({
      where: { status: TripStatus.IN_TRANSIT },
      include: {
        bus: { select: { regNumber: true, busName: true, busType: true } },
        route: { select: { routeNumber: true, sourceName: true, destName: true } },
      },
      orderBy: { startedAt: 'desc' },
    });
  }

  async getTripDetails(tripId: string) {
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      include: {
        bus: true,
        route: {
          include: { stops: { orderBy: { stageIndex: 'asc' } } },
        },
        conductor: { select: { fullName: true, phoneNumber: true } },
        tickets: {
          orderBy: { issuedAt: 'desc' },
          take: 50,
        },
      },
    });

    if (!trip) {
      throw new AppError('Trip not found.', 404);
    }

    return trip;
  }
}

export default new TripService();
