import { EmailService } from './email.service';
import { getPrisma } from '../prisma';

const emailService = new EmailService();

export class OtpService {
  async generateAndSendOtp(userId: number, email: string): Promise<void> {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    await getPrisma().user.update({
      where: { id: userId },
      data: {
        otp,
        otpExpiresAt: new Date(Date.now() + 5 * 60 * 1000),
      },
    });

    await emailService.sendEmail(
      email,
      'Your OTP Code',
      `<h1>Your OTP is: ${otp}</h1><p>Expires in 5 minutes.</p>`,
    );
  }

  async verifyOtp(userId: number, otp: string): Promise<void> {
    const user = await getPrisma().user.findUnique({
      where: { id: userId },
      select: { otp: true, otpExpiresAt: true },
    });

    if (!user?.otp) {
      throw new Error('OTP_NOT_FOUND');
    }

    if (user.otp !== otp) {
      throw new Error('OTP_INVALID');
    }

    if (user.otpExpiresAt && user.otpExpiresAt < new Date()) {
      throw new Error('OTP_EXPIRED');
    }

    await getPrisma().user.update({
      where: { id: userId },
      data: {
        otp: null,
        otpExpiresAt: null,
      },
    });
  }
}
