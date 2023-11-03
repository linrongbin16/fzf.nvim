local cwd = vim.fn.getcwd()

describe("module", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  require("fzfx.config").setup()
  require("fzfx.module").setup()
  local log = require("fzfx.log")
  local LogLevels = require("fzfx.log").LogLevels
  local LogLevelNames = require("fzfx.log").LogLevelNames
  log.setup({
    level = "DEBUG",
    console_log = true,
    file_log = true,
  })
  local conf = require("fzfx.config")
  local module = require("fzfx.module")
  local utils = require("fzfx.utils")
  describe("[module]", function()
    it("setup", function()
      conf.setup()
      module.setup()
      print(
        string.format(
          "_FZFX_NVIM_DEBUG_ENABLE:%s\n",
          vim.inspect(vim.env._FZFX_NVIM_DEBUG_ENABLE)
        )
      )
      print(
        string.format(
          "_FZFX_NVIM_DEVICONS_PATH:%s\n",
          vim.inspect(vim.env._FZFX_NVIM_DEVICONS_PATH)
        )
      )
      print(
        string.format(
          "_FZFX_NVIM_UNKNOWN_FILE_ICON:%s\n",
          vim.inspect(vim.env._FZFX_NVIM_UNKNOWN_FILE_ICON)
        )
      )
      print(
        string.format(
          "_FZFX_NVIM_FILE_FOLDER_ICON:%s\n",
          vim.inspect(vim.env._FZFX_NVIM_FILE_FOLDER_ICON)
        )
      )
      print(
        string.format(
          "_FZFX_NVIM_FILE_FOLDER_OPEN_ICON:%s\n",
          vim.inspect(vim.env._FZFX_NVIM_FILE_FOLDER_OPEN_ICON)
        )
      )
      assert_eq(vim.env._FZFX_NVIM_DEBUG_ENABLE, "0")
      assert_true(
        vim.env._FZFX_NVIM_DEVICONS_PATH == nil
          or (
            type(vim.env._FZFX_NVIM_DEVICONS_PATH) == "string"
            and type(
                utils.string_find(
                  vim.env._FZFX_NVIM_DEVICONS_PATH,
                  "nvim-web-devicons"
                )
              )
              == "number"
          )
      )
      assert_true(vim.env._FZFX_NVIM_UNKNOWN_FILE_ICON == nil)
      assert_true(vim.env._FZFX_NVIM_FILE_FOLDER_ICON == nil)
      assert_true(vim.env._FZFX_NVIM_FILE_FOLDER_OPEN_ICON == nil)
      assert_eq(type(module.plugin_home_dir()), "string")
      assert_true(string.len(module.plugin_home_dir()) > 0)
      assert_eq(
        type(utils.string_find(module.plugin_home_dir(), "fzfx.nvim")),
        "number"
      )
      assert_true(utils.string_find(module.plugin_home_dir(), "fzfx.nvim") > 0)
    end)
  end)
end)
