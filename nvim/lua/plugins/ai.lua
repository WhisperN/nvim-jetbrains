-- Lokale KI über Ollama: Inline-Completion (minuet) und Chat/Agent (CodeCompanion).
-- Modelle und URL stehen in lua/config/ai.lua.
local ai = require("config.ai")

return {
  -- Inline-Vorschläge als grauer "Ghost Text", Annahme mit Tab ---------------
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "InsertEnter",
    init = function()
      -- LazyVim ruft diese Aktion bei <Tab> auf: Vorschlag annehmen, falls sichtbar
      LazyVim.cmp.actions.ai_accept = function()
        local ok, vt = pcall(require, "minuet.virtualtext")
        if ok and vt.action.is_visible() then
          vt.action.accept()
          return true
        end
      end
    end,
    opts = {
      provider = "openai_fim_compatible",
      n_completions = 1,
      -- Zeichen Kontext vor/nach dem Cursor. Auf schnellen Rechnern erhöhen.
      context_window = 1024,
      request_timeout = 5,
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM", -- Ollama braucht keinen Key; irgendeine gesetzte Variable genügt
          name = "Ollama",
          end_point = ai.ollama_url .. "/v1/completions",
          model = ai.completion_model,
          optional = { max_tokens = 96, top_p = 0.9 },
        },
      },
      virtualtext = {
        auto_trigger_ft = { "*" },
        auto_trigger_ignore_ft = { "neo-tree", "snacks_picker_input", "codecompanion", "lazy", "mason" },
        keymap = {
          accept = "<M-l>", -- zusätzlich zu Tab
          accept_line = "<M-j>", -- nur eine Zeile übernehmen
          next = "<M-]>", -- nächster Vorschlag / manuell auslösen
          prev = "<M-[>",
          dismiss = "<M-e>",
        },
      },
    },
  },

  -- Chat, Inline-Bearbeitung und Agent-Tools ---------------------------------
  {
    "olimorris/codecompanion.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCmd" },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Chat" },
      { "<leader>ap", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
      { "<leader>ai", ":CodeCompanion ", mode = { "n", "v" }, desc = "AI Inline Edit" },
      { "<leader>as", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add Selection to AI Chat" },
    },
    opts = {
      adapters = {
        http = {
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
              env = { url = ai.ollama_url },
            })
          end,
        },
      },
      interactions = {
        chat = { adapter = { name = "ollama", model = ai.chat_model } },
        inline = { adapter = { name = "ollama", model = ai.chat_model } },
        cmd = { adapter = { name = "ollama", model = ai.chat_model } },
      },
    },
  },
}
