-- === ХОТКЕИ ===
-- 1. Прыжок по экрану на 's' (как в LazyVim)
vim.keymap.set({"n", "x", "o"}, "s", function()
    require("flash").jump()
end, {
    desc = "Flash Jump"
})

-- 2. Умный поиск (улучшает стандартный /)
vim.keymap.set({"n", "x", "o"}, "/", function()
    require("flash").jump({
        search = {
            mode = "search"
        },
        label = {
            after = {0, 0}
        },
        pattern = "^"
    })
end, {
    desc = "Flash Search"
})

-- 3. Прыжок по деревьям (Treesitter)
vim.keymap.set({"n", "x", "o"}, "<leader>k", function()
    require("flash").treesitter()
end, {
    desc = "Flash Treesitter"
})
