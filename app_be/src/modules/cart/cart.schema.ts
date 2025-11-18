import { z } from 'zod';

export const AddCartItemSchema = z.object({
  price: z.number().positive(),
  size: z.string(),
  quantity: z.number().min(1),
  isSelected: z.boolean().optional().default(false),
  productId: z.number().positive(),
});

export const UpdateQuantitySchema = z.object({
  quantity: z.number().min(1),
});

export const ToggleSelectionSchema = z.object({
  isSelected: z.boolean(),
});
