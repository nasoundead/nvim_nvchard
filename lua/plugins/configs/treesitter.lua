local options = {
    ensure_installed = { -- c
    "c", "cmake", "cpp", -- language
    "python", "rust", "java", "sql", "go", "gomod", "gosum", -- script
    "lua", "fish", "dockerfile", "git_config", "bash", "awk", "vim", -- web
    "css", "typescript", "html", "json", "json5", "javascript", "http", "tsx", -- config
    "diff", "xml", "yaml", "toml", "comment", -- notes
    "markdown", "org"},

    highlight = {
        enable = true,
        use_languagetree = true
    },

    indent = {
        enable = true
    }
}

return options
