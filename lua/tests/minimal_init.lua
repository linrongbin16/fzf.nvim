vim.o.number = true
vim.o.autoread = true
vim.o.autowrite = true
vim.o.swapfile = false
vim.o.confirm = true

local lazypath = vim.fn.expand("<sfile>:p:h") .. "/lazy/lazy.nvim"
print("lazypath:" .. lazypath)

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local opts = {
    root = vim.fn.expand("<sfile>:p:h") .. "/lazy",
    defaults = { lazy = false },
}

require("lazy").setup({
    "nvim-tree/nvim-web-devicons",
    {
        "junegunn/fzf",
        build = ":call fzf#install()",
    },
    {
        "linrongbin16/fzfx.nvim",
        dev = true,
        dir = "~/github/linrongbin16/fzfx.nvim",
        opts = {},
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "junegunn/fzf",
        },
    },
}, opts)

require("lazy").sync({ wait = true, show = false })
