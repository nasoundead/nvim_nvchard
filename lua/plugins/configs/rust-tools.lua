local on_attach = require("plugins.configs.lspconfig").on_attach

local capabilities = require("plugins.configs.lspconfig").capabilities
-- https://github.com/simrat39/rust-tools.nvim
local options = {
    server = {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
            ["rust-analyzer"] = {}
        }
    },
    dap = {
        adapter = require("rust-tools.dap").get_codelldb_adapter(vim.fn.getenv "HOME" ..
                                                                     "/.codelldb/extension/adapter/codelldb")
    },
    dap_repl = {
        enabled = true,
        open_cmd = "vsplit"
    }
}

return options
