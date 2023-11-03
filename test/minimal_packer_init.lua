vim.o.number = true
vim.o.autoread = true
vim.o.autowrite = true
vim.o.swapfile = false
vim.o.confirm = true
vim.o.termguicolors = true

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data")
    .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
    })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
  use("wbthomason/packer.nvim")
  use("folke/tokyonight.nvim")
  use("nvim-tree/nvim-web-devicons")
  use({ "junegunn/fzf", run = ":call fzf#install()" })
  use({
    vim.fn.expand("~/github/linrongbin16/fzfx.nvim"),
    config = function()
      require("fzfx").setup({
        debug = { enable = false, file_log = true },
      })
    end,
  })

  if packer_bootstrap then
    require("packer").sync()
  end
end)

vim.cmd([[
colorscheme tokyonight
]])
