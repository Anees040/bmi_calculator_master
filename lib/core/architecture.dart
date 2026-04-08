/// Architecture documentation and patterns
library architecture;

/// Layer descriptions
const String layerDescriptions = '''
# BMI Calculator - Architecture Documentation

## Clean Architecture Layers

### 1. Presentation Layer
- **Purpose**: UI and user interactions
- **Location**: lib/features/bmi/presentation/
- **Components**:
  - Pages: Screen-level widgets
  - Widgets: Reusable UI components
  - Formatters: Input validation and formatting
  - Animations: Transition and motion effects

### 2. Domain Layer
- **Purpose**: Business logic and entities
- **Location**: lib/features/bmi/domain/
- **Components**:
  - Models: Data structures (bmi_models.dart)
  - Repositories: Abstract interfaces
  - UseCases: Business operations
  - Services: Domain-specific services
  - Utils: Domain logic helpers
  - Validation: Business rules validation

### 3. Data Layer
- **Purpose**: Data access and persistence
- **Location**: lib/features/bmi/data/
- **Components**:
  - Repositories: Implementation of domain interfaces
  - Services: External API and database access
  - Models: Data transfer objects

### 4. Core Layer
- **Purpose**: Cross-cutting concerns
- **Location**: lib/core/
- **Components**:
  - Constants: App-wide constants
  - Extensions: Utility extensions
  - Utilities: Helper functions
  - Services: Core infrastructure (logging, analytics, cache)
  - Patterns: DI, event bus, state management

## Design Patterns

### Service Locator Pattern
- **File**: core/service_locator.dart
- **Purpose**: Dependency injection container
- **Usage**: Register and retrieve services globally

### Repository Pattern
- **Files**: domain/repositories.dart
- **Purpose**: Abstract data access layer
- **Implementation**: Preference, BMI History, Game State repositories

### Use Case Pattern
- **Files**: domain/usecases/*.dart
- **Purpose**: Encapsulate business logic
- **Classes**: CalculateBMI, GetBMIHistory, SaveBMIRecord, UpdatePreferences

### Event Bus Pattern
- **File**: core/event_bus.dart
- **Purpose**: Cross-component communication
- **Events**: BMI, Repository, Sync, Auth, Error events

### State Container Pattern
- **File**: core/state_holder.dart
- **Purpose**: Reactive state management
- **Classes**: StateHolder<T>, ListStateHolder<T>

## Data Flow Architecture

```
User Input → Presentation Layer
              ↓
         UseCase (Domain)
              ↓
         Repository Interface
              ↓
         Repository Implementation (Data)
              ↓
         Data Source (LocalStore/API)
              ↓
         Response → Service Logic
              ↓
         ViewModel/State Update
              ↓
         UI Rebuild
```

## Dependency Injection Setup

Services registered with ServiceLocator:
1. ConfigurationService (singleton)
2. AnalyticsService (singleton)
3. BiometricService (singleton)
4. SecureStorageService (singleton)
5. Repository implementations (singletons)
6. UseCase implementations (factories)

## Error Handling Strategy

1. **Custom Exceptions**: Defined in core/logger.dart
2. **Result Type**: core/result.dart for functional error handling
3. **Event Bus**: Publish ErrorOccurredEvent for global handling
4. **Retry Logic**: core/retry_policy.dart for resilience

## Testing Strategy

- Unit tests for domain logic and usecases
- Widget tests for presentation layer
- Integration tests for repository operations
- Mocking services with in-memory implementations

## Code Organization Guidelines

- Keep files small and focused (single responsibility)
- Use meaningful names for classes and functions
- Follow Dart naming conventions
- Document public APIs with doc comments
- Use extensions for common operations
- Leverage const constructors where possible
''';

/// Get layer description
String getLayerDescription(String layer) {
  const descriptions = {
    'presentation': 'UI and user interactions',
    'domain': 'Business logic and entities',
    'data': 'Data access and persistence',
    'core': 'Cross-cutting concerns',
  };
  return descriptions[layer] ?? 'Unknown layer';
}

/// Get pattern description
String getPatternDescription(String pattern) {
  const descriptions = {
    'service_locator': 'Dependency injection container for service management',
    'repository': 'Abstract data access layer for repositories',
    'use_case': 'Encapsulation of business logic operations',
    'event_bus': 'Cross-component communication via events',
    'state_container': 'Reactive state management with ChangeNotifier',
  };
  return descriptions[pattern] ?? 'Unknown pattern';
}

/// Architecture summary
class ArchitectureSummary {
  static const String title = 'BMI Calculator - Clean Architecture';
  
  static const List<String> layers = [
    'Presentation',
    'Domain',
    'Data',
    'Core',
  ];

  static const List<String> patterns = [
    'ServiceLocator',
    'Repository',
    'UseCase',
    'EventBus',
    'StateContainer',
  ];

  static const String principles = '''
  1. Separation of Concerns
  2. Dependency Inversion
  3. Single Responsibility
  4. DRY (Don't Repeat Yourself)
  5. KISS (Keep It Simple, Stupid)
  ''';
}
