local gh = function(repo)
    return 'https://github.com/' .. repo
end

vim.pack.add {gh 'mason-org/mason.nvim', gh 'WhoIsSethDaniel/mason-tool-installer.nvim'}

require('mason').setup()

require('mason-tool-installer').setup {
    ensure_installed = { -- LSP-серверы
    'html-lsp', 'css-lsp', 'vtsls', 'emmet-language-server', 'eslint-lsp',

    -- Инструменты для твоего conform.lua
    'prettierd', 'eslint_d'}
}
