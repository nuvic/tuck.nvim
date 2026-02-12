local M = {}

M.defaults = {
  enabled = true,
  exclude_filetypes = {},
  exclude_paths = {},
  keymaps = {
    enabled = true,
    definition = 'gd',
    references = 'gr',
    implementation = 'gi',
    type_definition = 'gy',
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', {}, M.defaults, opts or {})
end

function M.is_excluded(bufnr)
  bufnr = bufnr or 0
  local ft = vim.bo[bufnr].filetype
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  for _, excluded_ft in ipairs(M.options.exclude_filetypes) do
    if ft == excluded_ft then
      return true
    end
  end

  for _, pattern in ipairs(M.options.exclude_paths) do
    if vim.fn.match(filepath, vim.fn.glob2regpat(pattern)) >= 0 then
      return true
    end
  end

  return false
end

return M
