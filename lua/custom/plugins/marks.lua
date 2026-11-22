-- lua/custom/plugins/marks.lua
local gh = function(repo)
    return 'https://github.com' .. repo
end

vim.pack.add {gh 'chentoast/marks.nvim'}

require('marks').setup {
    -- Отключаем дефолтные комбинации с запятыми/минусами, чтобы не путаться
    default_mappings = false,
    builtin_marks = {},
    refresh_interval = 250,
    mappings = {
        -- Поставить / снять закладку на текущей строке (Пробел + m + a)
        toggle = '<leader>ma',
        -- Прыгнуть к следующей / предыдущей закладке (Пробел + m + n / p)
        next = '<leader>mn',
        prev = '<leader>mp',
        -- Удалить все закладки в текущем файле (Пробел + m + d)
        delete_buf = '<leader>md'
    }
}

vim.keymap.set('n', '<leader>ml', '<cmd>MarksListAll<CR>', {
    desc = '[M]arks [L]ist all'
})

-- Удаление метки из списка (:MarksListAll) одним нажатием на 'd'
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'qf',
    callback = function(event)
        vim.keymap.set('n', 'd', function()
            local idx = vim.fn.line('.')
            local line = vim.api.nvim_get_current_line()

            -- Парсим имя файла и букву метки напрямую из строки вида: "index.html|3 col 2| mark l: <head>"
            local fname, mark = line:match('^(.-)|%d+%s+col%s+%d+|%s+mark%s+([a-zA-Z]):')
            if not (fname and mark) then
                return
            end

            -- Находим буфер файла и удаляем в нём метку
            local bufnr = vim.fn.bufnr(fname)
            if bufnr ~= -1 then
                vim.api.nvim_buf_call(bufnr, function()
                    pcall(vim.cmd, 'delmarks ' .. mark)
                end)
            end
            -- Если метка заглавная (глобальная), удаляем и через API
            if mark:match('%u') then
                pcall(vim.api.nvim_del_mark, mark)
            end

            -- Возвращаемся в окно с кодом, обновляем состояние marks.nvim и перестраиваем список
            vim.cmd('wincmd p')
            pcall(function()
                require('marks').refresh(true)
            end)
            vim.cmd('MarksListAll')

            -- Если меток не осталось — закрываем окно, иначе возвращаем курсор на место
            local new_list = vim.fn.getloclist(0)
            if #new_list == 0 then
                vim.cmd('lclose')
            else
                vim.cmd('lopen')
                pcall(vim.api.nvim_win_set_cursor, 0, {math.min(idx, #new_list), 0})
            end
        end, {
            buffer = event.buf,
            silent = true,
            desc = 'Delete mark under cursor'
        })
    end
})
