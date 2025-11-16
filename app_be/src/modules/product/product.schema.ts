import { z } from 'zod';

export const searchProductsSchema = z.object({
  // text search theo tên / mô tả
  q: z.string().trim().min(1).optional(),

  // lọc theo khoảng giá
  minPrice: z
    .coerce.number() // convert từ query string -> number
    .min(0)
    .optional(),
  maxPrice: z.coerce.number().min(0).optional(),

  // lọc theo category id (bảng products có category_id)
  categoryId: z.coerce.number().int().min(1).optional(),

  // lọc theo gender (trong DB là VARCHAR(10))
  // bạn có thể thay enum này cho đúng với data thực tế của mình
  gender: z.enum(['male', 'female']).optional(),

  // pagination
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),

  // sort
  sortBy: z
    .enum(['newest', 'price_asc', 'price_desc'])
    .default('newest')
    .optional(),
});

export type SearchProductsQuery = z.infer<typeof searchProductsSchema>;
