local cwd = vim.fn.getcwd()

describe("config", function()
    local assert_eq = assert.is_equal
    local assert_true = assert.is_true
    local assert_false = assert.is_false

    before_each(function()
        vim.api.nvim_command("cd " .. cwd)
        require("fzfx.config").setup()
    end)

    local conf = require("fzfx.config")
    local fzf_helpers = require("fzfx.fzf_helpers")
    local utils = require("fzfx.utils")
    describe("[setup]", function()
        it("setup with default configs", function()
            conf.setup()
            assert_eq(type(conf.get_config()), "table")
            assert_false(vim.tbl_isempty(conf.get_config()))
            assert_eq(type(conf.get_config().live_grep), "table")
            assert_eq(type(conf.get_config().debug), "table")
            assert_eq(type(conf.get_config().debug.enable), "boolean")
            assert_false(conf.get_config().debug.enable)
            assert_eq(type(conf.get_config().popup), "table")
            assert_eq(type(conf.get_config().icons), "table")
            assert_eq(type(conf.get_config().fzf_opts), "table")
            local actual = fzf_helpers.make_fzf_opts(conf.get_config().fzf_opts)
            print(
                string.format(
                    "make fzf opts with default configs:%s\n",
                    vim.inspect(actual)
                )
            )
            assert_eq(type(actual), "string")
            assert_true(string.len(actual --[[@as string]]) > 0)
        end)
    end)
    describe("[get_defaults]", function()
        it("get defaults", function()
            assert_eq(type(conf.get_defaults()), "table")
            assert_false(vim.tbl_isempty(conf.get_defaults()))
            assert_eq(type(conf.get_defaults().live_grep), "table")
            assert_eq(type(conf.get_defaults().debug), "table")
            assert_eq(type(conf.get_defaults().debug.enable), "boolean")
            assert_false(conf.get_defaults().debug.enable)
            assert_eq(type(conf.get_defaults().popup), "table")
            assert_eq(type(conf.get_defaults().icons), "table")
            assert_eq(type(conf.get_defaults().fzf_opts), "table")
            local actual =
                fzf_helpers.make_fzf_opts(conf.get_defaults().fzf_opts)
            print(
                string.format(
                    "make fzf opts with default configs:%s\n",
                    vim.inspect(actual)
                )
            )
            assert_eq(type(actual), "string")
            assert_true(string.len(actual --[[@as string]]) > 0)
        end)
    end)
    describe("[_default_bat_style_theme]", function()
        it("defaults", function()
            vim.env.BAT_STYLE = nil
            vim.env.BAT_THEME = nil
            local style, theme = conf._default_bat_style_theme()
            assert_eq(style, "numbers,changes")
            assert_eq(theme, "base16")
        end)
        it("overwrites", function()
            vim.env.BAT_STYLE = "numbers,changes,headers"
            vim.env.BAT_THEME = "zenburn"
            local style, theme = conf._default_bat_style_theme()
            assert_eq(style, vim.env.BAT_STYLE)
            assert_eq(theme, vim.env.BAT_THEME)
            vim.env.BAT_STYLE = nil
            vim.env.BAT_THEME = nil
        end)
    end)
    describe("[_make_file_previewer]", function()
        it("file previewer", function()
            local f = conf._make_file_previewer("lua/fzfx/config.lua", 135)
            assert_eq(type(f), "function")
            local actual = f()
            print(string.format("file previewer:%s\n", vim.inspect(actual)))
            assert_true(actual[1] == "bat" or actual[1] == "cat")
        end)
    end)
    describe("[_live_grep_provider]", function()
        it("restricted", function()
            local actual = conf._live_grep_provider("hello", {}, nil)
            print(string.format("live grep provider:%s\n", vim.inspect(actual)))
            assert_eq(type(actual), "table")
            assert_true(
                actual[1] == "rg" or actual[1] == "grep" or actual[1] == "ggrep"
            )
        end)
        it("unrestricted", function()
            local actual = conf._live_grep_provider(
                "hello",
                {},
                { unrestricted = true }
            )
            print(string.format("live grep provider:%s\n", vim.inspect(actual)))
            assert_eq(type(actual), "table")
            assert_true(
                actual[1] == "rg" or actual[1] == "grep" or actual[1] == "ggrep"
            )
        end)
        it("buffer", function()
            vim.cmd([[edit README.md]])
            local actual = conf._live_grep_provider("hello", {
                bufnr = vim.api.nvim_get_current_buf(),
                winnr = vim.api.nvim_get_current_win(),
                tabnr = vim.api.nvim_get_current_tabpage(),
            }, { buffer = true })
            print(string.format("live grep provider:%s\n", vim.inspect(actual)))
            assert_eq(type(actual), "table")
            assert_true(
                actual[1] == "rg" or actual[1] == "grep" or actual[1] == "ggrep"
            )
        end)
    end)
    describe("[_parse_vim_ex_command_name]", function()
        it("parse", function()
            local lines = {
                "|:|",
                "|:next|",
                "|:FzfxGBranches|",
            }
            for _, line in ipairs(lines) do
                local actual = conf._parse_vim_ex_command_name(line)
                local expect = vim.trim(line:sub(3, #line - 1))
                assert_eq(actual, expect)
            end
        end)
    end)
    describe("[_get_vim_ex_commands]", function()
        it("get ex commands", function()
            local actual = conf._get_vim_ex_commands()
            assert_eq(type(actual["next"]), "table")
            print(
                string.format(
                    "ex command 'next':%s\n",
                    vim.inspect(actual["next"])
                )
            )
            assert_eq(actual["next"].name, "next")
            assert_true(vim.fn.filereadable(actual["next"].loc.filename) > 0)
            assert_true(tonumber(actual["next"].loc.lineno) > 0)
            assert_eq(type(actual["bnext"]), "table")
            print(
                string.format(
                    "ex command 'bnext':%s\n",
                    vim.inspect(actual["bnext"])
                )
            )
            assert_eq(actual["bnext"].name, "bnext")
            assert_true(vim.fn.filereadable(actual["bnext"].loc.filename) > 0)
            assert_true(tonumber(actual["bnext"].loc.lineno) > 0)
        end)
        it("is ex command output header", function()
            local line = "Name              Args Address Complete    Definition"
            local actual1 = conf._is_ex_command_output_header("asdf")
            local actual2 = conf._is_ex_command_output_header(line)
            assert_false(actual1)
            assert_true(actual2)
            local actual3 = conf._parse_ex_command_output_header(line)
            assert_eq(type(actual3), "table")
            assert_eq(actual3.name_pos, 1)
            assert_eq(actual3.args_pos, utils.string_find(line, "Args"))
            assert_eq(actual3.address_pos, utils.string_find(line, "Address"))
            assert_eq(actual3.complete_pos, utils.string_find(line, "Complete"))
            assert_eq(
                actual3.definition_pos,
                utils.string_find(line, "Definition")
            )
        end)
    end)
end)
