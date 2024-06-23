-- All plugins have lazy=true by default,to load a plugin on startup just lazy=false
-- List of all default plugins & their definitions
-- Get platform dependant build script
local function tabnine_build_path()
    -- Replace vim.uv with vim.loop if using NVIM 0.9.0 or below
    if vim.uv.os_uname().sysname == "Windows_NT" then
        return "pwsh.exe -file .\\dl_binaries.ps1"
    else
        return "./dl_binaries.sh"
    end
end
local default_plugins = {"nvim-lua/plenary.nvim", {
    "NvChad/base46",
    branch = "v2.0",
    build = function()
        require("base46").load_all_highlights()
    end
}, {
    "NvChad/ui",
    branch = "v2.0",
    lazy = false
}, {
    "NvChad/nvterm",
    init = function()
        require("core.utils").load_mappings("nvterm")
    end,
    config = function(_, opts)
        require("base46.term")
        require("nvterm").setup(opts)
    end
}, {
    "NvChad/nvim-colorizer.lua",
    init = function()
        require("core.utils").lazy_load("nvim-colorizer.lua")
    end,
    config = function(_, opts)
        require("colorizer").setup(opts)

        -- execute colorizer as soon as possible
        vim.defer_fn(function()
            require("colorizer").attach_to_buffer(0)
        end, 0)
    end
}, {
    "nvim-tree/nvim-web-devicons",
    opts = function()
        return {
            override = require("nvchad.icons.devicons")
        }
    end,
    config = function(_, opts)
        dofile(vim.g.base46_cache .. "devicons")
        require("nvim-web-devicons").setup(opts)
    end
}, {
    "lukas-reineke/indent-blankline.nvim",
    version = "2.20.7",
    init = function()
        require("core.utils").lazy_load("indent-blankline.nvim")
    end,
    opts = function()
        return require("plugins.configs.others").blankline
    end,
    config = function(_, opts)
        require("core.utils").load_mappings("blankline")
        dofile(vim.g.base46_cache .. "blankline")
        require("indent_blankline").setup(opts)
    end
}, {
    "nvim-treesitter/nvim-treesitter",
    init = function()
        require("core.utils").lazy_load("nvim-treesitter")
    end,
    cmd = {"TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo"},
    build = ":TSUpdate",
    opts = function()
        return require("plugins.configs.treesitter")
    end,
    config = function(_, opts)
        dofile(vim.g.base46_cache .. "syntax")
        require("nvim-treesitter.configs").setup(opts)
    end
}, -- git stuff
{
    "lewis6991/gitsigns.nvim",
    ft = {"gitcommit", "diff"},
    init = function()
        -- load gitsigns only when a git file is opened
        vim.api.nvim_create_autocmd({"BufRead"}, {
            group = vim.api.nvim_create_augroup("GitSignsLazyLoad", {
                clear = true
            }),
            callback = function()
                vim.fn.system("git -C " .. '"' .. vim.fn.expand("%:p:h") .. '"' .. " rev-parse")
                if vim.v.shell_error == 0 then
                    vim.api.nvim_del_augroup_by_name("GitSignsLazyLoad")
                    vim.schedule(function()
                        require("lazy").load({
                            plugins = {"gitsigns.nvim"}
                        })
                    end)
                end
            end
        })
    end,
    opts = function()
        return require("plugins.configs.others").gitsigns
    end,
    config = function(_, opts)
        dofile(vim.g.base46_cache .. "git")
        require("gitsigns").setup(opts)
    end
}, -- lsp stuff
{
    "williamboman/mason.nvim",
    cmd = {"Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate"},
    opts = function()
        return require("plugins.configs.mason")
    end,
    config = function(_, opts)
        dofile(vim.g.base46_cache .. "mason")
        require("mason").setup(opts)

        -- custom nvchad cmd to install all mason binaries listed
        vim.api.nvim_create_user_command("MasonInstallAll", function()
            vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
        end, {})

        vim.g.mason_binaries_list = opts.ensure_installed
    end
}, {
    "neovim/nvim-lspconfig",
    dependencies = {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
            require("plugins.configs.null-ls")
        end
    },
    init = function()
        require("core.utils").lazy_load("nvim-lspconfig")
    end,
    config = function()
        require("plugins.configs.lspconfig")
    end
}, {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
        require("core.utils").lazy_load("rust.vim")
        vim.g.rustfmt_autosave = 1
    end
}, {
    "simrat39/rust-tools.nvim",
    dependencies = {"neovim/nvim-lspconfig"},
    opts = function()
        return require("plugins.configs.rust-tools")
    end,
    config = function(_, opts)
        local rt = require("rust-tools")
        rt.setup(opts)
        -- rt.inlay_hints.enable()
    end
}, {"mfussenegger/nvim-dap"}, {
    "saecki/crates.nvim",
    ft = {"rust", "toml"},
    config = function(_, opts)
        local crates = require("crates")
        crates.setup(opts)
        crates.show()
    end
}, -- load luasnips + cmp related in insert mode only
{
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {{
        -- snippet plugin
        "L3MON4D3/LuaSnip",
        dependencies = "rafamadriz/friendly-snippets",
        opts = {
            history = true,
            updateevents = "TextChanged,TextChangedI"
        },
        config = function(_, opts)
            require("plugins.configs.others").luasnip(opts)
        end
    }, -- autopairing of (){}[] etc
    {
        "windwp/nvim-autopairs",
        opts = {
            fast_wrap = {},
            disable_filetype = {"TelescopePrompt", "vim"}
        },
        config = function(_, opts)
            require("nvim-autopairs").setup(opts)

            -- setup cmp for autopairs
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end
    }, -- cmp sources plugins
    {"saadparwaiz1/cmp_luasnip", "hrsh7th/cmp-nvim-lua", "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer",
     "hrsh7th/cmp-path"}},
    opts = function()
        local M = require("plugins.configs.cmp")
        table.insert(M.sources, {
            name = "crates",
            group_index = 2
        })
        return M
    end,
    config = function(_, opts)
        require("cmp").setup(opts)
    end
}, {
    "numToStr/Comment.nvim",
    keys = {{
        "gcc",
        mode = "n",
        desc = "Comment toggle current line"
    }, {
        "gc",
        mode = {"n", "o"},
        desc = "Comment toggle linewise"
    }, {
        "gc",
        mode = "x",
        desc = "Comment toggle linewise (visual)"
    }, {
        "gbc",
        mode = "n",
        desc = "Comment toggle current block"
    }, {
        "gb",
        mode = {"n", "o"},
        desc = "Comment toggle blockwise"
    }, {
        "gb",
        mode = "x",
        desc = "Comment toggle blockwise (visual)"
    }},
    init = function()
        require("core.utils").load_mappings("comment")
    end,
    config = function(_, opts)
        require("Comment").setup(opts)
    end
}, -- file managing , picker etc
{
    "nvim-tree/nvim-tree.lua",
    cmd = {"NvimTreeToggle", "NvimTreeFocus"},
    init = function()
        require("core.utils").load_mappings("nvimtree")
    end,
    opts = function()
        return require("plugins.configs.nvimtree")
    end,
    config = function(_, opts)
        dofile(vim.g.base46_cache .. "nvimtree")
        require("nvim-tree").setup(opts)
        local function my_on_attach(bufnr)
            local api = require("nvim-tree.api")
            local function opts(desc)
                return {
                    desc = "nvim-tree: " .. desc,
                    buffer = bufnr,
                    noremap = true,
                    silent = true,
                    nowait = true
                }
            end
            -- default mappings
            api.config.mappings.default_on_attach(bufnr)
            -- custom mappings
            vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
            vim.keymap.set("n", "h", api.node.navigate.parent, opts("Up"))
            vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
        end
        require("nvim-tree").setup({
            on_attach = my_on_attach
        })
    end
}, -- folding
{
    "kevinhwang91/nvim-ufo",
    dependencies = {{"kevinhwang91/promise-async"}, {
        "luukvbaal/statuscol.nvim",
        opts = function()
            return require("plugins.configs.statuscol")
        end,
        config = function(_, opts)
            require("statuscol").setup(opts)
        end
    }},
    event = "BufRead",
    keys = {{"zR", function()
        require("ufo").openAllFolds()
    end}, {"zM", function()
        require("ufo").closeAllFolds()
    end}, {"K", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
            vim.lsp.buf.hover()
        end
    end}},
    opts = function()
        return require("plugins.configs.ufo")
    end,
    config = function(_, opts)
        vim.o.foldcolumn = "1"
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true
        vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
        local ufo = require("ufo")
        ufo.setup(opts)
    end
}, -- statusline
{
    "ahmedkhalf/project.nvim",
    opts = function()
        return require("plugins.configs.project")
    end,
    config = function(_, opts)
        local project = require("project_nvim")
        project.setup(opts)
    end
}, {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {{
        "s",
        mode = {"n", "x", "o"},
        function()
            require("flash").jump()
        end,
        desc = "Flash"
    }, {
        "S",
        mode = {"n", "x", "o"},
        function()
            require("flash").treesitter()
        end,
        desc = "Flash Treesitter"
    }, {
        "r",
        mode = "o",
        function()
            require("flash").remote()
        end,
        desc = "Remote Flash"
    }, {
        "R",
        mode = {"o", "x"},
        function()
            require("flash").treesitter_search()
        end,
        desc = "Treesitter Search"
    }, {
        "<c-s>",
        mode = {"c"},
        function()
            require("flash").toggle()
        end,
        desc = "Toggle Flash Search"
    }}
}, {
    "nvim-telescope/telescope.nvim",
    dependencies = {"nvim-treesitter/nvim-treesitter", {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
    } -- {
    --     "nvim-telescope/telescope-fzf-native.nvim",
    --     build = "make"
    -- }
    },
    cmd = "Telescope",
    init = function()
        require("core.utils").load_mappings("telescope")
    end,
    opts = function()
        return require("plugins.configs.telescope")
    end,
    config = function(_, opts)
        dofile(vim.g.base46_cache .. "telescope")
        local telescope = require("telescope")
        telescope.setup(opts)

        -- load extensions
        for _, ext in ipairs(opts.extensions_list) do
            telescope.load_extension(ext)
        end
    end
}, -- Only load whichkey after all the gui
{
    "folke/which-key.nvim",
    keys = {"<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g"},
    init = function()
        require("core.utils").load_mappings("whichkey")
    end,
    cmd = "WhichKey",
    config = function(_, opts)
        dofile(vim.g.base46_cache .. "whichkey")
        require("which-key").setup(opts)
    end
}, -- nvim surround
--     Old text                    Command         New text
-- --------------------------------------------------------------------------------
--     surr*ound_words             ysiw)           (surround_words)
--     *make strings               ys$"            "make strings"
--     [delete ar*ound me!]        ds]             delete around me!
--     remove <b>HTML t*ags</b>    dst             remove HTML tags
--     'change quot*es'            cs'"            "change quotes"
--     <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
--     delete(functi*on calls)     dsf             function calls-
{
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = function()
        return {}
    end,
    config = function(_, opts)
        local sur = require("nvim-surround")
        sur.setup(opts)
    end
}, {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
    -- optional, but required for fuzzy finder support
    dependencies = {"nvim-telescope/telescope-fzf-native.nvim"}
    -- config = function(_, opts)
    -- 	require("dropbar").setup(opts)
    -- end,
}, {
    "codota/tabnine-nvim",
    build = tabnine_build_path(),

    event = "VeryLazy",
    opts = function()
        return require("plugins.configs.tabnine")
    end,

    config = function(_, opts)
        local tab = require("tabnine")
        tab.setup(opts)
        -- require("tabnine.keymaps")
        --- Example integration with Tabnine and LuaSnip; falling back to inserting tab if neither has a completion
        vim.keymap.set("i", "<tab>", function()
            if require("tabnine.keymaps").has_suggestion() then
                return require("tabnine.keymaps").accept_suggestion()
            elseif require("luasnip").jumpable(1) then
                return require("luasnip").jump(1)
            else
                return "<tab>"
            end
        end, {
            expr = true
        })
    end
}}

local config = require("core.utils").load_config()

if #config.plugins > 0 then
    table.insert(default_plugins, {
        import = config.plugins
    })
end

require("lazy").setup(default_plugins, config.lazy_nvim)
