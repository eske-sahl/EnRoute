import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import tripService from '../services/trip.service';

const startTripSchema = z.object({
  busId: z.string().uuid('Invalid Bus ID format'),
  routeId: z.string().uuid('Invalid Route ID format'),
});

const updateGpsSchema = z.object({
  tripId: z.string().uuid('Invalid Trip ID format'),
  latitude: z.number(),
  longitude: z.number(),
  bearing: z.number().optional(),
});

export class TripController {
  async startTrip(req: Request, res: Response, next: NextFunction) {
    try {
      const { busId, routeId } = startTripSchema.parse(req.body);
      const conductorId = req.user!.userId;

      const trip = await tripService.startTrip({
        busId,
        routeId,
        conductorId,
      });

      res.status(201).json({
        status: 'success',
        message: 'Trip started successfully. Realtime tracking active.',
        data: { trip },
      });
    } catch (error) {
      next(error);
    }
  }

  async updateLocation(req: Request, res: Response, next: NextFunction) {
    try {
      const validatedData = updateGpsSchema.parse(req.body);
      const updatedTrip = await tripService.updateLocation(validatedData);

      res.status(200).json({
        status: 'success',
        data: {
          tripId: updatedTrip.id,
          currentLatitude: updatedTrip.currentLatitude,
          currentLongitude: updatedTrip.currentLongitude,
          lastGpsPing: updatedTrip.lastGpsPing,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  async endTrip(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const conductorId = req.user!.userId;

      const result = await tripService.endTrip(id, conductorId);

      res.status(200).json({
        status: 'success',
        message: 'Trip ended successfully.',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  async getActiveTrips(req: Request, res: Response, next: NextFunction) {
    try {
      const trips = await tripService.getActiveTrips();
      res.status(200).json({
        status: 'success',
        data: { trips },
      });
    } catch (error) {
      next(error);
    }
  }

  async getTripDetails(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const trip = await tripService.getTripDetails(id);
      res.status(200).json({
        status: 'success',
        data: { trip },
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new TripController();
