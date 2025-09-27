# Lecture Scheduler App

A comprehensive lecture scheduling system with Next.js backend and Flutter mobile app, featuring phone-based authentication, schedule management, and real-time updates.

## Features

### 🔐 Authentication

- Phone number-based registration and login
- Email and password support
- Phone verification system
- Role-based access (User/Admin)

### 📅 Schedule Management

- **For Users:**

  - View lecture schedules by day
  - See marked lectures for the current day
  - Real-time schedule updates

- **For Admins:**
  - Create, edit, and delete lecture schedules
  - Mark specific lectures for the day
  - Manage lecture details (title, time, day, location, lecturer)

### 📢 Updates & Notifications

- **For Users:**

  - View announcements and updates
  - Filter updates by type (General, Lecture, System)
  - Priority-based notifications

- **For Admins:**
  - Create and manage updates
  - Set priority levels (Low, Medium, High)
  - Set expiration dates for updates

## Tech Stack

### Backend (Next.js)

- **Framework:** Next.js 15.5.4
- **Database:** MongoDB with Mongoose
- **Authentication:** JWT tokens with bcryptjs
- **API:** RESTful API with TypeScript
- **SMS:** Twilio integration (configurable)
- **Email:** Nodemailer integration (configurable)

### Mobile App (Flutter)

- **Framework:** Flutter 3.9.2+
- **State Management:** Provider
- **HTTP Client:** http package
- **Local Storage:** SharedPreferences
- **UI:** Material Design 3

## Project Structure

```
bdu-jemea/
├── backend/                 # Next.js API backend
│   ├── src/app/api/        # API routes
│   ├── lib/                # Utilities and configurations
│   ├── models/             # TypeScript interfaces
│   └── prisma/             # Database schema (if using Prisma)
├── mobile_app/             # Flutter mobile application
│   ├── lib/
│   │   ├── models/         # Dart data models
│   │   ├── providers/      # State management
│   │   ├── services/       # API services
│   │   └── screens/        # UI screens
│   └── android/ios/        # Platform-specific code
└── README.md
```

## Setup Instructions

### Prerequisites

- Node.js 18+ and npm
- Flutter SDK 3.9.2+
- MongoDB database
- (Optional) Twilio account for SMS
- (Optional) Email service for notifications

### Backend Setup

1. **Navigate to backend directory:**

   ```bash
   cd backend
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Set up environment variables:**
   Create a `.env.local` file in the backend directory:

   ```env
   # Database
   MONGODB_URI=mongodb://localhost:27017/lecture-scheduler

   # JWT
   JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
   JWT_EXPIRES_IN=7d

   # Twilio (for SMS verification)
   TWILIO_ACCOUNT_SID=your-twilio-account-sid
   TWILIO_AUTH_TOKEN=your-twilio-auth-token
   TWILIO_PHONE_NUMBER=your-twilio-phone-number

   # Email (for email verification)
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASS=your-app-password

   # App
   NEXT_PUBLIC_API_URL=http://localhost:3000/api
   ```

4. **Start the development server:**

   ```bash
   npm run dev
   ```

   The API will be available at `http://localhost:3000/api`

### Mobile App Setup

1. **Navigate to mobile app directory:**

   ```bash
   cd mobile_app
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Update API URL (if needed):**
   In `lib/services/api_service.dart`, update the `baseUrl` if your backend is running on a different port.

4. **Run the app:**
   ```bash
   flutter run
   ```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/verify` - Verify phone number

### Lectures

- `GET /api/lectures` - Get all lectures
- `POST /api/lectures` - Create lecture (Admin only)
- `PUT /api/lectures/[id]` - Update lecture (Admin only)
- `DELETE /api/lectures/[id]` - Delete lecture (Admin only)
- `POST /api/lectures/[id]/mark` - Mark lecture (Admin only)
- `DELETE /api/lectures/[id]/mark` - Unmark lecture (Admin only)

### Updates

- `GET /api/updates` - Get all updates
- `POST /api/updates` - Create update (Admin only)
- `PUT /api/updates/[id]` - Update update (Admin only)
- `DELETE /api/updates/[id]` - Delete update (Admin only)

## Database Schema

### Users Collection

```typescript
{
  _id: ObjectId,
  name: string,
  email: string,
  phone: string,
  password: string (hashed),
  role: 'user' | 'admin',
  isVerified: boolean,
  verificationCode?: string,
  createdAt: Date,
  updatedAt: Date
}
```

### Lectures Collection

```typescript
{
  _id: ObjectId,
  title: string,
  time: string (HH:MM format),
  day: string (Monday-Sunday),
  location: string,
  lecturerName: string,
  isMarked: boolean,
  markedDate?: Date,
  createdBy: ObjectId,
  createdAt: Date,
  updatedAt: Date
}
```

### Updates Collection

```typescript
{
  _id: ObjectId,
  title: string,
  content: string,
  type: 'general' | 'lecture' | 'system',
  priority: 'low' | 'medium' | 'high',
  isActive: boolean,
  createdBy: ObjectId,
  createdAt: Date,
  updatedAt: Date,
  expiresAt?: Date
}
```

## Usage

### For Users

1. **Register/Login:** Create an account with phone number, email, and password
2. **Verify Phone:** Enter the verification code sent to your phone
3. **View Schedule:** Browse lectures by day of the week
4. **Check Updates:** View announcements and notifications
5. **Profile Management:** Update personal information

### For Admins

1. **All User Features:** Access to all user functionality
2. **Manage Lectures:** Create, edit, and delete lecture schedules
3. **Mark Lectures:** Mark specific lectures for the current day
4. **Manage Updates:** Create and manage announcements
5. **Admin Dashboard:** View statistics and quick actions

## Development

### Backend Development

- API routes are in `backend/src/app/api/`
- Database models are in `backend/models/`
- Authentication utilities are in `backend/lib/auth.ts`
- MongoDB connection is in `backend/lib/mongodb.ts`

### Mobile App Development

- Screens are in `mobile_app/lib/screens/`
- State management is in `mobile_app/lib/providers/`
- API services are in `mobile_app/lib/services/`
- Models are in `mobile_app/lib/models/`

## Deployment

### Backend Deployment

1. Build the Next.js app: `npm run build`
2. Start the production server: `npm start`
3. Set up MongoDB Atlas or your preferred MongoDB hosting
4. Configure environment variables in production

### Mobile App Deployment

1. Build for Android: `flutter build apk`
2. Build for iOS: `flutter build ios`
3. Follow platform-specific deployment guides

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions, please open an issue in the repository.
