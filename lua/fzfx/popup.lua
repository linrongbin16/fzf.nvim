local log = require("fzfx.log")
local conf = require("fzfx.config")
local utils = require("fzfx.utils")
local helpers = require("fzfx.helpers")

--- @class PopupWindow
--- @field window_opts_context WindowOptsContext?
--- @field bufnr integer|nil
--- @field winnr integer|nil
local PopupWindow = {
    window_opts_context = nil,
    bufnr = nil,
    winnr = nil,
}

--- @class PopupWindowOpts
--- @field relative "editor"|"win"|"cursor"|nil
--- @field width integer|nil
--- @field height integer|nil
--- @field row integer|nil
--- @field col integer|nil
--- @field style "minimal"|nil
--- @field border "none"|"single"|"double"|"rounded"|"solid"|"shadow"|nil
--- @field zindex integer|nil
local PopupWindowOpts = {
    relative = nil,
    width = nil,
    height = nil,
    row = nil,
    col = nil,
    style = nil,
    border = nil,
    zindex = nil,
}

--- @param value number
--- @param base integer
--- @param minimal integer?
--- @return integer
local function make_popup_window_size(value, base, minimal)
    minimal = minimal or 3
    return utils.number_bound(
        minimal,
        value > 1 and value or math.floor(base * value),
        base
    )
end

--- @param win_opts Configs
--- @return PopupWindowOpts
local function make_popup_window_opts_relative_to_cursor(win_opts)
    --- @type "cursor"
    local relative = win_opts.relative
    local total_width = vim.api.nvim_win_get_width(0)
    local total_height = vim.api.nvim_win_get_height(0)

    local width = make_popup_window_size(win_opts.width, total_width)
    local height = make_popup_window_size(win_opts.height, total_height)
    if win_opts.row < 0 then
        log.throw(
            "error! invalid option (win_opts.row < 0): %s!",
            vim.inspect(win_opts)
        )
    end
    local row = win_opts.row

    if win_opts.col < 0 then
        log.throw(
            "error! invalid option (win_opts.col < 0): %s!",
            vim.inspect(win_opts)
        )
    end
    local col = win_opts.col

    --- @type PopupWindowOpts
    local popup_window_opts =
        vim.tbl_deep_extend("force", vim.deepcopy(PopupWindowOpts), {
            anchor = "NW",
            relative = relative,
            width = width,
            height = height,
            -- start point on NW
            row = row,
            col = col,
            style = "minimal",
            border = win_opts.border,
            zindex = win_opts.zindex,
        })
    log.debug(
        "|fzfx.popup - make_popup_window_opts_relative_to_cursor| (origin) win_opts:%s, popup_win_opts:%s",
        vim.inspect(win_opts),
        vim.inspect(popup_window_opts)
    )
    return popup_window_opts
end

--- @param total_size integer
--- @param popup_size integer
--- @param value number
local function make_popup_window_center_shift_size(
    total_size,
    popup_size,
    value
)
    local base = math.floor((total_size - popup_size) * 0.5)
    if value >= 0 then
        local shift = value < 1
                and math.floor((total_size - popup_size) * value)
            or value
        return utils.number_bound(0, base + shift, total_size - popup_size)
    else
        local shift = value > -1
                and math.ceil((total_size - popup_size) * value)
            or value
        return utils.number_bound(0, base + shift, total_size - popup_size)
    end
end

--- @param win_opts Configs
--- @return PopupWindowOpts
local function make_popup_window_opts_relative_to_center(win_opts)
    --- @type "editor"|"win"
    local relative = win_opts.relative or "editor"

    local total_width = vim.o.columns
    local total_height = vim.o.lines
    if relative == "win" then
        total_width = vim.api.nvim_win_get_width(0)
        total_height = vim.api.nvim_win_get_height(0)
    end

    local width = make_popup_window_size(win_opts.width, total_width)
    local height = make_popup_window_size(win_opts.height, total_height)

    if
        (win_opts.row > -1 and win_opts.row < -0.5)
        or (win_opts.row > 0.5 and win_opts.row < 1)
    then
        log.throw(
            "error! invalid option (win_opts.row): %s!",
            vim.inspect(win_opts)
        )
    end
    local row =
        make_popup_window_center_shift_size(total_height, height, win_opts.row)
    log.debug(
        "|fzfx.popup - make_popup_window_opts_relative_to_center| row:%s, win_opts:%s, total_height:%s, height:%s",
        vim.inspect(row),
        vim.inspect(win_opts),
        vim.inspect(total_height),
        vim.inspect(height)
    )

    if
        (win_opts.col > -1 and win_opts.col < -0.5)
        or (win_opts.col > 0.5 and win_opts.col < 1)
    then
        log.throw(
            "error! invalid option (win_opts.col): %s!",
            vim.inspect(win_opts)
        )
    end
    local col =
        make_popup_window_center_shift_size(total_width, width, win_opts.col)

    --- @type PopupWindowOpts
    local popup_window_opts =
        vim.tbl_deep_extend("force", vim.deepcopy(PopupWindowOpts), {
            anchor = "NW",
            relative = relative,
            width = width,
            height = height,
            -- start point on NW
            row = row,
            col = col,
            style = "minimal",
            border = win_opts.border,
            zindex = win_opts.zindex,
        })
    log.debug(
        "|fzfx.popup - make_popup_window_opts_relative_to_center| (origin) win_opts:%s, popup_win_opts:%s",
        vim.inspect(win_opts),
        vim.inspect(popup_window_opts)
    )
    return popup_window_opts
