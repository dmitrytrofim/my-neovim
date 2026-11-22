-- ============================================================
-- lua/custom/autocmds.lua
-- Автокоманды: защита readonly-буферов, web-indent, терминал, autoread.
-- Подключается из init.lua: require 'custom.autocmds'
-- ============================================================
-- ------------------------------------------------------------
-- 1. Защита от случайных нажатий в read-only и служебных буферах
-- ------------------------------------------------------------
local readonly_protection_group = vim.api.nvim_create_augroup('ReadonlyProtection', {
    clear = true
})

-- filetype'ы, где readonly — это норма, а не защита от случайного ввода.
-- NOTE: дополни своими по факту (:set ft? в нужном буфере).
local readonly_skip_ft = {
    snacks_picker_input = true,
    snacks_picker_list = true,
    snacks_explorer = true,
    snacks_terminal = true,
    snacks_notif = true,
    snacks_win = true,
    noice = true,
    lazy = true,
    mason = true,
    help = true,
    qf = true,
    codecompanion = true -- проверь фактический ft у chat/history
}

-- Клавиши, которые реально опасны в readonly-буфере.
-- NOTE: c/C/s/S сюда осознанно НЕ включены — в readonly они просто дают
-- ошибку (нормальный фидбэк), а блокировать их маппингом — сомнительно.
local readonly_block_keys = {'i', 'I', 'a', 'A', 'o', 'O'}

-- Снимаем <Nop>-маппинги, если буфер снова стал изменяемым.
-- Иначе они висят мёртвым грузом до закрытия буфера.
local function readonly_unmap(bufnr)
    for _, key in ipairs(readonly_block_keys) do
        pcall(vim.keymap.del, 'n', key, {
            buffer = bufnr
        })
    end
end

vim.api.nvim_create_autocmd({'BufWinEnter', 'BufEnter'}, {
    group = readonly_protection_group,
    pattern = '*',
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        -- Служебные буферы не трогаем
        if readonly_skip_ft[vim.bo[bufnr].filetype] then
            return
        end
        -- terminal/prompt/nofile/quickfix/help и пр. — не трогаем
        local bt = vim.bo[bufnr].buftype
        if bt ~= '' and bt ~= 'acwrite' then
            return
        end

        if not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then
            for _, key in ipairs(readonly_block_keys) do
                vim.keymap.set('n', key, '<Nop>', {
                    buffer = bufnr,
                    silent = true,
                    nowait = true
                })
            end
        else
            -- Буфер изменяем — на всякий случай снимаем возможные <Nop>
            readonly_unmap(bufnr)
        end
    end
})

-- Если readonly/modifiable меняется на лету (:set ma / :set noma) —
-- приводим маппинги в соответствие.
vim.api.nvim_create_autocmd('OptionSet', {
    group = readonly_protection_group,
    pattern = {'readonly', 'modifiable'},
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        if readonly_skip_ft[vim.bo[bufnr].filetype] then
            return
        end
        local bt = vim.bo[bufnr].buftype
        if bt ~= '' and bt ~= 'acwrite' then
            return
        end

        if not vim.bo[bufnr].modifiable or vim.bo[bufnr].readonly then
            for _, key in ipairs(readonly_block_keys) do
                vim.keymap.set('n', key, '<Nop>', {
                    buffer = bufnr,
                    silent = true,
                    nowait = true
                })
            end
        else
            readonly_unmap(bufnr)
        end
    end
})

-- ------------------------------------------------------------
-- 2. Web-индентация + Enter внутри тегов
-- ------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
    pattern = {'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue', 'xml'},
    group = vim.api.nvim_create_augroup('WebIndentSettings', {
        clear = true
    }),
    callback = function()
        -- Отключаем старый smartindent, чтобы он не мешал ESLint/Prettier
        vim.opt_local.indentexpr = ''
        vim.opt_local.smartindent = false
        vim.opt_local.autoindent = true

        -- NOTE: определение «проект уже задал отступы» здесь ненадёжно.
        -- FileType приходит ДО LspAttach/editorconfig, поэтому shiftwidth
        -- в этот момент ещё дефолтный. Оставляем как было — на перепроверку.
        -- Vim-way: вынести 2 пробела в ftplugin/javascript.lua (и т.д.),
        -- либо отдать editorconfig / LSP.
        local current_sw = vim.bo.shiftwidth
        if current_sw == 8 or current_sw == 0 then
            vim.opt_local.expandtab = true
            vim.opt_local.shiftwidth = 2
            vim.opt_local.tabstop = 2
            vim.opt_local.softtabstop = 2
        end

        vim.keymap.set('i', '<CR>', function()
            -- 1. СНАЧАЛА проверяем символы слева и справа от курсора для разрыва ><
            -- Если курсор стоит между тегами (например, <div>|</div>), всегда делаем разрыв с отступом
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before = line:sub(col, col)
            local after = line:sub(col + 1, col + 1)

            if before == '>' and after == '<' then
                local ok_ls, luasnip = pcall(require, 'luasnip')
                if ok_ls and luasnip.in_snippet() then
                    luasnip.unlink_current()
                end

                local keys = vim.api.nvim_replace_termcodes('<CR><C-o>O<C-t>', true, false, true)
                vim.api.nvim_feedkeys(keys, 'n', false)
                return
            end

            -- 2. Если мы НЕ между тегами и открыто меню blink.cmp — принимаем подсказку
            local ok_blink, blink = pcall(require, 'blink.cmp')
            if ok_blink and blink.is_visible() then
                blink.accept()
                return
            end

            -- 3. Если меню закрыто — сбрасываем активный сниппет, чтобы палочки-подсказки исчезли
            local ok_ls, luasnip = pcall(require, 'luasnip')
            if ok_ls and luasnip.in_snippet() then
                luasnip.unlink_current()
            end

            -- 4. Обычный перенос строки
            local cr = vim.api.nvim_replace_termcodes('<CR>', true, false, true)
            vim.api.nvim_feedkeys(cr, 'n', false)
        end, {
            buffer = true,
            silent = true
        })

    end
})

