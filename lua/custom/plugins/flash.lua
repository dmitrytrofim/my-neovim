-- === ХОТКЕИ ===
-- 1. Прыжок по экрану на 's' (как в LazyVim)
vim.keymap.set({"n", "x", "o"}, "s", function()
    require("flash").jump()
end, {
    desc = "Flash Jump"
})

-- 2. Прыжок по деревьям (Treesitter)
vim.keymap.set({"n", "x", "o"}, "<leader>k", function()
    require("flash").treesitter()
end, {
    desc = "Flash Treesitter"
})

-- Убираем курсив у затемненного фона (FlashBackdrop), оставляя его серым
vim.api.nvim_set_hl(0, "FlashBackdrop", {
    fg = "#c1c1c1",
    italic = false
})
