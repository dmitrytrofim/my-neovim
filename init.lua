-- ============================================================
-- SECTION 1: OPTIONS
-- Core Neovim settings, leaders, options
-- ============================================================
do
    vim.loader.enable()

    -- Set <space> as the leader key
    -- See `:help mapleader`
    --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
    vim.g.mapleader = ' '
    vim.g.maplocalleader = ' '

    -- Загружаем локальные секреты
    pcall(require, 'custom.local_env')

    -- Set to true if you have a Nerd Font installed and selected in the terminal
    vim.g.have_nerd_font = false

    -- [[ Setting options ]]
    --  See `:help vim.o`
    -- NOTE: You can change these options as you wish!
    --  For more options, you can see `:help option-list`

    -- Make line numbers default
    vim.o.number = true
    -- You can also add relative line numbers, to help with jumping.
    --  Experiment for yourself to see if you like it!
    -- vim.o.relativenumber = true

    -- Enable mouse mode, can be useful for resizing splits for example!
    vim.o.mouse = 'a'

    -- Don't show the mode, since it's already in the status line
    vim.o.showmode = false

    -- Sync clipboard between OS and Neovim.
    --  Schedule the setting after `UiEnter` because it can increase startup-time.
    --  Remove this option if you want your OS clipboard to remain independent.
    --  See `:help 'clipboard'`
    vim.schedule(function()
        vim.o.clipboard = 'unnamedplus'
    end)

    -- Enable break indent
    vim.o.breakindent = true

    -- Enable undo/redo changes even after closing and reopening a file
    vim.o.undofile = true

    -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
    vim.o.ignorecase = true
    vim.o.smartcase = true

    -- Keep signcolumn on by default
    vim.o.signcolumn = 'yes'

    -- Decrease update time
    vim.o.updatetime = 250

    -- Decrease mapped sequence wait time
    vim.o.timeoutlen = 300

    -- Configure how new splits should be opened
    vim.o.splitright = true
    vim.o.splitbelow = true

    -- Sets how neovim will display certain whitespace characters in the editor.
    --  See `:help 'list'`
    --  and `:help 'listchars'`
    --
    --  Notice listchars is set using `vim.opt` instead of `vim.o`.
    --  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
    --   See `:help lua-options`
    --   and `:help lua-guide-options`
    vim.o.list = true
    vim.opt.listchars = {
        tab = '» ',
        trail = '·',
        nbsp = '␣'
    }

    -- Preview substitutions live, as you type!
    vim.o.inccommand = 'split'

    -- Show which line your cursor is on
    vim.o.cursorline = true

    -- Minimal number of screen lines to keep above and below the cursor.
    vim.o.scrolloff = 10

    -- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
    -- instead raise a dialog asking if you wish to save the current file(s)
    -- See `:help 'confirm'`
    vim.o.confirm = true

    require('custom.options')
end

