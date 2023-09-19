local cwd = vim.fn.getcwd()

describe("general", function()
    local assert_eq = assert.are.equal
    local assert_neq = assert.are_not.equal
    local assert_true = assert.is_true
    local assert_false = assert.is_false
    local assert_truthy = assert.is.truthy
    local assert_falsy = assert.is.falsy

    before_each(function()
        vim.api.nvim_command("cd " .. cwd)
    end)

    local general = require("fzfx.general")
    local ProviderConfig = require("fzfx.schema").ProviderConfig
    describe("[ProviderSwitch:new]", function()
        it("creates single plain provider", function()
            local ps = general.ProviderSwitch:new(
                "single",
                "pipeline",
                ProviderConfig:make({
                    key = "ctrl-k",
                    provider = "ls -1",
                })
            )
            assert_eq(type(ps), "table")
            assert_false(vim.tbl_isempty(ps))
            assert_eq(type(ps.provider_configs.default), "table")
            assert_false(vim.tbl_isempty(ps.provider_configs.default))
            assert_eq(ps.provider_configs.default.key, "ctrl-k")
            assert_eq(ps.provider_configs.default.provider, "ls -1")
            assert_eq(ps.provider_configs.default.provider_type, "plain")
        end)
        it("creates single plain_list provider", function()
            local ps = general.ProviderSwitch:new(
                "single",
                "pipeline",
                ProviderConfig:make({
                    key = "ctrl-k",
                    provider = { "ls", "-1" },
                })
            )
            assert_eq(type(ps), "table")
            assert_false(vim.tbl_isempty(ps))
            assert_eq(type(ps.provider_configs.default), "table")
            assert_false(vim.tbl_isempty(ps.provider_configs.default))
            assert_eq(ps.provider_configs.default.key, "ctrl-k")
            assert_eq(type(ps.provider_configs.default.provider), "table")
            assert_eq(#ps.provider_configs.default.provider, 2)
            assert_eq(ps.provider_configs.default.provider[1], "ls")
            assert_eq(ps.provider_configs.default.provider[2], "-1")
            assert_eq(ps.provider_configs.default.provider_type, "plain_list")
        end)
        it("creates multiple providers", function()
            local ps = general.ProviderSwitch:new("single", "pipeline", {
                p1 = ProviderConfig:make({
                    key = "ctrl-p",
                    provider = "p1",
                }),
                p2 = ProviderConfig:make({
                    key = "ctrl-q",
                    provider = "p2",
                }),
            })
            assert_eq(type(ps), "table")
            assert_false(vim.tbl_isempty(ps))

            assert_eq(type(ps.provider_configs.p1), "table")
            assert_false(vim.tbl_isempty(ps.provider_configs.p1))
            assert_eq(ps.provider_configs.p1.key, "ctrl-p")
            assert_eq(type(ps.provider_configs.p1.provider), "string")
            assert_eq(ps.provider_configs.p1.provider, "p1")
            assert_eq(ps.provider_configs.p1.provider_type, "plain")

            assert_eq(type(ps.provider_configs.p2), "table")
            assert_false(vim.tbl_isempty(ps.provider_configs.p2))
            assert_eq(ps.provider_configs.p2.key, "ctrl-q")
            assert_eq(type(ps.provider_configs.p2.provider), "string")
            assert_eq(ps.provider_configs.p2.provider, "p2")
            assert_eq(ps.provider_configs.p2.provider_type, "plain")
        end)
    end)
end)
