# Copilot LSP Configuration for Neovim

## Features

### Done

- TextDocument Focusing

### In Progress

- Inline Completion
- Next Edit Suggestion
- Uses native LSP Binary

### To Do

- Sign In Flow
- Status Notification

## Usage
To use the plugin, add the following to your Neovim configuration:
```lua
return {
    "copilotlsp-nvim/copilot-lsp",
    init = function()
        vim.lsp.enable("copilot")
        vim.keymap.set("n", "<leader>xa", function()
            require("copilot-lsp.nes").apply_pending_nes()
        end)
    end,
}
```

# Requirements

- Copilot LSP installed via Mason or system and on PATH

### Screenshots

#### NES
![JS Correction](https://github.com/user-attachments/assets/8941f8f9-7d1b-4521-b8e9-f1dcd12d31e9)
![Go Insertion](https://github.com/user-attachments/assets/2c0c4ad9-873b-4860-9eff-ecdb76007234)

https://github.com/user-attachments/assets/1d5bed4a-fd0a-491f-91f3-a3335cc28682
