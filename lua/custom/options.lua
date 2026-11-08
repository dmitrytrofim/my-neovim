-- lua/custom/options.lua
-- Персональные опции для kickstart.nvim (перенесено из LazyVim)
-- [[ Базовый вид ]]
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.smoothscroll = false

-- [[ Neovide ]]
if vim.g.neovide then
    -- Убираем размытие/тени плавающих окон — главная причина фризов в Linux
    vim.g.neovide_floating_blur_amount_x = 0.0
    vim.g.neovide_floating_blur_amount_y = 0.0
    vim.g.neovide_floating_shadow = false

    -- ВАЖНО: сверьте с реальной герцовкой монитора (xrandr / GNOME Settings)
    vim.g.neovide_refresh_rate = 100

    -- Позволяем GPU засыпать, когда на экране ничего не меняется
    vim.g.neovide_no_idle = false

    -- Жёсткий ноль для всех GUI-анимаций
    vim.g.neovide_scroll_animation_length = 0.0
    vim.g.neovide_position_animation_length = 0.0
    vim.g.neovide_window_animation_length = 0.0

    -- Полное отключение анимации курсора
    vim.g.neovide_cursor_animation_length = 0.0
    vim.g.neovide_cursor_trail_size = 0
    vim.g.neovide_cursor_vfx_mode = "none"
    vim.g.neovide_cursor_animate_command_line = false

    -- Скорость прокрутки колесиком
    vim.opt.mousescroll = "ver:7,hor:6"

    -- Комфорт
    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_progress_bar_enabled = false
end

-- [[ Поиск файлов ]]
vim.opt.path:append({".", "src"})
vim.opt.suffixesadd:append({".tsx", ".ts", ".jsx", ".js", ".vue", ".json"})

-- [[ Диагностика ]]
vim.diagnostic.config({
    virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●"
    },
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always"
    }
})

-- Hover-подсказка при удержании курсора
-- ВНИМАНИЕ: в kickstart.nvim уже есть похожий CursorHold для диагностики.
-- Проверьте init.lua. Если дубль — удалите один из блоков.
vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, {
            focusable = false
        })
    end
})

-- [[ Отзывчивость ]]
-- updatetime НЕ ставим: kickstart уже выставляет 250 (быстрее ваших 400).
vim.o.timeoutlen = 50

-- [[ Файлы ]]
vim.opt.backupcopy = "yes" -- не пересоздавать файл (для Vite/Webpack watcher'ов)
vim.o.autoread = true
vim.opt.mouse = "a"

-- [[ Inlay hints ]]
vim.lsp.inlay_hint.enable(false)

local inlay_hints_group = vim.api.nvim_create_augroup("DisableInlayHints", {
    clear = true
})
vim.api.nvim_create_autocmd("LspAttach", {
    group = inlay_hints_group,
    callback = function(args)
        vim.lsp.inlay_hint.enable(false, {
            bufnr = args.buf
        })
    end
})

-- [[ Filetype ]]
vim.filetype.add({
    extension = {
        ejs = "ejs.html"
    }
})

-- [[ Отступы ]]
-- Проверьте: kickstart уже ставит tabstop=8, softtabstop=4, shiftwidth=4.
-- Если хотите именно 4/4/4 — оставьте этот блок.
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- [[ Авто-cd в корень проекта ]]
-- Заменяет LazyVim-переменную vim.g.root_spec на нативные маркеры.
local root_markers = {".git", "package.json", "tsconfig.json", "vite.config.ts", "vite.config.js"}
local project_cwd_group = vim.api.nvim_create_augroup("ProjectRootCwd", {
    clear = true
})

vim.api.nvim_create_autocmd({"BufEnter", "BufReadPost", "VimEnter"}, {
    group = project_cwd_group,
    callback = function()
        if vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= "" then
            local root = vim.fs.root(0, root_markers)
            if root and root ~= vim.fn.getcwd() then
                vim.cmd("cd " .. vim.fn.fnameescape(root))
            end
        end
    end
})
