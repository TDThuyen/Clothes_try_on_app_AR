import { Router } from 'express';
import { CartController } from './cart.controller';
import { DecodeMiddleware } from '../../common/middlewares/decode.middleware';

const router = Router();

// GET /cart
router.get('/', DecodeMiddleware, CartController.getCart);

// POST /cart
router.post('/', DecodeMiddleware, CartController.addItem);

// PATCH /cart/:itemId/quantity
router.patch('/:itemId/quantity', DecodeMiddleware, CartController.updateQuantity);

// PATCH /cart/:itemId/select
router.patch('/:itemId/select', DecodeMiddleware, CartController.toggleSelection);

// DELETE /cart/:itemId
router.delete('/:itemId', DecodeMiddleware, CartController.removeItem);

export default router;
