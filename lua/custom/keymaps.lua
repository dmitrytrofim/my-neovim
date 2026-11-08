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
vim.keymap.set('n', '<leader>h', function()
    -- Используем dashboard-nvim, а не snacks
    vim.cmd('Dashboard')
end, {
    desc = 'Open home'
})

-- F5: форматировать и сохранить (normal)
-- NOTE: async=true + wall может сохранить неотформатированный буфер.
-- Здесь ждём завершения формата, потом wall.
vim.keymap.set('n', '<F5>', function()
    require('conform').format({
        async = false,
        lsp_format = 'fallback'
    })
    vim.cmd('wall')
end, {
    desc = 'Форматировать и сохранить все файлы'
})

-- F5: форматировать и сохранить (insert)
vim.keymap.set('i', '<F5>', function()
    vim.cmd('stopinsert')
    require('conform').format({
        async = false,
        lsp_format = 'fallback'
    })
    vim.cmd('wall')
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
vim.keymap.set('n', '<F4>', '<C-w>w', {
    desc = 'Перейти в следующее окно'
})
vim.keymap.set('n', '<F3>', '<C-w>W', {
    desc = 'Вернуться в предыдущее окно'
})

-- Переключение + прыжок в конец
vim.keymap.set('n', '<leader><F4>', '<C-w>wG', {
    desc = 'Перейти в следующее окно и в конец'
})
vim.keymap.set('n', '<leader><F3>', '<C-w>WG', {
    desc = 'Перейти в предыдущее окно и в конец'
})

-- Переключение окон (insert)
vim.keymap.set('i', '<F4>', '<C-o><C-w>w', {
    desc = 'Перейти в следующее окно'
})
vim.keymap.set('i', '<F3>', '<C-o><C-w>W', {
    desc = 'Вернуться в предыдущее окно'
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

-- F1 — hover (normal + insert)
vim.keymap.set('n', '<F1>', vim.lsp.buf.hover, {
    desc = 'Показать документацию/типы'
})
vim.keymap.set('i', '<F1>', function()
    vim.lsp.buf.hover()
end, {
    desc = 'Показать документацию/типы'
})

-- F2 — rename (normal + insert)
vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, {
    desc = 'Переименовать сущность'
})
vim.keymap.set('i', '<F2>', function()
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
