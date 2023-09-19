-- Zero Dependency

local Clazz = require("fzfx.clazz").Clazz

-- Schema
-- See: https://github.com/linrongbin16/fzfx.nvim/wiki/A-General-Schema-for-Creating-FZF-Command
--
-- ========== Provider ==========
--
-- A provider is a shell command that run and generate the lines list for fzf (e.g. things on the left side).
-- We have 3 types of providers:
--  * Plain provider: a simple command string to execute and generate the lines list for fzf.
--  * Command provider: a lua function to run and generate the command string, execute it and generate the lines.
--  * List provider: a lua function to run and directly generate the lines.
--
-- The 1st parameter 'query' is the query in fzf prompt.
-- The 2nd parameter 'context' contains information before this plugin start.
-- E.g. the bufnr, winnr before this plugin start.
-- Since some providers will need the context before plugin starting, for example some buffer only commands needs the buffer number before plugin start.
--
--- @class PipelineContext
--- @field bufnr integer
--- @field winnr integer
--- @field tabnr integer
--
--- @alias PipelineContextMaker fun():PipelineContext
--
--- @alias PlainProvider string?|string[]?
--- @alias CommandProvider fun(query:string?,context:PipelineContext?):string?|string[]?
--- @alias ListProvider fun(query:string?,context:PipelineContext?):string[]?
--
--- @alias Provider PlainProvider|CommandProvider|ListProvider
--- @alias ProviderType "plain"|"command"|"list"|"plain_list"|"command_list"
--- @enum ProviderTypeEnum
local ProviderTypeEnum = {
    PLAIN = "plain",
    PLAIN_LIST = "plain_list",
    COMMAND = "command",
    COMMAND_LIST = "command_list",
    LIST = "list",
}

-- ========== Previewer ==========
--
-- A previewer is a shell command that run and echo details for fzf (e.g. things on the right side).
-- We have 3 types of previewers:
--  * Command previewer: a lua function that generate a command string to execute and echo details.
--  * List previewer: a lua function that directly generate a list of strings.
--  * Builtin previewer (todo): a nvim buffer & window, I think the biggest benefits can be allowing users to navigate to the buffer and edit it directly.
--
-- The BuiltinPreviewer returns the configs for the nvim window.
--
--- @alias CommandPreviewer fun(line:string?,context:PipelineContext?):string?
--- @alias ListPreviewer fun(line:string?,context:PipelineContext?):string[]?
--- @alias BuiltinPreviewer fun(line:string?,context:PipelineContext?):table?
--
--- @alias Previewer CommandPreviewer|ListPreviewer|BuiltinPreviewer
--- @alias PreviewerType "command"|"command_list"|"list"|"builtin"
--- @enum PreviewerTypeEnum
local PreviewerTypeEnum = {
    COMMAND = "command",
    COMMAND_LIST = "command_list",
    LIST = "list",
}

-- ========== Command Option ==========
--
-- User command options are something that passing to nvim user command lua api.
-- See:
--  * https://neovim.io/doc/user/api.html#nvim_create_user_command()
--  * https://neovim.io/doc/user/map.html#command-attributes
--
--- @alias CommandOptKey "nargs"|"bang"|"complete"|"desc"|"range"
--- @alias CommandOptValue string|boolean
--- @alias CommandOpt table<CommandOptKey, CommandOptValue>

-- ========== Command Feed ==========
--
-- User command feeds are method that what to feed the fzfx command.
-- E.g. visual selected, cursor word, etc.
--
--- @alias CommandFeed "args"|"visual"|"cword"|"put"
--- @enum CommandFeedEnum
local CommandFeedEnum = {
    ARGS = "args",
    VISUAL = "visual",
    CWORD = "cword",
    PUT = "put",
}

-- ========== Fzf Option ==========
--
-- A fzf option is passing directly to the final fzf command (e.g. --multi, --bind=ctrl-e:toggle).
-- We have 3 types of fzf options:
--  * Plain fzf option: a simple string, e.g. '--multi'.
--  * Pair fzf option: a list of two strings, e.g. { '--bind', 'ctrl-e:toggle' }.
--  * Function fzf option: a lua function that run and generate above two kinds of fzf options.
--
--- @alias PlainFzfOpt string
--- @alias PairFzfOpt string[]
--- @alias FunctionFzfOpt fun():PlainFzfOpt|PairFzfOpt
--
--- @alias FzfOpt PlainFzfOpt|PairFzfOpt|FunctionFzfOpt

-- ========== Action ==========
--
-- An action is user press a key and we do something.
-- We have 2 types of actions:
--  * Interaction: interactively execute something without exit fzf.
--  * Action: exit fzf and do something in callback.
--
--- @alias ActionKey string
--- @alias ActionHelp string
--
--- @alias Interaction fun(line:string?):any
--- @alias Action fun(line:string[]|nil):any

