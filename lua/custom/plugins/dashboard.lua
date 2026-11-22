local gh = function(repo)
    return 'https://github.com/' .. repo
end

vim.pack.add {gh 'nvimdev/dashboard-nvim'}

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

-- Прозрачная группа подсветки курсора (только для dashboard)
vim.api.nvim_set_hl(0, 'DashboardHiddenCursor', {
    blend = 100,
    nocombine = true
})

-- Сохраняем исходный guicursor (избегаем жесткого кодирования)
local original_guicursor = vim.go.guicursor

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'dashboard',
    callback = function()
        -- Ключевой момент: используем vim.schedule, чтобы дождаться завершения перерисовки буфера Neovide
        vim.schedule(function()
            vim.opt.guicursor = 'a:DashboardHiddenCursor'
        end)

        -- При выходе из буфера восстанавливаем
        vim.api.nvim_create_autocmd('BufLeave', {
            buffer = 0,
            once = true,
            callback = function()
                vim.schedule(function()
                    vim.opt.guicursor = original_guicursor
                end)
            end
        })
    end
})
