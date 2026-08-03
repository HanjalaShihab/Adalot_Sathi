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
// Flutter 3.44.8 / AGP 9.0.1 default to NDK 28.2.13676358, but the local SDK
// only has a broken/empty install of that version. Pin every Android
// subproject (including native plugins like :jni) to the fully-installed
// NDK 27 so configuration does not fail with CXX1101.
//
// NOTE: Native plugins (e.g. package:jni) set `ndkVersion flutter.ndkVersion`
// in their own android { } block, which overwrites any value set during plugin
// application. `afterEvaluate` ensures our override runs LAST, after the
// plugin's build script has fully evaluated.
subprojects {
    plugins.withId("com.android.library") {
        afterEvaluate {
            extensions.configure<com.android.build.api.dsl.LibraryExtension>("android") {
                ndkVersion = "27.1.12297006"
                // Native plugins (e.g. file_picker -> flutter_plugin_android_lifecycle)
                // now require compileSdk 36+. Pin plugin library modules to 36 so
                // AAR metadata checks pass.
                compileSdk = 36
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
