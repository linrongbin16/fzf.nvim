local cwd = vim.fn.getcwd()

describe("line_helpers", function()
    local assert_eq = assert.are.equal
    local assert_neq = assert.are_not.equal
    local assert_true = assert.is_true
    local assert_false = assert.is_false
    local assert_truthy = assert.is.truthy
    local assert_falsy = assert.is.falsy

    before_each(function()
        vim.api.nvim_command("cd " .. cwd)
    end)

    local line_helpers = require("fzfx.line_helpers")
    local utils = require("fzfx.utils")
    local DEVICONS_PATH =
        "~/github/linrongbin16/.config/nvim/lazy/nvim-web-devicons"
    describe("[parse_filename]", function()
        it("parse filename without icon", function()
            vim.env._FZFX_NVIM_DEVICONS_PATH = nil
            local expect = "~/github/linrongbin16/fzfx.nvim/README.md"
            local actual = line_helpers.parse_filename(expect)
            assert_eq(expect, actual)
        end)
        it("parse filename with prepend icon", function()
            vim.env._FZFX_NVIM_DEVICONS_PATH = DEVICONS_PATH
            local input = " ~/github/linrongbin16/fzfx.nvim/README.md"
            local actual = line_helpers.parse_filename(input)
            print(
                string.format(
                    "parse filename with prepend icon:%s\n",
                    vim.inspect(actual)
                )
            )
            assert_eq("~/github/linrongbin16/fzfx.nvim/README.md", actual)
        end)
    end)
    describe("[parse_path_line]", function()
        it("parse path without icon", function()
            vim.env._FZFX_NVIM_DEVICONS_PATH = nil
            local lines = {
                "~/github/linrongbin16/fzfx.nvim/README.md",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua",
            }
            for _, line in ipairs(lines) do
                local actual = line_helpers.parse_path_line(line)
                assert_eq(type(actual), "table")
                assert_eq(type(actual.filename), "string")
                assert_true(actual.lineno == nil)
                assert_true(actual.column == nil)
                assert_eq(actual.filename, line)
            end
        end)
        it("parse path with prepend icon", function()
            vim.env._FZFX_NVIM_DEVICONS_PATH = DEVICONS_PATH
            local lines = {
                " ~/github/linrongbin16/fzfx.nvim/README.md",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua",
            }
            for _, line in ipairs(lines) do
                local actual = line_helpers.parse_path_line(line)
                assert_eq(type(actual), "table")
                assert_eq(type(actual.filename), "string")
                assert_true(actual.lineno == nil)
                assert_true(actual.column == nil)
                assert_eq(actual.filename, utils.string_split(line, " ")[2])
            end
        end)
        it("parse path with delimiter, without icon", function()
            vim.env._FZFX_NVIM_DEVICONS_PATH = nil
            local lines = {
                "~/github/linrongbin16/fzfx.nvim/README.md:12",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:13:",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:13: hello world",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:1:3",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:1:3: ok ok",
            }
            for _, line in ipairs(lines) do
                local actual = line_helpers.parse_path_line(line, ":", 1)
                assert_eq(type(actual), "table")
                assert_eq(type(actual.filename), "string")
                assert_true(actual.lineno == nil)
                assert_true(actual.column == nil)
                assert_eq(actual.filename, utils.string_split(line, ":")[1])
            end
        end)
        it("parse path with delimiter, with prepend icon", function()
            vim.env._FZFX_NVIM_DEVICONS_PATH = DEVICONS_PATH
            local lines = {
                " ~/github/linrongbin16/fzfx.nvim/README.md:12",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:15",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:15:",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:1:70",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:4:71: ok ko",
            }
            for _, line in ipairs(lines) do
                local actual = line_helpers.parse_path_line(line, ":", 1)
                assert_eq(type(actual), "table")
                assert_eq(type(actual.filename), "string")
                assert_true(actual.lineno == nil)
                assert_true(actual.column == nil)
                assert_eq(
                    actual.filename,
                    utils.string_split(utils.string_split(line, ":")[1], " ")[2]
                )
            end
        end)
        it("parse path/lineno without icon", function()
            vim.env._FZFX_NVIM_DEVICONS_PATH = nil
            local lines = {
                "~/github/linrongbin16/fzfx.nvim/README.md:12",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:13:",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:13: hello world",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:1:3",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:1:3: ok ok",
            }
            for _, line in ipairs(lines) do
                local actual = line_helpers.parse_path_line(line, ":", 1, 2)
                assert_eq(type(actual), "table")
                assert_eq(type(actual.filename), "string")
                assert_eq(type(actual.lineno), "number")
                assert_true(actual.column == nil)
                assert_eq(actual.filename, utils.string_split(line, ":")[1])
                assert_eq(
                    tostring(actual.lineno),
                    utils.string_split(line, ":")[2]
                )
            end
        end)
        it("parse path/lineno with prepend icon", function()
            vim.env._FZFX_NVIM_DEVICONS_PATH = DEVICONS_PATH
            local lines = {
                " ~/github/linrongbin16/fzfx.nvim/README.md:12",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:15",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:15:",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:1:70",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:4:71: ok ko",
            }
            for _, line in ipairs(lines) do
                local actual = line_helpers.parse_path_line(line, ":", 1, 2)
                assert_eq(type(actual), "table")
                assert_eq(type(actual.filename), "string")
                assert_eq(type(actual.lineno), "number")
                assert_true(actual.column == nil)
                assert_eq(
                    actual.filename,
                    utils.string_split(utils.string_split(line, ":")[1], " ")[2]
                )
                assert_eq(
                    tostring(actual.lineno),
                    utils.string_split(line, ":")[2]
                )
            end
        end)
        it("parse path/lineno/col without icon", function()
            vim.env._FZFX_NVIM_DEVICONS_PATH = nil
            local lines = {
                "~/github/linrongbin16/fzfx.nvim/README.md:12:30",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:13:1:",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:13:2: hello world",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:1:3",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:1:3: ok ok",
            }
            for _, line in ipairs(lines) do
                local actual = line_helpers.parse_path_line(line, ":", 1, 2, 3)
                assert_eq(type(actual), "table")
                assert_eq(type(actual.filename), "string")
                assert_eq(type(actual.lineno), "number")
                assert_eq(type(actual.column), "number")
                assert_eq(actual.filename, utils.string_split(line, ":")[1])
                assert_eq(
                    tostring(actual.lineno),
                    utils.string_split(line, ":")[2]
                )
                assert_eq(
                    tostring(actual.column),
                    utils.string_split(line, ":")[3]
                )
            end
        end)
        it("edit file/lineno/col with prepend icon", function()
            vim.env._FZFX_NVIM_DEVICONS_PATH = DEVICONS_PATH
            local lines = {
                " ~/github/linrongbin16/fzfx.nvim/README.md:12:30",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:15:98",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua:15:82:",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:1:70",
                "󰢱 ~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua:4:71: ok ko",
            }
            for _, line in ipairs(lines) do
                local actual = line_helpers.parse_path_line(line, ":", 1, 2, 3)
                assert_eq(type(actual), "table")
                assert_eq(type(actual.filename), "string")
                assert_eq(type(actual.lineno), "number")
                assert_eq(type(actual.column), "number")
                assert_eq(
                    actual.filename,
                    utils.string_split(utils.string_split(line, ":")[1], " ")[2]
                )
                assert_eq(
                    tostring(actual.lineno),
                    utils.string_split(line, ":")[2]
                )
                assert_eq(
                    tostring(actual.column),
                    utils.string_split(line, ":")[3]
                )
            end
        end)
    end)
    describe("[PathLine]", function()
        it("create", function()
            vim.env._FZFX_NVIM_DEVICONS_PATH = nil
            local lines = {
                "~/github/linrongbin16/fzfx.nvim/README.md",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx.lua",
                "~/github/linrongbin16/fzfx.nvim/lua/fzfx/config.lua",
            }
            for _, line in ipairs(lines) do
                local p = line_helpers.PathLine:new(line)
                assert_eq(type(p), "table")
                assert_eq(type(p.filename), "string")
                assert_eq(p.filename, line)
                assert_true(p.lineno == nil)
                assert_true(p.column == nil)
            end
        end)
    end)
end)
