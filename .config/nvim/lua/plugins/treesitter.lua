return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "lua", "vim", "vimdoc", "bash", "python", "c", "dart", "yaml", "json", "markdown" },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}