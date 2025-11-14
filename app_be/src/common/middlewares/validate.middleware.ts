import type { Request, Response, NextFunction } from 'express';
import type { ZodType } from 'zod';
import type { ErrorResponse } from '../types/response.type';

export function validate(schema: ZodType<unknown>) {
  return (req: Request, res: Response<ErrorResponse>, next: NextFunction): void => {
    const result = schema.safeParse(req.body);

    if (!result.success) {
      const firstIssue = result.error.issues[0];

      res.status(400).json({
        success: false,
        errorCode: 'VALIDATION_ERROR',
        message: `${firstIssue.path.join('.')}: ${firstIssue.message}`,
      });

      return;
    }

    req.body = result.data;
    next();
  };
}
