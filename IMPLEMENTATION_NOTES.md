# Implementation Notes

## Settings Page Implementation Details

### Unit Selection Implementation
The SettingsPage uses `SegmentedButton<String>` for unit selection because:
1. **Mutually Exclusive Options**: Only one unit can be selected at a time
2. **Clear Visual State**: Selected option is highlighted
3. **Compact UI**: Takes less space than RadioButtons
4. **Material3 Compliant**: Matches current design system

### Available Units
- **Height**: cm (centimeter), m (meter), ft (feet)
- **Weight**: kg (kilogram), lb (pound)

### Notification Section Architecture
- Toggle enables/disables notifications globally
- Conditional rendering: time picker shows only when enabled
- Hour slider: 0-23 (24-hour format)
- Minute: Fixed at 00 (can be extended with minute slider)

### Future Enhancement Path
```
Current State:
├── Unit Setting (UI only)
├── Notification Toggle (UI only)
└── Reminder Time (UI only)

Future State:
├── Unit Setting → SharedPreferences storage
├── Notification State → Device notification permissions
└── Reminder Schedule → NotificationService integration
```

---

## Weekly Report Calculation Examples

### With History Data
Input: 7 BMI records from different days
Output:
- Average BMI: Sum of all BMI / Count
- Average Weight: Sum of all weights / Count  
- Weight Change: Last weight - First weight (%age)
- Daily breakdown: Table with formatted data

### Without Sufficient Data
Input: < 2 BMI records
Output: "Not enough data" message with helpful prompt

### Insight Generation Logic
The insights section analyzes the calculated metrics:
- **High BMI**: "Focus on maintaining healthy habits"
- **Positive Change**: "Great progress! Keep it up!"
- **Minimal Change**: "Steady progress towards your goals"
- **Negative Change**: "Consider adjusting your routine"

---

## Notification Service Implementation

### Singleton Pattern
```dart
static final NotificationService _instance = NotificationService._internal();

factory NotificationService() {
  return _instance;
}

NotificationService._internal();
```

**Benefit**: Only one notification manager instance throughout app lifetime

### Initialization Sequence
1. **App Start**: NotificationService().initializeNotifications() called
2. **Android Setup**: Notification channel configured
3. **iOS Setup**: Permission request prepared
4. **Plugin Listen**: Ready to receive notification responses
5. **Schedule Daily**: 9:00 AM reminder scheduled

### Timezone Handling
```
System Time: 15:30 PKT (UTC+5)
Scheduled Time: 09:00 (Any timezone)
Package: timezone converts to system timezone
Result: Notification fires at 9:00 system time daily
```

### Recurring Notification Pattern
- **Daily**: Repeats at same time every day
- **Weekly**: Repeats on same day/time each week
- **Both**: Non-cancelling (can coexist)

---

## Home Page Integration

### Header Button Arrangement
```
Before:
[Logo] [Title] [Theme Toggle]

After:
[Logo] [Title] [Weekly Report] [Settings] [Theme Toggle]
```

### Navigation Flow
```
Home Page
├── Settings Button → SettingsPage
│   (Material Navigation)
├── Weekly Report Button → WeeklyReportPage
│   (Receives history list)
└── [Existing tabs continue]
```

### Haptic Feedback
```dart
onPressed: () {
  _tapFeedback();  // Haptic feedback
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => SettingsPage()),
  );
}
```

---

## main.dart Initialization Order

### Current Implementation
```
1. WidgetsFlutterBinding.ensureInitialized()
   ↓
2. NotificationService().initializeNotifications()
   ↓
3. NotificationService().scheduleDailyReminder(hour: 9, minute: 0)
   ↓
4. SystemChrome.setPreferredOrientations()
   ↓
5. runApp(const MyApp())
```

### Why Async main()?
- NotificationService initialization is async (async/await on plugins)
- Must complete before app starts
- Non-blocking with proper await
- Minimal startup delay (typically <100ms)

---

## Dependencies & Packages

### flutter_local_notifications ^17.1.2

**Key Features**:
- Cross-platform (Android, iOS, Web, macOS, Linux)
- Multiple notification channels (Android)
- Recurring notifications
- Notification lifecycle management

**Usage**:
```dart
final plugin = FlutterLocalNotificationsPlugin();
await plugin.initialize(settings);
await plugin.zonedSchedule(...);
```

### timezone ^0.9.4

**Purpose**: Timezone-aware scheduling

**Problem Solved**:
- Without timezone: Notification time jumps when app changes timezone
- With timezone: Notification respects system timezone changes

**Usage**:
```dart
final scheduledTime = tz.TZDateTime.now(tz.local)
    .add(Duration(hours: 1));
```

---

## Error Handling Strategy

### Settings Page
- Local state only: No external errors possible
- Future: Will need null-safety for SharedPreferences

### Weekly Report
- Edge case: Fewer than 2 records handled explicitly
- Shows user-friendly message: "Not enough data yet"
- Prevents calculation errors

### Notification Service
- Platform exceptions: Try-catch blocks in each method
- Print error messages for debugging
- Graceful degradation if notifications unavailable
- Future: Could implement error logging service

---

## Performance Optimization Notes

### Memory
- Notification service: Singleton (single instance)
- Settings page: Only widget state in memory (minimal)
- Weekly report: Data passed from parent (no local storage)

### Rendering
- SegmentedButton: Native render (efficient)
- Weekly table: ListView with separator (optimized)
- Settings cards: Reusable widgets (no duplication)

### Calculations
- Weekly report aggregations: O(n) where n = records in week
- No complex algorithms
- Lazy evaluation in display

---

## Testing Strategy

### Unit Testing (Future)
```
- SettingsPage state management
- WeeklyReportPage calculations
- NotificationService scheduling
- Date/time utilities
```

### Widget Testing (Future)
```
- Settings UI renders correctly
- Report displays with sample data
- Navigation works properly
- Buttons respond to taps
```

### Integration Testing (Future)
```
- Full app flow with new features
- Notification persistence across restarts
- Feature persistence across sessions
- Cross-tab navigation
```

---

## Known Limitations & Future Work

### Settings Page
- **Current**: UI-only, no persistence
- **Future**: Add SharedPreferences integration
- **Impact**: Settings reset on app restart currently

### Weekly Report
- **Current**: Only 7-day window
- **Future**: Configurable date ranges
- **Impact**: No monthly/3-month comparisons yet

### Notifications
- **Current**: Text-only notifications
- **Future**: Custom sounds, actions, progress bars
- **Impact**: Cannot interact with notification directly

### Localization
- **Current**: English only
- **Future**: i18n support
- **Impact**: No language selection currently

---

## Debugging Tips

### For Settings Page Issues
1. Check `_selectedHeightUnit` and `_selectedWeightUnit` values
2. Verify SegmentedButton selected set is not empty
3. Check theme brightness for isDark switch

### For Weekly Report Issues
1. Verify history list has at least 2 items
2. Check BMI calculation formulas
3. Confirm date formatting matches locale

### For Notification Service Issues
1. Check Android notification channel configuration
2. Verify timezone package is initialized
3. Confirm app has notification permissions
4. Check device quiet hours settings

