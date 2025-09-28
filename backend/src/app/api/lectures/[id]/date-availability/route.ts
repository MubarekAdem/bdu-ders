import { NextRequest, NextResponse } from "next/server";
import { getDb } from "./../../../../../../lib/mongodb";
import {
  authenticateToken,
  requireAdmin,
} from "./../../../../../../lib/middleware";
import { UpdateDateAvailabilityData } from "./../../../../../../models/Lecture";
import { ObjectId } from "mongodb";

// PUT /api/lectures/[id]/date-availability - Update lecture availability for a specific date (admin only)
export const PUT = requireAdmin(
  async (
    request: NextRequest,
    context?: { params: Promise<{ id: string }> }
  ) => {
    try {
      const params = await context?.params;
      if (!params) {
        return NextResponse.json(
          { error: "Missing parameters" },
          { status: 400 }
        );
      }
      const { id } = params;
      const body: UpdateDateAvailabilityData = await request.json();

      if (!ObjectId.isValid(id)) {
        return NextResponse.json(
          { error: "Invalid lecture ID" },
          { status: 400 }
        );
      }

      const { date, available } = body;

      // Validate date format (YYYY-MM-DD)
      const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
      if (!date || !dateRegex.test(date)) {
        return NextResponse.json(
          { error: "Invalid date format. Use YYYY-MM-DD" },
          { status: 400 }
        );
      }

      if (typeof available !== "boolean") {
        return NextResponse.json(
          { error: "Available must be a boolean value" },
          { status: 400 }
        );
      }

      const db = await getDb();
      const lecturesCollection = db.collection("lectures");

      // Check if lecture exists
      const existingLecture = await lecturesCollection.findOne({
        _id: new ObjectId(id),
      });

      if (!existingLecture) {
        return NextResponse.json(
          { error: "Lecture not found" },
          { status: 404 }
        );
      }

      // Update the specific date availability
      const updateQuery = {
        [`dateAvailability.${date}`]: available,
        updatedAt: new Date(),
      };

      const result = await lecturesCollection.updateOne(
        { _id: new ObjectId(id) },
        { $set: updateQuery }
      );

      if (result.matchedCount === 0) {
        return NextResponse.json(
          { error: "Lecture not found" },
          { status: 404 }
        );
      }

      // Get the updated lecture
      const updatedLecture = await lecturesCollection.findOne({
        _id: new ObjectId(id),
      });

      return NextResponse.json({
        message: `Lecture availability for ${date} updated successfully`,
        lecture: {
          id: updatedLecture?._id,
          title: updatedLecture?.title,
          dateAvailability: updatedLecture?.dateAvailability,
          updatedAt: updatedLecture?.updatedAt,
        },
      });
    } catch (error) {
      console.error("Update lecture date availability error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  }
);

// GET /api/lectures/[id]/date-availability - Get lecture date availability (admin only)
export const GET = requireAdmin(
  async (
    request: NextRequest,
    context?: { params: Promise<{ id: string }> }
  ) => {
    try {
      const params = await context?.params;
      if (!params) {
        return NextResponse.json(
          { error: "Missing parameters" },
          { status: 400 }
        );
      }
      const { id } = params;

      if (!ObjectId.isValid(id)) {
        return NextResponse.json(
          { error: "Invalid lecture ID" },
          { status: 400 }
        );
      }

      const db = await getDb();
      const lecturesCollection = db.collection("lectures");

      const lecture = await lecturesCollection.findOne({
        _id: new ObjectId(id),
      });

      if (!lecture) {
        return NextResponse.json(
          { error: "Lecture not found" },
          { status: 404 }
        );
      }

      return NextResponse.json({
        lecture: {
          id: lecture._id,
          title: lecture.title,
          dateAvailability: lecture.dateAvailability || {},
        },
      });
    } catch (error) {
      console.error("Get lecture date availability error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  }
);
