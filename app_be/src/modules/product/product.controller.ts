import type { Request, Response } from 'express';
// SỬA LẠI IMPORT CHO ĐÚNG
import { productService, getAllProducts } from './product.service';
import { SearchProductsQuerySchema } from './product.schema';
import { ZodError } from 'zod';
import { err, ok } from '../../common/utils/response';

export class ProductController {
  async searchProducts(req: Request, res: Response) {
    try {
      const params = SearchProductsQuerySchema.parse(req.query);
      // Gọi phương thức từ instance `productService` đã import
      const result = await productService.searchProducts(params);
      // Trả về dữ liệu nhất quán bằng hàm `ok()`
      return res.json(ok(result));
    } catch (e) {
      if (e instanceof ZodError) {
        return res.status(400).json(err('INVALID_QUERY_PARAMS', 'Invalid query parameters'));
      }
      console.error('Search Products Error:', e); // Log lỗi ra để debug
      return res.status(500).json(err('INTERNAL_SERVER_ERROR', 'Something went wrong'));
    }
  }

  async getAllProducts(req: Request, res: Response) {
    try {
      // Gọi hàm `getAllProducts` đã được export riêng
      const products = await getAllProducts();
      return res.json(ok(products));
    } catch (e) {
      console.error('Get All Products Error:', e); // Log lỗi ra để debug
      return res.status(500).json(err('INTERNAL_SERVER_ERROR', 'Something went wrong'));
    }
  }
}

export const productController = new ProductController();
