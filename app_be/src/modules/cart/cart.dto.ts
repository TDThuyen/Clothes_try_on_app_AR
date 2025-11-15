import type { z } from 'zod';
import type { AddCartItemSchema, CartItemSchema } from './cart.schema';

export type CartItemDto = z.infer<typeof CartItemSchema>;
export type AddCartItemDto = z.infer<typeof AddCartItemSchema>;
