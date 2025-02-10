local options = vim.opt

options.nu = true
options.relativenumber = true

options.tabstop = 4
options.softtabstop = 4
options.shiftwidth = 4
options.expandtab = true

options.smartindent = true

options.wrap = false

-- Global formatting options
options.formatoptions = options.formatoptions
- "r" -- Don't continue comments on newline
- "o" -- Don't continue comment with 'o' or 'O'
- "c" -- Don't automatically continue '//' comments
+ "q" -- Allow formatting of comments with 'gq'

options.colorcolumn = "120"
