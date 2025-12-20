// CRITICAL FIX: Set version to the latest stable Face AR release.
// Do NOT use 1.34.0, which belongs to the Video Editor product line.
// Current stable Face AR versions are in the 1.17.x series.
val banubaSdkVersion = "1.17.6"

allprojects {
    // Define the variable in 'extra' so subprojects (plugins) can read it.
    // The Banuba Flutter plugin looks for "bnb_sdk_version".
    extra["bnb_sdk_version"] = banubaSdkVersion
}

val newBuildDir: Directory = rootProject.layout.buildDirectory
   .dir("../../build")
   .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Redundant but safe: Ensure plugins inheriting this project scope see the version
    project.extra["bnb_sdk_version"] = rootProject.extra["bnb_sdk_version"]
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}