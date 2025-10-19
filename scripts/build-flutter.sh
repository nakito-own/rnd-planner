#!/bin/bash


echo "🔨 Building Flutter web application..."

if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

cd frontend

echo "🧹 Cleaning previous build..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🌐 Building web application..."
flutter build web --release

if [ -d "build/web" ]; then
    echo "✅ Flutter web build completed successfully!"
    echo "📁 Build files are in: frontend/build/web"
else
    echo "❌ Flutter build failed!"
    exit 1
fi

echo ""
echo "🚀 Next steps:"
echo "1. Run: make dev"
echo "2. Open: http://localhost:8080"
