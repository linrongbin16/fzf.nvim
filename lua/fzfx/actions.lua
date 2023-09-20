local log = require("fzfx.log")
local env = require("fzfx.env")
local path = require("fzfx.path")
local utils = require("fzfx.utils")

--- @param lines string[]
--- @return nil
local function nop(lines)
    log.debug("|fzfx.actions - nop| lines:%s", vim.inspect(lines))
end

--- @param line string
--- @param delimiter string?
--- @param pos integer?
--- @return string
local function retrieve_filename(line, delimiter, pos)
    local filename = env.icon_enable()
            and utils.string_split(line, delimiter)[pos]
        or line
    return path.normalize(filename)
end

--- @param delimiter string?
--- @param filepos integer?
--- @return fun(lines:string[]):string[]
local function make_edit(delimiter, filepos)
    log.debug(
        "|fzfx.actions - make_edit| delimiter:%s, filepos:%s",
        vim.inspect(delimiter),
        vim.inspect(filepos)
    )

    --- @param lines string[]
    --- @return string[]
    local function impl(lines)
        local cmd_results = {}
        for i, line in ipairs(lines) do
            local filename = retrieve_filename(line, delimiter, filepos)
            local cmd = string.format("edit %s", vim.fn.expand(filename))
            table.insert(cmd_results, cmd)
            log.debug("|fzfx.actions - edit| line[%d] cmd:[%s]", i, cmd)
            vim.cmd(cmd)
        end
        return cmd_results
    end

    return impl
end

local function edit(lines)
    log.debug("|fzfx.actions - edit| lines:%s", vim.inspect(lines))
    for i, line in ipairs(lines) do
        local filename = env.icon_enable() and vim.fn.split(line)[2] or line
        filename = path.normalize(filename)
        local cmd = string.format("edit %s", vim.fn.expand(filename))
        log.debug("|fzfx.actions - edit| line[%d] cmd:[%s]", i, cmd)
        vim.cmd(cmd)
    end
end

local function edit_rg(lines)
    log.debug("|fzfx.actions - edit_rg| lines:%s", vim.inspect(lines))
    for i, line in ipairs(lines) do
        local splits = vim.fn.split(line, ":")
        local filename = env.icon_enable() and vim.fn.split(splits[1])[2]
            or splits[1]
        log.debug("|fzfx.actions - edit_rg| filename:%s", vim.inspect(filename))
        filename = path.normalize(filename)
        local row = tonumber(splits[2])
        local col = tonumber(splits[3])
        local edit_cmd = string.format("edit %s", vim.fn.expand(filename))
        local setpos_cmd =
            string.format("call setpos('.', [0, %d, %d])", row, col)
        log.debug(
            "|fzfx.actions - edit_rg| line[%d] - splits:%s, filename:%s, row:%d, col:%d",
            i,
            vim.inspect(splits),
            vim.inspect(filename),
            vim.inspect(row),
            vim.inspect(col)
        )
        log.debug(
            "|fzfx.actions - edit_rg| line[%d] - edit_cmd:[%s], setpos_cmd:[%s]",
            i,
            edit_cmd,
            setpos_cmd
        )
        vim.cmd(edit_cmd)
        if i == #lines then
            vim.cmd(setpos_cmd)
        end
    end
end

local function edit_grep(lines)
    log.debug("|fzfx.actions - edit_grep| lines:%s", vim.inspect(lines))
    for i, line in ipairs(lines) do
        local splits = vim.fn.split(line, ":")
        local filename = env.icon_enable() and vim.fn.split(splits[1])[2]
            or splits[1]
        log.debug(
            "|fzfx.actions - edit_grep| filename:%s",
            vim.inspect(filename)
        )
        filename = path.normalize(filename)
        local row = tonumber(splits[2])
        local col = 0
        local edit_cmd = string.format("edit %s", vim.fn.expand(filename))
        local setpos_cmd =
            string.format("call setpos('.', [0, %d, %d])", row, col)
        log.debug(
            "|fzfx.actions - edit_grep| line[%d] - splits:%s, filename:%s, row:%d, col:%d",
            i,
            vim.inspect(splits),
            vim.inspect(filename),
            vim.inspect(row),
            vim.inspect(col)
        )
        log.debug(
            "|fzfx.actions - edit_grep| line[%d] - edit_cmd:[%s], setpos_cmd:[%s]",
            i,
            edit_cmd,
            setpos_cmd
        )
        vim.cmd(edit_cmd)
        if i == #lines then
            vim.cmd(setpos_cmd)
        end
    end
end

local function buffer(lines)
    log.debug("|fzfx.actions - buffer| lines:%s", vim.inspect(lines))
    for i, line in ipairs(lines) do
        local filename = env.icon_enable() and vim.fn.split(line)[2] or line
        filename = path.normalize(filename)
        local cmd = string.format("buffer %s", vim.fn.expand(filename))
        log.debug("|fzfx.actions - buffer| line[%d] cmd:[%s]", i, cmd)
        vim.cmd(cmd)
    end
end

local function buffer_rg(lines)
    log.debug("|fzfx.actions - buffer_rg| lines:%s", vim.inspect(lines))
    for i, line in ipairs(lines) do
        local splits = vim.fn.split(line, ":")
        local filename = env.icon_enable() and vim.fn.split(splits[1])[2]
            or splits[1]
        filename = path.normalize(filename)
        local row = tonumber(splits[2])
        local col = tonumber(splits[3])
        local buffer_cmd = string.format("buffer %s", vim.fn.expand(filename))
        local setpos_cmd =
            string.format("call setpos('.', [0, %d, %d])", row, col)
        log.debug(
            "|fzfx.actions - buffer_rg| line[%d] - splits:%s, filename:%s, row:%d, col:%d",
            i,
            vim.inspect(splits),
            vim.inspect(filename),
            vim.inspect(row),
            vim.inspect(col)
        )
        log.debug(
            "|fzfx.actions - buffer_rg| line[%d] - buffer_cmd:[%s], setpos_cmd:[%s]",
            i,
            buffer_cmd,
            setpos_cmd
        )
        vim.cmd(buffer_cmd)
        if i == #lines then
            vim.cmd(setpos_cmd)
        end
    end
end

local function bdelete(lines)
    if type(lines) == "string" then
        lines = { lines }
    end
    if type(lines) == "table" and #lines > 0 then
        for _, line in ipairs(lines) do
            local bufname = env.icon_enable() and vim.fn.split(line)[2] or line
            bufname = path.normalize(bufname)
            local cmd = vim.trim(string.format([[ bdelete %s ]], bufname))
            log.debug(
                "|fzfx.actions - bdelete| line:[%s], bufname:[%s], cmd:[%s]",
                line,
                bufname,
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
    retrieve_filename = retrieve_filename,
    make_edit = make_edit,
    edit = edit,
    edit_rg = edit_rg,
    edit_grep = edit_grep,
    buffer = buffer,
    buffer_rg = buffer_rg,
    bdelete = bdelete,
    git_checkout = git_checkout,
    yank_git_commit = yank_git_commit,
}

return M
