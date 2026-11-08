-- ~/.config/nvim/lua/config/macros.lua
local M = {}

function M.copy_class_to_right_window()
    -- 1. Получаем строку и 0-based индекс курсора
    local line = vim.api.nvim_get_current_line()
    local cursor_col = vim.api.nvim_win_get_cursor(0)[2]

    -- 2. Вырезаем "сырое" слово, просто взяв символы вокруг курсора
    -- Идем влево до разделителя (пробел, кавычка, угловая скобка, равно)
    local start_idx = cursor_col + 1
    while start_idx > 1 and not line:sub(start_idx - 1, start_idx - 1):match("[%s\"'=<>{}().,]") do
        start_idx = start_idx - 1
    end

    -- Идем вправо до разделителя
    local end_idx = cursor_col + 1
    while end_idx <= #line and not line:sub(end_idx, end_idx):match("[%s\"'=<>{}().,]") do
        end_idx = end_idx + 1
    end

    -- Получаем слово
    local word = line:sub(start_idx, end_idx - 1)

    -- Если слово пустое (например, курсор на пробеле или скобке) — выходим
    if word == "" or word:match("^%s*$") then
        return
    end

    -- 3. Отрезаем префикс до точки (styles.header -> header)
    word = word:match("([^%.]+)$") or word

    -- 4. Запоминаем текущее окно
    local current_win = vim.api.nvim_get_current_win()

    -- 5. Переключаемся вправо
    vim.cmd("wincmd l")

    if vim.api.nvim_get_current_win() == current_win then
        vim.notify("Окно справа не найдено", vim.log.levels.WARN)
        return
    end

    -- 6. Вставляем блок в конец файла
    local buf = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(buf)

    vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, {"", "." .. word .. " {", "}"})

    -- 7. Возвращаем фокус обратно
    vim.api.nvim_set_current_win(current_win)
end

return M
