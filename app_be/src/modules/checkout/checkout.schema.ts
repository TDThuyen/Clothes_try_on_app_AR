// src/modules/checkout/checkout.schema.ts

import { z } from 'zod';

export const ShippingAddressSchema = z.object({
  firstName: z.string(),
  lastName: z.string(),
  country: z.string(),
  streetName: z.string(),
  city: z.string(),
  stateProvince: z.string().optional(),
  zipCode: z.string(),
  phoneNumber: z.string(),
});

export const CheckoutSchema = z.object({
  shippingAddress: ShippingAddressSchema,
  paymentMethod: z.enum(['cash', 'qr']),
  shippingMethod: z.enum(['free', 'standard', 'fast']),
  couponCode: z.string().optional(),
});
