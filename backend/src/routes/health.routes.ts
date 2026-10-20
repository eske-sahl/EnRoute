import { Router, Request, Response } from 'express';

const router = Router();

/**
 * @route   GET /api/health
 * @desc    System health check & status
 * @access  Public
 */
router.get('/', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'success',
    message: 'EnRoute Kerala API is running',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    uptimeSeconds: process.uptime(),
  });
});

export default router;
