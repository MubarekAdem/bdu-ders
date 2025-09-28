import { NextRequest, NextResponse } from "next/server";
import { getDb } from "./../../../../../../lib/mongodb";
import {
  authenticateToken,
  requireAdmin,
} from "./../../../../../../lib/middleware";
import { UpdateDayAvailabilityData } from "./../../../../../../models/Lecture";
import { ObjectId } from "mongodb";

// PUT /api/lectures/[id]/availability - Update lecture availability for a specific day (admin only)
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
      const body: UpdateDayAvailabilityData = await request.json();

      if (!ObjectId.isValid(id)) {
        return NextResponse.json(
          { error: "Invalid lecture ID" },
          { status: 400 }
        );
      }

      const { day, available } = body;

      // Validate day
      const validDays = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
      ];

      if (!day || !validDays.includes(day)) {
        return NextResponse.json(
          { error: "Invalid day. Use full day name (e.g., Monday)" },
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

      // Update the specific day availability
      const updateQuery = {
        [`dayAvailability.${day}`]: available,
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
        message: `Lecture availability for ${day} updated successfully`,
        lecture: {
          id: updatedLecture?._id,
          title: updatedLecture?.title,
          dayAvailability: updatedLecture?.dayAvailability,
          updatedAt: updatedLecture?.updatedAt,
        },
      });
    } catch (error) {
      console.error("Update lecture availability error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  }
);

// GET /api/lectures/[id]/availability - Get lecture availability (admin only)
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
          dayAvailability: lecture.dayAvailability,
        },
      });
    } catch (error) {
      console.error("Get lecture availability error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  }
);