-- ============================================================
-- SECTION 2: KEYMAPS & AUTOCMDS
-- basic keymaps, basic autocmds
-- ============================================================
do

    require 'custom.keymaps'
    -- [[ Basic Keymaps ]]
    --  See `:help vim.keymap.set()`

    -- Clear highlights on search when pressing <Esc> in normal mode
    --  See `:help hlsearch`
    vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

    -- Diagnostic Config & Keymaps
    --  See `:help vim.diagnostic.Opts`
    vim.diagnostic.config {
        update_in_insert = false,
        severity_sort = true,
        float = {
            border = 'rounded',
            source = 'if_many'
        },
        underline = {
            severity = {
                min = vim.diagnostic.severity.WARN
            }
        },

        -- Can switch between these as you prefer
        virtual_text = true, -- Text shows up at the end of the line
        virtual_lines = false, -- Text shows up underneath the line, with virtual lines

        -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
        jump = {
            on_jump = function(_, bufnr)
                vim.diagnostic.open_float {
                    bufnr = bufnr,
                    scope = 'cursor',
                    focus = false
                }
            end
        }
    }

    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {
        desc = 'Open diagnostic [Q]uickfix list'
    })

    -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
    -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
    -- is not what someone will guess without a bit more experience.
    --
    -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
    -- or just use <C-\><C-n> to exit terminal mode
    vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', {
        desc = 'Exit terminal mode'
    })

    vim.keymap.set('n', '<C-h>', '<C-w><C-h>', {
        desc = 'Move focus to the left window'
    })
    vim.keymap.set('n', '<C-l>', '<C-w><C-l>', {
        desc = 'Move focus to the right window'
    })
    vim.keymap.set('n', '<C-j>', '<C-w><C-j>', {
        desc = 'Move focus to the lower window'
    })
    vim.keymap.set('n', '<C-k>', '<C-w><C-k>', {
        desc = 'Move focus to the upper window'
    })

    -- Highlight when yanking (copying) text
    --  Try it with `yap` in normal mode
    --  See `:help vim.hl.on_yank()`
    vim.api.nvim_create_autocmd('TextYankPost', {
        desc = 'Highlight when yanking (copying) text',
        group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {
            clear = true
        }),
        callback = function()
            vim.hl.on_yank()
        end
    })
end

-- ============================================================
-- SECTION 3: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks
-- ============================================================
do
    local function run_build(name, cmd, cwd)
        local result = vim.system(cmd, {
            cwd = cwd
        }):wait()
        if result.code ~= 0 then
            local stderr = result.stderr or ''
            local stdout = result.stdout or ''
            local output = stderr ~= '' and stderr or stdout
            if output == '' then
                output = 'No output from build command.'
            end
            vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
        end
    end

    -- This autocommand runs after a plugin is installed or updated and
    --  runs the appropriate build command for that plugin if necessary.
    --
    -- See `:help vim.pack-events`
    vim.api.nvim_create_autocmd('PackChanged', {
        callback = function(ev)
            local name = ev.data.spec.name
            local kind = ev.data.kind
            if kind ~= 'install' and kind ~= 'update' then
                return
            end

            if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
                run_build(name, {'make'}, ev.data.path)
                return
            end

            if name == 'LuaSnip' then
                if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then
                    run_build(name, {'make', 'install_jsregexp'}, ev.data.path)
                end
                return
            end

            if name == 'nvim-treesitter' then
                if not ev.data.active then
                    vim.cmd.packadd 'nvim-treesitter'
                end
                vim.cmd 'TSUpdate'
                return
            end
        end
    })
end

--- Because most plugins are hosted on GitHub, you can use the helper
--- function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo)
    return 'https://github.com/' .. repo
end

