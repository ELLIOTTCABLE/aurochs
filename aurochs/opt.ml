(* Opt *)

let targets : [`nog|`c_table_nog|`ml|`mli|`ml_classic|`c] list ref = ref []
let interpreter : [`exp|`mlnog|`nog] ref = ref `nog
let dump_grammar : string option ref = ref None
let dump_canonified : string option ref = ref None
let dump_xml : string option ref = ref None
let dump_nog : string option ref = ref None
let load_nog : string option ref = ref None
let ml_load_nog : string option ref = ref None
let ml_save_nog : string option ref = ref None
let nog_file : string option ref = ref None
let prologue = ref "unsigned char nog[] = {"
let epilogue = ref "};"
let dump_colorized : string option ref = ref None
let colorize_background = ref false
let tree = ref true
let show_memo : string option ref = ref None
let show_choices : string option ref = ref None
let build_only = ref false
let log_calls : string option ref = ref None
let record : string option ref = ref None
let debug = ref false
let trace = ref false
let parse : string list ref = ref []
let parse_with_nog = ref true
let start = ref "start"
let generate = ref false
let base : string option ref = ref None
let function_prefix = ref ""
let node_prefix = ref "N_"
let root_node = ref "Root"
let attribute_prefix = ref "A_"
let bootstrap = ref false
let line = ref false
let quick = ref false
let profile : string option ref = ref None
let quiet = ref false
let terse = ref false
let indent = ref true

let warning : Talk_level.level ref = ref `Normal
let info    : Talk_level.level ref = ref `Normal
let error   : Talk_level.level ref = ref `Normal
