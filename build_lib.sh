#!/bin/bash

set -e

echo "🔧 Cleaning previous builds..."
flutter clean

echo "🔧 Getting dependencies..."
flutter pub get

echo "🔧 Preparing C++ library..."
cp -r lib/CppLibrary/* android/app/src/main/cpp/

echo "🔨 Compiling C++ for Android..."
cd android
./gradlew assembleDebug

echo "⚡ Generating Dart FFI bindings..."
cd ..
dart run ffigen --config ffigen.yaml

echo "✅ Build complete! You can now run your app."
