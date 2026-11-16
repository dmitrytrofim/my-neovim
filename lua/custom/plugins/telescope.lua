-- lua/custom/plugins/telescope.lua
local gh = function(repo)
    return 'https://github.com/' .. repo
end

vim.pack.add {gh 'nvim-lua/plenary.nvim', gh 'nvim-telescope/telescope.nvim',
              gh 'nvim-telescope/telescope-ui-select.nvim'}

local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup {
    defaults = {
        mappings = {
            i = {
                ['<Esc>'] = actions.close
            }
        }
    },
    pickers = {
        -- Позволяет удалять метки прямо из списка <leader>mm по Ctrl+d или dd
        marks = {
            mappings = {
                i = {
                    ['<C-d>'] = actions.delete_mark
                },
                n = {
                    ['dd'] = actions.delete_mark
                }
            }
        }
    },
    extensions = {
        ['ui-select'] = {require('telescope.themes').get_dropdown {}}
    }
}

pcall(telescope.load_extension, 'ui-select')

local builtin = require('telescope.builtin')

-- 1. Space + Space: Умный поиск файлов от корня проекта
vim.keymap.set('n', '<leader><leader>', function()
    local root = vim.fs.root(0, {'.git', 'package.json', 'Makefile', 'go.mod', 'Cargo.toml'})
    builtin.find_files({
        cwd = root or vim.fn.getcwd()
    })
end, {
    desc = 'Find files (Project Root)'
})

-- Остальные твои хоткеи Telescope (<leader>, убран, теперь он полностью за Snacks)
vim.keymap.set('n', '<leader>ff', builtin.find_files, {
    desc = 'Find files'
})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {
    desc = 'Live grep'
})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {
    desc = 'Buffers (Telescope)'
})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {
    desc = 'Help tags'
})
