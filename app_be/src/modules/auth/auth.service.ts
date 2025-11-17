import { UserService } from '../user/user.service';
import { hashPassword, comparePassword } from '../../common/utils/password';
import {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
} from '../../common/utils/jwt';
import type { TokenPayload } from '../../common/types/payload.type';
import { OtpService } from '../../common/services/otp.service';

export class AuthService {
  private userService = new UserService();
  private otpService = new OtpService();

  async register(email: string, password: string, name: string): Promise<{ id: number }> {
    const passwordHash = await hashPassword(password);
    const user = await this.userService.createUser(email, passwordHash, name);

    await this.otpService.generateAndSendOtp(user.id, user.email);

    return user;
  }

  async verifyOtp(userId: number, otp: string): Promise<void> {
    await this.otpService.verifyOtp(userId, otp);
  }

  async login(
    email: string,
    password: string,
  ): Promise<{
    accessToken: string;
    refreshToken: string;
  }> {
    const user = await this.userService.findByEmail(email);
    if (!user) {
      throw new Error('USER_NOT_FOUND');
    }

    const isValid = await comparePassword(password, user.password);
    if (!isValid) {
      throw new Error('INVALID_PASSWORD');
    }

    const payload: TokenPayload = { userId: user.id };
    const accessToken = signAccessToken(payload);
    const refreshToken = signRefreshToken(payload);

    await this.userService.updateRefreshToken(user.id, refreshToken);

    return {
      accessToken,
      refreshToken,
    };
  }

  async refresh(refreshToken: string): Promise<{ accessToken: string }> {
    try {
      const payload = verifyRefreshToken(refreshToken) as TokenPayload;

      const newAccess = signAccessToken({
        userId: payload.userId,
      });

      return { accessToken: newAccess };
    } catch {
      throw new Error('INVALID_REFRESH_TOKEN');
    }
  }

  async updateRefreshToken(userId: number, refreshToken: string): Promise<void> {
    await this.userService.updateRefreshToken(userId, refreshToken);
  }
}
