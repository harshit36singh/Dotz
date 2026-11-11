import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Daily-quote endpoint. Read from the repo-root .env (QUOTE_API_URL=...) so a
// keyed API can be swapped in without committing it; falls back to the free
// public zenquotes endpoint.
val quoteApiUrl: String = run {
    val env = rootProject.file("../.env")
    val fromEnv = if (env.exists()) {
        env.readLines()
            .map { it.trim() }
            .firstOrNull { it.startsWith("QUOTE_API_URL=") }
            ?.substringAfter("=")
            ?.trim()
    } else null
    fromEnv?.takeIf { it.isNotEmpty() } ?: "https://zenquotes.io/api/today"
}

android {
    namespace = "com.wallpaper.dotz"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.wallpaper.dotz"
        minSdk = 24
        targetSdk = 36
        // CI passes -PversionCode / -PversionName (from the run number and the
        // git tag) so every Play upload gets a higher code automatically.
        versionCode = (findProperty("versionCode") as String?)?.toInt() ?: 4
        versionName = (findProperty("versionName") as String?) ?: "2.0.1"
        buildConfigField("String", "QUOTE_API_URL", "\"$quoteApiUrl\"")
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        debug {
            // Installs next to the Play Store build instead of replacing it.
            applicationIdSuffix = ".debug"
        }
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            // CI has no key.properties: fall back to an unsigned release build
            // there instead of failing configuration.
            signingConfig = signingConfigs.findByName("release")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2025.10.01")
    implementation(composeBom)
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui-tooling-preview")
    debugImplementation("androidx.compose.ui:ui-tooling")

    implementation("androidx.core:core-ktx:1.17.0")
    implementation("androidx.activity:activity-compose:1.11.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.9.4")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.9.4")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")
}
