// src/modules/checkout/checkout.controller.ts

import type { Request, Response } from 'express';
import { CheckoutSchema } from './checkout.schema';
import { checkoutService } from './checkout.service';

export const CheckoutController = {
  async create(req: Request, res: Response) {
    const userId = req.user?.userId;

    if (!userId) {
      return res.status(401).json({ error: 'UNAUTHORIZED' });
    }

    const parsed = CheckoutSchema.safeParse(req.body);

    if (!parsed.success) {
      return res.status(400).json(parsed.error);
    }

    try {
      const order = await checkoutService.createOrder(userId, parsed.data);
      return res.status(201).json({ success: true, order });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: 'ORDER_CREATION_FAILED' });
    }
  },
};
