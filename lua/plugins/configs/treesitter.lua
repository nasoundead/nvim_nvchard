local options = {
    ensure_installed = { -- c
    "c", "cmake", "cpp", "python", "rust", "java", "sql", "go", "gomod", "gosum", "fish", "dockerfile", "git_config",
    "bash", "awk", "css", "typescript", "html", "json", "json5", "javascript", "http", "diff", "xml", "yaml", "toml",
    "comment", "markdown", "org"},
    auto_install = true,
    highlight = {
        enable = true,
        use_languagetree = true
    },

    indent = {
        enable = true
    },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil
    }
}

return options
