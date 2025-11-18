import type { z } from 'zod';
import type { AddCartItemSchema } from './cart.schema';

export type AddCartItemDto = z.infer<typeof AddCartItemSchema>;
