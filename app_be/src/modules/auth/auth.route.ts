import { Router } from 'express';
import { AuthController } from './auth.controller';
import { validate } from '../../common/middlewares/validate.middleware';
import {
  RegisterSchema,
  LoginSchema,
  RefreshTokenSchema,
  VerifyOtpSchema,
} from './auth.schema';

const router = Router();
const controller = new AuthController();

router.post('/register', validate(RegisterSchema), (req, res) => controller.register(req, res));
router.post('/login', validate(LoginSchema), (req, res) => controller.login(req, res));
router.post('/refresh', validate(RefreshTokenSchema), (req, res) => controller.refresh(req, res));
router.post('/verify-otp', validate(VerifyOtpSchema), (req, res) => controller.verifyOtp(req, res));

export default router;
