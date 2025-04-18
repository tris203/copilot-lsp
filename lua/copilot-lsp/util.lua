local M = {}
---@param edit copilotlsp.InlineEdit
function M.apply_inline_edit(edit)
    local bufnr = vim.uri_to_bufnr(edit.textDocument.uri)

    ---@diagnostic disable-next-line: assign-type-mismatch
    vim.lsp.util.apply_text_edits({ edit }, bufnr, "utf-16")
end

return M
