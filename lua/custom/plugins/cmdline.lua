local gh = function(repo)
    return 'https://github.com/' .. repo
end

-- ВАЖНО: tiny-cmdline требует cmdheight=0 и включенный ui2
vim.o.cmdheight = 0
require("vim._core.ui2").enable({})

-- Устанавливаем плагин
vim.pack.add {gh 'rachartier/tiny-cmdline.nvim'}

-- Плагин не требует setup(), но если вы хотите его настроить (например, изменить ширину):
-- require('tiny-cmdline').setup({
--   width = { value = "70%" },
-- })
