import type { Request, Response } from 'express';
import { AuthService } from './auth.service';
import { signAccessToken, signRefreshToken } from '../../common/utils/jwt';

import type {
  RegisterBodyDto,
  LoginBodyDto,
  RefreshTokenBodyDto,
  RegisterResponseDto,
  LoginResponseDto,
  RefreshTokenResponseDto,
  VerifyOtpBodyDto,
  VerifyOtpResponseDto,
} from './auth.dto';

import type { ApiResponse } from '../../common/types/response.type';
import { ok, err } from '../../common/utils/response';

export class AuthController {
  private authService = new AuthService();

  async register(req: Request, res: Response): Promise<Response<ApiResponse<RegisterResponseDto>>> {
    try {
      const { email, password, name } = req.body as RegisterBodyDto;
      const result = await this.authService.register(email, password, name);

      return res.status(201).json(ok<RegisterResponseDto>(result, 'User registered successfully'));
    } catch (error) {
      console.log(error);
      if (error instanceof Error && error.message === 'EMAIL_ALREADY_EXISTS') {
        return res.status(409).json(err('EMAIL_ALREADY_EXISTS', 'Email already exists'));
      }

      return res.status(500).json(err('INTERNAL_SERVER_ERROR', 'Something went wrong'));
    }
  }

  async login(req: Request, res: Response): Promise<Response<ApiResponse<LoginResponseDto>>> {
    try {
      const { email, password } = req.body as LoginBodyDto;
      const tokens = await this.authService.login(email, password);

      return res.json(ok<LoginResponseDto>(tokens, 'Login successful'));
    } catch (error) {
      if (error instanceof Error) {
        switch (error.message) {
          case 'USER_NOT_FOUND':
            return res.status(404).json(err('USER_NOT_FOUND', 'User not found'));
          case 'INVALID_PASSWORD':
            return res.status(401).json(err('INVALID_PASSWORD', 'Invalid password'));
        }
      }

      return res.status(500).json(err('INTERNAL_SERVER_ERROR', 'Something went wrong'));
    }
  }

  async refresh(
    req: Request,
    res: Response,
  ): Promise<Response<ApiResponse<RefreshTokenResponseDto>>> {
    try {
      const { refreshToken } = req.body as RefreshTokenBodyDto;
      const result = await this.authService.refresh(refreshToken);

      return res.json(ok<RefreshTokenResponseDto>(result, 'Token refreshed'));
    } catch (error) {
      if (error instanceof Error && error.message === 'INVALID_REFRESH_TOKEN') {
        return res.status(401).json(err('INVALID_REFRESH_TOKEN', 'Refresh token is invalid'));
      }

      return res.status(500).json(err('INTERNAL_SERVER_ERROR', 'Something went wrong'));
    }
  }

  async verifyOtp(
    req: Request,
    res: Response,
  ): Promise<Response<ApiResponse<VerifyOtpResponseDto>>> {
    try {
      const { userId, otp } = req.body as VerifyOtpBodyDto;

      // 1. Verify OTP
      await this.authService.verifyOtp(userId, otp);

      // 2. Generate tokens
      const payload = { userId };
      const accessToken = signAccessToken(payload);
      const refreshToken = signRefreshToken(payload);

      // 3. Update refreshToken trong DB
      await this.authService.updateRefreshToken(userId, refreshToken);

      return res.json(
        ok<VerifyOtpResponseDto>(
          {
            verified: true,
            accessToken,
            refreshToken,
          },
          'OTP verified & logged in',
        ),
      );
    } catch (error) {
      if (error instanceof Error) {
        switch (error.message) {
          case 'OTP_NOT_FOUND':
          case 'OTP_INVALID':
          case 'OTP_EXPIRED':
            return res.status(401).json(err(error.message, 'OTP invalid or expired'));
        }
      }

      return res.status(500).json(err('INTERNAL_SERVER_ERROR', 'Something went wrong'));
    }
  }
}
