return {
  {
    "slugbyte/lackluster.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("lackluster")  -- тема по умолчанию
    end,
  }
}