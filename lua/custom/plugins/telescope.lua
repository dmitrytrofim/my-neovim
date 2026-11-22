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
vim.keymap.set('n', '<F3>', function()
    local root = vim.fs.root(0, {'.git', 'package.json', 'Makefile', 'go.mod', 'Cargo.toml'})
    builtin.find_files({
        cwd = root or vim.fn.getcwd()
    })
end, {
    desc = 'Find files (Project Root)'
})

vim.keymap.set('n', '<leader>sh', builtin.help_tags, {
    desc = '[S]earch [H]elp'
})
vim.keymap.set('n', '<leader>sk', builtin.keymaps, {
    desc = '[S]earch [K]eymaps'
})
vim.keymap.set('n', '<leader>sf', builtin.find_files, {
    desc = '[S]earch [F]iles'
})
vim.keymap.set('n', '<leader>ss', builtin.builtin, {
    desc = '[S]earch [S]elect Telescope'
})
vim.keymap.set({'n', 'v'}, '<leader>sw', builtin.grep_string, {
    desc = '[S]earch current [W]ord'
})
vim.keymap.set('n', '<leader>sg', builtin.live_grep, {
    desc = '[S]earch by [G]rep'
})
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, {
    desc = '[S]earch [D]iagnostics'
})
vim.keymap.set('n', '<leader>sr', builtin.resume, {
    desc = '[S]earch [R]esume'
})
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, {
    desc = '[S]earch Recent Files ("." for repeat)'
})
vim.keymap.set('n', '<leader>sc', builtin.commands, {
    desc = '[S]earch [C]ommands'
})

