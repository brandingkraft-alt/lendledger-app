# LendLedger - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- Flutter SDK 3.0+ installed
- iOS/Android development environment
- Firebase account
- Git installed

### Step 1: Clone Repository
```bash
git clone https://github.com/brandingkraft-alt/lendledger-app.git
cd lendledger-app
```

### Step 2: Install Dependencies
```bash
cd mobile
flutter pub get
```

### Step 3: Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project "LendLedger"
3. Add iOS app (Bundle ID: `com.lendledger.app`)
4. Add Android app (Package: `com.lendledger.app`)
5. Download config files:
   - `google-services.json` → `mobile/android/app/`
   - `GoogleService-Info.plist` → `mobile/ios/Runner/`
6. Enable services:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Cloud Storage
   - Cloud Messaging

### Step 4: Run the App
```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

---

## 📱 App Features Overview

### Dashboard
- **Total Outstanding**: Sum of all active loan principals
- **Interest Accrued**: Real-time interest calculation
- **Capital Split**: Donut chart (Self-Funded vs Borrowed)
- **Due Today**: Horizontal scroll of loans due within 24 hours

### Add Loan
- Borrower name (with contact picker)
- Fund source toggle (Self-Funded/Borrowed)
- Transaction mode toggle (Cash/Bank)
- Principal amount (currency formatted)
- Interest rate (% per month/year)
- Payment frequency (Daily/Monthly/Quarterly)
- Loan start date & due date
- Cost of capital (if borrowed)

### Loan Cards
- **Blue cards** = Cash transactions
- **Green cards** = Bank transactions
- **Red highlight** = Overdue loans
- Quick "Mark Paid" button
- Tap to view details

### Source Buyout
- Convert "Borrowed" loans to "Self-Funded"
- Maintains borrower terms
- Stops cost tracking from conversion date
- Complete audit trail

### Export Data
- Excel (.xlsx) or CSV format
- Share via email, WhatsApp, or save to files
- All loan data with calculations

---

## 🔐 Security Features

### Authentication
- Biometric (FaceID/Fingerprint) required on launch
- PIN fallback if biometric fails
- Auto-lock after 5 minutes inactivity
- 3 failed attempts = app lock

### Data Protection
- AES-256 encryption for local database
- TLS 1.3 for all API calls
- Encrypted cloud backups
- Immutable audit logs

---

## 🧮 Interest Calculation

### Formula
```
Simple Interest: I = P × r × t

Where:
I = Interest Accrued
P = Principal Amount
r = Rate per period (decimal)
t = Time periods elapsed
```

### Example
```
Principal: ₹10,000
Rate: 2% per month
Days elapsed: 30 days

Interest = 10,000 × 0.02 × (30/30) = ₹200
Total Due = 10,000 + 200 = ₹10,200
```

---

## 📊 Project Structure

```
lendledger-app/
├── mobile/                    # Flutter app
│   ├── lib/
│   │   ├── main.dart         # App entry point
│   │   ├── models/           # Data models
│   │   │   └── loan.dart     # Loan model with logic
│   │   ├── screens/          # UI screens
│   │   │   ├── auth/         # Authentication screens
│   │   │   ├── dashboard/    # Dashboard screen
│   │   │   ├── loans/        # Loan management screens
│   │   │   └── settings/     # Settings screens
│   │   ├── providers/        # State management
│   │   ├── services/         # Business logic
│   │   │   ├── database_service.dart
│   │   │   ├── notification_service.dart
│   │   │   └── auth_service.dart
│   │   └── widgets/          # Reusable components
│   ├── pubspec.yaml          # Dependencies
│   └── test/                 # Unit tests
├── backend/
│   ├── database/
│   │   └── schema.sql        # Database schema
│   └── functions/            # Cloud functions
├── docs/
│   ├── TECHNICAL_SPECIFICATION.md
│   └── ARCHITECTURE.md
├── README.md
└── PROJECT_SETUP.md
```

---

## 🎯 Development Phases

### Phase 1: Security (Week 1)
- Biometric authentication
- Local encryption
- Secure storage

### Phase 2: Database (Week 1)
- SQLite setup
- Schema implementation
- Cloud sync

### Phase 3-5: Core UI (Weeks 2-4)
- Dashboard
- Add transaction form
- Loan cards feed

### Phase 6-9: Features (Weeks 5-7)
- Source buyout
- Interest calculation
- Notifications
- Data export

### Phase 10-12: Polish (Weeks 8-10)
- Loan details
- Cloud backup
- Settings

### Phase 13-14: Launch (Weeks 11-12)
- Testing
- App store deployment

---

## 🐛 Troubleshooting

### Flutter Issues
```bash
# Clean build
flutter clean
flutter pub get

# Check doctor
flutter doctor

# Upgrade Flutter
flutter upgrade
```

### Firebase Issues
- Verify config files are in correct locations
- Check Firebase console for enabled services
- Ensure package names match

### Database Issues
- Check schema.sql syntax
- Verify encryption library installed
- Test with sample data

---

## 📚 Resources

### Flutter
- [Flutter Docs](https://docs.flutter.dev)
- [Dart Language](https://dart.dev)
- [Provider Package](https://pub.dev/packages/provider)

### Firebase
- [Firebase Docs](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev)

### Database
- [SQLite](https://www.sqlite.org/docs.html)
- [sqflite Package](https://pub.dev/packages/sqflite)

---

## 💬 Need Help?

1. Check [Technical Specification](docs/TECHNICAL_SPECIFICATION.md)
2. Review [Architecture](docs/ARCHITECTURE.md)
3. See [Trello Board](https://trello.com/b/Bsvl9AUF/lendledger-development)
4. Check GitHub Issues

---

**Happy Coding! 🎉**
