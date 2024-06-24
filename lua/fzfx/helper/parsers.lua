local tbl = require("fzfx.commons.tbl")
local str = require("fzfx.commons.str")
local num = require("fzfx.commons.num")
local fileio = require("fzfx.commons.fileio")
local path = require("fzfx.commons.path")

local consts = require("fzfx.lib.constants")
local env = require("fzfx.lib.env")
local log = require("fzfx.lib.log")

local M = {}

-- Parse `fd`/`find`, it looks like:
--
-- ```
-- 󰢱 bin/general/provider.lua
-- 󰢱 bin/general/previewer.lua
-- ```
--
-- It removes the (optional) prepend file type icon, returns expanded full path file name, which looks like:
--
-- ```
-- /Users/linrongbin/github/linrongbin16/fzfx.nvim/bin/general/provider.lua
-- /Users/linrongbin/github/linrongbin16/fzfx.nvim/bin/general/previewer.lua
-- ```
--
--- @param line string
--- @return {filename:string}
M.parse_find = function(line)
  local filename

  if str.empty(line) then
    return { filename = nil }
  end

  if env.icon_enabled() then
    local first_space_pos = str.find(line, " ")
    assert(
      type(first_space_pos) == "number",
      string.format("failed to parse fd/find:%s", vim.inspect(line))
    )
    -- The real file name starts after the first space.
    filename = line:sub(first_space_pos + 1)
  else
    filename = line
  end

  return {
    filename = path.normalize(filename, { double_backslash = true, expand = true }),
  }
end

-- Parse `grep`, it looks like:
--
-- ```
-- 󰢱 bin/general/provider.lua:31:local conf = require("fzfx.config")
-- 󰢱 bin/general/previewer.lua:57:local str = require("fzfx.commons.str")
-- ```
--
-- It removes the (optional) prepend file type icon, returns expanded full path file name, (optional) line number and raw text contents.
--
--- @param line string
--- @return {filename:string,lineno:integer?,text:string}
M.parse_grep = function(line)
  local filename
  local lineno
  local text

  local first_colon_pos = str.find(line, ":")
  assert(
    type(first_colon_pos) == "number",
    string.format("failed to parse grep:%s", vim.inspect(line))
  )
  filename = line:sub(1, first_colon_pos - 1)

  local second_colon_pos = str.find(line, ":", first_colon_pos + 1)
  if type(second_colon_pos) == "number" and second_colon_pos > 0 then
    lineno = line:sub(first_colon_pos + 1, second_colon_pos - 1)
    text = line:sub(second_colon_pos + 1)
  else
    -- If failed to found the second colon ':', then try to parse the right hands as 'lineno', if failed again, treat them as 'text'.
    local rhs = line:sub(first_colon_pos + 1)
    if tonumber(rhs) == nil then
      text = rhs
    else
      lineno = tonumber(rhs)
    end
  end

  filename = M.parse_find(filename).filename
  lineno = tonumber(lineno)
  text = text or ""

  return { filename = filename, lineno = lineno, text = text }
end

-- Parse `grep` without filename (`-I`), it looks like:
--
-- ```
-- 31:local conf = require("fzfx.config")
-- 57:local str = require("fzfx.commons.str")
-- ```
--
-- It returns line number and raw text contents.
--
--- @param line string
--- @return {lineno:integer?,text:string}
M.parse_grep_no_filename = function(line)
  local lineno = nil
  local text = nil

  local first_colon_pos = str.find(line, ":")
  if type(first_colon_pos) == "number" and first_colon_pos > 0 then
    lineno = line:sub(1, first_colon_pos - 1)
    text = line:sub(first_colon_pos + 1)
  else
    -- If failed to found the first colon ':', then try to parse right hands as 'lineno', if failed again, treat them as 'text'.
    local rhs = line
    if tonumber(rhs) == nil then
      text = rhs
    else
      lineno = tonumber(rhs)
    end
  end

  lineno = tonumber(lineno)
  text = text or ""

  return { lineno = lineno, text = text }
end

