// src/modules/product/product.routes.ts
import { Router } from 'express';
import { productController } from './product.controller';

const router = Router();

// GET /products/searchProduct?q=...&minPrice=...&maxPrice=...&categoryName=...&gender=...
router.get('/searchProduct', (req, res, next) =>
  productController.searchProducts(req, res, next),
);

export default router;
