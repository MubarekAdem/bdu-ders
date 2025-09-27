import { ObjectId } from "mongodb";

export interface Update {
  _id?: ObjectId;
  title: string;
  content: string;
  type: "general" | "lecture" | "system";
  priority: "low" | "medium" | "high";
  isActive: boolean;
  createdBy: ObjectId; // Admin who created it
  createdAt: Date;
  updatedAt: Date;
  expiresAt?: Date; // Optional expiration date
}

export interface CreateUpdateData {
  title: string;
  content: string;
  type: "general" | "lecture" | "system";
  priority: "low" | "medium" | "high";
  createdBy: ObjectId;
  expiresAt?: Date;
}

export interface UpdateData {
  title?: string;
  content?: string;
  type?: "general" | "lecture" | "system";
  priority?: "low" | "medium" | "high";
  isActive?: boolean;
  expiresAt?: Date;
}
