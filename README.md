# nvim-jetbrains

Neovim im JetBrains-Look mit lokaler KI-Completion. Basis ist
[LazyVim](https://www.lazyvim.org); die KI läuft vollständig lokal über
[Ollama](https://ollama.com), es verlässt kein Code den Rechner.

| Baustein | Lösung |
|---|---|
| IDE-Grundgerüst (LSP, Tabs, Suche, Git, Terminal) | LazyVim |
| JetBrains-Farbschema (dunkel und hell) | jb.nvim |
| Projektbaum links | neo-tree |
| Debugger und Test-Runner | nvim-dap, neotest |
| Inline-Vorschläge (Ghost Text, Tab zum Annehmen) | minuet-ai.nvim + Ollama |
| Chat, Inline-Bearbeitung, Agent-Tools | codecompanion.nvim + Ollama |

## Installation

Voraussetzung auf macOS ist [Homebrew](https://brew.sh).

```bash
git clone https://github.com/WhisperN/nvim-jetbrains.git ~/nvim-jetbrains
cd ~/nvim-jetbrains
./install.sh
```

Das Skript erledigt Folgendes:

1. Installiert Neovim, die nötigen Werkzeuge, Ollama und die Schrift JetBrains Mono Nerd Font.
2. Sichert eine vorhandene `~/.config/nvim` als `nvim.backup-<datum>` und verlinkt stattdessen den Ordner `nvim/` aus diesem Repo.
3. Wählt die Modelle passend zum Arbeitsspeicher und schreibt sie nach `nvim/lua/config/ai_local.lua`.
4. Startet Ollama und lädt die Modelle herunter (mehrere GB).
5. Installiert alle Neovim-Plugins.

Das Repo muss an seinem Ort bleiben, weil `~/.config/nvim` darauf verlinkt.
Das Skript kann beliebig oft erneut ausgeführt werden. Mit `--no-packages`,
`--no-models` und `--no-sync` lassen sich einzelne Schritte überspringen.

Auf Linux verlinkt das Skript die Konfiguration und lädt die Modelle, die
Pakete müssen aber von Hand installiert werden.

### Nach der Installation: Terminal einstellen

Zwei Einstellungen im Terminal sind nötig, das Skript kann sie nicht setzen:

- **Schrift:** `JetBrainsMono Nerd Font`. Ohne sie fehlen die Icons.
- **Option-Taste als Alt/Meta**, damit Kürzel wie Alt+Enter ankommen.

Beispiel für Ghostty (`~/.config/ghostty/config`):

```
font-family = JetBrainsMono Nerd Font
macos-option-as-alt = true
```

In iTerm2: Settings → Profiles → Text (Schrift) und Profiles → Keys → Left
Option Key = `Esc+`.

Danach `nvim` starten. Beim ersten Öffnen einer Datei installiert Mason die
passenden Language Server im Hintergrund.

## Auf GitHub ablegen

```bash
cd ~/nvim-jetbrains
git init -b main
git add .
git commit -m "Neovim JetBrains setup"
gh repo create nvim-jetbrains --private --source=. --push
```

Ohne GitHub CLI: Repo auf github.com anlegen, dann
`git remote add origin <url>` und `git push -u origin main`.

`nvim/lazy-lock.json` gehört ins Repo. Die Datei hält die Plugin-Versionen
fest, damit jeder Rechner denselben Stand bekommt. Nach einem Plugin-Update
(`:Lazy update`) die geänderte Datei committen.

## Lokale KI

| Arbeitsspeicher | Completion | Chat / Agent |
|---|---|---|
| unter 16 GB | qwen2.5-coder:1.5b | qwen3:4b |
| 16–31 GB | qwen2.5-coder:3b | qwen3:8b |
| 32–47 GB | qwen2.5-coder:7b | qwen3:14b |
| ab 48 GB | qwen2.5-coder:7b | qwen3-coder:30b |

Andere Modelle: mit `ollama pull <modell>` laden und in
`nvim/lua/config/ai_local.lua` eintragen. Das Completion-Modell muss
Fill-in-the-Middle unterstützen (z. B. qwen2.5-coder, codegemma, starcoder2).

**Inline-Vorschläge** erscheinen beim Tippen als grauer Text.

| Taste | Aktion |
|---|---|
| Tab oder Alt+L | Vorschlag annehmen |
| Alt+J | nur eine Zeile annehmen |
| Alt+] / Alt+[ | nächster / vorheriger Vorschlag, auch manuelles Auslösen |
| Alt+E | Vorschlag verwerfen |

**Chat und Agent** (Leader ist die Leertaste):

| Taste | Aktion |
|---|---|
| Leader a a | Chat ein-/ausblenden |
| Leader a p | Aktionsmenü |
| Leader a i | Inline-Bearbeitung per Prompt (auch auf Auswahl) |
| Leader a s | Auswahl in den Chat übernehmen |

Im Chat fügt `#{buffer}` die aktuelle Datei hinzu, `@{...}` gibt dem Modell
Werkzeuge (Dateien lesen und ändern, Befehle ausführen); die verfügbaren
Namen schlägt die Completion nach `@` vor. Kleine lokale Modelle nutzen
Werkzeuge deutlich unzuverlässiger als grosse Cloud-Modelle.

## Tastenkürzel

JetBrains-ähnliche Kürzel aus `nvim/lua/config/keymaps.lua`:

| Taste | Aktion |
|---|---|
| Alt+Enter | Quick-Fix / Code Action |
| Shift+F6 | Umbenennen |
| F2 / Shift+F2 | nächster / vorheriger Fehler |
| Ctrl+E | Recent Files |
| Alt+1 | Projektbaum ein-/ausblenden |

Die wichtigsten LazyVim-Kürzel:

| Taste | Aktion |
|---|---|
| Leader Leader | Datei suchen (wie Shift+Shift) |
| Leader / | im Projekt suchen (wie Find in Path) |
| g d / g r | zur Definition / Verwendungen |
| K | Dokumentation |
| Shift+H / Shift+L | Tab links / rechts |
| Ctrl+/ | Terminal |
| Leader g g | Git (lazygit) |
| Leader c f | Formatieren |

Leader drücken und warten zeigt alle verfügbaren Kürzel an. Cmd-Kürzel und
Shift+Shift lassen sich im Terminal nicht abbilden.

## Anpassen

| Was | Wo |
|---|---|
| Sprachen ein-/ausschalten | `nvim/lua/config/lazy.lua` |
| Helles Theme | `nvim/lua/config/options.lua` (`background = "light"`) |
| KI-Modelle, Ollama-URL | `nvim/lua/config/ai_local.lua` (lokal) oder `ai.lua` (für alle Rechner) |
| Tastenkürzel | `nvim/lua/config/keymaps.lua` |
| Weitere Plugins | neue Datei in `nvim/lua/plugins/` |

## Fehlersuche

- `:checkhealth` prüft Neovim und die Plugins.
- Keine Vorschläge: `ollama list` muss das Completion-Modell zeigen und
  `curl http://localhost:11434/api/version` muss antworten. Sonst
  `brew services start ollama`.
- Vorschläge zu langsam: kleineres Modell wählen oder `context_window` in
  `nvim/lua/plugins/ai.lua` verkleinern.
- Zurück zur alten Konfiguration: `rm ~/.config/nvim` (nur der Link) und das
  Backup zurück nach `~/.config/nvim` verschieben.