-- Parse `rg`, which looks like:
--
-- ```
-- 󰢱 bin/general/provider.lua:31:2:local conf = require("fzfx.config")
-- 󰢱 bin/general/previewer.lua:57:13:local str = require("fzfx.commons.str")
-- ```
--
-- It removes the (optional) prepend file type icon, returns expanded full path file name, line number, (optional) column number and text.
--
--- @param line string
--- @return {filename:string,lineno:integer,column:integer?,text:string}
M.parse_rg = function(line)
  local filename
  local lineno
  local column
  local text

  local first_colon_pos = str.find(line, ":")
  assert(
    type(first_colon_pos) == "number",
    string.format("failed to parse rg:%s", vim.inspect(line))
  )
  filename = line:sub(1, first_colon_pos - 1)

  local second_colon_pos = str.find(line, ":", first_colon_pos + 1)
  assert(
    type(second_colon_pos) == "number",
    string.format("failed to parse rg:%s", vim.inspect(line))
  )
  lineno = line:sub(first_colon_pos + 1, second_colon_pos - 1)

  local third_colon_pos = str.find(line, ":", second_colon_pos + 1)
  if type(third_colon_pos) == "number" and third_colon_pos > 0 then
    column = line:sub(second_colon_pos + 1, third_colon_pos - 1)
    text = line:sub(third_colon_pos + 1)
  else
    -- If failed to found the third ':', then try to parse right hands as 'column', if failed again, treat them as 'text'.
    local rhs = line:sub(second_colon_pos + 1)
    if tonumber(rhs) == nil then
      text = rhs
    else
      column = tonumber(rhs)
    end
  end

  filename = M.parse_find(filename).filename
  lineno = tonumber(lineno)
  column = tonumber(column)
  text = text or ""

  return { filename = filename, lineno = lineno, column = column, text = text }
end

-- Parse `rg` with `-I` option, i.e. without filename. It looks like:
-- ```
-- 󰢱 31:2:local conf = require("fzfx.config")
-- 󰢱 57:13:local str = require("fzfx.commons.str")
-- ```
--
-- remove the prepend icon and returns **expanded** file path, line number, column number and text.
--
--- @param line string
--- @return {lineno:integer,column:integer?,text:string}
M.parse_rg_no_filename = function(line)
  local lineno = nil
  local column = nil
  local text = nil

  local first_colon_pos = str.find(line, ":")
  assert(
    type(first_colon_pos) == "number",
    string.format("failed to parse rg lines:%s", vim.inspect(line))
  )
  lineno = line:sub(1, first_colon_pos - 1)

  local second_colon_pos = str.find(line, ":", first_colon_pos + 1)
  if num.gt(second_colon_pos, 0) then
    column = line:sub(first_colon_pos + 1, second_colon_pos - 1)
    text = line:sub(second_colon_pos + 1)
  else
    -- If failed to found the second ':', then try to parse right hands as 'column', if failed again, treat them as 'text'.
    local rhs = line:sub(first_colon_pos + 1)
    if tonumber(rhs) == nil then
      text = rhs
    else
      column = tonumber(rhs)
    end
  end

  lineno = tonumber(lineno)
  column = tonumber(column)
  text = text or ""

  return { lineno = lineno, column = column, text = text }
end

-- Parse `git status --short`, which looks like:
--
-- ```
--  M lua/fzfx/helper/parsers.lua
-- ?? test.txt
-- ```
--
-- It removes the prepend status symbol, returns expanded full file name.
--
--- @param line string
--- @return {filename:string}
M.parse_git_status = function(line)
  line = str.trim(line)
  local first_space_pos = 1
  local n = #line
  while first_space_pos <= n and not str.isspace(line:sub(first_space_pos, first_space_pos)) do
    first_space_pos = first_space_pos + 1
  end
  return {
    filename = path.normalize(
      line:sub(first_space_pos),
      { double_backslash = true, expand = true }
    ),
  }
end

