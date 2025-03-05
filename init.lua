vim.opt.cmdheight = 0 -- Optional: Hide command line when not in use
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)


-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


-- Say hello

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- add your plugins here
		{
			"zbirenbaum/copilot.lua",
			cmd = "Copilot",
			event = "InsertEnter",
			config = function()
				require("copilot").setup({
					suggestion = { enabled = false },
					panel = { enabled = false },
				})
			end,
		},
		{
			"zbirenbaum/copilot-cmp",
			dependencies = { "zbirenbaum/copilot.lua" },
			config = function()
				require("copilot_cmp").setup()
			end,
		},
		{
			"hrsh7th/nvim-cmp",
			dependencies = { "zbirenbaum/copilot-cmp" },
			opts = function(_, opts)
				opts.sources = opts.sources or {} -- Ensure sources table exists
				table.insert(opts.sources, { name = "copilot", group_index = 2 })
			end,
		},
		{
			"nvim-telescope/telescope.nvim",
			cmd = "Telescope",
			version = false -- telescope did only one release, so use HEAD for now
		},
		{
			"catppuccin/nvim",
			name = "catppuccin",
			priority = 1000, -- Ensure it loads first
			config = function()
				require("catppuccin").setup({
					flavour = "auto", -- Auto-switch between dark & light
					integrations = {
						treesitter = true,
						telescope = true,
						nvimtree = true,
					},
				})
				vim.cmd.colorscheme("catppuccin") -- Set theme
			end,
		},
		{
			"folke/which-key.nvim",
			event = "VeryLazy",
			opts = {
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			},
			keys = {
				{
					"<leader>?",
					function()
						require("which-key").show({ global = false })
					end,
					desc = "Buffer Local Keymaps (which-key)",
				},
			},
		},
		{
			"williamboman/mason.nvim",
			build = ":MasonUpdate", -- Auto-update Mason registry
			config = function()
				require("mason").setup()
			end,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			dependencies = { "neovim/nvim-lspconfig" },
			config = function()
				require("mason-lspconfig").setup({
					ensure_installed = { "lua_ls", "pyright", "rust_analyzer", "intelephense" }, -- Add your needed servers
					automatic_installation = true,            -- Auto-install missing LSPs
				})

				local lspconfig = require("lspconfig")
				require("mason-lspconfig").setup_handlers({
					function(server_name) -- Auto setup installed LSPs
						lspconfig[server_name].setup({})
					end,
				})
			end,
		},
		{
			"stevearc/conform.nvim",
			config = function()
				require("conform").setup({
					formatters_by_ft = {
						lua = { "stylua" },
						python = { "black", "isort" },
						javascript = { "prettier" },
						typescript = { "prettier" },
						go = { "gofmt", "goimports" },
						rust = { "rustfmt" },
						json = { "prettier" },
						yaml = { "prettier" },
						php = { "php-cs-fixer" },
						markdown = { "prettier" },
						html = { "prettier" },
						css = { "prettier" },
						cpp = { "clang-format" },
					},
					format_on_save = {
						timeout_ms = 500,
						lsp_fallback = true, -- Use LSP if no formatter is found
					},
				})

				-- Keymap for manual formatting
				vim.keymap.set({ "n", "v" }, "<leader>lf", function()
					require("conform").format({ async = true, lsp_fallback = true })
				end, { desc = "Format Buffer" })
			end,
		},
		{
			"nvim-tree/nvim-web-devicons",
			config = function()
				require("nvim-web-devicons").setup({ default = true })
			end,
		},
		{
			"nvim-lualine/lualine.nvim",
			dependencies = { "nvim-tree/nvim-web-devicons" },
			config = function()
				require("lualine").setup({
					options = {
						theme = "auto",
						section_separators = "",
						component_separators = "|",
						globalstatus = true, -- Enables top bar behavior
					},
				})
			end,
		}
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "catppuccin" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})


