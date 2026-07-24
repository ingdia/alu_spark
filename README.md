# ALU Spark 

> The official internship and opportunity platform for the African Leadership University ecosystem.

ALU Spark connects ALU students with startups founded by fellow ALU entrepreneurs — enabling students to find internships, apply for opportunities, and grow within a trusted, verified community.

---

## Demo Video

>  **[Watch the Demo](YOUR_DEMO_VIDEO_LINK_HERE)**

---

##  Features

### For Students
- Register with your ALU email (`@alustudent.com` / `@alueducation.com`)
- Browse and apply for internship opportunities posted by verified ALU startups
- Track application status in real time
- Bookmark opportunities for later
- Message startup founders directly
- Build and showcase your student profile

### For Startup Founders
- Register and submit your startup for admin verification
- Post internship and job opportunities
- Review and manage incoming applications
- Message students directly
- Manage your startup profile and team

### For Admins
- Review and approve/reject startup submissions with rejection reasons
- Manage users across the platform
- Monitor platform activity and analytics
- Full access to all content moderation tools

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 |
| State Management | Riverpod |
| Backend | Firebase (Auth, Firestore, Storage) |
| Architecture | Feature-first, Repository Pattern |
| Auth | Firebase Auth + Email Verification |
| Database | Cloud Firestore |
| File Storage | Firebase Storage + Cloudinary |
| Navigation | Named Routes (`app_router.dart`) |

---

##  Project Structure

```
lib/
├── app/
│   ├── router/          # Named route definitions
│   └── theme/           # AppColors, AppTextStyles
├── core/
│   ├── constants/       # AppConstants (ALU domains, admin email)
│   ├── providers/       # Shared Firebase providers
│   ├── services/        # FirebaseAuthService
│   ├── utils/           # Helpers
│   └── widgets/         # GlassmorphicContainer, shared UI
├── features/
│   ├── auth/            # Register, Login, OTP, Role Selection, Onboarding
│   ├── home/            # Student home, Admin home
│   ├── opportunities/   # Browse & detail screens
│   ├── applications/    # Apply & track
│   ├── bookmarks/       # Saved opportunities
│   ├── messaging/       # Direct messages
│   ├── notifications/   # In-app notifications
│   ├── startup_profile/ # Startup public profile
│   ├── student_profile/ # Student public profile
│   ├── admin_verification/   # Startup review & approval
│   ├── admin_analytics/      # Platform analytics
│   └── admin_user_management/ # User management
└── shared/
    ├── enums/           # UserRole
    └── models/          # Shared data models
```

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.12.2`
- Firebase project with Firestore, Auth, and Storage enabled
- A `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) placed in the correct directories

### Setup

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/alu_spark.git
cd alu_spark

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment
Copy `.env.example` to `.env` and fill in your Firebase and Cloudinary credentials:

```bash
cp .env.example .env
```

---

## Authentication Flow

```
Register (ALU email only)
    └── Email OTP Verification
            └── Role Selection (Student / Founder)
                    ├── Student → Student Onboarding → Home
                    └── Founder → Startup Onboarding → Pending Review
                                        └── Admin Approves → Founder Home
```

- Only `@alustudent.com` and `@alueducation.com` emails are accepted
- Startup founders must submit proof documents and pass admin verification before going live
- Admin account is pre-configured via `AppConstants.adminEmail`

---

##  Firestore Security Rules

- Users can only read/write their own documents
- Startups can only be created by their owner (`isOwner(uid)`)
- Startup approval fields are admin-only (founders cannot self-approve)
- Opportunities can only be posted by verified founders
- Applications enforce no-duplicate and active-opportunity checks
- Admin notifications are writable by any verified ALU user

---

##  Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database |
| `firebase_storage` | File uploads |
| `url_launcher` | Open proof document links |
| `file_picker` | Document selection |
| `image_picker` | Profile photo selection |
| `cloudinary_flutter` | Image hosting |
| `shimmer` | Loading skeletons |
| `uuid` | Unique ID generation |

---

##  User Roles

| Role | Description |
|---|---|
| `student` | ALU student browsing and applying for opportunities |
| `founder` | ALU startup founder posting opportunities (requires admin approval) |
| `admin` | Platform administrator with full moderation access |

---

## Screenshots

> _Coming soon_

---


## License

This project is private and intended for use within the African Leadership University community.

---

<p align="center">Built with ❤️ by ALU students, for ALU students.</p>
