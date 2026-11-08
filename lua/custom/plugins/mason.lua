-- lua/custom/plugins/mason.lua
vim.pack.add {'https://github.com/mason-org/mason.nvim'}

require('mason').setup {
    ensure_installed = {"html-lsp", -- Оставляем только чистый HTML сервер
    "css-lsp"}
}
