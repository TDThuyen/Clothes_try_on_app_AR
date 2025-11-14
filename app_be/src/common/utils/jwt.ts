import jwt from 'jsonwebtoken';
import type { TokenPayload } from '../types/payload.type';

const ACCESS_SECRET = process.env.ACCESS_TOKEN_SECRET as string;
const ACCESS_EXPIRES_IN = Number(process.env.ACCESS_TOKEN_EXPIRES_IN ?? 900);
const REFRESH_SECRET = process.env.REFRESH_TOKEN_SECRET as string;
const REFRESH_EXPIRES_IN = Number(process.env.REFRESH_TOKEN_EXPIRES_IN ?? 2592000);

export function signAccessToken(payload: TokenPayload): string {
  const options = { expiresIn: ACCESS_EXPIRES_IN };
  return jwt.sign(payload, ACCESS_SECRET, options);
}

export function signRefreshToken(payload: TokenPayload): string {
  const options = { expiresIn: REFRESH_EXPIRES_IN };
  return jwt.sign(payload, REFRESH_SECRET, options);
}

export function verifyAccessToken(token: string): TokenPayload {
  try {
    return jwt.verify(token, ACCESS_SECRET) as TokenPayload;
  } catch {
    throw new Error('INVALID_ACCESS_TOKEN');
  }
}

export function verifyRefreshToken(token: string): TokenPayload {
  try {
    return jwt.verify(token, REFRESH_SECRET) as TokenPayload;
  } catch {
    throw new Error('INVALID_REFRESH_TOKEN');
  }
}
