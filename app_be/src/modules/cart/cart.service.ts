import type { AddCartItemDto } from './cart.dto';
import { getPrisma } from '../../common/prisma';

export class CartService {
  private prisma = getPrisma();

  // Get cart by userId
  async getCart(userId: number) {
    return this.prisma.cart.findFirst({
      where: { userId },
      include: {
        cartItems: {
          include: {
            product: true,
          },
        },
      },
    });
  }

  // Add item to cart
  async addItem(userId: number, item: AddCartItemDto) {
    // Find or create cart for user
    let cart = await this.prisma.cart.findFirst({ where: { userId } });

    if (!cart) {
      cart = await this.prisma.cart.create({
        data: { userId },
      });
    }

    // Check if cart item already exists (same product + same size)
    const existingItem = await this.prisma.cartItem.findFirst({
      where: {
        cartId: cart.id,
        productId: item.productId,
        size: item.size ?? undefined,
      },
    });

    if (existingItem) {
      // If found → increase quantity
      return this.prisma.cartItem.update({
        where: { id: existingItem.id },
        data: {
          quantity: existingItem.quantity + item.quantity,
        },
      });
    }

    // Otherwise create new cart item
    return this.prisma.cartItem.create({
      data: {
        cartId: cart.id,
        productId: item.productId,
        quantity: item.quantity,
        size: item.size,
        price: item.price,
      },
    });
  }

  // Update quantity of a cart item
  async updateQuantity(cartItemId: number, quantity: number) {
    return this.prisma.cartItem.update({
      where: { id: cartItemId },
      data: { quantity },
    });
  }

  // Toggle selection of a cart item
  async toggleSelection(cartItemId: number, isSelected: boolean) {
    return this.prisma.cartItem.update({
      where: { id: cartItemId },
      data: { isSelected },
    });
  }

  // Remove item from cart
  async removeItem(cartItemId: number) {
    return this.prisma.cartItem.delete({
      where: { id: cartItemId },
    });
  }
}
export const cartService = new CartService();
