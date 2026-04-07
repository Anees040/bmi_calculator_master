# Testing Guide - New Features

## Manual Testing Checklist

### Settings Page
- [ ] Navigate to Settings using header gear icon
- [ ] Confirm AppBar displays "Settings & Preferences"
- [ ] Test height unit selection:
  - [ ] Centimeter option selectable
  - [ ] Meter option selectable
  - [ ] Feet option selectable
- [ ] Test weight unit selection:
  - [ ] Kilogram option selectable
  - [ ] Pound option selectable
- [ ] Verify notification toggle works
- [ ] Test daily reminder time picker (0-23 hours)
- [ ] Confirm theme toggle functionality
- [ ] Navigate back to home page
- [ ] Verify app state is maintained

### Weekly Report Page
- [ ] Navigate to Weekly Report using header chart icon
- [ ] With less than 2 records:
  - [ ] Shows "Not enough data" message
  - [ ] Provides helpful prompt to log BMI data
  - [ ] Back button works correctly
- [ ] With sufficient history:
  - [ ] Displays week metrics section
  - [ ] Shows "Average BMI" card with correct calculation
  - [ ] Shows "Average Weight" card
  - [ ] Shows "Weight Change" indicator
  - [ ] Displays daily breakdown table
  - [ ] Table shows: Date, BMI, Weight, Status columns
  - [ ] Shows insights section with summary
- [ ] Scroll functionality works smoothly
- [ ] Navigate back to home page

### Notification Service
- [ ] App starts without crash
- [ ] No console errors on initialization
- [ ] Daily reminder can be verified in:
  - [ ] Android: Settings > Notifications (if available)
  - [ ] iOS: Settings > Notifications
- [ ] Test notification scheduling:
  - [ ] Android notifications display correctly
  - [ ] iOS notifications display correctly
- [ ] Verify notification channel name: "Daily BMI Reminder"

### Home Page Integration
- [ ] Settings button appears in header (gear icon)
- [ ] Weekly Report button appears in header (chart icon)
- [ ] Theme toggle button remains visible
- [ ] Logo and title display correctly
- [ ] Navigation to Settings works
- [ ] Navigation to Weekly Report works
- [ ] Haptic feedback triggers on button press
- [ ] All three tabs still functional:
  - [ ] Dashboard tab loads
  - [ ] Tracker tab loads
  - [ ] Insights tab loads

## Widget Testing
- Settings page constructs without errors
- Weekly report gracefully handles empty history
- Notification service initializes without exceptions

## Platform-Specific Testing

### Android
- [ ] Notifications appear in system tray
- [ ] Notifications have correct app icon
- [ ] Tapping notification dismisses it
- [ ] Daily reminder persists across app restart

### iOS
- [ ] Notifications display in Notification Center
- [ ] Notification sound plays (if enabled)
- [ ] Notification badge appears on app icon
- [ ] Weekly report data displays correctly without lag

## Performance Checks
- [ ] App doesn't stutter when opening Settings page
- [ ] Weekly report loads quickly with 100+ history items
- [ ] No memory leaks after navigation
- [ ] Notification initialization doesn't delay app startup
