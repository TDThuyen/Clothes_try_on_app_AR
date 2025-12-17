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
    console.log('🛒 [ADD TO CART] userId:', userId);
    console.log('📦 Item received:', item);

    // Find or create cart for user
    let cart = await this.prisma.cart.findFirst({
      where: { userId },
    });

    console.log('🔍 Existing cart:', cart);

    if (!cart) {
      console.log('➕ No cart found → creating new cart');
      cart = await this.prisma.cart.create({
        data: { userId },
      });
      console.log('✅ New cart created:', cart);
    }

    // Check if cart item already exists (same product + same size)
    const existingItem = await this.prisma.cartItem.findFirst({
      where: {
        cartId: cart.id,
        productId: item.productId,
        size: item.size ?? undefined,
      },
    });

    console.log('🔎 Existing cart item:', existingItem);

    if (existingItem) {
      console.log(
        `🔁 Item exists → updating quantity (${existingItem.quantity} + ${item.quantity})`,
      );

      const updatedItem = await this.prisma.cartItem.update({
        where: { id: existingItem.id },
        data: {
          quantity: existingItem.quantity + item.quantity,
        },
      });

      console.log('✅ Cart item updated:', updatedItem);
      return updatedItem;
    }

    console.log('🆕 Creating new cart item');

    const newItem = await this.prisma.cartItem.create({
      data: {
        cartId: cart.id,
        productId: item.productId,
        quantity: item.quantity,
        size: item.size,
        price: item.price,
      },
    });

    console.log('✅ New cart item created:', newItem);
    return newItem;
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