-- ============================================================
-- SECTION 4: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
    vim.pack.add {gh 'NMAC427/guess-indent.nvim'}
    require('guess-indent').setup {}

    -- Here is a more advanced configuration example that passes options to `gitsigns.nvim`
    --
    -- See `:help gitsigns` to understand what each configuration key does.
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    vim.pack.add {gh 'lewis6991/gitsigns.nvim'}
    local gitsigns = require 'gitsigns'
    gitsigns.setup {
        signs = {
            add = {
                text = '+'
            }, ---@diagnostic disable-line: missing-fields
            change = {
                text = '~'
            }, ---@diagnostic disable-line: missing-fields
            delete = {
                text = '_'
            }, ---@diagnostic disable-line: missing-fields
            topdelete = {
                text = '‾'
            }, ---@diagnostic disable-line: missing-fields
            changedelete = {
                text = '~'
            } ---@diagnostic disable-line: missing-fields
        },
        -- gitsigns.nvim's recommended keymaps:
        on_attach = function(bufnr)
            -- Navigation
            vim.keymap.set('n', ']c', function()
                if vim.wo.diff then
                    vim.cmd.normal {
                        ']c',
                        bang = true
                    }
                else
                    gitsigns.nav_hunk 'next'
                end
            end, {
                desc = 'Jump to next git [c]hange',
                buf = bufnr
            })

            vim.keymap.set('n', '[c', function()
                if vim.wo.diff then
                    vim.cmd.normal {
                        '[c',
                        bang = true
                    }
                else
                    gitsigns.nav_hunk 'prev'
                end
            end, {
                desc = 'Jump to previous git [c]hange',
                buf = bufnr
            })

            -- Visual mode actions
            vim.keymap.set('v', '<leader>hs', function()
                gitsigns.stage_hunk {vim.fn.line '.', vim.fn.line 'v'}
            end, {
                desc = 'git [s]tage hunk',
                buf = bufnr
            })
            vim.keymap.set('v', '<leader>hr', function()
                gitsigns.reset_hunk {vim.fn.line '.', vim.fn.line 'v'}
            end, {
                desc = 'git [r]eset hunk',
                buf = bufnr
            })
            -- Normal mode actions
            vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk, {
                desc = 'git [s]tage hunk',
                buf = bufnr
            })
            vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk, {
                desc = 'git [r]eset hunk',
                buf = bufnr
            })
            vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer, {
                desc = 'git [S]tage buffer',
                buf = bufnr
            })
            vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer, {
                desc = 'git [R]eset buffer',
                buf = bufnr
            })
            vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk, {
                desc = 'git [p]review hunk',
                buf = bufnr
            })
            vim.keymap.set('n', '<leader>hi', gitsigns.preview_hunk_inline, {
                desc = 'git preview hunk [i]nline',
                buf = bufnr
            })
            vim.keymap.set('n', '<leader>hb', function()
                gitsigns.blame_line {
                    full = true
                }
            end, {
                desc = 'git [b]lame line',
                buf = bufnr
            })
            vim.keymap.set('n', '<leader>hd', gitsigns.diffthis, {
                desc = 'git [d]iff against index',
                buf = bufnr
            })
            vim.keymap.set('n', '<leader>hD', function()
                gitsigns.diffthis '~'
            end, {
                desc = 'git [D]iff against last commit',
                buf = bufnr
            })
            vim.keymap.set('n', '<leader>hQ', function()
                gitsigns.setqflist 'all'
            end, {
                desc = 'git hunk [Q]uickfix list (all files in repo)',
                buf = bufnr
            })
            vim.keymap.set('n', '<leader>hq', gitsigns.setqflist, {
                desc = 'git hunk [q]uickfix list (all changes in this file)',
                buf = bufnr
            })
            -- Toggles
            vim.keymap.set('n', '<leader>tb', gitsigns.toggle_current_line_blame, {
                desc = '[T]oggle git show [b]lame line',
                buf = bufnr
            })
            vim.keymap.set('n', '<leader>tw', gitsigns.toggle_word_diff, {
                desc = '[T]oggle git intra-line [w]ord diff',
                buf = bufnr
            })
            -- Text object
            vim.keymap.set({'o', 'x'}, 'ih', gitsigns.select_hunk, {
                desc = 'text object [i]nside [h]unk',
                buf = bufnr
            })
        end
    }

    ---@diagnostic disable-next-line: missing-fields

    -- Highlight todo, notes, etc in comments
    vim.pack.add {gh 'folke/todo-comments.nvim'}
    require('todo-comments').setup {
        signs = false
    }

    -- [[ mini.nvim ]]
    --  A collection of various small independent plugins/modules
    vim.pack.add {gh 'nvim-mini/mini.nvim'}

    -- If a nerd font is available, load the icons module for pretty icons in various plugins.
    if vim.g.have_nerd_font then
        require('mini.icons').setup()
        -- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
        MiniIcons.mock_nvim_web_devicons()
    end

    require('mini.ai').setup {
        mappings = {
            around_next = 'aa',
            inside_next = 'ii'
        },
        n_lines = 500
    }

    require('mini.surround').setup({
        mappings = {
            add = '<leader>ua',
            delete = '<leader>ud',
            find = '<leader>uf',
            find_left = '<leader>uF',
            highlight = '<leader>uh',
            replace = '<leader>ur',
            update_n_lines = '<leader>un'
        }
    })

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    local statusline = require 'mini.statusline'
    -- Set `use_icons` to true if you have a Nerd Font
    statusline.setup {
        use_icons = vim.g.have_nerd_font
    }

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
        return '%2l:%-2v'
    end

    -- ... and there is more!
    --  Check out: https://github.com/nvim-mini/mini.nvim
