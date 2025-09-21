# Lifehack AI Coding Instructions

## Project Architecture

**Lifehack** is a multi-platform health & fitness app with iOS/watchOS clients and Node.js backend for AI coaching.

### Core Components
- **iOS App** (`onAppear.swift`, `View/`, `Services/`, `Models/`) - Main SwiftUI app with health tracking
- **WatchOS App** (`LifehackApp.swift/WatchApp/`) - Companion app for live workout tracking
- **Backend** (`backend/`) - Express.js server proxying OpenAI chat completions
- **Swift Package** (`SwiftBackendClient/`) - Shared networking client library

## Key Architectural Patterns

### 1. Health Data Flow (Detailed)
- **HealthKitManager_iOS** fetches HRV (ms), resting HR (bpm), age from HealthKit on app launch
- **Zone Calculation Logic**: Uses Karvonen formula + HRV adjustments in `makeZones()`:
  - Base: `maxHR = 208 - 0.7 * age` (modified formula)
  - HRV adjustment: High HRV (>70ms) → broader zones 2-3, Low HRV (<30ms) → narrower zones 3-4
  - Reserve capacity: `(maxHR - restingHR) * percentage + restingHR`
- **Data Synchronization**: iOS → WatchConnectivity → watchOS within seconds of HealthKit fetch
- **Watch Live Display**: Real-time HR + zone matching during WorkoutManager sessions

### 2. Backend Integration (Detailed)
- **Architecture**: iOS → ChatBackendClient → Express.js → OpenAI API → Response chain
- **Request Flow**: `ChatMessage[]` → `ChatMessageDTO[]` → JSON payload → `/v1/chat` endpoint
- **Authentication**: Simple token-based with `X-Client-Token` header (no JWT/OAuth complexity)
- **Error Handling**: HTTP status codes → NSError with localized descriptions → UI display
- **Configuration**: `AppConfig` class with `@AppStorage` for persistent backend URL + client token
- **Development vs Production**: Local `http://localhost:8787` vs configurable production endpoint

### 3. Cross-Platform Communication (Detailed)
- **WatchConnectivity Pattern**: 
  - iOS: `transferCurrentComplicationUserInfo()` immediately after HealthKit data fetch
  - watchOS: `didReceiveUserInfo()` delegate updates `Personalization` struct
  - Fallback: `didReceiveApplicationContext()` for reliability
- **Data Structure**: `["age": Int, "restingHR": Int?, "hrvMs": Double?]` dictionary
- **Timing**: Sync happens on iOS app launch task, watch receives within 1-2 seconds
- **State Management**: watchOS `@Published personalization` updates trigger zone recalculation

### 4. SwiftUI Architecture Patterns
- **Singleton Services**: Global shared instances (`HealthKitManager_iOS.shared`)
- **Environment Objects**: Services injected at root level, accessed via `@EnvironmentObject`
- **Reactive UI**: `@Published` properties trigger automatic SwiftUI view updates
- **Navigation**: `NavigationStack` with programmatic navigation in watchOS workout flow

## Development Workflows

### Building & Testing (Expanded)
```bash
# iOS/Watch Development (Requires Xcode)
open lifehackiosapp.xcodeproj
# Primary targets: Lifehack (iOS), LifehackTests, LifehackAppTests, LifehackUITests
# Scheme: "Lifehack" (shared scheme for CI/CD)

# Backend Development
cd backend
npm install                    # Install dependencies (express, cors, openai, etc.)
cp .env.example .env          # Create environment file
# Edit .env: Add OPENAI_API_KEY, CLIENT_TOKEN, PORT=8787
npm run dev                   # Development server with nodemon
npm start                     # Production server
# Test endpoints: GET /health, POST /v1/chat

# Swift Package Development
cd SwiftBackendClient
swift build                   # Compile package
swift test                    # Run package tests
# Package supports iOS 17+ and watchOS 10+

# Docker Deployment (Optional)
cd backend
docker build -t lifehack-backend .
docker run -p 8787:8787 --env-file .env lifehack-backend
```

### Testing Strategy
```bash
# Unit Tests (Focus on HRZones logic)
xcodebuild test -project lifehackiosapp.xcodeproj -scheme Lifehack -destination 'platform=iOS Simulator,name=iPhone 15'

# HR Zones Testing (Key business logic)
# Test files: LifehackAppTests/HRZonesTest.swift
# Validates: makeZones() produces 5 zones, zone lookup accuracy

# Backend API Testing
curl -H "X-Client-Token: YOUR_TOKEN" http://localhost:8787/health
curl -X POST -H "Content-Type: application/json" -H "X-Client-Token: YOUR_TOKEN" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}' \
  http://localhost:8787/v1/chat
```

