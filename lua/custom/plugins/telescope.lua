-- lua/custom/plugins/telescope.lua
vim.pack.add {'https://github.com/nvim-lua/plenary.nvim', 'https://github.com/nvim-telescope/telescope.nvim',
              'https://github.com/nvim-telescope/telescope-ui-select.nvim'}

local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup {
    defaults = {
        mappings = {
            i = {
                ["<Esc>"] = actions.close
            }
        }
    },
    extensions = {
        ["ui-select"] = {require("telescope.themes").get_dropdown {}}
    }
}

pcall(telescope.load_extension, 'ui-select')

local builtin = require('telescope.builtin')

-- 1. Space + Space: Умный поиск файлов от корня проекта
vim.keymap.set('n', '<leader><leader>', function()
    -- Ищем корень проекта по маркерам (.git, package.json и т.д.)
    local root = vim.fs.root(0, {".git", "package.json", "Makefile", "go.mod", "Cargo.toml"})
    -- Если нашли корень, ищем оттуда, иначе от текущей папки (cwd)
    builtin.find_files({
        cwd = root or vim.fn.getcwd()
    })
end, {
    desc = 'Find files (Project Root)'
})

-- 2. Space + , : Поиск по буферам
vim.keymap.set('n', '<leader>,', builtin.buffers, {
    desc = 'Find existing buffers'
})

-- Остальные твои хоткеи
vim.keymap.set('n', '<leader>ff', builtin.find_files, {
    desc = 'Find files'
})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {
    desc = 'Live grep'
})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {
    desc = 'Buffers'
})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {
    desc = 'Help tags'
})
