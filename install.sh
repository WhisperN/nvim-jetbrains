#!/usr/bin/env bash
# Installiert das Neovim-JetBrains-Setup auf diesem Rechner.
#
#   ./install.sh                 alles installieren
#   ./install.sh --no-packages   keine Pakete über Homebrew installieren
#   ./install.sh --no-models     keine Ollama-Modelle herunterladen
#   ./install.sh --no-sync       Plugins nicht vorab installieren
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_SRC="$REPO_DIR/nvim"
NVIM_DST="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

PACKAGES=1 MODELS=1 SYNC=1
for arg in "$@"; do
  case "$arg" in
    --no-packages) PACKAGES=0 ;;
    --no-models) MODELS=0 ;;
    --no-sync) SYNC=0 ;;
    -h | --help) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unbekannte Option: $arg" >&2; exit 1 ;;
  esac
done

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mHinweis:\033[0m %s\n' "$*"; }

# 1. Pakete -------------------------------------------------------------------
if [ "$PACKAGES" = 1 ]; then
  if [ "$(uname -s)" = "Darwin" ]; then
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew fehlt. Bitte zuerst installieren: https://brew.sh" >&2
      exit 1
    fi
    info "Installiere Pakete mit Homebrew"
    brew install neovim git ripgrep fd lazygit node tree-sitter-cli ollama
    brew install --cask font-jetbrains-mono-nerd-font
  else
    warn "Automatische Paketinstallation gibt es nur für macOS."
    warn "Bitte selbst installieren: neovim (>= 0.11), git, ripgrep, fd, lazygit, node, tree-sitter-cli, C-Compiler, ollama, JetBrainsMono Nerd Font"
  fi
fi

# 2. Konfiguration verlinken ---------------------------------------------------
if [ "$(readlink "$NVIM_DST" 2>/dev/null || true)" = "$NVIM_SRC" ]; then
  info "Konfiguration ist bereits verlinkt: $NVIM_DST"
else
  if [ -e "$NVIM_DST" ] || [ -L "$NVIM_DST" ]; then
    backup="$NVIM_DST.backup-$(date +%Y%m%d-%H%M%S)"
    info "Sichere bestehende Konfiguration nach $backup"
    mv "$NVIM_DST" "$backup"
  fi
  mkdir -p "$(dirname "$NVIM_DST")"
  ln -s "$NVIM_SRC" "$NVIM_DST"
  info "Verlinkt: $NVIM_DST -> $NVIM_SRC"
fi

# 3. Modelle passend zum Arbeitsspeicher wählen -------------------------------
if [ "$(uname -s)" = "Darwin" ]; then
  ram_gb=$(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024))
else
  ram_gb=$(awk '/MemTotal/ {printf "%d", ($2 + 524288) / 1048576}' /proc/meminfo)
fi

if [ "$ram_gb" -ge 48 ]; then
  completion_model="qwen2.5-coder:7b" chat_model="qwen3-coder:30b"
elif [ "$ram_gb" -ge 32 ]; then
  completion_model="qwen2.5-coder:7b" chat_model="qwen3:14b"
elif [ "$ram_gb" -ge 16 ]; then
  completion_model="qwen2.5-coder:3b" chat_model="qwen3:8b"
else
  completion_model="qwen2.5-coder:1.5b" chat_model="qwen3:4b"
fi

AI_LOCAL="$NVIM_SRC/lua/config/ai_local.lua"
if [ -f "$AI_LOCAL" ]; then
  info "Behalte vorhandene $AI_LOCAL"
  completion_model=$(sed -n 's/.*completion_model *= *"\(.*\)".*/\1/p' "$AI_LOCAL")
  chat_model=$(sed -n 's/.*chat_model *= *"\(.*\)".*/\1/p' "$AI_LOCAL")
else
  info "Arbeitsspeicher: ${ram_gb} GB -> Completion: $completion_model, Chat: $chat_model"
  cat >"$AI_LOCAL" <<LUA
-- Von install.sh erzeugt (${ram_gb} GB RAM). Nicht im Git; frei anpassbar.
return {
  completion_model = "$completion_model",
  chat_model = "$chat_model",
}
LUA
fi

# 4. Ollama starten und Modelle laden -----------------------------------------
if [ "$MODELS" = 1 ]; then
  if ! command -v ollama >/dev/null 2>&1; then
    warn "ollama nicht gefunden, Modelle werden übersprungen."
  else
    if ! curl -fsS http://localhost:11434/api/version >/dev/null 2>&1; then
      info "Starte Ollama"
      if command -v brew >/dev/null 2>&1; then
        brew services start ollama
      else
        (nohup ollama serve >/dev/null 2>&1 &)
      fi
      for _ in $(seq 1 30); do
        curl -fsS http://localhost:11434/api/version >/dev/null 2>&1 && break
        sleep 1
      done
    fi
    for model in $completion_model $chat_model; do
      info "Lade Modell $model"
      ollama pull "$model"
    done
  fi
fi

# 5. Plugins vorab installieren -------------------------------------------------
if [ "$SYNC" = 1 ] && command -v nvim >/dev/null 2>&1; then
  info "Installiere Neovim-Plugins (dauert beim ersten Mal ein paar Minuten)"
  nvim --headless "+Lazy! sync" +qa
  echo
fi

info "Fertig. Im Terminal die Schrift 'JetBrainsMono Nerd Font' einstellen und 'nvim' starten."
