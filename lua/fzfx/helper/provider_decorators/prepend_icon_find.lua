local _prepend_icon = require("fzfx.helper.provider_decorators._prepend_icon")

local M = {}

--- @param line string
--- @return string
M.decorate = function(line)
  return _prepend_icon._decorate(line)
end

return M
