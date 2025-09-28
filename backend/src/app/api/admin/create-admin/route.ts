import { NextRequest, NextResponse } from "next/server";
import { getDb } from "../../../../../lib/mongodb";
import { hashPassword } from "../../../../../lib/auth";
import { User } from "../../../../../models/User";

// POST /api/admin/create-admin - Create admin user (temporary endpoint)
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const {
      name = "Admin User",
      email = "admin@example.com",
      phone = "+1234567890",
      password = "admin123",
    } = body;

    const db = await getDb();
    const usersCollection = db.collection<User>("users");

    // Check if admin already exists
    const existingAdmin = await usersCollection.findOne({ role: "admin" });
    if (existingAdmin) {
      return NextResponse.json({
        message: "Admin user already exists",
        admin: {
          id: existingAdmin._id,
          name: existingAdmin.name,
          email: existingAdmin.email,
          phone: existingAdmin.phone,
          role: existingAdmin.role,
        },
        loginCredentials: {
          phone: existingAdmin.phone,
          password: "Use existing password or contact admin",
        },
      });
    }

    // Hash password
    const hashedPassword = await hashPassword(password);

    // Create admin user
    const adminUser: User = {
      name,
      email,
      phone,
      password: hashedPassword,
      role: "admin",
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const result = await usersCollection.insertOne(adminUser);
    const createdAdmin = await usersCollection.findOne({
      _id: result.insertedId,
    });

    if (!createdAdmin) {
      throw new Error("Failed to create admin user");
    }

    return NextResponse.json(
      {
        message: "Admin user created successfully!",
        admin: {
          id: createdAdmin._id,
          name: createdAdmin.name,
          email: createdAdmin.email,
          phone: createdAdmin.phone,
          role: createdAdmin.role,
        },
        loginCredentials: {
          phone: createdAdmin.phone,
          password: password,
        },
      },
      { status: 201 }
    );
  } catch (error) {
    console.error("Create admin error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
