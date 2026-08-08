allprojects {
    repositories {
        google()
        mavenCentral()
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
    project.evaluationDependsOn(":app")
}
// Native plugins (file_picker, flutter_secure_storage, jni, etc.) require
// NDK 28.2.13676358. Pin every Android library subproject to that version so
// native builds (CXX tasks) resolve the correct NDK.
//
// NOTE: Native plugins (e.g. package:jni) set `ndkVersion flutter.ndkVersion`
// in their own android { } block, which overwrites any value set during plugin
// application. `afterEvaluate` ensures our override runs LAST, after the
// plugin's build script has fully evaluated.
subprojects {
    plugins.withId("com.android.library") {
        afterEvaluate {
            extensions.configure<com.android.build.api.dsl.LibraryExtension>("android") {
                ndkVersion = "28.2.13676358"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
