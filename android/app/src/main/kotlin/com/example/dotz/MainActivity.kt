package com.example.dotz

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.dotz/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "saveSettings" -> {
                        try {
                            val prefs = getSharedPreferences("dotz_prefs", Context.MODE_PRIVATE)
                            prefs.edit().apply {
                                // Colors — Long→Int safe cast
                                putInt("bg_color",     (call.argument<Any>("bgColor")     as? Number)?.toInt() ?: Color.BLACK)
                                putInt("past_color",   (call.argument<Any>("pastColor")   as? Number)?.toInt() ?: Color.WHITE)
                                putInt("future_color", (call.argument<Any>("futureColor") as? Number)?.toInt() ?: Color.parseColor("#2A2A2A"))
                                putInt("today_color",  (call.argument<Any>("todayColor")  as? Number)?.toInt() ?: Color.parseColor("#FF4500"))
                                putInt("columns",      (call.argument<Any>("columns")     as? Number)?.toInt() ?: 20)
                                putBoolean("show_label", call.argument<Boolean>("showLabel") ?: true)

                                // Mode: 0=year, 1=goal, 2=life
                                putInt("mode", (call.argument<Any>("mode") as? Number)?.toInt() ?: 0)

                                // Goal
                                putInt("goal_total",  (call.argument<Any>("goalTotal")  as? Number)?.toInt() ?: 100)
                                putInt("goal_past",   (call.argument<Any>("goalPast")   as? Number)?.toInt() ?: 0)
                                putString("goal_name", call.argument<String>("goalName") ?: "Goal")

                                // Life
                                putInt("life_total",  (call.argument<Any>("lifeTotal")  as? Number)?.toInt() ?: 29200)
                                putInt("life_lived",  (call.argument<Any>("lifeLived")  as? Number)?.toInt() ?: 0)

                                apply()
                            }
                            result.success("saved")
                        } catch (e: Exception) {
                            result.error("SAVE_FAILED", e.message, null)
                        }
                    }

                    "openWallpaperPicker" -> {
                        var opened = false
                        // Method 1: direct to Dotz
                        if (!opened) try {
                            val i = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).apply {
                                putExtra(WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                                    ComponentName(packageName, "$packageName.DotzLiveWallpaper"))
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(i); opened = true
                        } catch (_: Exception) {}
                        // Method 2: live chooser
                        if (!opened) try {
                            val i = Intent("android.service.wallpaper.LIVE_WALLPAPER_CHOOSER")
                            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(i); opened = true
                        } catch (_: Exception) {}
                        // Method 3: generic
                        if (!opened) try {
                            val i = Intent(Intent.ACTION_SET_WALLPAPER)
                            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(i); opened = true
                        } catch (_: Exception) {}
                        if (opened) result.success("opened")
                        else result.error("FAILED", "Cannot open picker", null)
                    }

                    "isLiveWallpaperActive" -> {
                        try {
                            val wm   = WallpaperManager.getInstance(this)
                            val info = wm.wallpaperInfo
                            result.success(info?.packageName == packageName)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
