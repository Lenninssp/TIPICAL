import type { Context } from "hono";
import { ZodError } from "zod";
import { invalidInputResponse } from "../features/shared/responses/invalidInputResponse";

type ResultType = { success: false; error: ZodError<unknown>} | { success: true; data: any; };

/**
 * Middleware handle zod errors
 */

export const zodErrorMiddleware = (result: ResultType, c: Context) => {
  if (!result.success && 'error' in result && result.error instanceof ZodError) {
    return invalidInputResponse(c, result.error.issues)
  }
}