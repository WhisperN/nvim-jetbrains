-- Zentrale Einstellungen für die lokale KI (Ollama).
-- Maschinenspezifische Werte gehören in lua/config/ai_local.lua. Diese Datei
-- wird von install.sh passend zum Arbeitsspeicher erzeugt und ist in
-- .gitignore eingetragen, überschreibt also die Standardwerte hier.
local M = {
  ollama_url = "http://localhost:11434",
  completion_model = "qwen2.5-coder:3b", -- Inline-Vorschläge (muss FIM können)
  chat_model = "qwen3:8b", -- Chat und Agent
}

local ok, overrides = pcall(require, "config.ai_local")
if ok and type(overrides) == "table" then
  M = vim.tbl_extend("force", M, overrides)
end

return M
