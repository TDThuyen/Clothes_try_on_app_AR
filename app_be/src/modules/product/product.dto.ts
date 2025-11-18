import type { SearchProductsQuerySchema } from './product.schema';
import type { z } from 'zod';

export type SearchProductsQueryDto = z.infer<typeof SearchProductsQuerySchema>;

export interface Product {
  id: number;
  name: string;
  description: string;
  price: number;
  categoryId: number;
  gender: string;
  availableSizes: string;
  color: string;
  imageUrl: string;
  arModelUrl: string;
  ratingAvg: number;
  createdAt: string;
  updatedAt: string;
}

export interface PaginatedProductsResult {
  items: Product[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}
