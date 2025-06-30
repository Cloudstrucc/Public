import express from 'express';
import { AuthRequest } from '../middleware/auth';
import { prisma } from '../index';
import logger from '../config/logger';

const router = express.Router();

// GET /api/orders - Get user's orders
router.get('/', async (req: AuthRequest, res) => {
  try {
    const orders = await prisma.order.findMany({
      where: { userId: req.user!.id },
      include: {
        orderItems: {
          include: {
            product: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json(orders);
  } catch (error) {
    logger.error('Error fetching orders:', error);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

export default router;
