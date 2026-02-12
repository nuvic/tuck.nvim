local M = {}

local subcommands = {
  enable = function()
    require('tuck').enable()
  end,
  disable = function()
    require('tuck').disable()
  end,
  toggle = function()
    require('tuck').toggle()
  end,
  fold = function()
    require('tuck.fold').refold()
  end,
  debug = function()
    require('tuck.fold').debug()
  end,
}

function M.execute(args)
  local subcmd = args.fargs[1]

  if not subcmd then
    vim.notify('Tuck: subcommand required (enable, disable, toggle, fold)', vim.log.levels.ERROR)
    return
  end

  local fn = subcommands[subcmd]
  if fn then
    fn()
  else
    vim.notify('Tuck: unknown subcommand "' .. subcmd .. '"', vim.log.levels.ERROR)
  end
end

function M.complete(_, line)
  local words = vim.split(line, '%s+')
  if #words <= 2 then
    return vim.tbl_keys(subcommands)
  end
  return {}
end

return M
