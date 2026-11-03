return {
  "aikhe/fleur.nvim",
  priority = 1000,
  config = function()
    require("fleur").setup({ mode = "dark" })

    -- раскрашиваем код цветами палитры fleur
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "fleur*",
      callback = function()
        local p = require("fleur.palette.dark")
        local hl = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end

        -- ключевые слова: if, for, return, while...
        for _, g in ipairs({ "Keyword", "Statement", "Conditional", "Repeat",
                             "@keyword", "@keyword.return", "@keyword.conditional",
                             "@keyword.repeat", "@keyword.function" }) do
          hl(g, { fg = p.coquelicot })
        end

        -- строки
        hl("String", { fg = p.bruyere })
        hl("@string", { fg = p.bruyere })
        hl("Character", { fg = p.bruyere })

        -- функции
        hl("Function", { fg = p.bleuet })
        hl("@function", { fg = p.bleuet })
        hl("@function.call", { fg = p.bleuet })
        hl("@function.builtin", { fg = p.bleuet })

        -- типы: int, char, struct...
        hl("Type", { fg = p.zinnia })
        hl("@type", { fg = p.zinnia })
        hl("@type.builtin", { fg = p.zinnia })

        -- числа, константы, true/false
        for _, g in ipairs({ "Number", "Boolean", "Constant", "@number",
                             "@boolean", "@constant", "@constant.builtin" }) do
          hl(g, { fg = p.lulumi })
        end

        -- #include, #define, макросы
        hl("PreProc", { fg = p.lis })
        hl("@keyword.directive", { fg = p.lis })
        hl("@constant.macro", { fg = p.lis })

        -- параметры функций и поля структур
        hl("@variable.parameter", { fg = p.lis })
        hl("@variable.member", { fg = p.gray8 })

        -- комментарии
        hl("Comment", { fg = p.gray5, italic = true })
        hl("@comment", { fg = p.gray5, italic = true })
      end,
    })

    vim.cmd.colorscheme("fleur")
  end,
}
