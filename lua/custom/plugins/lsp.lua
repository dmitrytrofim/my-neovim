-- 1. Глобальные настройки для ВСЕХ серверов
vim.lsp.config('*', {
    handlers = {
        ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
            border = 'rounded',
            focusable = true
        })
    }
})

-- 2. Настройки конкретных серверов
local servers = {'html', 'cssls', 'jsonls', 'emmet_language_server' -- 'ts_ls',
-- 'eslint',
}

-- Безопасно получаем capabilities от blink.cmp (он сам включит snippetSupport)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_blink, blink = pcall(require, 'blink.cmp')
if has_blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
else
    -- Фоллбек на случай, если blink не загружен (хотя он должен быть)
    capabilities.textDocument.completion.completionItem.snippetSupport = true
end

-- Применяем capabilities к HTML, чтобы он начал отдавать теги и атрибуты
vim.lsp.config('html', {
    capabilities = capabilities
})

-- Настройка CSS (отключаем ругань на пустые классы)
vim.lsp.config('cssls', {
    capabilities = capabilities,
    settings = {
        css = {
            lint = {
                emptyRules = 'ignore'
            }
        },
        scss = {
            lint = {
                emptyRules = 'ignore'
            }
        },
        less = {
            lint = {
                emptyRules = 'ignore'
            }
        }
    }
})

-- Настройка Emmet (не показывать назойливые подсказки)
vim.lsp.config('emmet_language_server', {
    capabilities = capabilities,
    init_options = {
        showExpandedAbbreviation = 'never',
        showAbbreviationSuggestions = false
    }
})

-- 3. Установка и включение через Mason
require('mason-lspconfig').setup {
    ensure_installed = servers,
    automatic_installation = true
}

for _, server in ipairs(servers) do
    vim.lsp.enable(server)
end
