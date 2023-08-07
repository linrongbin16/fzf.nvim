local log = require("fzfx.log")

--- @param options Config
--- @return nil
local function setup(options)
    -- configs
    local configs = require("fzfx.config").setup(options)

    -- log
    log.setup({
        level = configs.debug.enable and "DEBUG" or "INFO",
        console_log = configs.debug.console_log,
        file_log = configs.debug.file_log,
    })
    log.debug("|fzfx - setup| configs:%s", vim.inspect(configs))

    -- cache
    vim.fn.mkdir(configs.cache.dir, "p")

    -- env
    if configs.debug.enable then
    end
    vim.env._FZFX_NVIM_DEBUG_ENABLE = configs.debug.enable and 1 or 0

    -- icons
    require("fzfx.icon").setup()

    -- files
    require("fzfx.files").setup()

    -- live_grep
    require("fzfx.live_grep").setup()
end

local M = {
    setup = setup,
}

return M
