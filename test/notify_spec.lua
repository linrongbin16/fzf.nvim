local cwd = vim.fn.getcwd()

describe("notify", function()
    local assert_eq = assert.are.equal
    local assert_neq = assert.are_not.equal
    local assert_true = assert.is_true
    local assert_false = assert.is_false
    local assert_truthy = assert.is.truthy
    local assert_falsy = assert.is.falsy

    before_each(function()
        vim.api.nvim_command("cd " .. cwd)
    end)

    local notify = require("fzfx.notify")
    local NotifyLevels = require("fzfx.notify").NotifyLevels
    local NotifyLevelNames = require("fzfx.notify").NotifyLevelNames
    describe("[NotifyLevels]", function()
        it("check levels", function()
            for k, v in pairs(NotifyLevels) do
                assert_eq(type(k), "string")
                assert_eq(type(v), "number")
            end
        end)
        it("check level names", function()
            for v, k in pairs(NotifyLevelNames) do
                assert_eq(type(k), "string")
                assert_eq(type(v), "number")
            end
        end)
    end)

    describe("[echo]", function()
        it("info", function()
            notify.echo(NotifyLevels.INFO, "echo without parameters")
            notify.echo(NotifyLevels.INFO, "echo with 1 parameters: %s", "a")
            notify.echo(
                NotifyLevels.INFO,
                "echo with 2 parameters: %s, %d",
                "a",
                1
            )
            notify.echo(
                NotifyLevels.INFO,
                "echo with 3 parameters: %s, %d, %f",
                "a",
                1,
                3.12
            )
            assert_true(true)
        end)
        it("debug", function()
            notify.echo(NotifyLevels.DEBUG, "echo without parameters")
            notify.echo(NotifyLevels.DEBUG, "echo with 1 parameters: %s", "a")
            notify.echo(
                NotifyLevels.DEBUG,
                "echo with 2 parameters: %s, %d",
                "a",
                1
            )
            notify.echo(
                NotifyLevels.DEBUG,
                "echo with 3 parameters: %s, %d, %f",
                "a",
                1,
                3.12
            )
            assert_true(true)
        end)
        it("warn", function()
            notify.echo(NotifyLevels.WARN, "echo without parameters")
            notify.echo(NotifyLevels.WARN, "echo with 1 parameters: %s", "a")
            notify.echo(
                NotifyLevels.WARN,
                "echo with 2 parameters: %s, %d",
                "a",
                1
            )
            notify.echo(
                NotifyLevels.WARN,
                "echo with 3 parameters: %s, %d, %f",
                "a",
                1,
                3.12
            )
            assert_true(true)
        end)
        it("err", function()
            notify.echo(NotifyLevels.ERROR, "echo without parameters")
            notify.echo(NotifyLevels.ERROR, "echo with 1 parameters: %s", "a")
            notify.echo(
                NotifyLevels.ERROR,
                "echo with 2 parameters: %s, %d",
                "a",
                1
            )
            notify.echo(
                NotifyLevels.ERROR,
                "echo with 3 parameters: %s, %d, %f",
                "a",
                1,
                3.12
            )
            assert_true(true)
        end)
    end)
end)
