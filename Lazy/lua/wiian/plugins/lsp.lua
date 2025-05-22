return {
    ------------------------------------------------------------------------------
    -- Mason: install/manage LSP servers, linters, formatters, etc.
    ------------------------------------------------------------------------------
    {
        "mason-org/mason.nvim",
        build = ":MasonUpdate",
        config = function()
            require("mason").setup()

            -- Enable all diagnostic displays
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "■", -- Could be '●', '■', '▎', etc.
                    spacing = 2, -- How much space between text and virtual text
                },
                signs = true, -- Show icons in the sign column
                underline = true, -- Underline problematic text
                update_in_insert = false, -- Don’t update diagnostics while in insert mode
                severity_sort = true, -- Sort diagnostics by severity
            })
        end,
    },

    ------------------------------------------------------------------------------
    -- Mason-LSPConfig v2: bridge Mason & nvim-lspconfig, now with `handlers` in setup
    ------------------------------------------------------------------------------
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            local mlsp         = require("mason-lspconfig")
            local lspconfig    = require("lspconfig")
            local cmp_nvim_lsp = require("cmp_nvim_lsp")

            -- Shared capabilities & on_attach
            local capabilities = cmp_nvim_lsp.default_capabilities(
                vim.lsp.protocol.make_client_capabilities()
            )
            local on_attach    = function(client, bufnr)
                local bufmap = function(mode, lhs, rhs)
                    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, {
                        noremap = true,
                        silent  = true,
                    })
                end

                -- LSP keybindings
                bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
                bufmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
                bufmap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
                bufmap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
                bufmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
                bufmap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
                bufmap("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>")
                bufmap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
                bufmap("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<CR>")
                bufmap("n", "<F3>", "<cmd>lua vim.lsp.buf.format()<CR>")
                bufmap("x", "<F3>", "<cmd>lua vim.lsp.buf.format()<CR>")

                -- signature help on CursorHoldI if supported
                if client.server_capabilities.signatureHelpProvider then
                    vim.api.nvim_create_autocmd("CursorHoldI", {
                        buffer   = bufnr,
                        callback = vim.lsp.buf.signature_help,
                    })
                end
            end

            local util         = require("lspconfig/util")

            -- Single setup, with `handlers` table (v2 API)
            mlsp.setup {
                ensure_installed = {
                    "lua_ls",        -- Lua
                    "pyright",       -- Python
                    "ts_ls",         -- TS/JS
                    "clangd",        -- C/C++
                    "marksman",      -- Markdown
                    "rust_analyzer", -- Rust
                },
                automatic_installation = true,
                handlers = {
                    -- default handler for all servers
                    function(server_name)
                        lspconfig[server_name].setup {
                            on_attach    = on_attach,
                            capabilities = capabilities,
                        }
                    end,

                    -- override lua_ls to recognize `vim` global
                    ["lua_ls"] = function()
                        lspconfig.lua_ls.setup {
                            on_attach    = on_attach,
                            capabilities = capabilities,
                            settings     = {
                                Lua = {
                                    diagnostics = {
                                        globals = { "vim" },
                                    },
                                },
                            },
                        }
                    end,

                    -- override marksman to disable signatureHelp
                    ["marksman"] = function()
                        lspconfig.marksman.setup {
                            on_attach    = on_attach,
                            capabilities = capabilities,
                            handlers     = {
                                ["textDocument/signatureHelp"] = function() end,
                            },
                        }
                    end,
                    ["ts_ls"] = function()
                        local lspconfig = require("lspconfig")

                        -- 1) find your TS project root via tsconfig.json/jsconfig.json/package.json or .git
                        local root_dir = util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git")

                        -- 2) determine the project’s path on disk
                        local project_root = root_dir(vim.fn.expand("%:p")) or vim.loop.cwd()

                        -- 3) point tsserver at your local TS lib (if it exists)
                        local tsdk = project_root .. "/node_modules/typescript/lib"
                        if not vim.loop.fs_stat(tsdk) then
                            tsdk = nil
                        end

                        lspconfig.ts_ls.setup({
                            on_attach    = on_attach,
                            capabilities = capabilities,
                            -- leave `cmd = { "typescript-language-server", "--stdio" }` alone
                            root_dir     = root_dir,
                            settings     = {
                                typescript = { tsdk = tsdk },
                                javascript = { tsdk = tsdk },
                            },
                        })
                    end,
                },
            }

            -- Format on save
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.lua,*.rs,*.ts,*.py",
                callback = function()
                    vim.lsp.buf.format({ async = false })
                end,
            })
        end,
    },

    ------------------------------------------------------------------------------
    -- Completion: nvim-cmp + snippet support
    ------------------------------------------------------------------------------
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            local cmp     = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "nvim_lsp_signature_help" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "luasnip" },
                },
            }
        end,
    },
}
