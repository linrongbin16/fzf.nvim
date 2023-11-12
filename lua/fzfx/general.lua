local constants = require("fzfx.constants")
local log = require("fzfx.log")
local Popup = require("fzfx.popup").Popup
local fzf_helpers = require("fzfx.fzf_helpers")
local server = require("fzfx.server")
local color = require("fzfx.color")
local utils = require("fzfx.utils")
local env = require("fzfx.env")
local path = require("fzfx.path")
local ProviderTypeEnum = require("fzfx.schema").ProviderTypeEnum
local PreviewerTypeEnum = require("fzfx.schema").PreviewerTypeEnum
local schema = require("fzfx.schema")
local conf = require("fzfx.config")
local json = require("fzfx.json")

local DEFAULT_PIPELINE = "default"

--- @param ... string
--- @return string
local function _make_cache_filename(...)
    if env.debug_enable() then
        return path.join(
            conf.get_config().cache.dir,
            table.concat({ ... }, "_")
        )
    else
        return vim.fn.tempname()
    end
end

--- @return string
local function _provider_metafile()
    return _make_cache_filename("provider", "metafile")
end

--- @return string
local function _provider_resultfile()
    return _make_cache_filename("provider", "resultfile")
end

--- @return string
local function _previewer_metafile()
    return _make_cache_filename("previewer", "metafile")
end

--- @return string
local function _previewer_resultfile()
    return _make_cache_filename("previewer", "resultfile")
end

--- @return string
local function _fzf_port_file()
    return _make_cache_filename("fzf", "port", "file")
end

--- @class ProviderMetaOpts
--- @field pipeline PipelineName
--- @field provider_type ProviderType
--- @field prepend_icon_by_ft boolean?
--- @field prepend_icon_path_delimiter string?
--- @field prepend_icon_path_position integer?

--- @param pipeline string
--- @param provider_config ProviderConfig
--- @return ProviderMetaOpts
local function make_provider_meta_opts(pipeline, provider_config)
    local o = {
        pipeline = pipeline,
        provider_type = provider_config.provider_type,
    }

    -- prepend_icon_by_ft
    if
        type(provider_config.line_opts) == "table"
        and type(provider_config.line_opts.prepend_icon_by_ft) == "boolean"
    then
        o.prepend_icon_by_ft = provider_config.line_opts.prepend_icon_by_ft
    end

    -- prepend_icon_path_delimiter
    if
        type(provider_config.line_opts) == "table"
        and type(provider_config.line_opts.prepend_icon_path_delimiter) == "string"
        and string.len(
                provider_config.line_opts.prepend_icon_path_delimiter
            )
            > 0
    then
        o.prepend_icon_path_delimiter =
            provider_config.line_opts.prepend_icon_path_delimiter
    end

    -- prepend_icon_path_position
    if
        type(provider_config.line_opts) == "table"
        and type(provider_config.line_opts.prepend_icon_path_position)
            == "number"
    then
        o.prepend_icon_path_position =
            provider_config.line_opts.prepend_icon_path_position
    end

    return o
end

--- @class PreviewerMetaOpts
--- @field pipeline PipelineName
--- @field previewer_type PreviewerType

--- @param pipeline string
--- @param previewer_config PreviewerConfig
--- @return PreviewerMetaOpts
local function make_previewer_meta_opts(pipeline, previewer_config)
    local o = {
        pipeline = pipeline,
        previewer_type = previewer_config.previewer_type,
    }
    return o
end

