---@type vim.lsp.Config
return {
    name = "copilot",
    cmd = {
        "copilot-language-server",
        "--stdio",
    },
    init_options = {
        editorInfo = { name = "neovim", version = "0.11" },
        editorPluginInfo = {
            name = "Github Copilot LSP for Neovim",
            version = "0.0.1",
        },
    },
    settings = {
        nextEditSuggestions = {
            enabled = true,
        },
    },
    root_markers = { ".git" },
    on_init = function(client)
        local nes = require("copilot-lsp.nes")
        local inline_completion = require("copilot-lsp.completion")

        vim.keymap.set("i", "<c-i>", function()
            inline_completion.request_inline_completion(1)
        end)

        vim.keymap.set("n", "<leader>x", function()
            nes.request_nes(client)
        end)

        local au = vim.api.nvim_create_augroup("copilot-language-server", { clear = true })
        vim.api.nvim_create_autocmd("TextChangedI", {
            callback = function()
                inline_completion.request_inline_completion(2)
            end,
            group = au,
        })

        vim.api.nvim_create_autocmd("BufEnter", {
            callback = function()
                local td_params = vim.lsp.util.make_text_document_params()
                client:notify("textDocument/didFocus", {
                    textDocument = {
                        uri = td_params.uri,
                    },
                })
            end,
            group = au,
        })
    end,
}
