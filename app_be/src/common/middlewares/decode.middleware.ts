import type { Request, Response, NextFunction } from 'express';
<<<<<<< HEAD
import { verifyAccessToken } from '../utils/jwt';

export function decodeMiddleware(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'No token provided' });
=======
import jwt from 'jsonwebtoken';

export function DecodeMiddleware(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No token provided' });
>>>>>>> 4069e14fb82fa5f9c73de30ef0430dd4d86ec7c4
  }

  const token = header.split(' ')[1];

  try {
<<<<<<< HEAD
    const decoded = verifyAccessToken(token);

    // gắn userId vào req để OrderController dùng
    (req as any).userId = decoded.userId;

    return next();
  } catch (error) {
    console.error('JWT error:', error);
    return res.status(401).json({ message: 'Invalid or expired token' });
=======
    const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET!) as {
      userId: number;
    };

    // ✔ Attach decoded data to the request
    req.user = { userId: decoded.userId };

    return next();
  } catch (error: unknown) {
    if (error instanceof Error) {
      return res.status(401).json({ error: error.message });
    }
    return res.status(401).json({ error: 'Invalid token' });
>>>>>>> 4069e14fb82fa5f9c73de30ef0430dd4d86ec7c4
  }
}
