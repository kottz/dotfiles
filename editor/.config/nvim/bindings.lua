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
--
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

  keymap('n', 'n', 'gj', opts)
  keymap('n', 'e', 'gk', opts)
  keymap('n', 'i', 'l', opts)
  keymap('n', 'gn', 'j', opts)
  keymap('n', 'ge', 'k', opts)
-- In(s)ert. The default s/S is synonymous with cl/cc and is not very useful.
--remap s i
--remap S I
  keymap('n', 's', 'i', opts)
  keymap('n', 'S', 'I', opts)
-- Repeat search.
--remap k nzz
--remap K Nzz
  keymap('n', 'k', 'nzz', opts)
  keymap('n', 'K', 'Nzz', opts)
-- BOL/EOL/Join.
--remap l ^
--remap L $
--remap <C-l> J
  keymap('n', 'l', '^', opts)
  keymap('n', 'L', '$', opts)
  keymap('n', '<C-l>', 'J', opts)
-- _r_ = inneR text objects.
--  onoremap r i
  keymap('n', 'r', 'i', opts) -- check if this works not sure
-- EOW.
--remap j e
--remap J E
  keymap('n', 'j', 'e', opts)
  keymap('n', 'J', 'E', opts)

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

  keymap('n', '<C-w>k', '<C-w>n', opts) -- Open new with k instead of n

  keymap('n', '<C-w>i', '<C-w>l', opts)
  keymap('n', '<C-w>n', '<C-w>j', opts)
  keymap('n', '<C-w>e', '<C-w>k', opts)
-- Moving windows around.
--remap <C-w>N <C-w>J
--remap <C-w>E <C-w>K
--remap <C-w>I <C-w>L
  keymap('n', '<C-w>N', '<C-w>J', opts)
  keymap('n', '<C-w>E', '<C-w>K', opts)
  keymap('n', '<C-w>I', '<C-w>L', opts)
-- High/Low. Mid remains `M` since <C-m> is unfortunately interpreted as <CR>.
--remap <C-e> H
--remap <C-n> L
  keymap('n', '<C-e>', 'H', opts)
  keymap('n', '<C-n>', 'L', opts)
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
  keymap('n', 'gh', '<C-o>', opts)
  keymap('n', 'gi', '<C-i>', opts)
  keymap('n', 'gH', 'g;', opts)
  keymap('n', 'gI', 'g,', opts)



-- =============================================================================
-- # Keyboard shortcuts
-- =============================================================================


-- Open hotkeys
--map <C-f> :Files<CR>
--nmap <leader>f :Buffers<CR>

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

--nnoremap <C-e> <Esc>
--inoremap <C-e> <Esc>
--vnoremap <C-e> <Esc>
--snoremap <C-e> <Esc>
--xnoremap <C-e> <Esc>
--cnoremap <C-e> <C-c>
--onoremap <C-e> <Esc>
--lnoremap <C-e> <Esc>
--tnoremap <C-e> <Esc>
  keymap('n', '<C-e>', t('<Esc>'), opts)
  keymap('i', '<C-e>', t('<Esc>'), opts)
  keymap('v', '<C-e>', t('<Esc>'), opts)
  keymap('c', '<C-e>', t('<Esc>'), opts)
  keymap('x', '<C-e>', t('<Esc>'), opts)
  keymap('t', '<C-e>', t('<Esc>'), opts)

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
  keymap('n', '<leader>p', ':read !wl-paste', opts)
  keymap('n', '<leader>c', ':read !wl-copy', opts)

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
  keymap('n', '<silent> gd', '<nop>', opts_silent)
  keymap('n', '<silent> gy', '<nop>', opts_silent)
  keymap('n', '<silent> gi', '<nop>', opts_silent)
  keymap('n', '<silent> gr', '<nop>', opts_silent)


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
