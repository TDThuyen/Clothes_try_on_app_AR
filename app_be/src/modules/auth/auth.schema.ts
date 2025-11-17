import { z } from 'zod';

export const RegisterSchema = z.object({
  email: z.string().email({ message: 'EMAIL_INVALID' }),
  password: z.string().min(6, { message: 'PASSWORD_TOO_SHORT' }),
  name: z.string().min(1, { message: 'NAME_REQUIRED' }),
});

export const LoginSchema = z.object({
  email: z.string().email({ message: 'EMAIL_INVALID' }),
  password: z.string().min(1, { message: 'PASSWORD_REQUIRED' }),
});

export const RefreshTokenSchema = z.object({
  refreshToken: z.string().min(1, { message: 'REFRESH_TOKEN_REQUIRED' }),
});

export const VerifyOtpSchema = z.object({
  userId: z.number(),
  otp: z.string().length(6),
});
