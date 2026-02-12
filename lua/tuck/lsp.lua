local M = {}

local config = require('tuck.config')

local function unfold_at_cursor()
  vim.schedule(function()
    pcall(vim.cmd, 'silent! normal! zO')
  end)
end

function M.definition()
  vim.lsp.buf.definition()
  unfold_at_cursor()
end

function M.references()
  vim.lsp.buf.references()
  unfold_at_cursor()
end

function M.implementation()
  vim.lsp.buf.implementation()
  unfold_at_cursor()
end

function M.type_definition()
  vim.lsp.buf.type_definition()
  unfold_at_cursor()
end

function M.setup_keymaps(bufnr)
  local keymaps = config.options.keymaps
  if not keymaps.enabled then
    return
  end

  local opts = { buffer = bufnr, silent = true }

  if keymaps.definition then
    vim.keymap.set('n', keymaps.definition, M.definition, opts)
  end

  if keymaps.references then
    vim.keymap.set('n', keymaps.references, M.references, opts)
  end

  if keymaps.implementation then
    vim.keymap.set('n', keymaps.implementation, M.implementation, opts)
  end

  if keymaps.type_definition then
    vim.keymap.set('n', keymaps.type_definition, M.type_definition, opts)
  end
end

return M
