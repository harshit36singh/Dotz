package com.wallpaper.dotz.data

import org.json.JSONArray
import java.net.HttpURLConnection
import java.net.URL

/**
 * Quote endpoint shared by the app and the live wallpaper, so both fetch and
 * format quotes the same way. Expects the zenquotes shape `[{"q": "...", "a": "..."}]`.
 */
object QuoteApi {

    /** Blocking: call off the main thread. Returns (quote, author) or null. */
    fun fetch(url: String): Pair<String, String>? {
        if (url.isBlank()) return null
        return try {
            val conn = (URL(url).openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                setRequestProperty("Accept", "application/json")
                connectTimeout = 8000
                readTimeout = 8000
            }
            try {
                if (conn.responseCode != 200) return null
                val body = conn.inputStream.bufferedReader().use { it.readText() }
                val arr = JSONArray(body)
                if (arr.length() == 0) return null
                val item = arr.getJSONObject(0)
                val q = item.optString("q").trim()
                val a = item.optString("a").trim()
                if (q.isEmpty()) null else q to a
            } finally {
                conn.disconnect()
            }
        } catch (e: Exception) {
            null
        }
    }

    /**
     * zenquotes' `/today` returns the same quote all day; `/random` gives a new
     * one per call. Other endpoints are used as-is.
     */
    fun randomUrl(url: String): String =
        if (url.endsWith("/today")) url.removeSuffix("/today") + "/random" else url

    /** The label text for a quote, as both the preview and the wallpaper show it. */
    fun format(quote: String, author: String): String =
        if (author.isNotBlank()) "“$quote” — $author" else "“$quote”"
}
