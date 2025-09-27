import { ObjectId } from "mongodb";

export interface Lecture {
  _id?: ObjectId;
  title: string;
  timeStart: string; // Format: "HH:MM" - Start time
  timeEnd: string; // Format: "HH:MM" - End time
  days: string[]; // Array of days: ["Monday", "Tuesday", etc.]
  location: string;
  lecturerName: string;
  isMarked: boolean; // Admin can mark this lecture for the day
  markedDate?: Date; // When it was marked (for today)
  markedDates?: Date[]; // Array of dates when this lecture was marked
  createdBy: ObjectId; // Admin who created it
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateLectureData {
  title: string;
  timeStart: string;
  timeEnd: string;
  days: string[];
  location: string;
  lecturerName: string;
  createdBy: ObjectId;
}

export interface UpdateLectureData {
  title?: string;
  timeStart?: string;
  timeEnd?: string;
  days?: string[];
  location?: string;
  lecturerName?: string;
  isMarked?: boolean;
  markedDate?: Date;
}
