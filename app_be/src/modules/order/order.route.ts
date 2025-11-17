import { Router } from 'express';
import { OrderController } from './order.controller';
import { authMiddleware } from '../../common/middlewares/auth.middleware';

const router = Router();
const orderController = new OrderController();

router.get('/orders', authMiddleware, (req, res) =>
  orderController.getMyOrders(req, res)
);

export default router;
