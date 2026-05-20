#ifndef AHLA_CORE_H
#define AHLA_CORE_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
void ahla_init(void);
char* ahla_echo(const char* input);
void ahla_string_free(char* s);
typedef struct AhlaBuf {
    uint8_t* ptr;
    uintptr_t len;
    uintptr_t cap;
} AhlaBuf;
AhlaBuf ahla_encrypt_xor(const uint8_t* data, uintptr_t len, uint8_t key);
void ahla_buf_free(AhlaBuf buf);
#ifdef __cplusplus
}
#endif
#endif
