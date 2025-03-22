vim.optfcmdheight = 0 -- Optional: Hide command line when not in use
-- disable mouse
vim.opt.mouse = ""


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Install & configure plugins
require("lazy").setup({
	spec = {
		-- LSP & Completion
		{ "neovim/nvim-lspconfig" },
		{ "williamboman/mason.nvim",           build = ":MasonUpdate" },
		{ "williamboman/mason-lspconfig.nvim", dependencies = { "neovim/nvim-lspconfig" } },
		{
			"hrsh7th/nvim-cmp",
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"saadparwaiz1/cmp_luasnip",
				"L3MON4D3/LuaSnip",
				"zbirenbaum/copilot-cmp",
			}
		},
		{ "zbirenbaum/copilot.lua",                 cmd = "Copilot",                                 event = "InsertEnter" },
		{ "zbirenbaum/copilot-cmp",                 dependencies = { "zbirenbaum/copilot.lua" } },
		{ "nvim-treesitter/nvim-treesitter",        build = ":TSUpdate" },
		{ 'nvim-treesitter/nvim-treesitter-context' },

		-- UI Enhancements
		{ "catppuccin/nvim",                        name = "catppuccin",                             priority = 1000 },
		{ "nvim-lualine/lualine.nvim",              dependencies = { "nvim-tree/nvim-web-devicons" } },
		{ "folke/which-key.nvim",                   event = "VeryLazy" },
		{ "nvim-tree/nvim-tree.lua",                dependencies = { "nvim-tree/nvim-web-devicons" } },

		-- Productivity
		{ "nvim-telescope/telescope.nvim",          cmd = "Telescope" },
		{ "stevearc/conform.nvim" },
		{
			"theprimeagen/harpoon",
			branch = "harpoon2",
			dependencies = { "nvim-lua/plenary.nvim" },
			config = function()
				require("harpoon"):setup()
			end,
			keys = {
				{ "<leader>A", function() require("harpoon"):list():append() end,  desc = "harpoon file", },
				{
					"<tab>",
					function()
						local harpoon = require("harpoon")
						harpoon.ui:toggle_quick_menu(harpoon:list())
					end,
					desc = "harpoon quick menu",
				},
				{ "<leader>1", function() require("harpoon"):list():select(1) end, desc = "harpoon to file 1", },
				{ "<leader>2", function() require("harpoon"):list():select(2) end, desc = "harpoon to file 2", },
				{ "<leader>3", function() require("harpoon"):list():select(3) end, desc = "harpoon to file 3", },
				{ "<leader>4", function() require("harpoon"):list():select(4) end, desc = "harpoon to file 4", },
				{ "<leader>5", function() require("harpoon"):list():select(5) end, desc = "harpoon to file 5", },
			},
		},
		-- Icons & Misc
		{ "nvim-tree/nvim-web-devicons" },
	},
	install = { colorscheme = { "catppuccin" } },
	checker = { enabled = true },
})

-- Configure nvim-tree
require("nvim-tree").setup({
	view = {
		side = "right", -- Open file tree on the right side
		width = 35, -- Set tree width
	},
	update_focused_file = {
		enable = true,
	},
	filters = {
		dotfiles = false, -- Show dotfiles
	},
})

-- LSP Configuration
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "pyright", "rust_analyzer", "ts_ls", "elixirls" },
	automatic_installation = true,
})

local lspconfig = require("lspconfig")
lspconfig.gleam.setup({})

local capabilities = require("cmp_nvim_lsp").default_capabilities()
lspconfig.ts_ls.setup({ capabilities = capabilities })
lspconfig.eslint.setup({
	on_attach = function(client, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			command = "EslintFixAll",
		})
	end,
	capabilities = capabilities
})


require("mason-lspconfig").setup_handlers({
	function(server_name)
		lspconfig[server_name].setup({ capabilities = capabilities })
	end,
})

require("copilot").setup({
	suggestion = { enabled = false }, -- Disable inline suggestions
	panel = { enabled = false }, -- No floating panel
})
require("copilot_cmp").setup()

local cmp = require("cmp")
cmp.setup({
	snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },   -- LSP completions only
		{ name = "copilot", group_index = 2 }, -- Copilot (secondary source)
	}),
})

-- Formatting with Conform
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black", "isort" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		go = { "gofmt", "goimports" },
		rust = { "rustfmt" },
		json = { "prettier" },
		css = { "prettier" },
		gleam = { "gleam format" },
		erlang = { "erl_tidy" },
		exlixir = { "mix format" },
	},
	format_on_save = { timeout_ms = 500, lsp_fallback = true },
})
vim.keymap.set({ "n", "v" }, "<leader>lf", function() require("conform").format({ async = true }) end,
	{ desc = "Format Buffer" })

