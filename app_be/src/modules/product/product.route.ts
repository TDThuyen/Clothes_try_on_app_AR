import { Router } from 'express';
import { productController } from './product.controller';

const router = Router();

router.get('/', (req, res) => productController.getAllProducts(req, res));
router.get('/search', (req, res) => productController.searchProducts(req, res));

export default router;
