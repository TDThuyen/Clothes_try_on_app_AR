// src/modules/products/product.controller.ts
import { Request, Response, NextFunction } from 'express';
import { productService } from './product.service';
import { searchProductsQuerySchema } from './product.dto';
import { ZodError } from 'zod';

export class ProductController {
  async searchProducts(req: Request, res: Response, next: NextFunction) {
    try {
      const params = searchProductsQuerySchema.parse(req.query);
      const result = await productService.searchProducts(params);
      return res.json(result);
    } catch (err) {
      if (err instanceof ZodError) {
        return res.status(400).json({
          message: 'Invalid query params',
          errors: err.flatten(),
        });
      }
      return next(err);
    }
  }
}

export const productController = new ProductController();
