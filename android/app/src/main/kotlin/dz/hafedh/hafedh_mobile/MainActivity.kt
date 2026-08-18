package dz.hafedh.hafedh_mobile

import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "dz.hafedh.hafedh_mobile/lockscreen"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val prefs = getSharedPreferences("HafedhLockScreenPrefs", Context.MODE_PRIVATE)

            when (call.method) {
                "startLockScreenService" -> {
                    prefs.edit().putBoolean("lock_screen_enabled", true).apply()
                    val serviceIntent = Intent(this, LockScreenService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }
                    result.success(true)
                }
                "stopLockScreenService" -> {
                    prefs.edit().putBoolean("lock_screen_enabled", false).apply()
                    val serviceIntent = Intent(this, LockScreenService::class.java)
                    stopService(serviceIntent)
                    result.success(true)
                }
                "isLockScreenEnabled" -> {
                    val isEnabled = prefs.getBoolean("lock_screen_enabled", true)
                    result.success(isEnabled)
                }
                "testLockScreen" -> {
                    val intent = Intent(this, LockScreenFlashcardActivity::class.java)
                    startActivity(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