-- ------------------------------------------------------------
-- 3. Терминал: мгновенный выход из terminal-mode по <Esc>
-- ------------------------------------------------------------
local term_group = vim.api.nvim_create_augroup('TerminalEscFix', {
    clear = true
})

vim.api.nvim_create_autocmd('TermOpen', {
    group = term_group,
    callback = function(event)
        -- NOTE: 'timeoutlen' — глобальная опция, opt_local писал в глобал.
        -- Для точного маппинга <Esc> задержка не нужна, поэтому строку убрали.
        -- Если нужен ttimeoutlen для терминальных escape-последовательностей —
        -- ему место в options.lua (vim.opt.ttimeoutlen = 10).
        vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], {
            buffer = event.buf,
            silent = true,
            desc = 'Instant escape terminal mode'
        })
    end
})

-- ------------------------------------------------------------
-- 4. Автообновление файлов при внешних изменениях
-- ------------------------------------------------------------
local autoread_group = vim.api.nvim_create_augroup('AutoReadReload', {
    clear = true
})

-- NOTE: CursorHold при updatetime=250 — это checktime каждые 250 мс
-- бездействия (stat() по буферам). На локальном SSD незаметно, на сетевой
-- ФС / большом репо — лишний I/O. FocusGained + BufEnter обычно хватает.
-- Оставляем CursorHold осознанно — на перепроверку поведения.
vim.api.nvim_create_autocmd({'FocusGained', 'BufEnter', 'CursorHold'}, {
    group = autoread_group,
    pattern = '*',
    callback = function()
        if vim.fn.mode() ~= 'c' then
            vim.cmd('checktime')
        end
    end,
    desc = 'Перечитывать файл с диска при внешних изменениях'
})

-- Удобная навигация в окне Quickfix (список меток, ошибок и т.д.)
-- В lua/custom/autocmds.lua
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'qf',
    group = vim.api.nvim_create_augroup('QuickfixNavigation', {
        clear = true
    }),
    callback = function(event)
        local opts = {
            buffer = event.buf,
            silent = true
        }

        vim.keymap.set('n', 'l', '<CR>', opts)
        vim.keymap.set('n', 'q', '<cmd>cclose<CR>', opts)
        vim.keymap.set('n', 'j', 'j', opts)
        vim.keymap.set('n', 'k', 'k', opts)
    end
})

-- Открываем картинки из проводника/пикера сразу через imv -s shrink вместо сырых байтов в буфере
vim.api.nvim_create_autocmd('BufReadCmd', {
    pattern = {'*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.svg', '*.ico', '*.bmp', '*.PNG', '*.JPG', '*.JPEG',
               '*.GIF', '*.WEBP', '*.SVG', '*.ICO', '*.BMP'},
    callback = function(ev)
        local path = vim.fn.fnamemodify(ev.file, ':p')
        local dir = vim.fn.fnamemodify(path, ':h')
        local filename = vim.fn.fnamemodify(path, ':t')

        -- -d включает оверлей с именем файла, -n <имя> <папка> открывает нужный файл в контексте всей папки
        vim.fn.jobstart({'imv', '-d', '-s', 'shrink', '-n', filename, dir}, {
            detach = true
        })

        -- Удаляем созданный пустой буфер, чтобы он не засорял список открытых файлов
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then
                vim.api.nvim_buf_delete(ev.buf, {
                    force = true
                })
            end
        end)
    end
})

-- После загрузки сессии закрываем все лишние сплиты, оставляя одно окно
vim.api.nvim_create_autocmd('SessionLoadPost', {
    group = vim.api.nvim_create_augroup('single-window-session', {
        clear = true
    }),
    callback = function()
        vim.cmd('silent! only')
    end
})
