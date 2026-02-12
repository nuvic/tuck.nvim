if vim.g.loaded_tuck then
  return
end
vim.g.loaded_tuck = true

vim.api.nvim_create_user_command('Tuck', function(args)
  require('tuck.commands').execute(args)
end, {
  nargs = 1,
  complete = function(arg_lead, line, cursor_pos)
    return require('tuck.commands').complete(arg_lead, line, cursor_pos)
  end,
})
