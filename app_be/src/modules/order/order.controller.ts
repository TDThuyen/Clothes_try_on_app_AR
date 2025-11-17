import type { Request, Response } from 'express';
import { OrderService } from './order.service';

export class OrderController {
  private orderService = new OrderService();

  async getMyOrders(req: Request, res: Response) {
    const userId = (req as any).userId; // ⬅ LẤY USER ID ĐÃ DECODE

    const orders = await this.orderService.getOrdersByUserId(userId);

    return res.json({
      success: true,
      data: orders,
      message: 'Orders fetched successfully'
    });
  }
}
