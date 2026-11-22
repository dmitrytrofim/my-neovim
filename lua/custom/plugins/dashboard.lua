local gh = function(repo)
    return 'https://github.com/' .. repo
end

vim.pack.add {gh 'nvimdev/dashboard-nvim'}

-- Быстрый возврат на стартовую страницу и сброс директории в ~
vim.keymap.set('n', '<BS>', function()
    vim.fn.chdir(vim.fn.expand('~'))
    vim.cmd('Dashboard')
end, {
    desc = 'Open home'
})

require('dashboard').setup {
    theme = 'hyper',
    config = {
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

local original_guicursor = vim.go.guicursor
local dash_group = vim.api.nvim_create_augroup('DashboardCursor', {
    clear = true
})

-- Скрываем курсор при КАЖДОМ входе в буфер дашборда (в том числе после закрытия пикеров)
vim.api.nvim_create_autocmd({'FileType', 'BufEnter'}, {
    group = dash_group,
    callback = function()
        if vim.bo.filetype == 'dashboard' then
            vim.schedule(function()
                if vim.bo.filetype == 'dashboard' then
                    vim.opt.guicursor = 'a:DashboardHiddenCursor'
                end
            end)
        end
    end
})

-- Восстанавливаем курсор при уходе из буфера дашборда
vim.api.nvim_create_autocmd('BufLeave', {
    group = dash_group,
    callback = function()
        if vim.bo.filetype == 'dashboard' then
            vim.schedule(function()
                if vim.bo.filetype ~= 'dashboard' then
                    vim.opt.guicursor = original_guicursor
                end
            end)
        end
    end
})