### Key Configuration Files (Detailed)
- **Entitlements** (Critical for HealthKit):
  - iOS: `LifehackApp.swift/Entitlements/lifehackApp.entitlements.txt`
  - watchOS: `LifehackApp.swift/Entitlements/LifeHackWatchApp.entitlements.swift`
  - Required: `com.apple.developer.healthkit`, `health-share`, `health-update`
  - App Groups: `group.com.yourcompany.lifehack` (modify for your bundle ID)

- **Backend Configuration**:
  ```bash
  # .env file structure
  OPENAI_API_KEY=sk-proj-...        # From OpenAI Dashboard
  CLIENT_TOKEN=your-secret-token    # Custom authentication token
  PORT=8787                         # Server port (default)
  ALLOWED_ORIGINS=http://localhost:3000  # CORS origins
  ```

- **Xcode Project Structure**:
  - Main project: `lifehackiosapp.xcodeproj`
  - Dependencies: Swift Algorithms (via Swift Package Manager)
  - Deployment target: iOS 26.0+ (uses latest SwiftUI features)
  - Development team: Automatic signing recommended

### Development Environment Setup
```bash
# Prerequisites
# 1. Xcode 15+ with iOS 17+ SDK
# 2. Node.js 18+ for backend
# 3. OpenAI API account + API key

# Initial Setup
git clone <repository>
cd Lifehack

# Backend setup
cd backend
npm install
cp .env.example .env
# Edit .env with your OpenAI API key and client token
npm run dev &

# iOS setup
open lifehackiosapp.xcodeproj
# Configure development team in project settings
# Run on iOS Simulator or device with HealthKit support

# Verify end-to-end flow
# 1. iOS app launches → requests HealthKit permissions
# 2. Backend responds to /health endpoint
# 3. Watch app receives health data via WatchConnectivity
# 4. Chat functionality works with OpenAI integration
```

## Project-Specific Conventions

### 1. File Naming & Structure
- **Loose file organization**: Files scattered across multiple directories (Models/, View/, Services/ at root AND within LifehackApp.swift/)
- **Mixed extensions**: `.swift` files sometimes contain non-Swift content (JSON, XML, shell commands)
- **Redundant structures**: Multiple `ChatBackendClient.swift` and similar files in different locations

### 2. Data Models
- **HRZones**: Uses Karvonen formula with HRV adjustments for personalized heart rate zones
- **Chat Models**: Separate DTO classes (`ChatMessageDTO`) for backend communication vs UI models (`ChatMessage`)
- **Nutrition**: Simple `FoodEntry` model with grams/notes, aggregated into daily totals

### 3. Service Pattern
- **Singleton Services**: `HealthKitManager_iOS.shared`, `Connectivity_iOS.shared`
- **ObservableObject + @Published**: All services follow SwiftUI reactive pattern
- **Async/await**: Modern concurrency for HealthKit and network calls

## Integration Points

### HealthKit Integration
- Request permissions in app launch (`onAppear.swift`)
- Fetch latest HRV/resting HR on app start
- Sync to watch via WatchConnectivity immediately after fetch

### Backend Authentication
- Uses simple token-based auth via `X-Client-Token` header
- Token configured in Settings tab, stored in `@AppStorage`
- No complex OAuth - designed for personal/prototype use

### Error Handling Patterns
- Network errors displayed in UI via `@State` error strings
- HealthKit failures are silent (graceful degradation)
- Backend client throws NSError with localized descriptions

## Common Tasks

### Adding New Health Metrics
1. Extend `HealthKitManager_iOS` to fetch new data types
2. Update `Connectivity_iOS.sendLatest()` to include new metrics
3. Modify watch `Personalization` struct to receive data
4. Update zone calculation if health-related

### Backend API Changes  
1. Modify Express routes in `backend/Server.json`
2. Update corresponding Swift client in `ChatBackendClient.swift`
3. Test with `/health` endpoint first, then full chat integration

### Adding Watch Complications
- Use `WCSession.transferCurrentComplicationUserInfo()` (already implemented)
- Ensure data is transferred immediately after HealthKit fetch
- Watch app listens via `Connectivity_watch.session(_:didReceiveUserInfo:)`

## Important Caveats
- **File structure is inconsistent** - check multiple locations for similar files
- **Backend uses port 8787** by default, configurable via PORT env var
- **HealthKit permissions** must be configured in both iOS and watchOS entitlements
- **Git commits contain mixed content** - some .swift files have shell commands/git history embedded