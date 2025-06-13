vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = false

-- [[ Setting options ]]
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.swapfile = false -- Disable swapfiles to avoid conflicts
vim.o.signcolumn = 'yes'
vim.o.confirm = false

vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.expandtab = true

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false

vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = false
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 8
vim.o.termguicolors = true
vim.o.completeopt = 'menuone,noselect'

vim.schedule(function()
  -- vim.o.clipboard = 'unnamedplus'
end)

-- [[ Basic Keymaps ]]
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<C-h>', '<cmd>nohlsearch<CR>', { desc = 'Clear Search Highlight' })
vim.keymap.set('v', '<C-h>', '<cmd>nohlsearch<CR>', { desc = 'Clear Search Highlight' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })

vim.keymap.set('n', '<leader>q', function()
  local winnr = vim.fn.winnr '$'
  local has_loclist = false
  for i = 1, winnr do
    if vim.fn.getwinvar(i, '&filetype') == 'qf' then
      has_loclist = true
      break
    end
  end
  if has_loclist then
    vim.cmd 'lclose'
  else
    vim.diagnostic.setloclist()
  end
end, { desc = 'Toggle diagnostics list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file' })

-- Handle <C-e> for escape while avoiding conflicts with completion menu
local function handle_ce_key_for_esc()
  if package.loaded['blink.cmp'] and require('blink.cmp').is_visible() then
    require('blink.cmp').close_menu()
    return ''
  end
  return vim.api.nvim_replace_termcodes('<Esc>', true, true, true)
end
vim.keymap.set({ 'n', 'v', 'x', 'c', 't' }, '<C-e>', handle_ce_key_for_esc, { expr = true, desc = 'Escape / Close Completion' })
vim.keymap.set('i', '<C-e>', handle_ce_key_for_esc, { expr = true, desc = 'Escape / Close Completion' })

vim.keymap.set('n', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
vim.keymap.set('v', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })

vim.keymap.set('n', '<up>', '<nop>')
vim.keymap.set('n', '<down>', '<nop>')
vim.keymap.set('i', '<up>', '<nop>')
vim.keymap.set('i', '<down>', '<nop>')
vim.keymap.set('i', '<left>', '<nop>')
vim.keymap.set('i', '<right>', '<nop>')

vim.keymap.set('n', '<left>', ':bp<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<right>', ':bn<CR>', { desc = 'Next buffer' })

vim.keymap.set('n', '<leader><leader>', '<C-^>', { desc = 'Toggle last buffer' })
vim.keymap.set('n', '<leader>m', 'ct_', { desc = 'Change To Underscore/Dash' })

-- Colemak mappings
local colemap = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- HNEI arrows
colemap('', 'n', 'gj', 'Colemak: Down (visual lines)')
colemap('', 'e', 'gk', 'Colemak: Up (visual lines)')
colemap('', 'i', 'l', 'Colemak: Right')
colemap('', 'h', 'h', 'Colemak: Left')

-- Search navigation
colemap('n', 'k', 'nzz', 'Colemak: Next search result (centered)')
colemap('n', 'K', 'Nzz', 'Colemak: Previous search result (centered)')

-- Insert mode
colemap('', 's', 'i', 'Colemak: Insert mode')
colemap('', 'S', 'I', 'Colemak: Insert at BOL')

-- Line navigation
colemap('', 'l', '^', 'Colemak: Beginning of line')
colemap('', 'L', '$', 'Colemak: End of line')
vim.keymap.set('', '<C-l>', 'J', { noremap = true, desc = 'Colemak: Join lines' })

-- End of word
colemap('', 'j', 'e', 'Colemak: End of word')
colemap('', 'J', 'E', 'Colemak: End of WORD')

-- Additional line navigation shortcuts
vim.keymap.set('n', 'H', '^', { desc = 'Beginning of line' })
vim.keymap.set('n', 'I', '$', { desc = 'End of line' })

-- Window focus with leader prefix
vim.keymap.set('n', '<leader>ch', '<C-w>h', { desc = 'Colemak: Focus left pane' })
vim.keymap.set('n', '<leader>ci', '<C-w>l', { desc = 'Colemak: Focus right pane' })
vim.keymap.set('n', '<leader>cn', '<C-w>j', { desc = 'Colemak: Focus down pane' })
vim.keymap.set('n', '<leader>ce', '<C-w>k', { desc = 'Colemak: Focus up pane' })

