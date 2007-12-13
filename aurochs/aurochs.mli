(* Aurochs *)

(** The main module for all your parsing needs! *)

(** This type alias helps distinguish binary programs from other strings. *)
type binary = string

(** This exception is raised on parse error.  The integer is the character position in the input. *)
exception Parse_error of int

(** This exception is raised on generic errors. *)
exception Error of string

(** Aurochs programs are represented using this abstract type.
    Actually, the program is malloc()'d and represented using C structures. *)
type ('node, 'attribute) program

(** A generic program *)
type generic_program = (int, int) program

(** Return the number of productions used in the grammar *)
val get_production_count : ('node, 'attribute) program -> int

(** Return the number of alternatives used in the grammar *)
val get_choice_count : ('node, 'attribute) program -> int

(** Return the number of constructors used in the grammar *)
val get_constructor_count : ('node, 'attribute) program -> int

(** Return the number of attributes used in the grammar *)
val get_attribute_count : ('node, 'attribute) program -> int

(** Get a table giving the string representation of node constructors *)
val constructors : ('node, 'attribute) program -> string array

(** Get a table giving the string representation of node attributes *)
val attributes : ('node, 'attribute) program -> string array

(** Unpack a binary string and create a program. *)
val program_of_binary : binary -> ('node, 'attribute) program

(** Parse a given string *)
val parse : ('node, 'attribute) program -> string -> ('node, 'attribute) Peg.poly_positioned_tree

(** Convert a positioned tree to a string tree *)
val convert_tree : ('node, 'attribute) program -> (int, int) Peg.poly_positioned_tree -> (string, string) Peg.poly_positioned_tree

(** Parse a given string *)
val parse_generic : generic_program -> string -> Peg.tree

(** Exception wrapper to differentiate between compile and parse errors. *)
exception Compile_error of exn

(** Mutable value for bootstrapping *)
val compiler : (?start:string -> ?base:string -> ?root:string -> ?check:bool -> string -> binary) ref

(** Interface to the compiler.
    Takes PEG source code and returns a program string. *)
val compile : ?start:string -> ?base:string -> ?root:string -> ?check:bool -> string -> binary

(** Convenience function *)

type data = [`File of string | `String of string]

val load : data -> string

val read :
   grammar:[`Source of data|`Program of ('n, 'a) program Lazy.t|`Binary of data] ->
   text:data ->
   ('n, 'a) Peg.poly_tree

val read_positioned :
   grammar:[`Source of data|`Program of ('n, 'a) program Lazy.t|`Binary of data] ->
   text:data ->
   ('n, 'a) Peg.poly_positioned_tree

val see :
   grammar:[`Source of data|`Program of generic_program Lazy.t|`Binary of data] ->
   text:data ->
   Peg.tree

val read_file : string -> string
