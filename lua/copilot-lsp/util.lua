local M = {}
---@param edit copilotInlineEdit
function M.apply_inline_edit(edit)
    local bufnr = vim.uri_to_bufnr(edit.textDocument.uri)
    local multi_line
    if edit.text:match("\n") then
        multi_line = vim.split(edit.text, "\n")
    end

    vim.api.nvim_buf_set_text(
        bufnr,
        edit.range.start.line,
        edit.range.start.character,
        edit.range["end"].line,
        edit.range["end"].character,
        multi_line or { edit.text }
    )
end

return M
