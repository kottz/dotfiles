vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.mason_lspconfig_automatic_server_setup = false
-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true -- From your old config

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  --vim.o.clipboard = 'unnamedplus' -- Kickstart's default, your old config had this commented
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy '+',
      ['*'] = require('vim.ui.clipboard.osc52').copy '*',
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste '+',
      ['*'] = require('vim.ui.clipboard.osc52').paste '*',
    },
  }
  if vim.env.TMUX ~= nil then
    local copy = { 'tmux', 'load-buffer', '-w', '-' }
    local paste = { 'bash', '-c', 'tmux refresh-client -l && sleep 0.05 && tmux save-buffer -' }
    vim.g.clipboard = {
      name = 'tmux',
      copy = {
        ['+'] = copy,
        ['*'] = copy,
      },
      paste = {
        ['+'] = paste,
        ['*'] = paste,
      },
      cache_enabled = 0,
    }
  end
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true
vim.o.swapfile = false -- From your old config

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false -- From your old config

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
-- vim.o.list = true -- Kickstart default
vim.o.list = false -- From your old config
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
-- vim.o.scrolloff = 10 -- Kickstart default
vim.o.scrolloff = 8 -- From your old config

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
-- vim.o.confirm = true -- Kickstart default
vim.o.confirm = false -- From your old config

vim.o.termguicolors = true -- From your old config

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier (Kickstart defaults)
-- These will be partially overridden by your Colemak C-w bindings below if Colemak is active
-- but kept for non-Colemak users or if you remove Colemak bindings later.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Custom Keymaps from Old Config ]]

-- Helper function for <C-e> escape/close completion
local function handle_ce_key_for_esc()
  if package.loaded['blink.cmp'] and require('blink.cmp').is_visible() then
    require('blink.cmp').close_menu()
    return ''
  end
  return vim.api.nvim_replace_termcodes('<Esc>', true, true, true)
end

-- Helper function for Colemak mappings
local colemap = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

-- Clear search highlight with <C-h>
vim.keymap.set('n', '<C-h>', '<cmd>nohlsearch<CR>', { desc = 'Clear Search Highlight' })
vim.keymap.set('v', '<C-h>', '<cmd>nohlsearch<CR>', { desc = 'Clear Search Highlight' })

-- Diagnostic keymaps (from old config)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })

-- Toggle diagnostic list (from old config, overrides Kickstart's <leader>q if it existed)
-- Kickstart maps <leader>q for diagnostics in LspAttach for LSP-specific diagnostics quickfix.
-- This one is more general.
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
    vim.diagnostic.setloclist() -- This uses the location list for diagnostics
  end
end, { desc = 'Toggle diagnostics list' })

-- Save file
vim.keymap.set('n', '<leader>ww', ':w<CR>', { desc = 'Save file' })

-- <C-e> for escape / close completion menu
vim.keymap.set({ 'n', 'v', 'x', 'c', 't' }, '<C-e>', handle_ce_key_for_esc, { expr = true, desc = 'Escape / Close Completion' })
vim.keymap.set('i', '<C-e>', handle_ce_key_for_esc, { expr = true, desc = 'Escape / Close Completion' })

