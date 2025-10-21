// Top-level build.gradle.kts

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.1") // متوافق مع desugaring
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22") // متوافق مع Java 1.8
        classpath("com.google.gms:google-services:4.3.15") // إذا تستخدم Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// تغيير مسار build لتجنب التعارضات
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}