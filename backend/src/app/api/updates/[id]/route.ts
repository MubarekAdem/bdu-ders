import { NextRequest, NextResponse } from "next/server";
import { getDb } from "./../../../../../lib/mongodb";
import { requireAdmin } from "./../../../../../lib/middleware";
import { Update, UpdateData } from "./../../../../../models/Update";
import { ObjectId } from "mongodb";

// PUT /api/updates/[id] - Update update (admin only)
export const PUT = requireAdmin(
  async (
    request: NextRequest,
    context?: { params: Promise<{ id: string }> }
  ) => {
    try {
      const params = (await context?.params) || {};
      const { id } = params;
      const body: UpdateData = await request.json();

      if (!ObjectId.isValid(id)) {
        return NextResponse.json(
          { error: "Invalid update ID" },
          { status: 400 }
        );
      }

      const db = await getDb();
      const updatesCollection = db.collection<Update>("updates");

      // Check if update exists
      const existingUpdate = await updatesCollection.findOne({
        _id: new ObjectId(id),
      });
      if (!existingUpdate) {
        return NextResponse.json(
          { error: "Update not found" },
          { status: 404 }
        );
      }

      // Validate type if provided
      if (body.type) {
        const validTypes = ["general", "lecture", "system"];
        if (!validTypes.includes(body.type)) {
          return NextResponse.json(
            { error: "Invalid type. Must be general, lecture, or system" },
            { status: 400 }
          );
        }
      }

      // Validate priority if provided
      if (body.priority) {
        const validPriorities = ["low", "medium", "high"];
        if (!validPriorities.includes(body.priority)) {
          return NextResponse.json(
            { error: "Invalid priority. Must be low, medium, or high" },
            { status: 400 }
          );
        }
      }

      const updateData = {
        ...body,
        updatedAt: new Date(),
      };

      const result = await updatesCollection.updateOne(
        { _id: new ObjectId(id) },
        { $set: updateData }
      );

      if (result.matchedCount === 0) {
        return NextResponse.json(
          { error: "Update not found" },
          { status: 404 }
        );
      }

      const updatedUpdate = await updatesCollection.findOne({
        _id: new ObjectId(id),
      });

      return NextResponse.json({
        message: "Update updated successfully",
        update: {
          id: updatedUpdate?._id,
          title: updatedUpdate?.title,
          content: updatedUpdate?.content,
          type: updatedUpdate?.type,
          priority: updatedUpdate?.priority,
          isActive: updatedUpdate?.isActive,
          updatedAt: updatedUpdate?.updatedAt,
          expiresAt: updatedUpdate?.expiresAt,
        },
      });
    } catch (error) {
      console.error("Update update error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  }
);

// DELETE /api/updates/[id] - Delete update (admin only)
export const DELETE = requireAdmin(
  async (
    request: NextRequest,
    context?: { params: Promise<{ id: string }> }
  ) => {
    try {
      const params = (await context?.params) || {};
      const { id } = params;

      if (!ObjectId.isValid(id)) {
        return NextResponse.json(
          { error: "Invalid update ID" },
          { status: 400 }
        );
      }

      const db = await getDb();
      const updatesCollection = db.collection<Update>("updates");

      const result = await updatesCollection.deleteOne({
        _id: new ObjectId(id),
      });

      if (result.deletedCount === 0) {
        return NextResponse.json(
          { error: "Update not found" },
          { status: 404 }
        );
      }

      return NextResponse.json({
        message: "Update deleted successfully",
      });
    } catch (error) {
      console.error("Delete update error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  }
);
