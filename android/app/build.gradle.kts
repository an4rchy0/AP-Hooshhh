// File: android/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.finalproject"
    compileSdk = 34
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId = "com.example.finalproject"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Hapus konfigurasi toolchain karena kamu tidak pakai Java 17/23
// Dan Kotlin sudah otomatis mengikuti Java target saat pakai plugin kotlin-android

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:2.0.20")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.window:window:1.3.0")
    implementation("androidx.window:window-java:1.3.0")
}

// Perbaikan di sini: Menambahkan pengaturan compiler untuk suppress warning
tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.add("-Xlint:-options")
    options.compilerArgs.add("-nowarn")
}
