---@diagnostic disable: undefined-field, unused-local, missing-fields, need-check-nil, param-type-mismatch, assign-type-mismatch, redundant-parameter
local cwd = vim.fn.getcwd()

describe("helper.contexts", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
    vim.opt.swapfile = false
  end)

  local tbls = require("fzfx.lib.tables")
  local contexts = require("fzfx.helper.contexts")

  describe("[make_pipeline_context]", function()
    it("test", function()
      local actual = contexts.make_pipeline_context()
      assert_true(tbls.tbl_not_empty(actual))
      assert_eq(type(actual.bufnr), "number")
      assert_eq(type(actual.winnr), "number")
      assert_eq(type(actual.tabnr), "number")
    end)
  end)
end)