end

--- @param win_opts Configs
--- @return PopupWindowOpts
local function make_popup_window_opts(win_opts)
    --- @type "editor"|"win"|"cursor"
    local relative = win_opts.relative or "editor"

    if relative == "cursor" then
        return make_popup_window_opts_relative_to_cursor(win_opts)
    elseif relative == "editor" or relative == "win" then
        return make_popup_window_opts_relative_to_center(win_opts)
    else
        log.throw(
            "error! failed to make popup window opts, unsupport relative value %s.",
            vim.inspect(relative)
        )
        ---@diagnostic disable-next-line: missing-return
    end
end

--- @param win_opts PopupWindowOpts?
--- @return PopupWindow
function PopupWindow:new(win_opts)
    -- check executable: nvim, fzf
    require("fzfx.helpers").nvim_exec()
    require("fzfx.helpers").fzf_exec()

    -- save current window context
    local window_opts_context = utils.WindowOptsContext:save()

    --- @type integer
    local bufnr = vim.api.nvim_create_buf(false, true)
    -- setlocal bufhidden=wipe nobuflisted
    -- setft=fzf
    utils.set_buf_option(bufnr, "bufhidden", "wipe")
    utils.set_buf_option(bufnr, "buflisted", false)
    utils.set_buf_option(bufnr, "filetype", "fzf")

    --- @type PopupWindowOpts
    local merged_win_opts = vim.tbl_deep_extend(
        "force",
        vim.deepcopy(conf.get_config().popup.win_opts),
        vim.deepcopy(win_opts) or {}
    )
    local popup_opts = make_popup_window_opts(merged_win_opts)

    --- @type integer
    local winnr = vim.api.nvim_open_win(bufnr, true, popup_opts)

    --- setlocal nospell nonumber
    --- set winhighlight='Pmenu:,Normal:Normal'
    --- set colorcolumn=''
    utils.set_win_option(winnr, "spell", false)
    utils.set_win_option(winnr, "number", false)
    utils.set_win_option(winnr, "winhighlight", "Pmenu:,Normal:Normal")
    utils.set_win_option(winnr, "colorcolumn", "")

    local o = {
        window_opts_context = window_opts_context,
        bufnr = bufnr,
        winnr = winnr,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function PopupWindow:close()
    log.debug("|fzfx.popup - Popup:close| self:%s", vim.inspect(self))

    if vim.api.nvim_win_is_valid(self.winnr) then
        vim.api.nvim_win_close(self.winnr, true)
    else
        log.debug(
            "error! cannot close invalid popup window! %s",
            vim.inspect(self.winnr)
        )
    end

    ---@diagnostic disable-next-line: undefined-field
    self.window_opts_context:restore()
end

--- @class Popup
--- @field popup_window PopupWindowOpts?
--- @field source string|string[]|nil
--- @field jobid integer|nil
--- @field result string|nil
local Popup = {
    popup_window = nil,
    source = nil,
    jobid = nil,
    result = nil,
}

--- @param actions table<string, any>
--- @return string[][]
local function make_expect_keys(actions)
    local expect_keys = {}
    if type(actions) == "table" then
        for name, _ in pairs(actions) do
            table.insert(expect_keys, { "--expect", name })
        end
    end
    return expect_keys
end

--- @param fzf_opts string[]|string[][]
--- @param actions table<string, any>
--- @return string[]
local function merge_fzf_opts(fzf_opts, actions)
    local expect_keys = make_expect_keys(actions)
    local merged_opts = vim.list_extend(vim.deepcopy(fzf_opts), expect_keys)
    log.debug(
        "|fzfx.popup - merge_fzf_opts| fzf_opts:%s, actions:%s, merged_opts:%s",
        vim.inspect(fzf_opts),
        vim.inspect(actions),
        vim.inspect(merged_opts)
    )
    return merged_opts
end

--- @param fzf_opts Configs
--- @param actions Configs
--- @param result string
--- @return string
local function make_fzf_command(fzf_opts, actions, result)
    local final_opts = merge_fzf_opts(fzf_opts, actions)
    local final_opts_string = helpers.make_fzf_opts(final_opts)
    log.debug(
        "|fzfx.popup - make_fzf_command| final_opts:%s, builder:%s",
        vim.inspect(final_opts),
        vim.inspect(final_opts_string)
    )
    local command = string.format(
        "%s %s >%s",
        helpers.fzf_exec(),
        final_opts_string,
        result
    )
    log.debug(
        "|fzfx.popup - make_fzf_command| command:%s",
        vim.inspect(command)
    )
    return command
end

--- @alias OnPopupExit fun(launch:Popup):nil

--- @param win_opts PopupWindowOpts?
--- @param source string
--- @param fzf_opts Configs
--- @param actions Configs
--- @param context PipelineContext
--- @param on_launch_exit OnPopupExit|nil
--- @return Popup
function Popup:new(win_opts, source, fzf_opts, actions, context, on_launch_exit)
    local result = vim.fn.tempname()
    local fzf_command = make_fzf_command(fzf_opts, actions, result)
    local popup_window = PopupWindow:new(win_opts)

    local function on_fzf_exit(jobid2, exitcode, event)
        log.debug(
            "|fzfx.popup - Popup:new.on_fzf_exit| jobid2:%s, exitcode:%s, event:%s",
            vim.inspect(jobid2),
            vim.inspect(exitcode),
            vim.inspect(event)
        )
        if exitcode > 1 and (exitcode ~= 130 and exitcode ~= 129) then
            log.err(
                "command '%s' running with exit code %d",
                fzf_command,
                exitcode
            )
            return
        end

        local esc_key =
            vim.api.nvim_replace_termcodes("<ESC>", true, false, true)

        -- press <ESC> if still in fzf terminal
        if vim.o.buftype == "terminal" and vim.o.filetype == "fzf" then
            vim.api.nvim_feedkeys(esc_key, "x", false)
        end

        -- close popup window and restore old window
        popup_window:close()

        -- -- press <ESC> if in insert mode
        -- vim.api.nvim_feedkeys(esc_key, "x", false)

        log.ensure(
            vim.fn.filereadable(result) > 0,
            "|fzfx.popup - Popup:new.on_fzf_exit| error! result %s must be readable",
            vim.inspect(result)
        )
        local lines = utils.readlines(result) --[[@as table]]
        log.debug(
            "|fzfx.popup - Popup:new.on_fzf_exit| result:%s, result_lines:%s",
            vim.inspect(result),
            vim.inspect(lines)
        )
        local action_key = vim.trim(lines[1])
        local action_lines = vim.list_slice(lines, 2)
        log.debug(
            "|fzfx.popup - Popup:new.on_fzf_exit| action_key:%s, action_lines:%s",
            vim.inspect(action_key),
            vim.inspect(action_lines)
        )
        if actions[action_key] ~= nil then
            local action_callback = actions[action_key]
            if type(action_callback) ~= "function" then
                log.throw(
                    "error! wrong action type on key: %s, must be function(%s): %s",
                    vim.inspect(action_key),
                    type(action_callback),
                    vim.inspect(action_callback)
                )
            else
                action_callback(action_lines, context)
            end
        else
            log.err("unknown action key: %s", vim.inspect(action_key))
        end
        if type(on_launch_exit) == "function" then
            on_launch_exit(self)
        end
    end

    -- save shell opts
    local shell_opts_context = utils.ShellOptsContext:save()
    local prev_fzf_default_opts = vim.env.FZF_DEFAULT_OPTS
    local prev_fzf_default_command = vim.env.FZF_DEFAULT_COMMAND
    vim.env.FZF_DEFAULT_OPTS = helpers.make_fzf_default_opts()
    vim.env.FZF_DEFAULT_COMMAND = source
    log.debug(
        "|fzfx.popup - Popup:new| $FZF_DEFAULT_OPTS:%s",
        vim.inspect(vim.env.FZF_DEFAULT_OPTS)
    )
    log.debug(
        "|fzfx.popup - Popup:new| $FZF_DEFAULT_COMMAND:%s",
        vim.inspect(vim.env.FZF_DEFAULT_COMMAND)
    )
    log.debug(
        "|fzfx.popup - Popup:new| fzf_command:%s",
        vim.inspect(fzf_command)
    )

    -- launch
    local jobid = vim.fn.termopen(fzf_command, { on_exit = on_fzf_exit }) --[[@as integer ]]

    -- restore shell opts
    shell_opts_context:restore()
    vim.env.FZF_DEFAULT_COMMAND = prev_fzf_default_command
    vim.env.FZF_DEFAULT_OPTS = prev_fzf_default_opts

    vim.cmd([[ startinsert ]])

    local o = {
        popup_window = popup_window,
        source = source,
        jobid = jobid,
        result = result,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Popup:close()
    log.debug("|fzfx.popup - Popup:close| self:%s", vim.inspect(self))
end

local M = {
    make_popup_window_size = make_popup_window_size,
    make_popup_window_center_shift_size = make_popup_window_center_shift_size,
    Popup = Popup,
}

return M
