import { NextRequest, NextResponse } from "next/server";
import { verifyToken } from "../../../../../lib/auth";

// GET /api/auth/me - Get current user info
export async function GET(request: NextRequest) {
  try {
    const authHeader = request.headers.get("authorization");
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      return NextResponse.json(
        { error: "Access token required" },
        { status: 401 }
      );
    }

    const decoded = verifyToken(token);

    return NextResponse.json({
      user: {
        id: decoded.id,
        name: decoded.name,
        email: decoded.email,
        phone: decoded.phone,
        role: decoded.role,
      },
    });
  } catch (error) {
    console.error("Get user error:", error);
    return NextResponse.json({ error: "Invalid token" }, { status: 401 });
  }
}
