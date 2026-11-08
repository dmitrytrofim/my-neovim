vim.pack.add {'https://github.com/folke/snacks.nvim'}

local ok, snacks = pcall(require, 'snacks')
if not ok then
    vim.notify('snacks.nvim не установлен. Запусти :lua vim.pack.update()', vim.log.levels.WARN)
    return
end

-- Создаем безопасную функцию для открытия проектов
-- Она уходит с дашборда в пустой буфер, а потом открывает пикер
_G.OpenProjects = function()
    vim.cmd("enew") -- Создаем новый пустой буфер, чтобы избежать ошибки modifiable
    Snacks.picker.projects()
end

snacks.setup {
    picker = {
        enabled = true,
        sources = {
            projects = {
                -- Укажи свои реальные пути к папкам с проектами
                dirs = {"~/Main/WebDev/practice", "~/Main/WebDev"}
            }
        }
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
    },
    dashboard = {
        enabled = false
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
