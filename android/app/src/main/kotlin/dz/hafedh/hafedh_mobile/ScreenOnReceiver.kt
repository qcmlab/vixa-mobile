package dz.hafedh.hafedh_mobile

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ScreenOnReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action

        // 1. Re-order and refresh the Outside Home Screen Widget automatically on phone lock / unlock
        if (action == Intent.ACTION_SCREEN_ON || action == Intent.ACTION_USER_PRESENT || action == Intent.ACTION_SCREEN_OFF) {
            HafedhWidgetProvider.shuffleOrAdvanceNextCard(context)
        }

        // 2. Launch Lockscreen overlay if enabled
        if (action == Intent.ACTION_SCREEN_ON || action == Intent.ACTION_USER_PRESENT) {
            val prefs = context.getSharedPreferences("HafedhLockScreenPrefs", Context.MODE_PRIVATE)
            val isEnabled = prefs.getBoolean("lock_screen_enabled", true)

            if (isEnabled) {
                val lockIntent = Intent(context, LockScreenFlashcardActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                }
                context.startActivity(lockIntent)
            }
        }
    }
}
