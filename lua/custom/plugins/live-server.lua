-- lua/custom/plugins/live-server.lua
vim.pack.add {'https://github.com/barrettruth/live-server.nvim'}

-- Настройки задаются через глобальную переменную до инициализации
vim.g.live_server = {
    port = 8080,
    browser = true -- автоматически открывать браузер по умолчанию в Gnome
}

-- Горячие клавиши для управления
vim.keymap.set('n', '<leader>ls', '<cmd>LiveServerStart<CR>', {
    desc = '[L]ive [S]erver Start'
})
vim.keymap.set('n', '<leader>lx', '<cmd>LiveServerStop<CR>', {
    desc = '[L]ive [S]erver Stop'
})
vim.keymap.set('n', '<leader>lt', '<cmd>LiveServerToggle<CR>', {
    desc = '[L]ive [S]erver Toggle'
})
