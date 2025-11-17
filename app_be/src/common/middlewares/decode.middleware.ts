import type { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../utils/jwt';

export function decodeMiddleware(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'No token provided' });
  }

  const token = header.split(' ')[1];

  try {
    const decoded = verifyAccessToken(token);

    // gắn userId vào req để OrderController dùng
    (req as any).userId = decoded.userId;

    return next();
  } catch (error) {
    console.error('JWT error:', error);
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
}
