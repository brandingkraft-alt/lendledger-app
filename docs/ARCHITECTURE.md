# LendLedger - System Architecture

## Architecture Diagrams

### 1. User Flow Diagram
![User Flow](https://external-agents.nyc3.digitaloceanspaces.com/mermaid-diagrams/2025-12-05T02-20-20-11674584-52dc-416f-b974-c32641d4ddad-generate_flowchart-1764901220177.png)

**Description**: Complete user journey from app launch through authentication, dashboard navigation, loan management, and source buyout feature.

### 2. System Architecture
![System Architecture](https://external-agents.nyc3.digitaloceanspaces.com/mermaid-diagrams/2025-12-05T02-20-22-c1fda822-5d06-4a74-96f3-86d4e1e88971-generate_flowchart-1764901222918.png)

**Description**: Three-layer architecture showing Mobile App Layer, Security Layer, and Cloud Services with their interactions.

### 3. Source Buyout Sequence
![Source Buyout Flow](https://external-agents.nyc3.digitaloceanspaces.com/mermaid-diagrams/2025-12-05T02-20-26-93464507-b6e7-4372-bfc0-d6c5b3e8d3c3-generate_sequence_diagram-1764901226623.png)

**Description**: Detailed sequence diagram showing the complete source buyout feature workflow from user action to database update.

---

## Architecture Overview

### Mobile Application Layer
- **UI Components**: Flutter widgets for all screens
- **State Management**: Provider/Bloc for reactive state
- **Local Database**: Encrypted SQLite for offline-first functionality

### Security Layer
- **Biometric Authentication**: FaceID/Fingerprint integration
- **Encryption**: AES-256 for all local data
- **Audit Logs**: Immutable transaction history

### Cloud Services
- **Firebase Auth**: User authentication and session management
- **Cloud Functions**: Serverless backend logic
- **Cloud Storage**: Encrypted backup storage
- **FCM**: Push notifications for payment reminders

---

## Data Flow

### Loan Creation Flow
1. User fills form → Validation
2. Data encrypted → Saved to SQLite
3. Notifications scheduled
4. Background sync to cloud (if online)

### Interest Calculation Flow
1. Daily background job runs
2. Calculates interest for all active loans
3. Updates dashboard counters
4. Triggers notifications if due dates approaching

### Source Buyout Flow
1. User initiates conversion
2. Confirmation dialog with date picker
3. Database transaction:
   - Update fund_source
   - Store original_fund_source
   - Set conversion_date
   - Stop cost_of_capital tracking
4. Audit log entry created
5. UI updates to reflect changes

---

## Security Architecture

### Authentication Flow
```
App Launch → Biometric Check → Success → Dashboard
                ↓ Fail
            PIN Entry → Success → Dashboard
                ↓ 3 Fails
            App Locked → Requires Device Unlock
```

### Data Encryption
- **At Rest**: All SQLite data encrypted with AES-256
- **In Transit**: TLS 1.3 for all API calls
- **Keys**: Stored in platform keychain (iOS Keychain / Android Keystore)

### Audit Trail
- All deletions logged with full data snapshot
- Logs are immutable (append-only)
- Includes timestamp, user ID, action type, and data

---

## Scalability Considerations

### Performance Optimization
- Lazy loading for large loan lists
- Indexed database queries
- Cached calculations for dashboard
- Background sync with exponential backoff

### Offline Support
- Full functionality without internet
- Queue-based sync when connection restored
- Conflict resolution for concurrent edits

---

## Technology Decisions

### Why Flutter?
- Single codebase for iOS and Android
- Native performance
- Rich widget library
- Strong community support

### Why SQLite?
- Lightweight and fast
- Excellent encryption support
- Proven reliability
- Works offline

### Why Firebase?
- Easy authentication integration
- Scalable cloud functions
- Real-time sync capabilities
- Built-in analytics

---

## Future Enhancements

### Phase 2 Features
- Multi-currency support
- Advanced analytics dashboard
- Borrower credit scoring
- Automated payment reminders via SMS
- Integration with banking APIs
- Team collaboration features
- Custom report generation

### Technical Improvements
- GraphQL API for flexible queries
- Machine learning for default prediction
- Blockchain for audit trail immutability
- Progressive Web App (PWA) version
