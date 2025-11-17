import type { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../utils/jwt';

export function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;

  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'No token provided' });
  }

  const token = header.split(' ')[1];

  try {
    const decoded = verifyAccessToken(token) as { userId: number };

    (req as any).userId = decoded.userId; // ⬅ SET USER ID VÀO REQUEST

    next();
  } catch {
    return res.status(401).json({ message: 'Invalid token' });
  }
}
