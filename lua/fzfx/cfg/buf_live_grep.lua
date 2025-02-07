local str = require("fzfx.commons.str")
local path = require("fzfx.commons.path")

local constants = require("fzfx.lib.constants")
local bufs = require("fzfx.lib.bufs")
local log = require("fzfx.lib.log")
local LogLevels = require("fzfx.lib.log").LogLevels

local actions_helper = require("fzfx.helper.actions")
local labels_helper = require("fzfx.helper.previewer_labels")
local previewers_helper = require("fzfx.helper.previewers")

local ProviderTypeEnum = require("fzfx.schema").ProviderTypeEnum
local PreviewerTypeEnum = require("fzfx.schema").PreviewerTypeEnum
local CommandFeedEnum = require("fzfx.schema").CommandFeedEnum

local _grep = require("fzfx.cfg._grep")

local M = {}

M.command = {
  name = "FzfxBufLiveGrep",
  desc = "Live grep on current buffer",
}

M.variants = {
  -- args
  {
    name = "args",
    feed = CommandFeedEnum.ARGS,
  },
  -- visual
  {
    name = "visual",
    feed = CommandFeedEnum.VISUAL,
  },
  -- cword
  {
    name = "cword",
    feed = CommandFeedEnum.CWORD,
  },
  -- put
  {
    name = "put",
    feed = CommandFeedEnum.PUT,
  },
  -- resume
  {
    name = "resume",
    feed = CommandFeedEnum.RESUME,
  },
}

--- @param query string
--- @param context fzfx.PipelineContext
--- @return string[]|nil
M._provider_rg = function(query, context)
  local parsed = _grep.parse_query(query or "")
  local payload = parsed.payload
  local option = parsed.option

  local bufpath = _grep.buf_path(context.bufnr)
  if not bufpath then
    return nil
  end

  local args = vim.deepcopy(_grep.UNRESTRICTED_RG)
  args = _grep.append_options(args, option)

  table.insert(args, "-I")
  table.insert(args, payload)
  table.insert(args, bufpath)
  return args
end

--- @param query string
--- @param context fzfx.PipelineContext
--- @return string[]|nil
M._provider_grep = function(query, context)
  local parsed = _grep.parse_query(query or "")
  local payload = parsed.payload
  local option = parsed.option

  local bufpath = _grep.buf_path(context.bufnr)
  if not bufpath then
    return nil
  end

  local args = vim.deepcopy(_grep.UNRESTRICTED_GREP)
  args = _grep.append_options(args, option)

  table.insert(args, "-h")
  table.insert(args, payload)
  table.insert(args, bufpath)
  return args
end

--- @return fun(query:string,context:fzfx.PipelineContext):string[]|nil
M._make_provider = function()
  if constants.HAS_RG then
    return M._provider_rg
  elseif constants.HAS_GREP then
    return M._provider_grep
  else
    local function impl()
      log.echo(LogLevels.INFO, "no rg/grep command found.")
      return nil
    end
    return impl
  end
end

M.providers = {
  key = "default",
  provider = M._make_provider(),
  provider_type = ProviderTypeEnum.COMMAND_ARRAY,
}

M.previewers = {
  previewer = previewers_helper.preview_grep_bufnr,
  previewer_type = PreviewerTypeEnum.COMMAND_ARRAY,
  previewer_label = constants.HAS_RG and labels_helper.label_rg_bufnr
    or labels_helper.label_grep_bufnr,
}

local set_cursor = constants.HAS_RG and actions_helper.cursor_move_rg_bufnr
  or actions_helper.cursor_move_grep_bufnr
local setqflist = constants.HAS_RG and actions_helper.setqflist_rg_bufnr
  or actions_helper.setqflist_grep_bufnr

M.actions = {
  ["esc"] = actions_helper.nop,
  ["enter"] = set_cursor,
  ["double-click"] = set_cursor,
  ["ctrl-q"] = setqflist,
}

M.fzf_opts = {
  "--multi",
  "--disabled",
  { "--delimiter", ":" },
  { "--preview-window", "+{1}-/2" },
  { "--prompt", "Buffer Live Grep > " },
}

M.other_opts = {
  reload_on_change = true,
}

return M
