package com.ahla.core
object AhlaCore {
    init { System.loadLibrary("ahla_core") }
    external fun echo(input: String): String
    external fun encryptXor(data: ByteArray, key: Byte): ByteArray
}
