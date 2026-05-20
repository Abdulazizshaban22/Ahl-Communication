import Foundation

final class AhlaCoreBridge {
    static let shared = AhlaCoreBridge()
    private init() { ahla_init() }

    func echo(_ text: String) -> String {
        guard let c = text.cString(using: .utf8), let ptr = ahla_echo(c) else { return "" }
        defer { ahla_string_free(ptr) }
        return String(cString: ptr)
    }

    func encryptXor(_ text: String, key: UInt8 = 0x5A) -> Data {
        let bytes = Array(text.utf8)
        var buf = bytes.withUnsafeBufferPointer { ahla_encrypt_xor($0.baseAddress, UInt(bytes.count), key) }
        defer { ahla_buf_free(buf) }
        return Data(bytes: buf.ptr, count: Int(buf.len))
    }
}
