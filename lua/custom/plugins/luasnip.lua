-- lua/custom/plugins/luasnip.lua
-- 1. Добавляем сам LuaSnip и friendly-snippets
vim.pack.add {'https://github.com/L3MON4D3/LuaSnip', 'https://github.com/rafamadriz/friendly-snippets'}

-- 2. Настраиваем LuaSnip
local luasnip = require('luasnip')
local types = require('luasnip.util.types')

luasnip.setup {
    history = false, -- Отключаем хранение истории завершённых сниппетов, чтобы палочки не висели
    region_check_events = 'CursorMoved,CursorMovedI,InsertEnter', -- Убирает метки, как только курсор ушёл из зоны сниппета
    delete_check_events = 'TextChanged,TextChangedI',
    update_events = 'TextChanged,TextChangedI',
    ext_opts = {
        -- Показываем метку только для промежуточных точек ($1, $2 и т.д.)
        [types.insertNode] = {
            passive = {
                virt_text = {{'│', 'Comment'}},
                virt_text_pos = 'inline'
            }
        },
        -- Для финальной точки ($0) метку не рисуем, чтобы она не зависала после выхода
        [types.exitNode] = {
            passive = {
                virt_text = {}
            }
        }
    }
}

-- 3. Загружаем сниппеты (встроенные + твои кастомные)
require('luasnip.loaders.from_vscode').lazy_load()
require('luasnip.loaders.from_vscode').lazy_load {
    paths = {vim.fn.stdpath('config') .. '/snippets'}
}
