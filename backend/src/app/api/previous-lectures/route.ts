import { NextRequest, NextResponse } from "next/server";
import { getDb } from "../../../../lib/mongodb";
import {
  authenticateToken,
  requireAdmin,
  AuthenticatedRequest,
} from "../../../../lib/middleware";
import {
  CreatePreviousLectureData,
  PreviousLecture,
} from "../../../../models/PreviousLecture";
import { ObjectId } from "mongodb";

export const GET = authenticateToken(async (req: AuthenticatedRequest) => {
  try {
    const db = await getDb();
    const previousLecturesCollection =
      db.collection<PreviousLecture>("previousLectures");

    const previousLectures = await previousLecturesCollection
      .find({})
      .sort({ date: -1 }) // Sort by date descending (newest first)
      .toArray();

    return NextResponse.json({
      success: true,
      previousLectures: previousLectures.map((lecture) => ({
        id: lecture._id.toString(),
        title: lecture.title,
        date: lecture.date,
        telegramLink: lecture.telegramLink,
        createdAt: lecture.createdAt,
        updatedAt: lecture.updatedAt,
      })),
    });
  } catch (error) {
    console.error("Error fetching previous lectures:", error);
    return NextResponse.json(
      { success: false, error: "Failed to fetch previous lectures" },
      { status: 500 }
    );
  }
});

export const POST = requireAdmin(async (req: AuthenticatedRequest) => {
  try {
    const body = await req.json();
    const { title, date, telegramLink } = body;

    if (!title || !date || !telegramLink) {
      return NextResponse.json(
        {
          success: false,
          error: "Title, date, and telegram link are required",
        },
        { status: 400 }
      );
    }

    // Validate telegram link format
    const telegramUrlPattern = /^https?:\/\/t\.me\/.+/;
    if (!telegramUrlPattern.test(telegramLink)) {
      return NextResponse.json(
        { success: false, error: "Invalid telegram link format" },
        { status: 400 }
      );
    }

    const db = await getDb();
    const previousLecturesCollection =
      db.collection<PreviousLecture>("previousLectures");

    const previousLectureData: PreviousLecture = {
      title: title.trim(),
      date: new Date(date),
      telegramLink: telegramLink.trim(),
      createdBy: new ObjectId(req.user!.id),
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const result = await previousLecturesCollection.insertOne(
      previousLectureData
    );

    const createdLecture = await previousLecturesCollection.findOne({
      _id: result.insertedId,
    });

    if (!createdLecture) {
      throw new Error("Failed to create previous lecture");
    }

    return NextResponse.json(
      {
        success: true,
        previousLecture: {
          id: createdLecture._id.toString(),
          title: createdLecture.title,
          date: createdLecture.date,
          telegramLink: createdLecture.telegramLink,
          createdAt: createdLecture.createdAt,
          updatedAt: createdLecture.updatedAt,
        },
      },
      { status: 201 }
    );
  } catch (error) {
    console.error("Error creating previous lecture:", error);
    return NextResponse.json(
      { success: false, error: "Failed to create previous lecture" },
      { status: 500 }
    );
  }
});
