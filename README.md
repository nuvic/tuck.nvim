# tuck.nvim

Automatically fold function bodies so you can actually see your code structure.

## Requirements

- Neovim 0.10+
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) with parsers installed for your languages:

```vim
:TSInstall ruby python lua javascript rust nix
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
- Nix

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
  integrations = {
    fzf_lua = false,
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

## How it works

tuck uses Tree-sitter queries to find function bodies, then sets up `foldexpr` to fold them. The queries live in `queries/tuck/` if you want to poke around or add new languages.

When you navigate via LSP (go to definition, references, etc.), tuck automatically unfolds the function body at the cursor position. This works with:

- Native LSP navigation (`vim.lsp.buf.definition()`, etc.)
- fzf-lua LSP pickers (with the integration enabled)

## Integrations

### fzf-lua

If you use [fzf-lua](https://github.com/ibhagwan/fzf-lua), enable the integration to automatically unfold when jumping via fzf-lua pickers:

```lua
require('tuck').setup({
  integrations = {
    fzf_lua = true,
  },
})
```

This patches fzf-lua's file actions (`file_edit`, `file_split`, `file_vsplit`, etc.) and LSP jump functions to unfold at cursor after jumping. Works with all fzf-lua pickers - `files`, `grep`, `lsp_definitions`, you name it.

Your existing fzf-lua keybinds and config are preserved.

## Troubleshooting

If it doesn't seem to work, run `:Tuck debug` to see what's happening.

## License

MIT
