-- Feinschliff an der Oberfläche
return {
  -- Projektbaum: versteckte Dateien zeigen, aktuelle Datei mitverfolgen
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = { width = 34 },
      filesystem = {
        follow_current_file = { enabled = true },
        filtered_items = { hide_dotfiles = false, hide_gitignored = true },
      },
    },
  },
  -- Editor-Tabs immer anzeigen, auch bei nur einer Datei
  {
    "akinsho/bufferline.nvim",
    opts = { options = { always_show_bufferline = true } },
  },
}
