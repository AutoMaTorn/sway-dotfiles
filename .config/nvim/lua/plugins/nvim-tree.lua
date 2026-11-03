return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Дерево файлов" },
    { "<leader>o", "<cmd>NvimTreeFindFile<cr>", desc = "Показать файл в дереве" },
  },
  opts = {
    hijack_cursor = true,
    view = {
      side = "left",
      width = 30,
      cursorline = true,
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

    -- прозрачный курсор в дереве
    vim.api.nvim_set_hl(0, "HiddenCursor", { blend = 100, nocombine = true })

    local group = vim.api.nvim_create_augroup("NvimTreeHideCursor", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
      group = group,
      pattern = "NvimTree_*",
      callback = function()
        vim.opt.guicursor:append("a:HiddenCursor")
      end,
    })

    vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
      group = group,
      pattern = "NvimTree_*",
      callback = function()
        vim.opt.guicursor:remove("a:HiddenCursor")
      end,
    })

    -- если осталось только дерево — закрыть nvim
    vim.api.nvim_create_autocmd("QuitPre", {
      group = group,
      callback = function()
        local normal = 0
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(w)
          if vim.bo[buf].filetype ~= "NvimTree"
            and vim.api.nvim_win_get_config(w).relative == "" then
            normal = normal + 1
          end
        end
        if normal == 1 then
          vim.cmd("NvimTreeClose")
        end
      end,
    })

    -- fleur перезаписывает подсветку при смене темы — вернуть прозрачный курсор
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = function()
        vim.api.nvim_set_hl(0, "HiddenCursor", { blend = 100, nocombine = true })
      end,
    })
  end,
}
