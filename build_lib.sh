#!/bin/bash

set -e

# Load environment variables from .env file
if [ -f .env ]; then
  source .env
else
  echo "❌ .env file not found. Please create it with the 'local_dir' variable."
  exit 1
fi

read -p "Copy Library from $local_dir? (y/n): " copy_lib

if [ "$copy_lib" == "y" ]; then
  echo "🔧 Copying library..."
  cp -r $local_dir ./assets/
else
  echo "🔧 Skipping library copy..."
fi

echo "🔧 Cleaning previous builds..."
flutter clean

echo "🔧 Getting dependencies..."
flutter pub get

echo "🔧 Preparing C++ library..."
cp -r assets/automata_lib android/app/src/main/cpp/

echo "🔨 Compiling C++ for Android..."
cd android
./gradlew assembleDebug

echo "⚡ Generating Dart FFI bindings..."
cd ..
dart run ffigen --config ffigen.yaml

echo "✅ Build complete! You can now run your app."
