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
                    prefix = "■",
                    spacing = 2,
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })
        end,
    },

    ------------------------------------------------------------------------------
    -- Mason-LSPConfig: bridge Mason & nvim-lspconfig
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

            local capabilities = cmp_nvim_lsp.default_capabilities(
                vim.lsp.protocol.make_client_capabilities()
            )

            mlsp.setup {
                ensure_installed = {
                    "lua_ls", "pyright", "ts_ls", "clangd",
                    "marksman", "rust_analyzer",
                },
                automatic_installation = true,
                handlers = {
                    -- default handler
                    function(server_name)
                        lspconfig[server_name].setup {
                            capabilities = capabilities,
                        }
                    end,

                    -- lua_ls: add vim as global
                    ["lua_ls"] = function()
                        lspconfig.lua_ls.setup {
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    diagnostics = { globals = { "vim" } },
                                },
                            },
                        }
                    end,

                    -- marksman: disable signatureHelp (annoying)
                    ["marksman"] = function()
                        lspconfig.marksman.setup {
                            capabilities = capabilities,
                            handlers = {
                                ["textDocument/signatureHelp"] = function() end,
                            },
                        }
                    end,

                    -- omnisharp: extra flags
                    ["omnisharp"] = function()
                        lspconfig.omnisharp.setup {
                            cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
                            enable_editorconfig_support = true,
                            enable_roslyn_analyzers = true,
                            organize_imports_on_format = true,
                            enable_import_completion = true,
                            sdk_include_prereleases = true,
                            analyze_open_documents_only = false,
                            capabilities = capabilities,
                        }
                    end,
                },
            }

            ------------------------------------------------------------------------------
            -- Global LSP keymaps (applied via LspAttach, not per-server on_attach)
            ------------------------------------------------------------------------------
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local bufnr = ev.buf
                    local client = vim.lsp.get_client_by_id(ev.data.client_id)

                    local bufmap = function(mode, lhs, rhs)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true })
                    end

                    -- LSP keymaps
                    bufmap("n", "gd", vim.lsp.buf.definition)
                    bufmap("n", "gD", vim.lsp.buf.declaration)
                    bufmap("n", "gi", vim.lsp.buf.implementation)
                    bufmap("n", "gr", vim.lsp.buf.references)
                    bufmap("n", "K", vim.lsp.buf.hover)
                    bufmap("n", "<leader>rn", vim.lsp.buf.rename)
                    bufmap("n", "<F2>", vim.lsp.buf.rename)
                    bufmap("n", "<leader>ca", vim.lsp.buf.code_action)
                    bufmap("n", "<F4>", vim.lsp.buf.code_action)
                    bufmap({ "n", "x" }, "<F3>", function()
                        require("conform").format({
                            async = true,
                            lsp_fallback = true, -- fall back to LSP if no formatter configured
                        })
                    end)

                    -- optional: signature help
                    if client and client.server_capabilities.signatureHelpProvider then
                        vim.api.nvim_create_autocmd("CursorHoldI", {
                            buffer = bufnr,
                            callback = vim.lsp.buf.signature_help,
                        })
                    end
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

    ------------------------------------------------------------------------------
    -- Formatter integration: Conform.nvim
    ------------------------------------------------------------------------------
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        config = function()
            require("conform").setup({
                formatters_by_ft = {
                    lua = { "stylua" },
                    python = { "yapf" },
                    javascript = { "prettier" },
                    typescript = { "prettier" },
                    sh = { "shfmt" },
                    -- fallback to LSP if nothing is configured
                },
                format_on_save = function(bufnr)
                    -- Try conform first, then fallback to LSP
                    return {
                        lsp_fallback = true,
                        timeout_ms = 1000,
                    }
                end,
            })
        end,
    },
}
