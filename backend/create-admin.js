const { MongoClient } = require("mongodb");
const bcrypt = require("bcryptjs");

// MongoDB connection string - update this with your MongoDB URI
const MONGODB_URI =
  process.env.MONGODB_URI || "mongodb://localhost:27017/lecture-scheduler";
const DB_NAME = "lecture-scheduler";

async function createAdminUser() {
  let client;

  try {
    console.log("Connecting to MongoDB...");
    client = new MongoClient(MONGODB_URI);
    await client.connect();

    const db = client.db(DB_NAME);
    const usersCollection = db.collection("users");

    // Check if admin already exists
    const existingAdmin = await usersCollection.findOne({ role: "admin" });
    if (existingAdmin) {
      console.log("Admin user already exists:");
      console.log(`Email: ${existingAdmin.email}`);
      console.log(`Phone: ${existingAdmin.phone}`);
      console.log(`Name: ${existingAdmin.name}`);
      return;
    }

    // Create admin user
    const adminData = {
      name: "Admin User",
      email: "admin@example.com",
      phone: "+1234567890",
      password: await bcrypt.hash("admin123", 10),
      role: "admin",
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const result = await usersCollection.insertOne(adminData);

    console.log("Admin user created successfully!");
    console.log("Login credentials:");
    console.log(`Phone: ${adminData.phone}`);
    console.log(`Password: admin123`);
    console.log(`Email: ${adminData.email}`);
    console.log(`User ID: ${result.insertedId}`);
  } catch (error) {
    console.error("Error creating admin user:", error);
  } finally {
    if (client) {
      await client.close();
    }
  }
}

createAdminUser();