vim.g.mapleader = " " -- Sets leader to Space

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.git_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<tab>', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>fa', builtin.find_files, { desc = 'Show all files' })
vim.keymap.set('n', '<leader>fc', builtin.git_commits, { desc = 'Show commits' })
vim.keymap.set('n', '<leader>fs', builtin.git_stash, { desc = 'Show stashes' })
vim.keymap.set('n', '<leader>fo', builtin.lsp_document_symbols, { desc = 'Show Symbols' })


-- Split the window to the left
vim.keymap.set("n", "<leader>bs", ":vsplit<CR>", { noremap = true, silent = true, desc = "Split Left" })

-- Navigate between splits
vim.keymap.set("n", "<leader>bh", "<C-w>h", { noremap = true, silent = true, desc = "Move Left" })
vim.keymap.set("n", "<leader>bl", "<C-w>l", { noremap = true, silent = true, desc = "Move Right" })

-- Close the split
vim.keymap.set("n", "<leader>bq", ":close<CR>", { noremap = true, silent = true, desc = "Close Split" })


vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local path = vim.fn.argv(0)               -- Get the first argument (the directory)
		if vim.fn.isdirectory(path) == 1 then
			vim.cmd("enew")                   -- Prevent opening a directory buffer
			require("telescope.builtin").git_files({ cwd = path }) -- Open Telescope in the directory
		end
	end
})

local lsp_active = true -- Track LSP state

function ToggleLSP()
	if lsp_active then
		-- Stop all active LSP clients
		for _, client in pairs(vim.lsp.get_active_clients()) do
			vim.lsp.stop_client(client.id)
		end
		vim.notify("LSP Disabled", vim.log.levels.WARN)
	else
		-- Restart the buffer's LSP client
		vim.cmd("edit") -- Reloads the file, triggering LSP attach
		vim.notify("LSP Enabled", vim.log.levels.INFO)
	end
	lsp_active = not lsp_active
end

-- Keybinding: Toggle LSP with <leader>l
vim.keymap.set("n", "<leader>lt", ToggleLSP, { desc = "Toggle LSP" })
vim.keymap.set("n", "<leader>qq", function()
	local current_buf = vim.api.nvim_get_current_buf()
	vim.cmd("bprevious")        -- Switch to previous buffer
	vim.cmd("bdelete " .. current_buf) -- Delete current buffer
end, { noremap = true, silent = true, desc = "Close Current Buffer" })
-- In init.lua (Lua)
vim.api.nvim_create_user_command('BufOnly', 'bufdo bdelete|edit #|bdelete #', {})
vim.keymap.set('n', '<leader>qo', ':BufOnly<CR>', { noremap = true, silent = true })

vim.opt.termguicolors = false
vim.opt.background = "dark" -- Or "light", depending on your terminal theme

vim.opt.number = true
local numbertoggle = vim.api.nvim_create_augroup("numbertoggle", {})
vim.api.nvim_create_autocmd(
	{ "BufEnter", "FocusGained", "InsertLeave", "WinEnter", "CmdlineLeave" },
	{
		group = numbertoggle,
		callback = function()
			if vim.opt.number and vim.api.nvim_get_mode() ~= "i" then
				vim.opt.relativenumber = true
			end
		end,
	}
)

vim.api.nvim_create_autocmd(
	{ "BufLeave", "FocusLost", "InsertEnter", "WinLeave", "CmdlineEnter" },
	{
		group = numbertoggle,
		callback = function()
			if vim.opt.number then
				vim.opt.relativenumber = false
				vim.cmd("redraw")
			end
		end,
	}
)


local function macos_appearance()
	local handle = io.popen([[defaults read -g AppleInterfaceStyle 2>/dev/null]])
	local result = handle:read("*a")
	handle:close()
	return result:match("Dark") and "mocha" or "latte" -- 'mocha' (dark) and 'latte' (light)
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.cmd.colorscheme("catppuccin-" .. macos_appearance()) -- Apply detected theme
	end,
})

vim.api.nvim_create_autocmd("FocusGained", {
	callback = function()
		vim.cmd.colorscheme("catppuccin-" .. macos_appearance())
	end,
})


local cmp = require("cmp")
cmp.setup({
	mapping = {
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	},
})
