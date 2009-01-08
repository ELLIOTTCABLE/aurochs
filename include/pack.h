/* pack.h
 *
 * Byte packer
 *
 * Copyright(C) 2007 Exalead SA
 */

#ifndef PACK_H
#define PACK_H

#include <base_types.h>
#include <alloc.h>

typedef size_t (*pack_resplenisher_t)(void *, u8 *, size_t);
typedef void (*pack_observer_t)(void *, u8 *, size_t);
  
typedef struct {
  size_t p_block_size;
  size_t p_index;
  size_t p_length;
  void *p_extra;
  pack_resplenisher_t p_resplenish;
  void *p_observer_extra;
  pack_observer_t p_observer;
  u8 *p_data;
} packer_t;

#define PACK_STOP 0x80
#define PACK_NEGATIVE 0x40

EXPORT bool pack_init(packer_t *pk, u8 *block_buffer, size_t block_size, void *extra, pack_resplenisher_t resplenish);
EXPORT bool pack_init_from_string(packer_t *pk, u8 *data, size_t size);
EXPORT void pack_shutdown(packer_t *pk);
EXPORT bool pack_set_observer(packer_t *pk, void *observer_extra, pack_observer_t observe);
EXPORT bool pack_finish_observing(packer_t *pk);
EXPORT bool pack_resplenish(packer_t *pk);
EXPORT bool pack_read_uint8(packer_t *pk, u8 *result);
EXPORT bool pack_read_bytes(packer_t *pk, u8 *result, size_t count);
EXPORT bool pack_read_string(packer_t *pk, u8 **result, size_t *length, alloc_t *alloc);
EXPORT bool pack_read_int64(packer_t *pk, s64 *result);
EXPORT bool pack_read_uint64(packer_t *pk, u64 *result);
EXPORT bool pack_read_int(packer_t *pk, int *result);
EXPORT bool pack_read_uint(packer_t *pk, unsigned int *result);

#endif
