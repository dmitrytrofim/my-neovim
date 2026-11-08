-- lua/custom/plugins/luasnip.lua
-- 1. Добавляем сам LuaSnip и friendly-snippets
vim.pack.add {'https://github.com/L3MON4D3/LuaSnip', 'https://github.com/rafamadriz/friendly-snippets'}

-- 2. Настраиваем LuaSnip
local luasnip = require('luasnip')
local types = require('luasnip.util.types')

luasnip.setup {
    history = true,
    delete_check_events = "TextChanged,TextChangedI",
    updateevents = "TextChanged,TextChangedI",
    ext_opts = {
        -- Настройка для обычных мест вставки ($1, $2 и т.д.)
        [types.insertNode] = {
            passive = {
                virt_text = {{"│", "Comment"}},
                virt_text_pos = "inline"
            }
        },
        -- Настройка для финальной точки выхода ($0)
        [types.exitNode] = {
            passive = {
                virt_text = {{"│", "Comment"}},
                virt_text_pos = "inline"
            }
        }
    }
}

-- 3. Загружаем сниппеты (встроенные + твои кастомные)
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_vscode").lazy_load({
    paths = {vim.fn.stdpath("config") .. "/snippets"}
})