-- ========== Pipeline ==========
--
-- A pipeline tries to match a provider with a previewer, with a interactive action key to switch the data sources, and the help message.
-- (Note: when you only have 1 provider, the interactive key and help message can be ommitted).
--
-- So we say the provider-interaction-previewer is a pipeline (data flow).
--
--- @alias PipelineName string
--
--- @class Pipeline
--- @field name PipelineName
--- @field provider Provider
--- @field provider_type ProviderType
--- @field previewer Previewer
--- @field previewer_type PreviewerType
--- @field switch ActionKey?
--- @field help ActionHelp?

-- ========== Schema ==========
--
-- Finally a schema defines the modern fzf command we are using, e.g. `FzfxLiveGrep`, `FzfxFiles`, etc.
-- The fzf command we try to define should be quite powerful:
--
--  * We can have multiple data sources from different providers, switch by different interactive actions.
--  * We can have multiple previewers, each bind to one provider.
--  * We can have multiple interactive keys to do something without exiting fzf.
--  * We can have multiple expect keys to exit fzf and run the callbacks.
--  * We can have extra fzf options.
--
--- @class Schema
--- @field name string
--- @field pipelines table<PipelineName, Pipeline>
--- @field interactions table<ActionKey, Interaction>
--- @field interaction_helps table<ActionKey, Interaction>
--- @field actions table<ActionKey, Action>

-- ========== Config ==========
--
-- Utility for easier writing 'fzfx.config'.
--
--- @alias ProviderLineType "file"
--- @enum ProviderLineTypeEnum
local ProviderLineTypeEnum = {
    FILE = "file",
}

--- @class ProviderConfig
--- @field key ActionKey
--- @field provider Provider
--- @field provider_type ProviderType? by default "plain"
--- @field context_maker PipelineContextMaker?
--- @field line_type ProviderLineType?
--- @field line_delimiter string?
--- @field line_pos integer?
local ProviderConfig = Clazz:implement("fzfx.config.ProviderConfig", {
    key = nil,
    provider = nil,
    provider_type = nil,
    context_maker = nil,
    line_type = nil,
    line_delimiter = nil,
    line_pos = nil,
})

function ProviderConfig:make(opts)
    local p =
        vim.tbl_deep_extend("force", vim.deepcopy(ProviderConfig), opts or {})
    p.provider_type = p.provider_type
        or (
            type(p.provider) == "string" and ProviderTypeEnum.PLAIN
            or ProviderTypeEnum.PLAIN_LIST
        )
    return p
end

--- @class PreviewerConfig
--- @field previewer Previewer
--- @field previewer_type PreviewerType
local PreviewerConfig = Clazz:implement("fzfx.config.PreviewerConfig", {
    previewer = nil,
    previewer_type = nil,
})

function PreviewerConfig:make(opts)
    local p =
        vim.tbl_deep_extend("force", vim.deepcopy(PreviewerConfig), opts or {})
    p.previewer_type = p.previewer_type or PreviewerTypeEnum.COMMAND
    return p
end

--- @class CommandConfig
--- @field name string
--- @field feed CommandFeed
--- @field opts CommandOpt
--- @field default_provider PipelineName?
local CommandConfig = Clazz:implement("fzfx.config.CommandConfig", {
    name = nil,
    feed = nil,
    opts = nil,
    default_provider = nil,
})

function CommandConfig:make(opts)
    return vim.tbl_deep_extend("force", vim.deepcopy(CommandConfig), opts or {})
end

--- @alias InteractionName string
--
--- @class InteractionConfig
--- @field key ActionKey
--- @field interaction Interaction
--- @field reload_after_execute boolean?
local InteractionConfig = Clazz:implement("fzfx.config.InteractionConfig", {
    key = nil,
    interaction = nil,
    reload_after_execute = false,
})

function InteractionConfig:make(opts)
    return vim.tbl_deep_extend(
        "force",
        vim.deepcopy(InteractionConfig),
        opts or {}
    )
end

--- @class GroupConfig
--- @field commands CommandConfig|CommandConfig[]
--- @field providers ProviderConfig|table<PipelineName, ProviderConfig>
--- @field previewers PreviewerConfig|table<PipelineName, PreviewerConfig>
--- @field interactions table<InteractionName, InteractionConfig>?
--- @field actions table<ActionKey, Action>
--- @field fzf_opts FzfOpt[]?
local GroupConfig = Clazz:implement("fzfx.config.GroupConfig", {
    commands = nil,
    providers = nil,
    previewers = nil,
    interactions = nil,
    actions = nil,
    fzf_opts = nil,
})

function GroupConfig:make(opts)
    return vim.tbl_deep_extend("force", vim.deepcopy(GroupConfig), opts or {})
end

local M = {
    ProviderTypeEnum = ProviderTypeEnum,
    PreviewerTypeEnum = PreviewerTypeEnum,
    CommandFeedEnum = CommandFeedEnum,
    ProviderConfig = ProviderConfig,
    ProviderLineTypeEnum = ProviderLineTypeEnum,
    PreviewerConfig = PreviewerConfig,
    CommandConfig = CommandConfig,
    InteractionConfig = InteractionConfig,
    GroupConfig = GroupConfig,
}

return M
