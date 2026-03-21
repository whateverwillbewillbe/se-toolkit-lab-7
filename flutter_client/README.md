# LMS Flutter Client

A beautiful Flutter-based mobile client for the Learning Management System (LMS) backend.

## Features

- 📚 **Browse Labs** - View all available laboratory works and their tasks
- 📊 **Analytics** - Detailed analytics including:
  - Completion rates
  - Score distributions
  - Pass rates by task
  - Submission timeline
  - Group performance
  - Top learners leaderboard
- 👥 **Learners** - View all learners grouped by student groups
- 🔄 **Interactions** - Track all student interactions with the system

## Screenshots

The app features a modern Material Design 3 UI with:

- Bottom navigation bar for easy navigation
- Pull-to-refresh on all lists
- Beautiful charts and visualizations
- Dark/Light theme support (follows system)

## Prerequisites

- Flutter SDK (3.5.0 or higher)
- Dart SDK (3.5.0 or higher)
- Running LMS backend (see [backend documentation](../backend/README.md))

## Setup

### 1. Install Dependencies

```bash
cd flutter_client
flutter pub get
```

### 2. Configure API Access

Create a `.env` file in the root directory (copy from `.env.example`):

```bash
cp .env.example .env
```

Edit `.env` with your backend credentials:

```env
LMS_API_URL=http://10.0.2.2:42002
LMS_API_KEY=my-secret-api-key
```

**Important:**

- For Android emulator: use `http://10.0.2.2:42002` to access localhost
- For physical device: use your computer's IP address (e.g., `http://192.168.1.100:42002`)
- Get the API key from `.env.docker.secret` or your backend configuration

### 3. Run the App

```bash
# Make sure you have an emulator running or a device connected
flutter run

# Or specify a device
flutter run -d <device_id>
```

## Configuration Options

You can pass API configuration as Dart defines:

```bash
flutter run \
  --dart-define=LMS_API_URL=http://10.0.2.2:42002 \
  --dart-define=LMS_API_KEY=my-secret-api-key
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── item.dart            # Lab and task models
│   ├── learner.dart         # Learner model
│   ├── interaction.dart     # Interaction log model
│   └── analytics.dart       # Analytics models
├── services/                 # Business logic
│   ├── api_client.dart      # HTTP client for backend API
│   └── lms_service.dart     # State management (Provider)
└── screens/                  # UI screens
    ├── home_screen.dart     # Labs list
    ├── item_detail_screen.dart  # Lab details
    ├── analytics_screen.dart    # Analytics dashboard
    ├── learners_screen.dart     # Learners list
    └── interactions_screen.dart # Interactions list
```

## API Endpoints Used

The client communicates with the following backend endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/items/` | GET | Get all labs and tasks |
| `/items/{id}` | GET | Get specific item |
| `/learners/` | GET | Get all learners |
| `/interactions/` | GET | Get all interactions |
| `/analytics/scores?lab=` | GET | Score distribution |
| `/analytics/pass-rates?lab=` | GET | Pass rates by task |
| `/analytics/timeline?lab=` | GET | Submission timeline |
| `/analytics/groups?lab=` | GET | Group performance |
| `/analytics/completion-rate?lab=` | GET | Completion rate |
| `/analytics/top-learners?lab=` | GET | Top learners |
| `/pipeline/sync` | POST | Trigger ETL sync |

## State Management

The app uses **Provider** for state management:

- `LmsService` is the main state holder
- API calls are made through `LmsApiClient`
- All screens consume data via `Consumer<LmsService>`

## Error Handling

The app handles errors gracefully:

- Network errors show retry buttons
- Empty states show helpful messages
- Loading states show progress indicators

## Building for Production

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

## Troubleshooting

### Connection Refused

- Make sure the backend is running: `curl http://localhost:42002/docs`
- For emulator, use `10.0.2.2` instead of `localhost`
- Check firewall settings

### Authentication Failed

- Verify the API key in `.env` matches `.env.docker.secret`
- Check that the key has correct permissions

### Empty Data

- Trigger a sync in the backend: `POST /pipeline/sync`
- Check that data exists in the database

## Dependencies

- `http` - HTTP client for API calls
- `provider` - State management
- `flutter_staggered_grid_view` - Advanced grid layouts (optional)

## Development

### Running Tests

```bash
flutter test
```

### Code Formatting

```bash
flutter format .
```

### Analyze Code

```bash
flutter analyze
```

## License

Same as the main project.
