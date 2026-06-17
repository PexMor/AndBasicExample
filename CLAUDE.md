# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

```bash
# Build debug APK
./gradlew assembleDebug

# Run unit tests
./gradlew test

# Run instrumented tests (requires connected device/emulator)
./gradlew connectedAndroidTest

# Run a single unit test class
./gradlew test --tests "io.github.pexmor.abe.ExampleUnitTest"

# Lint
./gradlew lint

# Full build with checks
./gradlew build
```

## Architecture

Single-module Android app (`app`), package `io.github.pexmor.abe`. Uses MVVM with Jetpack Navigation Component.

**Entry point:** `MainActivity` — a single-activity host that wires up `NavController` and adapts its navigation UI based on screen width.

**Navigation:** 4 destinations defined in `res/navigation/mobile_navigation.xml`:
- `TransformFragment` (start destination) — RecyclerView list with 16 avatar items
- `ReflowFragment` — text reflow demo
- `SlideshowFragment` — placeholder slideshow
- `SettingsFragment` — placeholder settings

**MVVM pattern:** Each fragment has a paired `ViewModel` (`TransformViewModel`, `ReflowViewModel`, etc.) exposing `LiveData`. Fragments observe via `viewLifecycleOwner`. ViewBinding is used throughout; `_binding` is nulled in `onDestroyView` to avoid leaks.

**Responsive layout (3 breakpoints):**
- Default (phone): bottom navigation bar (`BottomNavigationView`) — Settings accessible via overflow menu only
- `layout-w600dp`: tablet layout, still bottom nav, but wider item layouts
- `layout-w1240dp`: large screen layout with `NavigationDrawerLayout` — Settings appears in the drawer

`MainActivity` detects which layout is active by checking whether `binding.navView` (drawer) or `binding.appBarMain.contentMain.bottomNavView` is non-null, then calls the appropriate `setupWithNavController` variant.

**Dependencies** are managed via version catalog at `gradle/libs.versions.toml`. AGP 8.7.0, Kotlin 1.9.24, Gradle 8.9, compileSdk/targetSdk 34, minSdk 24.
