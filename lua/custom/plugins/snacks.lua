vim.pack.add {'https://github.com/folke/snacks.nvim', 'https://github.com/nvim-tree/nvim-web-devicons'}

local ok, snacks = pcall(require, 'snacks')
if not ok then
    vim.notify('snacks.nvim не установлен. Запусти :lua vim.pack.update()', vim.log.levels.WARN)
    return
end

-- Открываем пикер проектов напрямую, без создания пустого буфера
_G.OpenProjects = function()
    Snacks.picker.projects()
end

snacks.setup {
    picker = {
        enabled = true,
        win = {
            input = {
                keys = {
                    ["<Esc>"] = {
                        "focus_list",
                        mode = {"i", "n"}
                    }
                }
            }
        },
        sources = {
            projects = {
                dirs = {"~/Main/WebDev/practice", "~/Main/WebDev"},
                -- Переопределяем действие при нажатии Enter:
                confirm = function(picker, item)
                    if not item then
                        return
                    end
                    -- Меняем рабочую директорию и сразу открываем файлы внутри этого же окна пикера
                    vim.fn.chdir(item.file)
                    picker:action("picker_files")
                end
            },
            explorer = {
                auto_close = true
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
    Snacks.explorer()
end, {
    desc = "Explorer"
})
