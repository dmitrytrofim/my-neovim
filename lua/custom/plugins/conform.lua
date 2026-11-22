-- lua/custom/plugins/conform.lua
vim.pack.add {'https://github.com/stevearc/conform.nvim'}

require('conform').setup {
    -- Важно: format_after_save работает асинхронно ПОСЛЕ записи и не блокирует Neovide
    -- Либо убери его совсем, если форматируешь только по F5 и <leader>f
    format_after_save = {
        lsp_format = 'fallback'
    },
    formatters_by_ft = {
        javascript = {
            'eslint_d',
            'prettier',
            stop_after_first = true
        },
        typescript = {
            'eslint_d',
            'prettier',
            stop_after_first = true
        },
        javascriptreact = {
            'eslint_d',
            'prettier',
            stop_after_first = true
        },
        typescriptreact = {
            'eslint_d',
            'prettier',
            stop_after_first = true
        },
        json = {
            'prettier',
            stop_after_first = true
        },
        jsonc = {
            'prettier',
            stop_after_first = true
        },

        css = {
            'prettier',
            stop_after_first = true
        },
        scss = {
            'prettier',
            stop_after_first = true
        },
        html = {
            'prettier',
            stop_after_first = true
        }
    },
    formatters = {
        prettierd = {
            prepend_args = {'--tab-width', '4', '--use-tabs', 'false', '--html-whitespace-sensitivity', 'ignore',
                            '--bracket-same-line'}
        },
        prettier = {
            prepend_args = {'--tab-width', '4', '--use-tabs', 'false', '--html-whitespace-sensitivity', 'ignore',
                            '--bracket-same-line'}
        }
    }
}

