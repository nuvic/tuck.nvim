local M = {}

local config = require('tuck.config')
local fold = require('tuck.fold')
local lsp = require('tuck.lsp')

local augroup = vim.api.nvim_create_augroup('Tuck', { clear = true })

local function setup_autocmds()
  vim.api.nvim_clear_autocmds({ group = augroup })

  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = augroup,
    callback = function(args)
      if config.options.enabled then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(args.buf) then
            fold.apply_folds(args.buf)
          end
        end)
      end
    end,
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = augroup,
    callback = function(args)
      if config.options.enabled and not config.is_excluded(args.buf) then
        lsp.setup_keymaps(args.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd('TextChanged', {
    group = augroup,
    callback = function(args)
      fold.invalidate_cache(args.buf)
    end,
  })
end

function M.setup(opts)
  config.setup(opts)
  setup_autocmds()

  if config.options.enabled then
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].filetype ~= '' then
      fold.apply_folds(bufnr)
    end
  end
end

function M.enable()
  config.options.enabled = true
  setup_autocmds()
  fold.apply_folds()
  vim.notify('Tuck enabled', vim.log.levels.INFO)
end

function M.disable()
  config.options.enabled = false
  vim.api.nvim_clear_autocmds({ group = augroup })
  fold.reset_folds()
  vim.notify('Tuck disabled', vim.log.levels.INFO)
end

function M.toggle()
  if config.options.enabled then
    M.disable()
  else
    M.enable()
  end
end

M.definition = lsp.definition
M.references = lsp.references
M.implementation = lsp.implementation
M.type_definition = lsp.type_definition

return M
