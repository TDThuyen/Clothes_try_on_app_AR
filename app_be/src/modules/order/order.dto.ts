export interface OrderListItemDto {
  id: number;
  trackingNumber: string;
  quantity: number;
  subtotal: number;
  date: string; // ISO
  status: string; // PENDING / DELIVERED / CANCELLED
}
