-- lua/custom/plugins/codecompanion.lua
vim.pack
    .add {'https://github.com/olimorris/codecompanion.nvim', 'https://github.com/nvim-lua/plenary.nvim' -- treesitter у нас уже есть в базовом init.lua, но если нужно, можно добавить
}

require('codecompanion').setup {
    -- Настройка адаптера для OpenRouter
    adapters = {
        openrouter = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                    url = "https://openrouter.ai/api/v1",
                    api_key = "OPENROUTER_API_KEY"
                },
                schema = {
                    model = {
                        default = "deepseek/deepseek-v4.1-flash-1017"
                    }
                }
            })
        end
    },
    -- Указываем, где использовать этот адаптер
    interactions = {
        chat = {
            adapter = "openrouter"
        },
        inline = {
            adapter = "openrouter"
        }
    }
    -- (Опционально: здесь можно добавить display, чтобы окно чата выглядело красиво)
}

-- Хоткеи
vim.keymap.set('n', '<leader>ai', '<cmd>CodeCompanionChat Toggle<cr>', {
    desc = 'AI: Chat'
})
vim.keymap.set('n', '<leader>aa', '<cmd>CodeCompanionActions<cr>', {
    desc = 'AI: Actions'
})
vim.keymap.set({'n', 'v'}, '<leader>ae', '<cmd>CodeCompanion<cr>', {
    desc = 'AI: Inline Edit'
})
