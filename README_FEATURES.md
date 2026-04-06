# BMI Calculator - Feature Documentation

## New Features (April 6-7, 2026)

### 1. Settings & Preferences Page
- **Location**: `lib/features/bmi/presentation/pages/settings_page.dart`
- **Purpose**: Centralized app configuration and preferences
- **Features**:
  - Measurement unit selection (cm/m/ft for height, kg/lb for weight)
  - Notification settings with time picker
  - Theme appearance options
  - Clean, modular UI with segmented buttons and switches

### 2. Weekly Progress Report  
- **Location**: `lib/features/bmi/presentation/pages/weekly_report_page.dart`
- **Purpose**: Analyze BMI trends and progress over 7 days
- **Features**:
  - Weekly average BMI and weight calculations
  - Daily breakdown table with timestamps
  - Weight change tracking
  - Actionable insights based on progress
  - Graceful handling of insufficient data

### 3. Notification Service
- **Location**: `lib/features/bmi/data/notification_service.dart`
- **Purpose**: Manage app notifications and reminders
- **Features**:
  - Daily reminder notifications at configurable times
  - Weekly progress report reminders
  - Instant notifications
  - Cross-platform support (Android/iOS)
  - Timezone-aware scheduling

## Integration Points

### Home Page Updates
- Added Settings button (gear icon) in header
- Added Weekly Report button (chart icon) in header  
- Both accessible via tap with haptic feedback
- Proper navigation and routing implementation

### main.dart Initialization
- Notifications service initialized on app start
- Daily reminder scheduled at 9:00 AM by default
- Timezone configuration for reliable scheduling

## Dependencies Added
- `flutter_local_notifications: ^17.1.2`
- `timezone: ^0.9.4`

## Testing Checklist
- [x] Settings page navigates correctly
- [x] Weekly report displays data
- [x] Notifications initialize without errors
- [x] All compilation warnings resolved
- [x] Code follows Material3 design patterns
