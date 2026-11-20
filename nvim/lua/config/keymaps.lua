-- JetBrains-ähnliche Tastenkürzel, zusätzlich zu den LazyVim-Standards.
-- Alt-Kürzel brauchen im Terminal die Einstellung "Option als Meta/Alt".
local map = vim.keymap.set

-- Alt+Enter: Quick-Fix / Intention Actions
map({ "n", "v" }, "<M-CR>", vim.lsp.buf.code_action, { desc = "Code Action (Alt+Enter)" })

-- Shift+F6: Umbenennen (viele Terminals senden dafür F18)
map("n", "<S-F6>", vim.lsp.buf.rename, { desc = "Rename (Shift+F6)" })
map("n", "<F18>", vim.lsp.buf.rename, { desc = "Rename (Shift+F6)" })

-- F2 / Shift+F2: nächster / vorheriger Fehler (Shift+F2 = F14)
local function diag(count)
  return function()
    vim.diagnostic.jump({ count = count, float = true })
  end
end
map("n", "<F2>", diag(1), { desc = "Next Problem (F2)" })
map("n", "<S-F2>", diag(-1), { desc = "Previous Problem (Shift+F2)" })
map("n", "<F14>", diag(-1), { desc = "Previous Problem (Shift+F2)" })

-- Ctrl+E: Recent Files
map("n", "<C-e>", function()
  Snacks.picker.recent()
end, { desc = "Recent Files (Ctrl+E)" })

-- Alt+1: Project-Toolwindow ein-/ausblenden
map("n", "<M-1>", "<cmd>Neotree toggle<cr>", { desc = "Project Tree (Alt+1)" })
