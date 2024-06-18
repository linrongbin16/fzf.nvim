-- ========== Context ==========
--
--- @alias fzfx.PipelineContext {bufnr:integer,winnr:integer,tabnr:integer}
--- @alias fzfx.PipelineContextMaker fun():fzfx.PipelineContext
--
--
-- ========== Provider ==========
--
--- @alias fzfx.PlainProvider string|string[]
-- Note: The 1st parameter 'query' is the user input query in fzf prompt.
--- @alias fzfx.CommandProvider fun(query:string?,context:fzfx.PipelineContext?):string?|string[]?
--- @alias fzfx.ListProvider fun(query:string?,context:fzfx.PipelineContext?):string[]?
--- @alias fzfx.Provider fzfx.PlainProvider|fzfx.CommandProvider|fzfx.ListProvider
---
--- @alias fzfx.ProviderType "plain"|"command"|"list"|"plain_list"|"command_list"
--- @enum fzfx.ProviderTypeEnum
local ProviderTypeEnum = {
  -- A lua string or strings list.
  PLAIN = "plain",
  PLAIN_LIST = "plain_list",
  -- A lua function, that returns a string or strings list.
  COMMAND = "command",
  COMMAND_LIST = "command_list",
  -- A lua function, that directly returns lines.
  LIST = "list",
}
--
-- ========== Provider Decorator ==========
--
-- Note: In `fzfx._FunctionProviderDecorator`, the 1st parameter `line` is the raw generated line from providers.
--- @alias fzfx._FunctionProviderDecorator fun(line:string?):string?
--- @alias fzfx.ProviderDecorator {module:string,rtp:string?,builtin:boolean?}
--
-- ========== Previewer ==========
--
-- Note: The 1st parameter 'line' is the current selected line in (the left side of) the fzf binary.
--- @alias fzfx.CommandPreviewer fun(line:string?,context:fzfx.PipelineContext?):string?
--- @alias fzfx.ListPreviewer fun(line:string?,context:fzfx.PipelineContext?):string[]?
--- @alias fzfx.BufferFilePreviewerResult {filename:string,lineno:integer?,column:integer?}
--- @alias fzfx.BufferFilePreviewer fun(line:string?,context:fzfx.PipelineContext?):fzfx.BufferFilePreviewerResult?
--- @alias fzfx.Previewer fzfx.CommandPreviewer|fzfx.ListPreviewer|fzfx.BufferFilePreviewer
---
--- @alias fzfx.PreviewerType "command"|"command_list"|"list"|"buffer_file"
--- @enum fzfx.PreviewerTypeEnum
local PreviewerTypeEnum = {
  COMMAND = "command",
  COMMAND_LIST = "command_list",
  LIST = "list",
  BUFFER_FILE = "buffer_file",
}
--
-- ========== Previewer Label ==========
--
--- @alias fzfx.PlainPreviewerLabel string
-- Note: The 1st parameter 'line' is the current selected line in (the left side of) the fzf binary.
--- @alias fzfx.FunctionPreviewerLabel fun(line:string?,context:fzfx.PipelineContext?):string?
--- @alias fzfx.PreviewerLabel fzfx.PlainPreviewerLabel|fzfx.FunctionPreviewerLabel
---
--- @alias fzfx.PreviewerLabelType "plain"|"function"
--- @enum PreviewerLabelTypeEnum
local PreviewerLabelTypeEnum = {
  PLAIN = "plain",
  FUNCTION = "function",
}
--
-- ========== Command Feed ==========
--
--- @alias fzfx.CommandFeed "args"|"visual"|"cword"|"put"|"resume"
--- @enum fzfx.CommandFeedEnum
local CommandFeedEnum = {
  ARGS = "args",
  VISUAL = "visual",
  CWORD = "cword",
  PUT = "put",
  RESUME = "resume",
}
--
-- ========== Fzf Option ==========
--
--- @alias fzfx.PlainFzfOpt string
--- @alias fzfx.PairFzfOpt string[]
--- @alias fzfx.FunctionFzfOpt fun():fzfx.PlainFzfOpt|fzfx.PairFzfOpt
---
--- @alias fzfx.FzfOpt fzfx.PlainFzfOpt|fzfx.PairFzfOpt|fzfx.FunctionFzfOpt
--
-- ========== Interaction/Action ==========
--
--- @alias fzfx.ActionKey string
-- Note: The 1st parameter in `Interaction` is the current line.
--- @alias fzfx.Interaction fun(line:string?,context:fzfx.PipelineContext):any
-- Note: The 1st parameter in `Action` is the selected line(s).
--- @alias fzfx.Action fun(line:string[]|nil,context:fzfx.PipelineContext):any
--
-- ========== Config ==========
--
-- Note:
-- 1. The "key" option is to press and switch to this provider. For example in "FzfxFiles" command, user press "CTRL-U" to switch to **unrestricted mode**, press "CTRL-R" to switch to **restricted mode** (here a **mode** is actually a provider).
-- 2. The "provider" option is the **provider** we mentioned above, that provides the data source, i.e. the lines (in the left side) of fzf binary.
-- 3. The "provider_type" option by default is "plain" or "plain_list". Also see "get_provider_type_or_default" function in below.
-- 4. The "provider_decorator" option is optional.
--- @alias fzfx.ProviderConfig {key:fzfx.ActionKey,provider:fzfx.Provider,provider_type:fzfx.ProviderType?,provider_decorator:fzfx.ProviderDecorator?}
--
-- Note:
-- 1. The "previewer" option is the **previewer** we mentioned above, that previews the content of the current line, i.e. generates lines (in the right side) of fzf binary.
-- 2. The "previewer_type" option by default "command". Also see "get_previewer_type_or_default" function in below.
-- 3. The "previewer_label" option is optional.
-- 4. The "previewer_label_type" option by default is "plain" or "function". Also see "get_previewer_label_type_or_default" function in below.
--- @alias fzfx.PreviewerConfig {previewer:fzfx.Previewer,previewer_type:fzfx.PreviewerType?,previewer_label:fzfx.PreviewerLabel?,previewer_label_type:fzfx.PreviewerLabelType?}
---
--
-- Note: A pipeline name is the same with the provider name.
--- @alias fzfx.PipelineName string
--
--- @alias fzfx.InteractionName string
--
-- Note:
-- 1. The "key" option is to press and invokes the binded lua function.
-- 2. The "interaction" option is the **interaction** we mentioned above.
-- 3. The "reload_after_execute" option is to tell fzf binary, that reloads the query after execute this interaction.
--- @alias fzfx.InteractionConfig {key:fzfx.ActionKey,interaction:fzfx.Interaction,reload_after_execute:boolean?}
---
-- Note: Please refer to the command configurations in "fzfx.cfg" packages for the usage.
--- @alias fzfx.VariantConfig {name:string,feed:fzfx.CommandFeed,default_provider:fzfx.PipelineName?}
--
-- Note: Please refer to the command configurations in "fzfx.cfg" packages for the usage.
--- @alias fzfx.CommandConfig {name:string,desc:string?}
--
-- Note: Please refer to the command configurations in "fzfx.cfg" packages for the usage.
--- @alias fzfx.GroupConfig {command:fzfx.CommandConfig,variants:fzfx.VariantConfig[],providers:fzfx.ProviderConfig|table<fzfx.PipelineName,fzfx.ProviderConfig>,previewers:fzfx.PreviewerConfig|table<fzfx.PipelineName,fzfx.PreviewerConfig>,actions:table<fzfx.ActionKey,fzfx.Action>,interactions:table<fzfx.InteractionName,fzfx.InteractionConfig>?,fzf_opts:fzfx.FzfOpt[]?}

