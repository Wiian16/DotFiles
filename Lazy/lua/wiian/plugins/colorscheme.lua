-- return {
-- 	"nxstynate/onedarkpro.nvim",
-- 	priority = 1000,
-- 	config = function()
-- 		--load colorscheme
-- 		vim.cmd([[colorscheme onedarkpro]])
-- 	end,
-- }

-- return {
--     "navarasu/onedark.nvim",
--     priority = 1000,
--     config = function()
--         vim.cmd([[colorscheme onedark]])
--     end
-- }

-- return {
-- 	"rebelot/kanagawa.nvim",
-- 	priority = 1000,
-- 	config = function()
-- 		vim.cmd([[colorscheme kanagawa-dragon]])
-- 	end,
-- }
--
-- return {
-- 	"folke/tokyonight.nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	opts = {},
-- 	config = function()
-- 		vim.cmd([[colorscheme tokyonight]])
-- 	end,
-- }

return {
	"oxfist/night-owl.nvim",
	lazy = false,
	priority = 1000,
	opts = {},
	config = function()
		vim.cmd([[colorscheme night-owl]])
	end,
}
