---@diagnostic disable: undefined-field
local cwd = vim.fn.getcwd()

describe("lib.numbers", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local libnu = require("fzfx.lib.numbers")

  describe("[test]", function()
    it("INT32_MIN/INT32_MAX", function()
      assert_eq(libnu.INT32_MAX, 2 ^ 31 - 1)
      assert_eq(libnu.INT32_MIN, -(2 ^ 31))
    end)
    it("bound", function()
      assert_eq(libnu.bound(5, 1, 3), 3)
      assert_eq(libnu.bound(2, 1, 13), 2)
      assert_eq(libnu.bound(77), 77)
      assert_eq(libnu.bound(77, nil, 29), 29)
    end)
    it("uuid", function()
      assert_true(string.len(libnu.uuid()) > 0)
      assert_true(string.len(libnu.uuid(".")) > 0)
    end)
    it("inc_id", function()
      assert_true(libnu.inc_id() == libnu.inc_id() - 1)
    end)
  end)
end)
