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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// State-aware hook injection strategy
subprojects {
    val applySdkOverride = Action<Project> {
        val extension = extensions.findByName("android")
        if (extension != null) {
            val android = extension as? com.android.build.gradle.BaseExtension
            android?.apply {
                compileSdkVersion(34)
                defaultConfig {
                    targetSdk = 34
                }
            }
        }
    }

    if (project.state.executed) {
        applySdkOverride.execute(project)
    } else {
        project.afterEvaluate {
            applySdkOverride.execute(project)
        }
    }
}