-- provider switch {

--- @class ProviderSwitch
--- @field pipeline PipelineName
--- @field provider_configs ProviderConfig|table<PipelineName, ProviderConfig>
--- @field metafile string
--- @field resultfile string
local ProviderSwitch = {}

--- @param name string
--- @param pipeline PipelineName
--- @param provider_configs Options
--- @return ProviderSwitch
function ProviderSwitch:new(name, pipeline, provider_configs)
    local provider_configs_map = {}
    if schema.is_provider_config(provider_configs) then
        provider_configs.provider_type =
            schema.get_provider_type_or_default(provider_configs)
        provider_configs_map[DEFAULT_PIPELINE] = provider_configs
    else
        for provider_name, provider_opts in pairs(provider_configs) do
            log.ensure(
                schema.is_provider_config(provider_opts),
                "%s (%s) is not a valid provider! %s",
                vim.inspect(provider_name),
                vim.inspect(name),
                vim.inspect(provider_opts)
            )
            provider_opts.provider_type =
                schema.get_provider_type_or_default(provider_opts)
            provider_configs_map[provider_name] = provider_opts
        end
    end

    local o = {
        pipeline = pipeline,
        provider_configs = provider_configs_map,
        metafile = _provider_metafile(),
        resultfile = _provider_resultfile(),
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

--- @param next_pipeline PipelineName
--- @return nil
function ProviderSwitch:switch(next_pipeline)
    self.pipeline = next_pipeline
end

--- @param query string?
--- @param context PipelineContext?
function ProviderSwitch:provide(query, context)
    local provider_config = self.provider_configs[self.pipeline]
    -- log.debug(
    --     "|fzfx.general - ProviderSwitch:provide| pipeline:%s, provider_config:%s, context:%s",
    --     vim.inspect(self.pipeline),
    --     vim.inspect(provider_config),
    --     vim.inspect(context)
    -- )
    log.ensure(
        type(provider_config) == "table",
        "invalid provider config in %s! provider config: %s",
        vim.inspect(self.pipeline),
        vim.inspect(provider_config)
    )
    log.ensure(
        type(provider_config.provider) == "table"
            or type(provider_config.provider) == "string"
            or type(provider_config.provider) == "function",
        "invalid provider in %s! provider: %s",
        vim.inspect(self.pipeline),
        vim.inspect(provider_config)
    )
    log.ensure(
        provider_config.provider_type == ProviderTypeEnum.PLAIN
            or provider_config.provider_type == ProviderTypeEnum.PLAIN_LIST
            or provider_config.provider_type == ProviderTypeEnum.COMMAND
            or provider_config.provider_type == ProviderTypeEnum.COMMAND_LIST
            or provider_config.provider_type == ProviderTypeEnum.LIST,
        "invalid provider type in %s! provider type: %s",
        vim.inspect(self.pipeline),
        vim.inspect(provider_config)
    )

    local metaopts = make_provider_meta_opts(self.pipeline, provider_config)
    local metajson = json.encode(metaopts) --[[@as string]]
    utils.writefile(self.metafile, metajson)

    if provider_config.provider_type == ProviderTypeEnum.PLAIN then
        log.ensure(
            provider_config.provider == nil
                or type(provider_config.provider) == "string",
            "|fzfx.general - ProviderSwitch:provide| plain provider must be string or nil! self:%s, provider:%s",
            vim.inspect(self),
            vim.inspect(provider_config)
        )
        if provider_config.provider == nil then
            utils.writefile(self.resultfile, "")
        else
            utils.writefile(
                self.resultfile,
                provider_config.provider --[[@as string]]
            )
        end
    elseif provider_config.provider_type == ProviderTypeEnum.PLAIN_LIST then
        log.ensure(
            provider_config.provider == nil
                or type(provider_config.provider) == "table",
            "|fzfx.general - ProviderSwitch:provide| plain_list provider must be string or nil! self:%s, provider:%s",
            vim.inspect(self),
            vim.inspect(provider_config)
        )
        if
            provider_config.provider == nil
            or vim.tbl_isempty(provider_config.provider --[[@as table]])
        then
            utils.writefile(self.resultfile, "")
        else
            utils.writefile(
                self.resultfile,
                json.encode(provider_config.provider) --[[@as string]]
            )
        end
    elseif provider_config.provider_type == ProviderTypeEnum.COMMAND then
        local ok, result =
            pcall(provider_config.provider --[[@as function]], query, context)
        -- log.debug(
        --     "|fzfx.general - ProviderSwitch:provide| pcall command provider, ok:%s, result:%s",
        --     vim.inspect(ok),
        --     vim.inspect(result)
        -- )
        log.ensure(
            result == nil or type(result) == "string",
            "|fzfx.general - ProviderSwitch:provide| command provider result must be string! self:%s, result:%s",
            vim.inspect(self),
            vim.inspect(result)
        )
        if not ok then
            utils.writefile(self.resultfile, "")
            log.err(
                "failed to call pipeline %s command provider %s! query:%s, context:%s, error:%s",
                vim.inspect(self.pipeline),
                vim.inspect(provider_config),
                vim.inspect(query),
                vim.inspect(context),
                vim.inspect(result)
            )
        else
            if result == nil then
                utils.writefile(self.resultfile, "")
            else
                utils.writefile(self.resultfile, result)
            end
        end
    elseif provider_config.provider_type == ProviderTypeEnum.COMMAND_LIST then
        local ok, result =
            pcall(provider_config.provider --[[@as function]], query, context)
        -- log.debug(
        --     "|fzfx.general - ProviderSwitch:provide| pcall command_list provider, ok:%s, result:%s",
        --     vim.inspect(ok),
        --     vim.inspect(result)
        -- )
        log.ensure(
            result == nil or type(result) == "table",
            "|fzfx.general - ProviderSwitch:provide| command_list provider result must be string! self:%s, result:%s",
            vim.inspect(self),
            vim.inspect(result)
        )
        if not ok then
            utils.writefile(self.resultfile, "")
            log.err(
                "failed to call pipeline %s command_list provider %s! query:%s, context:%s, error:%s",
                vim.inspect(self.pipeline),
                vim.inspect(provider_config),
                vim.inspect(query),
                vim.inspect(context),
                vim.inspect(result)
            )
        else
            if result == nil or vim.tbl_isempty(result) then
                utils.writefile(self.resultfile, "")
            else
                utils.writefile(
                    self.resultfile,
                    json.encode(result) --[[@as string]]
                )
            end
        end
    elseif provider_config.provider_type == ProviderTypeEnum.LIST then
        local ok, result =
            pcall(provider_config.provider --[[@as function]], query, context)
        -- log.debug(
        --     "|fzfx.general - ProviderSwitch:provide| pcall list provider, ok:%s, result:%s",
        --     vim.inspect(ok),
        --     vim.inspect(result)
        -- )
        if not ok then
            utils.writefile(self.resultfile, "")
            log.err(
                "failed to call pipeline %s list provider %s! query:%s, context:%s, error:%s",
                vim.inspect(self.pipeline),
                vim.inspect(provider_config),
                vim.inspect(query),
                vim.inspect(context),
                vim.inspect(result)
            )
        else
            log.ensure(
                result == nil or type(result) == "table",
                "|fzfx.general - ProviderSwitch:provide| list provider result must be array! self:%s, result:%s",
                vim.inspect(self),
                vim.inspect(result)
            )
            if result == nil or vim.tbl_isempty(result) then
                utils.writefile(self.resultfile, "")
            else
                utils.writelines(self.resultfile, result)
            end
        end
    else
        log.throw(
            "|fzfx.general - ProviderSwitch:provide| invalid provider type! %s",
            vim.inspect(self)
        )
    end
    ---@diagnostic disable-next-line: need-check-nil
    return provider_config.provider_type
end

-- provider switch }

-- previewer switch {

--- @class PreviewerSwitch
--- @field pipeline PipelineName
--- @field previewer_configs table<PipelineName, PreviewerConfig>
--- @field previewer_labels_queue string[]
--- @field metafile string
--- @field resultfile string
--- @field fzf_port_file string
--- @field fzf_port string
local PreviewerSwitch = {}

--- @param name string
--- @param pipeline PipelineName
--- @param previewer_configs PreviewerConfig|table<PipelineName, PreviewerConfig>
--- @param fzf_port_file string
--- @return PreviewerSwitch
function PreviewerSwitch:new(name, pipeline, previewer_configs, fzf_port_file)
    local previewer_configs_map = {}
    if schema.is_previewer_config(previewer_configs) then
        previewer_configs.previewer_type =
            schema.get_previewer_type_or_default(previewer_configs)
        previewer_configs_map[DEFAULT_PIPELINE] = previewer_configs
    else
        for previewer_name, previewer_opts in pairs(previewer_configs) do
            log.ensure(
                schema.is_previewer_config(previewer_opts),
                "%s (%s) is not a valid previewer! %s",
                vim.inspect(previewer_name),
                vim.inspect(name),
                vim.inspect(previewer_opts)
            )
            previewer_opts.previewer_type =
                schema.get_previewer_type_or_default(previewer_opts)
            previewer_configs_map[previewer_name] = previewer_opts
        end
    end

    local o = {
        pipeline = pipeline,
        previewer_configs = previewer_configs_map,
        previewer_labels_queue = {},
        metafile = _previewer_metafile(),
        resultfile = _previewer_resultfile(),
        fzf_port_file = fzf_port_file,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

--- @param next_pipeline PipelineName
--- @return nil
function PreviewerSwitch:switch(next_pipeline)
    self.pipeline = next_pipeline
end

--- @param line string?
--- @param context PipelineContext
--- @return PreviewerType
function PreviewerSwitch:preview(line, context)
    local previewer_config = self.previewer_configs[self.pipeline]
    -- log.debug(
    --     "|fzfx.general - PreviewerSwitch:preview| pipeline:%s, previewer_config:%s, context:%s",
    --     vim.inspect(self.pipeline),
    --     vim.inspect(previewer_config),
    --     vim.inspect(context)
    -- )
    log.ensure(
        type(previewer_config) == "table",
        "invalid previewer config in %s! previewer config: %s",
        vim.inspect(self.pipeline),
        vim.inspect(previewer_config)
    )
    log.ensure(
        type(previewer_config.previewer) == "function",
        "invalid previewer in %s! previewer: %s",
        vim.inspect(self.pipeline),
        vim.inspect(previewer_config)
    )
    log.ensure(
        previewer_config.previewer_type == PreviewerTypeEnum.COMMAND
            or previewer_config.previewer_type == PreviewerTypeEnum.COMMAND_LIST
            or previewer_config.previewer_type == PreviewerTypeEnum.LIST,
        "invalid previewer type in %s! previewer type: %s",
        vim.inspect(self.pipeline),
        vim.inspect(previewer_config)
    )

    local metaopts = make_previewer_meta_opts(self.pipeline, previewer_config)
    local metajson = json.encode(metaopts) --[[@as string]]
    utils.writefile(self.metafile, metajson)

    if previewer_config.previewer_type == PreviewerTypeEnum.COMMAND then
        local ok, result = pcall(previewer_config.previewer, line, context)
        -- log.debug(
        --     "|fzfx.general - PreviewerSwitch:preview| pcall command previewer, ok:%s, result:%s",
        --     vim.inspect(ok),
        --     vim.inspect(result)
        -- )
        if not ok then
            utils.writefile(self.resultfile, "")
            log.err(
                "failed to call pipeline %s command previewer %s! line:%s, context:%s, error:%s",
                vim.inspect(self.pipeline),
                vim.inspect(previewer_config.previewer),
                vim.inspect(line),
                vim.inspect(context),
                vim.inspect(result)
            )
        else
            log.ensure(
                result == nil or type(result) == "string",
                "|fzfx.general - PreviewerSwitch:preview| command previewer result must be string! self:%s, result:%s",
                vim.inspect(self),
                vim.inspect(result)
            )
            if result == nil then
                utils.writefile(self.resultfile, "")
            else
                utils.writefile(self.resultfile, result --[[@as string]])
            end
        end
    elseif
        previewer_config.previewer_type == PreviewerTypeEnum.COMMAND_LIST
    then
        local ok, result = pcall(previewer_config.previewer, line, context)
        -- log.debug(
        --     "|fzfx.general - PreviewerSwitch:preview| pcall command_list previewer, ok:%s, result:%s",
        --     vim.inspect(ok),
        --     vim.inspect(result)
        -- )
        if not ok then
            utils.writefile(self.resultfile, "")
            log.err(
                "failed to call pipeline %s command_list previewer %s! line:%s, context:%s, error:%s",
                vim.inspect(self.pipeline),
                vim.inspect(previewer_config.previewer),
                vim.inspect(line),
                vim.inspect(context),
                vim.inspect(result)
            )
        else
            log.ensure(
                result == nil or type(result) == "table",
                "|fzfx.general - PreviewerSwitch:preview| command_list previewer result must be string! self:%s, result:%s",
                vim.inspect(self),
                vim.inspect(result)
            )
            ---@diagnostic disable-next-line: param-type-mismatch
            if result == nil or vim.tbl_isempty(result) then
                utils.writefile(self.resultfile, "")
            else
                utils.writefile(
                    self.resultfile,
                    json.encode(result) --[[@as string]]
                )
            end
        end
    elseif previewer_config.previewer_type == PreviewerTypeEnum.LIST then
        local ok, result = pcall(previewer_config.previewer, line, context)
        -- log.debug(
        --     "|fzfx.general - PreviewerSwitch:preview| pcall list previewer, ok:%s, result:%s",
        --     vim.inspect(ok),
        --     vim.inspect(result)
        -- )
        if not ok then
            utils.writefile(self.resultfile, "")
            log.err(
                "failed to call pipeline %s list previewer %s! line:%s, context:%s, error:%s",
                vim.inspect(self.pipeline),
                vim.inspect(previewer_config.previewer),
                vim.inspect(line),
                vim.inspect(context),
                vim.inspect(result)
            )
        else
            log.ensure(
                type(result) == "table",
                "|fzfx.general - PreviewerSwitch:preview| list previewer result must be array! self:%s, result:%s",
                vim.inspect(self),
                vim.inspect(result)
            )
            utils.writelines(self.resultfile, result --[[@as table]])
        end
    else
        log.throw(
            "|fzfx.general - PreviewerSwitch:preview| invalid previewer type! %s",
            vim.inspect(self)
        )
    end

    self:preview_label(line, context)

    return previewer_config.previewer_type
end

--- @param port string
--- @param body string
local function _send_http_post(port, body)
    -- if SendHttpPostContext.send then
    --     return
    -- end
    local asp = require("fzfx.spawn").Spawn:make({
        "curl",
        "-s",
        "-S",
        "-q",
        "-Z",
        "--parallel-immediate",
        "--http2",
        "--retry",
        "0",
        "--connect-timeout",
        "1",
        "-m",
        "1",
        "--noproxy",
        "*",
        "-XPOST",
        string.format("127.0.0.1:%s", vim.trim(port)),
        "-d",
        body,
    }, function(line)
        -- log.debug(
        --     "|fzfx.fzf_helpers - send_http_post| stdout:%s",
        --     vim.inspect(line)
        -- )
    end, function(line)
        -- log.debug(
        --     "|fzfx.fzf_helpers - send_http_post| stderr:%s",
        --     vim.inspect(line)
        -- )
    end, false) --[[@as Spawn]]
    asp:run()
end

--- @param line string?
--- @param context PipelineContext
--- @return string?
function PreviewerSwitch:preview_label(line, context)
    local previewer_config = self.previewer_configs[self.pipeline]
    -- log.debug(
    --     "|fzfx.general - PreviewerSwitch:preview_label| pipeline:%s, previewer_config:%s, context:%s",
    --     vim.inspect(self.pipeline),
    --     vim.inspect(previewer_config),
    --     vim.inspect(context)
    -- )
    log.ensure(
        type(previewer_config) == "table",
        "invalid previewer config in %s! previewer config: %s",
        vim.inspect(self.pipeline),
        vim.inspect(previewer_config)
    )
    log.ensure(
        type(previewer_config.previewer_label) == "function"
            or previewer_config.previewer_label == nil
            or type(previewer_config.previewer_label) == "boolean"
            or type(previewer_config.previewer_label) == "string",
        "invalid previewer label in %s! previewer: %s",
        vim.inspect(self.pipeline),
        vim.inspect(previewer_config)
    )

    if not constants.has_curl then
        return
    end
    if
        type(previewer_config.previewer_label) ~= "function"
        and type(previewer_config.previewer_label) ~= "string"
    then
        return
    end

    vim.schedule(function()
        local label = type(previewer_config.previewer_label) == "function"
                and previewer_config.previewer_label(line, context)
            or previewer_config.previewer_label
        log.debug(
            "|fzfx.general - PreviewerSwitch:preview_label| line:%s, label:%s",
            vim.inspect(line),
            vim.inspect(label)
        )
        if type(label) ~= "string" then
            return
        end
        table.insert(self.previewer_labels_queue, label)

        -- do later
        vim.defer_fn(function()
            if #self.previewer_labels_queue == 0 then
                return
            end
            local last_label =
                self.previewer_labels_queue[#self.previewer_labels_queue]
            self.previewer_labels_queue = {}
            if type(last_label) ~= "string" then
                return
            end
            self.fzf_port = utils.string_not_empty(self.fzf_port)
                    and self.fzf_port
                or utils.readfile(self.fzf_port_file) --[[@as string]]
            if utils.string_not_empty(self.fzf_port) then
                _send_http_post(
                    self.fzf_port,
                    string.format(
                        "change-preview-label(%s)",
                        vim.trim(last_label)
                    )
                )
            end
        end, 200)
    end)

    return self.pipeline
end

-- previewer switch }

-- header switch {

--- @class HeaderSwitch
--- @field headers table<PipelineName, string[]>
local HeaderSwitch = {}

--- @package
--- @param name string
--- @param action string
--- @return string
local function _render_help(name, action)
    return color.render(
        color.magenta,
        "Special",
        "%s to " .. table.concat(utils.string_split(name, "_"), " "),
        string.upper(action)
    )
end

--- @param excludes string[]|nil
--- @param s string
--- @return boolean
local function _should_skip_help(excludes, s)
    if type(excludes) ~= "table" then
        return false
    end
    for _, e in ipairs(excludes) do
        if e == s then
            return true
        end
    end
    return false
end

--- @param action_configs Options?
--- @param builder string[]
--- @param excludes string[]|nil
--- @return string[]
local function _make_help_doc(action_configs, builder, excludes)
    if type(action_configs) == "table" then
        local action_names = {}
        for name, opts in pairs(action_configs) do
            if not _should_skip_help(excludes, name) then
                table.insert(action_names, name)
            end
        end
        table.sort(action_names)
        for _, name in ipairs(action_names) do
            local opts = action_configs[name]
            local act = opts.key
            table.insert(builder, _render_help(name, act))
        end
    end
    return builder
end

--- @param provider_configs Options
--- @param interaction_configs Options
--- @return HeaderSwitch
function HeaderSwitch:new(provider_configs, interaction_configs)
    local headers_map = {}
    if schema.is_provider_config(provider_configs) then
        headers_map[DEFAULT_PIPELINE] = _make_help_doc(interaction_configs, {})
    else
        -- log.debug(
        --     "|fzfx.general - HeaderSwitch:new| provider_configs:%s",
        --     vim.inspect(provider_configs)
        -- )
        for provider_name, provider_opts in pairs(provider_configs) do
            local help_builder = _make_help_doc(
                provider_configs,
                {},
                { provider_name }
            )
            headers_map[provider_name] =
                _make_help_doc(interaction_configs, help_builder)
        end
    end

    local o = {
        headers = headers_map,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

--- @param pipeline PipelineName
--- @return FzfOpt?
function HeaderSwitch:get_header(pipeline)
    log.ensure(
        type(self.headers[pipeline]) == "table",
        "|fzfx.general - HeaderSwitch:get_header| pipeline (%s) must exists in headers! %s",
        vim.inspect(pipeline),
        vim.inspect(self)
    )
    local switch_help = self.headers[pipeline]
    return string.format(":: Press %s", table.concat(switch_help, ", "))
end

-- header switch }

--- @param pipeline_configs Options
local function get_pipeline_size(pipeline_configs)
    local n = 0
    if type(pipeline_configs) == "table" then
        if schema.is_provider_config(pipeline_configs.providers) then
            return 1
        end
        for _, _ in pairs(pipeline_configs.providers) do
            n = n + 1
        end
    end
    return n
end

--- @return PipelineContext
local function default_context_maker()
    return {
        bufnr = vim.api.nvim_get_current_buf(),
        winnr = vim.api.nvim_get_current_win(),
        tabnr = vim.api.nvim_get_current_tabpage(),
    }
end

--- @param name string
--- @param query string
--- @param bang boolean
--- @param pipeline_configs Options
--- @param default_pipeline PipelineName?
--- @return Popup
local function general(name, query, bang, pipeline_configs, default_pipeline)
    local fzf_port_file = _fzf_port_file()
    local pipeline_size = get_pipeline_size(pipeline_configs)

    local default_provider_key = nil
    if default_pipeline == nil then
        local pipeline = nil
        local provider_opts = nil
        if schema.is_provider_config(pipeline_configs.providers) then
            -- log.debug(
            --     "|fzfx.general - general| providers is single config: %s",
            --     vim.inspect(pipeline_configs.providers)
            -- )
            pipeline = DEFAULT_PIPELINE
            provider_opts = pipeline_configs.providers
        else
            -- log.debug(
            --     "|fzfx.general - general| providers is multiple configs: %s",
            --     vim.inspect(pipeline_configs.providers)
            -- )
            pipeline, provider_opts = next(pipeline_configs.providers)
        end
        default_pipeline = pipeline
        default_provider_key = provider_opts.key
    else
        local provider_opts = pipeline_configs.providers[default_pipeline]
        default_provider_key = provider_opts.key
    end

    --- @type ProviderSwitch
    local provider_switch =
        ProviderSwitch:new(name, default_pipeline, pipeline_configs.providers)

    --- @type PreviewerSwitch
    local previewer_switch = PreviewerSwitch:new(
        name,
        default_pipeline,
        pipeline_configs.previewers,
        fzf_port_file
    )

    --- @type PipelineContext

    local context_maker = (
        type(pipeline_configs.other_opts) == "table"
        and type(pipeline_configs.other_opts.context_maker) == "function"
    )
            and pipeline_configs.other_opts.context_maker
        or default_context_maker

    local context = context_maker()
    local rpc_registries = {}

    --- @param query_params string
    local function provide_rpc(query_params)
        provider_switch:provide(query_params, context)
    end

    --- @param line_params string
    local function preview_rpc(line_params)
        previewer_switch:preview(line_params, context)
    end

    local provide_rpc_id = server.get_rpc_server():register(provide_rpc)
    local preview_rpc_id = server.get_rpc_server():register(preview_rpc)
    table.insert(rpc_registries, provide_rpc_id)
    table.insert(rpc_registries, preview_rpc_id)

    local query_command = string.format(
        "%s %s %s %s %s",
        fzf_helpers.make_lua_command("general", "provider.lua"),
        provide_rpc_id,
        provider_switch.metafile,
        provider_switch.resultfile,
        utils.shellescape(query)
    )
    log.debug(
        "|fzfx.general - general| query_command:%s",
        vim.inspect(query_command)
    )
    local reload_query_command = string.format(
        "%s %s %s %s {q}",
        fzf_helpers.make_lua_command("general", "provider.lua"),
        provide_rpc_id,
        provider_switch.metafile,
        provider_switch.resultfile
    )
    log.debug(
        "|fzfx.general - general| reload_query_command:%s",
        vim.inspect(reload_query_command)
    )
    local preview_command = string.format(
        "%s %s %s %s {}",
        fzf_helpers.make_lua_command("general", "previewer.lua"),
        preview_rpc_id,
        previewer_switch.metafile,
        previewer_switch.resultfile
    )
    log.debug(
        "|fzfx.general - general| preview_command:%s",
        vim.inspect(preview_command)
    )

    local fzf_opts = {
        "--print-query",
        "--listen",
        { "--query", query },
        {
            "--preview",
            preview_command,
        },
    }

    local dump_fzf_port_command = nil
    if constants.is_windows then
        -- if vim.fn.executable("sh") > 0 or vim.fn.executable("bash") > 0 then
        --     dump_fzf_port_command = string.format(
        --         "%s -c '%s'",
        --         vim.fn.executable("sh") > 0 and "sh" or "bash",
        --         string.format("echo $FZF_PORT>%s", fzf_port_file)
        --     )
        -- else
        dump_fzf_port_command =
            string.format("cmd.exe /C echo %%FZF_PORT%%>%s", fzf_port_file)
        -- end
    else
        dump_fzf_port_command =
            string.format("echo $FZF_PORT>%s", fzf_port_file)
    end
    local fzf_start_binder = fzf_helpers.FzfOptEventBinder:new("start")
    fzf_start_binder:append(
        string.format("execute-silent(%s)", dump_fzf_port_command)
    )

    local header_switch = HeaderSwitch:new(
        pipeline_configs.providers,
        pipeline_configs.interactions
    )

    -- have interactions or pipelines >= 2
    if type(pipeline_configs.interactions) == "table" or pipeline_size > 1 then
        local header = header_switch:get_header(default_pipeline)
        table.insert(fzf_opts, {
            "--header",
            header,
        })
    end

    -- when no interactions, no need to add help
    if type(pipeline_configs.interactions) == "table" then
        for _, interaction_opts in pairs(pipeline_configs.interactions) do
            local action_key = string.lower(interaction_opts.key)
            local action = interaction_opts.interaction

            local function interaction_rpc(line_params)
                -- log.debug(
                --     "|fzfx.general - general.interaction_rpc| line_params:%s",
                --     vim.inspect(line_params)
                -- )
                action(line_params, context)
            end

            local interaction_rpc_id =
                server.get_rpc_server():register(interaction_rpc)
            table.insert(rpc_registries, interaction_rpc_id)

            local action_command = string.format(
                "%s %s {}",
                fzf_helpers.make_lua_command("rpc", "request.lua"),
                interaction_rpc_id
            )
            local bind_builder = string.format(
                "%s:execute-silent(%s)",
                action_key,
                action_command
            )
            if interaction_opts.reload_after_execute then
                bind_builder = bind_builder
                    .. string.format("+reload(%s)", reload_query_command)
            end
            table.insert(fzf_opts, {
                "--bind",
                bind_builder,
            })
        end
    end

    -- when only have 1 pipeline, no need to add help for switch keys
    if pipeline_size > 1 then
        for pipeline, provider_opts in pairs(pipeline_configs.providers) do
            local switch_key = string.lower(provider_opts.key)

            local function switch_rpc()
                provider_switch:switch(pipeline)
                previewer_switch:switch(pipeline)
            end

            local switch_rpc_id = server.get_rpc_server():register(switch_rpc)
            table.insert(rpc_registries, switch_rpc_id)

            local switch_command = string.format(
                "%s %s",
                fzf_helpers.make_lua_command("rpc", "request.lua"),
                switch_rpc_id
            )
            local bind_builder = string.format(
                "%s:unbind(%s)+execute-silent(%s)+change-header(%s)+reload(%s)",
                switch_key,
                switch_key,
                switch_command,
                header_switch:get_header(pipeline),
                reload_query_command
            )
            for pipeline2, provider_opts2 in pairs(pipeline_configs.providers) do
                if pipeline2 ~= pipeline then
                    local switch_key2 = string.lower(provider_opts2.key)
                    bind_builder = bind_builder
                        .. string.format("+rebind(%s)", switch_key2)
                end
            end
            table.insert(fzf_opts, {
                "--bind",
                bind_builder,
            })
        end
        fzf_start_binder:append(
            string.format("unbind(%s)", default_provider_key)
        )
    end
    if
        type(pipeline_configs.other_opts) == "table"
        and pipeline_configs.other_opts.reload_on_change
    then
        table.insert(fzf_opts, {
            "--bind",
            string.format("change:reload(%s)", reload_query_command),
        })
    end
    table.insert(fzf_opts, fzf_start_binder:build())

    fzf_opts =
        vim.list_extend(fzf_opts, vim.deepcopy(pipeline_configs.fzf_opts))
    fzf_opts = fzf_helpers.preprocess_fzf_opts(fzf_opts)
    local actions = pipeline_configs.actions
    local win_opts = nil
    if
        type(pipeline_configs.win_opts) == "table"
        and not vim.tbl_isempty(pipeline_configs.win_opts)
    then
        win_opts = vim.tbl_deep_extend(
            "force",
            vim.deepcopy(win_opts or {}),
            pipeline_configs.win_opts
        )
    end
    if bang then
        win_opts = vim.tbl_deep_extend(
            "force",
            vim.deepcopy(win_opts or {}),
            { height = 1, width = 1, row = 0, col = 0 }
        )
    end
    local p = Popup:new(
        win_opts or {},
        query_command,
        fzf_opts,
        actions,
        context,
        function(last_query)
            vim.schedule(function()
                for _, rpc_id in ipairs(rpc_registries) do
                    server:get_rpc_server():unregister(rpc_id)
                end
                local last_query_cache = fzf_helpers.make_last_query_cache(name)
                local content = json.encode({
                    default_provider = provider_switch.pipeline,
                    query = last_query,
                }) --[[@as string]]
                utils.asyncwritefile(
                    last_query_cache,
                    content,
                    function(err, bytes)
                        log.debug(
                            "|fzfx.general - general| dump last query:%s, error:%s",
                            vim.inspect(bytes),
                            vim.inspect(err)
                        )
                    end
                )
            end)
        end
    )
    return p
end

--- @param name string
--- @param command_config CommandConfig
--- @param group_config GroupConfig
local function _make_user_command(name, command_config, group_config)
    vim.api.nvim_create_user_command(command_config.name, function(opts)
        local query, last_provider =
            fzf_helpers.get_command_feed(command_config.feed, opts.args, name)
        local default_provider = last_provider
            or command_config.default_provider
        return general(name, query, opts.bang, group_config, default_provider)
    end, command_config.opts)
end

--- @param name string
--- @param pipeline_configs Options?
local function setup(name, pipeline_configs)
    if not pipeline_configs then
        return
    end

    -- log.debug(
    --     "|fzfx.general - setup| pipeline_configs:%s",
    --     vim.inspect(pipeline_configs)
    -- )
    -- User commands
    if schema.is_command_config(pipeline_configs.commands) then
        _make_user_command(name, pipeline_configs.commands, pipeline_configs)
    else
        for _, command_configs in pairs(pipeline_configs.commands) do
            _make_user_command(name, command_configs, pipeline_configs)
        end
    end
end

local M = {
    setup = setup,
    _make_user_command = _make_user_command,
    _make_cache_filename = _make_cache_filename,
    _provider_metafile = _provider_metafile,
    _provider_resultfile = _provider_resultfile,
    _previewer_metafile = _previewer_metafile,
    _previewer_resultfile = _previewer_resultfile,
    _fzf_port_file = _fzf_port_file,
    make_provider_meta_opts = make_provider_meta_opts,
    make_previewer_meta_opts = make_previewer_meta_opts,
    ProviderSwitch = ProviderSwitch,
    PreviewerSwitch = PreviewerSwitch,
    _send_http_post = _send_http_post,
    _render_help = _render_help,
    _should_skip_help = _should_skip_help,
    _make_help_doc = _make_help_doc,
    HeaderSwitch = HeaderSwitch,
}

return M
