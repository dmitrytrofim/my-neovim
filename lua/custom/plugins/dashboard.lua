local gh = function(repo)
    return 'https://github.com/' .. repo
end

vim.pack.add {gh 'nvimdev/dashboard-nvim', gh 'nvim-tree/nvim-web-devicons'}

require('dashboard').setup {
    theme = 'hyper',
    config = {
        -- Меняем заголовок
        header = {"", "", "",
                  "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
                  "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
                  "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
                  "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                  "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
                  "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
                  ""},
        shortcut = {{
            desc = ' Find File',
            group = 'Label',
            action = 'Telescope find_files',
            key = 'f'
        }, {
            desc = ' Recent Files',
            group = 'Label',
            action = 'Telescope oldfiles',
            key = 'r'
        }, {
            desc = ' Grep',
            group = 'Label',
            action = 'Telescope live_grep',
            key = 'g'
        }, {
            desc = ' Projects',
            group = 'Label',
            action = function()
                Snacks.picker.projects()
            end,
            key = 'p'
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
            enable = false
        },
        mru = {
            enable = false
        }
    }
}
