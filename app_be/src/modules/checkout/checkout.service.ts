// src/modules/checkout/checkout.service.ts

import { getPrisma } from '../../common/prisma';
import type { CheckoutDto } from './checkout.dto';

export class CheckoutService {
  private prisma = getPrisma();

  private formatAddress(address: CheckoutDto['shippingAddress']): string {
    return [
      address.streetName,
      address.city,
      address.stateProvince,
      address.country,
      address.zipCode,
      `Phone: ${address.phoneNumber}`,
    ]
      .filter((v) => v && v.trim() !== '')
      .join(', ');
  }

  async createOrder(userId: number, payload: CheckoutDto) {
    return await this.prisma.$transaction(async (tx) => {
      // 1. Get selected cart items
      const selectedItems = await tx.cartItem.findMany({
        where: { cart: { userId }, isSelected: true },
        include: { product: true },
      });

      if (selectedItems.length === 0) {
        throw new Error('No selected items to checkout.');
      }

      // 2. Calculate total from database, never trust frontend
      const total = selectedItems.reduce(
        (sum, item) => sum + (item.price ?? item.product.price) * item.quantity,
        0,
      );

      // 3. Create order
      const order = await tx.order.create({
        data: {
          userId,
          total,
          status: 'PENDING',
          address: this.formatAddress(payload.shippingAddress),
          first_name: payload.shippingAddress.firstName,
          last_name: payload.shippingAddress.lastName,
        },
      });

      // 4. Create order items
      for (const item of selectedItems) {
        await tx.orderItem.create({
          data: {
            orderId: order.id,
            productId: item.productId,
            quantity: item.quantity,
            size: item.size,
            price: item.price ?? item.product.price,
          },
        });
      }

      // 5. Remove selected cart items
      await tx.cartItem.deleteMany({
        where: { cart: { userId }, isSelected: true },
      });

      // 6. Create payment record
      await tx.payment.create({
        data: {
          orderId: order.id,
          userId,
          method: payload.paymentMethod,
          amount: total,
          status: 'UNPAID', // or "PENDING" if your DB uses that
        },
      });

      // 7. Return minimal response (frontend does not use QR)
      return {
        orderId: order.id,
        total,
        status: 'PENDING',
      };
    });
  }
}

export const checkoutService = new CheckoutService();
