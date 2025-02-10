return {
    -- Lazy.nvim setup for mason and lsp-zero
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate", -- Run MasonUpdate after installation
        config = function()
            require("mason").setup()
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-lspconfig").setup {
                ensure_installed = {
                    "lua_ls",  -- Lua LSP
                    "pyright", -- Python LSP
                    "ts_ls",   -- TypeScript/JavaScript LSP
                    "clangd",  -- C/C++ LSP
                },
                automatic_installation = true,
            }

            require("mason-lspconfig").setup_handlers {
                -- Default server handler, called on installed servers that don't already have a handler
                function(server_name)
                    require("lspconfig")[server_name].setup {}
                end,
                -- Specific language server setup_handlers
                ["lua_ls"] = function()
                    require("lspconfig").lua_ls.setup {
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim" },
                                },
                            },
                        },
                    }
                end,
                -- Marksman LSP settings (disabling signatureHelp)
                ["marksman"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.marksman.setup {
                        handlers = {
                            ["textDocument/signatureHelp"] = function() end, -- Disables signatureHelp
                        },
                    }
                end,
            }
        end,
    },
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v2.x",
        dependencies = {
            -- LSP Support
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- Autocompletion
            { "hrsh7th/nvim-cmp" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-nvim-lsp-signature-help" },
            { "saadparwaiz1/cmp_luasnip" },
            { "L3MON4D3/LuaSnip" }, -- Snippets plugin
        },
        config = function()
            local lsp = require("lsp-zero").preset("recommended")
            -- lsp.configure("ts_ls", {
            --     init_options = {
            --         preferences = {
            --             importModuleSpecifierPreference = "relative", -- or "non-relative"
            --             importModuleSpecifierEnding = "auto",
            --         }
            --     }
            -- })

            -- Setup LSP mappings and keybinds
            lsp.on_attach(function(client, bufnr)
                local opts = { noremap = true, silent = true }
                local keymap = vim.api.nvim_buf_set_keymap

                -- Use `bufnr` directly as the buffer number
                keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
                keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
                keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
                keymap(bufnr, "n", "go", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
                keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
                keymap(bufnr, "n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
                keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
                keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
                keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
                keymap(bufnr, "n", "<F3>", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
                keymap(bufnr, "x", "<F3>", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
                keymap(bufnr, "n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
                keymap(bufnr, "n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)

                -- Trigger signature help when typing a function delcaration
                if client.server_capabilities.signatureHelpProvider then
                    vim.api.nvim_create_autocmd("CursorHoldI", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.signature_help()
                        end,
                    })
                end
            end)

            lsp.setup()

            -- Autocompletion settings
            local cmp = require("cmp")
            cmp.setup({
                mapping = {
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "nvim_lsp_signature_help" }
                },
            })
        end,
    },
}
