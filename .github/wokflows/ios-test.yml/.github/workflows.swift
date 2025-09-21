//
//  workflows.swift
//  lifehackiosapp
//
//  Created by Aleksander Blindheim on 21/09/2025.
//
name: iOS Tests (Xcodebuild)

on:
  push:
    branches: [ main, "**/**" ]
    paths:
      - "ios-app/**"
      - ".github/workflows/ios-tests.yml"
  pull_request:
    branches: [ main ]
    paths:
      - "ios-app/**"
      - ".github/workflows/ios-tests.yml"

jobs:
  build-and-test:
    runs-on: macos-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # Velg Xcode-versjon (juster hvis du trenger en spesifikk)
      - name: Select Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: "latest-stable"

      - name: Show versions
        run: |
          xcodebuild -version
          xcode-select -p
          sw_vers

      - name: Build & Test (iOS Simulator)
        run: |
          set -eo pipefail
          xcodebuild \
            -project ios-app/LifehackApp.xcodeproj \
            -scheme LifehackApp \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
            -derivedDataPath build \
            clean test | xcpretty
        env:
          NSUnbufferedIO: "YES"

      - name: Archive test logs (on failure)
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: xcode-logs
          path: build/Logs
