import { NextRequest, NextResponse } from "next/server";
import { getDb } from "../../../../../../../lib/mongodb";
import { requireAdmin } from "../../../../../../../lib/middleware";
import { Lecture } from "../../../../../../../models/Lecture";
import { ObjectId } from "mongodb";

// POST /api/lectures/[id]/mark - Mark lecture for today (admin only)
export const POST = requireAdmin(
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

      const today = new Date();
      today.setHours(0, 0, 0, 0); // Start of today

      // Mark the lecture for today by adding today's date to markedDates array
      const result = await lecturesCollection.updateOne(
        { _id: new ObjectId(id) },
        {
          $addToSet: {
            markedDates: today,
          },
          $set: {
            updatedAt: new Date(),
          },
        }
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

      // Check if lecture is marked for today
      const isMarkedForToday =
        updatedLecture?.markedDates?.some((date) => {
          const markedDate = new Date(date);
          markedDate.setHours(0, 0, 0, 0);
          return markedDate.getTime() === today.getTime();
        }) || false;

      return NextResponse.json({
        message: "Lecture marked for today successfully",
        lecture: {
          id: updatedLecture?._id,
          title: updatedLecture?.title,
          timeStart: updatedLecture?.timeStart,
          timeEnd: updatedLecture?.timeEnd,
          days: updatedLecture?.days,
          location: updatedLecture?.location,
          lecturerName: updatedLecture?.lecturerName,
          isMarked: isMarkedForToday,
          markedDate: isMarkedForToday ? today : null,
          markedDates: updatedLecture?.markedDates,
        },
      });
    } catch (error) {
      console.error("Mark lecture error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  }
);

// DELETE /api/lectures/[id]/mark - Unmark lecture for today (admin only)
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

      const today = new Date();
      today.setHours(0, 0, 0, 0); // Start of today

      // Remove today's date from markedDates array
      const result = await lecturesCollection.updateOne(
        { _id: new ObjectId(id) },
        {
          $pull: {
            markedDates: today,
          },
          $set: {
            updatedAt: new Date(),
          },
        }
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

      // Check if lecture is marked for today
      const isMarkedForToday =
        updatedLecture?.markedDates?.some((date) => {
          const markedDate = new Date(date);
          markedDate.setHours(0, 0, 0, 0);
          return markedDate.getTime() === today.getTime();
        }) || false;

      return NextResponse.json({
        message: "Lecture unmarked for today successfully",
        lecture: {
          id: updatedLecture?._id,
          title: updatedLecture?.title,
          timeStart: updatedLecture?.timeStart,
          timeEnd: updatedLecture?.timeEnd,
          days: updatedLecture?.days,
          location: updatedLecture?.location,
          lecturerName: updatedLecture?.lecturerName,
          isMarked: isMarkedForToday,
          markedDate: isMarkedForToday ? today : null,
          markedDates: updatedLecture?.markedDates,
        },
      });
    } catch (error) {
      console.error("Unmark lecture error:", error);
      return NextResponse.json(
        { error: "Internal server error" },
        { status: 500 }
      );
    }
  }
);
