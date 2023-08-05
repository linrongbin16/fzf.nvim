local log = require("fzfx.log")
local constants = require("fzfx.constants")

local default_fd_command =
    string.format("%s . -cnever -tf -tl -L -i", constants.fd)
local default_rg_command =
    string.format("%s --column -n --no-heading --color=always -S", constants.rg)

--- @alias Config table<string, any>

--- @type Config
local Defaults = {
    files = {
        commands = {
            normal = {
                {
                    name = "FzfxFiles",
                    unrestricted = false,
                    opts = {
                        bang = true,
                        nargs = "?",
                        complete = "dir",
                        desc = "Find files",
                    },
                },
                {
                    name = "FzfxFilesU",
                    unrestricted = true,
                    opts = {
                        bang = true,
                        nargs = "?",
                        complete = "dir",
                        desc = "Find files",
                    },
                },
            },
            visual = {
                {
                    name = "FzfxFilesV",
                    unrestricted = false,
                    opts = {
                        bang = true,
                        range = true,
                        desc = "Find files by visual select",
                    },
                },
                {
                    name = "FzfxFilesUV",
                    unrestricted = true,
                    opts = {
                        bang = true,
                        range = true,
                        desc = "Find files unrestricted by visual select",
                    },
                },
            },
            cword = {
                {
                    name = "FzfxFilesW",
                    unrestricted = false,
                    opts = {
                        bang = true,
                        desc = "Find files by cursor word",
                    },
                },
                {
                    name = "FzfxFilesUW",
                    unrestricted = true,
                    opts = {
                        bang = true,
                        desc = "Find files unrestricted by cursor word",
                    },
                },
            },
        },
        providers = {
            restricted = default_fd_command,
            unrestricted = default_fd_command .. " -u",
        },
        actions = {
            builtin = {
                unrestricted_mode = "ctrl-u",
                restricted_mode = "ctrl-r",
            },
            expect = {
                ["enter"] = require("fzfx.action").edit,
                ["double-click"] = require("fzfx.action").edit,
            },
        },
        fzf_opts = {
            { "--bind", "ctrl-l:toggle-preview" },
        },
    },
    live_grep = {
        commands = {
            normal = {
                {
                    name = "FzfxLiveGrep",
                    unrestricted = false,
                    opts = {
                        bang = true,
                        nargs = "*",
                        desc = "Live grep",
                    },
                },
                {
                    name = "FzfxLiveGrepU",
                    unrestricted = true,
                    opts = {
                        bang = true,
                        nargs = "*",
                        desc = "Live grep unrestricted",
                    },
                },
            },
            visual = {
                {
                    name = "FzfxLiveGrepV",
                    unrestricted = false,
                    opts = {
                        bang = true,
                        range = true,
                        desc = "Live grep by visual select",
                    },
                },
                {
                    name = "FzfxLiveGrepUV",
                    unrestricted = true,
                    opts = {
                        bang = true,
                        range = true,
                        desc = "Live grep unrestricted by visual select",
                    },
                },
            },
            cword = {
                {
                    name = "FzfxLiveGrepW",
                    unrestricted = false,
                    opts = {
                        bang = true,
                        desc = "Live grep by cursor word",
                    },
                },
                {
                    name = "FzfxLiveGrepUW",
                    unrestricted = true,
                    opts = {
                        bang = true,
                        desc = "Live grep unrestricted by cursor word",
                    },
                },
            },
        },
        providers = {
            restricted = default_rg_command,
            unrestricted = default_rg_command .. " -uu",
        },
        actions = {
            builtin = {
                unrestricted_mode = "ctrl-u",
                restricted_mode = "ctrl-r",
            },
            expect = {
                ["enter"] = require("fzfx.action").edit_rg,
                ["double-click"] = require("fzfx.action").edit_rg,
            },
        },
        fzf_opts = {
            { "--bind", "ctrl-l:toggle-preview" },
        },
    },
    fzf_opts = {
        "--ansi",
        "--info=inline",
        "--layout=reverse",
        "--border=rounded",
        "--no-height",
        { "--preview-window", "right,50%" },
    },

    -- popup window opts
    -- please check: https://neovim.io/doc/user/api.html#nvim_open_win()
    win_opts = {
        -- popup window height/width
        -- if 0 <= h/w <= 1, evaluate as the ratio based on editor window's lines and columns
        -- if h/w > 1, pass it directly to nvim_open_win api
        height = 0.85,
        width = 0.85,
        -- popup window row/col position
        -- if 0 < r/c < 1, evaluate as the ratio based on editor window's lines and columns
        -- if r/c >= 1 or r/c <= -1, pass it directly to nvim_open_win api
        -- Note: r/c cannot be in range [-1, 0), it makes no sense.
        row = -vim.o.cmdheight, -- 0.5
        col = 0.5,
        anchor = "NW",
        border = "none",
        zindex = 51,
    },

    env = {
        nvim = nil,
        fzf = nil,
    },
    debug = {
        enable = false,
        console_log = true,
        file_log = false,
    },
}

--- @type Config
local Configs = {}

--- @param options Config
--- @return Config
local function setup(options)
    Configs = vim.tbl_deep_extend("force", Defaults, options or {})
    return Configs
end

--- @return Config
local function get_config()
    return Configs
end

local M = {
    setup = setup,
    get_config = get_config,
}

return M
