import prisma from '../config/prisma';
import routeService from './route.service';
import { AppError } from '../middlewares/error.middleware';
import { PaymentMethod, TripStatus } from '@prisma/client';

export interface IssueTicketDTO {
  passengerId: string;
  tripId: string;
  boardingStopName: string;
  destinationStopName: string;
  passengerCount?: number;
  paymentMethod: PaymentMethod;
}

export class TicketService {
  /**
   * Generates a unique, standardized Kerala bus ticket reference number.
   * Format: SBK-YYYYMMDD-XXXX
   */
  private generateTicketNumber(): string {
    const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const randomHex = Math.floor(1000 + Math.random() * 9000);
    return `SBK-${today}-${randomHex}`;
  }

  async issueTicket(data: IssueTicketDTO) {
    const passengerCount = data.passengerCount || 1;

    // 1. Validate Trip Existence and Active Status
    const trip = await prisma.trip.findUnique({
      where: { id: data.tripId },
      include: {
        bus: true,
        route: {
          include: { stops: { orderBy: { stageIndex: 'asc' } } },
        },
      },
    });

    if (!trip) {
      throw new AppError('Trip not found.', 404);
    }

    if (trip.status !== TripStatus.IN_TRANSIT) {
      throw new AppError('Tickets can only be issued for trips currently IN_TRANSIT.', 400);
    }

    // 2. Validate Passenger Existence
    const passenger = await prisma.user.findUnique({
      where: { id: data.passengerId },
      include: { wallet: true },
    });

    if (!passenger) {
      throw new AppError('Passenger not found in system.', 404);
    }

    // 3. Calculate Authoritative Stage Fare via Route Engine
    const fareInfo = await routeService.calculateFare(
      trip.routeId,
      data.boardingStopName,
      data.destinationStopName
    );

    const unitFare = fareInfo.authoritativeFare;
    const totalFareAmount = unitFare * passengerCount;
    const ticketNumber = this.generateTicketNumber();

    // 4. Execute Atomic Financial Transaction (ACID)
    const result = await prisma.$transaction(async (tx) => {
      // If payment method is WALLET, deduct balance atomically
      if (data.paymentMethod === PaymentMethod.WALLET) {
        if (!passenger.wallet) {
          throw new AppError('Passenger does not have an active digital wallet.', 400);
        }

        const currentWallet = await tx.wallet.findUnique({
          where: { userId: data.passengerId },
        });

        if (!currentWallet || currentWallet.balance < totalFareAmount) {
          throw new AppError(
            `Insufficient wallet balance (Available: ₹${currentWallet?.balance.toFixed(2) ?? 0}, Required: ₹${totalFareAmount.toFixed(2)}). Please use Cash or UPI.`,
            400
          );
        }

        // Deduct fare
        await tx.wallet.update({
          where: { userId: data.passengerId },
          data: { balance: { decrement: totalFareAmount } },
        });

        // Record debit transaction in passenger's financial ledger
        await tx.transaction.create({
          data: {
            walletId: currentWallet.id,
            amount: -totalFareAmount,
            type: 'DEBIT_TICKET',
            description: `Bus Ticket ${ticketNumber} (${trip.bus.regNumber}: ${data.boardingStopName} to ${data.destinationStopName})`,
          },
        });
      }

      // Create Digital Ticket Record
      const newTicket = await tx.ticket.create({
        data: {
          ticketNumber,
          passengerId: data.passengerId,
          tripId: data.tripId,
          boardingStop: data.boardingStopName,
          destinationStop: data.destinationStopName,
          boardingStage: fareInfo.boardingStop.stage,
          destinationStage: fareInfo.destinationStop.stage,
          fareAmount: totalFareAmount,
          passengerCount,
          paymentMethod: data.paymentMethod,
        },
        include: {
          passenger: { select: { fullName: true, phoneNumber: true } },
          trip: {
            select: {
              bus: { select: { regNumber: true, busName: true } },
              route: { select: { routeNumber: true } },
            },
          },
        },
      });

      return newTicket;
    });

    return result;
  }

  async getPassengerTickets(passengerId: string) {
    return prisma.ticket.findMany({
      where: { passengerId },
      include: {
        trip: {
          select: {
            bus: { select: { regNumber: true, busName: true } },
            route: { select: { routeNumber: true, sourceName: true, destName: true } },
          },
        },
      },
      orderBy: { issuedAt: 'desc' },
    });
  }

  async getTripTickets(tripId: string) {
    return prisma.ticket.findMany({
      where: { tripId },
      include: {
        passenger: { select: { fullName: true } },
      },
      orderBy: { issuedAt: 'desc' },
    });
  }

  async getTicketByNumber(ticketNumber: string) {
    const ticket = await prisma.ticket.findUnique({
      where: { ticketNumber },
      include: {
        passenger: { select: { fullName: true, phoneNumber: true } },
        trip: {
          include: {
            bus: true,
            route: true,
          },
        },
      },
    });

    if (!ticket) {
      throw new AppError('Ticket not found.', 404);
    }

    return ticket;
  }
}

export default new TicketService();