end

-- ============================================================
-- SECTION 5: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ============================================================
do
    ---@type (string | vim.pack.Spec)[]
    local telescope_plugins = {gh 'nvim-lua/plenary.nvim', gh 'nvim-telescope/telescope.nvim',
                               gh 'nvim-telescope/telescope-ui-select.nvim'}
    if vim.fn.executable 'make' == 1 then
        table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim')
    end

    -- NOTE: You can install multiple plugins at once
    vim.pack.add(telescope_plugins)

    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
        extensions = {
            ['ui-select'] = {require('telescope.themes').get_dropdown()}
        }
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'

    -- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
    -- If you later switch picker plugins, this is where to update these mappings.
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('telescope-lsp-attach', {
            clear = true
        }),
        callback = function(event)
            local buf = event.buf

            -- Find references for the word under your cursor.
            vim.keymap.set('n', 'grr', builtin.lsp_references, {
                buffer = buf,
                desc = '[G]oto [R]eferences'
            })

            -- Jump to the implementation of the word under your cursor.
            -- Useful when your language has ways of declaring types without an actual implementation.
            vim.keymap.set('n', 'gri', builtin.lsp_implementations, {
                buffer = buf,
                desc = '[G]oto [I]mplementation'
            })

            -- Jump to the definition of the word under your cursor.
            -- This is where a variable was first declared, or where a function is defined, etc.
            -- To jump back, press <C-t>.
            vim.keymap.set('n', 'grd', builtin.lsp_definitions, {
                buffer = buf,
                desc = '[G]oto [D]efinition'
            })

            -- Fuzzy find all the symbols in your current document.
            -- Symbols are things like variables, functions, types, etc.
            vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, {
                buffer = buf,
                desc = 'Open Document Symbols'
            })

            -- Fuzzy find all the symbols in your current workspace.
            -- Similar to document symbols, except searches over your entire project.
            vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, {
                buffer = buf,
                desc = 'Open Workspace Symbols'
            })

            -- Jump to the type of the word under your cursor.
            -- Useful when you're not sure what type a variable is and you want to see
            -- the definition of its *type*, not where it was *defined*.
            vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, {
                buffer = buf,
                desc = '[G]oto [T]ype Definition'
            })
        end
    })

    -- Override default behavior and theme when searching
    vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false
        })
    end, {
        desc = '[/] Fuzzily search in current buffer'
    })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files'
        }
    end, {
        desc = '[S]earch [/] in Open Files'
    })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files {
            cwd = vim.fn.stdpath 'config',
            follow = true
        }
    end, {
        desc = '[S]earch [N]eovim files'
    })
end

