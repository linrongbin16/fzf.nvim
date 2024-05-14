local consts = require("fzfx.lib.constants")
local tbl = require("fzfx.commons.tbl")

local M = {}

M._find = function()
  if consts.HAS_FD then
    vim.health.ok(string.format("'%s' found", consts.FD))
  elseif consts.HAS_FIND then
    vim.health.ok(string.format("'%s' found", consts.FIND))
  else
    vim.health.error("'fd'/'find'/'gfind' not found")
  end
end

M._cat = function()
  if consts.HAS_BAT then
    vim.health.ok(string.format("'%s' found", consts.BAT))
  elseif consts.HAS_CAT then
    vim.health.ok(string.format("'%s' found", consts.CAT))
  else
    vim.health.error("'bat'/'batcat'/'cat' not found")
  end
end

M.check = function()
  vim.health.start("fzfx")

  M._find()
end

return M
