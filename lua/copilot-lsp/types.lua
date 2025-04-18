---@class copilotlsp.InlineEdit
---@field command lsp.Command
---@field range lsp.Range
---@field text string
---@field newText string
---@field textDocument lsp.VersionedTextDocumentIdentifier
---@field ui nes.EditSuggestionUI?

---@class copilotlsp.copilotInlineEditResponse
---@field edits copilotlsp.InlineEdit[]

---@class nes.EditSuggestionUI
---@field preview_winnr? integer

---@class nes.Apply.Opts
---@field jump? boolean | { hl_timeout: integer? } auto jump to the end of the new edit
---@field trigger? boolean auto trigger the next edit suggestion
