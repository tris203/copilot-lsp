local errs = require("copilot-lsp.errors")
local utils = require("copilot-lsp.util")

local M = {}

local nes_ext
local nes_ns = vim.api.nvim_create_namespace("copilot-nes")

---@param edit copilotInlineEdit
local function display_nes(edit)
    dd("trying to display")
    local bufnr = vim.uri_to_bufnr(edit.textDocument.uri)
    if edit.text:match("\n") then
        assert(false, "multi line edits not supported yet")
    end

    nes_ext = vim.api.nvim_buf_set_extmark(bufnr, nes_ns, edit.range.start.line, edit.range.start.character, {
        id = nes_ext,
        virt_lines = { { { edit.text, "Comment" } } },
    })

    --create accept and decline keymaps
    vim.keymap.set("n", "<leader>xa", function()
        utils.apply_inline_edit(edit)
        vim.api.nvim_buf_del_extmark(bufnr, nes_ns, nes_ext)
    end, { buffer = bufnr })

    vim.keymap.set("n", "<leader>xd", function()
        vim.api.nvim_buf_del_extmark(bufnr, nes_ns, nes_ext)
    end, { buffer = bufnr })
end

---@param err lsp.ResponseError?
---@param result copilotInlineEditResponse
local function handle_nes_response(err, result)
    if err then
        vim.notify(err.message)
        return
    end
    if #result.edits > 1 then
        vim.notify("more than 1 edit, dont know what to do yet")
        return
    end

    if #result.edits == 0 then
        vim.notify("no edits")
        return
    end

    local edit = result.edits[1]
    display_nes(edit)
    -- utils.apply_inline_edit(edit)
end

---@param copilot_lss vim.lsp.Client?
function M.request_nes(copilot_lss)
    local pos_params = vim.lsp.util.make_position_params(0, "utf-16")
    local version = vim.lsp.util.buf_versions[vim.api.nvim_get_current_buf()]
    assert(copilot_lss, errs.ErrNotStarted)
    ---@diagnostic disable-next-line: inject-field
    pos_params.textDocument.version = version
    copilot_lss:request("textDocument/copilotInlineEdit", pos_params, handle_nes_response)
end

return M
