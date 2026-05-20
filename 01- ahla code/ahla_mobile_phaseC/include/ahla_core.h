#ifndef AHLA_CORE_H
#define AHLA_CORE_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
void ahla_init(void);
void ahla_kp_generate(void);
char* ahla_pubkey_hex(void);
int ahla_set_peer_pubkey_hex(const char* hex);
char* ahla_encrypt_text(const char* plain);
char* ahla_decrypt_text(const char* b64);
void ahla_string_free(char* s);
int ahla_db_open(const char* path);
int ahla_store_message(const char* room, int mine, const char* plain);
char* ahla_export_room_json(const char* room);
int ahla_nats_connect(const char* url, const char* token);
int ahla_nats_subscribe_room(const char* room);
int ahla_nats_publish_room(const char* room, const char* plain);
char* ahla_nats_poll_json(void);
#ifdef __cplusplus
}
#endif
#endif
