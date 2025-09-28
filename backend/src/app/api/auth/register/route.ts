import { NextRequest, NextResponse } from "next/server";
import { getDb } from "../../../../../lib/mongodb";
import { hashPassword, generateToken } from "../../../../../lib/auth";
import { User, CreateUserData } from "../../../../../models/User";

export async function POST(request: NextRequest) {
  try {
    const body: CreateUserData = await request.json();
    const { name, email, password, role = "user" } = body;

    // Validate required fields
    if (!email || !password) {
      return NextResponse.json(
        { error: "Email and password are required" },
        { status: 400 }
      );
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return NextResponse.json(
        { error: "Invalid email format" },
        { status: 400 }
      );
    }

    // Validate password strength
    if (password.length < 6) {
      return NextResponse.json(
        { error: "Password must be at least 6 characters long" },
        { status: 400 }
      );
    }

    const db = await getDb();
    const usersCollection = db.collection<User>("users");

    // Check if user already exists
    const existingUser = await usersCollection.findOne({ email });

    if (existingUser) {
      return NextResponse.json(
        { error: "User with this email already exists" },
        { status: 409 }
      );
    }

    // Hash password
    const hashedPassword = await hashPassword(password);

    // Create user
    const newUser: User = {
      name,
      email,
      password: hashedPassword,
      role,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const result = await usersCollection.insertOne(newUser);
    const user = await usersCollection.findOne({ _id: result.insertedId });

    if (!user) {
      throw new Error("Failed to create user");
    }

    // Generate token
    const token = generateToken(user);

    return NextResponse.json(
      {
        message: "User registered successfully",
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,
        },
        token,
      },
      { status: 201 }
    );
  } catch (error) {
    console.error("Registration error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
