local consts = require("fzfx.lib.constants")
local paths = require("fzfx.lib.paths")
local env = require("fzfx.lib.env")
local strs = require("fzfx.lib.strings")
local nums = require("fzfx.lib.numbers")
local fs = require("fzfx.lib.filesystems")
local tbls = require("fzfx.lib.tables")

local M = {}

-- parse lines from fd/find, also support buffers, git files. looks like:
-- ```
-- 󰢱 bin/general/provider.lua
-- 󰢱 bin/general/previewer.lua
-- ```
--
-- remove the prepend icon and returns **expanded** file path. looks like:
-- ```
-- /Users/linrongbin/github/linrongbin16/fzfx.nvim/bin/general/provider.lua
-- /Users/linrongbin/github/linrongbin16/fzfx.nvim/bin/general/previewer.lua
-- ```
--
--- @param line string
--- @return {filename:string}
M.parse_find = function(line)
  local filename = nil
  if env.icon_enabled() then
    local first_icon_pos = strs.find(line, " ")
    assert(type(first_icon_pos) == "number")
    filename = line:sub(first_icon_pos + 1)
  else
    filename = line
  end
  return { filename = paths.normalize(filename, { expand = true }) }
end

-- parse lines from grep. looks like:
-- ```
-- 󰢱 bin/general/provider.lua:31:  local conf = require("fzfx.config")
-- 󰢱 bin/general/previewer.lua:57:  local colors = require("fzfx.commons.termcolors")
-- ```
--
-- remove the prepend icon and returns **expanded** file path, line number and text.
--
--- @param line string
--- @return {filename:string,lineno:integer?,text:string}
M.parse_grep = function(line)
  local filename = nil
  local lineno = nil
  local text = nil

  local first_colon_pos = strs.find(line, ":")
  assert(
    type(first_colon_pos) == "number",
    string.format("failed to parse grep lines:%s", vim.inspect(line))
  )
  filename = line:sub(1, first_colon_pos - 1)

  local second_colon_pos = strs.find(line, ":", first_colon_pos + 1)
  if nums.positive(second_colon_pos) then
    lineno = line:sub(first_colon_pos + 1, second_colon_pos - 1)
    text = line:sub(second_colon_pos + 1)
  else
    -- if failed to found the second ':', then
    -- 1. first try to parse right hands as 'lineno'
    -- 2. if failed, treat them as 'text'
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

-- parse lines from rg. looks like:
-- ```
-- 󰢱 bin/general/provider.lua:31:2:  local conf = require("fzfx.config")
-- 󰢱 bin/general/previewer.lua:57:13:  local colors = require("fzfx.commons.termcolors")
-- ```
--
-- remove the prepend icon and returns **expanded** file path, line number, column number and text.
--
--- @param line string
--- @return {filename:string,lineno:integer,column:integer?,text:string}
M.parse_rg = function(line)
  local filename = nil
  local lineno = nil
  local column = nil
  local text = nil

  local first_colon_pos = strs.find(line, ":")
  assert(
    type(first_colon_pos) == "number",
    string.format("failed to parse rg lines:%s", vim.inspect(line))
  )
  filename = line:sub(1, first_colon_pos - 1)

  local second_colon_pos = strs.find(line, ":", first_colon_pos + 1)
  assert(
    type(second_colon_pos) == "number",
    string.format("failed to parse rg lines:%s", vim.inspect(line))
  )
  lineno = line:sub(first_colon_pos + 1, second_colon_pos - 1)

  local third_colon_pos = strs.find(line, ":", second_colon_pos + 1)
  if nums.positive(third_colon_pos) then
    column = line:sub(second_colon_pos + 1, third_colon_pos - 1)
    text = line:sub(third_colon_pos + 1)
  else
    -- if failed to found the third ':', then
    -- 1. first try to parse right hands as 'column'
    -- 2. if failed, treat them as 'text'
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

-- parse lines from `git status --short`. looks like:
-- ```
--  M lua/fzfx/helper/parsers.lua
-- ?? test.txt
-- ```
--
-- remove the prepend symbol and returns **expanded** file path.
--
--- @param line string
--- @return {filename:string}
M.parse_git_status = function(line)
  line = vim.trim(line)
  local i = 1
  while i <= #line and not strs.isspace(line:sub(i, i)) do
    i = i + 1
  end
  return { filename = paths.normalize(line:sub(i), { expand = true }) }
end

