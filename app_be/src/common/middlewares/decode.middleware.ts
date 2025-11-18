import type { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export function DecodeMiddleware(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No token provided' });
  }

  const token = header.split(' ')[1];

  try {
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
  }
}