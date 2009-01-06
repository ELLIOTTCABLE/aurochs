/* parse_tree.h
 *
 */

#ifndef PARSE_TREE_H
#define PARSE_TREE_H

#include <stdio.h>
#include <alloc.h>
#include <base_types.h>

typedef enum {
  TREE_NODE,
  TREE_TOKEN,
} tree_kind;

typedef unsigned char *string;

struct _tree;

typedef struct {
  int s_begin;
  int s_end;
} substring;

struct _attribute;

typedef struct _attribute {
  struct _attribute *a_sibling;
  string a_name;
  substring a_value;
} attribute_t;

typedef struct {
  string n_name;
  attribute_t *n_attributes;
  struct _tree *n_children;
} node_t;

typedef substring token_t;

typedef struct _tree {
  tree_kind t_kind;
  struct _tree *t_sibling;
  struct _tree *t_parent;
  union {
    node_t t_node;
    token_t t_token;
  } t_element;
} tree_t;

typedef tree_t *construction;
typedef tree_t *tree;
typedef node_t *node;
typedef attribute_t *attribute;
typedef alloc_t *info;
typedef token_t *token;

#define BUILDER_TYPES_DEFINED 1

#include <peg.h>

construction ptree_start_construction(info pti, int id, unsigned char *name, int begin);
bool ptree_add_attribute(info pti, construction tr, int id, unsigned char *name, int v_begin, int v_end);
bool ptree_add_token(info pti, construction tr, int t_begin, int t_end);
bool ptree_add_children(info pti, construction tr1, tree tr2);
tree ptree_finish_construction(info pti, construction c, int end);

void ptree_delete_attribute(info pti, attribute at);
void ptree_delete_tree(info pti, tree tr);
void ptree_reverse_sibling(info pti, tree tr);
void ptree_reverse_tree(info pti, tree tr);
void ptree_dump_tree(info pti, FILE *f, unsigned char *input, tree tr, int indent);
void ptree_dump_context(info pti, FILE *f, peg_context_t *cx);
void ptree_init(peg_builder_t *pb, alloc_t *alloc);

#endif
