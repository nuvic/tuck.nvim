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
    local config = require('tuck.config')
    print('')
    print('=== Integrations ===')
    print('fzf_lua enabled: ' .. tostring(config.options.integrations.fzf_lua))
    if config.options.integrations.fzf_lua then
      require('tuck.integrations.fzf_lua').debug()
    end
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
