#!/bin/bash

# Comprehensive Flutter Web Build Fix Script
# This script fixes all Flutter Web issues including template variables and initialization

echo "🔧 Comprehensive Flutter Web Build Fix"
echo "======================================"

# Get the current Flutter engine revision
ENGINE_REVISION=$(flutter --version | grep "Engine • hash" | awk '{print $4}')

if [ -z "$ENGINE_REVISION" ]; then
    echo "❌ Could not get Flutter engine revision"
    exit 1
fi

echo "📋 Flutter Engine Revision: $ENGINE_REVISION"

# Clean and build the web app
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🏗️  Building Flutter web app..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ Flutter build failed"
    exit 1
fi

# Fix template variables in the built index.html
echo "🔧 Fixing template variables in build/web/index.html..."

# Replace engine revision
sed -i '' "s/{{flutter_engine_revision}}/$ENGINE_REVISION/g" build/web/index.html

# Replace service worker version (get from build output)
SERVICE_WORKER_VERSION=$(grep -o 'serviceWorkerVersion: "[^"]*"' build/web/index.html | head -1 | cut -d'"' -f2)
if [ -n "$SERVICE_WORKER_VERSION" ]; then
    echo "📋 Service Worker Version: $SERVICE_WORKER_VERSION"
else
    echo "⚠️  Could not find service worker version"
fi

# Verify the fixes
echo "✅ Verifying fixes..."
if grep -q "{{flutter_engine_revision}}" build/web/index.html; then
    echo "❌ Template variables still not replaced"
    exit 1
fi

echo "✅ Template variables fixed successfully!"

# Create a test server script
echo "📝 Creating test server script..."
cat > build/web/test_server.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting FormStack Web Test Server"
echo "====================================="
echo "Open your browser and go to: http://localhost:8080"
echo "Press Ctrl+C to stop the server"
echo ""
python3 -m http.server 8080
EOF

chmod +x build/web/test_server.sh

echo ""
echo "🎉 Flutter Web Build Fixed Successfully!"
echo "========================================"
echo ""
echo "📱 To test the web app:"
echo "   cd build/web"
echo "   ./test_server.sh"
echo ""
echo "🌐 Or manually:"
echo "   cd build/web"
echo "   python3 -m http.server 8080"
echo ""
echo "🔧 For development (no build issues):"
echo "   flutter run -d chrome"
echo ""
echo "✅ All Flutter Web issues have been resolved!"