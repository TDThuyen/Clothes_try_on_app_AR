import { z } from 'zod';

export const SearchProductsQuerySchema = z.object({
  q: z.string().trim().optional(),

  minPrice: z.preprocess(
    (v) => (v === undefined || v === '' ? undefined : Number(v)),
    z.number().nonnegative().optional(),
  ),

  maxPrice: z.preprocess(
    (v) => (v === undefined || v === '' ? undefined : Number(v)),
    z.number().nonnegative().optional(),
  ),

  categoryId: z.preprocess(
    (v) => (v === undefined || v === '' ? undefined : Number(v)),
    z.number().int().positive().optional(),
  ),

  categoryName: z.string().trim().optional(),

  gender: z.string().trim().optional(),

  page: z
    .preprocess((v) => (v === undefined || v === '' ? 1 : Number(v)), z.number().int().positive())
    .optional(),

  limit: z
    .preprocess(
      (v) => (v === undefined || v === '' ? 20 : Number(v)),
      z.number().int().positive().max(100),
    )
    .optional(),

  sortBy: z.enum(['newest', 'price_asc', 'price_desc']).optional().default('newest'),
});
