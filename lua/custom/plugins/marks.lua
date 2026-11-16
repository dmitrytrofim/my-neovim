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
        -- Предпросмотр закладки (Пробел + m + v)
        preview = '<leader>mv',
        -- Удалить закладку на текущей строке (Пробел + m + d)
        delete_line = '<leader>md',
        -- Удалить все закладки в текущем файле (Пробел + m + D)
        delete_buf = '<leader>mD'
    }
}

vim.keymap.set('n', '<leader>ml', '<cmd>MarksListAll<CR>', {
    desc = '[M]arks [L]ist all'
})
