import java.util.Properties

plugins {
    id("com.android.application")
    // Reads android/app/google-services.json and generates the resources
    // Firebase's native SDKs read at runtime. Version is declared (with
    // apply false) in the root-level build.gradle.kts.
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing secrets (upload keystore path + passwords) — never
// committed (see android/.gitignore + PROJECT_CONTEXT.md §6). Populated
// locally by generating android/key.properties once, and in CI by
// .github/workflows/build-release-aab.yml writing it from GitHub Actions
// secrets before this file is evaluated.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

// No native Firebase Gradle dependencies (firebase-bom, firebase-analytics,
// etc.) are added here on purpose — this app uses the FlutterFire Dart
// packages (firebase_core, firebase_auth in pubspec.yaml), which already
// pull in the native Android bindings they need. Adding the native deps
// Firebase's generic Android setup instructions show would be redundant.

android {
    namespace = "com.carvault.carvault"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.carvault.carvault"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // A permanent, checked-in debug keystore (android/keystores/debug.keystore),
        // used instead of Gradle's own auto-generated per-machine one. Google
        // Sign-In is tied to the signing certificate's SHA-1 fingerprint, so
        // every build — local or CI — needs to sign with the *same* key,
        // otherwise Google Sign-In only works from whichever machine happened
        // to build it last.
        getByName("debug") {
            storeFile = file("../keystores/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }

        // The upload key used for Play Store submissions (Play App Signing
        // re-signs with its own key on Google's side — this is only the key
        // that authenticates *uploads* to Play Console). Only registered
        // when key.properties is present, so a checkout without it (e.g. a
        // contributor who hasn't generated their own) doesn't break the
        // build — release falls back to the debug config below.
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // No key.properties on this machine — fall back to the debug
                // key so `flutter run --release` still works locally. Never
                // use this fallback for anything actually distributed.
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
