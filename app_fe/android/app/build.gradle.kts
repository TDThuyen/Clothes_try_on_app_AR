plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}
val bnbSdkVersion = rootProject.extra["bnb_sdk_version"] as String
android {
    namespace = "com.example.clothes_try_on_app"
    compileSdk = 36

    // Speech_to_text yêu cầu NDK này
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.clothes_try_on_app"
        minSdk = 26          // ✅ Banuba bắt buộc
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
            debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    implementation("com.banuba.sdk:banuba_sdk_resources:$bnbSdkVersion")
}