-- Whether `cfg` is a `fzfx.VariantConfig` instance.
--- @param cfg fzfx.VariantConfig?
--- @return boolean
local function is_variant_config(cfg)
  return type(cfg) == "table"
    and type(cfg.name) == "string"
    and string.len(cfg.name) > 0
    and type(cfg.feed) == "string"
    and string.len(cfg.feed) > 0
end

-- Whether `cfg` is a `fzfx.ProviderConfig` instance.
--- @param cfg fzfx.ProviderConfig?
--- @return boolean
local function is_provider_config(cfg)
  return type(cfg) == "table"
    and type(cfg.key) == "string"
    and string.len(cfg.key) > 0
    and (
      (
        type(cfg.provider) == "string" and string.len(cfg.provider --[[@as string]]) > 0
      )
      or (type(cfg.provider) == "table" and #cfg.provider > 0)
      or type(cfg.provider) == "function"
    )
end

-- Whether `cfg` is a `fzfx.PreviewerConfig` instance.
--- @param cfg fzfx.PreviewerConfig?
--- @return boolean
local function is_previewer_config(cfg)
  return type(cfg) == "table"
    and type(cfg.previewer) == "function"
    and (
      cfg.previewer_type == nil
      or (type(cfg.previewer_type) == "string" and string.len(cfg.previewer_type) > 0)
    )
end

-- Get provider type or default.
--- @param provider_config fzfx.ProviderConfig
--- @return fzfx.ProviderType
local function get_provider_type_or_default(provider_config)
  return provider_config.provider_type
    or (
      type(provider_config.provider) == "string" and ProviderTypeEnum.PLAIN
      or ProviderTypeEnum.PLAIN_LIST
    )
end

-- Get previewer type or default.
--- @param previewer_config fzfx.PreviewerConfig
--- @return fzfx.PreviewerType
local function get_previewer_type_or_default(previewer_config)
  return previewer_config.previewer_type or PreviewerTypeEnum.COMMAND
end

-- Get previewer label type or default.
--- @param previewer_config fzfx.PreviewerConfig
--- @return fzfx.PreviewerLabelType
local function get_previewer_label_type_or_default(previewer_config)
  return previewer_config.previewer_label_type
    or (
      type(previewer_config.previewer_label) == "function" and PreviewerLabelTypeEnum.FUNCTION
      or PreviewerLabelTypeEnum.PLAIN
    )
end

local M = {
  ProviderTypeEnum = ProviderTypeEnum,
  PreviewerTypeEnum = PreviewerTypeEnum,
  PreviewerLabelTypeEnum = PreviewerLabelTypeEnum,
  CommandFeedEnum = CommandFeedEnum,

  is_variant_config = is_variant_config,
  is_provider_config = is_provider_config,
  is_previewer_config = is_previewer_config,

  get_provider_type_or_default = get_provider_type_or_default,
  get_previewer_type_or_default = get_previewer_type_or_default,
  get_previewer_label_type_or_default = get_previewer_label_type_or_default,
}

return M
