local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

----------------
--- plugins ---
----------------
require("lazy").setup({

    -- colorscheme
    {
        'sainnhe/gruvbox-material',
        enabled = true,
        priority = 1000,
        config = function()
            vim.o.background = "dark"
            vim.g.gruvbox_material_background = "hard"
            vim.cmd.colorscheme 'gruvbox-material'
        end,
    },

    -- git signs
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
        },
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
                end

                -- stylua: ignore start
                map("n", "]h", gs.next_hunk, "Next Hunk")
                map("n", "[h", gs.prev_hunk, "Prev Hunk")
                map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
                map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
                map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
                map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
                map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
                map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
                map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
                map("n", "<leader>ghd", gs.diffthis, "Diff This")
                map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
            end,
        }

    },

    -- LSP ZERO
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' }, -- Required
            {
                -- Optional
                'williamboman/mason.nvim',
                build = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end,
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },     -- Required
        },
        config = function()
            local lsp = require('lsp-zero').preset("recommended")
            lsp.ensure_installed({
                'gopls', 'rust_analyzer', 'tsserver'
            })
            lsp.on_attach(function(client, bufnr)
                local opts = { buffer = bufnr, remap = false }
                vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                vim.keymap.set('n', 'lr', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                vim.keymap.set({ 'n', 'x' }, 'lf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                vim.keymap.set('n', 'la', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

                vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
                vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
                vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
            end)
            lsp.set_preferences({
                suggest_lsp_servers = false,
                sign_icons = {
                    error = 'E',
                    warn = 'W',
                    hint = 'H',
                    info = 'I'
                }
            })
            lsp.setup()
        end
    },

    -- better diagnostics list and others
    {
        "folke/trouble.nvim",
        cmd = { "TroubleToggle", "Trouble" },
        opts = { use_diagnostic_signs = true },
        keys = {
            { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>",  desc = "Document Diagnostics (Trouble)" },
            { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
            { "<leader>xL", "<cmd>TroubleToggle loclist<cr>",               desc = "Location List (Trouble)" },
            { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>",              desc = "Quickfix List (Trouble)" },
            {
                "[q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").previous({ skip_groups = true, jump = true })
                    else
                        vim.cmd.cprev()
                    end
                end,
                desc = "Previous trouble/quickfix item",
            },
            {
                "]q",
                function()
                    if require("trouble").is_open() then
                        require("trouble").next({ skip_groups = true, jump = true })
                    else
                        vim.cmd.cnext()
                    end
                end,
                desc = "Next trouble/quickfix item",
            },
        },
    },

    -- Vim-Go
    {
        "fatih/vim-go",
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
            "nvim-lua/plenary.nvim",
            build = "make",
            config = function()
                require("telescope").load_extension("fzf")
            end,
        },
        keys = {
            { "<leader>st",       "<cmd>Telescope live_grep<cr>",                 desc = "Grepd" },
            { "<leader>:",        "<cmd>Telescope command_history<cr>",           desc = "Command History" },
            -- find
            { "<leader>fb",       "<cmd>Telescope buffers<cr>",                   desc = "Buffers" },
            { "<leader><leader>", "<cmd>Telescope buffers<cr>",                   desc = "Buffers" },
            { "<leader>ff",       "<cmd>Telescope find_files<cr>",                desc = "Find Files" },
            { "<C-f>",            "<cmd>Telescope find_files<cr>",                desc = "Find Files" },
            { "<C-p>",            "<cmd>Telescope git_files<cr>",                 desc = "Git Files" },
            -- search
            { "<leader>sa",       "<cmd>Telescope autocommands<cr>",              desc = "Auto Commands" },
            { "<leader>sb",       "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
            { "<leader>sc",       "<cmd>Telescope command_history<cr>",           desc = "Command History" },
            { "<leader>sC",       "<cmd>Telescope commands<cr>",                  desc = "Commands" },
            { "<leader>sd",       "<cmd>Telescope diagnostics bufnr=0<cr>",       desc = "Document diagnostics" },
            { "<leader>sD",       "<cmd>Telescope diagnostics<cr>",               desc = "Workspace diagnostics" },
            { "<leader>sh",       "<cmd>Telescope help_tags<cr>",                 desc = "Help Pages" },
            { "<leader>sH",       "<cmd>Telescope highlights<cr>",                desc = "Search Highlight Groups" },
            { "<leader>sk",       "<cmd>Telescope keymaps<cr>",                   desc = "Key Maps" },
            { "<leader>sM",       "<cmd>Telescope man_pages<cr>",                 desc = "Man Pages" },
            { "<leader>sm",       "<cmd>Telescope marks<cr>",                     desc = "Jump to Mark" },
            { "<leader>so",       "<cmd>Telescope vim_options<cr>",               desc = "Options" },
            { "<leader>sR",       "<cmd>Telescope resume<cr>",                    desc = "Resume" },
            { "<leader>sw",       "<cmd>Telescope grep_string<cr>",               desc = "Grep String" },
        },
        opts = {
            defaults = {
                file_ignore_patterns = { 'node_modules', 'package-lock.json' },
                initial_mode         = 'insert',
                select_strategy      = 'reset',
                sorting_strategy     = 'ascending',
                layout_config        = {
                    width = 0.75,
                    height = 0.75,
                    prompt_position = "top",
                    preview_cutoff = 120,
                },
            },
            pickers = {
                find_files = {
                    hidden           = true,
                    previewer        = false,
                    initial_mode     = 'insert',
                    select_strategy  = 'reset',
                    sorting_strategy = 'ascending',
                    layout_strategy  = 'horizontal',
                    layout_config    = {
                        prompt_position = "top",
                        preview_cutoff = 120,
                        horizontal = {
                            width = 0.5,
                            height = 0.4,
                            preview_width = 0.6,
                        },
                    },
                },
                git_files = {
                    hidden           = true,
                    previewer        = false,
                    initial_mode     = 'insert',
                    select_strategy  = 'reset',
                    sorting_strategy = 'ascending',
                    layout_strategy  = 'horizontal',
                    layout_config    = {
                        prompt_position = "top",
                        preview_cutoff = 120,
                        horizontal = {
                            width = 0.5,
                            height = 0.4,
                            preview_width = 0.6,
                        },
                    },
                },
                buffers = {
                    hidden           = true,
                    previewer        = false,
                    initial_mode     = 'insert',
                    select_strategy  = 'reset',
                    sorting_strategy = 'ascending',
                    layout_strategy  = 'horizontal',
                    layout_config    = {
                        prompt_position = "top",
                        preview_cutoff = 120,
                        horizontal = {
                            width = 0.5,
                            height = 0.4,
                            preview_width = 0.6,
                        },
                    },
                },
            },
        },
    },

    -- autopairs
    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup {
                check_ts = true,
            }
        end
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        version = false, -- last release is way too old and doesn't work on Windows
        build = ":TSUpdate",
        lazy = false,
        event = { "BufReadPost", "BufNewFile" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, { "typescript", "tsx" })
            end
        end,
        config = function()
            require("nvim-treesitter.configs").setup {
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
                context_commentstring = { enable = true, enable_autocmd = false },
                auto_install = true,
                ensure_installed = {
                    "bash",
                    "c",
                    "javascript",
                    "typescript",
                    "yaml",
                    "rust",
                    "go"
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<leader>vv",
                        node_incremental = "+",
                        scope_incremental = false,
                        node_decremental = "_",
                    },
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,

                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["af"] = { query = "@function.outer", desc = "around a function" },
                            ["if"] = { query = "@function.inner", desc = "inner part of a function" },
                            ["ac"] = { query = "@class.outer", desc = "around a class" },
                            ["ic"] = { query = "@class.inner", desc = "inner part of a class" },
                            ["ai"] = { query = "@conditional.outer", desc = "around an if statement" },
                            ["ii"] = { query = "@conditional.inner", desc = "inner part of an if statement" },
                            ["al"] = { query = "@loop.outer", desc = "around a loop" },
                            ["il"] = { query = "@loop.inner", desc = "inner part of a loop" },
                            ["ap"] = { query = "@parameter.outer", desc = "around parameter" },
                            ["ip"] = { query = "@parameter.inner", desc = "inside a parameter" },
                        },
                        selection_modes = {
                            ["@parameter.outer"] = "v",   -- charwise
                            ["@parameter.inner"] = "v",   -- charwise
                            ["@function.outer"] = "v",    -- charwise
                            ["@conditional.outer"] = "V", -- linewise
                            ["@loop.outer"] = "V",        -- linewise
                            ["@class.outer"] = "<c-v>",   -- blockwise
                        },
                        include_surrounding_whitespace = false,
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist
                        goto_previous_start = {
                            ["[f"] = { query = "@function.outer", desc = "Previous function" },
                            ["[c"] = { query = "@class.outer", desc = "Previous class" },
                            ["[p"] = { query = "@parameter.inner", desc = "Previous parameter" },
                        },
                        goto_next_start = {
                            ["]f"] = { query = "@function.outer", desc = "Next function" },
                            ["]c"] = { query = "@class.outer", desc = "Next class" },
                            ["]p"] = { query = "@parameter.inner", desc = "Next parameter" },
                        },
                    },
                },
            }
        end
    },
})


