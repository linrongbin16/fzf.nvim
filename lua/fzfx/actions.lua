local log = require("fzfx.log")
local line_helpers = require("fzfx.line_helpers")

--- @param lines string[]
--- @return nil
local function nop(lines)
    log.debug("|fzfx.actions - nop| lines:%s", vim.inspect(lines))
end

--- @alias EditActionVimCommands {edit:string[],setpos:string?}
--- @param lines string[]
--- @param delimiter string?
--- @param file_pos integer?
--- @param lineno_pos integer?
--- @param colno_pos integer?
--- @return EditActionVimCommands
local function make_edit_vim_commands(
    lines,
    delimiter,
    file_pos,
    lineno_pos,
    colno_pos
)
    local vim_commands = { edit = {}, setpos = nil }
    for i, line in ipairs(lines) do
        local parsed = line_helpers.PathLine:new(
            line,
            delimiter,
            file_pos,
            lineno_pos,
            colno_pos
        )
        local edit_cmd =
            string.format("edit %s", vim.fn.expand(parsed.filename))
        table.insert(vim_commands.edit, edit_cmd)
        log.debug(
            "|fzfx.actions - make_edit_vim_commands| edit_cmd[%d]:[%s]",
            i,
            edit_cmd
        )
        if parsed.lineno ~= nil then
            if i == #lines then
                local column = parsed.column or 1
                local setpos_cmd = string.format(
                    "call setpos('.', [0, %d, %d])",
                    parsed.lineno,
                    column
                )
                log.debug(
                    "|fzfx.actions - make_edit_vim_commands| edit_cmd[%d]:[%s]",
                    i,
                    edit_cmd
                )
                vim_commands.setpos = setpos_cmd
            end
        end
    end
    return vim_commands
end

--- @param delimiter string?
--- @param file_pos integer?
--- @param lineno_pos integer?
--- @param colno_pos integer?
--- @return fun(lines:string[]):string[]
local function make_edit(delimiter, file_pos, lineno_pos, colno_pos)
    log.debug(
        "|fzfx.actions - make_edit| delimiter:%s, file_pos:%s, lineno_pos:%s, colno_pos:%s",
        vim.inspect(delimiter),
        vim.inspect(file_pos),
        vim.inspect(lineno_pos),
        vim.inspect(colno_pos)
    )

    --- @param lines string[]
    --- @return nil
    local function impl(lines)
        local vim_commands = make_edit_vim_commands(
            lines,
            delimiter,
            file_pos,
            lineno_pos,
            colno_pos
        )
        for i, edit_cmd in ipairs(vim_commands.edit) do
            log.debug(
                "|fzfx.actions - make_edit.impl| edit_cmd[%d]:[%s]",
                i,
                edit_cmd
            )
            vim.cmd(edit_cmd)
        end
        if
            type(vim_commands.setpos) == "string"
            and string.len(vim_commands.setpos) > 0
        then
            vim.cmd(vim_commands.setpos)
        end
    end

    return impl
end

--- @deprecated
local function edit(lines)
    return make_edit()(lines)
end

local function edit_rg(lines)
    return make_edit(":", 1, 2, 3)(lines)
end

local function edit_grep(lines)
    return make_edit(":", 1, 2)(lines)
end

local function buffer(lines)
    return make_edit()(lines)
end

local function bdelete(lines)
    if type(lines) == "string" then
        lines = { lines }
    end
    if type(lines) == "table" and #lines > 0 then
        for _, line in ipairs(lines) do
            local parsed = line_helpers.PathLine:new(line)
            local cmd = string.format("bdelete %s", parsed.filename)
            log.debug(
                "|fzfx.actions - bdelete| line:[%s], bufname:[%s], cmd:[%s]",
                line,
                parsed.filename,
                cmd
            )
            vim.cmd(cmd)
        end
    end
end

local function git_checkout(lines)
    log.debug("|fzfx.actions - git_checkout| lines:%s", vim.inspect(lines))

    --- @param l string
    ---@param p string
    local function remove_prefix(l, p)
        local n = #p
        if string.len(l) > n and l:sub(1, n) == p then
            return l:sub(n + 1, #l)
        end
        return l
    end

    if type(lines) == "table" and #lines > 0 then
        local last_line = vim.trim(lines[#lines])
        if type(last_line) == "string" and string.len(last_line) > 0 then
            last_line = remove_prefix(last_line, "origin/")
            local arrow_pos = vim.fn.stridx(last_line, "->")
            if arrow_pos >= 0 then
                arrow_pos = arrow_pos + 1 + 2
                last_line = vim.trim(last_line:sub(arrow_pos, #last_line))
            end
            last_line = remove_prefix(last_line, "origin/")
            vim.cmd(vim.trim(string.format([[ !git checkout %s ]], last_line)))
        end
    end
end

local function yank_git_commit(lines)
    if type(lines) == "table" and #lines > 0 then
        local line = lines[#lines]
        local git_commit = vim.fn.split(line)[1]
        vim.api.nvim_command("let @+ = '" .. git_commit .. "'")
    end
end

local M = {
    nop = nop,
    make_edit_vim_commands = make_edit_vim_commands,
    make_edit = make_edit,
    edit = edit,
    edit_rg = edit_rg,
    edit_grep = edit_grep,
    buffer = buffer,
    bdelete = bdelete,
    git_checkout = git_checkout,
    yank_git_commit = yank_git_commit,
}

return M
