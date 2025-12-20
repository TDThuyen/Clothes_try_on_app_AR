pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localPropsFile = file("local.properties")
        if (localPropsFile.exists()) {
            localPropsFile.inputStream().use { properties.load(it) }
        }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath!= null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.6.0" apply false
    id("com.android.library") version "8.6.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}

include(":app")

dependencyResolutionManagement {
    // PREFER_SETTINGS ensures centralized control. 
    // We explicitly list ALL required repos here.
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    
    repositories {
        google()
        mavenCentral()
        
        // REQUIRED: Banuba Nexus Repository
        // This is the only place where com.banuba.sdk artifacts are hosted.
        maven {
            name = "BanubaNexus"
            url = uri("https://nexus.banuba.net/repository/maven-releases/")
        }
        
        // REQUIRED: Flutter Engine artifacts
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
        
        // REQUIRED: JitPack for various helper libraries
        maven { url = uri("https://jitpack.io") }
    }
}