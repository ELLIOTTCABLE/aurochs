(* Cgi-bin *)

open Aurochs_pack
open Peg
open Cgi
open Xml
open Pffpsf

let error_html msg =
  [
    U(N("h1", [], [D"Error"]));
    U(N("p", [],  [D msg]))
  ]

let br = O("br",[])

let paragraph x = N("p",[],x)

let div taxon child = N("div", [{n="class"; v=S taxon}], child)

let span taxon child = N("span", [{n="class"; v=S taxon}], child)

let textarea ~name ~rows ~cols ?(content="") () =
  U(N("textarea",
    [{n="rows"; v=I rows};
     {n="cols"; v=I cols};
     {n="name"; v=S name}],
     [D content]))

let submit ~name ~value () =
  U(N("input",
    [{n="type";  v=S"submit"};
     {n="value"; v=S value};
     {n="name";  v=S name}],
     []))

let make_html x =
  html_xml
    (
      N("html",
        [{n="xmlns";    v=S"http://www.w3.org/1999/xhtml"};
         {n="lang";     v=S"en"};
         {n="xml:lang"; v=S"en"}],
        [
          N("head", [],
            [
              U(N("title", [], [D"The Aurochs parser generator"]));
              O("meta",
                [{n="http-equiv"; v=S"Content-Type"};
                 {n="content";    v=S"text/html; charset=utf-8"}]);
              O("meta",
                [{n="name";       v=S"keyword"};
                 {n="content";    v=S"Aurochs, parse expression grammar, PEG, parsing, Ocaml, Java, C, memoization"}]);
              O("link",
                [{n="rel";       v=S"stylesheet"};
                 {n="type";      v=S"text/css"};
                 {n="href";      v=S"/default.css"};
                 {n="media";     v=S"screen"}]);
              O("link",
                [{n="rel";       v=S"icon"};
                 {n="type";      v=S"image/png"};
                 {n="href";      v=S"/icon.png"}])
            ]
          );
          N("body", [],
            (paragraph [D"Return to the"; N("a",[{n="href";v=S"/"}],[D"Aurochs homepage"])]) ::
            x);
        ]
      )
    )

type 'a model =
  {
    m_grammar : string;
    m_input   : string;
    m_output  : 'a;
    m_info    : Buffer.t
  }

let model0 =
  let (_, (grammar, input)) = List.hd Examples.examples in
  {
    m_grammar = grammar;
    m_input   = input;
    m_output  = paragraph [D"Welcome to the Aurochs parser generator on-line demonstration!  Please feel comfortable and try a few grammars."];
    m_info    = Buffer.create 8
  }

let reply h = reply_html (fun oc -> output_xml oc (make_html h))

let view model =
  reply
    [
      U(N("h1", [], [D"Aurochs parser"]));
      N("form", [{n="action"; v=S"demo.cgi"}; {n="method";v=S"post"}],
        [
          paragraph [D"PEG grammar:"];
          textarea ~name:"grammar" ~rows:25 ~cols:80 ~content:model.m_grammar ();
          br;
          paragraph [D"Input:"];
          textarea ~name:"input"   ~rows:5 ~cols:80 ~content:model.m_input ();
          br;
          submit ~name:"submit" ~value:"Parse" ();
          (* Examples *)
          div "examples"
            [
              paragraph [D"Some pre-defined examples:"];
              N("ul", [],
                List.map
                   (fun (name, _) -> N("li", [], [submit ~name:"example" ~value:name ()]))
                   Examples.examples)
            ]
        ]
      );
      model.m_output;
      div "info" [U(N("pre", [], [D(Buffer.contents model.m_info)]))]
    ]

let grammar_limit = 1000
let input_limit = 1000
let workload_limit = 1000000

let workload program input =
  let m = String.length input in
  let n =
    Aurochs.get_choice_count program *
    Aurochs.get_production_count program
  in
  m * n

let ( |< ) f g x = f (g x)

