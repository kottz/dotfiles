-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  'lambdalisue/suda.vim',

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} -- this is equalent to setup({}) function
  },
  'windwp/nvim-ts-autotag',
  {
    'zbirenbaum/copilot.lua',
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require('copilot').setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = 'node', -- Node.js version must be > 16.x
        server_opts_overrides = {},
      })
    end,
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',          opts = {} },
  {
    -- Adds git releated signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '[c', require('gitsigns').prev_hunk, { buffer = bufnr, desc = 'Go to Previous Hunk' })
        vim.keymap.set('n', ']c', require('gitsigns').next_hunk, { buffer = bufnr, desc = 'Go to Next Hunk' })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
      end,
    },
  },

  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'onedark'
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  --  {
  --    -- Add indentation guides even on blank lines
  --    'lukas-reineke/indent-blankline.nvim',
  --    -- Enable `lukas-reineke/indent-blankline.nvim`
  --    -- See `:help indent_blankline.txt`
  --    main = 'ibl',
  --    opts = {
  --      --char = '┊',
  --      --show_trailing_blankline_indent = false,
  --    },
  --  },
  --
  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim',         opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },
  {
    "robitx/gp.nvim",
    config = function()
      local openai_api_key_path = os.getenv("HOME") .. "/.config/nvim/openai_api_key"
      require("gp").setup({
        openai_api_key = { "cat", openai_api_key_path },
        agents = {
          {
            name = "ChatGPT4o",
            chat = true,
            command = true,
            -- string with model name or table with model name and parameters
            model = { model = "gpt-4o", temperature = 1.1, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = "You are a general AI assistant.\n\n"
                .. "The user provided the additional info about how they would like you to respond:\n\n"
                .. "- If you're unsure don't guess and say you don't know instead.\n"
                .. "- Ask question if you need clarification to provide better answer.\n"
                .. "- Think deeply and carefully from first principles step by step.\n"
                .. "- Zoom out first to see the big picture and then zoom in to details.\n"
                .. "- Use Socratic method to improve your thinking and coding skills.\n"
                .. "- Don't elide any code from your output if the answer requires coding.\n"
                .. "- Take a deep breath; You've got this!\n",
          },
          { name = "ChatGPT3-5" },
          { name = "CodeGPT4" },
          { name = "CodeGPT3-5" },
        },
        chat_topic_gen_model = "gpt-4o",
      })

      -- or setup with your own config (see Install > Configuration in Readme)
      -- require("gp").setup(config)

      -- shortcuts might be setup here (see Usage > Shortcuts in Readme)
    end,
  },
  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below automatically adds your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- relative linenumbers
vim.wo.relativenumber = true

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
--vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
--vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Configure Comment.nvim
require('Comment').setup()


-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>f', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,
  autotag = { enable = true },

  highlight = { enable = true },
  indent = { enable = true, disable = { 'python' } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end


  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('gk', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
  nmap('<leader>l', ':Format<CR>', 'Format Code')
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      elseif cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}
--cmp.setup {
--  snippet = {
--    expand = function(args)
--      luasnip.lsp_expand(args.body)
--    end,
--  },
--  mapping = cmp.mapping.preset.insert {
--    ['<C-n>'] = cmp.mapping.select_next_item(),
--    ['<C-p>'] = cmp.mapping.select_prev_item(),
--    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
--    ['<C-f>'] = cmp.mapping.scroll_docs(4),
--    ['<C-Space>'] = cmp.mapping.complete {},
--    ['<CR>'] = cmp.mapping.confirm {
--      behavior = cmp.ConfirmBehavior.Replace,
--      select = true,
--    },
--    ['<Tab>'] = cmp.mapping(function(fallback)
--      if cmp.visible() then
--        --cmp.select_next_item()
--        luasnip.expand_or_jump()
--      elseif luasnip.expand_or_locally_jumpable() then
--        luasnip.expand_or_jump()
--      else
--        fallback()
--      end
--    end, { 'i', 's' }),
--    ['<S-Tab>'] = cmp.mapping(function(fallback)
--      if cmp.visible() then
--        --cmp.select_prev_item()
--        luasnip.jump(-1)
--      elseif luasnip.locally_jumpable(-1) then
--        luasnip.jump(-1)
--      else
--        fallback()
--      end
--    end, { 'i', 's' }),
--  },
--  sources = {
--    { name = 'nvim_lsp' },
--    { name = 'luasnip' },
--  },
--}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et


-- Keyboard bindings old
M = {}
local opts = { noremap = true }
local opts_silent = { noremap = true, silent = true }
local opts_ono = { omap = true, silent = true }
local opts_nno = { nnoremap = true, silent = true }


-- The function is called `t` for `termcodes`.
-- Without it <Esc> is interpreted interpreted literally
local function t(str)
  -- Adjust boolean arguments as needed
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

keymap('n', t('<leader>'), t('<Space>'), opts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
keymap('n', '<C-Space>', '<cmd>WhichKey \\<leader><cr>', opts)
--------------------------------------------------
-- Colemak-Vim Mappings
--hjkl hnei
-- The idea is to use HNEI as arrows – keeping the traditional Vim homerow style – and changing as
-- little else as possible. This means JKL are free to use and NEI need new keys.
-- - k/K is the new n/N.
-- - s/S is the new i/I [--inSert--].
-- - j/J is the new e/E [--Jump-- to EOW].
-- - l/L skip to the beginning and end of lines. Much more intuitive than ^/$.
-- - Ctrl-l joins lines, making l/L the veritable --Line-- key.
-- - r replaces i as the --inneR-- modifier [e.g. --diw-- becomes --drw--].
-----------------------------------------
-- HNEI arrows. Swap 'gn'/'ge' and 'n'/'e'.
--remap n gj
--remap e gk
--remap i l
--remap gn j
--remap ge k

keymap('', 'n', 'gj', opts)
keymap('', 'e', 'gk', opts)
keymap('', 'i', 'l', opts)
keymap('', 'gn', 'j', opts)
keymap('', 'ge', 'k', opts)
-- In(s)ert. The default s/S is synonymous with cl/cc and is not very useful.
--remap s i
--remap S I
keymap('', 's', 'i', opts)
keymap('', 'S', 'I', opts)
-- Repeat search.
--remap k nzz
--remap K Nzz
keymap('', 'k', 'nzz', opts)
keymap('', 'K', 'Nzz', opts)
-- BOL/EOL/Join.
--remap l ^
--remap L $
--remap <C-l> J
keymap('', 'l', '^', opts)
keymap('', 'L', '$', opts)
keymap('', '<C-l>', 'J', opts)
-- _r_ = inneR text objects.
--  onoremap r i
keymap('', 'r', 'i', opts) -- check if this works not sure
-- EOW.
--remap j e
--remap J E
keymap('', 'j', 'e', opts)
keymap('', 'J', 'E', opts)

keymap('', 'N', 'J', opts)
--  keymap('', 'J', 'E', opts)
-----------------------------------------
-- Other Colemak Arrow-Based Mappings
-----------------------------------------
-- Switch tabs with Ctrl.
--  nnoremap <C-i> <C-PageDown>
--  nnoremap <C-h> <C-PageUp>
keymap('n', '<C-i>', '<C-PageDown', opts)
keymap('n', '<C-h>', '<C-PageUp', opts)
-- Switch panes with Shift.
--remap H <C-w>h
--remap I <C-w>l
--remap N <C-w>j
--remap E <C-w>k
--keymap('n', '<C-w>h', '<C-w>h', opts)

keymap('', '<C-w>k', '<C-w>n', opts) -- Open new with k instead of n

keymap('', '<C-w>i', '<C-w>l', opts)
keymap('', '<C-w>n', '<C-w>j', opts)
keymap('', '<C-w>e', '<C-w>k', opts)
-- Moving windows around.
--remap <C-w>N <C-w>J
--remap <C-w>E <C-w>K
--remap <C-w>I <C-w>L
keymap('', '<C-w>N', '<C-w>J', opts)
keymap('', '<C-w>E', '<C-w>K', opts)
keymap('', '<C-w>I', '<C-w>L', opts)
-- High/Low. Mid remains `M` since <C-m> is unfortunately interpreted as <CR>.
--remap <C-e> H
--remap <C-n> L
--keymap('', '<C-e>', 'H', opts)
--keymap('', '<C-n>', 'L', opts)
-- Scroll up/down.
--noremap zn <C-y>
--noremap ze <C-e>
keymap('n', 'zn', '<C-y>', opts)
keymap('n', 'ze', '<C-e>', opts)
-- Back and forth in jump and changelist.
--nnoremap gh <C-o>
--nnoremap gi <C-i>
--nnoremap gH g;
--nnoremap gI g,
--keymap('n', 'gh', '<C-o>', opts)
--keymap('n', 'gi', '<C-i>', opts)
keymap('n', 'gH', 'g;', opts)
keymap('n', 'gI', 'g,', opts)

-- =============================================================================
-- # Keyboard shortcuts
-- =============================================================================


-- Open hotkeys
--map <C-f> :Files<CR>
--nmap <eader>f :Buffers<CR>

-- Quick-save
--nmap <leader>w :w<CR>
keymap('n', '<leader>w', ':w<CR>', opts)






-- ; as :
--nnoremap ; :
keymap('n', ';', ':', opts)
-- Ctrl+j and Ctrl+k as Esc
-- Ctrl-j is a little awkward unfortunately:
-- https://github.com/neovim/neovim/issues/5916
-- So we also map Ctrl+k
--nnoremap <C-n> <Esc>
--inoremap <C-n> <Esc>
--vnoremap <C-n> <Esc>
--snoremap <C-n> <Esc>
--xnoremap <C-n> <Esc>
--cnoremap <C-n> <C-c>
--onoremap <C-n> <Esc>
--lnoremap <C-n> <Esc>
--tnoremap <C-n> <Esc>
--  keymap('n', '<C-n>', t('Esc'), opts)
--  keymap('i', '<C-n>', t('Esc'), opts)
--  keymap('v', '<C-n>', t('Esc'), opts)
--  keymap('c', '<C-n>', t('Esc'), opts)
--  keymap('x', '<C-n>', t('Esc'), opts)
--  keymap('t', '<C-n>', t('Esc'), opts)

--\   local Escape = function()
--\     if vim.fn.pumvisible() then
--\       return '\\<C-e><Esc>'
--\     else
--\       vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nit', true)
--\       return ''
--\     end
--\   end

--nnoremap <C-e> <Esc>
--inoremap <C-e> <Esc>
--vnoremap <C-e> <Esc>
--snoremap <C-e> <Esc>
--xnoremap <C-e> <Esc>
--cnoremap <C-e> <C-c>
--onoremap <C-e> <Esc>
--lnoremap <C-e> <Esc>
--tnoremap <C-e> <Esc>

-- This was really tough to debug. I had to change the nvim-cmp source
-- to get this to work correctly. you can check where <C-e> is bound
-- by using :imap
local function handle_ce_key()
  print("ce key fired")
  if cmp.visible() then
    -- Dismiss the completion panel
    cmp.close()
  end
  print("ce key fired")
  return vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
end
local function ce_key()
  print("WTFFFF")
end

keymap('n', '<C-e>', t('<Esc>'), opts)
--keymap('i', '<C-e>', t('<Esc>'), opts)
keymap('v', '<C-e>', t('<Esc>'), opts)
keymap('c', '<C-e>', t('<Esc>'), opts)
keymap('x', '<C-e>', t('<Esc>'), opts)
keymap('t', '<C-e>', t('<Esc>'), opts)
vim.keymap.set('i', '<C-e>', handle_ce_key, { expr = true, noremap = true })
--kvim.keymap.set({ 'n', 'v' }, '<C-e>', t('<Esc>', { silent = true })
--kkeymap('i', '<C-e>', t('<Esc>'), opts)
--keymap('', '<C-e>', t('<Esc>'), opts)
-- Ctrl+h to stop searching
--vnoremap <C-h> :nohlsearch<cr>
--nnoremap <C-h> :nohlsearch<cr>
keymap('v', '<C-h>', ':nohlsearch<cr>', opts)
keymap('n', '<C-h>', ':nohlsearch<cr>', opts)


--map H ^
--map I $
keymap('n', 'H', '^', opts)
keymap('n', 'I', '$', opts)


--noremap <leader>p :read !xsel --clipboard --output<cr>
--noremap <leader>c :w !xsel -ib<cr><cr>
--keymap('n', '<leader>p', ':read !wl-paste', opts_silent)
--keymap('n', '<leader>c', ':read !wl-copy', opts)
--keymap('n', '<leader>c', ':let @*=@<CR>:!echo -n *@ | wl-copy<CR>', opts)
keymap('n', '<leader>y', '"+y', opts)
keymap('n', '<leader>p', '+p', opts)


-- Open new file adjacent to current file
--nnoremap <leader>e :e <C-R>=expand("%:p:h") . "/" <CR>
keymap('n', '<leader>e', ':vsplit <C-R>=expand("%:p:h") . "/" <CR>', opts)


-- No arrow keys --- force yourself to use the home row
--nnoremap <up> <nop>
--nnoremap <down> <nop>
--inoremap <up> <nop>
--inoremap <down> <nop>
--inoremap <left> <nop>
--inoremap <right> <nop>
keymap('n', '<up>', '<nop>', opts)
keymap('n', '<down>', '<nop>', opts)
keymap('n', '<up>', '<nop>', opts)
keymap('i', '<down>', '<nop>', opts)
keymap('i', '<left>', '<nop>', opts)
keymap('i', '<right>', '<nop>', opts)

-- Left and right can switch buffers
--nnoremap <left> :bp<CR>
--nnoremap <right> :bn<CR>
keymap('n', '<left>', ':bp<CR>', opts)
keymap('n', '<right>', ':bp<CR>', opts)

-- Add goto def later like this
--nmap <silent> gd <Plug>(coc-definition)
--nmap <silent> gy <Plug>(coc-type-definition)
--nmap <silent> gi <Plug>(coc-implementation)
--nmap <silent> gr <Plug>(coc-references)
--  keymap('n', '<silent> gd', '<nop>', opts_silent)
--  keymap('n', '<silent> gy', '<nop>', opts_silent)
--  keymap('n', '<silent> gi', '<nop>', opts_silent)
--  keymap('n', '<silent> gr', '<nop>', opts_silent)


-- Symbol renaming.
--nmap <leader>rn <Plug>(coc-rename)
keymap('n', '<leader>rn', '<nop>', opts)

-- <leader><leader> toggles between buffers
--nnoremap <leader><leader> <c-^>
keymap('n', '<leader><leader>', t('<C-^>'), opts)
-- <leader>q shows stats
--nnoremap <leader>q g<c-g>
keymap('n', t('<leader>q'), t('g<c-g>'), opts)


-- Keymap for replacing up to next _ or -
--noremap <leader>m ct_
keymap('n', '<leader>m', 'ct_', opts)

-- Try to fix all of this
--[[
vim.api.nvim_create_user_command('Files', 'call fzf#vim#files(<q-args>', {nargs = 1 })

vim.api.nvim_create_user_command(
    'Upper',
    function(opts)
        print(string.upper(opts.args))
    end,
    { nargs = 1 }
)

function! s:list_cmd()
  let base = fnamemodify(expand('%'), ':h:.:S')
  return base == '.' ? 'fd --type file --follow' : printf('fd --type file --follow | proximity-sort %s', shellescape(expand('%')))
endfunction


local function list_cmd()
  -- Adjust boolean arguments as needed
  vim.api.nvim_fnamemodify(expand('e
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

keymap('n', '<C-p>', 'Upper', opts)

--map <C-f> :Files<CR>
--
keymap('n', '<C-p>', ':Upper<CR>', opts)

--]]
