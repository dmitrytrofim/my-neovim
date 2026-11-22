-- 1. Хоткеи при подключении LSP к буферу
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('CustomLspHover', {
        clear = true
    }),
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, {
                buffer = event.buf,
                desc = 'LSP: ' .. desc
            })
        end

        map('K', function()
            vim.lsp.buf.hover {
                border = 'rounded',
                focusable = true
            }
        end, 'Hover Documentation')

        -- Переход к определению (если удалил из init.lua)
        map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    end
})

-- 2. Список LSP-серверов (HTML, CSS/SCSS, JSON, Emmet, JS/TS/React, ESLint)
local servers = {'html', 'cssls', 'jsonls', 'emmet_language_server', 'vtsls', 'eslint', 'dockerls',
                 'docker_compose_language_service'}

-- Capabilities от blink.cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_blink, blink = pcall(require, 'blink.cmp')
if has_blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
else
    capabilities.textDocument.completion.completionItem.snippetSupport = true
end

vim.lsp.config('*', {
    capabilities = capabilities
})

-- Настройка CSS / SCSS / LESS (отключаем ругань на пустые классы)
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

-- Настройка Emmet
vim.lsp.config('emmet_language_server', {
    init_options = {
        showExpandedAbbreviation = 'always',
        showAbbreviationSuggestions = false
    }
})

-- 3. Единый список установки для Mason (LSP + форматтеры для conform.lua)
local ensure_installed = vim.list_extend(vim.deepcopy(servers), {'prettierd', 'eslint_d'})

require('mason-tool-installer').setup {
    ensure_installed = ensure_installed
}

for _, server in ipairs(servers) do
    vim.lsp.enable(server)
end
