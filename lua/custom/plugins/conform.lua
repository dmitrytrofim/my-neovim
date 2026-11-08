-- lua/custom/plugins/conform.lua
vim.pack.add {'https://github.com/stevearc/conform.nvim'}

require('conform').setup {
    -- Включаем форматирование при сохранении
    format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback" -- Если нет prettier/eslint, пробуем через LSP
    },
    formatters_by_ft = {
        -- Для JS/TS используем ESLint
        javascript = {"eslint"},
        typescript = {"eslint"},
        javascriptreact = {"eslint"},
        typescriptreact = {"eslint"},

        -- Для стилей — Prettier
        css = {"prettier"},
        scss = {"prettier"},
        html = {"prettier"}
    },
    formatters = {
        prettier = {
            -- Принудительно 4 пробела
            prepend_args = {"--tab-width", "4", "--use-tabs", "false", "--html-whitespace-sensitivity", "ignore",
                            "--bracket-same-line"}
        }
    }
}

-- На всякий случай (если у тебя не объявлено в keymaps.lua): 
-- добавь маппинг для форматирования
vim.keymap.set({"n", "v"}, "<leader>f", function()
    require("conform").format({
        async = true,
        lsp_format = "fallback"
    })
end, {
    desc = "Format buffer"
})