let split u i =
  let m = String.length u in
  let i = max 0 (min m i) in
  if i = m then
    (u, "")
  else
    if i = 0 then
      ("", u)
    else
      (String.sub u 0 i, String.sub u i (m - i))

let error text position =
  let (u, v) = split text position in
  U(
     N("pre",[],
       [
         D u;
         span "marker" [D " "];
         span "highlight" [D v];
         D " "
       ]
     )
   )

let convert_tree t =
  let rec loop = function
    | Token t -> div "token" [D t]
    | Node(name, attrs, child) ->
        let attrs' =
          List.map
            (fun (aname, aval) -> span "attribute" [D aname; D"="; D aval])
            attrs
        in
        match child with
        | [] ->
            div "node"
              [span "node-name"
                (List.concat[
                  [D("<" ^ name)];
                  attrs';
                  [D("/>")]
                ])
              ]
        | _ ->
            div "node"
              (List.concat
                [
                  [span "node-name"
                    (List.concat[
                      [D("<" ^ name)];
                      attrs';
                      [D">"]
                    ])];
                  List.map loop child;
                  [span "node-name" [D("</" ^ name ^">")]];
                ]
              )
  in
  loop t

let compute ~grammar ~input ?example () =
  let (grammar, input) =
    match example with
    | None -> (grammar, input)
    | Some name -> List.assoc name Examples.examples
  in
  let info = Buffer.create 256 in
  let model =
    {
      model0 with
      m_grammar = grammar;
      m_input   = input;
      m_info    = info;
    }
  in
  let err x = { model with m_output  = div "error" x } in
  if String.length grammar > grammar_limit then
    err [paragraph [D"Grammar too big for on-line version"]]
  else if String.length input > input_limit then
    err [paragraph [D"Input too big for on-line version"]]
  else
    try
      let bin = 
        try
          !Aurochs.compiler grammar
        with
        | x -> raise (Aurochs.Compile_error x)
      in
      let prog = Aurochs.program_of_binary bin in
      let w = workload prog input in
      bf info "Total %d productions\n" (Aurochs.get_production_count prog);
      bf info "Total %d choices\n" (Aurochs.get_choice_count prog);
      bf info "Total %d constructors\n" (Aurochs.get_constructor_count prog);
      bf info "Total %d attributes\n" (Aurochs.get_attribute_count prog);
      bf info "Workload %d units\n" w;
      if w > workload_limit then
        err [paragraph [D(sf "Workload of %d is too high for on-line version, limit is %d" w workload_limit)]]
      else
        let t = Aurochs.parse_generic prog input in
        let output = convert_tree t in
        { model with m_output  = div "tree" [output] }
    with
    | Check.Error u -> err [paragraph [D(sf "Grammar error: %s" u)]]
    | Aurochs.Compile_error(Aurochs.Error u|Check.Error u) -> err [paragraph [D(sf "Error in grammar: %s" u)]]
    | Aurochs.Compile_error(Aurochs.Parse_error n) ->
       err
         [
           paragraph [D(sf "Parse error in grammar at %d" n)];
           error grammar n
         ]
    | Aurochs.Parse_error n ->
        err
          [
            paragraph [D(sf "Parse error in input at %d" n)];
            error input n
          ]
    | Aurochs.Compile_error x -> err [paragraph [D(sf "Error in grammar: %s" (Printexc.to_string x))]]
    | Aurochs.Error u -> err [paragraph [D(sf "Parse error in input: %s" u)]]
    | Canonify.Error u -> err [paragraph [D(sf "Can't canonify grammar: %s" u)]]
    | x -> err [paragraph [D(sf "Exception: %s" (Printexc.to_string x))]]

let _ =
  (*let host = remote_host in*)
  match invocation_method () with
  | GET -> view model0
  | POST ->
      let form = Form.parse_form_from_stream (Stream.of_channel stdin) in
      let gs key = Form.get_value form Form.to_string key in
      let model =
        compute
          ~grammar:(gs "grammar")
          ~input:(gs "input")
          ?example:(Form.get_value form ~default:None (Form.some |< Form.to_string) "example")
          ()
      in
      view model
