package com.ahla.core
object AhlaCore {
    init { System.loadLibrary("ahla_core") }
    external fun echo(input: String): String
    external fun encryptXor(data: ByteArray, key: Byte): ByteArray
}
fun demoAhlaCore() {
    val e = AhlaCore.echo("مرحبا من Kotlin")
    println(e)
    val out = AhlaCore.encryptXor("hello".toByteArray(), 0x5A)
    println(out.joinToString())
}
