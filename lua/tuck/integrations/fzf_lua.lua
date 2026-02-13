local M = {}

local patched = false
local originals = {}

function M.is_patched()
  return patched
end

local function with_unfold(original_fn)
  return function(selected, opts)
    original_fn(selected, opts)
    vim.defer_fn(function()
      require('tuck.fold').unfold_at_cursor()
    end, 50)
  end
end

local function with_unfold_jump(original_fn)
  return function(...)
    local result = original_fn(...)
    vim.defer_fn(function()
      require('tuck.fold').unfold_at_cursor()
    end, 50)
    return result
  end
end

function M.setup()
  if patched then
    return
  end

  local actions_ok, actions = pcall(require, 'fzf-lua.actions')
  if not actions_ok then
    vim.notify('Tuck: fzf-lua not found, skipping integration', vim.log.levels.WARN)
    return
  end

  local utils_ok, utils = pcall(require, 'fzf-lua.utils')

  originals.file_edit = actions.file_edit
  originals.file_edit_or_qf = actions.file_edit_or_qf
  originals.file_split = actions.file_split
  originals.file_vsplit = actions.file_vsplit
  originals.file_tabedit = actions.file_tabedit
  originals.file_switch = actions.file_switch
  originals.file_switch_or_edit = actions.file_switch_or_edit

  actions.file_edit = with_unfold(originals.file_edit)
  actions.file_edit_or_qf = with_unfold(originals.file_edit_or_qf)
  actions.file_split = with_unfold(originals.file_split)
  actions.file_vsplit = with_unfold(originals.file_vsplit)
  actions.file_tabedit = with_unfold(originals.file_tabedit)
  actions.file_switch = with_unfold(originals.file_switch)
  actions.file_switch_or_edit = with_unfold(originals.file_switch_or_edit)

  if utils_ok and utils.jump_to_location then
    originals.jump_to_location = utils.jump_to_location
    utils.jump_to_location = with_unfold_jump(originals.jump_to_location)
  end

  patched = true
end

function M.restore()
  if not patched then
    return
  end

  local actions_ok, actions = pcall(require, 'fzf-lua.actions')
  local utils_ok, utils = pcall(require, 'fzf-lua.utils')

  if actions_ok then
    actions.file_edit = originals.file_edit
    actions.file_edit_or_qf = originals.file_edit_or_qf
    actions.file_split = originals.file_split
    actions.file_vsplit = originals.file_vsplit
    actions.file_tabedit = originals.file_tabedit
    actions.file_switch = originals.file_switch
    actions.file_switch_or_edit = originals.file_switch_or_edit
  end

  if utils_ok and originals.jump_to_location then
    utils.jump_to_location = originals.jump_to_location
  end

  patched = false
  originals = {}
end

function M.debug()
  print('=== Tuck fzf-lua Integration Debug ===')
  print('Patched: ' .. tostring(patched))

  local actions_ok, actions = pcall(require, 'fzf-lua.actions')
  if not actions_ok then
    print('fzf-lua.actions: NOT FOUND')
  else
    print('fzf-lua.actions: loaded')
  end

  local utils_ok, utils = pcall(require, 'fzf-lua.utils')
  if not utils_ok then
    print('fzf-lua.utils: NOT FOUND')
  else
    print('fzf-lua.utils: loaded')
  end

  print('')
  print('Checking if actions are wrapped:')
  local action_names = {
    'file_edit',
    'file_edit_or_qf',
    'file_split',
    'file_vsplit',
    'file_tabedit',
    'file_switch',
    'file_switch_or_edit',
  }

  for _, name in ipairs(action_names) do
    local is_wrapped = originals[name] ~= nil and actions_ok and actions[name] ~= originals[name]
    print(string.format('  %s: %s', name, is_wrapped and 'WRAPPED' or 'NOT WRAPPED'))
  end

  print('')
  print('Checking if utils.jump_to_location is wrapped:')
  local jump_wrapped = originals.jump_to_location ~= nil and utils_ok and utils.jump_to_location ~= originals.jump_to_location
  print(string.format('  jump_to_location: %s', jump_wrapped and 'WRAPPED' or 'NOT WRAPPED'))

  print('')
  print('=== End Debug ===')
end

return M
