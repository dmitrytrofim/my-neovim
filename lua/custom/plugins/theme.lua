-- Добавляем Catppuccin
vim.pack.add {'https://github.com/catppuccin/nvim'}

-- Настраиваем и включаем
require('catppuccin').setup {
    flavour = "mocha",
    transparent_background = false
}

-- Применяем тему (в новых версиях имя именно catppuccin-nvim)
vim.cmd.colorscheme 'catppuccin-nvim'
