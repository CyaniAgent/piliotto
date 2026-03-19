allprojects {
    repositories {
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        google()
        mavenCentral()
    }
    if (project.name == "auto_orientation") {
        afterEvaluate {
            extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
                namespace = "de.bytepark.autoorientation"
            }
        }
    }
    if (project.name == "status_bar_control") {
        afterEvaluate {
            extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
                namespace = "com.example.status_bar_control"
            }
        }
    }
    if (project.name == "system_proxy") {
        afterEvaluate {
            extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
                namespace = "com.kaivean.system_proxy"
            }
        }
    }

}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    afterEvaluate {
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
            compileSdk = 36
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
