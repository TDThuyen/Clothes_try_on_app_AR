import { Router } from 'express';
import { productController } from './product.controller';

const router = Router();

// GET /product?q=...&minPrice=...&maxPrice=...&categoryName=...&gender=...
router.get('/', (req, res) => productController.searchProducts(req, res));

export default router;
