# Android basic example app

Purpose of this application is to showacse minimalistic Android app.

| Prop    | More                                        |
| ------- | ------------------------------------------- |
| Home    | <https://pexmor.github.io/AndBasicExample/> |
| package | io.github.pexmor.abe                        |

## Publishing to Google Play

### One-time setup

**1. Generate a release keystore** (do this once; back it up securely — losing it means you can never update the app):

```bash
./setup-keystore.sh
```

This creates `release.jks` and `keystore.properties` in the project root. Both are gitignored.

**2. Create a Google Play service account**

- Open [Google Play Console](https://play.google.com/console) → Setup → API access
- Link to a Google Cloud project and create a new service account
- Grant the service account **Release manager** permissions in Play Console
- Download the JSON key and save it as `service-account.json` in the project root (gitignored)

**3. Create the app listing in Play Console**

The app must exist on Play Console (at least a draft) before the first upload. Create it manually via the console, using application ID `io.github.pexmor.abe`.

### Publish

```bash
# Upload to the internal test track (default)
./publish.sh

# Upload to a specific track
./publish.sh --track=alpha
./publish.sh --track=production
```

The script checks that `keystore.properties` and `service-account.json` are present, then runs `./gradlew publishReleaseBundle` which builds a signed AAB and uploads it via the Google Play Developer API.

To build the signed AAB locally without uploading:

```bash
./gradlew bundleRelease
# Output: app/build/outputs/bundle/release/app-release.aab
```
