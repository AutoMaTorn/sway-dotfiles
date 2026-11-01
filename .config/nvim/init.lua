-- Конфиг для neovim

-- нормальные циферки и подсветка текущей строки)
vim.opt.number = true
vim.opt.cursorline = true

-- поиск
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.splitright = true
vim.opt.splitbelow = true  
vim.opt.updatetime = 250 

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>w", ":w<CR>") -- space+w = сохранить
vim.keymap.set("n", "<leader>q", ":q<CR>") -- space+q = выйти
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")  -- Esc убирает подсветку поиска

--lazy.nvim если нет то скачать
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- загрузить плагины из lua/plugins
require("lazy").setup("plugins")

