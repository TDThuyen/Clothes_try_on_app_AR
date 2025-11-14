export interface SuccessResponse<T> {
  success: true;
  message?: string;
  data: T;
}

export interface ErrorResponse {
  success: false;
  errorCode: string;
  message?: string;
}

export type ApiResponse<T> = SuccessResponse<T> | ErrorResponse;
