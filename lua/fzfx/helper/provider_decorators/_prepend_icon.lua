local strings = require("fzfx.commons.strings")
local term_colors = require("fzfx.commons.colors.term")

local DEVICONS_OK = nil
local DEVICONS = nil
if strings.not_empty(vim.env._FZFX_NVIM_DEVICONS_PATH) then
  vim.opt.runtimepath:append(vim.env._FZFX_NVIM_DEVICONS_PATH)
  DEVICONS_OK, DEVICONS = pcall(require, "nvim-web-devicons")
end

local M = {}

--- @param line string
--- @param delimiter string?
--- @param index integer?
--- @return string
M._decorate = function(line, delimiter, index)
  if not DEVICONS_OK or DEVICONS == nil then
    return line
  end

  local filename = nil
  if strings.not_empty(delimiter) and type(index) == "number" then
    local splits = strings.split(line, delimiter --[[@as string]])
    filename = splits[index]
  else
    filename = line
  end
  -- remove ansi color codes
  -- see: https://stackoverflow.com/a/55324681/4438921
  if strings.not_empty(filename) then
    filename = term_colors.erase(filename)
  end
  local ext = vim.fn.fnamemodify(filename, ":e")
  local icon_text, icon_color = DEVICONS.get_icon_color(filename, ext)
  -- log_debug(
  --     "|fzfx.shell_helpers - render_line_with_icon| ext:%s, icon:%s, icon_color:%s",
  --     vim.inspect(ext),
  --     vim.inspect(icon),
  --     vim.inspect(icon_color)
  -- )
  if strings.not_empty(icon_text) then
    local rendered_text = term_colors.render(icon_text, icon_color)
    return rendered_text .. " " .. line
  else
    if vim.fn.isdirectory(filename) > 0 then
      return string.format("%s %s", vim.env._FZFX_NVIM_FILE_FOLDER_ICON, line)
    else
      return string.format("%s %s", vim.env._FZFX_NVIM_UNKNOWN_FILE_ICON, line)
    end
  end
end

return M
