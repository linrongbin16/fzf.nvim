local consts = require("fzfx.lib.constants")

local ProviderTypeEnum = require("fzfx.schema").ProviderTypeEnum
local CommandFeedEnum = require("fzfx.schema").CommandFeedEnum

local _lsp_locations = require("fzfx.cfg._lsp_locations")

local M = {}

M.command = {
  name = "FzfxLspImplementations",
  desc = "Search lsp implementations",
}

M.variants = {
  name = "args",
  feed = CommandFeedEnum.ARGS,
}

M.providers = {
  key = "default",
  provider = _lsp_locations._make_lsp_locations_provider({
    method = "textDocument/implementation",
    capability = "implementationProvider",
  }),
  provider_type = ProviderTypeEnum.LIST,
  provider_decorator = { module = "prepend_icon_grep", builtin = true },
}

M.previewers = _lsp_locations.previewers

M.actions = _lsp_locations.actions

M.win_opts = _lsp_locations.win_opts

M.other_opts = _lsp_locations.other_opts

M.fzf_opts = {
  consts.FZF_OPTS.MULTI,
  consts.FZF_OPTS.LSP_PREVIEW_WINDOW,
  consts.FZF_OPTS.DELIMITER,
  "--border=none",
  { "--prompt", "Implementations > " },
}

return M
