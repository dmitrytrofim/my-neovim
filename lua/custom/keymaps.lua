-- ============================================================
-- lua/custom/keymaps.lua
-- Подключается из init.lua: require 'custom.keymaps'
-- ВАЖНО: файл зависит от плагинов (snacks, conform, bufferline, lsp).
-- Поэтому require 'custom.keymaps' должен идти ПОСЛЕ require 'custom.plugins'.
-- ============================================================
local macros = require('custom.macros') -- NOTE: путь custom.*, не config.*

-- Копировать класс как CSS-правило
vim.keymap.set('n', '<F12>', macros.copy_class_to_right_window, {
    desc = 'Send class to right window'
})

-- Быстрый возврат на стартовую страницу (dashboard)
vim.keymap.set('n', '<BS>', function()
    -- Используем dashboard-nvim, а не snacks
    vim.fn.chdir(vim.fn.expand('~'))
    vim.cmd('Dashboard')
end, {
    desc = 'Open home'
})

local function format_and_save()
    require('conform').format({
        async = true,
        lsp_format = 'fallback'
    }, function(err)
        if not err then
            -- noautocmd отключает повторное срабатывание format_on_save, если он включён
            vim.cmd('silent! noautocmd update')
        end
    end)
end

-- F5: форматировать и сохранить (normal)
vim.keymap.set('n', '<F5>', format_and_save, {
    desc = 'Форматировать и сохранить все файлы'
})

-- F5: форматировать и сохранить (insert)
vim.keymap.set('i', '<F5>', function()
    vim.cmd('stopinsert')
    format_and_save()
end, {
    desc = 'Форматировать и сохранить все файлы'
})

-- Alt+Shift+h/l — двигать вкладки bufferline
-- NOTE: в Neovide/Gnome <A-S-h> часто приходит как <A-H>. Проверь :verbose nmap <A-S-h>.
-- Если не срабатывает — замени на <A-H>/<A-L>.
vim.keymap.set('n', '<A-S-h>', '<cmd>BufferLineMovePrev<cr>', {
    desc = 'Сдвинуть вкладку влево'
})
vim.keymap.set('n', '<A-S-l>', '<cmd>BufferLineMoveNext<cr>', {
    desc = 'Сдвинуть вкладку вправо'
})

-- gf: умный переход по импортам (через snacks.picker), иначе родной gf
pcall(vim.keymap.del, 'n', 'gf')
vim.keymap.set('n', 'gf', function()
    local line = vim.api.nvim_get_current_line()
    if line:match('import') or line:match('from') or line:match('require') then
        local path = line:match("['\"`]([^'\"`]+)['\"`]")
        if path then
            local filename = vim.fs.basename(path)
            require('snacks').picker.files({
                search = filename,
                title = 'Jump to: ' .. filename,
                auto_confirm = true
            })
            return
        end
    end
    -- NOTE: было "normal! f" (опечатка) — родной gf это "normal! gf".
    local ok = pcall(vim.cmd, 'normal! gf')
    if not ok then
        vim.notify('Путь не найден', vim.log.levels.WARN)
    end
end, {
    desc = 'True Alias Go to File (gf)',
    silent = true
})

-- Insert-mode навигация по словам
vim.keymap.set('i', '<C-Left>', '<C-o>b', {
    desc = 'Прыжок на слово назад'
})
vim.keymap.set('i', '<C-Right>', '<C-o>e<Right>', {
    desc = 'Прыжок на слово вперед'
})

-- Удаление слова слева (два кода — для терминалов и Neovide)
vim.keymap.set('i', '<C-Backspace>', '<C-w>', {
    desc = 'Удалить слово слева'
})
vim.keymap.set('i', '<C-H>', '<C-w>', {
    desc = 'Удалить слово слева (fallback)'
})

-- Ctrl+Enter — новая строка снизу
vim.keymap.set('i', '<C-CR>', '<C-o>o', {
    desc = 'Создать чистую строку снизу'
})
vim.keymap.set('i', '<C-NL>', '<C-o>o', {
    desc = 'Создать чистую строку снизу (fallback)'
})

-- Ctrl+Shift+Enter — новая строка сверху
vim.keymap.set('i', '<C-S-CR>', '<C-o>O', {
    desc = 'Создать чистую строку сверху'
})
vim.keymap.set('i', '<C-S-NL>', '<C-o>O', {
    desc = 'Создать чистую строку сверху (fallback)'
})

-- Переключение окон (normal)
vim.keymap.set('n', '<F1>', '<C-w>W', {
    desc = 'Вернуться в предыдущее окно'
})
vim.keymap.set('n', '<F2>', '<C-w>w', {
    desc = 'Перейти в следующее окно'
})

-- Сброс зависших диагностик
-- NOTE: было :edit! — отбрасывает несохранённые правки. Опасно.
-- Убрал bang: :e перечитывает с диска только если нет изменений (иначе предупреждение).
vim.keymap.set('n', '<leader>dr', function()
    vim.diagnostic.reset()
    vim.cmd('edit')
end, {
    desc = 'Сбросить зависшие ошибки (LSP Refresh)'
})

-- Shift+Space — в конец строки (insert)
vim.keymap.set('i', '<S-Space>', '<End>', {
    desc = 'В конец строки'
})

