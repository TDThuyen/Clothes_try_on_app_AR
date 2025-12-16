import { Router } from 'express';
import { AuthController } from './auth.controller';
import { validate } from '../../common/middlewares/validate.middleware';
import { DecodeMiddleware } from '../../common/middlewares/decode.middleware';

import { RegisterSchema, LoginSchema, RefreshTokenSchema, VerifyOtpSchema } from './auth.schema';

const router = Router();
const controller = new AuthController();

// Register
router.post('/register', validate(RegisterSchema), (req, res) => controller.register(req, res));

// Login
router.post('/login', validate(LoginSchema), (req, res) => controller.login(req, res));

// Refresh token
router.post('/refresh', validate(RefreshTokenSchema), (req, res) => controller.refresh(req, res));

// Verify OTP
router.post('/verify-otp', validate(VerifyOtpSchema), (req, res) => controller.verifyOtp(req, res));

router.get('/me', DecodeMiddleware, (req, res) => controller.getMe(req, res));

export default router;
