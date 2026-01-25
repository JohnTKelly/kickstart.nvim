-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

-- NOTE: JTK - Adding Powershell as the terminal emulator.

-- vim.opt.shell = '"C:\\Program Files\\PowerShell\\7\\pwsh.exe"'
-- vim.opt.shellquote = '"'
-- vim.opt.shellxquote = ''
-- vim.api.nvim_set_var(
-- 'shellcmdflag',
-- '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[Out-File:Encoding]=utf8;Remove-Alias -Force -ErrorAction SilentlyContinue tee;'
-- )
-- vim.api.nvim_set_var('shellreir', '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode')
-- vim.api.nvim_set_var('shellpipe', '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode')
-- vim.api.nvim_set_var('shellquote', 'shellxquote')
--

-- Store original shell settings for restoration if needed
-- local original_shell = vim.o.shell
-- local original_shellcmdflag = vim.o.shellcmdflag

-- Configure PowerShell as terminal emulator
-- vim.opt.shell = 'pwsh'
-- vim.opt.shellcmdflag = '-nologo -noprofile -ExecutionPolicy RemoteSigned -command'

-- Set shell redirection and piping for PowerShell
-- vim.api.nvim_set_var('shellredir', '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode')
-- vim.api.nvim_set_var('shellpipe', '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode')
-- vim.api.nvim_set_var('shellquote', '')

-- Set PowerShell as the default shell
vim.opt.shell = 'pwsh'
vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
vim.opt.shellquote = ''
vim.opt.shellxquote = ''

-- Simplified redirection and piping
vim.opt.shellredir = '| Out-File -Encoding UTF8 %s; exit $LastExitCode'
vim.opt.shellpipe = '| Out-File -Encoding UTF8 %s; exit $LastExitCode'