-- ============================================================
-- SECTION 6: LSP
-- LSP keymaps, server configuration, Mason tools installations
-- ============================================================
do
    vim.pack.add {gh 'j-hui/fidget.nvim'}
    require('fidget').setup {}

    --  This function gets run when an LSP attaches to a particular buffer.
    --    That is to say, every time a new file is opened that is associated with
    --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
    --    function will be executed to configure the current buffer
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', {
            clear = true
        }),
        callback = function(event)
            -- NOTE: Remember that Lua is a real programming language, and as such it is possible
            -- to define small helper and utility functions so you don't have to repeat yourself.
            --
            -- In this case, we create a function that lets us more easily define mappings specific
            -- for LSP related items. It sets the mode, buffer and description for us each time.
            local map = function(keys, func, desc, mode)
                mode = mode or 'n'
                vim.keymap.set(mode, keys, func, {
                    buffer = event.buf,
                    desc = 'LSP: ' .. desc
                })
            end

            -- Rename the variable under your cursor.
            --  Most Language Servers support renaming across files, etc.
            map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

            -- Execute a code action, usually your cursor needs to be on top of an error
            -- or a suggestion from your LSP for this to activate.
            map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', {'n', 'x'})

            -- WARN: This is not Goto Definition, this is Goto Declaration.
            --  For example, in C this would take you to the header.
            map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

            -- The following two autocommands are used to highlight references of the
            -- word under your cursor when your cursor rests there for a little while.
            --    See `:help CursorHold` for information about when this is executed
            --
            -- When you move your cursor, the highlights will be cleared (the second autocommand).
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            if client and client:supports_method('textDocument/documentHighlight', event.buf) then
                local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', {
                    clear = false
                })
                vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
                    buffer = event.buf,
                    group = highlight_augroup,
                    callback = vim.lsp.buf.document_highlight
                })

                vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
                    buffer = event.buf,
                    group = highlight_augroup,
                    callback = vim.lsp.buf.clear_references
                })

                vim.api.nvim_create_autocmd('LspDetach', {
                    group = vim.api.nvim_create_augroup('kickstart-lsp-detach', {
                        clear = true
                    }),
                    callback = function(event2)
                        vim.lsp.buf.clear_references()
                        vim.api.nvim_clear_autocmds {
                            group = 'kickstart-lsp-highlight',
                            buffer = event2.buf
                        }
                    end
                })
            end

            -- The following code creates a keymap to toggle inlay hints in your
            -- code, if the language server you are using supports them
            --
            -- This may be unwanted, since they displace some of your code
            if client and client:supports_method('textDocument/inlayHint', event.buf) then
                map('<leader>th', function()
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {
                        bufnr = event.buf
                    })
                end, '[T]oggle Inlay [H]ints')
            end
        end
    })

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --  See `:help lsp-config` for information about keys and how to configure
    ---@type table<string, vim.lsp.Config>
    local servers = {
        stylua = {}, -- Used to format Lua code

        -- Special Lua Config, as recommended by neovim help docs
        lua_ls = {
            on_init = function(client)
                client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

                if client.workspace_folders then
                    local path = client.workspace_folders[1].name
                    if path ~= vim.fn.stdpath 'config' and
                        (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
                        return
                    end
                end

                local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
                client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
                    runtime = {
                        version = 'LuaJIT',
                        path = {'lua/?.lua', 'lua/?/init.lua'}
                    },
                    workspace = {
                        checkThirdParty = false,
                        -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
                        --  See https://github.com/neovim/nvim-lspconfig/issues/3189
                        library = vim.api.nvim_get_runtime_file('', true)
                    }
                })
            end,
            ---@type lspconfig.settings.lua_ls
            settings = {
                Lua = {
                    format = {
                        enable = false
                    } -- Disable formatting (formatting is done by stylua)
                }
            }
        }
    }

    vim.pack.add {gh 'neovim/nvim-lspconfig', gh 'mason-org/mason.nvim', gh 'mason-org/mason-lspconfig.nvim',
                  gh 'WhoIsSethDaniel/mason-tool-installer.nvim'}

    -- Automatically install LSPs and related tools to stdpath for Neovim
    require('mason').setup {}

    -- Translates between nvim-lspconfig server names and mason.nvim package names (e.g. lua_ls <-> lua-language-server)
    require('mason-lspconfig').setup {
        automatic_enable = false -- Change this to true if you want to automatically enable servers that are installed manually (e.g. via :Mason / :MasonInstall)
    }

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
        -- You can add other tools here that you want Mason to install
    })

    require('mason-tool-installer').setup {
        ensure_installed = ensure_installed
    }

    for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
    end
end

