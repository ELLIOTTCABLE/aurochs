/* peg.h
 *
 * Copyright (C)2007 Exalead
 */

#ifndef PEG_H
#define PEG_H

#include <stdio.h>
#include <base_types.h>
#include <alloc.h>
#include <staloc.h>
#include <pushdown.h>

typedef enum {
  R_EOF = -1,
  R_UNKNOWN = -2,
  R_FAIL = -3,
  R_BUSY = -4
} memo_t;

typedef int choice_t;

typedef struct {
  int key;
  int value;
} memo_cell_t;

#define CHOICE_CELLS_PER_BLOCK 1
#define RESULT_CELLS_PER_BLOCK 7
#define MEMO_INVALID_KEY (-1)

struct memo_block {
  struct memo_block *next;
  memo_cell_t cells[1];
};

typedef struct memo_block memo_block_t;

#if LONG_LETTERS
typedef unsigned int letter_t;
#else
typedef unsigned char letter_t;
#endif

typedef int symbol_t;

/* Builder callbacks */
#if !BUILDER_TYPES_DEFINED
typedef struct { int dummy; }* info;
typedef struct { int dummy; }* tree;
typedef struct { int dummy; }* construction;
#endif

typedef struct {
  info pb_info;
  construction (*pb_start_construction)(info a, int id, unsigned char *name, int n_begin);
  bool (*pb_add_children)(info a, construction c, tree tr2);
  bool (*pb_add_token)(info a, construction c, int t_begin, int t_end);
  bool (*pb_add_attribute)(info a, construction c, int id, unsigned char *name, int v_begin, int v_end);
  bool (*pb_add_constant_attribute)(info a, construction c, int id, unsigned char *name, unsigned char *value, int size);
  tree (*pb_finish_construction)(info a, construction t, int n_end);
} peg_builder_t;

#if 0
/* Specific */
void (*pb_delete_attribute)(info *a, attribute *at);
void (*pb_delete_tree)(info *a, tree *tr);
void (*pb_reverse_sibling)(info *a, tree *tr);
void (*pb_reverse_tree)(info *a, tree *tr);
void (*pb_dump_tree)(info *a, FILE *f, unsigned char *input, tree *tr, int indent);
#endif

/* Execution context.  None of your business. */
typedef struct {
  alloc_t *cx_alloc;
  letter_t *cx_input;
  memo_block_t **cx_results;
  memo_block_t **cx_choices;
  staloc_t *cx_table_staloc; 
  pushdown_t *cx_stack;
  int cx_stack_size;
  int cx_input_length;
  int cx_num_productions;
  int cx_num_alternatives;
  peg_builder_t *cx_builder;
  info cx_builder_info;
} peg_context_t;

#endif
