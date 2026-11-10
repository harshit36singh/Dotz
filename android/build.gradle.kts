buildscript {
    repositories {
        google()
    }
    dependencies {
        // AGP 8.9's bundled R8 can't read Kotlin 2.2 metadata; pin a newer R8.
        classpath("com.android.tools:r8:8.11.18")
    }
}

plugins {
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.2.20" apply false
}
