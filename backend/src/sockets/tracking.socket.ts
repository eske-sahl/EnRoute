import { Server, Socket } from 'socket.io';

interface LocationUpdatePayload {
  tripId: string;
  busId: string;
  latitude: number;
  longitude: number;
  bearing?: number;
  speed?: number;
  conductorId: string;
  timestamp?: string;
}

export const setupTrackingSocket = (io: Server) => {
  const trackingNamespace = io.of('/tracking');

  trackingNamespace.on('connection', (socket: Socket) => {
    console.log(`[Socket.io] Client connected to /tracking: ${socket.id}`);

    // Passenger or Conductor joins a specific trip tracking room
    socket.on('join_trip_room', (tripId: string) => {
      socket.join(`trip_${tripId}`);
      console.log(`[Socket.io] Socket ${socket.id} joined room: trip_${tripId}`);
      socket.emit('joined_room_ack', { tripId, message: `Subscribed to live tracking for trip ${tripId}` });
    });

    // Leave a trip room
    socket.on('leave_trip_room', (tripId: string) => {
      socket.leave(`trip_${tripId}`);
      console.log(`[Socket.io] Socket ${socket.id} left room: trip_${tripId}`);
    });

    // Conductor broadcasts active GPS coordinate
    socket.on('conductor:send_location', (payload: LocationUpdatePayload) => {
      if (!payload.tripId || payload.latitude === undefined || payload.longitude === undefined) {
        return socket.emit('error', { message: 'Invalid location payload' });
      }

      const updateData = {
        tripId: payload.tripId,
        busId: payload.busId,
        latitude: payload.latitude,
        longitude: payload.longitude,
        bearing: payload.bearing || 0,
        speed: payload.speed || 0,
        updatedAt: new Date().toISOString(),
      };

      // Broadcast coordinates to all passengers currently tracking this trip
      trackingNamespace.to(`trip_${payload.tripId}`).emit('bus:location_update', updateData);
    });

    socket.on('disconnect', () => {
      console.log(`[Socket.io] Client disconnected: ${socket.id}`);
    });
  });
};
