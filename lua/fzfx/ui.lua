local strs = require("fzfx.lib.strings")
local nvims = require("fzfx.lib.nvims")

local log = require("fzfx.log")
local LogLevels = require("fzfx.log").LogLevels

local user_cancelled_error = "cancelled."

--- @param bufnr integer
--- @param callback fun():any
local function confirm_discard_buffer_modified(bufnr, callback)
  if not vim.o.hidden and nvims.get_buf_option(bufnr, "modified") then
    local ok, input = pcall(vim.fn.input, {
      prompt = "[fzfx] current buffer has been modified, continue? (y/n) ",
      cancelreturn = "n",
    })
    if
      ok
      and type(input) == "string"
      and string.len(input) > 0
      and strs.startswith(input:lower(), "y")
    then
      callback()
    else
      log.echo(LogLevels.INFO, user_cancelled_error)
    end
  else
    callback()
  end
end

local M = {
  confirm_discard_buffer_modified = confirm_discard_buffer_modified,
}

return M
