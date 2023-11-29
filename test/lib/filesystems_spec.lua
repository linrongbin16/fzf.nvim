---@diagnostic disable: undefined-field, unused-local
local cwd = vim.fn.getcwd()

describe("lib.filesystems", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local strs = require("fzfx.lib.strings")
  local fs = require("fzfx.lib.filesystems")

  describe("[readfile/readlines]", function()
    it("readfile and FileLineReader", function()
      local content = fs.readfile("README.md")
      local reader = fs.FileLineReader:open("README.md") --[[@as fzfx.FileLineReader]]
      local buffer = nil
      assert_eq(type(reader), "table")
      while reader:has_next() do
        local line = reader:next() --[[@as string]]
        assert_eq(type(line), "string")
        assert_true(string.len(line) >= 0)
        buffer = buffer and (buffer .. line .. "\n") or (line .. "\n")
      end
      reader:close()
      assert_eq(strs.rtrim(buffer --[[@as string]]), content)
    end)
    it("readfile and readlines", function()
      local content = fs.readfile("README.md")
      local lines = fs.readlines("README.md")
      local buffer = nil
      for _, line in
        ipairs(lines --[[@as table]])
      do
        assert_eq(type(line), "string")
        assert_true(string.len(line) >= 0)
        buffer = buffer and (buffer .. line .. "\n") or (line .. "\n")
      end
      assert_eq(strs.rtrim(buffer --[[@as string]]), content)
    end)
  end)
  describe("[writefile/writelines]", function()
    it("writefile and writelines", function()
      local content = fs.readfile("README.md") --[[@as string]]
      local lines = fs.readlines("README.md") --[[@as table]]

      local t1 = "writefile-test1-README.md"
      local t2 = "writefile-test2-README.md"
      fs.writefile(t1, content)
      fs.writelines(t2, lines)

      content = fs.readfile(t1) --[[@as string]]
      lines = fs.readlines(t2) --[[@as table]]

      local buffer = nil
      for _, line in
        ipairs(lines --[[@as table]])
      do
        assert_eq(type(line), "string")
        assert_true(string.len(line) >= 0)
        buffer = buffer and (buffer .. line .. "\n") or (line .. "\n")
      end
      assert_eq(strs.rtrim(buffer --[[@as string]]), content)
      local j1 = vim.fn.jobstart(
        { "rm", t1 },
        { on_stdout = function() end, on_stderr = function() end }
      )
      local j2 = vim.fn.jobstart(
        { "rm", t2 },
        { on_stdout = function() end, on_stderr = function() end }
      )
      vim.fn.jobwait({ j1, j2 })
    end)
  end)
  describe("[asyncwritefile]", function()
    it("write", function()
      local t = "asyncwritefile-test.txt"
      local content = "hello world, goodbye world!"
      fs.asyncwritefile(t, content, function(bytes)
        assert_eq(bytes, #content)
      end)
    end)
  end)
  describe("[asyncreadfile]", function()
    it("read", function()
      local t = "README.md"
      fs.asyncreadfile(t, function(content)
        assert_true(string.len(content) > 0)
      end)
    end)
  end)
end)
