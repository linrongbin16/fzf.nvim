local log = require("fzfx.log")

local AnsiCode = {
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
}

--- @param attr "fg"|"bg"
--- @param group string
--- @return string|nil
local function get_color(attr, group)
    local gui = vim.fn.has("termguicolors") > 0 and vim.o.termguicolors
    local family = gui and "gui" or "cterm"
    local pattern = gui and "^#[%l%d]+" or "^[%d]+$"
    local code =
        vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attr, family)
    if string.find(code, pattern) then
        log.debug(
            "|fzfx.color - get_color| attr:%s, group:%s, code:%s",
            vim.inspect(attr),
            vim.inspect(group),
            vim.inspect(code)
        )
        return code
    end
    log.debug(
        "|fzfx.color - get_color| return nil, attr:%s, group:%s, code:%s",
        vim.inspect(attr),
        vim.inspect(group),
        vim.inspect(code)
    )
    return nil
end

--- @param color string|nil
--- @param fg boolean
--- @return string|nil
local function csi(color, fg)
    if type(color) ~= "string" then
        return nil
    end
    local code = fg and 38 or 48
    local r, g, b = color:match("#(..)(..)(..)")
    if not r or not g or not b then
        log.debug(
            "|fzfx.color - csi| fallback, color:%s, fg:%s, result:nil",
            vim.inspect(color),
            vim.inspect(fg)
        )
        return nil
    end
    r = tonumber(r, 16)
    g = tonumber(g, 16)
    b = tonumber(b, 16)
    local result = string.format("%d;2;%d;%d;%d", code, r, g, b)
    log.debug(
        "|fzfx.color - csi| color:%s, fg:%s, result:%s",
        vim.inspect(color),
        vim.inspect(fg),
        vim.inspect(result)
    )
    return result
end

--- @param text string
--- @param name string
--- @param group string
--- @return string
local function ansi(text, name, group)
    local color = get_color("fg", group)

    local rgbcolor = csi(color, true)
    if type(rgbcolor) == "string" and string.len(rgbcolor) > 0 then
        local result = string.format("[%sm%s[0m", rgbcolor, text)
        log.debug(
            "|fzfx.color - ansi| text:%s, name:%s, group:%s, fg:%s, rgbcolor:%s, result:%s",
            vim.inspect(text),
            vim.inspect(name),
            vim.inspect(group),
            vim.inspect(color),
            vim.inspect(rgbcolor),
            vim.inspect(result)
        )
        return result
    end

    local ansicolor = AnsiCode[name]
    local result = string.format("[%sm%s[0m", ansicolor, text)
    log.debug(
        "|fzfx.color - ansi| text:%s, name:%s, group:%s, fg:%s, ansicolor:%s, result:%s",
        vim.inspect(text),
        vim.inspect(name),
        vim.inspect(group),
        vim.inspect(color),
        vim.inspect(ansicolor),
        vim.inspect(result)
    )
    return result
end

local M = {}

for color, default_hl in pairs({
    black = "Comment",
    red = "Exception",
    green = "Label",
    yellow = "LineNr",
    blue = "TabLine",
    magenta = "Special",
    cyan = "String",
}) do
    --- @param text string
    --- @param hl string|nil
    --- @return string
    M[color] = function(text, hl)
        return ansi(text, color, hl or default_hl)
    end
end

--- @param fmt string
--- @param renderer fun(color:string,hl:string|nil):string
--- @return string
local function render(fmt, renderer, ...)
    local args = {}
    for _, a in ipairs({ ... }) do
        table.insert(args, renderer(a))
    end
    return string.format(fmt, unpack(args))
end

M.unrestricted_mode_header = function(action)
    return render(
        ":: Press %s to unrestricted mode",
        M.magenta,
        string.upper(action)
    )
end

M.restricted_mode_header = function(action)
    return render(
        ":: Press %s to restricted mode",
        M.magenta,
        string.upper(action)
    )
end

return M
