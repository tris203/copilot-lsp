local errs = require("copilot-lsp.errors")
local utils = require("copilot-lsp.util")

local M = {}

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
    utils.apply_inline_edit(edit)
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
