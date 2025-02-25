local tbl = require("fzfx.commons.tbl")
local str = require("fzfx.commons.str")
local async = require("fzfx.commons.async")

local shells = require("fzfx.lib.shells")
local cmds = require("fzfx.lib.commands")
local log = require("fzfx.lib.log")
local LogLevels = require("fzfx.lib.log").LogLevels

local actions_helper = require("fzfx.helper.actions")

local ProviderTypeEnum = require("fzfx.schema").ProviderTypeEnum
local PreviewerTypeEnum = require("fzfx.schema").PreviewerTypeEnum
local CommandFeedEnum = require("fzfx.schema").CommandFeedEnum

local _git = require("fzfx.cfg._git")

local M = {}

M.command = {
  name = "FzfxGBranches",
  desc = "Search git branches",
}

M.variants = {
  -- args
  {
    name = "args",
    feed = CommandFeedEnum.ARGS,
    default_provider = "local_branch",
  },
  {
    name = "remote_args",
    feed = CommandFeedEnum.ARGS,
    default_provider = "remote_branch",
  },
  -- visual
  {
    name = "visual",
    feed = CommandFeedEnum.VISUAL,
    default_provider = "local_branch",
  },
  {
    name = "remote_visual",
    feed = CommandFeedEnum.VISUAL,
    default_provider = "remote_branch",
  },
  -- cword
  {
    name = "cword",
    feed = CommandFeedEnum.CWORD,
    default_provider = "local_branch",
  },
  {
    name = "remote_cword",
    feed = CommandFeedEnum.CWORD,
    default_provider = "remote_branch",
  },
  -- put
  {
    name = "put",
    feed = CommandFeedEnum.PUT,
    default_provider = "local_branch",
  },
  {
    name = "remote_put",
    feed = CommandFeedEnum.PUT,
    default_provider = "remote_branch",
  },
  -- resume
  {
    name = "resume",
    feed = CommandFeedEnum.RESUME,
    default_provider = "local_branch",
  },
  {
    name = "remote_resume",
    feed = CommandFeedEnum.RESUME,
    default_provider = "remote_branch",
  },
}

--- @param opts {remote_branch:boolean?}?
--- @return fun(query:string,context:fzfx.GitBranchesPipelineContext,on_complete:fzfx.AsyncDirectProviderOnComplete):nil
M._make_async_provider = function(opts)
  local remote_branch = tbl.tbl_get(opts, "remote_branch") or false

  --- @param query string
  --- @param context fzfx.GitBranchesPipelineContext
  --- @param on_complete fzfx.AsyncDirectProviderOnComplete
  local function impl(query, context, on_complete)
    async.void(function()
      local git_root_cmd = context.git_root_cmd
      if git_root_cmd:failed() then
        log.echo(LogLevels.INFO, "not in git repo.")
        on_complete(nil)
        return
      end

      local git_current_branch_cmd = cmds.run_git_current_branch_async()
      if git_current_branch_cmd:failed() then
        log.echo(LogLevels.INFO, table.concat(git_current_branch_cmd.stderr, " "))
        on_complete(nil)
        return
      end

      local results = {}
      table.insert(results, string.format("* %s", git_current_branch_cmd.stdout[1]))

      local git_branches_cmd = cmds.run_git_branches_async(remote_branch)
      if git_branches_cmd:failed() then
        log.echo(LogLevels.INFO, table.concat(git_branches_cmd.stderr, " "))
        on_complete(nil)
        return
      end

      for _, line in ipairs(git_branches_cmd.stdout) do
        if vim.trim(line):sub(1, 1) ~= "*" then
          table.insert(results, string.format("  %s", vim.trim(line)))
        end
      end

      on_complete(results)
    end)()
  end

  return impl
end

local local_branch_async_provider = M._make_async_provider()
local remote_branch_async_provider = M._make_async_provider({ remote_branch = true })

M.providers = {
  local_branch = {
    key = "ctrl-o",
    provider = local_branch_async_provider,
    provider_type = ProviderTypeEnum.ASYNC_DIRECT,
  },
  remote_branch = {
    key = "ctrl-r",
    provider = remote_branch_async_provider,
    provider_type = ProviderTypeEnum.ASYNC_DIRECT,
  },
}

--- @param line string
--- @param context fzfx.PipelineContext
--- @return string
M._previewer = function(line, context)
  local branch = str.split(line, " ")[1]
  return string.format(
    "git log --pretty=%s --graph --date=short --color=always %s",
    shells.escape(_git.GIT_LOG_PRETTY_FORMAT),
    branch
  )
end

M.previewers = {
  local_branch = {
    previewer = M._previewer,
    previewer_type = PreviewerTypeEnum.COMMAND_STRING,
  },
  remote_branch = {
    previewer = M._previewer,
    previewer_type = PreviewerTypeEnum.COMMAND_STRING,
  },
}

M.actions = {
  ["esc"] = actions_helper.nop,
  ["enter"] = actions_helper.git_checkout,
  ["double-click"] = actions_helper.git_checkout,
}

M.fzf_opts = {
  "--no-multi",
  { "--prompt", "Git Branches > " },
  function()
    local git_root_cmd = cmds.run_git_root_sync()
    if git_root_cmd:failed() then
      return nil
    end
    local git_current_branch_cmd = cmds.run_git_current_branch_sync()
    if git_current_branch_cmd:failed() then
      return nil
    end
    if
      tbl.list_not_empty(git_current_branch_cmd.stdout)
      and str.not_empty(git_current_branch_cmd.stdout[1])
    then
      return "--header-lines=1"
    else
      return nil
    end
  end,
}

-- This is actually for the "git checkout" actions.
--- @alias fzfx.GitBranchesPipelineContext {git_root_cmd:fzfx.CommandResult,remotes:string[]|nil}
--- @return fzfx.GitBranchesPipelineContext
M._context_maker = function()
  local ctx = {}

  local git_root_cmd = cmds.run_git_root_sync()
  ctx.git_root_cmd = git_root_cmd
  local git_remotes_cmd = cmds.run_git_remotes_sync()
  if git_remotes_cmd:failed() or tbl.list_empty(git_remotes_cmd.stdout) then
    return ctx
  end
  ctx.remotes = git_remotes_cmd.stdout
  return ctx
end

M.other_opts = {
  context_maker = M._context_maker,
}

return M
