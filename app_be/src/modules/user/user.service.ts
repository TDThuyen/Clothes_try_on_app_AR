import { getPrisma } from '../../common/prisma';

export class UserService {
  private prisma = getPrisma();

  async createUser(
    email: string,
    passwordHash: string,
    name: string,
  ): Promise<{ id: number; email: string }> {
    const existing = await this.prisma.user.findUnique({ where: { email } });

    if (existing) {
      throw new Error('EMAIL_ALREADY_EXISTS');
    }

    return this.prisma.user.create({
      data: { email, password: passwordHash, name },
      select: { id: true, email: true },
    });
  }

  async findByEmail(email: string): Promise<{ id: number; password: string } | null> {
    return this.prisma.user.findUnique({
      where: { email },
      select: { id: true, password: true },
    });
  }

  async findById(id: number) {
    return this.prisma.user.findUnique({
      where: { id },
    });
  }

  async updateRefreshToken(userId: number, refreshToken: string): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        token: refreshToken,
        tokenExpiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      },
    });
  }
}
