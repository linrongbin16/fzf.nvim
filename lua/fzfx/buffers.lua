local log = require("fzfx.log")
local conf = require("fzfx.config")
local general = require("fzfx.general")
local InteractionConfig = require("fzfx.schema").InteractionConfig

local function setup()
    local buffers_configs = conf.get_config().buffers
    if not buffers_configs then
        return
    end
    log.debug(
        "|fzfx.buffers - setup| buffers_configs:",
        vim.inspect(buffers_configs)
    )

    local deprecated = false
    -- interactions
    if
        type(buffers_configs.interactions) == "table"
        and #buffers_configs.interactions == 2
        and type(buffers_configs.interactions[1]) == "string"
        and type(buffers_configs.interactions[2]) == "function"
        and buffers_configs.interactions["delete_buffer"] == nil
    then
        local new_interactions = {}
        new_interactions["delete_buffer"] = InteractionConfig:make({
            key = buffers_configs.interactions[1],
            interaction = buffers_configs.interactions[2],
            reload_after_execute = true,
        })
        buffers_configs.interactions = new_interactions
        deprecated = true
    end
    -- other_opts
    if
        type(buffers_configs["other_opts"]) == "table"
        and type(buffers_configs["other_opts"]["exclude_filetypes"])
            == "table"
    then
        deprecated = true
    end

    general.setup("buffers", buffers_configs)
    if deprecated then
        log.warn(
            "deprecated FzfxGCommits previewer configs, please migrate to latest config schema!"
        )
        -- local vim_enter_notified = false
        -- vim.api.nvim_create_autocmd("VimEnter", {
        --     pattern = { "*" },
        --     callback = function()
        --         if not vim_enter_notified then
        --             log.warn(
        --                 'deprecated "FzfxGCommits" previewer configs, please migrate to latest config schema!'
        --             )
        --             vim_enter_notified = true
        --         end
        --     end,
        -- })
        -- local buf_enter_notified = false
        -- vim.api.nvim_create_autocmd("BufEnter", {
        --     pattern = { "*" },
        --     callback = function()
        --         if not buf_enter_notified then
        --             log.warn(
        --                 'deprecated "FzfxGCommits" previewer configs, please migrate to latest config schema!'
        --             )
        --             buf_enter_notified = true
        --         end
        --     end,
        -- })
    end
end

local M = {
    setup = setup,
}

return M
