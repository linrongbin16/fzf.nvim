local strings = require("fzfx.commons.strings")
local paths = require("fzfx.commons.paths")

local constants = require("fzfx.lib.constants")
local log = require("fzfx.lib.log")
local LogLevels = require("fzfx.lib.log").LogLevels

local bat_themes_helper = require("fzfx.helper.bat_themes")
local colorschemes_helper = require("fzfx.helper.colorschemes")
local parsers_helper = require("fzfx.helper.parsers")
local queries_helper = require("fzfx.helper.queries")
local actions_helper = require("fzfx.helper.actions")
local labels_helper = require("fzfx.helper.previewer_labels")

local M = {}

-- files {

--- @return string, string
M._bat_style_theme = function()
  local style = "numbers,changes"
  if
    type(vim.env["BAT_STYLE"]) == "string"
    and string.len(vim.env["BAT_STYLE"]) > 0
  then
    style = vim.env["BAT_STYLE"]
  end
  local theme = "base16"
  if
    type(vim.env["BAT_THEME"]) == "string"
    and string.len(vim.env["BAT_THEME"]) > 0
  then
    theme = vim.env["BAT_THEME"]
    return style, theme
  end

  if constants.HAS_BAT and vim.opt.termguicolors then
    local color = colorschemes_helper.get_color_name() --[[@as string]]
    if strings.not_empty(color) then
      local theme_config_file = bat_themes_helper.get_theme_config_file(color)
      if paths.isfile(theme_config_file or "") then
        -- print(string.format("bat previewer color:%s", vim.inspect(color)))
        local custom_theme_name = bat_themes_helper.get_theme_name(color) --[[@as string]]
        -- log.debug(
        --   "|_bat_style_theme| theme_config_file:%s, custom_theme_name:%s",
        --   vim.inspect(theme_config_file),
        --   vim.inspect(custom_theme_name)
        -- )
        if strings.not_empty(custom_theme_name) then
          return style, custom_theme_name
        end
      end
    end
  end

  return style, theme
end

-- for rg/grep, the line number is the 2nd column split by colon ':'.
-- so we set fzf's option '--preview-window=+{2}-/2' + '--delimiter=:' (see live_grep).
-- the `+{2}-/2` indicates:
--   1. the 2nd column (split by colon ':') is the line number
--   2. set it as the highlight line
--   3. place it in the center (1/2) of the whole preview window
--
--- @param filename string
--- @param lineno integer?
--- @return string[]
M.preview_files = function(filename, lineno)
  if constants.HAS_BAT then
    local style, theme = M._bat_style_theme()
    -- "%s --style=%s --theme=%s --color=always --pager=never --highlight-line=%s -- %s"
    return type(lineno) == "number"
        and {
          constants.BAT,
          "--style=" .. style,
          "--theme=" .. theme,
          "--color=always",
          "--pager=never",
          "--highlight-line=" .. lineno,
          "--",
          filename,
        }
      or {
        constants.BAT,
        "--style=" .. style,
        "--theme=" .. theme,
        "--color=always",
        "--pager=never",
        "--",
        filename,
      }
  else
    -- "cat %s"
    return {
      "cat",
      filename,
    }
  end
end

--- @param line string
--- @return string[]
M.preview_files_find = function(line)
  local parsed = parsers_helper.parse_find(line)
  return M.preview_files(parsed.filename)
end

-- preview files with nvim buffer.
--- @param line string
--- @return table
M.buffer_preview_files_find = function(line)
  local parsed = parsers_helper.parse_find(line)
  return { filename = parsed.filename }
end

-- files }

-- live grep {

--- @param line string
--- @return string[]
M.preview_files_grep = function(line)
  local parsed = parsers_helper.parse_grep(line)
  return M.preview_files(parsed.filename, parsed.lineno)
end

-- live grep }

-- previewer window {

local PREVIEW_WINDOW_OFFSET = 6

--- @return integer
M.get_preview_window_width = function()
  local win_width = vim.api.nvim_win_get_width(0)
  return math.floor(math.max(3, win_width / 2 - PREVIEW_WINDOW_OFFSET))
end

--- @return integer
M.get_preview_window_center = function()
  local win_height = vim.api.nvim_win_get_height(0)
  return math.floor(math.max(3, win_height / 2 - PREVIEW_WINDOW_OFFSET))
end

-- previewer window }

-- git commits {

--- @param commit string
--- @return string?
M._make_preview_git_commit = function(commit)
  if constants.HAS_DELTA then
    local win_width = M.get_preview_window_width()
    return string.format(
      [[git show %s | delta -n --tabs 4 --width %d]],
      commit,
      win_width
    )
  else
    return string.format([[git show --color=always %s]], commit)
  end
end

M.preview_git_commit = function(line)
  if strings.isspace(line:sub(1, 1)) then
    return nil
  end
  local first_space_pos = strings.find(line, " ")
  local commit = line:sub(1, first_space_pos - 1)
  return M._make_preview_git_commit(commit)
end

-- git commits }

-- vim commands/keymaps {

-- for self-rendered lines (unlike rg/grep), we don't have the line number split by colon ':'.
-- thus we cannot set fzf's option '--preview-window=+{2}-/2' or '--delimiter=:' (see `preview_files`).
-- so we set `--line-range=40:` (in bat) to place the highlight line in the center of the preview window.
--
--- @param filename string
--- @param lineno integer
--- @return string[]
M.preview_files_with_line_range = function(filename, lineno)
  local height = vim.api.nvim_win_get_height(0)
  if constants.HAS_BAT then
    local style, theme = M._bat_style_theme()
    return {
      constants.BAT,
      "--style=" .. style,
      "--theme=" .. theme,
      "--color=always",
      "--pager=never",
      "--highlight-line=" .. lineno,
      "--line-range",
      string.format("%d:", math.max(lineno - M.get_preview_window_center(), 1)),
      "--",
      filename,
    }
  else
    -- "cat %s"
    return {
      "cat",
      filename,
    }
  end
end

-- vim commands/keymaps }

return M