-- Move windows with leader prefix
vim.keymap.set('n', '<leader>cH', '<C-w>H', { desc = 'Colemak: Move window left' })
vim.keymap.set('n', '<leader>cI', '<C-w>L', { desc = 'Colemak: Move window right' })
vim.keymap.set('n', '<leader>cN', '<C-w>J', { desc = 'Colemak: Move window down' })
vim.keymap.set('n', '<leader>cE', '<C-w>K', { desc = 'Colemak: Move window up' })

-- Additional window management from old config
vim.keymap.set('n', '<C-i>', '<C-PageDown>', { desc = 'Next tab' })
vim.keymap.set('', '<C-w>k', '<C-w>n', { desc = 'New window with k' })
vim.keymap.set('', '<C-w>i', '<C-w>l', { desc = 'Focus right window' })
vim.keymap.set('', '<C-w>n', '<C-w>j', { desc = 'Focus down window' })
vim.keymap.set('', '<C-w>e', '<C-w>k', { desc = 'Focus up window' })
vim.keymap.set('', '<C-w>N', '<C-w>J', { desc = 'Move window down' })
vim.keymap.set('', '<C-w>E', '<C-w>K', { desc = 'Move window up' })
vim.keymap.set('', '<C-w>I', '<C-w>L', { desc = 'Move window right' })

-- Jump and changelist navigation
vim.keymap.set('n', 'gH', 'g;', { desc = 'Colemak: Previous in changelist' })
vim.keymap.set('n', 'gI', 'g,', { desc = 'Colemak: Next in changelist' })
vim.keymap.set('n', 'gh', '<C-o>', { desc = 'Colemak: Older cursor position' })
vim.keymap.set('n', 'gi', '<C-i>', { desc = 'Colemak: Newer cursor position' })

-- Scroll commands
vim.keymap.set('n', 'zn', '<C-y>', { desc = 'Scroll up' })
vim.keymap.set('n', 'ze', '<C-e>', { desc = 'Scroll down' })

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

_G.Kickstart = {}
Kickstart.diagnostic_config = function(extra_opts)
  local signs = vim.g.have_nerd_font
      and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      }
    or {
      text = {
        [vim.diagnostic.severity.ERROR] = 'E',
        [vim.diagnostic.severity.WARN] = 'W',
        [vim.diagnostic.severity.INFO] = 'I',
        [vim.diagnostic.severity.HINT] = 'H',
      },
    }
  return vim.tbl_deep_extend('force', {
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = signs,
    virtual_text = false,
  }, extra_opts or {})
