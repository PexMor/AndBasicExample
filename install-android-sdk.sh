#!/usr/bin/env bash
# Installs a minimal Android SDK for building this project (compileSdk 34, AGP 8.7.0).
# Run from the project root. Requires: curl, unzip, sudo (for openjdk only).
set -euo pipefail

SDK_DIR="$HOME/android-sdk"
# cmdline-tools r11 (Linux x86_64). Check https://developer.android.com/studio#command-line-tools-only
# for a newer URL if this one fails.
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 1. Java 17+ ──────────────────────────────────────────────────────────────
JAVA_VER=$(java -version 2>&1 | awk -F '"' '/version/{print $2}' | cut -d. -f1)
if [[ -z "$JAVA_VER" || "$JAVA_VER" -lt 17 ]]; then
    echo "Installing OpenJDK 17..."
    sudo apt-get update -qq
    sudo apt-get install -y openjdk-17-jdk
fi

# ── 2. Download cmdline-tools ─────────────────────────────────────────────────
if [[ -x "$SDK_DIR/cmdline-tools/latest/bin/sdkmanager" ]]; then
    echo "cmdline-tools already present, skipping download."
else
    echo "Downloading Android command-line tools..."
    TMP=$(mktemp -d)
    trap 'rm -rf "$TMP"' EXIT
    curl -fL "$CMDLINE_TOOLS_URL" -o "$TMP/cmdline-tools.zip"
    unzip -q "$TMP/cmdline-tools.zip" -d "$TMP"
    mkdir -p "$SDK_DIR/cmdline-tools"
    mv "$TMP/cmdline-tools" "$SDK_DIR/cmdline-tools/latest"
fi

export ANDROID_HOME="$SDK_DIR"
export PATH="$SDK_DIR/cmdline-tools/latest/bin:$SDK_DIR/platform-tools:$PATH"

# ── 3. Accept licenses and install SDK components ────────────────────────────
echo "Accepting licenses..."
yes | sdkmanager --licenses > /dev/null 2>&1 || true

echo "Installing: platforms;android-34  build-tools;34.0.0  platform-tools"
sdkmanager "platforms;android-34" "build-tools;34.0.0" "platform-tools"

# ── 4. Wire up the project ───────────────────────────────────────────────────
echo "sdk.dir=$SDK_DIR" > "$PROJECT_DIR/local.properties"
echo "Written: $PROJECT_DIR/local.properties"

# ── 5. Persist env in shell profiles ─────────────────────────────────────────
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [[ -f "$RC" ]] || continue
    if ! grep -q 'ANDROID_HOME' "$RC"; then
        cat >> "$RC" <<EOF

# Android SDK
export ANDROID_HOME="$SDK_DIR"
export PATH="\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH"
EOF
        echo "Updated $RC"
    fi
done

echo ""
echo "Android SDK installed at $SDK_DIR (~450 MB)."
echo "Build with: ./gradlew assembleDebug"
