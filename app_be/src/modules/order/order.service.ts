import { getPrisma } from '../../common/prisma';

export class OrderService {
  async getOrdersByUserId(userId: number) {
    return getPrisma().order.findMany({
      where: { userId: userId },
      orderBy: { createdAt: 'desc' }
    });
  }
}
