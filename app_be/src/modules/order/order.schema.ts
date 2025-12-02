import { z } from 'zod';

export const CreateOrderSchema = z.object({
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  address: z.string().min(1),
  usedPoints: z.number().int().min(0).default(0),
  items: z
    .array(
      z.object({
        productId: z.number().int().positive(),
        quantity: z.number().int().positive(),
        size: z.string().min(1),
        price: z.number().positive(),
      }),
    )
    .nonempty(),
});

export const GetOrdersQuerySchema = z.object({
  status: z.enum(['PENDING', 'DELIVERED', 'CANCELLED']).optional(),
});
