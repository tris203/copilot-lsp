local M = {}

---@param bufnr integer
---@param suggestion_ui nes.EditSuggestionUI
---@param ns_id integer
local function _dismiss_suggestion_ui(bufnr, suggestion_ui, ns_id)
    pcall(vim.api.nvim_win_close, suggestion_ui.preview_winnr, true)
    pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns_id, 0, -1)
end

---@param bufnr? integer
---@param ns_id integer
function M.clear_suggestion(bufnr, ns_id)
    bufnr = bufnr and bufnr > 0 and bufnr or vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
    ---@type copilotlsp.InlineEdit
    local state = vim.b[bufnr].nes_state
    if not state then
        return
    end

    _dismiss_suggestion_ui(bufnr, state.ui, ns_id)
    vim.b[bufnr].nes_state = nil
end

---@private
---@param edits copilotlsp.InlineEdit[]
---@param ns_id integer
function M._display_next_suggestion(edits, ns_id)
    if not edits or #edits == 0 then
        vim.notify("No suggestion available", vim.log.levels.INFO)
        return
    end
    local bufnr = vim.uri_to_bufnr(edits[1].textDocument.uri)
    local win_id = vim.fn.win_findbuf(bufnr)[1]
    local suggestion = edits[1]

    local ui = {}
    local deleted_lines_count = suggestion.range["end"].line - suggestion.range.start.line
    local added_lines = vim.split(suggestion.newText, "\n")
    local added_lines_count = suggestion.newText == "" and 0 or #added_lines - 1
    local same_line = 0

    if deleted_lines_count == 0 and added_lines_count == 0 then
        ---changing within line
        deleted_lines_count = 1
        added_lines_count = 1
        same_line = 1
        added_lines = { suggestion.newText }
    end

    if deleted_lines_count > 0 then
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, suggestion.range.start.line, 0, {
            hl_group = "NesDelete",
            end_row = suggestion.range["end"].line + 1,
        })
    end
    if added_lines_count > 0 then
        local virt_lines = {}
        for _ = 1, added_lines_count do
            table.insert(virt_lines, {
                { "", "Normal" },
            })
        end
        local line = suggestion.range.start.line + deleted_lines_count - 1 + same_line

        vim.api.nvim_buf_set_extmark(bufnr, ns_id, line, 0, {
            virt_lines = virt_lines,
        })

        local preview_bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(preview_bufnr, 0, -1, false, added_lines)
        vim.bo[preview_bufnr].modifiable = false
        vim.bo[preview_bufnr].buflisted = false
        vim.bo[preview_bufnr].bufhidden = "wipe"
        vim.bo[preview_bufnr].filetype = vim.bo[bufnr].filetype

        local cursor = vim.api.nvim_win_get_cursor(win_id)
        local win_width = vim.api.nvim_win_get_width(win_id)
        local offset = vim.fn.getwininfo(win_id)[1].textoff
        local preview_winnr = vim.api.nvim_open_win(preview_bufnr, false, {
            relative = "cursor",
            width = win_width - offset,
            height = (#added_lines + same_line) - 1,
            row = (suggestion.range["end"].line + same_line) - cursor[1] + 1,
            col = 0,
            style = "minimal",
            border = "none",
        })
        vim.wo[preview_winnr].number = false
        vim.wo[preview_winnr].winhighlight = "Normal:NesAdd"
        vim.wo[preview_winnr].winblend = 0

        ui.preview_winnr = preview_winnr
    end

    suggestion.ui = ui

    vim.b[bufnr].nes_state = suggestion

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = bufnr,
        callback = function()
            if not vim.b.nes_state then
                return true
            end

            local accepted_cursor = vim.b.nes_state.accepted_cursor
            if accepted_cursor then
                local cursor = vim.api.nvim_win_get_cursor(win_id)
                if cursor[1] == accepted_cursor[1] and cursor[2] == accepted_cursor[2] then
                    return
                end
            end

            M.clear_suggestion(bufnr, ns_id)
            return true
        end,
    })
end

return M
