; Function bodies
(function_item
  body: (block) @fold)

; Method bodies in impl blocks
(impl_item
  body: (declaration_list
    (function_item
      body: (block) @fold)))

; Trait method bodies (default implementations)
(trait_item
  body: (declaration_list
    (function_item
      body: (block) @fold)))
