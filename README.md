# LendLedger

**Professional Loan Tracking Application for Money Lenders**

## Overview

LendLedger is a mobile application designed for professional money lenders to track loans, manage interest accruals, and monitor payment schedules. The app distinguishes itself by tracking the source of capital (Self-funded vs. Borrowed) and the mode of transfer (Cash vs. Bank).

## Key Features

### Core Functionality
- **Dual Capital Tracking**: Track Self-Funded vs Borrowed capital
- **Visual Transaction Modes**: Cash (Blue) and Bank (Green) color coding
- **Real-time Interest Calculations**: Automatic simple interest accrual
- **Payment Tracking**: Due date monitoring with smart notifications
- **Source Buyout**: Convert borrowed loans to self-funded when you repay the original lender

### Security Features
- Biometric Authentication (FaceID/Fingerprint)
- AES-256 Local Encryption
- Optional Encrypted Cloud Backup
- Immutable Audit Logs

### User Experience
- Comprehensive Dashboard with financial overview
- Transaction Feed with color-coded cards
- Smart notifications (T-3, T-0, T+1 days)
- Excel/CSV data export
- Contact integration

## Tech Stack

- **Framework**: Flutter (recommended) or React Native
- **Database**: SQLite (local) + Firebase/Supabase (cloud sync)
- **State Management**: Provider/Bloc
- **Authentication**: Firebase Auth with Biometric
- **Storage**: Encrypted local storage with cloud backup

## Project Structure

```
lendledger-app/
├── mobile/                 # Flutter/React Native app
│   ├── lib/               # Source code
│   ├── assets/            # Images, fonts
│   └── test/              # Unit tests
├── backend/               # Cloud functions
│   ├── functions/         # Firebase/Supabase functions
│   └── database/          # Schema definitions
├── docs/                  # Documentation
│   ├── api/              # API documentation
│   ├── design/           # Design specs
│   └── architecture/     # System architecture
└── scripts/              # Build and deployment scripts
```

## Getting Started

### Prerequisites
- Flutter SDK 3.0+ or React Native
- Firebase/Supabase account
- iOS/Android development environment

### Installation

```bash
# Clone the repository
git clone https://github.com/brandingkraft-alt/lendledger-app.git
cd lendledger-app

# Install dependencies
cd mobile
flutter pub get  # or npm install for React Native

# Run the app
flutter run  # or npm start
```

## Database Schema

See `backend/database/schema.sql` for complete database structure.

## Features in Detail

### 1. Dashboard
- Total Outstanding Principal
- Interest Accrued (live counter)
- Capital Split Graph (Self vs Borrowed)
- "Due Today" horizontal scroll

### 2. Transaction Management
- Add new loans with borrower details
- Track fund source and transaction mode
- Set interest rates and payment frequency
- Edit/Delete with audit trail

### 3. Source Buyout Feature
- Convert "Borrowed" loans to "Self-Funded"
- Maintains loan history and borrower terms
- Stops cost-of-capital tracking from conversion date

### 4. Data Export
- Export to Excel (.xlsx) or CSV
- Share via email, WhatsApp, or save to files
- Comprehensive transaction history

## Interest Calculation

Simple Interest Formula:
```
I = P × r × t
Total Amount = P + I
```

Where:
- I = Interest Accrued
- P = Principal Amount
- r = Rate per period (decimal)
- t = Time periods elapsed

## Security & Compliance

- All data encrypted at rest (AES-256)
- Biometric authentication required
- Audit logs for all deletions
- Optional cloud backup with encryption
- No data shared with third parties

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is proprietary software. All rights reserved.

## Contact

Project Link: [https://github.com/brandingkraft-alt/lendledger-app](https://github.com/brandingkraft-alt/lendledger-app)

---

**Built with ❤️ for professional money lenders**
