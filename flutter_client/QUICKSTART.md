# Quick Start - LMS Flutter Client

## Prerequisites

1. **Backend running**: Make sure the LMS backend is running on port 42002
   ```bash
   # Check backend
   curl -sf http://localhost:42002/docs
   ```

2. **Flutter installed**: Verify Flutter is installed
   ```bash
   flutter --version
   ```

## Setup

### 1. Install dependencies

```bash
cd flutter_client
flutter pub get
```

### 2. Configure API access

Create `.env` file:

```bash
cp .env.example .env
```

Edit `.env` with your settings:

```env
# For Android emulator
LMS_API_URL=http://10.0.2.2:42002
LMS_API_KEY=my-secret-api-key
```

**Get API key from**: `.env.docker.secret` or backend configuration

### 3. Run the app

**Option A: Using VS Code**
- Press `F5` or click "Run and Debug"

**Option B: Using terminal**
```bash
# Make sure emulator is running or device is connected
flutter run

# Or with explicit configuration
flutter run \
  --dart-define=LMS_API_URL=http://10.0.2.2:42002 \
  --dart-define=LMS_API_KEY=my-secret-api-key
```

## For Physical Device

1. Find your computer's IP address:
   ```bash
   # Linux
   ip addr show
   
   # Or
   hostname -I
   ```

2. Use the IP in `.env`:
   ```env
   LMS_API_URL=http://192.168.1.100:42002
   LMS_API_KEY=my-secret-api-key
   ```

3. Run on device:
   ```bash
   flutter run
   ```

## Troubleshooting

### Connection Refused

- Backend not running? Start it: `docker compose up backend`
- Wrong URL? For emulator use `10.0.2.2`, not `localhost`
- Firewall? Allow port 42002

### No Devices Found

- Android: Start emulator via Android Studio
- iOS: `open -a Simulator` or connect iPhone
- List devices: `flutter devices`

### Build Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Features to Try

1. **Browse Labs** - View all laboratory works
2. **View Analytics** - Tap FAB or lab → "View Analytics"
3. **See Learners** - Bottom navigation → Learners tab
4. **Track Interactions** - Bottom navigation → Interactions tab

## Build APK

```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`
