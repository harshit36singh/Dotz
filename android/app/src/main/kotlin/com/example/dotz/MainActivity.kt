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
    private val CHANNEL    = "com.example.dotz/wallpaper"
    private val PREFS_NAME = "dotz_prefs"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    "saveSettings" -> {
                        try {
                            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                            prefs.edit().apply {
                                // ── Dot colours ───────────────────────────────
                                putInt("bgColor",     (call.argument<Any>("bgColor")     as? Number)?.toInt() ?: Color.BLACK)
                                putInt("pastColor",   (call.argument<Any>("pastColor")   as? Number)?.toInt() ?: Color.WHITE)
                                putInt("futureColor", (call.argument<Any>("futureColor") as? Number)?.toInt() ?: Color.parseColor("#2A2A2A"))
                                putInt("todayColor",  (call.argument<Any>("todayColor")  as? Number)?.toInt() ?: Color.parseColor("#FF4500"))
                                // ── Label colour + size ────────────────────────
                                putInt("labelColor",    (call.argument<Any>("labelColor")    as? Number)?.toInt() ?: Color.WHITE)
                                putFloat("labelFontSize", (call.argument<Any>("labelFontSize") as? Number)?.toFloat() ?: 0f)
                                // ── Grid & Shapes ─────────────────────────────
                                putInt("columns",    (call.argument<Any>("columns") as? Number)?.toInt() ?: 20)
                                putBoolean("showLabel", call.argument<Boolean>("showLabel") ?: true)
                                putInt("dotShape",   (call.argument<Any>("dotShape") as? Number)?.toInt() ?: 0) // ── FIX: Added Shape saving here! ──
                                // ── Label mode: 0=off,1=progress,2=quote,3=custom ──
                                putInt("labelMode",   (call.argument<Any>("labelMode") as? Number)?.toInt() ?: 1)
                                putString("customLabel", call.argument<String>("customLabel") ?: "")
                                putString("bgImagePath", call.argument<String>("bgImagePath") ?: "")
                                putString("apiUrl", call.argument<String>("apiUrl") ?: "")
                                // ── Calendar mode ─────────────────────────────
                                putInt("mode", (call.argument<Any>("mode") as? Number)?.toInt() ?: 0)
                                // ── Goal ──────────────────────────────────────
                                putInt("goalTotal", (call.argument<Any>("goalTotal") as? Number)?.toInt() ?: 100)
                                putInt("goalPast",  (call.argument<Any>("goalPast")  as? Number)?.toInt() ?: 0)
                                putString("goalName", call.argument<String>("goalName") ?: "Goal")
                                // ── Life ──────────────────────────────────────
                                putInt("lifeTotal", (call.argument<Any>("lifeTotal") as? Number)?.toInt() ?: 29200)
                                putInt("lifeLived", (call.argument<Any>("lifeLived") as? Number)?.toInt() ?: 0)
                                apply()
                            }
                            result.success("saved")
                        } catch (e: Exception) {
                            result.error("SAVE_FAILED", e.message, null)
                        }
                    }

                    "openWallpaperPicker" -> {
                        var opened = false
                        if (!opened) try {
                            val i = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).apply {
                                putExtra(WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                                    ComponentName(packageName, "$packageName.DotzLiveWallpaper"))
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(i); opened = true
                        } catch (_: Exception) {}
                        if (!opened) try {
                            val i = Intent("android.service.wallpaper.LIVE_WALLPAPER_CHOOSER")
                            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(i); opened = true
                        } catch (_: Exception) {}
                        if (!opened) try {
                            val i = Intent(Intent.ACTION_SET_WALLPAPER)
                            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(i); opened = true
                        } catch (_: Exception) {}
                        if (opened) result.success("opened")
                        else result.error("FAILED", "Cannot open wallpaper picker", null)
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