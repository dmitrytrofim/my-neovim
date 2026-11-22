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
    -- Включаем модуль image: в Neovide без Kitty-протокола он автоматически
    -- подхватит chafa или конвертацию для превью в пикерах
    image = {
        enabled = false,
        doc = {
            enabled = false -- отключаем рендер внутри markdown-буферов (в Neovide не работает)
        }
    },
    picker = {
        enabled = true,
        previewers = {
            file = {
                max_size = 5 * 1024 * 1024 -- разрешаем превью картинок до 5 МБ
            }
        },
        preview = function(ctx)
            local path = Snacks.picker.util.path(ctx.item)
            local ext = path and path:match('%.([^%.]+)$')
            local img_exts = {
                png = true,
                jpg = true,
                jpeg = true,
                gif = true,
                webp = true,
                bmp = true,
                ico = true
            }

            if ext and img_exts[ext:lower()] then
                return Snacks.picker.preview.cmd({'chafa', '--format=symbols',
                                                  '--symbols=block+border+space-wide-inverted',
                                                  '--size=' .. ctx.win:width() .. 'x' .. ctx.win:height(), path}, ctx)
            end
            return Snacks.picker.preview.file(ctx)
        end,
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
                        -- Скрываем пустые буферы
                        if not item.file or item.file == '' then
                            return false
                        end
                        -- Скрываем служебные буферы (терминалы, окна помощи, quickfix)
                        if item.buf and vim.bo[item.buf].buftype ~= '' then
                            return false
                        end
                        -- Скрываем виртуальные URI-буферы (health://, fugitive://, oil:// и т.д.)
                        if item.file:match('^[a-zA-Z0-9_-]+://') then
                            return false
                        end
                        -- Скрываем временные скратч-буферы
                        return not item.file:match('%[Scratch%]')
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
                auto_close = false,
                win = {
                    list = {
                        keys = {
                            ["<Left>"] = "explorer_close",
                            ["<Right>"] = "confirm_smart",
                            ["<CR>"] = "confirm_smart",
                            ["l"] = "confirm_smart"
                        }
                    }
                },
                actions = {
                    confirm_smart = function(picker, item, action)
                        if not item then
                            return
                        end
                        if not item.dir then
                            local path = Snacks.picker.util.path(item)
                            local ext = path and path:match('%.([^%.]+)$')
                            local img_exts = {
                                png = true,
                                jpg = true,
                                jpeg = true,
                                gif = true,
                                webp = true,
                                svg = true,
                                ico = true,
                                bmp = true,
                                avif = true,
                                tiff = true
                            }
                            if ext and img_exts[ext:lower()] then
                                -- ВОТ ЭТИ 3 СТРОЧКИ (вместо старого jobstart):
                                local dir = vim.fn.fnamemodify(path, ':h')
                                local filename = vim.fn.fnamemodify(path, ':t')
                                vim.fn.jobstart({'imv', '-s', 'shrink', '-n', filename, dir}, {
                                    detach = true
                                })
                                return
                            end
                        end

                        require('snacks.explorer.actions').actions.confirm(picker, item, action)

                        if not item.dir then
                            vim.schedule(function()
                                if not picker.closed then
                                    picker:close()
                                end
                            end)
                        end
                    end
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
vim.keymap.set("n", "<leader><leader>", function()
    Snacks.picker.buffers()
end, {
    desc = "Buffers"
})

vim.keymap.set('n', '<leader>od', function()
    Snacks.terminal('lazydocker')
end, {
    desc = '[O]pen [D]ocker'
})