-- ============================================================
-- SECTION 7: FORMATTING
-- conform.nvim setup and keymap
-- ============================================================
do
    -- [[ Formatting ]]
    vim.pack.add {gh 'stevearc/conform.nvim'}
    require('conform').setup {
        notify_on_error = false,
        format_on_save = function(bufnr)
            -- You can specify filetypes to autoformat on save here:
            local enabled_filetypes = {
                -- lua = true,
                -- python = true,
            }
            if enabled_filetypes[vim.bo[bufnr].filetype] then
                return {
                    timeout_ms = 500
                }
            else
                return nil
            end
        end,
        default_format_opts = {
            lsp_format = 'fallback' -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
        },
        -- You can also specify external formatters in here.
        formatters_by_ft = {
            -- rust = { 'rustfmt' },
            -- Conform can also run multiple formatters sequentially
            -- python = { "isort", "black" },
            --
            -- You can use 'stop_after_first' to run the first available formatter from the list
            -- javascript = { "prettierd", "prettier", stop_after_first = true },
        }
    }

    vim.keymap.set({'n', 'v'}, '<leader>f', function()
        require('conform').format {
            async = true
        }
    end, {
        desc = '[F]ormat buffer'
    })
end

-- ============================================================
-- SECTION 8: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup
-- ============================================================

-- ============================================================
-- SECTION 9: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ============================================================
do
    -- [[ Configure Treesitter ]]
    --  Used to highlight, edit, and navigate code
    --
    --  See `:help nvim-treesitter-intro`

    -- NOTE: You can also specify a branch or a specific commit
    vim.pack.add {{
        src = gh 'nvim-treesitter/nvim-treesitter',
        version = 'main'
    }}

    -- Ensure basic parsers are installed
    local parsers = {'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim',
                     'vimdoc'}
    require('nvim-treesitter').install(parsers)

    ---@param buf integer
    ---@param language string
    local function treesitter_try_attach(buf, language)
        -- Check if the buffer is valid (might not be after install completes)
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end

        -- Check if a parser exists and load it
        if not vim.treesitter.language.add(language) then
            return
        end

        -- Enable syntax highlighting and other treesitter features
        vim.treesitter.start(buf, language)

        local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil

        -- Enable treesitter based indentation
        if has_indent_query then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end

    local available_parsers = require('nvim-treesitter').get_available()
    vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
            local buf, filetype = args.buf, args.match

            local language = vim.treesitter.language.get_lang(filetype)
            if not language then
                return
            end

            local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

            if vim.tbl_contains(installed_parsers, language) then
                -- Enable the parser if it is already installed
                treesitter_try_attach(buf, language)
            elseif vim.tbl_contains(available_parsers, language) then
                -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
                require('nvim-treesitter').install(language):await(function()
                    treesitter_try_attach(buf, language)
                end)
            else
                -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
                treesitter_try_attach(buf, language)
            end
        end
    })
end

-- ============================================================
-- SECTION 10: OPTIONAL EXAMPLES / NEXT STEPS
-- kickstart.plugins.* examples
-- ============================================================
do
    -- Принудительно активируем flash.nvim, чтобы он не терялся при загрузке
    vim.cmd('packadd flash.nvim')

    -- NOTE: You can add your own plugins, configuration, etc. in `lua/custom/plugins/*.lua`.
    --
    -- For independent modules, uncomment the convenience loader:
    require 'custom.plugins'
    --
    -- `custom.plugins` automatically loads files from that directory, but their
    -- order is unspecified. If plugins depend on each other, keep them in the same
    -- file and put their `vim.pack.add()` and `setup()` calls in the required order.
    --
    -- If separate modules need a specific order, require them explicitly instead:
    -- require 'custom.plugins.colorscheme'
    -- require 'custom.plugins.ui'
    -- require 'custom.plugins.git'
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- ============================================================
-- SECTION 11: CUSTOM AUTOCMDS
-- ============================================================
do
    require 'custom.autocmds'
end
