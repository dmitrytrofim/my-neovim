vim.pack.add {'https://github.com/L3MON4D3/LuaSnip', 'https://github.com/saghen/blink.cmp'}

require('luasnip').setup {}

require('blink.cmp').setup {
    keymap = {
        preset = 'default',
        -- Твоя фишка: При нажатии <Esc> сначала принудительно очищаем сниппет, затем скрываем меню
        ['<Esc>'] = {function()
            local ok, luasnip = pcall(require, 'luasnip')
            if ok then
                luasnip.unlink_current()
            end
        end, 'hide', 'fallback'},
        ['<CR>'] = {'accept', 'fallback'},
        ['<Tab>'] = {'accept', 'snippet_forward', 'fallback'},
        ['<S-Tab>'] = {'snippet_backward', 'select_prev', 'fallback'},
        ['<C-l>'] = {'accept', 'fallback'},
        ['<Up>'] = {'select_prev', 'fallback'},
        ['<Down>'] = {'select_next', 'fallback'},
        ['<C-j>'] = {'select_next', 'fallback'},
        ['<C-k>'] = {'select_prev', 'fallback'}
    },

    cmdline = {
        enabled = true,
        completion = {
            menu = {
                auto_show = true -- <--- ВОТ ЭТО включает автопоказ в командной строке
            }
        },
        keymap = {
            preset = 'cmdline',
            ['<CR>'] = {'accept', 'fallback'},
            ['<Up>'] = {'select_prev', 'fallback'},
            ['<Down>'] = {'select_next', 'fallback'},
            ['<Right>'] = {'accept', 'fallback'}
        }
    },

    sources = {
        default = {'lsp', 'path', 'snippets', 'buffer'}
    },

    snippets = {
        preset = 'luasnip'
    },

    fuzzy = {
        implementation = 'lua'
    },

    completion = {
        trigger = {
            show_on_insert_on_trigger_character = false, -- Твоя настройка: не открывать при вводе спецсимволов
            show_on_trigger_character = true,
            show_on_keyword = true,
            prefetch_on_insert = true
        },
        list = {
            selection = {
                preselect = true,
                auto_insert = false
            }
        },
        menu = {
            auto_show = true,
            auto_show_delay_ms = 50 -- задержка 50мс перед показом
        }
    }
}
