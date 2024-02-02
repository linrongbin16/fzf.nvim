local paths = require("fzfx.commons.paths")
local fileios = require("fzfx.commons.fileios")
local spawn = require("fzfx.commons.spawn")
local strings = require("fzfx.commons.strings")

local constants = require("fzfx.lib.constants")
local env = require("fzfx.lib.env")
local log = require("fzfx.lib.log")

local M = {}

--- @return string
M._theme_dir_cache = function()
  return paths.join(env.cache_dir(), "_last_bat_themes_dir_cache")
end

--- @type string?
local CACHED_THEME_DIR = nil

--- @return string?
M._cached_theme_dir = function()
  if CACHED_THEME_DIR == nil then
    CACHED_THEME_DIR = fileios.readfile(M._theme_dir_cache(), { trim = true })
  end
  return CACHED_THEME_DIR
end

--- @return string
M.get_theme_dir = function()
  local cached_result = M._cached_theme_dir() --[[@as string]]

  if strings.empty(cached_result) then
    log.ensure(
      constants.HAS_BAT,
      "|get_theme_dir| cannot find 'bat' executable"
    )

    local result = ""
    spawn
      .run({ constants.BAT, "--config-dir" }, {
        on_stdout = function(line)
          result = result .. line
        end,
        on_stderr = function() end,
      })
      :wait()
    local theme_dir = paths.join(result, "themes")
    if not paths.isdir(theme_dir) then
      spawn
        .run({ "mkdir", "-p", theme_dir }, {
          on_stdout = function() end,
          on_stderr = function() end,
        })
        :wait()
    end
    fileios.writefile(M._theme_dir_cache(), theme_dir)

    return result
  end

  return cached_result
end

-- Vim colorscheme name => bat theme name
--- @type table<string, string>
local THEME_NAMES_MAP = {}

--- @param names string[]
--- @return string[]
M._upper_first = function(names)
  assert(
    type(names) == "table" and #names > 0,
    string.format("|_upper_firsts| invalid names:%s", vim.inspect(names))
  )
  local new_names = {}
  for i, n in ipairs(names) do
    assert(
      type(n) == "string" and string.len(n) > 0,
      string.format(
        "|_upper_firsts| invalid name(%d):%s",
        vim.inspect(i),
        vim.inspect(n)
      )
    )
    local new_name = string.sub(n, 1, 1):upper()
      .. (string.len(n) > 1 and string.sub(n, 2) or "")
    table.insert(new_names, new_name)
  end
  return new_names
end

--- @param s string
--- @param delimiter string
--- @return string
M._normalize_by = function(s, delimiter)
  local splits = strings.find(s, delimiter)
      and strings.split(s, delimiter, { trimempty = true })
    or { s }
  splits = M._upper_first(splits)
  return table.concat(splits, "")
end

--- @param name string
--- @return string
M.get_theme_name = function(name)
  assert(type(name) == "string" and string.len(name) > 0)
  if THEME_NAMES_MAP[name] == nil then
    local result = name
    result = M._normalize_by(result, "-")
    result = M._normalize_by(result, "+")
    result = M._normalize_by(result, "_")
    result = M._normalize_by(result, ".")
    result = M._normalize_by(result, " ")
    THEME_NAMES_MAP[name] = "FzfxNvim" .. result
  end

  return THEME_NAMES_MAP[name]
end

--- @param colorname string
--- @return string
M.get_theme_config_file = function(colorname)
  local theme_dir = M.get_theme_dir()
  log.ensure(
    strings.not_empty(theme_dir),
    "|get_theme_config_file| failed to get bat config theme dir"
  )
  local theme_name = M.get_theme_name(colorname)
  log.ensure(
    strings.not_empty(theme_name),
    "|get_theme_config_file| failed to get bat theme name from nvim colorscheme name:%s",
    vim.inspect(colorname)
  )
  return paths.join(theme_dir, theme_name .. ".tmTheme")
end

return M
