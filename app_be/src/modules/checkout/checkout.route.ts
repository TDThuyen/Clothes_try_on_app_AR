// src/modules/checkout/checkout.route.ts

import { Router } from 'express';
import { CheckoutController } from './checkout.controller';
import { DecodeMiddleware } from '../../common/middlewares/decode.middleware';

const router = Router();

// POST /checkout
router.post('/', DecodeMiddleware, CheckoutController.create);

export default router;
