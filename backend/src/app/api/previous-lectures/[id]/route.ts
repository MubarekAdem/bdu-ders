import { NextRequest, NextResponse } from "next/server";
import { getDb } from "../../../../../lib/mongodb";
import {
  authenticateToken,
  requireAdmin,
  AuthenticatedRequest,
} from "../../../../../lib/middleware";
import {
  UpdatePreviousLectureData,
  PreviousLecture,
} from "../../../../../models/PreviousLecture";
import { ObjectId } from "mongodb";

export const GET = authenticateToken(
  async (req: AuthenticatedRequest, { params }: { params: { id: string } }) => {
    try {
      const db = await getDb();
      const previousLecturesCollection =
        db.collection<PreviousLecture>("previousLectures");

      const previousLecture = await previousLecturesCollection.findOne({
        _id: new ObjectId(params.id),
      });

      if (!previousLecture) {
        return NextResponse.json(
          { success: false, error: "Previous lecture not found" },
          { status: 404 }
        );
      }

      return NextResponse.json({
        success: true,
        previousLecture: {
          id: previousLecture._id.toString(),
          title: previousLecture.title,
          date: previousLecture.date,
          telegramLink: previousLecture.telegramLink,
          createdAt: previousLecture.createdAt,
          updatedAt: previousLecture.updatedAt,
        },
      });
    } catch (error) {
      console.error("Error fetching previous lecture:", error);
      return NextResponse.json(
        { success: false, error: "Failed to fetch previous lecture" },
        { status: 500 }
      );
    }
  }
);

export const PUT = requireAdmin(
  async (req: AuthenticatedRequest, { params }: { params: { id: string } }) => {
    try {
      const body = await req.json();
      const { title, date, telegramLink } = body;

      const db = await getDb();
      const previousLecturesCollection =
        db.collection<PreviousLecture>("previousLectures");

      // Check if the previous lecture exists
      const existingLecture = await previousLecturesCollection.findOne({
        _id: new ObjectId(params.id),
      });

      if (!existingLecture) {
        return NextResponse.json(
          { success: false, error: "Previous lecture not found" },
          { status: 404 }
        );
      }

      // Validate telegram link format if provided
      if (telegramLink) {
        const telegramUrlPattern = /^https?:\/\/t\.me\/.+/;
        if (!telegramUrlPattern.test(telegramLink)) {
          return NextResponse.json(
            { success: false, error: "Invalid telegram link format" },
            { status: 400 }
          );
        }
      }

      const updateData: UpdatePreviousLectureData = {};
      if (title !== undefined) updateData.title = title.trim();
      if (date !== undefined) updateData.date = new Date(date);
      if (telegramLink !== undefined)
        updateData.telegramLink = telegramLink.trim();

      const result = await previousLecturesCollection.updateOne(
        { _id: new ObjectId(params.id) },
        {
          $set: {
            ...updateData,
            updatedAt: new Date(),
          },
        }
      );

      if (result.matchedCount === 0) {
        return NextResponse.json(
          { success: false, error: "Previous lecture not found" },
          { status: 404 }
        );
      }

      const updatedLecture = await previousLecturesCollection.findOne({
        _id: new ObjectId(params.id),
      });

      if (!updatedLecture) {
        throw new Error("Failed to fetch updated lecture");
      }

      return NextResponse.json({
        success: true,
        previousLecture: {
          id: updatedLecture._id.toString(),
          title: updatedLecture.title,
          date: updatedLecture.date,
          telegramLink: updatedLecture.telegramLink,
          createdAt: updatedLecture.createdAt,
          updatedAt: updatedLecture.updatedAt,
        },
      });
    } catch (error) {
      console.error("Error updating previous lecture:", error);
      return NextResponse.json(
        { success: false, error: "Failed to update previous lecture" },
        { status: 500 }
      );
    }
  }
);

export const DELETE = requireAdmin(
  async (req: AuthenticatedRequest, { params }: { params: { id: string } }) => {
    try {
      const db = await getDb();
      const previousLecturesCollection =
        db.collection<PreviousLecture>("previousLectures");

      const result = await previousLecturesCollection.deleteOne({
        _id: new ObjectId(params.id),
      });

      if (result.deletedCount === 0) {
        return NextResponse.json(
          { success: false, error: "Previous lecture not found" },
          { status: 404 }
        );
      }

      return NextResponse.json({
        success: true,
        message: "Previous lecture deleted successfully",
      });
    } catch (error) {
      console.error("Error deleting previous lecture:", error);
      return NextResponse.json(
        { success: false, error: "Failed to delete previous lecture" },
        { status: 500 }
      );
    }
  }
);