----------------
--- SETTINGS ---
----------------
local options = {
    incsearch = true,                        -- make search act like search in modern browsers
    backup = false,                          -- creates a backup file
    clipboard = "unnamedplus",               -- allows neovim to access the system clipboard
    cmdheight = 1,                           -- more space in the neovim command line for displaying messages
    completeopt = { "menuone", "noselect" }, -- mostly just for cmp
    conceallevel = 0,                        -- so that `` is visible in markdown files
    fileencoding = "utf-8",                  -- the encoding written to a file
    hlsearch = true,                         -- highlight all matches on previous search pattern
    ignorecase = true,                       -- ignore case in search patterns
    mouse = "a",                             -- allow the mouse to be used in neovim
    pumheight = 10,                          -- pop up menu height
    showmode = false,                        -- we don't need to see things like -- INSERT -- anymore
    showtabline = 0,                         -- always show tabs
    smartcase = true,                        -- smart case
    smartindent = true,                      -- make indenting smarter again
    splitbelow = true,                       -- force all horizontal splits to go below current window
    splitright = true,                       -- force all vertical splits to go to the right of current window
    swapfile = false,                        -- creates a swapfile
    termguicolors = true,                    -- set term gui colors (most terminals support this)
    timeoutlen = 1000,                       -- time to wait for a mapped sequence to complete (in milliseconds)
    undofile = true,                         -- enable persistent undo
    updatetime = 100,                        -- faster completion (4000ms default)
    writebackup = false,                     -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
    expandtab = true,                        -- convert tabs to spaces
    shiftwidth = 2,                          -- the number of spaces inserted for each indentation
    tabstop = 2,                             -- insert 2 spaces for a tab
    cursorline = true,                       -- highlight the current line
    number = true,                           -- set numbered lines
    breakindent = true,                      -- wrap lines with indent
    relativenumber = true,                   -- set relative numbered lines
    numberwidth = 4,                         -- set number column width to 2 {default 4}
    signcolumn = "yes",                      -- always show the sign column, otherwise it would shift the text each time
    wrap = false,                            -- display lines as one long line
    scrolloff = 8,                           -- Makes sure there are always eight lines of context
    sidescrolloff = 8,                       -- Makes sure there are always eight lines of context
    laststatus = 3,                          -- Always display the status line
    showcmd = false,                         -- Don't show the command in the last line
    ruler = false,                           -- Don't show the ruler
    guifont = "monospace:h17",               -- the font used in graphical neovim applications
    title = true,                            -- set the title of window to the value of the titlestring
    modifiable = true,                       -- allow a buffer to be modified
}

