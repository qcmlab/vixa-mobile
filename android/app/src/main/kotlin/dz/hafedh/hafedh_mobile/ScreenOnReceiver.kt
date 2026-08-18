package dz.hafedh.hafedh_mobile

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ScreenOnReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_SCREEN_ON) {
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
