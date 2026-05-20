package com.ahla.core
object AhlaCore {
    init { System.loadLibrary("ahla_core") }
    external fun pubkeyHex(): String
    external fun setPeerPubkey(hex: String): Int
}
