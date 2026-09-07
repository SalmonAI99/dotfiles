-- sync nvim and system keyboard
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)



-- line numbers
vim.o.number = true


-- leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- cache module setup
vim.loader.enable()


-- key mappings
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
      callback = function() vim.hl.on_yank() end
    })
-- helper macro
local function gh(repo) return 'https://github.com/' .. repo end


-- colorscheme
vim.pack.add { gh 'folke/tokyonight.nvim' }
---@diagnostic disable-next-line: missing-fields
require('tokyonight').setup {
    styles = {
      comments = { italic = false }, -- Disable italics in comments
    },
    transparent = true,
 }
 vim.cmd.colorscheme("tokyonight")


 -- tree-sitter
 
vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter' } }

require('nvim-treesitter').install {'lua', 'rust'}

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "vim", "vimdoc", "query", "rust" },
  callback = function()
    vim.treesitter.start()
  end,
})


-- lsp
vim.pack.add{
  { src = gh 'neovim/nvim-lspconfig' },
}

vim.lsp.enable{'lua_ls', 'rust_analyzer'}

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)


-- vim diagnostic
vim.diagnostic.enable(false)

-- autocomplete
vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
  require('blink.cmp').setup {
    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See `:help blink-cmp-config-keymap` for defining your own keymap
      preset = 'default',
    },
    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },
    completion = {
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },
    sources = {
      default = { 'lsp', 'path'},
    },
    fuzzy = { implementation = "prefer_rust_with_warning"},
    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  }
  
-- pairs
vim.pack.add {
  { src = gh 'echasnovski/mini.pairs' },
  { src = gh 'echasnovski/mini.move' },
}

require('mini.pairs').setup()
require('mini.move').setup()


-- telescope
vim.pack.add {
	{
		src = gh 'nvim-lua/plenary.nvim'

	},
	{
		src = gh 'nvim-telescope/telescope.nvim', 
		dependencies = {
			'nvim-lua/plenary.nvim',
			-- optional but recommended
			{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		}
	}
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })




-- markdown preview
vim.pack.add {
  {
    src = gh "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", {
      buffer = true,
      desc = "Markdown Preview",
    })
  end,
})


-- obsidian
vim.pack.add({
  {
    src = gh "obsidian-nvim/obsidian.nvim",
    version = vim.version.range("*"),
  },
})

require("obsidian").setup({
  legacy_commands = false,
  workspaces = {
    {
      name = "work",
      path = "~/Documents/obsidian-vault/",
    },
  },
  -- Specify how to handle attachments.
  attachments = {
    -- The default folder to place images in via `:ObsidianPasteImg`.
    -- If this is a relative path it will be interpreted as relative to the vault root.
    -- You can always override this per image by passing a full path to the command instead of just a filename.
    folder = "assets/imgs",  -- This is the default

    ---@return string
    img_name_func = function()
      -- Prefix image names with timestamp.
      return string.format("%s-", os.time())
    end,
    img_text_func = function(client, path)
	    path = client:vault_relative_path(path) or path
	    return string.format("![%s](%s)", path.name, path)
    end,

  },
  -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
  -- file it will be ignored but you can customize this behavior here.
  ---@param img string
  -- follow_img_func = function(img)
  --   -- vim.fn.jobstart { "qlmanage", "-p", img }  -- Mac OS quick look preview
  --   vim.fn.jobstart({"xdg-open", img})  -- linux
  --   -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
  -- end,
})
vim.opt.conceallevel = 2
-- key maps
vim.api.nvim_create_autocmd("FileType", {
	pattern = 'markdown',
	callback = function ()
		vim.keymap.set("n", "<leader>p", "<cmd>Obsidian paste_img<CR>", { buffer = true, desc = "Obsidian Paste Image" })
	end
})
-- obsidian-cmp
-- NOTE: you don't need this is you are on neovim 0.13 (nightly)
-- HACK: to trigger on every ASCII char
local chars = {}
for i = 32, 126 do
  table.insert(chars, string.char(i))
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local buf = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.name == "obsidian-ls" then
      client.server_capabilities.completionProvider.triggerCharacters = chars -- HACK:
      vim.bo[buf].completeopt = "menuone,noselect,fuzzy,nosort" -- noselect to make sure no accidentally accept and create new notes, others are not strictly necessary, adjust to your taste, see `:h completeopt'
      vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
    end
  end,
})
-- image in nvim
vim.pack.add {
	{
		src = gh '3rd/image.nvim',
		build = false,
		opts = {
			processor = 'magick_cli',
		}
	}
}



require("image").setup({
  backend = "kitty", -- or "ueberzug" or "sixel"
  processor = "magick_cli", -- or "magick_rock"
  integrations = {
    markdown = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
      only_render_image_at_cursor_mode = "popup", -- or "inline"
      floating_windows = false, -- if true, images will be rendered in floating markdown windows
      filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
    },
    asciidoc = {
      enabled = true,
      clear_in_insert_mode = false,
      download_remote_images = true,
      only_render_image_at_cursor = false,
      only_render_image_at_cursor_mode = "popup",
      floating_windows = false,
      filetypes = { "asciidoc", "adoc" },
    },
    neorg = {
      enabled = true,
      filetypes = { "norg" },
    },
    rst = {
      enabled = true,
    },
    typst = {
      enabled = true,
      filetypes = { "typst" },
    },
    html = {
      enabled = false,
    },
    css = {
      enabled = false,
    },
  },
  max_width = nil,
  max_height = nil,
  max_width_window_percentage = nil,
  max_height_window_percentage = 50,
  scale_factor = 1.0,
  kitty_direct_chunk_size = 4096, -- chunk size for direct Kitty graphics protocol transmission
  window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
  window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "snacks_notif", "scrollview", "scrollview_sign" },
  editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
  tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
  hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }, -- render image files as images when opened
})

-- oil
vim.pack.add {
	gh 'stevearc/oil.nvim'
}
require("oil").setup()



