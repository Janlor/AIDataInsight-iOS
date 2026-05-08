package com.aidatainsight.android.core.testing.fixture

object FixtureFactory {
    inline fun <reified T> unsupported(): T {
        error("Fixture for ${T::class.qualifiedName} is not implemented yet.")
    }
}
