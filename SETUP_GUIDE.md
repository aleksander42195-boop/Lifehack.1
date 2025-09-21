# Lifehack iOS App Setup Guide

## 🚨 REQUIRED INSTALLATIONS

### 1. Install Node.js (for backend)
1. Go to https://nodejs.org
2. Download **LTS version** (left green button)
3. Run the installer
4. **Restart Terminal**

### 2. Setup Backend
```bash
cd /Users/aleksanderblindheim/Lifehack/backend
npm install
cp .env.example .env
# Edit .env file and add your OpenAI API key
```

### 3. Create Missing .env File
Create `backend/.env` with this content:
```
OPENAI_API_KEY=sk-proj-your-key-here
CLIENT_TOKEN=lifehack-secret-2025
PORT=8787
ALLOWED_ORIGINS=http://localhost:3000
```

## 📱 BUILD THE iOS APP

### Option 1: Use Xcode (Easiest)
1. Open `lifehackiosapp.xcodeproj` in Xcode
2. Select "Lifehack" scheme
3. Choose iPhone simulator or connected device
4. Click Build & Run (⌘+R)

### Option 2: Command Line
```bash
cd /Users/aleksanderblindheim/Lifehack
xcodebuild -project lifehackiosapp.xcodeproj -scheme Lifehack -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## 🔧 IF BUILD FAILS

### Common Issues:
1. **Missing AppConfig** - Fixed in Models/ChatModels.swift
2. **Missing imports** - Add `import SwiftUI` to files
3. **HealthKit permissions** - iPhone/iPad only, not simulator
4. **Signing issues** - Set your Apple ID in Xcode project settings

### Quick Fixes:
```bash
# Clean build folder
cd /Users/aleksanderblindheim/Lifehack
rm -rf ~/Library/Developer/Xcode/DerivedData

# Then rebuild in Xcode
```

## 📝 NEXT STEPS

1. **Install Node.js first** (most important)
2. **Open in Xcode** - use lifehackiosapp.xcodeproj
3. **Set signing team** in project settings
4. **Run on real iPhone/iPad** for HealthKit features
5. **Start backend** with `npm run dev`

## 🆘 EMERGENCY SIMPLIFIED VERSION

If nothing works, I can create a minimal working version. Let me know!

## 🔗 VS Code Extensions (Optional)
- GitHub Copilot (for AI assistance)
- Swift (for syntax highlighting)
- Docker (only if you want containerized backend)

**You DON'T need Docker or special extensions to run this app!**