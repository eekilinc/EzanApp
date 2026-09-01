import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val envKeyAlias = System.getenv("KEY_ALIAS") ?: (keystoreProperties["keyAlias"] as String?)
val envKeyPassword = System.getenv("KEY_PASSWORD") ?: (keystoreProperties["keyPassword"] as String?)
val envStorePassword = System.getenv("STORE_PASSWORD") ?: (keystoreProperties["storePassword"] as String?)
val envStoreFile = System.getenv("STORE_FILE") ?: (keystoreProperties["storeFile"] as String?)

val isSigningConfigured = !envKeyAlias.isNullOrEmpty() &&
        !envKeyPassword.isNullOrEmpty() &&
        !envStorePassword.isNullOrEmpty() &&
        !envStoreFile.isNullOrEmpty() &&
        (file(envStoreFile).exists() || rootProject.file(envStoreFile).exists())

android {
    namespace = "com.ekilinc.ezanapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.ekilinc.ezanapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (isSigningConfigured) {
                keyAlias = envKeyAlias
                keyPassword = envKeyPassword
                val resolvedStoreFile = if (file(envStoreFile!!).exists()) file(envStoreFile) else rootProject.file(envStoreFile)
                storeFile = resolvedStoreFile
                storePassword = envStorePassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (isSigningConfigured) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
