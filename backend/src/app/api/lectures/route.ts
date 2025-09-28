import { NextRequest, NextResponse } from "next/server";
import { getDb } from "../../../../lib/mongodb";
import {
  authenticateToken,
  requireAdmin,
  AuthenticatedRequest,
} from "../../../../lib/middleware";
import { Lecture, CreateLectureData } from "../../../../models/Lecture";
import { ObjectId } from "mongodb";

// GET /api/lectures - Get all lectures (for users and admins)
export const GET = authenticateToken(async (req: AuthenticatedRequest) => {
  try {
    const db = await getDb();
    const lecturesCollection = db.collection<Lecture>("lectures");

    const lectures = await lecturesCollection
      .find({})
      .sort({ days: 1, timeStart: 1 })
      .toArray();

    const today = new Date();
    today.setHours(0, 0, 0, 0); // Start of today

    return NextResponse.json({
      lectures: lectures.map((lecture) => {
        // Check if lecture is marked for today
        const isMarkedForToday = lecture.markedDates
          ? lecture.markedDates.some((date) => {
              const markedDate = new Date(date);
              markedDate.setHours(0, 0, 0, 0);
              return markedDate.getTime() === today.getTime();
            })
          : lecture.isMarked; // Fallback to isMarked field if markedDates is not available

        return {
          id: lecture._id,
          title: lecture.title,
          timeStart: lecture.timeStart,
          timeEnd: lecture.timeEnd,
          days: lecture.days,
          location: lecture.location,
          lecturerName: lecture.lecturerName,
          isMarked: isMarkedForToday,
          markedDate: isMarkedForToday ? today : null,
          markedDates: lecture.markedDates,
          dayAvailability: lecture.dayAvailability,
          dateAvailability: lecture.dateAvailability,
          createdAt: lecture.createdAt,
        };
      }),
    });
  } catch (error) {
    console.error("Get lectures error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
});

// POST /api/lectures - Create new lecture (admin only)
export const POST = requireAdmin(async (req: AuthenticatedRequest) => {
  try {
    const body: CreateLectureData = await req.json();
    const { title, timeStart, timeEnd, days, location, lecturerName } = body;

    // Validate required fields
    if (
      !title ||
      !timeStart ||
      !timeEnd ||
      !days ||
      !location ||
      !lecturerName
    ) {
      return NextResponse.json(
        { error: "All fields are required" },
        { status: 400 }
      );
    }

    // Validate time format (HH:MM)
    const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (!timeRegex.test(timeStart) || !timeRegex.test(timeEnd)) {
      return NextResponse.json(
        { error: "Invalid time format. Use HH:MM" },
        { status: 400 }
      );
    }

    // Validate days array
    const validDays = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    if (!Array.isArray(days) || days.length === 0) {
      return NextResponse.json(
        { error: "At least one day must be selected" },
        { status: 400 }
      );
    }

    for (const day of days) {
      if (!validDays.includes(day)) {
        return NextResponse.json(
          { error: "Invalid day. Use full day names (e.g., Monday)" },
          { status: 400 }
        );
      }
    }

    const db = await getDb();
    const lecturesCollection = db.collection<Lecture>("lectures");

    const today = new Date();
    today.setHours(0, 0, 0, 0); // Start of today

    // Create default day availability (all days available by default)
    const defaultDayAvailability = {
      Monday: true,
      Tuesday: true,
      Wednesday: true,
      Thursday: true,
      Friday: true,
      Saturday: true,
      Sunday: true,
    };

    const newLecture: Lecture = {
      title,
      timeStart,
      timeEnd,
      days,
      location,
      lecturerName,
      isMarked: true, // Default to marked
      markedDates: [today], // Mark for today by default
      dayAvailability: body.dayAvailability || defaultDayAvailability,
      createdBy: new ObjectId(req.user!.id),
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const result = await lecturesCollection.insertOne(newLecture);
    const lecture = await lecturesCollection.findOne({
      _id: result.insertedId,
    });

    if (!lecture) {
      throw new Error("Failed to create lecture");
    }

    return NextResponse.json(
      {
        message: "Lecture created successfully",
        lecture: {
          id: lecture._id,
          title: lecture.title,
          timeStart: lecture.timeStart,
          timeEnd: lecture.timeEnd,
          days: lecture.days,
          location: lecture.location,
          lecturerName: lecture.lecturerName,
          isMarked: lecture.isMarked,
          dayAvailability: lecture.dayAvailability,
          createdAt: lecture.createdAt,
        },
      },
      { status: 201 }
    );
  } catch (error) {
    console.error("Create lecture error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
});
