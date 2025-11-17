import type { Request, Response } from 'express';
import { cartService } from './cart.service';
import { AddCartItemSchema, ToggleSelectionSchema, UpdateQuantitySchema } from './cart.schema';

export const CartController = {
  // GET /cart
  async getCart(req: Request, res: Response) {
    try {
      const userId = req.user!.userId;
      const cart = await cartService.getCart(userId);
      return res.json(cart);
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(500).json({ error: error.message });
      }
      return res.status(500).json({ error: 'Unknown error' });
    }
  },

  // POST /cart
  async addItem(req: Request, res: Response) {
    const parsed = AddCartItemSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json(parsed.error);
    }

    try {
      const userId = req.user!.userId;
      const item = await cartService.addItem(userId, parsed.data);
      return res.status(201).json(item);
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(500).json({ error: error.message });
      }
      return res.status(500).json({ error: 'Unknown error' });
    }
  },

  // PATCH /cart/:itemId/quantity
  async updateQuantity(req: Request, res: Response) {
    const itemId = Number(req.params.itemId);

    const parsed = UpdateQuantitySchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json(parsed.error);
    }

    try {
      const updated = await cartService.updateQuantity(itemId, parsed.data.quantity);
      return res.json(updated);
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(404).json({ error: error.message });
      }
      return res.status(404).json({ error: 'Unknown error' });
    }
  },

  // PATCH /cart/:itemId/select
  async toggleSelection(req: Request, res: Response) {
    const itemId = Number(req.params.itemId);

    const parsed = ToggleSelectionSchema.safeParse(req.body);
    if (!parsed.success) {
      return res.status(400).json(parsed.error);
    }

    try {
      const updated = await cartService.toggleSelection(itemId, parsed.data.isSelected);
      return res.json(updated);
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(404).json({ error: error.message });
      }
      return res.status(404).json({ error: 'Unknown error' });
    }
  },

  // DELETE /cart/:itemId
  async removeItem(req: Request, res: Response) {
    const itemId = Number(req.params.itemId);

    try {
      const deleted = await cartService.removeItem(itemId);
      return res.json(deleted);
    } catch (error: unknown) {
      if (error instanceof Error) {
        return res.status(404).json({ error: error.message });
      }
      return res.status(404).json({ error: 'Unknown error' });
    }
  },
};
