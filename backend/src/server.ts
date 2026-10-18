import express from 'express';
import http from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import dotenv from 'dotenv';
import healthRoutes from './routes/health.routes';
import authRoutes from './routes/auth.routes';
import busRoutes from './routes/bus.routes';
import routeRoutes from './routes/route.routes';
import tripRoutes from './routes/trip.routes';
import ticketRoutes from './routes/ticket.routes';
import walletRoutes from './routes/wallet.routes';
import { setupTrackingSocket } from './sockets/tracking.socket';
import { errorHandler } from './middlewares/error.middleware';

dotenv.config();

const app = express();
const server = http.createServer(app);

// Setup Socket.io
const io = new Server(server, {
  cors: {
    origin: process.env.CLIENT_URL || '*',
    methods: ['GET', 'POST'],
  },
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Setup Real-time Tracking Gateway
setupTrackingSocket(io);

// Base API Routes
app.use('/api/health', healthRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/buses', busRoutes);
app.use('/api/routes', routeRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/tickets', ticketRoutes);
app.use('/api/wallet', walletRoutes);

// Root Welcome Endpoint
app.get('/', (req, res) => {
  res.json({
    project: 'SmartBus Kerala',
    type: 'Final-Year Degree Project',
    apiDocumentation: '/api-docs',
    healthCheck: '/api/health',
    status: 'Operational',
  });
});

// Error handling middleware
app.use(errorHandler);

const PORT = process.env.PORT || 5001;

server.listen(PORT, () => {
  console.log(`===============================================`);
  console.log(`🚍 SmartBus Kerala Backend Server Running`);
  console.log(`🌐 REST API: http://localhost:${PORT}`);
  console.log(`🩺 Health:   http://localhost:${PORT}/api/health`);
  console.log(`📡 Sockets:  ws://localhost:${PORT}/tracking`);
  console.log(`===============================================`);
});

export { app, server, io };
