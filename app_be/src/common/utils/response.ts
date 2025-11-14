import type { SuccessResponse, ErrorResponse } from '../types/response.type';

export function ok<T>(data: T, message?: string): SuccessResponse<T> {
  return {
    message,
    success: true,
    data,
  };
}

export function err(errorCode: string, message?: string): ErrorResponse {
  return {
    success: false,
    errorCode,
    message,
  };
}