-- Ctrl+a — в начало строки (insert)
-- NOTE: перебивает встроенное C-a (вставка ранее введённого). Осознанно?
vim.keymap.set('i', '<C-a>', '<Home>', {
    desc = 'В начало строки'
})

vim.keymap.set('n', '<F9>', vim.lsp.buf.hover, {
    desc = 'Показать документацию/типы'
})
vim.keymap.set('i', '<F9>', function()
    vim.lsp.buf.hover()
end, {
    desc = 'Показать документацию/типы'
})

-- F2 — rename (normal + insert)
vim.keymap.set('n', '<F10>', vim.lsp.buf.rename, {
    desc = 'Переименовать сущность'
})
vim.keymap.set('i', '<F10>', function()
    vim.lsp.buf.rename()
end, {
    desc = 'Переименовать сущность'
})

-- Вставить строку ниже/выше, остаться в normal
-- NOTE: "o<Esc>" оставляет курсор на новой строке (сдвиг на символ влево от начала).
-- Если нужно «курсор на пустой строке» — проверь поведение.
vim.keymap.set('n', '<leader>o', 'o<Esc>', {
    desc = 'Insert line below (stay in normal mode)'
})
vim.keymap.set('n', '<leader>O', 'O<Esc>', {
    desc = 'Insert line above (stay in normal mode)'
})

-- Терминал в корне проекта
-- NOTE: Snacks — глобал, доступен только после require('snacks').setup{}.
-- Если keymaps.lua грузится до custom.plugins — упадёт. Грузи после.
local function open_root_terminal()
    require('snacks').terminal(nil, {
        cwd = vim.fn.getcwd()
    })
end
vim.keymap.set('n', '<leader>ft', open_root_terminal, {
    desc = 'Terminal (Root Dir)'
})
vim.keymap.set('n', '<C-/>', open_root_terminal, {
    desc = 'Terminal (Root Dir)'
})
vim.keymap.set('t', '<C-/>', open_root_terminal, {
    desc = 'Terminal (Root Dir)'
})
-- NOTE: если <C-/> не доходит в твоём терминале/Neovide — добавь дубль:
-- vim.keymap.set({ 'n', 't' }, '<C-_>', open_root_terminal, { desc = 'Terminal (Root Dir)' })

-- Вставка из системного буфера в терминале
vim.keymap.set('t', '<C-S-v>', '<C-\\><C-n>"+pi', {
    desc = 'Вставить из системного буфера'
})

-- Умный <Esc> в Insert-режиме:
-- 1. Если открыто меню blink.cmp (Emmet / подсказки) — закрывает его и оставляет в Insert-режиме.
-- 2. Если меню закрыто — сбрасывает активный сниппет LuaSnip и выходит в Normal-режим.
vim.keymap.set({'i', 's'}, '<Esc>', function()
    local handled = false

    -- 1. Закрываем меню blink.cmp и документацию, если открыты
    local ok_blink, blink = pcall(require, 'blink.cmp')
    if ok_blink and (blink.is_menu_visible() or blink.is_documentation_visible()) then
        blink.hide()
        blink.hide_documentation()
        handled = true
    end

    -- 2. Сбрасываем активный сниппет LuaSnip (убираем метки для прыжка)
    local ok_ls, luasnip = pcall(require, 'luasnip')
    if ok_ls and (luasnip.in_snippet() or luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]) then
        luasnip.unlink_current()
        handled = true
    end

    -- 3. Дополнительно сбрасываем встроенные метки сниппетов Neovim (если Emmet развернулся через vim.snippet)
    if vim.snippet and vim.snippet.active() then
        vim.snippet.stop()
        handled = true
    end

    -- Если на этом нажатии закрыли меню или сняли метки — остаёмся в Insert
    if handled then
        return
    end

    -- Иначе сразу переходим в Normal-режим
    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
    vim.api.nvim_feedkeys(esc, 'n', false)
end, {
    desc = '1-й Esc: убрать меню/метки сниппета; 2-й Esc: выйти в Normal',
    silent = true
})

local map = vim.keymap.set

-- Регистрация группы в which-key (для красивой подписи +Windows)
local ok, wk = pcall(require, 'which-key')
if ok then
    wk.add({{
        '<leader>w',
        group = 'Windows',
        icon = ' '
    }})
end

-- Разделение экрана (сплиты)
map('n', '<leader>wv', '<C-w>v', {
    desc = 'Split window vertically (справа)'
})
map('n', '<leader>ws', '<C-w>s', {
    desc = 'Split window horizontally (снизу)'
})
map('n', '<leader>we', '<C-w>=', {
    desc = 'Make splits equal size (выровнять)'
})
map('n', '<leader>wx', '<cmd>close<CR>', {
    desc = 'Close current split (закрыть)'
})
map('n', '<leader>wo', '<cmd>only<CR>', {
    desc = 'Close other splits (оставить одно)'
})

-- Навигация между окнами через <leader>w
map('n', '<leader>wh', '<C-w>h', {
    desc = 'Go to left window'
})
map('n', '<leader>wj', '<C-w>j', {
    desc = 'Go to lower window'
})
map('n', '<leader>wk', '<C-w>k', {
    desc = 'Go to upper window'
})
map('n', '<leader>wl', '<C-w>l', {
    desc = 'Go to right window'
})
map('n', '<leader>ww', '<C-w>w', {
    desc = 'Switch to next window'
})
