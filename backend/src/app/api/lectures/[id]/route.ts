import { NextRequest, NextResponse } from "next/server";
import { getDb } from "../../../../../lib/mongodb";
import { authenticateToken, requireAdmin } from "../../../../../lib/middleware";
import { Lecture, UpdateLectureData } from "../../../../../models/Lecture";
import { ObjectId } from "mongodb";

// GET /api/lectures/[id] - Get specific lecture
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const resolvedParams = await params;
    const { id } = resolvedParams;

    if (!ObjectId.isValid(id)) {
      return NextResponse.json(
        { error: "Invalid lecture ID" },
        { status: 400 }
      );
    }

    const db = await getDb();
    const lecturesCollection = db.collection<Lecture>("lectures");

    const lecture = await lecturesCollection.findOne({ _id: new ObjectId(id) });

    if (!lecture) {
      return NextResponse.json({ error: "Lecture not found" }, { status: 404 });
    }

    return NextResponse.json({
      lecture: {
        id: lecture._id,
        title: lecture.title,
        time: lecture.time,
        day: lecture.day,
        location: lecture.location,
        lecturerName: lecture.lecturerName,
        isMarked: lecture.isMarked,
        markedDate: lecture.markedDate,
        createdAt: lecture.createdAt,
        updatedAt: lecture.updatedAt,
      },
    });
  } catch (error) {
    console.error("Get lecture error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}

// PUT /api/lectures/[id] - Update lecture (admin only)
export const PUT = requireAdmin(
  async (
    request: NextRequest,
    context?: { params: Promise<{ id: string }> }
  ) => {
    try {
      const params = (await context?.params) || {};
      const { id } = params;
      const body: UpdateLectureData = await request.json();

      if (!ObjectId.isValid(id)) {
        return NextResponse.json(
          { error: "Invalid lecture ID" },
          { status: 400 }
        );
      }

      const db = await getDb();
      const lecturesCollection = db.collection<Lecture>("lectures");

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

      // Validate time format if provided
      if (body.time) {
        const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
        if (!timeRegex.test(body.time)) {
          return NextResponse.json(
            { error: "Invalid time format. Use HH:MM" },
            { status: 400 }
          );
        }
      }

      // Validate day if provided
      if (body.day) {
        const validDays = [
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
          "Friday",
          "Saturday",
          "Sunday",
        ];
        if (!validDays.includes(body.day)) {
          return NextResponse.json(
            { error: "Invalid day. Use full day name (e.g., Monday)" },
            { status: 400 }
          );
        }
      }

      const updateData = {
        ...body,
        updatedAt: new Date(),
      };

      const result = await lecturesCollection.updateOne(
        { _id: new ObjectId(id) },
        { $set: updateData }
      );

      if (result.matchedCount === 0) {
        return NextResponse.json(
          { error: "Lecture not found" },
          { status: 404 }
        );
      }

      const updatedLecture = await lecturesCollection.findOne({
        _id: new ObjectId(id),
      });

      return NextResponse.json({
        message: "Lecture updated successfully",
        lecture: {
          id: updatedLecture?._id,
          title: updatedLecture?.title,
          time: updatedLecture?.time,
          day: updatedLecture?.day,
          location: updatedLecture?.location,
          lecturerName: updatedLecture?.lecturerName,
          isMarked: updatedLecture?.isMarked,
          markedDate: updatedLecture?.markedDate,
          updatedAt: updatedLecture?.updatedAt,
        },
      });
    } catch (error) {
      console.error("Update lecture error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  }
);

// DELETE /api/lectures/[id] - Delete lecture (admin only)
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
          { error: "Invalid lecture ID" },
          { status: 400 }
        );
      }

      const db = await getDb();
      const lecturesCollection = db.collection<Lecture>("lectures");

      const result = await lecturesCollection.deleteOne({
        _id: new ObjectId(id),
      });

      if (result.deletedCount === 0) {
        return NextResponse.json(
          { error: "Lecture not found" },
          { status: 404 }
        );
      }

      return NextResponse.json({
        message: "Lecture deleted successfully",
      });
    } catch (error) {
      console.error("Delete lecture error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  }
);
