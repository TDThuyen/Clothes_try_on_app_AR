import type { Request, Response } from 'express';
import { productService } from './product.service';
import { SearchProductsQuerySchema } from './product.schema';
import { ZodError } from 'zod';
import { err } from '../../common/utils/response';

export class ProductController {
  async searchProducts(req: Request, res: Response) {
    try {
      const params = SearchProductsQuerySchema.parse(req.query);
      const result = await productService.searchProducts(params);
      return res.json(result);
    } catch (e) {
      if (e instanceof ZodError) {
        return res.status(400).json(err('INVALID_QUERY_PARAMS', 'Invalid query parameters'));
      }

      return res.status(500).json(err('INTERNAL_SERVER_ERROR', 'Something went wrong'));
    }
  }
}

export const productController = new ProductController();
