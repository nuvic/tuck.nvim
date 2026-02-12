local M = {}

local config = require('tuck.config')

local query_cache = {}

local function get_query(lang)
  if query_cache[lang] then
    return query_cache[lang]
  end

  local query_path = vim.api.nvim_get_runtime_file('queries/tuck/' .. lang .. '.scm', false)[1]
  if not query_path then
    return nil
  end

  local query_file = io.open(query_path, 'r')
  if not query_file then
    return nil
  end

  local query_text = query_file:read('*all')
  query_file:close()

  local ok, query = pcall(vim.treesitter.query.parse, lang, query_text)
  if not ok then
    return nil
  end

  query_cache[lang] = query
  return query
end

local notified_missing_parser = {}

local function get_fold_ranges(bufnr)
  local ft = vim.bo[bufnr].filetype
  local lang = vim.treesitter.language.get_lang(ft) or ft

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok or not parser then
    if not notified_missing_parser[lang] then
      vim.notify(
        string.format('Tuck: Tree-sitter parser for "%s" not found. Run :TSInstall %s', lang, lang),
        vim.log.levels.WARN
      )
      notified_missing_parser[lang] = true
    end
    return {}
  end

  local query = get_query(lang)
  if not query then
    return {}
  end

  local tree = parser:parse()[1]
  if not tree then
    return {}
  end

  local ranges = {}
  for _, match, _ in query:iter_matches(tree:root(), bufnr, 0, -1) do
    for id, nodes in pairs(match) do
      local name = query.captures[id]
      if name == 'fold' then
        local node_list = type(nodes) == 'table' and nodes or { nodes }
        for _, node in ipairs(node_list) do
          local start_row, _, end_row, _ = node:range()
          if end_row > start_row then
            table.insert(ranges, { start_row + 1, end_row + 1 })
          end
        end
      end
    end
  end

  return ranges
end

function M.foldexpr(lnum)
  local bufnr = vim.api.nvim_get_current_buf()

  if not M._fold_cache then
    M._fold_cache = {}
  end

  if not M._fold_cache[bufnr] then
    M._fold_cache[bufnr] = get_fold_ranges(bufnr)
  end

  local ranges = M._fold_cache[bufnr]

  for _, range in ipairs(ranges) do
    local start_row, end_row = range[1], range[2]
    if lnum == start_row then
      return '>1'
    elseif lnum > start_row and lnum <= end_row then
      return '1'
    end
  end

  return '0'
end

function M.invalidate_cache(bufnr)
  if M._fold_cache then
    M._fold_cache[bufnr or vim.api.nvim_get_current_buf()] = nil
  end
end

function M.apply_folds(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if config.is_excluded(bufnr) then
    return
  end

  local ft = vim.bo[bufnr].filetype
  local lang = vim.treesitter.language.get_lang(ft) or ft
  if not get_query(lang) then
    return
  end

  M.invalidate_cache(bufnr)

  vim.wo.foldmethod = 'expr'
  vim.wo.foldexpr = "v:lua.require'tuck.fold'.foldexpr(v:lnum)"
  vim.wo.foldlevel = 0
  vim.wo.foldenable = true

  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_get_current_buf() == bufnr then
      vim.cmd('silent! normal! zM')
    end
  end)
end

function M.reset_folds(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  M.invalidate_cache(bufnr)

  vim.wo.foldmethod = 'manual'
  vim.wo.foldexpr = ''
  vim.wo.foldenable = false
  vim.cmd('silent! normal! zR')
end

function M.refold(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  M.invalidate_cache(bufnr)
  vim.cmd('silent! normal! zM')
end

function M.debug(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local lang = vim.treesitter.language.get_lang(ft) or ft

  print('=== Tuck Debug ===')
  print('Buffer: ' .. bufnr)
  print('Filetype: ' .. ft)
  print('Language: ' .. lang)

  local query_path = vim.api.nvim_get_runtime_file('queries/tuck/' .. lang .. '.scm', false)[1]
  if query_path then
    print('Query file: ' .. query_path)
  else
    print('Query file: NOT FOUND')
    print('  Searched for: queries/tuck/' .. lang .. '.scm')
    return
  end

  local query_file = io.open(query_path, 'r')
  if not query_file then
    print('Query file: FAILED TO OPEN')
    return
  end
  local query_text = query_file:read('*all')
  query_file:close()
  print('Query text:\n' .. query_text)

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok then
    print('Parser: FAILED - ' .. tostring(parser))
    return
  end
  if not parser then
    print('Parser: NIL')
    return
  end
  print('Parser: OK')

  local parse_ok, query = pcall(vim.treesitter.query.parse, lang, query_text)
  if not parse_ok then
    print('Query parse: FAILED - ' .. tostring(query))
    return
  end
  print('Query parse: OK')

  local tree = parser:parse()[1]
  if not tree then
    print('Tree: NIL')
    return
  end
  print('Tree: OK')

  local ranges = get_fold_ranges(bufnr)
  print('Fold ranges found: ' .. #ranges)
  for i, range in ipairs(ranges) do
    print('  ' .. i .. ': lines ' .. range[1] .. '-' .. range[2])
  end

  print('=== End Debug ===')
end

return M
