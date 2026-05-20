import Foundation

func demoPhaseC() {
    ahla_init()
    ahla_kp_generate()
    if let my = ahla_pubkey_hex() {
        print("My PK:", String(cString: my))
        ahla_string_free(my)
    }
    _ = ahla_db_open("ahla_messages.db")
    // For demo (no remote peer), set peer= self to allow local enc/dec:
    if let my = ahla_pubkey_hex() {
        _ = ahla_set_peer_pubkey_hex(my)
        ahla_string_free(my)
    }
    // Store & export:
    _ = ahla_store_message("general", 1, "مرحبا من Swift Phase C")
    if let json = ahla_export_room_json("general") {
        print("Room dump:", String(cString: json))
        ahla_string_free(json)
    }
}
