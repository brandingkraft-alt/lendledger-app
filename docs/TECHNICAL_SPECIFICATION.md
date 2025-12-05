# LendLedger - Technical Specification

## Document Version: 1.0
**Last Updated**: December 5, 2025

---

## Table of Contents
1. [System Architecture](#system-architecture)
2. [Security Requirements](#security-requirements)
3. [Core Features](#core-features)
4. [Data Models](#data-models)
5. [Business Logic](#business-logic)
6. [API Specifications](#api-specifications)
7. [UI/UX Guidelines](#uiux-guidelines)

---

## 1. System Architecture

### Technology Stack

**Mobile Application**
- **Framework**: Flutter (Primary) or React Native (Alternative)
- **Language**: Dart (Flutter) / JavaScript/TypeScript (React Native)
- **State Management**: Provider or Bloc pattern
- **Local Database**: SQLite with encryption
- **Cloud Sync**: Firebase Firestore or Supabase

**Backend Services**
- **Authentication**: Firebase Auth with Biometric integration
- **Cloud Functions**: Firebase Cloud Functions or Supabase Edge Functions
- **Storage**: Encrypted cloud storage for backups
- **Notifications**: Firebase Cloud Messaging (FCM)

**Security Layer**
- **Encryption**: AES-256 for local data
- **Authentication**: Biometric (FaceID/Fingerprint) + PIN fallback
- **Transport**: TLS 1.3 for all network communications

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Mobile Application                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  UI Layer    │  │ Business     │  │  Data Layer  │  │
│  │  (Flutter)   │→ │ Logic Layer  │→ │  (SQLite)    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│         ↓                  ↓                  ↓          │
│  ┌──────────────────────────────────────────────────┐  │
│  │         Biometric Auth + Encryption Layer        │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           ↓
                    ┌──────────────┐
                    │   Internet   │
                    └──────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                   Cloud Services                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Firebase    │  │  Cloud       │  │  Backup      │  │
│  │  Auth        │  │  Functions   │  │  Storage     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Security Requirements

### Priority 1: Authentication
- **Biometric Login**: Mandatory FaceID/Fingerprint on app launch
- **PIN Fallback**: 6-digit PIN if biometric fails
- **Session Management**: Auto-lock after 5 minutes of inactivity
- **Failed Attempts**: Lock app after 3 failed authentication attempts

### Priority 2: Data Encryption
- **At Rest**: AES-256 encryption for all local SQLite data
- **In Transit**: TLS 1.3 for all API communications
- **Backup**: End-to-end encrypted cloud backups
- **Key Management**: Secure key storage using platform keychain

### Priority 3: Audit Trail
- **Immutable Logs**: All deletions logged with timestamp and user
- **Data Snapshot**: Store JSON snapshot of deleted records
- **Retention**: Audit logs retained for 7 years
- **Access Control**: Only user can view their own audit logs

### Priority 4: Compliance
- **Data Privacy**: No third-party data sharing
- **User Control**: User can export and delete all their data
- **Offline First**: App functions fully offline
- **GDPR Ready**: Data portability and right to deletion

---

## 3. Core Features

### 3.1 Dashboard (Home Screen)

**Components:**
1. **Total Outstanding Principal** (Large, bold number)
2. **Interest Accrued** (Live counter, updates daily)
3. **Capital Split Graph** (Donut chart: Self-Funded vs Borrowed)
4. **Due Today Section** (Horizontal scrollable list)

**Calculations:**
```dart
// Total Outstanding Principal
double totalPrincipal = loans.where((l) => l.status == 'active')
                             .fold(0, (sum, loan) => sum + loan.principal);

// Total Interest Accrued
double totalInterest = loans.where((l) => l.status == 'active')
                            .fold(0, (sum, loan) => sum + loan.calculateInterest());

// Capital Split
double selfFunded = loans.where((l) => l.fundSource == 'self_funded')
                         .fold(0, (sum, loan) => sum + loan.principal);
double borrowed = loans.where((l) => l.fundSource == 'borrowed')
                       .fold(0, (sum, loan) => sum + loan.principal);
```

### 3.2 Add Transaction Interface

**Form Fields:**
| Field | Type | Validation | Notes |
|-------|------|------------|-------|
| Borrower Name | Text | Required, 2-100 chars | Contact picker integration |
| Fund Source | Toggle | Required | Self-Funded / Borrowed |
| Transaction Mode | Toggle | Required | Cash / Bank |
| Principal Amount | Numeric | Required, > 0 | Currency formatted |
| Interest Rate | Numeric | Required, 0-100 | Percentage |
| Rate Type | Dropdown | Required | Per Month / Per Year |
| Payment Frequency | Dropdown | Required | Daily / Monthly / Quarterly |
| Loan Start Date | Date | Required | Defaults to today |
| Due Date | Date | Required | Must be > start date |
| Cost of Capital | Numeric | Optional | Only if "Borrowed" selected |

**Conditional Logic:**
```dart
if (fundSource == 'borrowed') {
  showField('costOfCapital');
}
```

### 3.3 Transaction Feed (Card View)

**Visual Logic:**
- **Blue Cards**: Cash transactions
- **Green Cards**: Bank transactions
- **Red Highlight**: Overdue due dates

**Card Layout:**
```
┌─────────────────────────────────────────────┐
│ John Doe                    Due: 12/10/2025 │ ← Header
├─────────────────────────────────────────────┤
│ Principal: ₹10,000                          │
│ Interest Accrued: ₹200                      │
│ Total Due: ₹10,200                          │ ← Body
│ [Self-Funded] [Bank]                        │ ← Tags
├─────────────────────────────────────────────┤
│              [Mark Paid]                    │ ← Footer
└─────────────────────────────────────────────┘
```

**Sorting & Filtering:**
- Default: Sort by nearest due date (ascending)
- Filters: Cash Only, Bank Only, Overdue Only, Self-Funded, Borrowed

### 3.4 Source Buyout Feature

**Location**: Transaction Detail View (for "Borrowed" loans only)

**UI Flow:**
1. User opens a loan tagged as "Borrowed"
2. Button visible: "Repay Lender & Switch to Self-Funded"
3. User taps button
4. Popup appears:
   - Title: "Confirm Source Conversion"
   - Message: "Confirm you have returned the principal to the original lender? This loan will now be tracked as Self-Funded."
   - Input: "Date of Return" (Date picker, defaults to today)
   - Buttons: [Cancel] [Confirm]
5. On Confirm:
   - Update `fund_source` from 'borrowed' to 'self_funded'
   - Set `original_fund_source` = 'borrowed'
   - Set `source_converted_at` = selected date
   - Stop tracking `cost_of_capital` from this date forward
   - **Important**: Do NOT change loan start date, interest rate, or borrower terms

**Database Update:**
```sql
UPDATE loans 
SET 
  fund_source = 'self_funded',
  original_fund_source = 'borrowed',
  source_converted_at = :conversion_date,
  updated_at = CURRENT_TIMESTAMP
WHERE loan_id = :loan_id;
```

**Business Logic:**
```dart
void convertToSelfFunded(String loanId, DateTime conversionDate) {
  // Fetch loan
  Loan loan = getLoanById(loanId);
  
  // Validate
  if (loan.fundSource != 'borrowed') {
    throw Exception('Only borrowed loans can be converted');
  }
  
  // Calculate interest paid to lender (optional tracking)
  double interestPaidToLender = loan.calculateInterestUpToDate(conversionDate);
  
  // Update loan
  loan.originalFundSource = loan.fundSource;
  loan.fundSource = 'self_funded';
  loan.sourceConvertedAt = conversionDate;
  loan.costOfCapital = null; // Stop tracking
  
  // Save
  saveLoan(loan);
  
  // Audit log
  logAudit('source_conversion', loan.loanId, {
    'from': 'borrowed',
    'to': 'self_funded',
    'conversion_date': conversionDate,
    'interest_paid_to_lender': interestPaidToLender
  });
}
```

### 3.5 Data Export Feature

**Location**: Settings → Export Data

**Export Format**: Excel (.xlsx) or CSV

**Columns:**
| Column | Description | Example |
|--------|-------------|---------|
| Date | Loan start date | 12/01/2025 |
| Borrower Name | Name of borrower | John Doe |
| Type | Cash or Bank | Bank |
| Source | Self-Funded or Borrowed | Self-Funded |
| Status | Active/Paid/Overdue | Active |
| Principal | Principal amount | 10,000 |
| Rate | Interest rate | 2% |
| Interest Accrued | Calculated interest | 200 |
| Total Due | Principal + Interest | 10,200 |
| Due Date | Payment due date | 15/02/2025 |

**Implementation:**
```dart
Future<File> exportToExcel() async {
  var excel = Excel.createExcel();
  Sheet sheet = excel['Loans'];
  
  // Headers
  sheet.appendRow(['Date', 'Borrower Name', 'Type', 'Source', 'Status', 
                   'Principal', 'Rate', 'Interest Accrued', 'Total Due', 'Due Date']);
  
  // Data rows
  for (var loan in loans) {
    sheet.appendRow([
      loan.loanStartDate.toString(),
      loan.borrowerName,
      loan.transactionMode,
      loan.fundSource,
      loan.status,
      loan.principalAmount,
      '${loan.interestRate}%',
      loan.calculateInterest(),
      loan.principalAmount + loan.calculateInterest(),
      loan.dueDate.toString()
    ]);
  }
  
  // Save and share
  var fileBytes = excel.save();
  var file = File('${directory.path}/lendledger_export.xlsx');
  await file.writeAsBytes(fileBytes);
  
  return file;
}
```

---

## 4. Data Models

### Loan Model
```dart
class Loan {
  String loanId;
  String userId;
  String borrowerId;
  
  // Financial
  double principalAmount;
  double interestRate;
  String interestRateType; // 'monthly' or 'yearly'
  String paymentFrequency; // 'daily', 'monthly', 'quarterly'
  
  // Source tracking
  String fundSource; // 'self_funded' or 'borrowed'
  String transactionMode; // 'cash' or 'bank'
  double? costOfCapital; // Optional, only for borrowed
  
  // Source buyout tracking
  String? originalFundSource;
  DateTime? sourceConvertedAt;
  String? sourceConversionNotes;
  
  // Dates
  DateTime loanStartDate;
  DateTime dueDate;
  
  // Status
  String status; // 'active', 'paid', 'overdue', 'defaulted'
  
  // Timestamps
  DateTime createdAt;
  DateTime updatedAt;
  
  // Calculated fields
  double calculateInterest() {
    int daysSinceStart = DateTime.now().difference(loanStartDate).inDays;
    double rate = interestRate / 100;
    
    if (interestRateType == 'yearly') {
      return principalAmount * rate * (daysSinceStart / 365);
    } else {
      return principalAmount * rate * (daysSinceStart / 30);
    }
  }
  
  double getTotalDue() {
    return principalAmount + calculateInterest();
  }
  
  bool isOverdue() {
    return DateTime.now().isAfter(dueDate) && status == 'active';
  }
}
```

---

## 5. Business Logic

### 5.1 Interest Calculation

**Formula**: Simple Interest
```
I = P × r × t

Where:
I = Interest Accrued
P = Principal Amount
r = Rate per period (as decimal)
t = Time periods elapsed
```

**Implementation:**
```dart
double calculateSimpleInterest({
  required double principal,
  required double rate,
  required String rateType,
  required DateTime startDate,
  DateTime? endDate,
}) {
  endDate ??= DateTime.now();
  int daysDifference = endDate.difference(startDate).inDays;
  
  double rateDecimal = rate / 100;
  double timePeriods;
  
  if (rateType == 'yearly') {
    timePeriods = daysDifference / 365.0;
  } else if (rateType == 'monthly') {
    timePeriods = daysDifference / 30.0;
  } else {
    throw ArgumentError('Invalid rate type');
  }
  
  return principal * rateDecimal * timePeriods;
}
```

### 5.2 Notification Logic

**Trigger Times:**
- **T-3 Days**: "Reminder: Payment from [Name] due in 3 days."
- **T-0 Days** (9:00 AM): "Due Today: Collect ₹[Amount] from [Name]."
- **T+1 Days** (9:00 AM): "Overdue: [Name] missed their payment."

**Implementation:**
```dart
void scheduleNotifications(Loan loan) {
  // T-3 notification
  DateTime threeDaysBefore = loan.dueDate.subtract(Duration(days: 3));
  scheduleNotification(
    id: '${loan.loanId}_t3',
    title: 'Payment Reminder',
    body: 'Payment from ${loan.borrowerName} due in 3 days.',
    scheduledDate: threeDaysBefore.add(Duration(hours: 9)),
  );
  
  // T-0 notification
  scheduleNotification(
    id: '${loan.loanId}_t0',
    title: 'Due Today',
    body: 'Collect ₹${loan.getTotalDue()} from ${loan.borrowerName}.',
    scheduledDate: loan.dueDate.add(Duration(hours: 9)),
  );
  
  // T+1 notification
  DateTime oneDayAfter = loan.dueDate.add(Duration(days: 1));
  scheduleNotification(
    id: '${loan.loanId}_t1',
    title: 'Overdue Payment',
    body: '${loan.borrowerName} missed their payment.',
    scheduledDate: oneDayAfter.add(Duration(hours: 9)),
  );
}
```

### 5.3 Source Conversion Logic

**Critical Rules:**
1. Only "Borrowed" loans can be converted to "Self-Funded"
2. Conversion does NOT affect:
   - Loan start date
   - Interest rate
   - Borrower terms
   - Accrued interest calculation
3. Conversion DOES affect:
   - Fund source tag
   - Cost of capital tracking (stops from conversion date)
   - Profit calculation (if tracking net profit)

**Profit Calculation (Advanced):**
```dart
double calculateNetProfit(Loan loan) {
  double totalInterestEarned = loan.calculateInterest();
  
  if (loan.originalFundSource == 'borrowed' && loan.sourceConvertedAt != null) {
    // Calculate interest paid to lender up to conversion date
    double interestPaidToLender = calculateSimpleInterest(
      principal: loan.principalAmount,
      rate: loan.costOfCapital ?? 0,
      rateType: loan.interestRateType,
      startDate: loan.loanStartDate,
      endDate: loan.sourceConvertedAt,
    );
    
    return totalInterestEarned - interestPaidToLender;
  } else if (loan.fundSource == 'borrowed') {
    // Still borrowed, calculate ongoing cost
    double interestPaidToLender = calculateSimpleInterest(
      principal: loan.principalAmount,
      rate: loan.costOfCapital ?? 0,
      rateType: loan.interestRateType,
      startDate: loan.loanStartDate,
    );
    
    return totalInterestEarned - interestPaidToLender;
  } else {
    // Self-funded from start
    return totalInterestEarned;
  }
}
```

---

## 6. API Specifications

### 6.1 REST API Endpoints

**Base URL**: `https://api.lendledger.com/v1`

#### Authentication
```
POST /auth/login
POST /auth/logout
POST /auth/refresh-token
```

#### Loans
```
GET    /loans                    # List all loans
POST   /loans                    # Create new loan
GET    /loans/:id                # Get loan details
PUT    /loans/:id                # Update loan
DELETE /loans/:id                # Delete loan (with audit)
POST   /loans/:id/convert-source # Convert borrowed to self-funded
POST   /loans/:id/mark-paid      # Mark loan as paid
```

#### Borrowers
```
GET    /borrowers                # List all borrowers
POST   /borrowers                # Create borrower
GET    /borrowers/:id            # Get borrower details
PUT    /borrowers/:id            # Update borrower
DELETE /borrowers/:id            # Delete borrower
```

#### Payments
```
GET    /payments                 # List all payments
POST   /payments                 # Record payment
GET    /payments/:id             # Get payment details
```

#### Export
```
GET    /export/excel             # Export data to Excel
GET    /export/csv               # Export data to CSV
```

---

## 7. UI/UX Guidelines

### Color Scheme
- **Primary**: #2196F3 (Blue) - Cash transactions
- **Secondary**: #4CAF50 (Green) - Bank transactions
- **Accent**: #FF5722 (Red) - Overdue/Alerts
- **Background**: #FFFFFF (White)
- **Text**: #212121 (Dark Gray)

### Typography
- **Headers**: Roboto Bold, 24px
- **Body**: Roboto Regular, 16px
- **Captions**: Roboto Light, 14px

### Card Design
- **Border Radius**: 12px
- **Shadow**: Elevation 2
- **Padding**: 16px
- **Margin**: 8px

### Accessibility
- **Minimum Touch Target**: 48x48 dp
- **Contrast Ratio**: 4.5:1 for text
- **Font Scaling**: Support system font sizes
- **Screen Reader**: Full VoiceOver/TalkBack support

---

## 8. Testing Requirements

### Unit Tests
- Interest calculation accuracy
- Date calculations
- Source conversion logic
- Data validation

### Integration Tests
- Database operations
- API calls
- Authentication flow
- Notification scheduling

### UI Tests
- Navigation flows
- Form validation
- Card interactions
- Export functionality

### Security Tests
- Encryption verification
- Authentication bypass attempts
- Data leakage checks
- Audit log integrity

---

## 9. Deployment Checklist

- [ ] Code review completed
- [ ] All tests passing
- [ ] Security audit completed
- [ ] Database migrations tested
- [ ] Backup/restore tested
- [ ] Performance benchmarks met
- [ ] App store assets prepared
- [ ] Privacy policy updated
- [ ] Terms of service updated
- [ ] User documentation complete

---

**Document End**
