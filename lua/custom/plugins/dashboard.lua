-- Установка плагина через встроенный vim.pack
local gh = function(repo)
    return 'https://github.com/' .. repo
end

vim.pack.add {gh 'nvimdev/dashboard-nvim', gh 'nvim-tree/nvim-web-devicons' -- зависимость
}

-- Настройка
require('dashboard').setup {
    theme = 'hyper',
    config = {
        shortcut = {{
            desc = ' Find File',
            group = 'Label',
            action = 'Telescope find_files',
            key = 'f'
        }, {
            desc = ' Recent',
            group = 'Label',
            action = 'Telescope oldfiles',
            key = 'r'
        }, {
            desc = ' Grep',
            group = 'Label',
            action = 'Telescope live_grep',
            key = 'g'
        }, {
            desc = ' Config',
            group = 'Label',
            action = 'edit ~/.config/nvim/init.lua',
            key = 'c'
        }, {
            desc = ' Quit',
            group = 'Label',
            action = 'qa',
            key = 'q'
        }},
        project = {
            enable = true,
            limit = 8
        },
        mru = {
            enable = true,
            limit = 10
        }
    }
}