end

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({
  'lambdalisue/suda.vim',
  'tpope/vim-sleuth', -- Keep only this one for auto-indent

  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = { add = { text = '+' }, change = { text = '~' }, delete = { text = '_' }, topdelete = { text = '‾' }, changedelete = { text = '~' } },
      on_attach = function(bufnr)
        vim.keymap.set('n', '[c', require('gitsigns').prev_hunk, { buffer = bufnr, desc = 'Go to Previous Hunk' })
        vim.keymap.set('n', ']c', require('gitsigns').next_hunk, { buffer = bufnr, desc = 'Go to Next Hunk' })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
      end,
    },
  },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy', -- Defer loading
    opts = {
      delay = 0,
    },
  },
  {
    'navarasu/onedark.nvim',
    priority = 1000,
    lazy = false, -- Load immediately but optimize
    config = function()
      -- Minimal setup to reduce startup time
      require('onedark').setup {
        style = 'cool',
        code_style = {
          comments = 'none', -- Reduce highlighting complexity
          keywords = 'none',
          functions = 'none',
          strings = 'none',
          variables = 'none',
        },
        diagnostics = {
          darker = false, -- Simplify diagnostics
          undercurl = false,
          background = false,
        },
      }
      vim.cmd.colorscheme 'onedark'
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = vim.g.have_nerd_font,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
  {
    'folke/todo-comments.nvim',
    event = 'BufReadPost', -- Load after buffer is read
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  { 'numToStr/Comment.nvim', opts = {} },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'windwp/nvim-ts-autotag',
    ft = { 'html', 'xml', 'javascriptreact', 'typescriptreact', 'svelte', 'vue' },
    config = function()
      require('nvim-ts-autotag').setup()
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope', -- Only load when using telescope
    keys = {
      { '<leader>?', '<cmd>Telescope oldfiles<cr>', desc = '[?] Find recently opened files' },
      { '<leader>f', '<cmd>Telescope buffers<cr>', desc = '[F]ind existing [B]uffers' },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
        end,
        desc = '[/] Fuzzily search in current buffer',
      },
      { '<leader>gf', '<cmd>Telescope git_files<cr>', desc = 'Search [G]it [F]iles' },
      { '<leader>sf', '<cmd>Telescope find_files<cr>', desc = '[S]earch [F]iles' },
      { '<leader>sh', '<cmd>Telescope help_tags<cr>', desc = '[S]earch [H]elp' },
      { '<leader>sk', '<cmd>Telescope keymaps<cr>', desc = '[S]earch [K]eymaps' },
      { '<leader>sw', '<cmd>Telescope grep_string<cr>', desc = '[S]earch current [W]ord' },
      { '<leader>sg', '<cmd>Telescope live_grep<cr>', desc = '[S]earch by [G]rep' },
      { '<leader>sd', '<cmd>Telescope diagnostics<cr>', desc = '[S]earch [D]iagnostics' },
      { '<leader>sr', '<cmd>Telescope resume<cr>', desc = '[S]earch [R]esume' },
      {
        '<leader>sn',
        function()
          require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
        end,
        desc = '[S]earch [N]eovim files',
      },
    },
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = { ['ui-select'] = { require('telescope.themes').get_dropdown() } },
        defaults = {
          mappings = { i = { ['<C-u>'] = false, ['<C-d>'] = false } },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
    end,
  },

  { 'folke/lazydev.nvim', ft = 'lua', opts = { library = { { path = '${3rd}/luv/library', words = { 'vim%.uv' } } } } },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' }, -- Lazy load LSP
    dependencies = {
      { 'mason-org/mason.nvim', cmd = 'Mason', opts = {} }, -- Only load when needed
      { 'mason-org/mason-lspconfig.nvim', lazy = true },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim', lazy = true },
      { 'j-hui/fidget.nvim', event = 'LspAttach', opts = {} }, -- Only when LSP attaches
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach-custom', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc, noremap = true, silent = true })
          end

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'v' })
          map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('gk', vim.lsp.buf.hover, 'Hover Documentation')
          map('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration (header)')
          map('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
          map('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          map('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')

          -- Create Format command and keymap
          vim.api.nvim_buf_create_user_command(event.buf, 'Format', function(_)
            vim.lsp.buf.format()
          end, { desc = 'Format current buffer with LSP' })

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local client_supports_method = function(cl, method, bufnr_arg)
            if vim.fn.has 'nvim-0.11' == 1 then
              return cl:supports_method(method, bufnr_arg)
            else
              return cl.supports_method(method, { bufnr = bufnr_arg })
            end
          end
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config(Kickstart.diagnostic_config())

      local capabilities = require('blink.cmp').get_lsp_capabilities()
      -- Fix position encoding conflicts
      capabilities.general = capabilities.general or {}
      capabilities.general.positionEncodings = { 'utf-16' }

      local servers = {
        clangd = {},
        gopls = {},
        pyright = {},
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              -- Enable persistent cache (most important for speed)
              cachePriming = {
                enable = true,
                numThreads = 0, -- Use all available threads
              },

              -- Improve indexing performance
              cargo = {
                buildScripts = {
                  enable = true,
                },
                features = 'all', -- Index all features
                loadOutDirsFromCheck = true,
              },

              -- Optimize check configuration
              check = {
                command = 'clippy', -- Use clippy for better diagnostics
                features = 'all',
              },

              -- Improve completion performance
              completion = {
                limit = 25, -- Limit completion items for faster response
                postfix = {
                  enable = false, -- Disable postfix completions for speed
                },
              },

              -- Optimize proc macro handling
              procMacro = {
                enable = true,
                ignored = {
                  -- Add slow proc macros here if needed
                  -- Example: leptos_macro = { "component", "server" },
                },
              },

              -- Reduce memory usage and improve performance
              files = {
                excludeDirs = {
                  '.direnv',
                  '.git',
                  '.github',
                  '.gitlab',
                  'node_modules',
                  'target',
                  '.vscode',
                },
              },

              -- Optimize lens configuration
              lens = {
                enable = true,
                references = {
                  adt = { enable = false },
                  enumVariant = { enable = false },
                  method = { enable = false },
                  trait = { enable = false },
                },
                implementations = { enable = false },
              },

              -- Improve hover performance
              hover = {
                actions = {
                  references = { enable = false },
                  implementations = { enable = false },
                },
              },

              -- Optimize inlay hints
              inlayHints = {
                bindingModeHints = { enable = false },
                chainingHints = { enable = true },
                closingBraceHints = { enable = false },
                closureReturnTypeHints = { enable = 'never' },
                lifetimeElisionHints = { enable = 'never' },
                parameterHints = { enable = false },
                reborrowHints = { enable = 'never' },
                renderColons = false,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              completion = { callSnippet = 'Replace' },
            },
          },
        },
        ruff = {
          cmd = { 'ruff', 'server', '--preview' },
        },
        golangci_lint_ls = {},
      }

      -- Only install tools you actually use
      local ensure_installed_tools = {
        'stylua', -- Only essential tools
        'ruff',
      }
      require('mason-tool-installer').setup { ensure_installed = ensure_installed_tools }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- Don't auto-install, install manually as needed
        automatic_installation = false, -- Disable automatic installation
        handlers = {
          function(server_name)
            local server_config = servers[server_name] or {}
            server_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_config.capabilities or {})

            if server_name == 'ruff' and not server_config.cmd then
              server_config.cmd = { 'ruff', 'server', '--preview' }
            end

            require('lspconfig')[server_name].setup(server_config)
          end,
        },
      }
    end,
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>l',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[L]SP Format Buffer (Conform)',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return { timeout_ms = 1000, lsp_format = 'fallback' }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format' },
      },
    },
  },
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0) and nil or 'make install_jsregexp',
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              -- Lazy load snippets only when needed
              vim.defer_fn(function()
                require('luasnip.loaders.from_vscode').lazy_load()
              end, 100)
            end,
          },
        },
        config = function()
          -- Minimal LuaSnip setup
          require('luasnip').config.setup {
            update_events = 'TextChanged,TextChangedI', -- Reduce update frequency
            delete_check_events = 'TextChanged', -- Less frequent checking
          }
        end,
      },
      'folke/lazydev.nvim',
    },
    opts = {
      keymap = {
        preset = 'enter',
        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      },
      appearance = { nerd_font_variant = vim.g.have_nerd_font and 'mono' or 'normal' },
      completion = { documentation = { auto_show = false } },
      sources = {
        default = { 'lsp', 'path', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = {
        preset = 'luasnip',
      },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile' }, -- Lazy load
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        event = 'VeryLazy', -- Even lazier loading
      },
    },
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'c',
        'cpp',
        'go',
        'lua',
        'python',
        'rust',
        'vim',
        'vimdoc', -- Only essential parsers
      },
      auto_install = false, -- Don't auto-install parsers
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false, -- Disable for performance
      },
      indent = { enable = true, disable = { 'ruby', 'python' } },
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
          lookahead = true,
          keymaps = {
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
          set_jumps = true,
          goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
          goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
          goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
          goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
        },
        swap = {
          enable = true,
          swap_next = { ['<leader>a'] = '@parameter.inner' },
          swap_previous = { ['<leader>A'] = '@parameter.inner' },
        },
      },
      autotag = { enable = true },
    },
  },

  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = { jump_prev = '[[', jump_next = ']]', accept = '<CR>', refresh = 'gr', open = '<M-CR>' },
          layout = { position = 'bottom', ratio = 0.4 },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = { accept = '<M-l>', accept_word = false, accept_line = false, next = '<M-]>', prev = '<M-[>', dismiss = '<C-]>' },
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
          ['.'] = false,
        },
        copilot_node_command = 'node',
        server_opts_overrides = {},
      }
    end,
  },
}, {})

-- vim: ts=2 sts=2 sw=2 et
