---@diagnostic disable: undefined-field, unused-local, missing-fields, need-check-nil, param-type-mismatch, assign-type-mismatch
local cwd = vim.fn.getcwd()

describe("detail.general", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false
  local assert_truthy = assert.is.truthy
  local assert_falsy = assert.is.falsy

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
    vim.env._FZFX_NVIM_DEBUG_ENABLE = 1
  end)

  local github_actions = os.getenv("GITHUB_ACTIONS") == "true"

  local tables = require("fzfx.commons.tables")
  local strings = require("fzfx.commons.strings")
  local fileios = require("fzfx.commons.fileios")
  local jsons = require("fzfx.commons.jsons")
  local paths = require("fzfx.commons.paths")

  local schema = require("fzfx.schema")
  local conf = require("fzfx.config")
  conf.setup()

  local general = require("fzfx.detail.general")

  describe("[ProviderSwitch:new]", function()
    it("creates single plain provider", function()
      local ps = general.ProviderSwitch:new("single_test", "pipeline", {
        key = "ctrl-k",
        provider = "ls -1",
      })
      assert_eq(type(ps), "table")
      assert_false(tables.tbl_empty(ps))
      assert_eq(type(ps.provider_configs.default), "table")
      assert_false(tables.tbl_empty(ps.provider_configs.default))
      assert_eq(ps.provider_configs.default.key, "ctrl-k")
      assert_eq(ps.provider_configs.default.provider, "ls -1")
      assert_eq(ps.provider_configs.default.provider_type, "plain")
      assert_eq(ps:switch("default"), nil)
      assert_eq(ps:provide("hello", {}), "plain")
      if not github_actions then
        local meta1 =
          fileios.readfile(general._provider_metafile(), { trim = true })
        local result1 =
          fileios.readfile(general._provider_resultfile(), { trim = true })
        print(string.format("metafile1:%s\n", meta1))
        local metajson1 = jsons.decode(meta1) --[[@as table]]
        assert_eq(type(metajson1), "table")
        assert_eq(metajson1.pipeline, "default")
        assert_eq(metajson1.provider_type, "plain")
        print(string.format("resultfile1:%s\n", result1))
        assert_eq(result1, "ls -1")
      end
    end)
    it("creates single plain_list provider", function()
      local ps =
        general.ProviderSwitch:new("single_plain_list_test", "pipeline", {
          key = "ctrl-k",
          provider = { "ls", "-lh", "~" },
        })
      assert_eq(type(ps), "table")
      assert_false(tables.tbl_empty(ps))
      assert_eq(type(ps.provider_configs.default), "table")
      assert_false(tables.tbl_empty(ps.provider_configs.default))
      assert_eq(ps.provider_configs.default.key, "ctrl-k")
      assert_eq(type(ps.provider_configs.default.provider), "table")
      assert_eq(#ps.provider_configs.default.provider, 3)
      assert_eq(ps.provider_configs.default.provider[1], "ls")
      assert_eq(ps.provider_configs.default.provider[2], "-lh")
      assert_eq(ps.provider_configs.default.provider[3], "~")
      assert_eq(ps.provider_configs.default.provider_type, "plain_list")
      assert_eq(ps:switch("default"), nil)
      assert_eq(ps:provide("hello", {}), "plain_list")
      if not github_actions then
        local meta2 =
          fileios.readfile(general._provider_metafile(), { trim = true })
        local result2 =
          fileios.readfile(general._provider_resultfile(), { trim = true })
        print(string.format("metafile2:%s\n", meta2))
        local metajson1 = jsons.decode(meta2) --[[@as table]]
        assert_eq(type(metajson1), "table")
        assert_eq(metajson1.pipeline, "default")
        assert_eq(metajson1.provider_type, "plain_list")
        print(string.format("resultfile2:%s\n", result2))
        local resultjson2 = jsons.decode(result2) --[[@as table]]
        assert_eq(type(resultjson2), "table")
        assert_eq(#resultjson2, 3)
        assert_eq(resultjson2[1], "ls")
        assert_eq(resultjson2[2], "-lh")
        assert_eq(resultjson2[3], "~")
      end
    end)
    it("creates multiple plain providers", function()
      local ps = general.ProviderSwitch:new("multiple_test", "pipeline", {
        p1 = {
          key = "ctrl-p",
          provider = "p1",
        },
        p2 = {
          key = "ctrl-q",
          provider = { "p2", "p3", "p4" },
        },
      })
      assert_eq(type(ps), "table")
      assert_false(tables.tbl_empty(ps))

      assert_eq(type(ps.provider_configs.p1), "table")
      assert_false(tables.tbl_empty(ps.provider_configs.p1))
      assert_eq(ps.provider_configs.p1.key, "ctrl-p")
      assert_eq(type(ps.provider_configs.p1.provider), "string")
      assert_eq(ps.provider_configs.p1.provider, "p1")
      assert_eq(ps.provider_configs.p1.provider_type, "plain")
      assert_eq(ps:switch("p1"), nil)
      assert_eq(ps:provide("hello", {}), "plain")
      if not github_actions then
        local meta3 =
          fileios.readfile(general._provider_metafile(), { trim = true })
        local result3 =
          fileios.readfile(general._provider_resultfile(), { trim = true })
        print(string.format("metafile3:%s\n", meta3))
        local metajson1 = jsons.decode(meta3) --[[@as table]]
        assert_eq(type(metajson1), "table")
        assert_eq(metajson1.pipeline, "p1")
        assert_eq(metajson1.provider_type, "plain")
        print(string.format("resultfile3:%s\n", result3))
        assert_eq(result3, "p1")
      end

      assert_eq(type(ps.provider_configs.p2), "table")
      assert_false(tables.tbl_empty(ps.provider_configs.p2))
      assert_eq(ps.provider_configs.p2.key, "ctrl-q")
      assert_eq(type(ps.provider_configs.p2.provider), "table")
      assert_eq(type(ps.provider_configs.p2.provider), "table")
      assert_eq(#ps.provider_configs.p2.provider, 3)
      assert_eq(ps.provider_configs.p2.provider[1], "p2")
      assert_eq(ps.provider_configs.p2.provider[2], "p3")
      assert_eq(ps.provider_configs.p2.provider[3], "p4")
      assert_eq(ps.provider_configs.p2.provider_type, "plain_list")
      assert_eq(ps:switch("p2"), nil)
      assert_eq(ps:provide("hello", {}), "plain_list")
      if not github_actions then
        local meta4 =
          fileios.readfile(general._provider_metafile(), { trim = true })
        local result4 =
          fileios.readfile(general._provider_resultfile(), { trim = true })
        print(string.format("metafile4:%s\n", meta4))
        local metajson1 = jsons.decode(meta4) --[[@as table]]
        assert_eq(type(metajson1), "table")
        assert_eq(metajson1.pipeline, "p2")
        assert_eq(metajson1.provider_type, "plain_list")
        print(string.format("resultfile4:%s\n", result4))
        local resultjson4 = jsons.decode(result4) --[[@as table]]
        assert_eq(type(resultjson4), "table")
        assert_eq(#resultjson4, 3)
        assert_eq(resultjson4[1], "p2")
        assert_eq(resultjson4[2], "p3")
        assert_eq(resultjson4[3], "p4")
      end
    end)
  end)
  describe("[PreviewerSwitch:preview]", function()
    local FZFPORTFILE = general._make_cache_filename("fzf_port_file")
    it("is a plain/plain_list provider", function()
      local ps = general.PreviewerSwitch:new("plain_test", "p1", {
        p1 = {
          previewer = function()
            return "ls -lh"
          end,
        },
        p2 = {
          previewer = function()
            return { "ls", "-lha", "~" }
          end,
          previewer_type = "command_list",
        },
      }, FZFPORTFILE)
      print(string.format("GITHUB_ACTIONS:%s\n", os.getenv("GITHUB_ACTIONS")))
      assert_eq(ps:preview("hello", {}), "command")
      if not github_actions then
        local meta1 =
          fileios.readfile(general._previewer_metafile(), { trim = true })
        local result1 =
          fileios.readfile(general._previewer_resultfile(), { trim = true })
        print(string.format("metafile1:%s\n", meta1))
        local metajson1 = jsons.decode(meta1) --[[@as table]]
        assert_eq(type(metajson1), "table")
        assert_eq(metajson1.pipeline, "p1")
        assert_eq(metajson1.previewer_type, "command")
        print(string.format("resultfile1:%s\n", result1))
        assert_eq(result1, "ls -lh")
      end
      ps:switch("p2")
      assert_eq(ps:preview("world", {}), "command_list")
      if not github_actions then
        local meta2 =
          fileios.readfile(general._previewer_metafile(), { trim = true })
        local result2 =
          fileios.readfile(general._previewer_resultfile(), { trim = true })
        print(string.format("metafile2:%s\n", meta2))
        local metajson2 = jsons.decode(meta2) --[[@as table]]
        assert_eq(type(metajson2), "table")
        assert_eq(metajson2.pipeline, "p2")
        assert_eq(metajson2.previewer_type, "command_list")
        print(string.format("resultfile2:%s\n", result2))
        local resultjson2 = jsons.decode(result2) --[[@as table]]
        assert_eq(type(resultjson2), "table")
        assert_eq(#resultjson2, 3)
        assert_eq(resultjson2[1], "ls")
        assert_eq(resultjson2[2], "-lha")
        assert_eq(resultjson2[3], "~")
      end
    end)
    it("is a command/command_list provider", function()
      local ps = general.PreviewerSwitch:new("command_test", "p1", {
        p1 = {
          previewer = function()
            return "ls -lh"
          end,
          previewer_type = schema.ProviderTypeEnum.COMMAND,
        },
        p2 = {
          previewer = function()
            return { "ls", "-lha", "~" }
          end,
          previewer_type = schema.ProviderTypeEnum.COMMAND_LIST,
        },
      }, FZFPORTFILE)
      assert_eq(ps:preview("hello", {}), "command")
      if not github_actions then
        local meta1 =
          fileios.readfile(general._previewer_metafile(), { trim = true })
        local result1 =
          fileios.readfile(general._previewer_resultfile(), { trim = true })
        print(string.format("metafile:%s\n", meta1))
        local metajson1 = jsons.decode(meta1) --[[@as table]]
        assert_eq(type(metajson1), "table")
        assert_eq(metajson1.pipeline, "p1")
        assert_eq(metajson1.previewer_type, "command")
        print(string.format("resultfile:%s\n", result1))
        assert_eq(result1, "ls -lh")
      end
      ps:switch("p2")
      assert_eq(ps:preview("world", {}), "command_list")
      if not github_actions then
        local meta2 =
          fileios.readfile(general._previewer_metafile(), { trim = true })
        local result2 =
          fileios.readfile(general._previewer_resultfile(), { trim = true })
        print(string.format("metafile:%s\n", meta2))
        local metajson2 = jsons.decode(meta2) --[[@as table]]
        assert_eq(type(metajson2), "table")
        assert_eq(metajson2.pipeline, "p2")
        assert_eq(metajson2.previewer_type, "command_list")
        print(string.format("resultfile:%s\n", result2))
        local resultjson2 = jsons.decode(result2) --[[@as table]]
        assert_eq(type(resultjson2), "table")
        assert_eq(#resultjson2, 3)
        assert_eq(resultjson2[1], "ls")
        assert_eq(resultjson2[2], "-lha")
        assert_eq(resultjson2[3], "~")
      end
    end)
  end)
  describe("[PreviewerSwitch:new]", function()
    local FZFPORTFILE = general._make_cache_filename("fzf_port_file")
    it("creates single command previewer", function()
      local ps = general.PreviewerSwitch:new("single", "pipeline", {
        previewer = function()
          return "ls -1"
        end,
      }, FZFPORTFILE)
      assert_eq(type(ps), "table")
      assert_false(tables.tbl_empty(ps))
      assert_eq(type(ps.previewer_configs), "table")
      assert_false(tables.tbl_empty(ps.previewer_configs))
      assert_eq(type(ps.previewer_configs.default.previewer), "function")
      assert_eq(ps.previewer_configs.default.previewer(), "ls -1")
      assert_eq(ps.previewer_configs.default.previewer_type, "command")
      assert_eq(ps.fzf_port_file, FZFPORTFILE)
      assert_eq(ps:switch("default"), nil)
    end)
    it("creates multiple command previewer", function()
      local ps = general.PreviewerSwitch:new("single", "pipeline", {
        p1 = {
          previewer = function()
            return "p1"
          end,
        },
        p2 = {
          previewer = function()
            return "p2"
          end,
        },
      }, FZFPORTFILE)
      assert_eq(type(ps), "table")
      assert_false(tables.tbl_empty(ps))
      assert_eq(type(ps.previewer_configs), "table")
      assert_false(tables.tbl_empty(ps.previewer_configs))
      assert_eq(type(ps.previewer_configs.p1.previewer), "function")
      assert_eq(ps.previewer_configs.p1.previewer(), "p1")
      assert_eq(ps.previewer_configs.p1.previewer_type, "command")
      assert_eq(ps:switch("p1"), nil)

      assert_eq(type(ps.previewer_configs), "table")
      assert_false(tables.tbl_empty(ps.previewer_configs))
      assert_eq(type(ps.previewer_configs.p2.previewer), "function")
      assert_eq(ps.previewer_configs.p2.previewer(), "p2")
      assert_eq(ps.previewer_configs.p2.previewer_type, "command")
      assert_eq(ps:switch("p2"), nil)
    end)
  end)
  describe("[PreviewerSwitch:preview_label]", function()
    local FZFPORTFILE = general._make_cache_filename("fzf_port_file")
    it("not previews label", function()
      local name = "label_test1"
      fileios.writefile(FZFPORTFILE, "12345")
      local ps = general.PreviewerSwitch:new(name, "p1", {
        p1 = {
          previewer = function()
            return "ls -lh"
          end,
        },
        p2 = {
          previewer = function()
            return { "ls", "-lha", "~" }
          end,
          previewer_type = "command_list",
        },
      }, FZFPORTFILE)
      print(string.format("GITHUB_ACTIONS:%s\n", os.getenv("GITHUB_ACTIONS")))
      assert_true(ps:preview_label("hello", {}) == nil)
      ps:switch("p2")
      assert_true(ps:preview_label("world", {}) == nil)
    end)
    it("previews label", function()
      local name = "label_test2"
      fileios.writefile(FZFPORTFILE, "54321")
      local ps = general.PreviewerSwitch:new(name, "p1", {
        p1 = {
          previewer = function()
            return "ls -lh"
          end,
          previewer_label = function(line)
            return nil
          end,
        },
        p2 = {
          previewer = function()
            return { "ls", "-lha", "~" }
          end,
          previewer_type = "command_list",
          previewer_label = function(line)
            return nil
          end,
        },
      }, FZFPORTFILE)
      print(string.format("GITHUB_ACTIONS:%s\n", os.getenv("GITHUB_ACTIONS")))
      assert_true(ps:preview_label("hello", {}) == "p1")
      ps:switch("p2")
      assert_true(ps:preview_label("world", {}) == "p2")
    end)
  end)
  describe("[_render_help]", function()
    it("renders1", function()
      local actual = general._render_help("doc1", "bs")
      print(string.format("render help1:%s\n", actual))
      assert_true(actual:gmatch("to doc1") ~= nil)
      assert_true(actual:gmatch("BS") ~= nil)
      assert_true(strings.find(actual, "to doc1") > strings.find(actual, "BS"))
    end)
    it("renders2", function()
      local actual = general._render_help("do_it", "ctrl")
      print(string.format("render help2:%s\n", actual))
      assert_true(actual:gmatch("to do it") ~= nil)
      assert_true(actual:gmatch("CTRL") ~= nil)
      assert_true(
        strings.find(actual, "to do it") > strings.find(actual, "CTRL")
      )
    end)
    it("renders3", function()
      local actual = general._render_help("ok_ok", "alt")
      print(string.format("render help3:%s\n", actual))
      assert_true(actual:gmatch("to ok ok") ~= nil)
      assert_true(actual:gmatch("ALT") ~= nil)
      assert_true(
        strings.find(actual, "to ok ok") > strings.find(actual, "ALT")
      )
    end)
  end)
  describe("[_should_skip_help]", function()
    it("skip1", function()
      local actual = general._should_skip_help(nil, "bs")
      assert_false(actual)
    end)
    it("skip2", function()
      local actual = general._should_skip_help({}, "bs")
      assert_false(actual)
    end)
    it("skip3", function()
      local actual = general._should_skip_help({ "bs" }, "bs")
      assert_true(actual)
    end)
  end)
  describe("[make_help_doc]", function()
    it("make1", function()
      local action_configs = {
        action1 = {
          key = "ctrl-l",
        },
        upper = {
          key = "ctrl-u",
        },
      }
      local actual = general._make_help_doc(action_configs, {})
      assert_eq(type(actual), "table")
      assert_eq(#actual, 2)
      assert_true(
        strings.find(actual[1], "to action1")
          > strings.find(actual[1], "CTRL-L")
      )
      assert_true(strings.endswith(actual[1], "to action1"))
      assert_true(
        strings.find(actual[2], "to upper") > strings.find(actual[2], "CTRL-U")
      )
      assert_true(strings.endswith(actual[2], "to upper"))
    end)
    it("make2", function()
      local action_configs = {
        action1 = {
          key = "ctrl-l",
        },
        upper = {
          key = "ctrl-u",
        },
        goto_inter = {
          key = "alt-p",
        },
      }
      local actual = general._make_help_doc(action_configs, {})
      assert_eq(type(actual), "table")
      assert_eq(#actual, 3)
      assert_true(
        strings.find(actual[1], "to action1")
          > strings.find(actual[1], "CTRL-L")
      )
      assert_true(strings.endswith(actual[1], "to action1"))
      assert_true(
        strings.find(actual[2], "to goto inter")
          > strings.find(actual[2], "ALT-P")
      )
      assert_true(strings.endswith(actual[2], "to goto inter"))
      assert_true(
        strings.find(actual[3], "to upper") > strings.find(actual[3], "CTRL-U")
      )
      assert_true(strings.endswith(actual[3], "to upper"))
    end)
  end)
  describe("[_make_cache_filename]", function()
    it("is debug mode", function()
      vim.env._FZFX_NVIM_DEBUG_ENABLE = 1
      assert_eq(
        general._make_cache_filename("provider", "switch", "meta", "live_grep"),
        paths.join(
          conf.get_config().cache.dir,
          "provider_switch_meta_live_grep"
        )
      )
    end)
    it("is not debug mode", function()
      vim.env._FZFX_NVIM_DEBUG_ENABLE = 0
      local actual =
        general._make_cache_filename("provider", "switch", "meta", "live_grep")
      print(
        string.format("make cache filename (non-debug):%s", vim.inspect(actual))
      )
      assert_true(
        actual
          ~= paths.join(
            vim.fn.stdpath("data"),
            "provider_switch_meta_live_grep"
          )
      )
    end)
  end)
  describe("[make_provider_meta_opts]", function()
    it("makes without icon", function()
      local actual1 = general.make_provider_meta_opts("test1", {
        key = "test1",
        provider_type = "command",
      })
      assert_eq(type(actual1), "table")
      assert_eq(actual1.pipeline, "test1")
      assert_eq(actual1.provider_type, "command")
      local actual2 = general.make_provider_meta_opts("test2", {
        key = "test2",
        provider_type = "command_list",
      })
      assert_eq(type(actual2), "table")
      assert_eq(actual2.pipeline, "test2")
      assert_eq(actual1.provider_type, "command")
    end)
    it("makes with icon", function()
      local actual = general.make_provider_meta_opts("test3", {
        key = "test3",
        provider_type = "list",
      })
      assert_eq(type(actual), "table")
      assert_eq(actual.pipeline, "test3")
      assert_eq(actual.provider_type, "list")
    end)
  end)
  describe("[make_previewer_meta_opts]", function()
    it("makes without icon", function()
      local actual1 = general.make_previewer_meta_opts("test1", {
        previewer = function() end,
        previewer_type = "command",
      })
      assert_eq(type(actual1), "table")
      assert_eq(actual1.pipeline, "test1")
      assert_eq(actual1.previewer_type, "command")
      local actual2 = general.make_previewer_meta_opts("test2", {
        previewer = function() end,
        previewer_type = "command_list",
      })
      assert_eq(type(actual2), "table")
      assert_eq(actual2.pipeline, "test2")
      assert_eq(actual2.previewer_type, "command_list")
    end)
    it("makes with icon", function()
      local actual = general.make_previewer_meta_opts("test3", {
        previewer = function() end,
        previewer_type = "list",
      })
      assert_eq(type(actual), "table")
      assert_eq(actual.pipeline, "test3")
      assert_eq(actual.previewer_type, "list")
    end)
  end)
  describe("[_make_user_command]", function()
    it("makes", function()
      local actual = general._make_user_command(
        "live_grep_test",
        conf.get_config().live_grep.commands[1],
        conf.get_config().live_grep
      )
      assert_true(actual == nil)
    end)
  end)
  describe("[_send_http_post]", function()
    it("send", function()
      local ok, err = pcall(general._send_http_post, "12345", "asdf")
      assert_eq(type(ok), "boolean")
      assert_true(type(err) == "string" or err == nil)
    end)
  end)
end)
