import { NextRequest, NextResponse } from "next/server";
import { getDb } from "../../../../../lib/mongodb";
import { requireAdmin } from "../../../../../lib/middleware";
import { ObjectId } from "mongodb";

// PUT /api/admin/users/[id] - Update user role (admin only)
export const PUT = requireAdmin(
  async (
    request: NextRequest,
    context?: { params: Promise<{ id: string }> }
  ) => {
    try {
      const params = (await context?.params) || {};
      const { id } = params;
      const body = await request.json();
      const { role } = body;

      if (!ObjectId.isValid(id)) {
        return NextResponse.json({ error: "Invalid user ID" }, { status: 400 });
      }

      if (!role || !["user", "admin"].includes(role)) {
        return NextResponse.json(
          { error: "Invalid role. Must be 'user' or 'admin'" },
          { status: 400 }
        );
      }

      const db = await getDb();
      const usersCollection = db.collection("users");

      // Check if user exists
      const existingUser = await usersCollection.findOne({
        _id: new ObjectId(id),
      });

      if (!existingUser) {
        return NextResponse.json({ error: "User not found" }, { status: 404 });
      }

      // Update user role
      const result = await usersCollection.updateOne(
        { _id: new ObjectId(id) },
        {
          $set: {
            role: role,
            updatedAt: new Date(),
          },
        }
      );

      if (result.matchedCount === 0) {
        return NextResponse.json({ error: "User not found" }, { status: 404 });
      }

      // Get updated user
      const updatedUser = await usersCollection.findOne(
        { _id: new ObjectId(id) },
        { projection: { password: 0 } }
      );

      return NextResponse.json({
        success: true,
        message: `User role updated to ${role}`,
        user: {
          _id: updatedUser?._id,
          name: updatedUser?.name,
          email: updatedUser?.email,
          role: updatedUser?.role,
          createdAt: updatedUser?.createdAt,
          updatedAt: updatedUser?.updatedAt,
        },
      });
    } catch (error) {
      console.error("Update user role error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  }
);
