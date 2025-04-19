---@type vim.lsp.Config
return {
    --NOTE: This name means that existing blink completion works
    name = "copilot",
    cmd = {
        "copilot-language-server",
        "--stdio",
    },
    init_options = {
        --TODO: Grab versions from the editor
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
    root_dir = vim.uv.cwd(),
    on_init = function(client)
        vim.api.nvim_set_hl(0, "NesAdd", { link = "DiffAdd", default = true })
        vim.api.nvim_set_hl(0, "NesDelete", { link = "DiffDelete", default = true })
        vim.api.nvim_set_hl(0, "NesApply", { link = "DiffText", default = true })

        local nes = require("copilot-lsp.nes")
        local inline_completion = require("copilot-lsp.completion")

        -- TODO: make this configurable for key maps, or just expose commands to map in config
        vim.keymap.set("i", "<c-i>", function()
            inline_completion.request_inline_completion(1)
        end)

        vim.keymap.set("n", "<leader>xa", function()
            nes.apply_pending_nes(nil, { trigger = true, jump = true }, client)
        end)

        local au = vim.api.nvim_create_augroup("copilot-language-server", { clear = true })
        vim.api.nvim_create_autocmd("TextChangedI", {
            callback = function()
                inline_completion.request_inline_completion(2)
            end,
            group = au,
        })

        vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
            callback = function()
                local debounced_request = require("copilot-lsp.util").debounce(nes.request_nes, 500)
                debounced_request(client)
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
