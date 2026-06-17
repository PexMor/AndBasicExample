#!/usr/bin/env bash
# Generates a release keystore and writes keystore.properties.
# Run once; keep both files out of version control.
set -euo pipefail

KEYSTORE_FILE="$(pwd)/release.jks"
PROPERTIES_FILE="$(pwd)/keystore.properties"
APP_ID="io.github.pexmor.abe"

if [[ -f "$PROPERTIES_FILE" ]]; then
    echo "keystore.properties already exists — delete it first if you want to regenerate."
    exit 1
fi

echo "=== Android release keystore generator ==="
read -rp "Key alias (e.g. $APP_ID): " KEY_ALIAS
read -rsp "Key password: " KEY_PASS;  echo
read -rsp "Store password: " STORE_PASS; echo
read -rp "Your full name: " CN
read -rp "Organisation (company or personal name): " O
read -rp "City: " L
read -rp "Country code (2 letters, e.g. CZ): " C

keytool -genkeypair \
    -keystore "$KEYSTORE_FILE" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA -keysize 4096 \
    -validity 10000 \
    -storepass "$STORE_PASS" \
    -keypass "$KEY_PASS" \
    -dname "CN=$CN, O=$O, L=$L, C=$C"

cat > "$PROPERTIES_FILE" <<EOF
storeFile=$KEYSTORE_FILE
storePassword=$STORE_PASS
keyAlias=$KEY_ALIAS
keyPassword=$KEY_PASS
EOF

echo ""
echo "Keystore : $KEYSTORE_FILE"
echo "Config   : $PROPERTIES_FILE"
echo ""
echo "Back up $KEYSTORE_FILE securely — losing it means you can never update the app on the Play Store."
