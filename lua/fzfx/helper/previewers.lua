-- Note:
-- The previewers works with fzf's builtin preview window, are named with prefix `fzf_`.
-- To enable them, set feature flag: `vim.g.fzfx_disable_buffer_previewer=1`.
--
-- The previewers works with Neovim's buffer, are named with prefix `buffer_`.
-- To enable them, unset feature flag: `vim.g.fzfx_disable_buffer_previewer`.

local str = require("fzfx.commons.str")
local path = require("fzfx.commons.path")
local tbl = require("fzfx.commons.tbl")

local consts = require("fzfx.lib.constants")
local shells = require("fzfx.lib.shells")
local log = require("fzfx.lib.log")

local parsers_helper = require("fzfx.helper.parsers")
local bat_themes_helper = require("fzfx.helper.bat_themes")

local M = {}

-- utils {

--- @return string
M._bat_style = function()
  local style = "numbers,changes"
  if str.not_empty(vim.env["BAT_STYLE"]) then
    style = vim.env["BAT_STYLE"]
  end
  return "--style=" .. style
end

--- @return string
M._bat_theme = function()
  local theme = "base16"
  if str.not_empty(vim.env["BAT_THEME"]) then
    theme = vim.env["BAT_THEME"]
    return "--theme=" .. theme
  end

  if consts.HAS_BAT and vim.opt.termguicolors then
    local colorname = vim.g.colors_name --[[@as string]]
    if str.not_empty(colorname) then
      local theme_config_file = bat_themes_helper.get_theme_config_filename(colorname) --[[@as string]]
      if str.not_empty(theme_config_file) and path.isfile(theme_config_file) then
        local theme_name = bat_themes_helper.get_theme_name(colorname) --[[@as string]]
        if str.not_empty(theme_name) then
          return "--theme=" .. theme_name
        end
      end
    end
  end

  return "--theme=" .. theme
end

-- The margin of fzf preview window
local FZF_PREVIEW_WINDOW_MARGIN = 6

-- Calculate fzf's preview window width.
--- @return integer
M._fzf_preview_window_width = function()
  local win_width = vim.api.nvim_win_get_width(0)
  return math.floor(math.max(3, win_width / 2 - FZF_PREVIEW_WINDOW_MARGIN))
end

-- Calculate fzf's preview window half height.
--- @return integer
M._fzf_preview_window_half_height = function()
  local win_height = vim.api.nvim_win_get_height(0)
  return math.floor(math.max(3, win_height / 2 - FZF_PREVIEW_WINDOW_MARGIN))
end

-- utils }

-- fd/find {

M._FZF_PREVIEW_BAT = {
  consts.BAT,
  "--color=always",
  "--pager=never",
}

M._FZF_PREVIEW_CAT = {
  consts.CAT,
  "-n",
}

--- @param filename string
--- @return string[]
M._fzf_preview_find = function(filename)
  if consts.HAS_BAT then
    -- "bat --style=%s --theme=%s --color=always --pager=never -- %s"
    local results = vim.deepcopy(M._FZF_PREVIEW_BAT)

    local style = M._bat_style()
    local theme = M._bat_theme()
    table.insert(results, style)
    table.insert(results, theme)
    table.insert(results, "--")
    table.insert(results, filename)
    return results
  else
    -- "cat -n -- %s"
    local results = vim.deepcopy(M._FZF_PREVIEW_CAT)
    table.insert(results, "--")
    table.insert(results, filename)
    return results
  end
end

-- It generates the cat/bat shell command in strings list, for previewing fd/find results.
--- @param line string
--- @return string[]
M.fzf_preview_find = function(line)
  local parsed = parsers_helper.parse_find(line)
  return M._fzf_preview_find(parsed.filename)
end

-- It generates buffer configurations for previewing fd/find results.
--- @param line string
--- @return {filename:string}
M.buffer_preview_find = function(line)
  local parsed = parsers_helper.parse_find(line)
  return { filename = parsed.filename }
end

-- fd/find }

-- rg/grep {

-- When working with rg/grep results,
-- this plugin mostly set `--preview-window=+{2}/2` and `--delimiter=':'` for fzf command.
--
-- It tells fzf:
--   1. Split the lines (on the left side of fzf) by colon ':'.
--   2. The 2nd part (indicate by `+{2}`) is the line number that previewer should focus.
--   3. The `/2` tells fzf to put the focused line in the 1/2 of the preview window.
--
-- Thus fzf's preview window will automatically scroll down to the focused line,
-- and put the focused line in the center of the preview window.
--
-- When working with rg/grep no filename results,
-- this plugin set `--preview-window=+{1}/2` and `--delimiter=':'` for fzf command.
-- It tells fzf the 1st part (indicate by `+{1}`) is the line number that previewer should focus.
--
--- @param filename string
--- @param lineno integer?
--- @return string[]
M._fzf_preview_grep = function(filename, lineno)
  if consts.HAS_BAT then
    -- "bat --style=%s --theme=%s --color=always --pager=never --highlight-line=%s -- %s"
    local results = vim.deepcopy(M._FZF_PREVIEW_BAT)

    local style = M._bat_style()
    local theme = M._bat_theme()
    if type(lineno) == "number" then
      table.insert(results, "--highlight-line=" .. lineno)
    end
    table.insert(results, style)
    table.insert(results, theme)
    table.insert(results, "--")
    table.insert(results, filename)
    return results
  else
    -- When bat doesn't exist, we use cat.
    -- But cat doesn't support highlight a specific line number.

    -- "cat -n -- %s"
    local results = vim.deepcopy(M._FZF_PREVIEW_CAT)
    table.insert(results, "--")
    table.insert(results, filename)
    return results
  end
end

-- It generates the cat/bat shell command in strings list, for previewing rg/grep results.
M.fzf_preview_grep = function(line)
  local parsed = parsers_helper.parse_grep(line)
  return M._fzf_preview_grep(parsed.filename, parsed.lineno)
end

-- It generates buffer configurations for previewing rg/grep results.
--- @param line string
--- @return {filename:string,lineno:integer?}
M.buffer_preview_grep = function(line)
  local parsed = parsers_helper.parse_grep(line)
  return { filename = parsed.filename, lineno = parsed.lineno }
end

-- rg/grep }

