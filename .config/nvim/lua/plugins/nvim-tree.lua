return {
  "nvim-tree/nvim-tree.lua",
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Дерево файлов" },
  },
  opts = {
    hijack_cursor = true,  -- держать курсор в начале имени, а не где попало
    view = {
      side = "left",
      width = 30,
      cursorline = true,   -- подсвечивать текущую строку
    },
    renderer = {
      group_empty = true,
      icons = {
        show = {
          file = false,
          folder = false,
          folder_arrow = true,
          git = false,
        },
        glyphs = {
          folder = {
            arrow_closed = ">",
            arrow_open = "v",
          },
        },
      },
    },
    filters = {
      dotfiles = false,
    },
  },
  config = function(_, opts)
    require("nvim-tree").setup(opts)

    -- прозрачный курсор
    vim.api.nvim_set_hl(0, "HiddenCursor", { blend = 100, nocombine = true })

    local group = vim.api.nvim_create_augroup("NvimTreeHideCursor", { clear = true })

    -- зашёл в дерево — спрятать курсор
    vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
      group = group,
      pattern = "NvimTree_*",
      callback = function()
        vim.opt.guicursor:append("a:HiddenCursor")
      end,
    })

    -- вышел из дерева — вернуть курсор
    vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
      group = group,
      pattern = "NvimTree_*",
      callback = function()
        vim.opt.guicursor:remove("a:HiddenCursor")
      end,
    })
  end,
}