import jwt from 'jsonwebtoken';
import type { TokenPayload } from '../types/payload.type';

const ACCESS_TOKEN_SECRET = process.env.ACCESS_TOKEN_SECRET || 'ACCESS_TOKEN_SECRET';
const REFRESH_TOKEN_SECRET = process.env.REFRESH_TOKEN_SECRET || 'REFRESH_TOKEN_SECRET';

const ACCESS_EXPIRES_IN = Number(process.env.ACCESS_TOKEN_EXPIRES_IN ?? 900); // 15 phút
const REFRESH_EXPIRES_IN = Number(process.env.REFRESH_TOKEN_EXPIRES_IN ?? 2592000); // 30 ngày

export function signAccessToken(payload: TokenPayload): string {
  console.log('[JWT] signAccessToken with secret =', ACCESS_TOKEN_SECRET);
  return jwt.sign(payload, ACCESS_TOKEN_SECRET, { expiresIn: ACCESS_EXPIRES_IN });
}

export function signRefreshToken(payload: TokenPayload): string {
  console.log('[JWT] signRefreshToken with secret =', REFRESH_TOKEN_SECRET);
  return jwt.sign(payload, REFRESH_TOKEN_SECRET, { expiresIn: REFRESH_EXPIRES_IN });
}

export function verifyAccessToken(token: string): TokenPayload {
  try {
    console.log('[JWT] verifyAccessToken with secret =', ACCESS_TOKEN_SECRET);
    return jwt.verify(token, ACCESS_TOKEN_SECRET) as TokenPayload;
  } catch (e) {
    console.error('[JWT] verifyAccessToken error:', e);
    throw new Error('INVALID_ACCESS_TOKEN');
  }
}

export function verifyRefreshToken(token: string): TokenPayload {
  try {
    return jwt.verify(token, REFRESH_TOKEN_SECRET) as TokenPayload;
  } catch {
    throw new Error('INVALID_REFRESH_TOKEN');
  }
}
