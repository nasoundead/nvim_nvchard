dofile(vim.g.base46_cache .. "lsp")
require "nvchad.lsp"

local M = {}
local utils = require "core.utils"

-- export on_attach & capabilities for custom lspconfigs

M.on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false

    utils.load_mappings("lspconfig", {
        buffer = bufnr
    })

    if client.server_capabilities.signatureHelpProvider then
        require("nvchad.signature").setup(client)
    end

    if not utils.load_config().ui.lsp_semantic_tokens and client.supports_method "textDocument/semanticTokens" then
        client.server_capabilities.semanticTokensProvider = nil
    end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
    documentationFormat = {"markdown", "plaintext"},
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = {
        valueSet = {1}
    },
    resolveSupport = {
        properties = {"documentation", "detail", "additionalTextEdits"}
    }
}
M.capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
}

require("lspconfig").lua_ls.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,

    settings = {
        Lua = {
            diagnostics = {
                globals = {"vim"}
            },
            workspace = {
                library = {
                    [vim.fn.expand "$VIMRUNTIME/lua"] = true,
                    [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
                    [vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
                    [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true
                },
                maxPreload = 100000,
                preloadFileSize = 10000
            }
        }
    }
}

require("lspconfig").gopls.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,

    settings = {}
}

local util = require("lspconfig/util")
require("lspconfig").rust_analyzer.setup {
    on_attach = M.on_attach,
    capabilities = M.capabilities,
    filetypes = {"rust"},
    -- root_dir = util.root_pattern("Cargo.toml"),
    root_dir = function(fname)
        local cargo_crate_dir = util.root_pattern 'Cargo.toml'(fname)
        local cmd = 'cargo metadata --no-deps --format-version 1'
        if cargo_crate_dir ~= nil then
            cmd = cmd .. ' --manifest-path ' .. util.path.join(cargo_crate_dir, 'Cargo.toml')
        end
        local cargo_metadata = vim.fn.system(cmd)
        local cargo_workspace_dir = nil
        if vim.v.shell_error == 0 then
            cargo_workspace_dir = vim.fn.json_decode(cargo_metadata)['workspace_root']
        end
        return cargo_workspace_dir or cargo_crate_dir or util.root_pattern 'rust-project.json'(fname) or
                   util.find_git_ancestor(fname)
    end,
    settings = {
        ["rust-analyzer"] = {
            checkOnSave = {
                command = "clippy"
            },
            inlayHints = {
                enable = true,
                parameterHints = true,
                typeHints = true,
                otherHints = true
            },
            cargo = {
                buildScripts = {
                    enable = true
                },
                allFeatures = true
            },
            procMacro = {
                enable = true
            },
            diagnostics = {
                enable = true,
                disabled = {},
                enableExperimental = true
            }
        }
    }
}

return M
