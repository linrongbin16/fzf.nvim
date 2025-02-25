local tbl = require("fzfx.commons.tbl")

local cmds = require("fzfx.lib.commands")
local log = require("fzfx.lib.log")
local LogLevels = require("fzfx.lib.log").LogLevels

local actions_helper = require("fzfx.helper.actions")
local previewers_helper = require("fzfx.helper.previewers")

local ProviderTypeEnum = require("fzfx.schema").ProviderTypeEnum
local PreviewerTypeEnum = require("fzfx.schema").PreviewerTypeEnum
local CommandFeedEnum = require("fzfx.schema").CommandFeedEnum

local M = {}

M.command = {
  name = "FzfxGStatus",
  desc = "Find changed git files (git status)",
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

M._GIT_STATUS_CURRENT_DIR = {
  "git",
  "-c",
  "color.status=always",
  "status",
  "--short",
  ".",
}

M._GIT_STATUS_WORKSPACE = {
  "git",
  "-c",
  "color.status=always",
  "status",
  "--short",
}

--- @param opts {current_folder:boolean?}?
--- @return fun(query:string, context:fzfx.GitStatusPipelineContext):string[]|nil
M._make_provider = function(opts)
  local current_folder_mode = tbl.tbl_get(opts, "current_folder") or false

  --- @param query string
  --- @param context fzfx.GitStatusPipelineContext
  --- @return string[]|nil
  local function impl(query, context)
    local git_root_cmd = context.git_root_cmd
    if git_root_cmd:failed() then
      log.echo(LogLevels.INFO, "not in git repo.")
      return nil
    end
    if current_folder_mode then
      return vim.deepcopy(M._GIT_STATUS_CURRENT_DIR)
    else
      return vim.deepcopy(M._GIT_STATUS_WORKSPACE)
    end
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
  },
  workspace = {
    key = "ctrl-w",
    provider = workspace_provider,
    provider_type = ProviderTypeEnum.COMMAND_ARRAY,
  },
}

M.previewers = {
  current_folder = {
    previewer = previewers_helper.preview_git_status,
    previewer_type = PreviewerTypeEnum.COMMAND_STRING,
  },
  workspace = {
    previewer = previewers_helper.preview_git_status,
    previewer_type = PreviewerTypeEnum.COMMAND_STRING,
  },
}

M.actions = {
  ["esc"] = actions_helper.nop,
  ["enter"] = actions_helper.edit_git_status,
  ["double-click"] = actions_helper.edit_git_status,
  ["ctrl-q"] = actions_helper.setqflist_git_status,
}

M.fzf_opts = {
  "--multi",
  { "--preview-window", "wrap" },
  { "--prompt", "Git Status > " },
}

--- @alias fzfx.GitStatusPipelineContext {bufnr:integer,winnr:integer,tabnr:integer,git_root_cmd:fzfx.CommandResult}
--- @return fzfx.GitStatusPipelineContext
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
