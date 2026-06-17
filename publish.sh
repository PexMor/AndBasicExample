#!/usr/bin/env bash
# Build a signed release AAB and upload it to Google Play.
#
# Prerequisites:
#   1. keystore.properties (run setup-keystore.sh once to generate)
#   2. service-account.json — Google Play service account credentials
#      Instructions: https://github.com/Triple-T/gradle-play-publisher#service-account
#
# Usage:
#   ./publish.sh                  # uploads to the 'internal' track (default)
#   ./publish.sh --track=alpha
#   ./publish.sh --track=production
set -euo pipefail

TRACK=""
for arg in "$@"; do
    case "$arg" in
        --track=*) TRACK="${arg#--track=}" ;;
        *) echo "Unknown argument: $arg"; exit 1 ;;
    esac
done

# ── Preflight checks ──────────────────────────────────────────────────────────
if [[ ! -f keystore.properties ]]; then
    echo "ERROR: keystore.properties not found."
    echo "       Run ./setup-keystore.sh first, or copy keystore.properties.example and fill it in."
    exit 1
fi

if [[ ! -f service-account.json ]]; then
    echo "ERROR: service-account.json not found."
    echo "       Create a service account in Google Play Console and download its JSON key:"
    echo "       Play Console → Setup → API access → Create new service account"
    echo "       Grant it 'Release manager' permissions, then download the key here."
    exit 1
fi

# ── Build & publish ───────────────────────────────────────────────────────────
GRADLE_ARGS=""
if [[ -n "$TRACK" ]]; then
    # Override the track configured in build.gradle.kts
    GRADLE_ARGS="-Pandroid.play.track=$TRACK"
fi

echo "Building signed release AAB and uploading to Google Play (track: ${TRACK:-internal})..."
./gradlew publishReleaseBundle $GRADLE_ARGS

echo ""
echo "Done. Visit https://play.google.com/console to review the release."
