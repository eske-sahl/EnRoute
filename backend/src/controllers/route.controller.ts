import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import routeService from '../services/route.service';

const stopSchema = z.object({
  stopName: z.string().min(2, 'Stop name is required'),
  stageIndex: z.number().int().positive('Stage index must be a positive integer'),
  latitude: z.number(),
  longitude: z.number(),
});

const createRouteSchema = z.object({
  routeNumber: z.string().min(1, 'Route number is required (e.g. R-14)'),
  sourceName: z.string().min(2, 'Source is required'),
  destName: z.string().min(2, 'Destination is required'),
  baseFare: z.number().positive().optional(),
  farePerStage: z.number().positive().optional(),
  stops: z.array(stopSchema).min(2, 'Route must have at least 2 stops'),
});

const calculateFareSchema = z.object({
  routeId: z.string().uuid('Invalid Route ID format'),
  boardingStopName: z.string().min(1, 'Boarding stop is required'),
  destinationStopName: z.string().min(1, 'Destination stop is required'),
});

export class RouteController {
  async createRoute(req: Request, res: Response, next: NextFunction) {
    try {
      const validatedData = createRouteSchema.parse(req.body);
      const route = await routeService.createRoute(validatedData);
      res.status(201).json({
        status: 'success',
        message: 'Route created successfully',
        data: { route },
      });
    } catch (error) {
      next(error);
    }
  }

  async getAllRoutes(req: Request, res: Response, next: NextFunction) {
    try {
      const routes = await routeService.getAllRoutes();
      res.status(200).json({
        status: 'success',
        data: { routes },
      });
    } catch (error) {
      next(error);
    }
  }

  async getRouteById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const route = await routeService.getRouteById(id);
      res.status(200).json({
        status: 'success',
        data: { route },
      });
    } catch (error) {
      next(error);
    }
  }

  async calculateFare(req: Request, res: Response, next: NextFunction) {
    try {
      const { routeId, boardingStopName, destinationStopName } = calculateFareSchema.parse(req.body);
      const fareInfo = await routeService.calculateFare(routeId, boardingStopName, destinationStopName);
      res.status(200).json({
        status: 'success',
        data: fareInfo,
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new RouteController();
