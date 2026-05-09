package com.aidatainsight.android.core.account.user

import android.content.Context
import android.content.SharedPreferences
import com.aidatainsight.android.core.model.account.AccountUser

class SharedPreferencesAccountUserStore(
    context: Context,
) : AccountUserStore {
    private val preferences: SharedPreferences = context.applicationContext.getSharedPreferences(
        USER_PREFERENCES_NAME,
        Context.MODE_PRIVATE,
    )

    override suspend fun updateUser(user: AccountUser) {
        updateUserImmediately(user)
    }

    override suspend fun getUser(): AccountUser? {
        return getUserImmediately()
    }

    fun updateUserImmediately(user: AccountUser) {
        preferences.edit()
            .putNullableInt(KEY_ID, user.id)
            .putNullableString(KEY_PHONE, user.phone)
            .putNullableString(KEY_USERNAME, user.username)
            .putNullableString(KEY_NICKNAME, user.nickname)
            .apply()
    }

    fun getUserImmediately(): AccountUser? {
        val hasValue = preferences.contains(KEY_ID) ||
            preferences.contains(KEY_PHONE) ||
            preferences.contains(KEY_USERNAME) ||
            preferences.contains(KEY_NICKNAME)
        if (!hasValue) return null

        return AccountUser(
            id = if (preferences.contains(KEY_ID)) preferences.getInt(KEY_ID, 0) else null,
            phone = preferences.getString(KEY_PHONE, null),
            username = preferences.getString(KEY_USERNAME, null),
            nickname = preferences.getString(KEY_NICKNAME, null),
        )
    }

    fun removeImmediately() {
        preferences.edit().clear().apply()
    }

    private fun SharedPreferences.Editor.putNullableString(
        key: String,
        value: String?,
    ): SharedPreferences.Editor {
        return if (value == null) remove(key) else putString(key, value)
    }

    private fun SharedPreferences.Editor.putNullableInt(
        key: String,
        value: Int?,
    ): SharedPreferences.Editor {
        return if (value == null) remove(key) else putInt(key, value)
    }

    private companion object {
        const val USER_PREFERENCES_NAME = "ai_data_insight_account_user"
        const val KEY_ID = "id"
        const val KEY_PHONE = "phone"
        const val KEY_USERNAME = "username"
        const val KEY_NICKNAME = "nickname"
    }
}

