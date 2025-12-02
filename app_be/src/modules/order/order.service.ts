import { getPrisma } from '../../common/prisma';
import type { CreateOrderDto } from './order.dto';

export class OrderService {
  private prisma = getPrisma();

  async getOrdersByUser(userId: number, status?: string) {
    return this.prisma.order.findMany({
      where: {
        userId,
        ...(status && { status }),
      },
      include: {
        orderItems: {
          include: {
            product: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });
  }

  async getOrderById(userId: number, orderId: number) {
    return this.prisma.order.findFirst({
      where: { id: orderId, userId },
      include: {
        orderItems: { include: { product: true } },
        payments: true,
      },
    });
  }

  async createOrder(userId: number, data: CreateOrderDto) {
    const { firstName, lastName, address, usedPoints, items } = data;

    const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);

    const earnedPoints = Math.floor(total * 0.1);

    return this.prisma.order.create({
      data: {
        userId,
        first_name: firstName,
        last_name: lastName,
        address,
        total,
        usedPoints,
        earnedPoints,
        status: 'PENDING',
        orderItems: {
          create: items.map((item) => ({
            productId: item.productId,
            quantity: item.quantity,
            size: item.size,
            price: item.price,
          })),
        },
      },
      include: {
        orderItems: true,
      },
    });
  }
}

export const orderService = new OrderService();