for k, v in pairs(options) do
    vim.opt[k] = v
end


-- Keymaps --
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Ex)

-- Fast saving
vim.keymap.set('n', '<Leader>w', ':write!<CR>')
vim.keymap.set('n', '<Leader>q', ':q!<CR>', { silent = true })

-- Some useful quickfix shortcuts for quickfix
vim.keymap.set('n', '<C-n>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-m>', '<cmd>cprev<CR>zz')
vim.keymap.set('n', '<leader>a', '<cmd>cclose<CR>')

-- Exit on jj and jk
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

-- Exit on jj and jk
vim.keymap.set('i', 'jj', '<ESC>')
vim.keymap.set('i', 'jk', '<ESC>')

-- Remove search highlight
vim.keymap.set('n', '<Leader>h', ':nohlsearch<CR>')

vim.keymap.set('n', 'n', 'nzzzv', { noremap = true })
vim.keymap.set('n', 'N', 'Nzzzv', { noremap = true })
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")


-- If I visually select words and paste from clipboard, don't replace my
-- clipboard with the selected word, instead keep my old word in the
-- clipboard
vim.keymap.set("x", "p", "\"_dP")

-- Better split switching
vim.keymap.set('', '<C-j>', '<C-W>j')
vim.keymap.set('', '<C-k>', '<C-W>k')
vim.keymap.set('', '<C-h>', '<C-W>h')
vim.keymap.set('', '<C-l>', '<C-W>l')

-- Visually select lines, and move them up/down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('n', '<leader>c', ":bd<cr>")


-- autocommands
local api = vim.api

-- don't auto comment new line
api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })

--- Remove all trailing whitespace on save
local TrimWhiteSpaceGrp = api.nvim_create_augroup("TrimWhiteSpaceGrp", { clear = true })
api.nvim_create_autocmd("BufWritePre", {
    command = [[:%s/\s\+$//e]],
    group = TrimWhiteSpaceGrp,
})

-- wrap words "softly" (no carriage return) in mail buffer
api.nvim_create_autocmd("Filetype", {
    pattern = "mail",
    callback = function()
        vim.opt.textwidth = 0
        vim.opt.wrapmargin = 0
        vim.opt.wrap = true
        vim.opt.linebreak = true
        vim.opt.columns = 80
        vim.opt.colorcolumn = "80"
    end,
})

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- go to last loc when opening a buffer
api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

api.nvim_create_autocmd("FileType", { pattern = "man", command = [[nnoremap <buffer><silent> q :quit<CR>]] })

-- show cursor line only in active window
local cursorGrp = api.nvim_create_augroup("CursorLine", { clear = true })
api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
    pattern = "*",
    command = "set cursorline",
    group = cursorGrp,
})
api.nvim_create_autocmd(
    { "InsertEnter", "WinLeave" },
    { pattern = "*", command = "set nocursorline", group = cursorGrp }
)

-- Enable spell checking for certain file types
api.nvim_create_autocmd(
    { "BufRead", "BufNewFile" },
    -- { pattern = { "*.txt", "*.md", "*.tex" }, command = [[setlocal spell<cr> setlocal spelllang=en,de<cr>]] }
    {
        pattern = { "*.txt", "*.md", "*.tex" },
        callback = function()
            vim.opt.spell = true
            vim.opt.spelllang = "en,de"
        end,
    }
)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', '<leader>v', "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>", opts)
    end,
})
