package com.aidatainsight.android.feature.privacy.domain

interface PrivacyRepository {
    fun isAgreedAllPolicyAgreement(): Boolean
    fun saveLatestAgreement()
    fun privacyPolicyUrl(): String
}
