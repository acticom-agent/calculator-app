package com.example.calculator

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val Orange = Color(0xFFFF9800)
private val DarkGray = Color(0xFF333333)
private val LightGray = Color(0xFFA5A5A5)

@Composable
fun CalculatorApp() {
    var display by remember { mutableStateOf("0") }
    var operand1 by remember { mutableStateOf<Double?>(null) }
    var operator by remember { mutableStateOf<String?>(null) }
    var resetNext by remember { mutableStateOf(false) }

    fun onNumber(n: String) {
        if (resetNext) { display = n; resetNext = false }
        else if (display == "0" && n != ".") display = n
        else if (n == "." && display.contains(".")) { /* ignore */ }
        else display += n
    }

    fun calculate(): Double? {
        val a = operand1 ?: return null
        val b = display.toDoubleOrNull() ?: return null
        return when (operator) {
            "+" -> a + b; "−" -> a - b; "×" -> a * b
            "÷" -> if (b != 0.0) a / b else null; else -> null
        }
    }

    fun formatResult(v: Double): String =
        if (v == v.toLong().toDouble() && v in Long.MIN_VALUE.toDouble()..Long.MAX_VALUE.toDouble())
            v.toLong().toString() else v.toString()

    fun onOperator(op: String) {
        if (operand1 != null && operator != null && !resetNext) {
            val result = calculate()
            if (result != null) { display = formatResult(result); operand1 = result }
        } else { operand1 = display.toDoubleOrNull() }
        operator = op; resetNext = true
    }

    fun onEquals() {
        val result = calculate()
        if (result != null) display = formatResult(result)
        operand1 = null; operator = null; resetNext = true
    }

    fun onClear() { display = "0"; operand1 = null; operator = null; resetNext = false }

    fun onBackspace() {
        if (display.length > 1) display = display.dropLast(1) else display = "0"
    }

    fun onPercent() {
        val v = display.toDoubleOrNull() ?: return
        display = formatResult(v / 100.0)
    }

    MaterialTheme(colorScheme = darkColorScheme()) {
        Column(
            modifier = Modifier.fillMaxSize().background(Color.Black).padding(12.dp)
                .systemBarsPadding(),
            verticalArrangement = Arrangement.Bottom
        ) {
            Text(
                text = display, color = Color.White, fontSize = 64.sp,
                fontWeight = FontWeight.Light, textAlign = TextAlign.End,
                maxLines = 1, overflow = TextOverflow.Ellipsis,
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 24.dp)
            )

            val buttons = listOf(
                listOf("C", "⌫", "%", "÷"),
                listOf("7", "8", "9", "×"),
                listOf("4", "5", "6", "−"),
                listOf("1", "2", "3", "+"),
                listOf("0", ".", "=")
            )

            buttons.forEach { row ->
                Row(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    row.forEach { label ->
                        val isOp = label in listOf("+", "−", "×", "÷", "=")
                        val isFunc = label in listOf("C", "⌫", "%")
                        val isZero = label == "0"
                        val bg = when { isOp -> Orange; isFunc -> LightGray; else -> DarkGray }
                        val fg = when { isFunc -> Color.Black; else -> Color.White }
                        val weight = if (isZero) 2.14f else 1f

                        Button(
                            onClick = {
                                when {
                                    label == "C" -> onClear()
                                    label == "⌫" -> onBackspace()
                                    label == "%" -> onPercent()
                                    label == "=" -> onEquals()
                                    isOp -> onOperator(label)
                                    else -> onNumber(label)
                                }
                            },
                            modifier = Modifier.weight(weight).aspectRatio(if (isZero) 2.14f else 1f),
                            shape = CircleShape,
                            colors = ButtonDefaults.buttonColors(containerColor = bg, contentColor = fg),
                            contentPadding = PaddingValues(0.dp)
                        ) {
                            Text(label, fontSize = 28.sp, fontWeight = FontWeight.Medium)
                        }
                    }
                }
            }
        }
    }
}
