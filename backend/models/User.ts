import { ObjectId } from "mongodb";

export interface User {
  _id?: ObjectId;
  name?: string;
  email: string;
  password: string;
  role: "user" | "admin";
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserData {
  name?: string;
  email: string;
  password: string;
  role?: "user" | "admin";
}

export interface LoginData {
  email: string;
  password: string;
}

export interface UpdateUserData {
  name?: string;
  email?: string;
  password?: string;
}
