# Contributing to LendLedger

Thank you for your interest in contributing to LendLedger! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Maintain professional communication

## Getting Started

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/lendledger-app.git
   ```
3. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### 1. Pick a Task
- Check the [Trello Board](https://trello.com/b/Bsvl9AUF/lendledger-development)
- Choose an unassigned card from "To Do"
- Move it to "Doing" and assign yourself

### 2. Write Code
- Follow the coding standards below
- Write tests for new features
- Update documentation as needed

### 3. Test Your Changes
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Check code formatting
flutter format .

# Analyze code
flutter analyze
```

### 4. Commit Your Changes
```bash
git add .
git commit -m "feat: add source buyout feature"
```

**Commit Message Format:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Adding tests
- `chore:` Maintenance tasks

### 5. Push and Create PR
```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub with:
- Clear title and description
- Reference to Trello card
- Screenshots (if UI changes)
- Test results

## Coding Standards

### Dart/Flutter
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Use const constructors where possible

### File Organization
```
lib/
├── models/          # Data models
├── screens/         # UI screens
├── widgets/         # Reusable widgets
├── providers/       # State management
├── services/        # Business logic
└── utils/           # Utility functions
```

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`
- **Private**: `_leadingUnderscore`

### Example Code Style
```dart
// Good
class LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;
  
  const LoanCard({
    super.key,
    required this.loan,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getCardColor(),
      child: ListTile(
        title: Text(loan.borrowerName),
        subtitle: Text('₹${loan.getTotalDue()}'),
        onTap: onTap,
      ),
    );
  }
  
  Color _getCardColor() {
    return loan.transactionMode == 'cash' 
        ? Colors.blue 
        : Colors.green;
  }
}
```

## Testing Guidelines

### Unit Tests
- Test all business logic
- Test edge cases
- Mock external dependencies

```dart
test('calculateInterest returns correct value', () {
  final loan = Loan(
    principalAmount: 10000,
    interestRate: 2,
    interestRateType: 'monthly',
    loanStartDate: DateTime(2024, 1, 1),
    // ... other required fields
  );
  
  final interest = loan.calculateInterest(
    endDate: DateTime(2024, 2, 1),
  );
  
  expect(interest, 200.0);
});
```

### Integration Tests
- Test complete user flows
- Test database operations
- Test API integrations

## Documentation

### Code Comments
```dart
/// Calculates simple interest for the loan.
/// 
/// Uses the formula: I = P × r × t
/// 
/// [endDate] defaults to current date if not provided.
/// Returns the calculated interest amount.
double calculateInterest({DateTime? endDate}) {
  // Implementation
}
```

### README Updates
- Update README.md for new features
- Add examples for new APIs
- Update installation instructions if needed

## Pull Request Process

1. **Ensure all tests pass**
2. **Update documentation**
3. **Add screenshots for UI changes**
4. **Request review from maintainers**
5. **Address review feedback**
6. **Wait for approval and merge**

### PR Checklist
- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No console errors/warnings
- [ ] Tested on iOS and Android
- [ ] Trello card updated

## Security

### Reporting Vulnerabilities
- **DO NOT** create public issues for security vulnerabilities
- Email security concerns privately
- Provide detailed reproduction steps
- Allow time for fix before disclosure

### Security Best Practices
- Never commit API keys or secrets
- Use environment variables for sensitive data
- Validate all user inputs
- Sanitize data before database operations
- Use parameterized queries

## Feature Requests

1. Check existing issues/cards
2. Create detailed Trello card or GitHub issue
3. Explain use case and benefits
4. Provide mockups if applicable
5. Discuss with maintainers before implementing

## Bug Reports

Include:
- Clear description
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/videos
- Device/OS information
- App version

## Questions?

- Check [Technical Specification](docs/TECHNICAL_SPECIFICATION.md)
- Review [Architecture](docs/ARCHITECTURE.md)
- Ask on GitHub Discussions
- Comment on Trello cards

---

**Thank you for contributing to LendLedger! 🎉**
