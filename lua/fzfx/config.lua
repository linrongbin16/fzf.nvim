local constants = require("fzfx.constants")
local utils = require("fzfx.utils")
local env = require("fzfx.env")
local log = require("fzfx.log")
local LogLevels = require("fzfx.log").LogLevels
local color = require("fzfx.color")
local path = require("fzfx.path")
local line_helpers = require("fzfx.line_helpers")
local ProviderTypeEnum = require("fzfx.schema").ProviderTypeEnum
local PreviewerTypeEnum = require("fzfx.schema").PreviewerTypeEnum
local CommandFeedEnum = require("fzfx.schema").CommandFeedEnum

--- @type table<string, FzfOpt>
local default_fzf_options = {
    multi = "--multi",
    toggle = "--bind=ctrl-e:toggle",
    toggle_all = "--bind=ctrl-a:toggle-all",
    toggle_preview = "--bind=alt-p:toggle-preview",
    preview_half_page_down = "--bind=ctrl-f:preview-half-page-down",
    preview_half_page_up = "--bind=ctrl-b:preview-half-page-up",
    no_multi = "--no-multi",
    lsp_preview_window = { "--preview-window", "left,65%,+{2}-/2" },
}

local default_git_log_pretty =
    "%C(yellow)%h %C(cyan)%cd %C(green)%aN%C(auto)%d %Creset%s"

-- files {

-- fd
-- "fd . -cnever -tf -tl -L -i"
local default_restricted_fd = {
    constants.fd,
    ".",
    "-cnever",
    "-tf",
    "-tl",
    "-L",
    "-i",
}
-- "fd . -cnever -tf -tl -L -i -u"
local default_unrestricted_fd = {
    constants.fd,
    ".",
    "-cnever",
    "-tf",
    "-tl",
    "-L",
    "-i",
    "-u",
}
-- find
-- 'find -L . -type f -not -path "*/.*"'
local default_restricted_find = constants.is_windows
        and {
            constants.find,
            "-L",
            ".",
            "-type",
            "f",
        }
    or {
        constants.find,
        "-L",
        ".",
        "-type",
        "f",
        "-not",
        "-path",
        [[*/.*]],
    }
-- "find -L . -type f"
local default_unrestricted_find = {
    constants.find,
    "-L",
    ".",
    "-type",
    "f",
}

--- @param filename string
--- @param lineno integer?
--- @return fun():string[]
local function make_file_previewer(filename, lineno)
    --- @return string[]
    local function wrap()
        if constants.has_bat then
            local style = "numbers,changes"
            if
                type(vim.env["BAT_STYLE"]) == "string"
                and string.len(vim.env["BAT_STYLE"]) > 0
            then
                style = vim.env["BAT_STYLE"]
            end
            local theme = "base16"
            if
                type(vim.env["BAT_THEME"]) == "string"
                and string.len(vim.env["BAT_THEME"]) > 0
            then
                theme = vim.env["BAT_THEME"]
            end
            -- "%s --style=%s --theme=%s --color=always --pager=never --highlight-line=%s -- %s"
            return type(lineno) == "number"
                    and {
                        constants.bat,
                        "--style=" .. style,
                        "--theme=" .. theme,
                        "--color=always",
                        "--pager=never",
                        "--highlight-line=" .. lineno,
                        "--",
                        filename,
                    }
                or {
                    constants.bat,
                    "--style=" .. style,
                    "--theme=" .. theme,
                    "--color=always",
                    "--pager=never",
                    "--",
                    filename,
                }
        else
            -- "cat %s"
            return {
                "cat",
                filename,
            }
        end
    end
    return wrap
end

--- @param line string
--- @return string[]
local function file_previewer(line)
    local filename = line_helpers.parse_find(line)
    local impl = make_file_previewer(filename)
    return impl()
end

-- files }

-- live grep {

-- rg
-- "rg --column -n --no-heading --color=always -S"
local default_restricted_rg = {
    "rg",
    "--column",
    "-n",
    "--no-heading",
    "--color=always",
    "-S",
}
-- "rg --column -n --no-heading --color=always -S -uu"
local default_unrestricted_rg = {
    "rg",
    "--column",
    "-n",
    "--no-heading",
    "--color=always",
    "-S",
    "-uu",
}

-- grep
-- "grep --color=always -n -H -r --exclude-dir='.*' --exclude='.*'"
local default_restricted_grep = {
    constants.grep,
    "--color=always",
    "-n",
    "-H",
    "-r",
    "--exclude-dir=" .. (constants.has_gnu_grep and [[.*]] or [[./.*]]),
    "--exclude=" .. (constants.has_gnu_grep and [[.*]] or [[./.*]]),
}
-- "grep --color=always -n -H -r"
local default_unrestricted_grep = {
    constants.grep,
    "--color=always",
    "-n",
    "-H",
    "-r",
}

--- @param query string
--- @param unrestricted boolean
--- @return string[]|nil
local function live_grep_provider(query, unrestricted)
    local parsed_query = utils.parse_flag_query(query or "")
    local content = parsed_query[1]
    local option = parsed_query[2]

    local args = nil
    if vim.fn.executable("rg") > 0 then
        args = unrestricted and vim.deepcopy(default_unrestricted_rg)
            or vim.deepcopy(default_restricted_rg)
    elseif vim.fn.executable("grep") > 0 or vim.fn.executable("ggrep") > 0 then
        args = unrestricted and vim.deepcopy(default_unrestricted_grep)
            or vim.deepcopy(default_restricted_grep)
    else
        log.echo(LogLevels.INFO, "no rg/grep command found.")
        return nil
    end
    if type(option) == "string" and string.len(option) > 0 then
        local option_splits = utils.string_split(option, " ")
        for _, o in ipairs(option_splits) do
            if type(o) == "string" and string.len(o) > 0 then
                table.insert(args, o)
            end
        end
    end
    table.insert(args, "--")
    table.insert(args, content)
    return args
end

--- @param line string
--- @return string[]
local function file_previewer_grep(line)
    local parsed = line_helpers.parse_grep(line)
    local impl = make_file_previewer(parsed.filename, parsed.lineno)
    return impl()
end

-- }

