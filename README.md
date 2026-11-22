## Environment & Architecture

- **Base Configuration**: Built on top of `kickstart.nvim` (Neovim `v0.12+`).
- **Plugin Management**: Uses Neovim's native built-in `vim.pack` (`vim.pack.add` + manual `setup()` calls, lockfile tracked via `nvim-pack-lock.json`) — zero third-party plugin managers like `lazy.nvim`.
- **GUI & Rendering**: Tuned for **Neovide** (GPU-accelerated rendering with animations disabled for zero micro-stutters and crisp responsiveness).
- **Host OS**: Linux (Manjaro / GNOME).
- **Modular Structure**:
  - `init.lua` — Core options, base keymaps, LSP, Treesitter, and `vim.pack` build hooks.
  - `lua/custom/` — Personal overrides (`options.lua`, `keymaps.lua`, `autocmds.lua`, `macros.lua`, and git-ignored `local_env.lua` for local secrets).
  - `lua/custom/plugins/` — Modular plugin setups (Blink, CodeCompanion, Conform, Flash, Lualine, LuaSnip, Marks, Mason, Snacks, Telescope, Which-Key, etc.).
  - `snippets/` — Custom VSCode-style JSON snippets (`html`, `scss`, `js-ts`, `react`, `ejs`, `package.json`).
