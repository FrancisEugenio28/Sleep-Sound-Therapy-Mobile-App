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
    
    // --- SDK INTERCEPTOR MUST GO HERE (Before evaluation) ---
    afterEvaluate {
        if (project.hasProperty("android") && project.name != "app") {
            project.extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                // ONLY apply the SDK downgrade to the broken bluetooth package
                if (project.name == "flutter_bluetooth_serial") {
                    compileSdk = 34
                }
                
                // Keep the namespace fix global
                if (namespace == null) {
                    namespace = project.group.toString()
                }
            }
        }
    }
}

// Now Flutter can safely evaluate the app
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}