-- rg/grep no filename {

-- It generates the cat/bat shell command in strings list, for previewing rg/grep no filename results.
--- @param line string
--- @param context fzfx.PipelineContext
--- @return string[]|nil
M.fzf_preview_grep_no_filename = function(line, context)
  local bufnr = tbl.tbl_get(context, "bufnr")
  if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  filename = path.normalize(filename, { double_backslash = true, expand = true })

  local parsed = parsers_helper.parse_grep_no_filename(line)
  return M._fzf_preview_grep(filename, parsed.lineno)
end

-- It generates buffer configurations for previewing rg/grep no filename results.
--- @param line string
--- @param context fzfx.PipelineContext
--- @return {filename:string,lineno:integer?}?
M.buffer_preview_grep_no_filename = function(line, context)
  local bufnr = tbl.tbl_get(context, "bufnr")
  if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  filename = path.normalize(filename, { double_backslash = true, expand = true })

  local parsed = parsers_helper.parse_grep_no_filename(line)
  return { filename = filename, lineno = parsed.lineno }
end

-- rg/grep no filename }

-- git commit {

-- It generates 'git show' (with 'delta') shell command for git log/blame results.
--- @param line string
--- @return string?
M.fzf_preview_git_commit = function(line)
  -- If the first character is whitespace, return `nil` shell command.
  if str.isspace(line:sub(1, 1)) then
    return nil
  end

  local first_space_pos = str.find(line, " ")
  local commit_id = line:sub(1, first_space_pos - 1) --[[@as string]]
  if consts.HAS_DELTA then
    return string.format("git show %s | delta -n --tabs 4 --width $FZF_PREVIEW_COLUMNS", commit_id)
  else
    return string.format("git show --color=always %s", commit_id)
  end
end

-- git commit }

-- git status {

-- It generates 'git diff' (with 'delta') shell command for git status results.
--- @param line string
--- @return string
M.fzf_preview_git_status = function(line)
  local parsed = parsers_helper.parse_git_status(line)
  if consts.HAS_DELTA then
    return string.format(
      "git diff %s | delta -n --tabs 4 --width $FZF_PREVIEW_COLUMNS",
      shells.shellescape(parsed.filename)
    )
  else
    return string.format("git diff --color=always %s", shells.shellescape(parsed.filename))
  end
end

-- git status }

-- vim command/keymap/mark {

-- For self-rendering lines, i.e. commands/keymaps/marks, since we're rendering them as a table aligned with whitespaces.
-- Unlike rg/grep, we don't have the colon ':' to separate filenames and line numbers (see `fzf_preview_grep`).
--
-- When working on fzf's builtin preview window, with bat/cat,
-- we cannot use options `--preview-window=+{2}-/2` and `--delimiter=':'` to tell fzf what is the line number.
-- So we have to use bat option `--line-range` to truncate other parts of preview contents,
-- leave only interested text contents around the target line number.
-- But this also introduce another limitation: it cannot scroll up in preview window.
--
-- When working on Neovim's buffer, this is no longer an issue, the internal buffer previewer engine will handle it.
--
--- @param filename string
--- @param lineno integer
--- @return string[]
M._fzf_preview_grep_with_line_range = function(filename, lineno)
  if consts.HAS_BAT then
    -- "%s --style=%s --theme=%s --color=always --pager=never --highlight-line=%s -- %s"
    local results = vim.deepcopy(M._FZF_PREVIEW_BAT)

    local style = M._bat_style()
    local theme = M._bat_theme()
    table.insert(results, style)
    table.insert(results, theme)
    table.insert(results, "--highlight-line=" .. lineno)

    local win_height = vim.api.nvim_win_get_height(0)
    local half_height = math.floor(math.max(3, win_height / 2 - FZF_PREVIEW_WINDOW_MARGIN))
    local start_lineno = math.max(lineno - half_height, 1)

    table.insert(results, "--line-range")
    table.insert(results, string.format("%d:", start_lineno))
    table.insert(results, "--")
    table.insert(results, filename)
    return results
  else
    -- "cat -n -- %s"
    return {
      "cat",
      "-n",
      "--",
      filename,
    }
  end
end

-- vim command/keymap/mark }

return M
