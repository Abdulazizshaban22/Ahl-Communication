import Foundation
func demoAhlaCore() {
    ahla_init()
    let msg = "مرحبا من Swift"
    if let c = msg.cString(using: .utf8) {
        if let ptr = ahla_echo(c) {
            print(String(cString: ptr))
            ahla_string_free(ptr)
        }
    }
    let bytes = Array("hello".utf8)
    var buf = bytes.withUnsafeBufferPointer { ahla_encrypt_xor($0.baseAddress, UInt(bytes.count), 0x5A) }
    let data = Data(bytes: buf.ptr, count: Int(buf.len))
    print("Encrypted len:", data.count)
    ahla_buf_free(buf)
}
