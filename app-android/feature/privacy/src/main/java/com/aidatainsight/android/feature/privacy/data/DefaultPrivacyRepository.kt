package com.aidatainsight.android.feature.privacy.data

import com.aidatainsight.android.feature.privacy.domain.PrivacyRepository

class DefaultPrivacyRepository : PrivacyRepository {
    override fun isAgreedAllPolicyAgreement(): Boolean = false

    override fun saveLatestAgreement() = Unit

    override fun privacyPolicyUrl(): String = "file:///android_asset/privacy_policy.html"
}
