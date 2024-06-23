local opt = vim.opt
local g = vim.g
local config = require("core.utils").load_config()

-------------------------------------- globals -----------------------------------------
g.nvchad_theme = config.ui.theme
g.base46_cache = vim.fn.stdpath("data") .. "/nvchad/base46/"
g.toggle_theme_icon = "   "
g.transparency = config.ui.transparency

-------------------------------------- neovide ------------------------------------------

if vim.g.neovide then
    -- Put anything you want to happen only in Neovide here
    vim.g.neovide_transparency = 0.99
    vim.g.neovide_remember_window_size = true
    vim.g.neovide_cursor_vfx_mode = "railgun"

    local function set_ime(args)
        if args.event:match("Enter$") then
            vim.g.neovide_input_ime = true
        else
            vim.g.neovide_input_ime = false
        end
    end

    local ime_input = vim.api.nvim_create_augroup("ime_input", {
        clear = true
    })

    vim.api.nvim_create_autocmd({"InsertEnter", "InsertLeave"}, {
        group = ime_input,
        pattern = "*",
        callback = set_ime
    })

    vim.api.nvim_create_autocmd({"CmdlineEnter", "CmdlineLeave"}, {
        group = ime_input,
        pattern = "[/\\?]",
        callback = set_ime
    })

end

-------------------------------------- options ------------------------------------------
opt.laststatus = 3 -- global statusline
opt.showmode = false

opt.clipboard:append("unnamedplus")
opt.cursorline = true

-- Indenting
opt.expandtab = true
opt.shiftwidth = 4
opt.smartindent = true
opt.tabstop = 4
opt.softtabstop = 4

opt.fillchars = {
    eob = " "
}
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"

-- Numbers
opt.number = true
opt.numberwidth = 4
opt.ruler = false

opt.guifont = "JetBrainsMono Nerd Font:h11"
-- opt.guifont = "FiraCode Nerd Font:h11"

-- disable nvim intro
opt.shortmess:append("sI")

opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.timeoutlen = 400
opt.undofile = true

-- interval for writing swap file to disk, also used by gitsigns
opt.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append("<>[]hl")

vim.opt.fileencoding = "utf-8" -- the encoding written to a file
opt.backup = false
opt.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited

g.mapleader = " "

-- disable some default providers
for _, provider in ipairs({"node", "perl", "python3", "ruby"}) do
    vim.g["loaded_" .. provider .. "_provider"] = 0
end

-- add binaries installed by mason.nvim to path
local is_windows = vim.loop.os_uname().sysname == "Windows_NT"
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. (is_windows and ";" or ":") .. vim.env.PATH

-------------------------------------- autocmds ------------------------------------------
local autocmd = vim.api.nvim_create_autocmd

-- dont list quickfix buffers
autocmd("FileType", {
    pattern = "qf",
    callback = function()
        vim.opt_local.buflisted = false
    end
})

-- reload some chadrc options on-save
autocmd("BufWritePost", {
    pattern = vim.tbl_map(function(path)
        return vim.fs.normalize(vim.loop.fs_realpath(path))
    end, vim.fn.glob(vim.fn.stdpath("config") .. "/lua/custom/**/*.lua", true, true, true)),
    group = vim.api.nvim_create_augroup("ReloadNvChad", {}),

    callback = function(opts)
        local fp = vim.fn.fnamemodify(vim.fs.normalize(vim.api.nvim_buf_get_name(opts.buf)), ":r") --[[@as string]]
        local app_name = vim.env.NVIM_APPNAME and vim.env.NVIM_APPNAME or "nvim"
        local module = string.gsub(fp, "^.*/" .. app_name .. "/lua/", ""):gsub("/", ".")

        require("plenary.reload").reload_module("base46")
        require("plenary.reload").reload_module(module)
        require("plenary.reload").reload_module("custom.chadrc")

        config = require("core.utils").load_config()

        vim.g.nvchad_theme = config.ui.theme
        vim.g.transparency = config.ui.transparency

        -- statusline
        require("plenary.reload").reload_module("nvchad.statusline." .. config.ui.statusline.theme)
        vim.opt.statusline = "%!v:lua.require('nvchad.statusline." .. config.ui.statusline.theme .. "').run()"

        -- tabufline
        if config.ui.tabufline.enabled then
            require("plenary.reload").reload_module("nvchad.tabufline.modules")
            vim.opt.tabline = "%!v:lua.require('nvchad.tabufline.modules').run()"
        end

        require("base46").load_all_highlights()
    end
})

-------------------------------------- commands ------------------------------------------
local new_cmd = vim.api.nvim_create_user_command

-- new_cmd("NvChadUpdate", function()
--     require "nvchad.updater"()
-- end, {})

-- autocmd("LspAttach", {
--     group = vim.api.nvim_create_augroup("UserLspConfig", {}),
--     callback = function(args)
--         local client = vim.lsp.get_client_by_id(args.data.client_id)
--         if client.server_capabilities.inlayHintProvider then
--             vim.lsp.inlay_hint.enable(args.buf, true)
--         end
--         -- whatever other lsp config you want
--     end
-- })
