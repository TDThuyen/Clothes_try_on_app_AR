import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
dotenv.config();

import authRoutes from './modules/auth/auth.route';
import cartRoutes from './modules/cart/cart.route';
import checkoutRoutes from './modules/checkout/checkout.route';
import productRoutes from './modules/product/product.route';
import orderRouts from './modules/order/order.routes';

const app = express();

app.use(
  cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }),
);

app.use(express.json());

// Logging middleware
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} from ${req.ip}`);
  next();
});

// Routes
app.use('/auth', authRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

app.use('/api/products', productRoutes);
app.use('/cart', cartRoutes); // <-- MOUNT ROUTE
app.use('/checkout', checkoutRoutes); // <-- MOUNT ROUTE
app.use('/orders', orderRouts);

// Start server
const PORT = parseInt(process.env.PORT || '3000', 10);
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server started on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`Network access: http://192.168.1.9:${PORT}/health`);
  console.log(`Products API: http://localhost:${PORT}/api/products`);
});
