plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.nabdh.nabdh_therapist"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nabdh.nabdh_therapist"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

android.packagingOptions {
    // Compressed native libs: much smaller APK to share; extracted on install.
    jniLibs.useLegacyPackaging = true
    pickFirst("lib/x86/libc++_shared.so")
    pickFirst("lib/x86_64/libc++_shared.so")
    pickFirst("lib/arm64-v8a/libc++_shared.so")
    pickFirst("lib/armeabi-v7a/libc++_shared.so")
    // Optional Agora extensions this app never enables (~29 MB per ABI).
    for (ext in listOf(
        "lip_sync", "clear_vision", "spatial_audio", "face_capture",
        "segmentation", "audio_beauty", "content_inspect",
        "video_quality_analyzer", "video_av1_encoder", "face_detection",
        "screen_capture",
    )) {
        exclude("lib/*/libagora_${ext}_extension.so")
    }
}
