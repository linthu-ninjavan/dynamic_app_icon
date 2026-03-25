package com.example.change_app_icon

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log

class IconManager(private val context: Context) {
    companion object {
        private const val TAG = "IconManager"
        const val DEFAULT_ICON = "defaultIcon"
        const val SECOND_ICON = "secondIcon"
        const val THIRD_ICON = "thirdIcon"
    }

    private val packageManager = context.packageManager
    private val defaultAlias = ComponentName(context, "${context.packageName}.DefaultIconAlias")
    private val secondAlias = ComponentName(context, "${context.packageName}.SecondIconAlias")
    private val thirdAlias = ComponentName(context, "${context.packageName}.ThirdIconAlias")
    private val aliases = linkedMapOf(
        DEFAULT_ICON to defaultAlias,
        SECOND_ICON to secondAlias,
        THIRD_ICON to thirdAlias,
    )

    fun changeIcon(requestedIcon: String) {
        val iconName = normalizeIconName(requestedIcon)
        val targetAlias = aliases[iconName]
            ?: throw IllegalArgumentException(
                "Unsupported Android icon '$requestedIcon'. Supported icons: ${aliases.keys.joinToString(", ")}",
            )

        if (getCurrentIcon() == iconName) {
            Log.d(TAG, "Icon '$iconName' is already active")
            return
        }

        Log.d(TAG, "Switching launcher icon to '$iconName'")
        // Disable all aliases first
        setComponentState(defaultAlias, PackageManager.COMPONENT_ENABLED_STATE_DISABLED)
        setComponentState(secondAlias, PackageManager.COMPONENT_ENABLED_STATE_DISABLED)
        setComponentState(thirdAlias, PackageManager.COMPONENT_ENABLED_STATE_DISABLED)
        // Enable the target alias
        setComponentState(
            targetAlias,
            if (targetAlias == defaultAlias) {
                PackageManager.COMPONENT_ENABLED_STATE_DEFAULT
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            },
        )
    }

    fun getCurrentIcon(): String {
        return when {
            packageManager.getComponentEnabledSetting(secondAlias) == PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> SECOND_ICON
            packageManager.getComponentEnabledSetting(thirdAlias) == PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> THIRD_ICON
            else -> DEFAULT_ICON
        }
    }

    private fun setComponentState(componentName: ComponentName, state: Int) {
        if (packageManager.getComponentEnabledSetting(componentName) == state) {
            return
        }

        packageManager.setComponentEnabledSetting(
            componentName,
            state,
            PackageManager.DONT_KILL_APP,
        )
    }

    private fun normalizeIconName(iconName: String): String {
        return when (iconName.trim()) {
            DEFAULT_ICON, "default", "primary", "DefaultIconAlias" -> DEFAULT_ICON
            SECOND_ICON, "second_icon", "secondIcon", "SecondIconAlias" -> SECOND_ICON
            THIRD_ICON, "third_icon", "thirdIcon", "ThirdIconAlias" -> THIRD_ICON
            else -> iconName.trim()
        }
    }
}
