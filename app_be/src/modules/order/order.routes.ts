import { Router } from 'express';
import { orderController } from './order.controller';
import { validate } from '../../common/middlewares/validate.middleware';
import { DecodeMiddleware } from '../../common/middlewares/decode.middleware';
import { CreateOrderSchema } from './order.schema';

const router = Router();

// GET /orders
router.get('/', DecodeMiddleware, orderController.getOrders.bind(orderController));

// GET /orders/:id
router.get('/:id', DecodeMiddleware, orderController.getOrderDetail.bind(orderController));

// POST /orders
router.post(
  '/',
  DecodeMiddleware,
  validate(CreateOrderSchema),
  orderController.createOrder.bind(orderController),
);
export default router;