-- parse lines from `git branch` and `git branch --remotes`. looks like:
-- ```
-- * chore-lint
-- main
-- origin/HEAD -> origin/main
-- origin/chore-lint
-- ```
--
-- remove the prefix and extra symbols, returns branch name.
--
--- @param line string
--- @param context fzfx.GitBranchesPipelineContext
--- @return {local_branch:string,remote_branch:string}
M.parse_git_branch = function(line, context)
  --- @param s string
  --- @param t string
  --- @return boolean, string
  local function _remove_prefix(s, t)
    if strs.startswith(s, t) then
      return true, vim.trim(s:sub(#t + 1))
    else
      return false, s
    end
  end

  -- remove prefix "* "
  --
  -- The `git branch` looks like:
  -- ```
  -- * my-plugin-dev
  -- ```
  --
  --- @param l string
  --- @return string
  local function _remove_star(l)
    local success, l1 = _remove_prefix(l, "* ")
    return success and l1 or l
  end

  -- remove prefix "remotes/origin/"
  --
  -- The `git branch -a` looks like:
  -- ```
  --   main
  -- * my-plugin-dev
  --   remotes/origin/HEAD -> origin/main
  --   remotes/origin/main
  --   remotes/origin/my-plugin-dev
  -- ```
  --
  --- @param l string
  --- @return string
  local function _remove_remotes_origin_slash(l)
    if tbls.list_not_empty(context.remotes) then
      for _, r in ipairs(context.remotes) do
        local success, l1 = _remove_prefix(l, string.format("remotes/%s/", r))
        if success then
          return l1
        end
      end
    end
    return l
  end

  -- remove prefix "origin/"
  --
  -- The `git branch -r` looks like:
  -- ```
  -- origin/HEAD -> origin/main
  -- origin/main
  -- origin/my-plugin-dev
  -- ```
  --
  --- @param l string
  --- @return string
  local function _remove_origin_slash(l)
    if tbls.list_not_empty(context.remotes) then
      for _, r in ipairs(context.remotes) do
        local success, l1 = _remove_prefix(l, string.format("%s/", r))
        if success then
          return l1
        end
      end
    end
    return l
  end

  -- remove prefix "->", looks like:
  --
  -- ```
  -- origin/HEAD -> origin/main
  -- ```
  --
  --- @param l string
  --- @return string
  local function _remove_right_arrow(l)
    local arrow_pos = strs.find(l, "->")
    if nums.positive(arrow_pos) then
      return vim.trim(l:sub(arrow_pos + 3))
    end
    return l
  end

  local local_branch = vim.trim(line)
  local remote_branch = local_branch

  -- remove prefix "* "
  local_branch = _remove_star(local_branch)
  remote_branch = local_branch

  if strs.find(local_branch, "->") ~= nil then
    -- remove right arrow ("->") prefix
    local_branch = _remove_right_arrow(local_branch)
    remote_branch = local_branch
  end

  -- remove prefix "remotes/origin/"
  local_branch = _remove_remotes_origin_slash(local_branch)

  -- remove prefix "origin/"
  local_branch = _remove_origin_slash(local_branch)

  return { local_branch = local_branch, remote_branch = remote_branch }
end

-- parse lines from `git log --pretty=oneline`. looks like:
-- ```
-- c2e32c 2023-11-30 linrongbin16 (HEAD -> chore-lint)
-- 5fe6ad 2023-11-29 linrongbin16 chore
-- ```
--
--- @param line string
--- @return {commit:string}
M.parse_git_commit = function(line)
  local first_space_pos = strs.find(line, " ")
  assert(
    nums.positive(first_space_pos),
    string.format("failed to parse git commit line:%s", vim.inspect(line))
  )
  return { commit = vim.trim(line:sub(1, first_space_pos - 1)) }
end

-- parse lines from ls/lsd/eza/exa.
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
-- remove the prepend extra info and returns **expanded** file path.
--
--- @package
--- @param start_pos integer
--- @return fun(line:string,context:fzfx.FileExplorerPipelineContext):{filename:string}
M._make_parse_ls = function(start_pos)
  --- @param line string
  --- @param context fzfx.FileExplorerPipelineContext
  --- @return {filename:string}
  local function impl(line, context)
    local cwd = fs.readfile(context.cwd)
    assert(
      strs.not_empty(cwd),
      string.format(
        "failed to parse file explorer context:%s",
        vim.inspect(cwd)
      )
    )
    local pos = 1
    for i = 1, start_pos do
      pos = strs.find(line, " ", pos) --[[@as integer]]
      assert(
        nums.positive(pos),
        string.format("failed to parse ls/eza/lsd lines:%s", vim.inspect(line))
      )
      while
        pos + 1 <= #line
        and string.byte(line, pos + 1) == string.byte(" ")
      do
        pos = pos + 1
      end
      pos = pos + 1
    end

    -- remove extra single/double quotes
    local result = strs.trim_quotes(vim.trim(line:sub(pos)))
    return {
      filename = paths.normalize(paths.join(cwd, result), { expand = true }),
    }
  end
  return impl
end

M.parse_ls = M._make_parse_ls(8)
M.parse_eza = consts.IS_WINDOWS and M._make_parse_ls(5) or M._make_parse_ls(6)
M.parse_lsd = M._make_parse_ls(10)

-- parse vim commands. looks like:
-- ```
-- Name              Bang|Bar|Nargs|Range|Complete         Desc/Location
-- #                 N   |Y  |N/A  |N/A  |N/A              /opt/homebrew/Cellar/neovim/0.9.4/share/nvim/runtime/doc/index.txt:1121
-- !                 N   |Y  |N/A  |N/A  |N/A              /opt/homebrew/Cellar/neovim/0.9.4/share/nvim/runtime/doc/index.txt:1122
-- Next              N   |Y  |N/A  |N/A  |N/A              /opt/homebrew/Cellar/neovim/0.9.4/share/nvim/runtime/doc/index.txt:1124
-- bdelete           N   |Y  |N/A  |N/A  |N/A              "delete buffer"
-- ```
--
-- removes extra command attributes and returns the command name with **expanded** file path and line number, or with command description.
--
--- @param line string
--- @param context fzfx.VimCommandsPipelineContext
--- @return {command:string,filename:string,lineno:integer?}|{command:string,definition:string}
M.parse_vim_command = function(line, context)
  local first_space_pos = strs.find(line, " ")
  assert(
    nums.positive(first_space_pos),
    string.format("failed to parse vim command lines:%s", vim.inspect(line))
  )
  local command = vim.trim(line:sub(1, first_space_pos - 1))
  local desc_or_loc =
    vim.trim(line:sub(context.name_width + 1 + context.opts_width + 1 + 1))
  -- log.debug(
  --     "|fzfx.helper.parsers - parse_vim_commands| desc_or_loc:%s",
  --     vim.inspect(desc_or_loc)
  -- )
  if
    string.len(desc_or_loc) > 0
    and not strs.startswith(desc_or_loc, '"')
    and not strs.endswith(desc_or_loc, '"')
  then
    local split_pos = strs.rfind(desc_or_loc, ":")
    local splits = {
      desc_or_loc:sub(1, split_pos - 1),
      desc_or_loc:sub(split_pos + 1),
    }
    -- log.debug(
    --     "|fzfx.helper.parsers - parse_vim_commands| splits:%s",
    --     vim.inspect(splits)
    -- )
    local filename = paths.normalize(splits[1], { expand = true })
    local lineno = tonumber(splits[2])
    -- log.debug(
    --     "|fzfx.helper.parsers - parse_vim_commands| filename:%s, lineno:%s",
    --     vim.inspect(filename),
    --     vim.inspect(lineno)
    -- )
    return { command = command, filename = filename, lineno = lineno }
  else
    return { command = command, definition = strs.trim_quotes(desc_or_loc) }
  end
end

-- parse vim keymap, looks like:
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
-- removes extra mapping attributes and returns the key left hands with **expanded** file path and line number, or with mapping description.
--
--- @param line string
--- @param context fzfx.VimKeyMapsPipelineContext
--- @return {lhs:string,mode:string,filename:string,lineno:integer?}|{lhs:string,definition:string}
M.parse_vim_keymap = function(line, context)
  local first_space_pos = strs.find(line, " ")
  assert(
    nums.positive(first_space_pos),
    string.format("failed to parse vim keymap lines:%s", vim.inspect(line))
  )
  local lhs = vim.trim(line:sub(1, first_space_pos - 1))
  local first_bar_pos = strs.find(line, "|", first_space_pos + 1)
  local mode = vim.trim(line:sub(first_space_pos + 1, first_bar_pos - 1))
  local rhs_or_loc =
    vim.trim(line:sub(context.key_width + 1 + context.opts_width + 1 + 1))
  -- log.debug(
  --     "|fzfx.helper.parsers - parse_vim_commands| desc_or_loc:%s",
  --     vim.inspect(desc_or_loc)
  -- )
  if
    string.len(rhs_or_loc) > 0
    and not strs.startswith(rhs_or_loc, '"')
    and not strs.endswith(rhs_or_loc, '"')
  then
    local split_pos = strs.rfind(rhs_or_loc, ":")
    local splits = {
      rhs_or_loc:sub(1, split_pos - 1),
      rhs_or_loc:sub(split_pos + 1),
    }
    -- log.debug(
    --     "|fzfx.helper.parsers - parse_vim_commands| splits:%s",
    --     vim.inspect(splits)
    -- )
    local filename = paths.normalize(splits[1], { expand = true })
    local lineno = tonumber(splits[2])
    -- log.debug(
    --     "|fzfx.helper.parsers - parse_vim_commands| filename:%s, lineno:%s",
    --     vim.inspect(filename),
    --     vim.inspect(lineno)
    -- )
    return { lhs = lhs, mode = mode, filename = filename, lineno = lineno }
  else
    return { lhs = lhs, mode = mode, definition = strs.trim_quotes(rhs_or_loc) }
  end
end

return M
