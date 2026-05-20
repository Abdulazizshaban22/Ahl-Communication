package com.ahla.chat

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import com.ahla.core.AhlaCore

data class Message(val mine: Boolean, val text: String)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                ChatScreen()
            }
        }
    }
}

@Composable
fun ChatScreen() {
    var messages by remember { mutableStateOf(listOf(
        Message(false, "مرحبا 👋🏽"), Message(true, "يا هلا")
    ))}
    var draft by remember { mutableStateOf(TextFieldValue("")) }

    Column(modifier = Modifier.fillMaxSize()) {
        LazyColumn(
            modifier = Modifier.weight(1f).fillMaxWidth().padding(8.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(messages) { m ->
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = if (m.mine) Arrangement.End else Arrangement.Start
                ) {
                    Surface(
                        color = if (m.mine) Color(0x336CC5A3) else Color(0x22000000),
                        shape = MaterialTheme.shapes.medium
                    ) {
                        Text(m.text, modifier = Modifier.padding(12.dp))
                    }
                }
            }
        }
        Row(modifier = Modifier.fillMaxWidth().padding(8.dp), verticalAlignment = Alignment.CenterVertically) {
            TextField(value = draft, onValueChange = { draft = it }, modifier = Modifier.weight(1f), placeholder = { Text("اكتب رسالة…") })
            Spacer(Modifier.width(8.dp))
            Button(onClick = {
                val t = draft.text
                if (t.isNotBlank()) {
                    messages = messages + Message(true, t)
                    val echoed = AhlaCore.echo(t)
                    messages = messages + Message(false, echoed)
                    draft = TextFieldValue("")
                }
            }) { Text("إرسال") }
        }
    }
}
