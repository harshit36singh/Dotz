package com.wallpaper.dotz.ui.screens

import android.graphics.BitmapFactory
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.wallpaper.dotz.DotzViewModel
import com.wallpaper.dotz.data.DotzState
import com.wallpaper.dotz.ui.components.DotzIcons
import com.wallpaper.dotz.ui.components.PageHeader
import com.wallpaper.dotz.ui.components.Pip
import com.wallpaper.dotz.ui.components.PipMood
import com.wallpaper.dotz.ui.components.PrimaryButton
import com.wallpaper.dotz.ui.components.SecondaryButton
import com.wallpaper.dotz.ui.components.TextAction
import com.wallpaper.dotz.ui.theme.DotzType
import com.wallpaper.dotz.ui.theme.Ink
import com.wallpaper.dotz.ui.theme.Surface
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@Composable
fun BackgroundImageScreen(vm: DotzViewModel, state: DotzState, onBack: () -> Unit) {
    val picker = rememberLauncherForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri ->
        if (uri != null) vm.importBackground(uri)
    }
    val pick = { picker.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)) }
    val path = state.bgImagePath

    Column(
        Modifier
            .fillMaxSize()
            .background(Ink)
            .safeDrawingPadding()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 24.dp, vertical = 20.dp),
        verticalArrangement = Arrangement.spacedBy(24.dp),
    ) {
        PageHeader("Background image", onBack)

        if (path.isEmpty()) {
            Column(
                Modifier
                    .fillMaxWidth()
                    .padding(top = 40.dp, bottom = 16.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(14.dp),
            ) {
                Pip(size = 96.dp, mood = PipMood.WINK)
                Text("Use a photo behind the dots", style = DotzType.emptyTitle, textAlign = TextAlign.Center, modifier = Modifier.padding(top = 8.dp))
                Text(
                    "It's dimmed a little so the dots stay easy to read. Picking a background colour removes it.",
                    style = DotzType.body,
                    textAlign = TextAlign.Center,
                )
            }
            PrimaryButton("Choose from gallery", { pick() }, Modifier.fillMaxWidth())
        } else {
            val image by produceState<ImageBitmap?>(null, path) {
                value = withContext(Dispatchers.IO) {
                    val opts = BitmapFactory.Options().apply { inSampleSize = 4 }
                    BitmapFactory.decodeFile(path, opts)?.asImageBitmap()
                }
            }
            Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                Box(
                    Modifier
                        .width(200.dp)
                        .aspectRatio(9f / 19.5f)
                        .clip(RoundedCornerShape(28.dp))
                        .background(Surface),
                ) {
                    image?.let {
                        Image(it, contentDescription = "Selected background", contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize())
                    }
                }
            }
            Text("Custom image selected", style = DotzType.body, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth())
            Row(
                Modifier
                    .fillMaxWidth()
                    .navigationBarsPadding(),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                SecondaryButton("Change image", { pick() }, Modifier.weight(1f), icon = DotzIcons.Image)
                TextAction("Remove", vm::clearBackground)
            }
        }
    }
}
