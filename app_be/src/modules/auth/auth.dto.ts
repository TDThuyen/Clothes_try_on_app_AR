import type { z } from 'zod';
import type {
  RegisterSchema,
  LoginSchema,
  RefreshTokenSchema,
  VerifyOtpSchema,
} from './auth.schema';

export type RegisterBodyDto = z.infer<typeof RegisterSchema>;
export type LoginBodyDto = z.infer<typeof LoginSchema>;
export type RefreshTokenBodyDto = z.infer<typeof RefreshTokenSchema>;
export type VerifyOtpBodyDto = z.infer<typeof VerifyOtpSchema>;

export interface RegisterResponseDto {
  id: number;
}

export interface LoginResponseDto {
  accessToken: string;
  refreshToken: string;
}

export interface RefreshTokenResponseDto {
  accessToken: string;
}

export interface VerifyOtpResponseDto {
  verified: boolean;
  accessToken: string;
  refreshToken: string;
}
