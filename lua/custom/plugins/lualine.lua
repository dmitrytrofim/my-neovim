-- lua/custom/plugins/lualine.lua
vim.pack.add {'https://github.com/nvim-lualine/lualine.nvim'}

require('lualine').setup {
    options = {
        -- В новых версиях LazyVim тема подтягивалась автоматически.
        -- В чистом Neovim lualine нужно указать тему явно. 
        -- Если у тебя не установлена цветовая схема, он будет использовать 'auto' (определять по цветам Neovim).
        theme = 'auto'
        -- Если хочешь убрать разделители (как в LazyVim), можно включить:
        -- section_separators = '',
        -- component_separators = '',
    },
    sections = {
        -- 1. Полностью очищаем правую угловую секцию (убираем время)
        lualine_z = {},

        -- 2. Переопределяем центральную секцию с путём файла
        lualine_c = {{ -- Кастомная функция, которая ищет корень проекта
        function()
            local root = vim.fs.root(0, {".git", "package.json", "Makefile"})
            if root then
                -- Берем только имя папки (roboschool-nvim)
                return "📁 " .. vim.fn.fnamemodify(root, ":t")
            end
            return ""
        end}, -- Оставляем стандартное отображение имени файла
        {
            "filename",
            path = 1
        }}
    }
}
