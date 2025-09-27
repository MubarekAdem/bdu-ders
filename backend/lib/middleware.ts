import { NextRequest, NextResponse } from "next/server";
import { verifyToken } from "./auth";

export interface AuthenticatedRequest extends NextRequest {
  user?: {
    id: string;
    email: string;
    phone: string;
    role: string;
  };
}

export function authenticateToken(
  handler: (req: AuthenticatedRequest, context?: any) => Promise<NextResponse>
) {
  return async (req: NextRequest, context?: any) => {
    try {
      const authHeader = req.headers.get("authorization");
      const token = authHeader && authHeader.split(" ")[1];

      if (!token) {
        return NextResponse.json(
          { error: "Access token required" },
          { status: 401 }
        );
      }

      const decoded = verifyToken(token);
      (req as AuthenticatedRequest).user = decoded;

      return handler(req as AuthenticatedRequest, context);
    } catch (error) {
      return NextResponse.json({ error: "Invalid token" }, { status: 401 });
    }
  };
}

export function requireAdmin(
  handler: (req: AuthenticatedRequest, context?: any) => Promise<NextResponse>
) {
  return authenticateToken(async (req: AuthenticatedRequest, context?: any) => {
    if (req.user?.role !== "admin") {
      return NextResponse.json(
        { error: "Admin access required" },
        { status: 403 }
      );
    }
    return handler(req, context);
  });
}
