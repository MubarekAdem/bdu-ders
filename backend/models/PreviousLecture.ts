import { ObjectId } from "mongodb";

export interface PreviousLecture {
  _id?: ObjectId;
  title: string;
  date: Date; // Date when the lecture was held
  telegramLink: string; // Telegram link to the lecture recording
  createdBy: ObjectId; // Admin who created it
  createdAt: Date;
  updatedAt: Date;
}

export interface CreatePreviousLectureData {
  title: string;
  date: Date;
  telegramLink: string;
  createdBy: ObjectId;
}

export interface UpdatePreviousLectureData {
  title?: string;
  date?: Date;
  telegramLink?: string;
}
