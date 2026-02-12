; Top-level function bodies
(function_declaration
  body: (block) @fold)

; Method definitions in tables (common Lua pattern)
(field
  value: (function_definition
    body: (block) @fold))

; Local function bodies
(local_function
  body: (block) @fold)
