pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "AIDataInsight-Android"

include(
    ":app",
    ":core:common",
    ":core:model",
    ":core:network",
    ":core:account",
    ":core:ui",
    ":feature:login",
    ":feature:setting",
    ":feature:privacy",
    ":feature:history",
    ":feature:ai-chat",
)
