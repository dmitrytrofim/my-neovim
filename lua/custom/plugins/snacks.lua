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

vim.g.snacks_animate = false

snacks.setup {
    picker = {
        enabled = true,
        win = {
            list = {
                keys = {
                    ['l'] = 'confirm',
                    ['h'] = 'close',
                    ['d'] = 'bufdelete'
                }
            },
            input = {
                keys = {
                    ["<Esc>"] = {
                        "focus_list",
                        mode = {"i"}
                    },
                    ['l'] = {
                        'confirm',
                        mode = {'n'}
                    },
                    ['h'] = {
                        'close',
                        mode = {'n'}
                    }
                }
            }
        },
        sources = {
            buffers = {
                focus = 'list',
                filter = {
                    filter = function(item)
                        return item.file ~= ''
                    end
                }
            },
            projects = {
                focus = 'list',
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
                auto_close = true,
                win = {
                    list = {
                        keys = {
                            ["<Left>"] = "explorer_close",
                            ["<Right>"] = "confirm"
                        }
                    }
                }
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
        enabled = true,
        indent = {
            char = " ", -- пробел для фоновых (серых) линий
            only_scope = true
        },
        animate = {
            enabled = false
        },
        scope = {
            enabled = true,
            char = "│", -- сплошная черта для текущей секции
            hl = "SnacksIndentScope"
        }
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

-- === ХОТКЕЙ ДЛЯ БУФЕРОВ ===
vim.keymap.set("n", "<leader>,", function()
    Snacks.picker.buffers({
        focus = "list"
    })
end, {
    desc = "Buffers"
})
