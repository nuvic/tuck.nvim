# tuck.nvim

Automatically fold function bodies so you can actually see your code structure.

## Requirements

- Neovim 0.9+
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) with parsers installed for your languages:

```vim
:TSInstall ruby python lua javascript rust
```

Inspired by [this article](https://matklad.github.io/2024/10/14/missing-ide-feature.html) from matklad - the idea is simple: function signatures are way more useful than function bodies when you're reading code. So let's fold the bodies by default.

When you jump to a definition via LSP, tuck automatically unfolds at the cursor. Everything else stays tucked away.

## What it does

- Folds top-level function/method bodies on file open
- Unfolds at cursor when you use LSP navigation (go to definition, references, etc.)
- Uses Tree-sitter, so it actually understands your code

## Supported languages

- Lua
- Ruby  
- Python
- JavaScript
- Rust

PRs welcome for more languages - the queries are pretty simple.

## Installation

lazy.nvim:
```lua
{
  'nuvic/tuck.nvim',
  config = function()
    require('tuck').setup()
  end,
}
```

packer:
```lua
use {
  'nuvic/tuck.nvim',
  config = function()
    require('tuck').setup()
  end,
}
```

## Configuration

```lua
require('tuck').setup({
  enabled = true,
  exclude_filetypes = { 'markdown', 'text' },
  exclude_paths = { 'vendor/*', 'node_modules/*' },
  keymaps = {
    enabled = true,       -- set to false if you want to handle keymaps yourself
    definition = 'gd',
    references = 'gr',
    implementation = 'gi',
    type_definition = 'gy',
  },
})
```

## Commands

| Command | What it does |
|---------|--------------|
| `:Tuck enable` | Turn it on |
| `:Tuck disable` | Turn it off |
| `:Tuck toggle` | Toggle |
| `:Tuck fold` | Re-fold everything in current buffer |

## Using your own keymaps

If you've got your own LSP keymaps and don't want tuck stepping on them, disable the built-in keymaps and call the functions directly:

```lua
require('tuck').setup({
  keymaps = { enabled = false },
})

-- Then in your LSP on_attach or wherever:
vim.keymap.set('n', '<leader>gd', require('tuck').definition)
vim.keymap.set('n', '<leader>gr', require('tuck').references)
vim.keymap.set('n', '<leader>gi', require('tuck').implementation)
vim.keymap.set('n', '<leader>gy', require('tuck').type_definition)
```

These are just wrappers around the normal `vim.lsp.buf.*` functions that unfold at the cursor after jumping.

## How it works

tuck uses Tree-sitter queries to find function bodies, then sets up `foldexpr` to fold them. The queries live in `queries/tuck/` if you want to poke around or add new languages.

When you call one of the LSP navigation wrappers, it does the normal LSP thing and then runs `zO` to recursively open folds at the cursor.

## Troubleshooting

If it doesn't seem to work,run `:Tuck debug` to see what's happening.

## License

MIT