-- lsp diagnostics {

--- @alias LspDiagnosticOpts {mode:"buffer_diagnostics"|"workspace_diagnostics",severity:integer?,bufnr:integer?}
--- @param opts LspDiagnosticOpts
--- @return string[]?
local function lsp_diagnostics_provider(opts)
    local active_lsp_clients = vim.lsp.get_active_clients()
    if active_lsp_clients == nil or vim.tbl_isempty(active_lsp_clients) then
        log.echo(LogLevels.INFO, "no active lsp clients.")
        return nil
    end
    local signs = {
        [1] = {
            severity = 1,
            text = env.icon_enable() and "" or "E", -- nf-fa-times \uf00d
            texthl = vim.fn.hlexists("DiagnosticSignError") > 0
                    and "DiagnosticSignError"
                or (
                    vim.fn.hlexists("LspDiagnosticsSignError") > 0
                        and "LspDiagnosticsSignError"
                    or "ErrorMsg"
                ),
            textcolor = "red",
        },
        [2] = {
            severity = 2,
            text = env.icon_enable() and "" or "W", -- nf-fa-warning \uf071
            texthl = vim.fn.hlexists("DiagnosticSignWarn") > 0
                    and "DiagnosticSignWarn"
                or (
                    vim.fn.hlexists("LspDiagnosticsSignWarn") > 0
                        and "LspDiagnosticsSignWarn"
                    or "WarningMsg"
                ),
            textcolor = "orange",
        },
        [3] = {
            severity = 3,
            text = env.icon_enable() and "" or "I", -- nf-fa-info_circle \uf05a
            texthl = vim.fn.hlexists("DiagnosticSignInfo") > 0
                    and "DiagnosticSignInfo"
                or (
                    vim.fn.hlexists("LspDiagnosticsSignInfo") > 0
                        and "LspDiagnosticsSignInfo"
                    or "None"
                ),
            textcolor = "teal",
        },
        [4] = {
            severity = 4,
            text = env.icon_enable() and "" or "H", -- nf-fa-bell \uf0f3
            texthl = vim.fn.hlexists("DiagnosticSignHint") > 0
                    and "DiagnosticSignHint"
                or (
                    vim.fn.hlexists("LspDiagnosticsSignHint") > 0
                        and "LspDiagnosticsSignHint"
                    or "Comment"
                ),
            textcolor = "grey",
        },
    }
    for _, sign_opts in pairs(signs) do
        local sign_def = vim.fn.sign_getdefined(sign_opts.sign)
        if type(sign_def) == "table" and not vim.tbl_isempty(sign_def) then
            sign_opts.text = sign_def[1].text
            sign_opts.texthl = sign_def[1].texthl
        end
    end

    local diag_results = vim.diagnostic.get(
        opts.mode == "buffer_diagnostics" and opts.bufnr or nil
    )
    -- descending: error, warn, info, hint
    table.sort(diag_results, function(a, b)
        return a.severity < b.severity
    end)
    if diag_results == nil or vim.tbl_isempty(diag_results) then
        log.echo(LogLevels.INFO, "no lsp diagnostics found.")
        return nil
    end

    --- @alias DiagItem {bufnr:integer,filename:string,lnum:integer,col:integer,text:string,severity:integer}
    --- @return DiagItem?
    local function process_diagnostic_item(diag)
        if not vim.api.nvim_buf_is_valid(diag.bufnr) then
            return nil
        end
        log.debug(
            "|fzfx.config - lsp_diagnostics_provider.process_diagnostic_item| diag-1:%s",
            vim.inspect(diag)
        )
        local result = {
            bufnr = diag.bufnr,
            filename = path.reduce(vim.api.nvim_buf_get_name(diag.bufnr)),
            lnum = diag.lnum + 1,
            col = diag.col + 1,
            text = vim.trim(diag.message:gsub("\n", " ")),
            severity = diag.severity or 1,
        }
        log.debug(
            "|fzfx.config - lsp_diagnostics_provider.process_diagnostic_item| diag-2:%s, result:%s",
            vim.inspect(diag),
            vim.inspect(result)
        )
        return result
    end

    -- simulate rg's filepath color, see:
    -- * https://github.com/BurntSushi/ripgrep/discussions/2605#discussioncomment-6881383
    -- * https://github.com/BurntSushi/ripgrep/blob/d596f6ebd035560ee5706f7c0299c4692f112e54/crates/printer/src/color.rs#L14
    local filepath_color = constants.is_windows and color.cyan or color.magenta

    local diag_lines = {}
    for _, diag in ipairs(diag_results) do
        local d = process_diagnostic_item(diag)
        if d then
            -- it looks like:
            -- `lua/fzfx/config.lua:10:13: Unused local `query`.
            log.debug(
                "|fzfx.config - lsp_diagnostics_provider| d:%s",
                vim.inspect(d)
            )
            local dtext = ""
            if type(d.text) == "string" and string.len(d.text) > 0 then
                if type(signs[d.severity]) == "table" then
                    local sign_def = signs[d.severity]
                    local icon_color = color[sign_def.textcolor]
                    dtext = " " .. icon_color(sign_def.text, sign_def.texthl)
                end
                dtext = dtext .. " " .. d.text
            end
            log.debug(
                "|fzfx.config - lsp_diagnostics_provider| d:%s, dtext:%s",
                vim.inspect(d),
                vim.inspect(dtext)
            )
            local line = string.format(
                "%s:%s:%s:%s",
                filepath_color(d.filename),
                color.green(tostring(d.lnum)),
                tostring(d.col),
                dtext
            )
            table.insert(diag_lines, line)
        end
    end
    return diag_lines
end

-- lsp diagnostics }

-- lsp locations {

--- @alias LspLocationRangeStart {line:integer,character:integer}
--- @alias LspLocationRangeEnd {line:integer,character:integer}
--- @alias LspLocationRange {start:LspLocationRangeStart,end:LspLocationRangeEnd}
--- @alias LspLocation {uri:string,range:LspLocationRange}
--- @alias LspLocationLink {originSelectionRange:LspLocationRange,targetUri:string,targetRange:LspLocationRange,targetSelectionRange:LspLocationRange}

--- @param r LspLocationRange?
--- @return boolean
local function is_lsp_range(r)
    return type(r) == "table"
        and type(r.start) == "table"
        and type(r.start.line) == "number"
        and type(r.start.character) == "number"
        and type(r["end"]) == "table"
        and type(r["end"].line) == "number"
        and type(r["end"].character) == "number"
end

--- @param loc LspLocation|LspLocationLink|nil
local function is_lsp_location(loc)
    return type(loc) == "table"
        and type(loc.uri) == "string"
        and is_lsp_range(loc.range)
end

--- @param loc LspLocation|LspLocationLink|nil
local function is_lsp_locationlink(loc)
    return type(loc) == "table"
        and type(loc.targetUri) == "string"
        and is_lsp_range(loc.originSelectionRange)
        and is_lsp_range(loc.targetRange)
        and is_lsp_range(loc.targetSelectionRange)
end

--- @param line string
--- @param range LspLocationRange
--- @param color_renderer fun(text:string):string
--- @return string?
local function lsp_location_render_line(line, range, color_renderer)
    log.debug(
        "|fzfx.config - lsp_location_render_line| range:%s, line:%s",
        vim.inspect(range),
        vim.inspect(line)
    )
    local line_start = range.start.character + 1
    local line_end = range["end"].line ~= range.start.line and #line
        or math.min(range["end"].character, #line)
    local p1 = ""
    if line_start > 1 then
        p1 = line:sub(1, line_start - 1)
    end
    local p2 = ""
    if line_start <= line_end then
        p2 = color_renderer(line:sub(line_start, line_end))
    end
    local p3 = ""
    if line_end + 1 <= #line then
        p3 = line:sub(line_end + 1, #line)
    end
    local result = p1 .. p2 .. p3
    return result
end

--- @alias LspLocationPipelineContext {bufnr:integer,winnr:integer,tabnr:integer,position_params:any}
--- @return LspLocationPipelineContext
local function lsp_position_context_maker()
    local context = {
        bufnr = vim.api.nvim_get_current_buf(),
        winnr = vim.api.nvim_get_current_win(),
        tabnr = vim.api.nvim_get_current_tabpage(),
    }
    context.position_params =
        vim.lsp.util.make_position_params(context.winnr, nil)
    context.position_params.context = {
        includeDeclaration = true,
    }
    return context
end

--- @alias LspMethod "textDocument/definition"|"textDocument/type_definition"|"textDocument/references"|"textDocument/implementation"
--- @alias LspServerCapability "definitionProvider"|"typeDefinitionProvider"|"referencesProvider"|"implementationProvider"

--- @alias LspDefinitionOpts {method:LspMethod,capability:LspServerCapability,bufnr:integer,timeout:integer?,position_params:any?}
--- @param opts LspDefinitionOpts
--- @return string[]?
local function lsp_locations_provider(opts)
    local lsp_clients = vim.lsp.get_active_clients({ bufnr = opts.bufnr })
    if lsp_clients == nil or vim.tbl_isempty(lsp_clients) then
        log.echo(LogLevels.INFO, "no active lsp clients.")
        return nil
    end
    log.debug(
        "|fzfx.config - lsp_locations_provider| lsp_clients:%s",
        vim.inspect(lsp_clients)
    )
    local method_support = false
    for _, lsp_client in ipairs(lsp_clients) do
        if lsp_client.server_capabilities[opts.capability] then
            method_support = true
            break
        end
    end
    if not method_support then
        log.echo(
            LogLevels.INFO,
            string.format("method %s not supported.", vim.inspect(opts.method))
        )
        return nil
    end
    local lsp_results, lsp_err = vim.lsp.buf_request_sync(
        opts.bufnr,
        opts.method,
        opts.position_params,
        opts.timeout or 3000
    )
    log.debug(
        "|fzfx.config - lsp_locations_provider| opts:%s, lsp_results:%s, lsp_err:%s",
        vim.inspect(opts),
        vim.inspect(lsp_results),
        vim.inspect(lsp_err)
    )
    if lsp_err then
        log.echo(LogLevels.ERROR, lsp_err)
        return nil
    end
    if type(lsp_results) ~= "table" then
        log.echo(LogLevels.INFO, "no lsp definitions found.")
        return nil
    end

    local filepath_color = constants.is_windows and color.cyan or color.magenta

    --- @param loc LspLocation|LspLocationLink
    --- @return string?
    local function process_location(loc)
        --- @type string
        local filename = nil
        --- @type LspLocationRange
        local range = nil
        log.debug(
            "|fzfx.config - lsp_locations_provider.process_location| loc:%s",
            vim.inspect(loc)
        )
        if is_lsp_location(loc) then
            filename = path.reduce(vim.uri_to_fname(loc.uri))
            range = loc.range
            log.debug(
                "|fzfx.config - lsp_locations_provider.process_location| location filename:%s, range:%s",
                vim.inspect(filename),
                vim.inspect(range)
            )
        end
        if is_lsp_locationlink(loc) then
            filename = path.reduce(vim.uri_to_fname(loc.targetUri))
            range = loc.targetRange
            log.debug(
                "|fzfx.config - lsp_locations_provider.process_location| locationlink filename:%s, range:%s",
                vim.inspect(filename),
                vim.inspect(range)
            )
        end
        if not is_lsp_range(range) then
            return nil
        end
        if type(filename) ~= "string" or vim.fn.filereadable(filename) <= 0 then
            return nil
        end
        local filelines = utils.readlines(filename)
        if type(filelines) ~= "table" or #filelines < range.start.line + 1 then
            return nil
        end
        local loc_line = lsp_location_render_line(
            filelines[range.start.line + 1],
            range,
            color.red
        )
        log.debug(
            "|fzfx.config - lsp_locations_provider.process_location| range:%s, loc_line:%s",
            vim.inspect(range),
            vim.inspect(loc_line)
        )
        local line = string.format(
            "%s:%s:%s:%s",
            filepath_color(vim.fn.fnamemodify(filename, ":~:.")),
            color.green(tostring(range.start.line + 1)),
            tostring(range.start.character + 1),
            loc_line
        )
        log.debug(
            "|fzfx.config - lsp_locations_provider| line:%s",
            vim.inspect(line)
        )
        return line
    end

    local def_lines = {}

    for client_id, lsp_result in pairs(lsp_results) do
        if
            client_id == nil
            or type(lsp_result) ~= "table"
            or type(lsp_result.result) ~= "table"
        then
            break
        end
        local lsp_defs = lsp_result.result
        if is_lsp_location(lsp_defs) then
            local line = process_location(lsp_defs)
            if type(line) == "string" and string.len(line) > 0 then
                table.insert(def_lines, line)
            end
        else
            for _, def in ipairs(lsp_defs) do
                local line = process_location(def)
                if type(line) == "string" and string.len(line) > 0 then
                    table.insert(def_lines, line)
                end
            end
        end
    end

    if def_lines == nil or vim.tbl_isempty(def_lines) then
        log.echo(LogLevels.INFO, "no lsp definitions found.")
        return nil
    end

    return def_lines
end

-- lsp locations }

-- file explorer {

--- @alias FileExplorerPipelineContext {bufnr:integer,winnr:integer,tabnr:integer,cwd:string}
--- @return FileExplorerPipelineContext
local function file_explorer_context_maker()
    local temp = vim.fn.tempname()
    utils.writefile(temp, vim.fn.getcwd())
    local context = {
        bufnr = vim.api.nvim_get_current_buf(),
        winnr = vim.api.nvim_get_current_win(),
        tabnr = vim.api.nvim_get_current_tabpage(),
        cwd = temp,
    }
    return context
end

--- @param ls_args "-lh"|"-lha"
--- @return fun(query:string,context:PipelineContext):string?
local function make_file_explorer_provider(ls_args)
    --- @param query string
    --- @param context FileExplorerPipelineContext
    --- @return string?
    local function wrap(query, context)
        local cwd = utils.readfile(context.cwd)
        if constants.has_eza then
            return vim.fn.executable("echo") > 0
                    and string.format(
                        "echo %s && %s --color=always %s -- %s",
                        utils.shellescape(cwd --[[@as string]]),
                        constants.eza,
                        ls_args,
                        utils.shellescape(cwd --[[@as string]])
                    )
                or string.format(
                    "%s --color=always %s -- %s",
                    constants.eza,
                    ls_args,
                    utils.shellescape(cwd --[[@as string]])
                )
        elseif vim.fn.executable("ls") > 0 then
            return vim.fn.executable("echo") > 0
                    and string.format(
                        "echo %s && ls --color=always %s %s",
                        utils.shellescape(cwd --[[@as string]]),
                        ls_args,
                        utils.shellescape(cwd --[[@as string]])
                    )
                or string.format(
                    "ls --color=always %s %s",
                    ls_args,
                    utils.shellescape(cwd --[[@as string]])
                )
        else
            log.echo(LogLevels.INFO, "no ls/eza/exa command found.")
            return nil
        end
    end

    return wrap
end

--- @param filename string
--- @return string[]|nil
local function directory_previewer(filename)
    if constants.has_eza then
        return {
            constants.eza,
            "--color=always",
            "-lha",
            "--",
            filename,
        }
    elseif vim.fn.executable("ls") > 0 then
        return { "ls", "--color=always", "-lha", "--", filename }
    else
        log.echo(LogLevels.INFO, "no ls/eza/exa command found.")
        return nil
    end
end

--- @param line string
--- @param context FileExplorerPipelineContext
--- @return string
local function make_filename_by_file_explorer_context(line, context)
    line = vim.trim(line)
    local cwd = utils.readfile(context.cwd)
    local target = constants.has_eza and line_helpers.parse_eza(line)
        or line_helpers.parse_ls(line)
    if
        (
            utils.string_startswith(target, "'")
            and utils.string_endswith(target, "'")
        )
        or (
            utils.string_startswith(target, '"')
            and utils.string_endswith(target, '"')
        )
    then
        target = target:sub(2, #target - 1)
    end
    local p = path.join(cwd, target)
    log.debug(
        "|fzfx.config - make_filename_by_file_explorer_context| cwd:%s, target:%s, p:%s",
        vim.inspect(cwd),
        vim.inspect(target),
        vim.inspect(p)
    )
    return p
end

--- @param line string
--- @param context FileExplorerPipelineContext
--- @return string[]|nil
local function file_explorer_previewer(line, context)
    local p = make_filename_by_file_explorer_context(line, context)
    if vim.fn.filereadable(p) > 0 then
        local preview = make_file_previewer(p)
        return preview()
    elseif vim.fn.isdirectory(p) > 0 then
        return directory_previewer(p)
    else
        return nil
    end
end

--- @param lines string[]
--- @param context FileExplorerPipelineContext
--- @return any
local function edit_file_explorer(lines, context)
    local fullpath_lines = {}
    for _, line in ipairs(lines) do
        local p = make_filename_by_file_explorer_context(line, context)
        table.insert(fullpath_lines, p)
    end
    log.debug(
        "|fzfx.config - file_explorer.actions| full_lines:%s",
        vim.inspect(fullpath_lines)
    )
    return require("fzfx.actions").edit_ls(fullpath_lines)
end

-- file explorer }

--- @alias Options table<string, any>
--- @type Options
local Defaults = {
    -- the 'Files' commands
    --- @type GroupConfig
    files = {
        commands = {
            -- normal
            {
                name = "FzfxFiles",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    complete = "dir",
                    desc = "Find files",
                },
                default_provider = "restricted_mode",
            },
            {
                name = "FzfxFilesU",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    complete = "dir",
                    desc = "Find files",
                },
                default_provider = "unrestricted_mode",
            },
            -- visual
            {
                name = "FzfxFilesV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Find files by visual select",
                },
                default_provider = "restricted_mode",
            },
            {
                name = "FzfxFilesUV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Find files unrestricted by visual select",
                },
                default_provider = "unrestricted_mode",
            },
            -- cword
            {
                name = "FzfxFilesW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Find files by cursor word",
                },
                default_provider = "restricted_mode",
            },
            {
                name = "FzfxFilesUW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Find files unrestricted by cursor word",
                },
                default_provider = "unrestricted_mode",
            },
            -- put
            {
                name = "FzfxFilesP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Find files by yank text",
                },
                default_provider = "restricted_mode",
            },
            {
                name = "FzfxFilesUP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Find files unrestricted by yank text",
                },
                default_provider = "unrestricted_mode",
            },
        },
        providers = {
            restricted_mode = {
                key = "ctrl-r",
                provider = constants.has_fd and default_restricted_fd
                    or default_restricted_find,
                line_opts = { prepend_icon_by_ft = true },
            },
            unrestricted_mode = {
                key = "ctrl-u",
                provider = constants.has_fd and default_unrestricted_fd
                    or default_unrestricted_find,
                line_opts = { prepend_icon_by_ft = true },
            },
        },
        previewers = {
            restricted_mode = {
                previewer = file_previewer,
                previewer_type = PreviewerTypeEnum.COMMAND_LIST,
            },
            unrestricted_mode = {
                previewer = file_previewer,
                previewer_type = PreviewerTypeEnum.COMMAND_LIST,
            },
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = require("fzfx.actions").edit_find,
            ["double-click"] = require("fzfx.actions").edit_find,
        },
        fzf_opts = {
            default_fzf_options.multi,
            function()
                return {
                    "--prompt",
                    path.shorten() .. " > ",
                }
            end,
        },
    },

    -- the 'Live Grep' commands
    --- @type GroupConfig
    live_grep = {
        commands = {
            -- normal
            {
                name = "FzfxLiveGrep",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "*",
                    desc = "Live grep",
                },
                default_provider = "restricted_mode",
            },
            {
                name = "FzfxLiveGrepU",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "*",
                    desc = "Live grep unrestricted",
                },
                default_provider = "unrestricted_mode",
            },
            -- visual
            {
                name = "FzfxLiveGrepV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Live grep by visual select",
                },
                default_provider = "restricted_mode",
            },
            {
                name = "FzfxLiveGrepUV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Live grep unrestricted by visual select",
                },
                default_provider = "unrestricted_mode",
            },
            -- cword
            {
                name = "FzfxLiveGrepW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Live grep by cursor word",
                },
                default_provider = "restricted_mode",
            },
            {
                name = "FzfxLiveGrepUW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Live grep unrestricted by cursor word",
                },
                default_provider = "unrestricted_mode",
            },
            -- put
            {
                name = "FzfxLiveGrepP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Live grep by yank text",
                },
                default_provider = "restricted_mode",
            },
            {
                name = "FzfxLiveGrepUP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Live grep unrestricted by yank text",
                },
                default_provider = "unrestricted_mode",
            },
        },
        providers = {
            restricted_mode = {
                key = "ctrl-r",
                provider = function(query)
                    return live_grep_provider(query, false)
                end,
                provider_type = ProviderTypeEnum.COMMAND_LIST,
                line_opts = {
                    prepend_icon_by_ft = true,
                    prepend_icon_path_delimiter = ":",
                    prepend_icon_path_position = 1,
                },
            },
            unrestricted_mode = {
                key = "ctrl-u",
                provider = function(query)
                    return live_grep_provider(query, true)
                end,
                provider_type = ProviderTypeEnum.COMMAND_LIST,
                line_opts = {
                    prepend_icon_by_ft = true,
                    prepend_icon_path_delimiter = ":",
                    prepend_icon_path_position = 1,
                },
            },
        },
        previewers = {
            restricted_mode = {
                previewer = file_previewer_grep,
                previewer_type = PreviewerTypeEnum.COMMAND_LIST,
            },
            unrestricted_mode = {
                previewer = file_previewer_grep,
                previewer_type = PreviewerTypeEnum.COMMAND_LIST,
            },
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = constants.has_rg and require("fzfx.actions").edit_rg
                or require("fzfx.actions").edit_grep,
            ["double-click"] = constants.has_rg
                    and require("fzfx.actions").edit_rg
                or require("fzfx.actions").edit_grep,
        },
        fzf_opts = {
            default_fzf_options.multi,
            "--disabled",
            { "--prompt", "Live Grep > " },
            { "--delimiter", ":" },
            { "--preview-window", "+{2}-/2" },
        },
        other_opts = {
            reload_on_change = true,
        },
    },

    -- the 'Buffers' commands
    --- @type GroupConfig
    buffers = {
        commands = {
            -- normal
            {
                name = "FzfxBuffers",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    complete = "file",
                    desc = "Find buffers",
                },
            },
            -- visual
            {
                name = "FzfxBuffersV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Find buffers by visual select",
                },
            },
            -- cword
            {
                name = "FzfxBuffersW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Find buffers by cursor word",
                },
            },
            -- put
            {
                name = "FzfxBuffersP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Find buffers by yank text",
                },
            },
        },
        providers = {
            key = "default",
            provider = function(query, context)
                local function valid_bufnr(b)
                    local exclude_filetypes = {
                        ["qf"] = true,
                        ["neo-tree"] = true,
                    }
                    local ft = utils.get_buf_option(b, "filetype")
                    return utils.is_buf_valid(b) and not exclude_filetypes[ft]
                end
                local bufnrs_list = vim.api.nvim_list_bufs()
                local bufpaths_list = {}
                local current_bufpath = valid_bufnr(context.bufnr)
                        and path.reduce(
                            vim.api.nvim_buf_get_name(context.bufnr)
                        )
                    or nil
                if
                    type(current_bufpath) == "string"
                    and string.len(current_bufpath) > 0
                then
                    table.insert(bufpaths_list, current_bufpath)
                end
                for _, bn in ipairs(bufnrs_list) do
                    local bp = path.reduce(vim.api.nvim_buf_get_name(bn))
                    if valid_bufnr(bn) and bp ~= current_bufpath then
                        table.insert(bufpaths_list, bp)
                    end
                end
                return bufpaths_list
            end,
            provider_type = ProviderTypeEnum.LIST,
            line_opts = { prepend_icon_by_ft = true },
        },
        previewers = {
            previewer = file_previewer,
            previewer_type = PreviewerTypeEnum.COMMAND_LIST,
        },
        interactions = {
            delete_buffer = {
                key = "ctrl-d",
                interaction = require("fzfx.actions").bdelete,
                reload_after_execute = true,
            },
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = require("fzfx.actions").edit_find,
            ["double-click"] = require("fzfx.actions").edit_find,
        },
        fzf_opts = {
            default_fzf_options.multi,
            {
                "--prompt",
                "Buffers > ",
            },
            function()
                local current_bufnr = vim.api.nvim_get_current_buf()
                return utils.is_buf_valid(current_bufnr) and "--header-lines=1"
                    or nil
            end,
        },
    },

    -- the 'Git Files' commands
    --- @type GroupConfig
    git_files = {
        commands = {
            -- normal
            {
                name = "FzfxGFiles",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    complete = "dir",
                    desc = "Find git files",
                },
                default_provider = "workspace",
            },
            {
                name = "FzfxGFilesC",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    complete = "dir",
                    desc = "Find git files in current directory",
                },
                default_provider = "current_folder",
            },
            -- visual
            {
                name = "FzfxGFilesV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Find git files by visual select",
                },
                default_provider = "workspace",
            },
            {
                name = "FzfxGFilesCV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Find git files in current directory by visual select",
                },
                default_provider = "current_folder",
            },
            -- cword
            {
                name = "FzfxGFilesW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Find git files by cursor word",
                },
                default_provider = "workspace",
            },
            {
                name = "FzfxGFilesCW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Find git files in current directory by cursor word",
                },
                default_provider = "current_folder",
            },
            -- put
            {
                name = "FzfxGFilesP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Find git files by yank text",
                },
                default_provider = "workspace",
            },
            {
                name = "FzfxGFilesCP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Find git files in current directory by yank text",
                },
                default_provider = "current_folder",
            },
        },
        providers = {
            current_folder = {
                key = "ctrl-u",
                provider = { "git", "ls-files" },
                line_opts = { prepend_icon_by_ft = true },
            },
            workspace = {
                key = "ctrl-w",
                provider = { "git", "ls-files", ":/" },
                line_opts = { prepend_icon_by_ft = true },
            },
        },
        previewers = {
            current_folder = {
                previewer = file_previewer,
                previewer_type = PreviewerTypeEnum.COMMAND_LIST,
            },
            workspace = {
                previewer = file_previewer,
                previewer_type = PreviewerTypeEnum.COMMAND_LIST,
            },
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = require("fzfx.actions").edit_find,
            ["double-click"] = require("fzfx.actions").edit_find,
        },
        fzf_opts = {
            default_fzf_options.multi,
            function()
                return {
                    "--prompt",
                    path.shorten() .. " > ",
                }
            end,
        },
    },

    -- the 'Git Branches' commands
    --- @type GroupConfig
    git_branches = {
        commands = {
            -- normal
            {
                name = "FzfxGBranches",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    complete = "dir",
                    desc = "Search local git branches",
                },
                default_provider = "local_branch",
            },
            {
                name = "FzfxGBranchesR",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    complete = "dir",
                    desc = "Search remote git branches",
                },
                default_provider = "remote_branch",
            },
            -- visual
            {
                name = "FzfxGBranchesV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Search local git branches by visual select",
                },
                default_provider = "local_branch",
            },
            {
                name = "FzfxGBranchesRV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Search remote git branches by visual select",
                },
                default_provider = "remote_branch",
            },
            -- cword
            {
                name = "FzfxGBranchesW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Search local git branches by cursor word",
                },
                default_provider = "local_branch",
            },
            {
                name = "FzfxGBranchesRW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Search remote git branches by cursor word",
                },
                default_provider = "remote_branch",
            },
            -- put
            {
                name = "FzfxGBranchesP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Search local git branches by yank text",
                },
                default_provider = "local_branch",
            },
            {
                name = "FzfxGBranchesRP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Search remote git branches by yank text",
                },
                default_provider = "remote_branch",
            },
        },
        providers = {
            local_branch = {
                key = "ctrl-o",
                provider = function(query, context)
                    local cmd = require("fzfx.cmd")
                    local git_root_cmd = cmd.GitRootCmd:run()
                    if git_root_cmd:wrong() then
                        log.echo(LogLevels.INFO, "not in git repo.")
                        return nil
                    end
                    local git_current_branch_cmd = cmd.GitCurrentBranchCmd:run()
                    if git_current_branch_cmd:wrong() then
                        log.echo(
                            LogLevels.WARN,
                            table.concat(
                                git_current_branch_cmd.result.stderr,
                                " "
                            )
                        )
                        return nil
                    end
                    local branch_results = {}
                    table.insert(
                        branch_results,
                        string.format("* %s", git_current_branch_cmd:value())
                    )
                    local git_branch_cmd = cmd.Cmd:run("git branch")
                    if git_branch_cmd.result:wrong() then
                        log.echo(
                            LogLevels.WARN,
                            table.concat(
                                git_current_branch_cmd.result.stderr,
                                " "
                            )
                        )
                        return nil
                    end
                    for _, line in ipairs(git_branch_cmd.result.stdout) do
                        if vim.trim(line):sub(1, 1) ~= "*" then
                            table.insert(
                                branch_results,
                                string.format("  %s", vim.trim(line))
                            )
                        end
                    end

                    return branch_results
                end,
                provider_type = ProviderTypeEnum.LIST,
            },
            remote_branch = {
                key = "ctrl-r",
                provider = function(query, context)
                    local cmd = require("fzfx.cmd")
                    local git_root_cmd = cmd.GitRootCmd:run()
                    if git_root_cmd:wrong() then
                        log.echo(LogLevels.INFO, "not in git repo.")
                        return nil
                    end
                    local git_current_branch_cmd = cmd.GitCurrentBranchCmd:run()
                    if git_current_branch_cmd:wrong() then
                        log.echo(
                            LogLevels.WARN,
                            table.concat(
                                git_current_branch_cmd.result.stderr,
                                " "
                            )
                        )
                        return nil
                    end
                    local branch_results = {}
                    table.insert(
                        branch_results,
                        string.format("* %s", git_current_branch_cmd:value())
                    )
                    local git_branch_cmd = cmd.Cmd:run("git branch --remotes")
                    if git_branch_cmd.result:wrong() then
                        log.echo(
                            LogLevels.WARN,
                            table.concat(
                                git_current_branch_cmd.result.stderr,
                                " "
                            )
                        )
                        return nil
                    end
                    for _, line in ipairs(git_branch_cmd.result.stdout) do
                        if vim.trim(line):sub(1, 1) ~= "*" then
                            table.insert(
                                branch_results,
                                string.format("  %s", vim.trim(line))
                            )
                        end
                    end

                    return branch_results
                end,
                provider_type = ProviderTypeEnum.LIST,
            },
        },
        previewers = {
            local_branch = {
                previewer = function(line)
                    local branch = vim.fn.split(line)[1]
                    -- "git log --graph --date=short --color=always --pretty='%C(auto)%cd %h%d %s'",
                    -- "git log --graph --color=always --date=relative",
                    return string.format(
                        "git log --pretty=%s --graph --date=short --color=always %s",
                        utils.shellescape(default_git_log_pretty),
                        branch
                    )
                end,
            },
            remote_branch = {
                previewer = function(line)
                    local branch = vim.fn.split(line)[1]
                    return string.format(
                        "git log --pretty=%s --graph --date=short --color=always %s",
                        utils.shellescape(default_git_log_pretty),
                        branch
                    )
                end,
            },
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = require("fzfx.actions").git_checkout,
            ["double-click"] = require("fzfx.actions").git_checkout,
        },
        fzf_opts = {
            default_fzf_options.no_multi,
            {
                "--prompt",
                "GBranches > ",
            },
            function()
                local cmd = require("fzfx.cmd")
                local git_root_cmd = cmd.GitRootCmd:run()
                if git_root_cmd:wrong() then
                    return nil
                end
                local git_current_branch_cmd = cmd.GitCurrentBranchCmd:run()
                if git_current_branch_cmd:wrong() then
                    return nil
                end
                return utils.string_not_empty(git_current_branch_cmd:value())
                        and "--header-lines=1"
                    or nil
            end,
        },
    },

    -- the 'Git Commits' commands
    --- @type GroupConfig
    git_commits = {
        commands = {
            -- normal
            {
                name = "FzfxGCommits",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    desc = "Search git commits",
                },
                default_provider = "all_commits",
            },
            {
                name = "FzfxGCommitsB",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    desc = "Search git commits only on current buffer",
                },
                default_provider = "buffer_commits",
            },
            -- visual
            {
                name = "FzfxGCommitsV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Search git commits by visual select",
                },
                default_provider = "all_commits",
            },
            {
                name = "FzfxGCommitsBV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Search git commits only on current buffer by visual select",
                },
                default_provider = "buffer_commits",
            },
            -- cword
            {
                name = "FzfxGCommitsW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Search git commits by cursor word",
                },
                default_provider = "all_commits",
            },
            {
                name = "FzfxGCommitsBW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Search git commits only on current buffer by cursor word",
                },
                default_provider = "buffer_commits",
            },
            -- put
            {
                name = "FzfxGCommitsP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Search git commits by yank text",
                },
                default_provider = "all_commits",
            },
            {
                name = "FzfxGCommitsBP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Search git commits only on current buffer by yank text",
                },
                default_provider = "buffer_commits",
            },
        },
        providers = {
            all_commits = {
                key = "ctrl-a",
                provider = {
                    "git",
                    "log",
                    "--pretty=" .. default_git_log_pretty,
                    "--date=short",
                    "--color=always",
                },
            },
            buffer_commits = {
                key = "ctrl-u",
                provider = function(query, context)
                    if not utils.is_buf_valid(context.bufnr) then
                        log.echo(
                            LogLevels.INFO,
                            "no commits found on invalid buffer (%s).",
                            vim.inspect(context.bufnr)
                        )
                        return nil
                    end
                    -- return string.format(
                    --     "git log --pretty=%s --date=short --color=always -- %s",
                    --     utils.shellescape(default_git_log_pretty),
                    --     vim.api.nvim_buf_get_name(context.bufnr)
                    -- )
                    return {
                        "git",
                        "log",
                        "--pretty=" .. default_git_log_pretty,
                        "--date=short",
                        "--color=always",
                        "--",
                        vim.api.nvim_buf_get_name(context.bufnr),
                    }
                end,
                provider_type = ProviderTypeEnum.COMMAND_LIST,
            },
        },
        previewers = {
            all_commits = {
                previewer = function(line)
                    local commit = vim.fn.split(line)[1]
                    return string.format("git show --color=always %s", commit)
                end,
            },
            buffer_commits = {
                previewer = function(line)
                    local commit = vim.fn.split(line)[1]
                    return string.format("git show --color=always %s", commit)
                end,
            },
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = require("fzfx.actions").yank_git_commit,
            ["double-click"] = require("fzfx.actions").yank_git_commit,
        },
        fzf_opts = {
            default_fzf_options.no_multi,
            {
                "--prompt",
                "GCommits > ",
            },
        },
    },

    -- the 'Git Blame' command
    --- @type GroupConfig
    git_blame = {
        commands = {
            -- normal
            {
                name = "FzfxGBlame",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    desc = "Search git commits",
                },
            },
            -- visual
            {
                name = "FzfxGBlameV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Search git commits by visual select",
                },
            },
            -- cword
            {
                name = "FzfxGBlameW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Search git commits by cursor word",
                },
            },
            -- put
            {
                name = "FzfxGBlameP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Search git commits by yank text",
                },
            },
        },
        providers = {
            default = {
                key = "default",
                provider = function(query, context)
                    if not utils.is_buf_valid(context.bufnr) then
                        log.echo(
                            LogLevels.INFO,
                            "no commits found on invalid buffer (%s).",
                            vim.inspect(context.bufnr)
                        )
                        return nil
                    end
                    local bufname = vim.api.nvim_buf_get_name(context.bufnr)
                    local bufpath = vim.fn.fnamemodify(bufname, ":~:.")
                    -- return string.format(
                    --     "git blame --date=short --color-lines %s",
                    --     bufpath
                    -- )
                    return {
                        "git",
                        "blame",
                        "--date=short",
                        "--color-lines",
                        bufpath,
                    }
                end,
                provider_type = ProviderTypeEnum.COMMAND_LIST,
            },
        },
        previewers = {
            default = {
                previewer = function(line)
                    local commit = vim.fn.split(line)[1]
                    return string.format("git show --color=always %s", commit)
                end,
            },
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = require("fzfx.actions").yank_git_commit,
            ["double-click"] = require("fzfx.actions").yank_git_commit,
        },
        fzf_opts = {
            default_fzf_options.no_multi,
            {
                "--prompt",
                "GBlame > ",
            },
        },
    },

    -- the 'Lsp Diagnostics' command
    --- @type GroupConfig
    lsp_diagnostics = {
        commands = {
            -- normal
            {
                name = "FzfxLspDiagnostics",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    desc = "Search lsp diagnostics on workspace",
                },
                default_provider = "workspace_diagnostics",
            },
            {
                name = "FzfxLspDiagnosticsB",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    desc = "Search lsp diagnostics on current buffer",
                },
                default_provider = "buffer_diagnostics",
            },
            -- visual
            {
                name = "FzfxLspDiagnosticsV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Search lsp diagnostics on workspace by visual select",
                },
                default_provider = "workspace_diagnostics",
            },
            {
                name = "FzfxLspDiagnosticsBV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "Search lsp diagnostics on current buffer by visual select",
                },
                default_provider = "buffer_diagnostics",
            },
            -- cword
            {
                name = "FzfxLspDiagnosticsW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Search lsp diagnostics on workspace by cursor word",
                },
                default_provider = "workspace_diagnostics",
            },
            {
                name = "FzfxLspDiagnosticsBW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "Search lsp diagnostics on current buffer by cursor word",
                },
                default_provider = "buffer_diagnostics",
            },
            -- put
            {
                name = "FzfxLspDiagnosticsP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Search lsp diagnostics on workspace by yank text",
                },
                default_provider = "workspace_diagnostics",
            },
            {
                name = "FzfxLspDiagnosticsBP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "Search lsp diagnostics on current buffer by yank text",
                },
                default_provider = "buffer_diagnostics",
            },
        },
        providers = {
            workspace_diagnostics = {
                key = "ctrl-w",
                provider = function(query, context)
                    return lsp_diagnostics_provider({
                        mode = "workspace_diagnostics",
                    })
                end,
                provider_type = ProviderTypeEnum.LIST,
                line_opts = {
                    prepend_icon_by_ft = true,
                    prepend_icon_path_delimiter = ":",
                    prepend_icon_path_position = 1,
                },
            },
            buffer_diagnostics = {
                key = "ctrl-u",
                provider = function(query, context)
                    return lsp_diagnostics_provider({
                        mode = "buffer_diagnostics",
                        bufnr = context.bufnr,
                    })
                end,
                provider_type = ProviderTypeEnum.LIST,
                line_opts = {
                    prepend_icon_by_ft = true,
                    prepend_icon_path_delimiter = ":",
                    prepend_icon_path_position = 1,
                },
            },
        },
        previewers = {
            workspace_diagnostics = {
                previewer = file_previewer_grep,
                previewer_type = PreviewerTypeEnum.COMMAND_LIST,
            },
            buffer_diagnostics = {
                previewer = file_previewer_grep,
                previewer_type = PreviewerTypeEnum.COMMAND_LIST,
            },
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = require("fzfx.actions").edit_rg,
            ["double-click"] = require("fzfx.actions").edit_rg,
        },
        fzf_opts = {
            default_fzf_options.multi,
            { "--delimiter", ":" },
            { "--preview-window", "+{2}-/2" },
            {
                "--prompt",
                "Diagnostics > ",
            },
        },
    },

    -- the 'Lsp Definitions' command
    --- @type GroupConfig
    lsp_definitions = {
        commands = {
            name = "FzfxLspDefinitions",
            feed = CommandFeedEnum.ARGS,
            opts = {
                bang = true,
                desc = "Search lsp definitions",
            },
        },
        providers = {
            key = "default",
            --- @param query string
            --- @param context LspLocationPipelineContext
            provider = function(query, context)
                return lsp_locations_provider({
                    method = "textDocument/definition",
                    capability = "definitionProvider",
                    bufnr = context.bufnr,
                    position_params = context.position_params,
                })
            end,
            provider_type = ProviderTypeEnum.LIST,
            line_opts = {
                prepend_icon_by_ft = true,
                prepend_icon_path_delimiter = ":",
                prepend_icon_path_position = 1,
            },
        },
        previewers = {
            previewer = file_previewer_grep,
            previewer_type = PreviewerTypeEnum.COMMAND_LIST,
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = require("fzfx.actions").edit_rg,
            ["double-click"] = require("fzfx.actions").edit_rg,
        },
        fzf_opts = {
            default_fzf_options.multi,
            default_fzf_options.lsp_preview_window,
            "--border=none",
            { "--delimiter", ":" },
            {
                "--prompt",
                "Definitions > ",
            },
        },
        win_opts = {
            relative = "cursor",
            height = 0.45,
            width = 1,
            row = 1,
            col = 0,
            border = "none",
            zindex = 51,
        },
        other_opts = {
            context_maker = lsp_position_context_maker,
        },
    },

    -- the 'Lsp Type Definitions' command
    --- @type GroupConfig
    lsp_type_definitions = {
        commands = {
            name = "FzfxLspTypeDefinitions",
            feed = CommandFeedEnum.ARGS,
            opts = {
                bang = true,
                desc = "Search lsp type definitions",
            },
        },
        providers = {
            key = "default",
            --- @param query string
            --- @param context LspLocationPipelineContext
            provider = function(query, context)
                return lsp_locations_provider({
                    method = "textDocument/type_definition",
                    capability = "typeDefinitionProvider",
                    bufnr = context.bufnr,
                    position_params = context.position_params,
                })
            end,
            provider_type = ProviderTypeEnum.LIST,
            line_opts = {
                prepend_icon_by_ft = true,
                prepend_icon_path_delimiter = ":",
                prepend_icon_path_position = 1,
            },
        },
        previewers = {
            previewer = file_previewer_grep,
            previewer_type = PreviewerTypeEnum.COMMAND_LIST,
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = require("fzfx.actions").edit_rg,
            ["double-click"] = require("fzfx.actions").edit_rg,
        },
        fzf_opts = {
            default_fzf_options.multi,
            default_fzf_options.lsp_preview_window,
            "--border=none",
            { "--delimiter", ":" },
            {
                "--prompt",
                "TypeDefinitions > ",
            },
        },
        win_opts = {
            relative = "cursor",
            height = 0.45,
            width = 1,
            row = 1,
            col = 0,
            border = "none",
            zindex = 51,
        },
        other_opts = {
            context_maker = lsp_position_context_maker,
        },
    },

    -- the 'Lsp References' command
    --- @type GroupConfig
    lsp_references = {
        commands = {
            name = "FzfxLspReferences",
            feed = CommandFeedEnum.ARGS,
            opts = {
                bang = true,
                desc = "Search lsp references",
            },
        },
        providers = {
            key = "default",
            --- @param query string
            --- @param context LspLocationPipelineContext
            provider = function(query, context)
                return lsp_locations_provider({
                    method = "textDocument/references",
                    capability = "referencesProvider",
                    bufnr = context.bufnr,
                    position_params = context.position_params,
                })
            end,
            provider_type = ProviderTypeEnum.LIST,
            line_opts = {
                prepend_icon_by_ft = true,
                prepend_icon_path_delimiter = ":",
                prepend_icon_path_position = 1,
            },
        },
        previewers = {
            previewer = file_previewer_grep,
            previewer_type = PreviewerTypeEnum.COMMAND_LIST,
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = require("fzfx.actions").edit_rg,
            ["double-click"] = require("fzfx.actions").edit_rg,
        },
        fzf_opts = {
            default_fzf_options.multi,
            default_fzf_options.lsp_preview_window,
            "--border=none",
            { "--delimiter", ":" },
            {
                "--prompt",
                "References > ",
            },
        },
        win_opts = {
            relative = "cursor",
            height = 0.45,
            width = 1,
            row = 1,
            col = 0,
            border = "none",
            zindex = 51,
        },
        other_opts = {
            context_maker = lsp_position_context_maker,
        },
    },

    -- the 'Lsp Implementations' command
    --- @type GroupConfig
    lsp_implementations = {
        commands = {
            name = "FzfxLspImplementations",
            feed = CommandFeedEnum.ARGS,
            opts = {
                bang = true,
                desc = "Search lsp implementations",
            },
        },
        providers = {
            key = "default",
            --- @param query string
            --- @param context LspLocationPipelineContext
            provider = function(query, context)
                return lsp_locations_provider({
                    method = "textDocument/implementation",
                    capability = "implementationProvider",
                    bufnr = context.bufnr,
                    position_params = context.position_params,
                })
            end,
            provider_type = ProviderTypeEnum.LIST,
            line_opts = {
                prepend_icon_by_ft = true,
                prepend_icon_path_delimiter = ":",
                prepend_icon_path_position = 1,
            },
        },
        previewers = {
            previewer = file_previewer_grep,
            previewer_type = PreviewerTypeEnum.COMMAND_LIST,
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = require("fzfx.actions").edit_rg,
            ["double-click"] = require("fzfx.actions").edit_rg,
        },
        fzf_opts = {
            default_fzf_options.multi,
            default_fzf_options.lsp_preview_window,
            "--border=none",
            { "--delimiter", ":" },
            {
                "--prompt",
                "Implementations > ",
            },
        },
        win_opts = {
            relative = "cursor",
            height = 0.45,
            width = 1,
            row = 1,
            col = 0,
            border = "none",
            zindex = 51,
        },
        other_opts = {
            context_maker = lsp_position_context_maker,
        },
    },

    -- the 'File Explorer' commands
    --- @type GroupConfig
    file_explorer = {
        commands = {
            {
                name = "FzfxFileExplorer",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    complete = "dir",
                    desc = "File explorer (ls -l)",
                },
                default_provider = "filter_hidden",
            },
            {
                name = "FzfxFileExplorerU",
                feed = CommandFeedEnum.ARGS,
                opts = {
                    bang = true,
                    nargs = "?",
                    complete = "dir",
                    desc = "File explorer (ls -la)",
                },
                default_provider = "include_hidden",
            },
            {
                name = "FzfxFileExplorerV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "File explorer (ls -l) by visual select",
                },
                default_provider = "filter_hidden",
            },
            {
                name = "FzfxFileExplorerUV",
                feed = CommandFeedEnum.VISUAL,
                opts = {
                    bang = true,
                    range = true,
                    desc = "File explorer (ls -la) by visual select",
                },
                default_provider = "include_hidden",
            },
            {
                name = "FzfxFileExplorerW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "File explorer (ls -l) by cursor word",
                },
                default_provider = "filter_hidden",
            },
            {
                name = "FzfxFileExplorerUW",
                feed = CommandFeedEnum.CWORD,
                opts = {
                    bang = true,
                    desc = "File explorer (ls -la) by cursor word",
                },
                default_provider = "include_hidden",
            },
            {
                name = "FzfxFileExplorerP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "File explorer (ls -l) by yank text",
                },
                default_provider = "filter_hidden",
            },
            {
                name = "FzfxFileExplorerUP",
                feed = CommandFeedEnum.PUT,
                opts = {
                    bang = true,
                    desc = "File explorer (ls -la) by yank text",
                },
                default_provider = "include_hidden",
            },
        },
        providers = {
            filter_hidden = {
                key = "ctrl-r",
                provider = make_file_explorer_provider("-lh"),
                provider_type = ProviderTypeEnum.COMMAND,
            },
            include_hidden = {
                key = "ctrl-u",
                provider = make_file_explorer_provider("-lha"),
                provider_type = ProviderTypeEnum.COMMAND,
            },
        },
        previewers = {
            filter_hidden = {
                previewer = file_explorer_previewer,
                previewer_type = PreviewerTypeEnum.COMMAND_LIST,
            },
            include_hidden = {
                previewer = file_explorer_previewer,
                previewer_type = PreviewerTypeEnum.COMMAND_LIST,
            },
        },
        interactions = {
            cd = {
                key = "alt-l",
                --- @param line string
                --- @param context FileExplorerPipelineContext
                interaction = function(line, context)
                    local target =
                        make_filename_by_file_explorer_context(line, context)
                    if vim.fn.isdirectory(target) > 0 then
                        utils.writefile(context.cwd, target)
                    end
                end,
                reload_after_execute = true,
            },
            upper = {
                key = "alt-h",
                --- @param line string
                --- @param context FileExplorerPipelineContext
                interaction = function(line, context)
                    local cwd = utils.readfile(context.cwd) --[[@as string]]
                    local target = vim.fn.fnamemodify(cwd, ":h")
                    -- Windows root folder: `C:\`
                    -- Unix/linux root folder: `/`
                    local root_len = constants.is_windows and 3 or 1
                    if
                        vim.fn.isdirectory(target) > 0
                        and string.len(target) > root_len
                    then
                        utils.writefile(context.cwd, target)
                    end
                end,
                reload_after_execute = true,
            },
        },
        actions = {
            ["esc"] = require("fzfx.actions").nop,
            ["enter"] = edit_file_explorer,
            ["double-click"] = edit_file_explorer,
        },
        fzf_opts = {
            default_fzf_options.multi,
            {
                "--prompt",
                path.shorten() .. " > ",
            },
            function()
                local n = 0
                if constants.has_eza or vim.fn.executable("ls") > 0 then
                    n = n + 1
                end
                if vim.fn.executable("echo") > 0 then
                    n = n + 1
                end
                return n > 0 and string.format("--header-lines=%d", n) or nil
            end,
        },
        other_opts = {
            context_maker = file_explorer_context_maker,
        },
    },

    -- the 'Yank History' commands
    yank_history = {
        other_opts = {
            maxsize = 100,
        },
    },

    -- the 'Users' commands
    users = nil,

    -- FZF_DEFAULT_OPTS
    fzf_opts = {
        "--ansi",
        "--info=inline",
        "--layout=reverse",
        "--border=rounded",
        "--height=100%",
        default_fzf_options.toggle,
        default_fzf_options.toggle_all,
        default_fzf_options.toggle_preview,
        default_fzf_options.preview_half_page_down,
        default_fzf_options.preview_half_page_up,
    },

    -- fzf colors
    -- see: https://github.com/junegunn/fzf/blob/master/README-VIM.md#explanation-of-gfzf_colors
    fzf_color_opts = {
        fg = { "fg", "Normal" },
        bg = { "bg", "Normal" },
        hl = { "fg", "Comment" },
        ["fg+"] = { "fg", "CursorLine", "CursorColumn", "Normal" },
        ["bg+"] = { "bg", "CursorLine", "CursorColumn" },
        ["hl+"] = { "fg", "Statement" },
        info = { "fg", "PreProc" },
        border = { "fg", "Ignore" },
        prompt = { "fg", "Conditional" },
        pointer = { "fg", "Exception" },
        marker = { "fg", "Keyword" },
        spinner = { "fg", "Label" },
        header = { "fg", "Comment" },
    },

    -- nerd fonts: https://www.nerdfonts.com/cheat-sheet
    -- unicode: https://symbl.cc/en/
    icons = {
        -- nerd fonts:
        --     nf-fa-file_text_o               \uf0f6 (default)
        --     nf-fa-file_o                    \uf016
        unknown_file = "",

        -- nerd fonts:
        --     nf-custom-folder                \ue5ff (default)
        --     nf-fa-folder                    \uf07b
        -- 󰉋    nf-md-folder                    \udb80\ude4b
        folder = "",

        -- nerd fonts:
        --     nf-custom-folder_open           \ue5fe (default)
        --     nf-fa-folder_open               \uf07c
        -- 󰝰    nf-md-folder_open               \udb81\udf70
        folder_open = "",

        -- nerd fonts:
        --     nf-oct-arrow_right              \uf432
        --     nf-cod-arrow_right              \uea9c
        --     nf-fa-caret_right               \uf0da
        --     nf-weather-direction_right      \ue349
        --     nf-fa-long_arrow_right          \uf178
        --     nf-oct-chevron_right            \uf460
        --     nf-fa-chevron_right             \uf054 (default)
        --
        -- unicode:
        -- https://symbl.cc/en/collections/arrow-symbols/
        -- ➜    U+279C                          &#10140;
        -- ➤    U+27A4                          &#10148;
        fzf_pointer = "",

        -- nerd fonts:
        --     nf-fa-star                      \uf005
        -- 󰓎    nf-md-star                      \udb81\udcce
        --     nf-cod-star_full                \ueb59
        --     nf-oct-dot_fill                 \uf444
        --     nf-fa-dot_circle_o              \uf192
        --     nf-cod-check                    \ueab2
        --     nf-fa-check                     \uf00c
        -- 󰄬    nf-md-check                     \udb80\udd2c
        --
        -- unicode:
        -- https://symbl.cc/en/collections/star-symbols/
        -- https://symbl.cc/en/collections/list-bullets/
        -- https://symbl.cc/en/collections/special-symbols/
        -- •    U+2022                          &#8226;
        -- ✓    U+2713                          &#10003; (default)
        fzf_marker = "✓",
    },

    popup = {
        -- nvim float window options
        -- see: https://neovim.io/doc/user/api.html#nvim_open_win()
        win_opts = {
            -- popup window height/width.
            --
            -- 1. if 0 <= h/w <= 1, evaluate proportionally according to editor's lines and columns,
            --    e.g. popup height = h * lines, width = w * columns.
            --
            -- 2. if h/w > 1, evaluate as absolute height and width, directly pass to vim.api.nvim_open_win.

            --- @type number
            height = 0.85,
            --- @type number
            width = 0.85,

            -- popup window position, by default popup window is in the center of editor.
            -- e.g. the option `relative="editor"`.
            -- for now the `relative` options supports:
            --  - editor
            --  - win
            --  - cursor
            --
            -- when relative is 'editor' or 'win', the anchor is the center position, not default 'NW' (north west).
            -- because 'NW' is a little bit complicated for users to calculate the position, usually we just put the popup window in the center of editor.
            --
            -- 1. if -0.5 <= r/c <= 0.5, evaluate proportionally according to editor's lines and columns.
            --    e.g. shift rows = r * lines, shift columns = c * columns.
            --
            -- 2. if r/c <= -1 or r/c >= 1, evaluate as absolute rows/columns to be shift.
            --    e.g. you can easily set 'row = -vim.o.cmdheight' to move popup window to up 1~2 lines (based on your 'cmdheight' option).
            --    this is especially useful when popup window is too big and conflicts with command/status line at bottom.
            --
            -- 3. r/c cannot be in range (-1, -0.5) or (0.5, 1), it makes no sense.
            --
            -- when relative is 'cursor', the anchor is 'NW' (north west).
            -- because we just want to put the popup window relative to the cursor.
            -- so 'row' and 'col' will be directly passed to `vim.api.nvim_open_win` API without any pre-processing.

            --- @type number
            row = 0,
            --- @type number
            col = 0,

            border = "none",
            zindex = 51,
        },
    },

    -- environment variables
    env = {
        --- @type string|nil
        nvim = nil,
        --- @type string|nil
        fzf = nil,
    },

    cache = {
        dir = path.join(vim.fn.stdpath("data"), "fzfx.nvim"),
    },

    -- debug
    debug = {
        enable = false,
        console_log = true,
        file_log = false,
    },
}

--- @type Options
local Configs = {}

--- @param options Options|nil
--- @return Options
local function setup(options)
    Configs = vim.tbl_deep_extend("force", Defaults, options or {})
    return Configs
end

--- @return Options
local function get_config()
    return Configs
end

--- @return Options
local function get_defaults()
    return Defaults
end

local M = {
    setup = setup,
    get_config = get_config,
    get_defaults = get_defaults,
}

return M
