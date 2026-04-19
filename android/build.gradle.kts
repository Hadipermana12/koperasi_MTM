allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.value(rootProject.layout.projectDirectory.dir("../../build"))

subprojects {
    project.layout.buildDirectory.value(rootProject.layout.buildDirectory.map { it.dir(project.name) })
}


subprojects {
    if (project.name != "app") {
        evaluationDependsOn(":app")
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
