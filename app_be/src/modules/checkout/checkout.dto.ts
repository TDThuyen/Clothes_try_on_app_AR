// src/modules/checkout/checkout.dto.ts

export interface ShippingAddressDto {
  firstName: string;
  lastName: string;
  country: string;
  streetName: string;
  city: string;
  stateProvince?: string;
  zipCode: string;
  phoneNumber: string;
}

export interface CheckoutDto {
  shippingAddress: ShippingAddressDto;
  paymentMethod: 'cash' | 'qr';
  shippingMethod: 'free' | 'standard' | 'fast';
  couponCode?: string;
}
