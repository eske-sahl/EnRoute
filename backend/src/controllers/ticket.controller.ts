import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import ticketService from '../services/ticket.service';
import { PaymentMethod } from '@prisma/client';

const issueTicketSchema = z.object({
  passengerId: z.string().uuid('Invalid Passenger ID format'),
  tripId: z.string().uuid('Invalid Trip ID format'),
  boardingStopName: z.string().min(1, 'Boarding stop is required'),
  destinationStopName: z.string().min(1, 'Destination stop is required'),
  passengerCount: z.number().int().positive().optional(),
  paymentMethod: z.enum([PaymentMethod.WALLET, PaymentMethod.CASH, PaymentMethod.UPI]),
});

export class TicketController {
  async issueTicket(req: Request, res: Response, next: NextFunction) {
    try {
      const validatedData = issueTicketSchema.parse(req.body);
      const ticket = await ticketService.issueTicket(validatedData);

      res.status(201).json({
        status: 'success',
        message: 'Digital ticket issued successfully',
        data: { ticket },
      });
    } catch (error) {
      next(error);
    }
  }

  async getMyTickets(req: Request, res: Response, next: NextFunction) {
    try {
      const passengerId = req.user!.userId;
      const tickets = await ticketService.getPassengerTickets(passengerId);

      res.status(200).json({
        status: 'success',
        data: { tickets },
      });
    } catch (error) {
      next(error);
    }
  }

  async getTripTickets(req: Request, res: Response, next: NextFunction) {
    try {
      const { tripId } = req.params;
      const tickets = await ticketService.getTripTickets(tripId);

      res.status(200).json({
        status: 'success',
        data: { tickets },
      });
    } catch (error) {
      next(error);
    }
  }

  async verifyTicket(req: Request, res: Response, next: NextFunction) {
    try {
      const { ticketNumber } = req.params;
      const ticket = await ticketService.getTicketByNumber(ticketNumber);

      res.status(200).json({
        status: 'success',
        data: { ticket },
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new TicketController();
