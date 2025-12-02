import type { Request, Response } from 'express';
import { orderService } from './order.service';
import { CreateOrderSchema, GetOrdersQuerySchema } from './order.schema';
import { ZodError } from 'zod';
import { err, ok } from '../../common/utils/response';

export class OrderController {
  async getOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.userId;
      if (!userId) return res.status(401).json(err('UNAUTHORIZED'));

      const { status } = GetOrdersQuerySchema.parse(req.query);

      const orders = await orderService.getOrdersByUser(userId, status);

      return res.json(ok(orders));
    } catch (error) {
      console.error(error);
      return res.status(500).json(err('INTERNAL_SERVER_ERROR'));
    }
  }

  async getOrderDetail(req: Request, res: Response) {
    try {
      const userId = req.user?.userId;
      const orderId = Number(req.params.id);

      const order = await orderService.getOrderById(userId!, orderId);

      if (!order) return res.status(404).json(err('ORDER_NOT_FOUND'));

      return res.json(ok(order));
    } catch (error) {
      console.error(error);
      return res.status(500).json(err('INTERNAL_SERVER_ERROR'));
    }
  }

  async createOrder(req: Request, res: Response) {
    try {
      const userId = req.user?.userId;
      if (!userId) return res.status(401).json(err('UNAUTHORIZED'));

      const parsed = CreateOrderSchema.parse(req.body);

      const newOrder = await orderService.createOrder(userId, parsed);

      return res.status(201).json(ok(newOrder));
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json(err('INVALID_BODY', error.message));
      }
      console.error(error);
      return res.status(500).json(err('INTERNAL_SERVER_ERROR'));
    }
  }
}

export const orderController = new OrderController();
