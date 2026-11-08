-- lua/custom/plugins/snacks.lua
vim.pack.add {'https://github.com/folke/snacks.nvim'}

local ok, snacks = pcall(require, 'snacks')
if not ok then
    vim.notify('snacks.nvim не установлен. Запусти :lua vim.pack.update()', vim.log.levels.WARN)
    return
end

snacks.setup {
    -- Включаем только самые базовые модули
    picker = {
        enabled = true
    },
    terminal = {
        enabled = true
    },
    notifier = {
        enabled = true
    },
    indent = {
        enabled = true
    },
    scope = {
        enabled = true
    },
    scroll = {
        enabled = false
    },
    explorer = {
        enabled = true
    }, -- <--- ВКЛЮЧАЕМ EXPLORER

    dashboard = {
        enabled = true,
        sections = {{
            section = "header"
        }, {
            section = "keys",
            gap = 1,
            padding = 1
        }, {
            section = "recent_files",
            icon = " ",
            title = "Recent",
            indent = 2,
            padding = 1
        }}
    }
}

_G.Snacks = snacks

-- === ХОТКЕЙ ДЛЯ ДЕРЕВА ===
vim.keymap.set("n", "<leader>e", function()
    Snacks.explorer({
        enter = true
    })
end, {
    desc = "Explorer"
})