-- System clipboard operations
vim.keymap.set('n', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
vim.keymap.set('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
vim.keymap.set('v', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })

-- Arrow key handling (from old config)
vim.keymap.set('n', '<up>', '<nop>')
vim.keymap.set('n', '<down>', '<nop>')
vim.keymap.set('i', '<up>', '<nop>')
vim.keymap.set('i', '<down>', '<nop>')
vim.keymap.set('i', '<left>', '<nop>')
vim.keymap.set('i', '<right>', '<nop>')

-- Buffer navigation with arrow keys in normal mode
vim.keymap.set('n', '<left>', ':bp<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<right>', ':bn<CR>', { desc = 'Next buffer' })

-- Toggle last buffer (Kickstart's <leader><leader> is for Telescope buffers, this overrides it)
vim.keymap.set('n', '<leader><leader>', '<C-^>', { desc = 'Toggle last buffer' })

-- Change to underscore/dash
vim.keymap.set('n', '<leader>m', 'ct_', { desc = 'Change To Underscore/Dash' })

-- Colemak mappings
colemap('', 'n', 'gj', 'Colemak: Down (visual lines)')
colemap('', 'e', 'gk', 'Colemak: Up (visual lines)')
colemap('', 'i', 'l', 'Colemak: Right')
colemap('', 'h', 'h', 'Colemak: Left')

colemap('n', 'k', 'nzz', 'Colemak: Next search result (centered)')
colemap('n', 'K', 'Nzz', 'Colemak: Previous search result (centered)')

colemap('', 's', 'i', 'Colemak: Insert mode')
colemap('', 'S', 'I', 'Colemak: Insert at BOL')

colemap('', 'l', '^', 'Colemak: Beginning of line')
colemap('', 'L', '$', 'Colemak: End of line')
vim.keymap.set('', '<C-l>', 'J', { noremap = true, desc = 'Colemak: Join lines' }) -- Note: This is Ctrl + Colemak 'l'

colemap('', 'j', 'e', 'Colemak: End of word')
colemap('', 'J', 'E', 'Colemak: End of WORD')

vim.keymap.set('n', 'H', '^', { desc = 'Beginning of line (Colemak H)' })
vim.keymap.set('n', 'I', '$', { desc = 'End of line (Colemak I)' })

vim.keymap.set('n', '<leader>ch', '<C-w>h', { desc = 'Colemak: Focus left pane' })
vim.keymap.set('n', '<leader>ci', '<C-w>l', { desc = 'Colemak: Focus right pane' })
vim.keymap.set('n', '<leader>cn', '<C-w>j', { desc = 'Colemak: Focus down pane' })
vim.keymap.set('n', '<leader>ce', '<C-w>k', { desc = 'Colemak: Focus up pane' })

vim.keymap.set('n', '<leader>cH', '<C-w>H', { desc = 'Colemak: Move window left' })
vim.keymap.set('n', '<leader>cI', '<C-w>L', { desc = 'Colemak: Move window right' })
vim.keymap.set('n', '<leader>cN', '<C-w>J', { desc = 'Colemak: Move window down' })
vim.keymap.set('n', '<leader>cE', '<C-w>K', { desc = 'Colemak: Move window up' })

-- Additional window management adapting <C-w> for Colemak keys
-- These assume your OS keyboard is set to Colemak.
-- Kickstart's <C-h/j/k/l> for window navigation are QWERTY based.
-- Your Colemak-specific <C-w> bindings:
vim.keymap.set('', '<C-w>i', '<C-w>l', { desc = 'Focus right window (Colemak <C-w>i)' })
vim.keymap.set('', '<C-w>n', '<C-w>j', { desc = 'Focus down window (Colemak <C-w>n)' })
vim.keymap.set('', '<C-w>e', '<C-w>k', { desc = 'Focus up window (Colemak <C-w>e)' })
-- The QWERTY <C-w>h is fine as 'h' is the same.

vim.keymap.set('', '<C-w>N', '<C-w>J', { desc = 'Move window down (Colemak <C-w>N)' })
vim.keymap.set('', '<C-w>E', '<C-w>K', { desc = 'Move window up (Colemak <C-w>E)' })
vim.keymap.set('', '<C-w>I', '<C-w>L', { desc = 'Move window right (Colemak <C-w>I)' })
-- The QWERTY <C-w>H is fine.

-- This specific mapping from your old config:
-- <C-w> + (Qwerty 'k' key) -> new horizontal split (Vim's <C-w>n)
vim.keymap.set('', '<C-w>k', '<C-w>n', { desc = 'New window with k (Qwerty <C-w>k -> Vim <C-w>n)' })
-- Note: Kickstart maps <C-k> to <C-w><C-k> for focus. This custom map for <C-w>k is different.

vim.keymap.set('n', '<C-i>', '<C-PageDown>', { desc = 'Next tab (Colemak C-i)' }) -- This is Ctrl + Colemak 'i'

vim.keymap.set('n', 'gH', 'g;', { desc = 'Colemak: Previous in changelist (gH)' })
vim.keymap.set('n', 'gI', 'g,', { desc = 'Colemak: Next in changelist (gI)' })
vim.keymap.set('n', 'gh', '<C-o>', { desc = 'Colemak: Older cursor position (gh)' })
vim.keymap.set('n', 'gi', '<C-i>', { desc = 'Colemak: Newer cursor position (gi)' }) -- Note: Vim's <C-i> for jump forward

vim.keymap.set('n', 'zn', '<C-y>', { desc = 'Scroll up (Colemak zn)' })
vim.keymap.set('n', 'ze', '<C-e>', { desc = 'Scroll down (Colemak ze)' })

-- [[ End of Custom Keymaps from Old Config ]]

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({
  'NMAC427/guess-indent.nvim',
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch (Telescope)' }, -- Kickstart default
        { '<leader>t', group = '[T]oggle' }, -- Kickstart default (for inlay hints)
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Kickstart default
        -- Your custom leader mappings for which-key
        { '<leader>w', group = 'File', desc = 'Save file' },
        { '<leader>y', group = 'Clipboard', desc = 'Yank to system clipboard' },
        { '<leader>p', group = 'Clipboard', desc = 'Paste from system clipboard' },
        { '<leader>m', group = 'Text Object', desc = 'Change To Underscore/Dash' },
        { '<leader>e', group = 'Diagnostics', desc = 'Open floating diagnostic' },
        { '<leader>q', group = 'Diagnostics', desc = 'Toggle diagnostics list' },
        { '<leader>l', group = 'Format', desc = '[F]ormat buffer (Conform)' }, -- From conform.nvim (Kickstart)
        { '<leader>c', group = 'Colemak Window' },
        { '<leader>c', '<leader>ch', desc = 'Focus left pane', group = 'Colemak Window' },
        { '<leader>c', '<leader>ci', desc = 'Focus right pane', group = 'Colemak Window' },
        { '<leader>c', '<leader>cn', desc = 'Focus down pane', group = 'Colemak Window' },
        { '<leader>c', '<leader>ce', desc = 'Focus up pane', group = 'Colemak Window' },
        { '<leader>c', '<leader>cH', desc = 'Move window left', group = 'Colemak Window' },
        { '<leader>c', '<leader>cI', desc = 'Move window right', group = 'Colemak Window' },
        { '<leader>c', '<leader>cN', desc = 'Move window down', group = 'Colemak Window' },
        { '<leader>c', '<leader>cE', desc = 'Move window up', group = 'Colemak Window' },
        { '<leader>r', group = 'LSP Rename/Workspace' },
        { '<leader>r', '<leader>rn', desc = '[R]e[n]ame (LSP)', group = 'LSP Rename/Workspace' },
        { '<leader>w', '<leader>wa', desc = '[W]orkspace [A]dd Folder (LSP)', group = 'LSP Rename/Workspace' },
        { '<leader>w', '<leader>wr', desc = '[W]orkspace [R]emove Folder (LSP)', group = 'LSP Rename/Workspace' },
        { '<leader>w', '<leader>wl', desc = '[W]orkspace [L]ist Folders (LSP)', group = 'LSP Rename/Workspace' },
        { '<leader>d', desc = '[D]ocument [S]ymbols (LSP Telescope)', group = 'LSP Search' }, -- for <leader>ds
        { '<leader>D', desc = 'Type [D]efinition (LSP)', group = 'LSP Go To' },
        { '<leader>c', '<leader>ca', desc = '[C]ode [A]ction (LSP)', group = 'LSP Actions' },
      },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
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
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>f', builtin.buffers, { desc = '[F]ind existing buffers' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      -- Kickstart's <leader><leader> for Telescope buffers is overridden by your custom <C-^>

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Your custom LSP keybindings
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'v' })
          map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('gk', vim.lsp.buf.hover, 'Hover Documentation')
          map('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

          -- Workspace folder management (from your old config)
          map('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
          map('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          map('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')

          -- Kickstart's default for quickfix diagnostics list (can coexist with your general <leader>q)
          -- map('<leader>q', vim.diagnostic.setloclist, 'Open diagnostic [Q]uickfix list')
          -- Your general <leader>q toggles the loclist, so this specific LSP one is probably not needed
          -- or could be mapped differently if you want both. For now, your general <leader>q takes precedence.

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local function client_supports_method(client_arg, method, bufnr_arg)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client_arg:supports_method(method, bufnr_arg)
            else
              return client_arg.supports_method(method, { bufnr = bufnr_arg })
            end
          end

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {
          text = { -- Non-Nerd Font fallback
            [vim.diagnostic.severity.ERROR] = 'E',
            [vim.diagnostic.severity.WARN] = 'W',
            [vim.diagnostic.severity.INFO] = 'I',
            [vim.diagnostic.severity.HINT] = 'H',
          },
        },
        virtual_text = false,
        -- virtual_text = { -- Kickstart default virtual_text
        --   enable = false,
        --   source = 'if_many',
        --   spacing = 2,
        --   format = function(diagnostic)
        --     local diagnostic_message = {
        --       [vim.diagnostic.severity.ERROR] = diagnostic.message,
        --       [vim.diagnostic.severity.WARN] = diagnostic.message,
        --       [vim.diagnostic.severity.INFO] = diagnostic.message,
        --       [vim.diagnostic.severity.HINT] = diagnostic.message,
        --     }
        --     return diagnostic_message[diagnostic.severity]
        --   end,
        -- },
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()
      capabilities.general = capabilities.general or {}
      capabilities.general.positionEncodings = { 'utf-16' } -- From your old config

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              workspace = { checkThirdParty = false }, -- from your old config for lua_ls
              telemetry = { enable = false }, -- from your old config for lua_ls
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
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
        '<leader>l', -- Kickstart uses <leader>f
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
      },
    },
  },
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` is COMMMENTED OUT in original Kickstart
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {}, -- Kickstart default for LuaSnip opts
      },
      'folke/lazydev.nvim',
    },
    opts = {
      keymap = {
        preset = 'enter', -- Your old config preset
        ['<Tab>'] = { 'snippet_forward', 'fallback' }, -- From your old config
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' }, -- From your old config
      },
      appearance = {
        nerd_font_variant = vim.g.have_nerd_font and 'mono' or 'normal',
      },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' }, -- Kickstart default (includes snippets source)
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
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
  -- {
  --   'folke/tokyonight.nvim',
  --   priority = 1000,
  --   config = function()
  --     require('tokyonight').setup {
  --       styles = {
  --         comments = { italic = false },
  --       },
  --     }
  --     vim.cmd.colorscheme 'tokyonight-night'
  --   end,
  -- },
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }

      -- Customized mini.surround setup
      require('mini.surround').setup {
        mappings = {
          -- Main actions: Remap from s-prefixed to gz-prefixed
          add = 'gza', -- Default 'sa'
          delete = 'gzd', -- Default 'sd'
          find = 'gzf', -- Default 'sf'
          find_left = 'gzF', -- Default 'sF'
          highlight = 'gzh', -- Default 'sh'
          replace = 'gzr', -- Default 'sr'
          update_n_lines = 'gzn', -- Default 'sn', or false if you don't use it

          -- Next/previous actions: Remap or disable (set to false)
          -- If you don't use "find next surrounding" etc., set to false.
          -- Otherwise, remap them like 'gzan', 'gzal', etc.
          add_next = false, -- 'gzan',    -- Default 'san'
          delete_next = false, -- 'gzdn',    -- Default 'sdn'
          find_next = false, -- 'gzfn',    -- Default 'sfn'
          find_left_next = false, -- 'gzFn',    -- Default 'sFn'
          highlight_next = false, -- 'gzhn',    -- Default 'shn'
          replace_next = false, -- 'gzrn',    -- Default 'srn'

          add_previous = false, -- 'gzal',    -- Default 'sal'
          delete_previous = false, -- 'gzdl',    -- Default 'sdl'
          find_previous = false, -- 'gzfl',    -- Default 'sfl'
          find_left_previous = false, -- 'gzFl',    -- Default 'sFl'
          highlight_previous = false, -- 'gzhl',    -- Default 'shl'
          replace_previous = false, -- 'gzrl',    -- Default 'srl'
        },
      }

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    -- NO 'dependencies' table here for nvim-treesitter-textobjects, as per original Kickstart
    opts = { -- Using Kickstart's default opts for treesitter
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      -- No 'textobjects' or 'incremental_selection' keymaps here, as per original Kickstart's opts.
      -- Kickstart mentions incremental selection is included, but doesn't set specific keymaps in its opts.
    },
  },
  -- Removed commented out 'windwp/nvim-ts-autotag' as it's not in original Kickstart
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns',
  -- { import = 'custom.plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
