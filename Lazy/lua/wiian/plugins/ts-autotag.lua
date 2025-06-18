return {
    -- 1) Treesitter itself, without autotag in its setup:
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",                 -- keep parsers up-to-date
        event = { "BufReadPost", "BufNewFile" }, -- lazy-load on file open
        config = function()
            require("nvim-treesitter.configs").setup {
                -- list the languages you care about:
                ensure_installed = {
                    "html",
                    "javascript",
                    "typescript",
                    "tsx",
                    "vue",
                    "php",
                    "css",
                    "json",
                    "svelte",
                    "xml",
                },
                highlight        = { enable = true },
                indent           = { enable = true },
                -- **no** `autotag` field here
            }
        end,
    },

    -- 2) ts-autotag, declared as a dependency of treesitter:
    {
        "windwp/nvim-ts-autotag",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        -- load it as soon as you start typing tags:
        event = "InsertEnter",
        config = function()
            -- now call its own setup() (the only supported way going forward):
            require("nvim-ts-autotag").setup()
        end,
    },
}
