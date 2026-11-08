-- lua/custom/plugins/which-key.lua
vim.pack.add {'https://github.com/folke/which-key.nvim'}

require('which-key').setup {
    preset = "helix",
    -- Убираем искусственную задержку перед показом меню
    delay = 0,

    -- Дополнительная оптимизация анимации окон для Neovide
    win = {
        no_overlap = true, -- Окно не будет перекрывать курсор
        padding = {1, 2} -- Аккуратные отступы без лишней графической нагрузки
    },

    -- Добавляем группы для твоих кастомных хоткеев (чтобы было красиво)
    spec = {{
        "<leader>f",
        group = "Find/Format"
    }, {
        "<leader>t",
        group = "Toggle"
    }, {
        "<leader>d",
        group = "Diagnostics"
    }, {
        "<leader>h",
        group = "Home/Git"
    }}
}
