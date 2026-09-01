#!/usr/bin/env bash
set -e

# ==============================================================================
# EzanApp Release Keystore Generator & Setup Script
# ==============================================================================

KEYSTORE_DIR="android/app"
KEYSTORE_FILE="upload-keystore.jks"
KEYSTORE_PATH="$KEYSTORE_DIR/$KEYSTORE_FILE"
KEY_PROPERTIES_PATH="android/key.properties"

echo "================================================="
echo "🔑 EzanApp Release Keystore Generation Script"
echo "================================================="

if [ -f "$KEYSTORE_PATH" ]; then
    echo "⚠️ Keystore already exists at: $KEYSTORE_PATH"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

mkdir -p "$KEYSTORE_DIR"

echo "Please enter the keystore details:"
read -p "Key Alias [upload]: " KEY_ALIAS
KEY_ALIAS=${KEY_ALIAS:-upload}

read -s -p "Enter Keystore & Key Password (min 6 characters): " PASSWORD
echo
if [ ${#PASSWORD} -lt 6 ]; then
    echo "❌ Error: Password must be at least 6 characters."
    exit 1
fi

echo "Generating keystore with keytool..."
keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$PASSWORD" \
    -keypass "$PASSWORD" \
    -dname "CN=EzanApp, OU=Mobile, O=Ekilinc, L=Istanbul, ST=Istanbul, C=TR"

echo "✅ Keystore created at: $KEYSTORE_PATH"

# Write key.properties
cat <<EOF > "$KEY_PROPERTIES_PATH"
storePassword=$PASSWORD
keyPassword=$PASSWORD
keyAlias=$KEY_ALIAS
storeFile=$KEYSTORE_PATH
EOF

echo "✅ Configuration written to: $KEY_PROPERTIES_PATH"
echo "🎉 You can now build signed release APK or App Bundle:"
echo "   flutter build apk --release"
echo "   flutter build appbundle --release"
echo "================================================="
