    export interface CreateOrderItemDto {
      productId: number;
      quantity: number;
      size: string;
      price: number;
    }

    export interface CreateOrderDto {
      firstName: string;
      lastName: string;
      address: string;
      usedPoints: number;
      items: CreateOrderItemDto[];
    }
