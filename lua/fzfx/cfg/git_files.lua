local tbl = require("fzfx.commons.tbl")
local path = require("fzfx.commons.path")

local cmds = require("fzfx.lib.commands")
local log = require("fzfx.lib.log")
local LogLevels = require("fzfx.lib.log").LogLevels
local actions_helper = require("fzfx.helper.actions")
local labels_helper = require("fzfx.helper.previewer_labels")
local previewers_helper = require("fzfx.helper.previewers")
local ProviderTypeEnum = require("fzfx.schema").ProviderTypeEnum
local PreviewerTypeEnum = require("fzfx.schema").PreviewerTypeEnum
local CommandFeedEnum = require("fzfx.schema").CommandFeedEnum
local _decorator = require("fzfx.cfg._decorator")

local M = {}

M.command = {
  name = "FzfxGFiles",
  desc = "Find git files",
}

M.variants = {
  -- args
  {
    name = "args",
    feed = CommandFeedEnum.ARGS,
    default_provider = "workspace",
  },
  {
    name = "cwd_args",
    feed = CommandFeedEnum.ARGS,
    default_provider = "current_folder",
  },
  -- visual
  {
    name = "visual",
    feed = CommandFeedEnum.VISUAL,
    default_provider = "workspace",
  },
  {
    name = "cwd_visual",
    feed = CommandFeedEnum.VISUAL,
    default_provider = "current_folder",
  },
  -- cword
  {
    name = "cword",
    feed = CommandFeedEnum.CWORD,
    default_provider = "workspace",
  },
  {
    name = "cwd_cword",
    feed = CommandFeedEnum.CWORD,
    default_provider = "current_folder",
  },
  -- put
  {
    name = "put",
    feed = CommandFeedEnum.PUT,
    default_provider = "workspace",
  },
  {
    name = "cwd_put",
    feed = CommandFeedEnum.PUT,
    default_provider = "current_folder",
  },
  -- resume
  {
    name = "resume",
    feed = CommandFeedEnum.RESUME,
    default_provider = "workspace",
  },
  {
    name = "cwd_resume",
    feed = CommandFeedEnum.RESUME,
    default_provider = "current_folder",
  },
}

M._GIT_LS_WORKSPACE = { "git", "ls-files", ":/" }
M._GIT_LS_CWD = { "git", "ls-files" }

--- @param opts {current_folder:boolean?}?
--- @return fun(query:string,context:fzfx.GitFilesPipelineContext):string[]|nil
M._make_provider = function(opts)
  --- @param query string
  --- @param context fzfx.GitFilesPipelineContext
  --- @return string[]|nil
  local function impl(query, context)
    local git_root_cmd = context.git_root_cmd
    if git_root_cmd:failed() then
      log.echo(LogLevels.INFO, "not in git repo.")
      return nil
    end
    return tbl.tbl_get(opts, "current_folder") and vim.deepcopy(M._GIT_LS_CWD)
      or vim.deepcopy(M._GIT_LS_WORKSPACE)
  end
  return impl
end

local current_folder_provider = M._make_provider({ current_folder = true })
local workspace_provider = M._make_provider()

M.providers = {
  current_folder = {
    key = "ctrl-u",
    provider = current_folder_provider,
    provider_type = ProviderTypeEnum.COMMAND_ARRAY,
    provider_decorator = { module = _decorator.PREPEND_ICON_FIND },
  },
  workspace = {
    key = "ctrl-w",
    provider = workspace_provider,
    provider_type = ProviderTypeEnum.COMMAND_ARRAY,
    provider_decorator = { module = _decorator.PREPEND_ICON_FIND },
  },
}

M.previewers = {
  current_folder = {
    previewer = previewers_helper.preview_find,
    previewer_type = PreviewerTypeEnum.COMMAND_ARRAY,
    previewer_label = labels_helper.label_find,
  },
  workspace = {
    previewer = previewers_helper.preview_find,
    previewer_type = PreviewerTypeEnum.COMMAND_ARRAY,
    previewer_label = labels_helper.label_find,
  },
}

M.actions = {
  ["esc"] = actions_helper.nop,
  ["enter"] = actions_helper.edit_find,
  ["double-click"] = actions_helper.edit_find,
  ["ctrl-q"] = actions_helper.setqflist_find,
}

M.fzf_opts = {
  "--multi",
  function()
    return { "--prompt", path.shorten() .. " > " }
  end,
}

--- @alias fzfx.GitFilesPipelineContext {bufnr:integer,winnr:integer,tabnr:integer,git_root_cmd:fzfx.CommandResult}
--- @return fzfx.GitFilesPipelineContext
M._context_maker = function()
  local git_root_cmd = cmds.run_git_root_sync()
  local context = {
    bufnr = vim.api.nvim_get_current_buf(),
    winnr = vim.api.nvim_get_current_win(),
    tabnr = vim.api.nvim_get_current_tabpage(),
    git_root_cmd = git_root_cmd,
  }
  return context
end

M.other_opts = {
  context_maker = M._context_maker,
}

return M