-- Parse `git branch` and `git branch --remotes`.
-- The local branches look like:
--
-- ```
-- * chore-lint
--   main
--   refactor12
-- ```
--
-- The remote branches look like:
--
-- ```
--   origin/HEAD -> origin/main
--   origin/main
--   origin/refactor12
--   origin/release-please--branches--main--components--fzfx.nvim
-- ```
--
-- Note: the component before '->' symbol is the remote branch name, the component afterr '->' symbol is the local branch name.
--
-- It removes the prepend symbols, returns local branch name and (optional) remote branch name.
--
--- @param line string
--- @param context fzfx.GitBranchesPipelineContext
--- @return {local_branch:string,remote_branch:string}
M.parse_git_branch = function(line, context)
  -- Removes prefix `t` from string `s`.
  -- Returns `true` and the trimmed value if success.
  -- Returns `false` and the original value if failed.
  --- @param s string
  --- @param t string
  --- @return boolean, string
  local function _remove_prefix(s, t)
    if str.startswith(s, t) then
      return true, vim.trim(s:sub(#t + 1))
    else
      return false, s
    end
  end

  -- Remove "* " (the current branch symbol).
  -- Returns trimmed value (if success) or original value (if failed).
  --
  --- @param s string
  --- @return string
  local function _remove_star(s)
    local ok, result = _remove_prefix(s, "* ")
    if ok then
      return result
    else
      return s
    end
  end

  -- Removes remote prefix "remotes/origin/". Note: usually the remotes is 'origin' or 'upstream', but it's just a convention.
  --
  -- The `git branch --remotes` looks like:
  --
  -- ```
  --   remotes/origin/HEAD -> origin/main
  --   remotes/origin/main
  --   remotes/origin/my-plugin-dev
  -- ```
  --
  --- @param s string
  --- @return string
  local function _remove_remotes_origin_prefix(s)
    if tbl.list_not_empty(context.remotes) then
      for _, r in ipairs(context.remotes) do
        local ok, result = _remove_prefix(s, string.format("remotes/%s/", r))
        if ok then
          return result
        end
      end
    end
    return s
  end

  -- Removes prefix "origin/". Note: usually the remote is 'origin' or 'usptream', but it's just a convention.
  --
  -- The `git branch -r` looks like:
  --
  -- ```
  -- origin/HEAD -> origin/main
  -- origin/main
  -- origin/my-plugin-dev
  -- ```
  --
  --- @param s string
  --- @return string
  local function _remove_origin_prefix(s)
    if tbl.list_not_empty(context.remotes) then
      for _, r in ipairs(context.remotes) do
        local ok, result = _remove_prefix(s, string.format("%s/", r))
        if ok then
          return result
        end
      end
    end
    return s
  end

  -- Removes remotes prefix "remotes/".
  --
  --- @param s string
  --- @return string
  local function _remove_remotes_prefix(s)
    for _, r in ipairs(context.remotes) do
      local ok, result = _remove_prefix(s, "remotes/")
      if ok then
        return result
      end
    end
    return s
  end

  -- Remove prefix before "->" (include "->" itself).
  --
  --- @param s string
  --- @return string
  local function _remove_arrow(s)
    local arrow_pos = str.find(s, "->")
    if num.gt(arrow_pos, 0) then
      local truncated = s:sub(arrow_pos + 3)
      local result = str.trim(truncated)
      return result
    end
    return s
  end

  local local_branch = str.trim(line)
  local remote_branch = local_branch

  -- Remove "* "
  local_branch = _remove_star(local_branch)
  remote_branch = local_branch

  if str.find(local_branch, "->") ~= nil then
    -- Remove right arrow ("->") prefix
    local_branch = _remove_arrow(local_branch)
    remote_branch = local_branch
  end

  -- Remove prefix "remotes/origin/"
  local_branch = _remove_remotes_origin_prefix(local_branch)

  -- Remove prefix "origin/"
  local_branch = _remove_origin_prefix(local_branch)

  -- Remove prefix "remotes/"
  remote_branch = _remove_remotes_prefix(remote_branch)

  return { local_branch = local_branch, remote_branch = remote_branch }
end

-- Parse `git log --pretty=oneline`, which looks like:
--
-- ```
-- c2e32c 2023-11-30 linrongbin16 (HEAD -> chore-lint)
-- 5fe6ad 2023-11-29 linrongbin16 chore
-- ```
--
-- It removes suffix git logs, returns only the git commit ID at the beginning.
--
--- @param line string
--- @return {commit:string}
M.parse_git_commit = function(line)
  local first_space_pos = str.find(line, " ")
  assert(
    num.gt(first_space_pos, 0),
    string.format("failed to parse git commit:%s", vim.inspect(line))
  )
  local truncated = line:sub(1, first_space_pos - 1)
  local trimmed = str.trim(truncated)
  return { commit = trimmed }
end

-- Parse "ls"/"lsd"/"eza"/"exa" with "-lh"/"-lha" option.
--
-- The `ls -lh` looks like (file name starts from the 8th space):
--
-- (windows)
-- ```
-- total 31K
-- -rwxrwxrwx 1 somebody somegroup  150 Aug  3 21:29 .editorconfig
-- drwxrwxrwx 1 somebody somegroup    0 Oct  8 12:02 .github
-- -rwxrwxrwx 1 somebody somegroup  363 Aug 30 15:51 .gitignore
-- -rwxrwxrwx 1 somebody somegroup  124 Sep 18 23:56 .luacheckrc
-- -rwxrwxrwx 1 somebody somegroup   68 Sep 11 21:58 .luacov
-- ```
--
-- (macOS)
-- ```
-- total 184
-- -rw-r--r--   1 linrongbin  staff   1.0K Aug 28 12:39 LICENSE
-- -rw-r--r--   1 linrongbin  staff    27K Oct  8 11:37 README.md
-- drwxr-xr-x   3 linrongbin  staff    96B Aug 28 12:39 autoload
-- drwxr-xr-x   4 linrongbin  staff   128B Sep 22 10:11 bin
-- -rw-r--r--   1 linrongbin  staff   120B Sep  5 14:14 codecov.yml
-- ```
--
-- The `eza -lh` (`exa -lh`) looks like:
--
-- (windows, file name starts from the 5th space)
-- ```
-- Mode  Size Date Modified Name
-- d----    - 30 Sep 21:55  deps
-- -a---  585 22 Jul 14:26  init.vim
-- -a--- 6.4k 30 Sep 21:55  install.ps1
-- -a--- 5.3k 23 Sep 13:43  install.sh
-- ```
--
-- (macOS/linux, file name starts from the 6th space)
-- ```
-- Permissions Size User Date Modified Name
-- drwxr-xr-x     - linrongbin 28 Aug 12:39  autoload
-- drwxr-xr-x     - linrongbin 22 Sep 10:11  bin
-- .rw-r--r--   120 linrongbin  5 Sep 14:14  codecov.yml
-- .rw-r--r--  1.1k linrongbin 28 Aug 12:39  LICENSE
-- drwxr-xr-x     - linrongbin  8 Oct 09:14  lua
-- .rw-r--r--   28k linrongbin  8 Oct 11:37  README.md
-- drwxr-xr-x     - linrongbin  8 Oct 11:44  test
-- .rw-r--r--   28k linrongbin  8 Oct 12:10  test1-README.md
-- .rw-r--r--   28k linrongbin  8 Oct 12:10  test2-README.md
-- ```
--
-- The `lsd -lh --header --icon=never` looks like (file name starts from the 10th space):
--
-- ```
-- Permissions User Group  Size       Date Modified            Name
-- drwxr-xr-x  rlin staff 160 B  Wed Oct 25 16:59:44 2023 bin
-- .rw-r--r--  rlin staff  54 KB Tue Oct 31 22:29:35 2023 CHANGELOG.md
-- .rw-r--r--  rlin staff 120 B  Tue Oct 10 14:47:43 2023 codecov.yml
-- .rw-r--r--  rlin staff 1.0 KB Mon Aug 28 12:39:24 2023 LICENSE
-- drwxr-xr-x  rlin staff 128 B  Tue Oct 31 21:55:28 2023 lua
-- .rw-r--r--  rlin staff  38 KB Wed Nov  1 10:29:19 2023 README.md
-- drwxr-xr-x  rlin staff 992 B  Wed Nov  1 11:16:13 2023 test
-- ```
--
-- It removes the extra prefix info, returns only the expanded full file path.
--
--- @param start_pos integer
--- @param name string
--- @return fun(line:string,context:fzfx.FileExplorerPipelineContext):{filename:string}
M._make_parse_ls = function(start_pos, name)
  --- @param line string
  --- @param context fzfx.FileExplorerPipelineContext
  --- @return {filename:string}
  local function impl(line, context)
    local cwd = fileio.readfile(context.cwd, { trim = true })
    assert(
      str.not_empty(cwd),
      string.format("failed to parse file explorer context, cwd:%s", vim.inspect(cwd))
    )
    local pos = 1
    for i = 1, start_pos do
      pos = str.find(line, " ", pos) --[[@as integer]]
      assert(num.gt(pos, 0), string.format("failed to parse %s:%s", name, vim.inspect(line)))
      while pos + 1 <= #line and string.byte(line, pos + 1) == string.byte(" ") do
        pos = pos + 1
      end
      pos = pos + 1
    end

    -- Remove extra single/double quotes
    local truncated = line:sub(pos)
    local trimmed1 = vim.trim(truncated)
    local result = str.trim(trimmed1, "['\"]+")
    return {
      filename = path.normalize(path.join(cwd, result), { double_backslash = true, expand = true }),
    }
  end
  return impl
end

M.parse_ls = M._make_parse_ls(8, consts.LS)
if consts.IS_WINDOWS then
  M.parse_eza = M._make_parse_ls(5, consts.EZA)
else
  M.parse_eza = M._make_parse_ls(6, consts.EZA)
end
M.parse_lsd = M._make_parse_ls(10, consts.LSD)

-- Parse vim commands, it looks like:
--
-- ```
-- Name              Bang|Bar|Nargs|Range|Complete         Desc/Location
-- #                 N   |Y  |N/A  |N/A  |N/A              /opt/homebrew/Cellar/neovim/0.9.4/share/nvim/runtime/doc/index.txt:1121
-- !                 N   |Y  |N/A  |N/A  |N/A              /opt/homebrew/Cellar/neovim/0.9.4/share/nvim/runtime/doc/index.txt:1122
-- Next              N   |Y  |N/A  |N/A  |N/A              /opt/homebrew/Cellar/neovim/0.9.4/share/nvim/runtime/doc/index.txt:1124
-- bdelete           N   |Y  |N/A  |N/A  |N/A              "delete buffer"
-- ```
--
-- It removes extra suffix info, returns command name with either expanded full file path and line number, or the command definition.
--
--- @param line string
--- @param context fzfx.VimCommandsPipelineContext
--- @return {command:string,filename:string,lineno:integer?}|{command:string,definition:string}
M.parse_vim_command = function(line, context)
  local first_space_pos = str.find(line, " ")
  assert(
    num.gt(first_space_pos, 0),
    string.format("failed to parse vim command:%s", vim.inspect(line))
  )
  local command = str.trim(line:sub(1, first_space_pos - 1))
  local desc_or_loc =
    str.trim(line:sub(context.name_column_width + 1 + context.opts_column_width + 1 + 1))
  -- log.debug(
  --     "|fzfx.helper.parsers - parse_vim_commands| desc_or_loc:%s",
  --     vim.inspect(desc_or_loc)
  -- )
  if
    str.not_empty(desc_or_loc)
    and not str.startswith(desc_or_loc, '"')
    and not str.endswith(desc_or_loc, '"')
  then
    local last_colon_pos = str.rfind(desc_or_loc, ":")
    local splits = {
      desc_or_loc:sub(1, last_colon_pos - 1),
      desc_or_loc:sub(last_colon_pos + 1),
    }
    -- log.debug(
    --     "|fzfx.helper.parsers - parse_vim_commands| splits:%s",
    --     vim.inspect(splits)
    -- )
    local filename = path.normalize(splits[1], { double_backslash = true, expand = true })
    local lineno = tonumber(splits[2])
    -- log.debug(
    --     "|fzfx.helper.parsers - parse_vim_commands| filename:%s, lineno:%s",
    --     vim.inspect(filename),
    --     vim.inspect(lineno)
    -- )
    return { command = command, filename = filename, lineno = lineno }
  else
    local desc = str.trim(desc_or_loc, "['\"]+")
    return { command = command, definition = desc }
  end
end

-- Parse vim keymap, which looks like:
--
-- ```
-- Lhs                                          Mode|Noremap|Nowait|Silent Rhs/Location
-- <C-F>                                            |N      |N     |N      ~/.config/nvim/lazy/nvim-cmp/lua/cmp/utils/keymap.lua:127
-- <CR>                                             |N      |N     |N      ~/.config/nvim/lazy/nvim-cmp/lua/cmp/utils/keymap.lua:127
-- <Plug>(YankyGPutAfterShiftRight)             n   |Y      |N     |Y      ~/.config/nvim/lazy/yanky.nvim/lua/yanky.lua:369
-- %                                            n   |N      |N     |Y      "<Plug>(matchup-%)"
-- &                                            n   |Y      |N     |N      ":&&<CR>"
-- <2-LeftMouse>                                n   |N      |N     |Y      "<Plug>(matchup-double-click)"
-- ```
--
-- It removes extra mapping attributes, returns the left hands (Lhs) and either expanded full file name with line number, or the mapping definition.
--
--- @param line string
--- @param context fzfx.VimKeyMapsPipelineContext
--- @return {lhs:string,mode:string,filename:string,lineno:integer?}|{lhs:string,definition:string}
M.parse_vim_keymap = function(line, context)
  local first_space_pos = str.find(line, " ")
  assert(
    num.gt(first_space_pos, 0),
    string.format("failed to parse vim keymap:%s", vim.inspect(line))
  )
  local truncated1 = line:sub(1, first_space_pos - 1)
  local lhs = str.trim(truncated1)
  local first_bar_pos = str.find(line, "|", first_space_pos + 1)
  local truncated2 = line:sub(first_space_pos + 1, first_bar_pos - 1)
  local mode = str.trim(truncated2)
  local truncated3 = line:sub(context.key_column_width + 1 + context.opts_column_width + 1 + 1)
  local loc_or_desc = str.trim(truncated3)
  -- log.debug(
  --     "|fzfx.helper.parsers - parse_vim_commands| desc_or_loc:%s",
  --     vim.inspect(desc_or_loc)
  -- )
  if
    str.not_empty(loc_or_desc)
    and not str.startswith(loc_or_desc, '"')
    and not str.endswith(loc_or_desc, '"')
  then
    local last_colon_pos = str.rfind(loc_or_desc, ":")
    local truncated_filename = loc_or_desc:sub(1, last_colon_pos - 1)
    local truncated_lineno = loc_or_desc:sub(last_colon_pos + 1)
    local filename = path.normalize(truncated_filename, { double_backslash = true, expand = true })
    local lineno = tonumber(truncated_lineno)
    return { lhs = lhs, mode = mode, filename = filename, lineno = lineno }
  else
    local desc = str.trim(loc_or_desc, "['\"]+")
    return { lhs = lhs, mode = mode, definition = desc }
  end
end

-- Parse vim marks, which looks like:
--
-- ```
-- mark line  col file/text
--  '    543    7 return M
--  0     18    4 ~/.gitconfig
--  1      7   41 README.md
--  2      1    0 spec/contents/hello world.txt
--  3      2    0 lua/fzfx/detail/general.lua
--  4    315    0 lua/fzfx/config.lua
--  5   1225   43 lua/fzfx/detail/general.lua
--  6      2    0 lua/fzfx/detail/general.lua
--  7      2    1 lua/fzfx/detail/general.lua
--  8    569    9 /Users/rlin/github/linrongbin16/fzfx.nvim/lua/fzfx/detail/popup/buffer_popup_window.lua
--  9   1164   72 lua/fzfx/detail/general.lua
--  "      6    6 local constants = require("fzfx.lib.constants")
--  [      1    0 local tbl = require("fzfx.commons.tbl")
--  ]    543    0 return M
--  ^    134   14 -- the ':marks' output looks like:
--  .    134   13 -- the ':marks' output looks like:
-- ```
--
-- It returns mark/line/col and either expanded full file name, or marked text.
--
--- @param line string
--- @param context fzfx.VimMarksPipelineContext
--- @return {mark:string,lineno:integer?,col:integer?,filename:string?,text:string?}
M.parse_vim_mark = function(line, context)
  log.debug(
    string.format("|parse_vim_mark| line:%s, context:%s", vim.inspect(line), vim.inspect(context))
  )
  local mark_value = string.sub(line, context.mark_pos, context.lineno_pos - 1)
  local mark = str.trim(mark_value)

  local lineno_value = string.sub(line, context.lineno_pos, context.col_pos - 1)
  local trimmed_lineno_value = str.trim(lineno_value)
  local lineno = tonumber(trimmed_lineno_value) --[[@as integer]]

  local col_value = string.sub(line, context.col_pos, context.file_text_pos - 1)
  local trimmed_col_value = str.trim(col_value)
  local col = tonumber(trimmed_col_value)

  local file_text_value = string.sub(line, context.file_text_pos)
  local trimmed_file_text = str.trim(file_text_value) --[[@as string?]]
  local file_text
  if str.not_empty(trimmed_file_text) then
    local normalized_filename =
      path.normalize(trimmed_file_text --[[@as string]], { expand = true, double_backslash = true })
    if path.isfile(normalized_filename) then
      file_text = normalized_filename
    elseif type(context.bufnr) == "number" and vim.api.nvim_buf_is_valid(context.bufnr) then
      local bufname = vim.api.nvim_buf_get_name(context.bufnr)
      bufname = path.normalize(bufname, { double_backslash = true, expand = true })
      if path.isfile(bufname) then
        file_text = bufname
      end
    end
  end
  file_text = file_text or ""

  local isfile = path.isfile(file_text)
  if isfile then
    return { mark = mark, lineno = lineno, col = col, filename = file_text }
  else
    return { mark = mark, lineno = lineno, col = col, text = file_text }
  end
end

return M
