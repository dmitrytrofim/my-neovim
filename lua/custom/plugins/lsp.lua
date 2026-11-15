-- 1. Настройка хоткея K (hover) с рамкой и фокусом для всех LSP-серверов
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('CustomLspHover', {
        clear = true
    }),
    callback = function(event)
        vim.keymap.set('n', 'K', function()
            vim.lsp.buf.hover {
                border = 'rounded',
                focusable = true
            }
        end, {
            buffer = event.buf,
            desc = 'LSP: Hover Documentation'
        })
    end
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
    capabilities.textDocument.completion.completionItem.snippetSupport = true
end

-- Применяем capabilities ко всем серверам глобально (Vim 0.12+ way)
vim.lsp.config('*', {
    capabilities = capabilities
})

-- Настройка CSS (отключаем ругань на пустые классы)
vim.lsp.config('cssls', {
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

-- Настройка Emmet (разворачиваем сокращения, но отключаем назойливые автоподсказки)
vim.lsp.config('emmet_language_server', {
    init_options = {
        showExpandedAbbreviation = 'always',
        showAbbreviationSuggestions = false
    }
})

-- 3. Установка серверов через Mason и их включение
require('mason-tool-installer').setup {
    ensure_installed = servers
}

for _, server in ipairs(servers) do
    vim.lsp.enable(server)
end

