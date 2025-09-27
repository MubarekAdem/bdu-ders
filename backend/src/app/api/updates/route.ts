import { NextRequest, NextResponse } from "next/server";
import { getDb } from "../../../../lib/mongodb";
import { authenticateToken, requireAdmin } from "../../../../lib/middleware";
import { Update, CreateUpdateData } from "../../../../models/Update";
import { ObjectId } from "mongodb";

// GET /api/updates - Get all active updates (for users and admins)
export const GET = authenticateToken(async (req: AuthenticatedRequest) => {
  try {
    const db = await getDb();
    const updatesCollection = db.collection<Update>("updates");

    // Get active updates that haven't expired
    const now = new Date();
    const updates = await updatesCollection
      .find({
        isActive: true,
        $or: [{ expiresAt: { $exists: false } }, { expiresAt: { $gt: now } }],
      })
      .sort({ priority: -1, createdAt: -1 })
      .toArray();

    return NextResponse.json({
      updates: updates.map((update) => ({
        id: update._id,
        title: update.title,
        content: update.content,
        type: update.type,
        priority: update.priority,
        createdAt: update.createdAt,
        expiresAt: update.expiresAt,
      })),
    });
  } catch (error) {
    console.error("Get updates error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
});

// POST /api/updates - Create new update (admin only)
export const POST = requireAdmin(async (req: AuthenticatedRequest) => {
  try {
    const body: CreateUpdateData = await request.json();
    const { title, content, type, priority, expiresAt } = body;

    // Validate required fields
    if (!title || !content || !type || !priority) {
      return NextResponse.json(
        { error: "Title, content, type, and priority are required" },
        { status: 400 }
      );
    }

    // Validate type
    const validTypes = ["general", "lecture", "system"];
    if (!validTypes.includes(type)) {
      return NextResponse.json(
        { error: "Invalid type. Must be general, lecture, or system" },
        { status: 400 }
      );
    }

    // Validate priority
    const validPriorities = ["low", "medium", "high"];
    if (!validPriorities.includes(priority)) {
      return NextResponse.json(
        { error: "Invalid priority. Must be low, medium, or high" },
        { status: 400 }
      );
    }

    const db = await getDb();
    const updatesCollection = db.collection<Update>("updates");

    const newUpdate: Update = {
      title,
      content,
      type,
      priority,
      isActive: true,
      createdBy: new ObjectId(req.user!.id),
      createdAt: new Date(),
      updatedAt: new Date(),
      expiresAt: expiresAt ? new Date(expiresAt) : undefined,
    };

    const result = await updatesCollection.insertOne(newUpdate);
    const update = await updatesCollection.findOne({ _id: result.insertedId });

    if (!update) {
      throw new Error("Failed to create update");
    }

    return NextResponse.json(
      {
        message: "Update created successfully",
        update: {
          id: update._id,
          title: update.title,
          content: update.content,
          type: update.type,
          priority: update.priority,
          isActive: update.isActive,
          createdAt: update.createdAt,
          expiresAt: update.expiresAt,
        },
      },
      { status: 201 }
    );
  } catch (error) {
    console.error("Create update error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
});
