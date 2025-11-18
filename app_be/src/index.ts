import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

// Routes
import authRoutes from './modules/auth/auth.route';
import productRoutes from './modules/product/product.route';
import cartRoutes from './modules/cart/cart.route';
import checkoutRoutes from './modules/checkout/checkout.route';
import orderRoutes from './modules/order/order.route'; 

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
app.use((req, _res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} from ${req.ip}`);
  next();
});

// --- Health check ---
app.get('/health', (_req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// --- Auth ---
app.use('/auth', authRoutes);

// --- Products ---
app.use('/api/products', productRoutes);

// --- Cart ---
app.use('/cart', cartRoutes);

// --- Checkout ---
app.use('/checkout', checkoutRoutes);

// --- Orders (route của bạn) ---
app.use('/api/orders', orderRoutes);  // <-- giữ chuẩn REST

// --- Start server ---
const PORT = parseInt(process.env.PORT || '8080', 10);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server started on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`Products API: http://localhost:${PORT}/api/products`);
  console.log(`Orders API: http://localhost:${PORT}/api/orders`);
});