require("lualine").setup({
	options = {
		theme = "auto",
		section_separators = "",
		component_separators = "|",
		globalstatus = true,
	},
})

require("nvim-treesitter.configs").setup({
	ensure_installed = { "lua", "python", "javascript", "typescript", "go", "rust", "json", "yaml", "html", "css", "bash", "gleam", "erlang", "elixir" }, -- Add more as needed
	highlight = { enable = true },                                                                                                                 -- Enable syntax highlighting
	indent = { enable = true },                                                                                                                    -- Enable indentation based on Treesitter
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-space>",
			node_incremental = "<C-space>",
			scope_incremental = "<C-s>",
			node_decremental = "<C-backspace>",
		},
	},
})


-- Telescope keymaps
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.git_files, { desc = "Find Git Files" })
vim.keymap.set("n", "<leader>fa", telescope.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fo", telescope.lsp_document_symbols, { desc = "Show Symbols" })
vim.keymap.set("n", "<leader>fs", ":NvimTreeToggle<CR>", { desc = "Toggle File Tree" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "List Buffers" })
-- Telescop git commands
vim.keymap.set("n", "<leader>gc", telescope.git_commits, { desc = "List Commits" })
vim.keymap.set("n", "<leader>gb", telescope.git_branches, { desc = "List Branches" })
vim.keymap.set("n", "<leader>gs", telescope.git_status, { desc = "Show Status" })


-- Window navigation
vim.keymap.set("n", "<leader>bs", ":vsplit<CR>", { desc = "Split Left" })
vim.keymap.set("n", "<leader>bh", "<C-w>h", { desc = "Move Left" })
vim.keymap.set("n", "<leader>bl", "<C-w>l", { desc = "Move Right" })
vim.keymap.set("n", "<leader>bq", ":close<CR>", { desc = "Close Split" })

-- Buffer management
vim.keymap.set("n", "<leader>qq", function()
	local buf = vim.api.nvim_get_current_buf()
	vim.cmd("bprevious")
	vim.cmd("bdelete " .. buf)
end, { desc = "Close Current Buffer" })
vim.api.nvim_create_user_command("BufOnly", "bufdo bdelete|edit #|bdelete #", {})
vim.keymap.set("n", "<leader>qo", ":BufOnly<CR>", { desc = "Close All But Current Buffer" })

-- LSP keybindings
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gr", telescope.lsp_references, { desc = "Go to References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Information" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })
vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float, { desc = "Show Diagnostics" })
vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
-- Clipboard keybindings
vim.keymap.set("n", "<leader>s", function()
	local unnamed = vim.fn.getreg('"')
	local system = vim.fn.getreg('*')

	-- Swap the registers
	vim.fn.setreg('"', system)
	vim.fn.setreg('*', unnamed)

	print("Swapped unnamed register and system clipboard")
end, { desc = "Swap paste buffer with system clipboard" })
-- paste without losing the paste buffer
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without overwrite" })

-- Enable true color support
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd.colorscheme("catppuccin-mocha");

-- Make a toggle for the theme <spc>tt (toggle theme)
local function toggle_theme()
	local theme = vim.g.colors_name
	if theme == "catppuccin-mocha" then
		vim.cmd("colorscheme catppuccin-latte")
	else
		vim.cmd("colorscheme catppuccin-mocha")
	end
end

vim.keymap.set("n", "<leader>tt", toggle_theme, { desc = "Toggle Theme" })

-- Number toggle
vim.opt.number = true
local num_group = vim.api.nvim_create_augroup("numbertoggle", {})
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave" },
	{ group = num_group, callback = function() vim.opt.relativenumber = true end })
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter" },
	{ group = num_group, callback = function() vim.opt.relativenumber = false end })


-- Set up tab stops
vim.opt.tabstop = 3

-- Auto save on normal mode
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	callback = function()
		vim.cmd("silent! write")
	end
})

-- Set up langauge specific settings
-- Set Gleam filetype indentation to 2 spaces
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gleam",
	callback = function()
		vim.bo.shiftwidth = 2 -- Number of spaces to use for each indentation level
		vim.bo.tabstop = 2 -- Number of spaces a tab character counts for
		vim.bo.expandtab = true -- Use spaces instead of tabs
	end
})
