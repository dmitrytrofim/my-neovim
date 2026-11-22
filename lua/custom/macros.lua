-- ~/.config/nvim/lua/custom/macros.lua
local M = {}

-- Вспомогательная функция: достает имя класса под курсором
local function get_class_under_cursor()
    local line = vim.api.nvim_get_current_line()
    local cursor_col = vim.api.nvim_win_get_cursor(0)[2]

    local start_idx = cursor_col + 1
    while start_idx > 1 and not line:sub(start_idx - 1, start_idx - 1):match("[%s\"'=<>{}().,]") do
        start_idx = start_idx - 1
    end

    local end_idx = cursor_col + 1
    while end_idx <= #line and not line:sub(end_idx, end_idx):match("[%s\"'=<>{}().,]") do
        end_idx = end_idx + 1
    end

    local word = line:sub(start_idx, end_idx - 1)
    if word == "" or word:match("^%s*$") then
        return nil
    end

    -- Отрезаем префикс до точки (styles.header -> header)
    return word:match("([^%.]+)$") or word
end

-- 1. Старая функция: копирует класс и сразу вставляет в окно справа
function M.copy_class_to_right_window()
    local word = get_class_under_cursor()
    if not word then
        return
    end

    local current_win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd l")

    if vim.api.nvim_get_current_win() == current_win then
        vim.notify("Окно справа не найдено", vim.log.levels.WARN)
        return
    end

    local buf = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(buf)

    vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, {"", "." .. word .. " {", "}"})
    vim.api.nvim_set_current_win(current_win)
end

-- 2. Новая функция: только копирует класс в буфер обмена (с точкой в начале)
function M.copy_class_to_clipboard()
    local word = get_class_under_cursor()
    if not word then
        return
    end

    local class_str = "." .. word .. " {\n}"
    -- Копируем в системный буфер обмена ('+') и безымянный регистр ('"')
    vim.fn.setreg("+", class_str)
    vim.fn.setreg('"', class_str)

    vim.notify("Скопировано: " .. class_str, vim.log.levels.INFO)
end

return M
