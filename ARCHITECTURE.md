# Architecture & Design Decisions

## Feature Architecture

### Settings Page
- **Pattern**: StatefulWidget with local state management
- **Design**: Material3 with segmented buttons and switches
- **Structure**: 
  - Measurement Units Section
  - Notifications Section  
  - Appearance Section
  - About Section
- **State Management**: Local setState (no external state management)
- **Persistence**: Ready for SharedPreferences integration

### Weekly Report Page
- **Pattern**: StatelessWidget (pure data display)
- **Design**: Material3 cards with metrics display
- **Structure**:
  - Week metrics cards (average BMI, weight, change)
  - Daily breakdown table
  - Insights generator
- **Data Flow**: Receives BmiRecord list from parent
- **Edge Cases**: Handles <2 records gracefully with message

### Notification Service
- **Pattern**: Singleton (ensures single instance)
- **Implementation**: Factory pattern for instance creation
- **Platforms**: Android + iOS support
- **Scheduling**: Timezone-aware using `timezone` package
- **Features**:
  - Daily recurring reminders
  - Weekly report notifications
  - Instant notifications
  - Cross-platform consistency

## Integration Points

### Home Page Enhancements
- Added two new navigation buttons in header:
  - Settings button (gear icon) - opens SettingsPage
  - Weekly Report button (chart icon) - opens WeeklyReportPage
- Buttons positioned between content and theme toggle
- Haptic feedback on button press
- Navigation via Navigator.push

### Main.dart Changes
- Made main() async to support async initialization
- Calls NotificationService().initializeNotifications()
- Schedules daily morning reminder at 9:00 AM
- Non-blocking: notification initialization doesn't delay app startup

## Design Rationale

### Why Singleton for NotificationService?
- Only need one instance managing notifications throughout app
- Prevents duplicate notification registrations
- Easier to access from anywhere with NotificationService()
- Matches common notification service patterns

### Why StatelessWidget for WeeklyReportPage?
- Pure data display widget (no internal state changes)
- History provided by parent
- Simpler, more predictable behavior
- Better performance (no rebuilds except parent)

### Why Local State in SettingsPage?
- First version focuses on UI without persistence
- Can be upgraded to persist via SharedPreferences later
- Clean separation between UI and data layer
- Allows for undo/cancel operations easily

### Unit Selection Approach
- Uses SegmentedButton for clear options
- Metric (cm/m/ft) and Imperial (ft/lb) support
- Ready for calculation unit conversion layer
- Extensible for future unit types

## Dependencies Rationale

### flutter_local_notifications ^17.1.2
- Mature, well-maintained package
- Active development and bug fixes
- Comprehensive platform support
- Community adoption and examples

### timezone ^0.9.4
- Essential for reliable recurring notifications
- Handles daylight saving time
- Converts system time correctly
- Small package with minimal overhead

## Future Improvements

### Settings Persistence
- [ ] Add SharedPreferences integration
- [ ] Persist unit selections
- [ ] Remember notification preferences
- [ ] Save theme preference

### Notification Enhancements  
- [ ] Custom notification sounds
- [ ] Notification action buttons
- [ ] User-configurable notification times
- [ ] Push notifications from backend

### Weekly Report Features
- [ ] Export report as PDF
- [ ] Share weekly report
- [ ] Goal progress tracking
- [ ] Comparative analysis (week-over-week)

### Mobile-Specific Refinements
- [ ] Android: Rich notification with progress bar
- [ ] iOS: Alert styles and actions
- [ ] Platform-specific gesture feedback
- [ ] Adaptive UI for different screen sizes

## Performance Considerations

### Settings Page
- Lightweight: only local variables
- No database queries
- Quick render time
- Should load in <100ms

### Weekly Report
- Optimized calculation algorithms
- Handles 1000+ history items efficiently
- Lazy-calculates only visible data
- Should load in <200ms even with large history

### Notifications
- Initialized once at app startup
- Async operations don't block main thread
- Minimal memory footprint
- Background scheduling is efficient

## Security & Privacy

### Settings
- All settings stored locally (no server communication)
- No PII in settings
- No sensitive data exposure

### Notifications
- No personal data in notification text
- Generic reminder messages
- Local scheduling (no API calls)
- No third-party integration

### Weekly Report
- Calculations done locally
- No data sent to external services
- Privacy-respecting analytics
