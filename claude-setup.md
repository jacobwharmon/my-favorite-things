# Claude Code Setup (no admin)

Supplement to `laptop-setup.md`. Run that first (Git, Node, uv), then open a new **Windows PowerShell** in the repo folder:

```powershell
$b = (Resolve-Path .\laptop-setup-parts).Path
```

---

## 1. Claude Code CLI (→ `~\.local\bin`)

```powershell
irm https://claude.ai/install.ps1 | iex
claude   # first run: log in via the browser, then /exit
```

## 2. Preferences

```powershell
@'
{
  "theme": "dark-ansi",
  "autoUpdatesChannel": "latest",
  "modelSettings": { "claude-opus-5-5": { "effortLevel": "high" } }
}
'@ | Set-Content "$env:USERPROFILE\.claude\settings.json" -Encoding ascii
```

## 3. context-mode (plugin: MCP tools + hooks)

```powershell
claude plugin marketplace add mksglu/context-mode
claude plugin install context-mode@context-mode
```

Check: start `claude`, then run `/context-mode:ctx-doctor`.

## 4. dbt-mcp

```powershell
# dbt project + venv (dbt-snowflake). uv downloads Python 3.13 if it's missing
git clone https://github.com/bps-edm-operations/powerbi-dbt.git "$env:USERPROFILE\powerbi-dbt"
uv sync --directory "$env:USERPROFILE\powerbi-dbt"

# Snowflake profile (externalbrowser auth)
New-Item -ItemType Directory -Force "$env:USERPROFILE\.dbt" | Out-Null
Copy-Item "$b\profiles.yml" "$env:USERPROFILE\.dbt"

claude mcp add dbt --scope user `
  -e "DBT_PROJECT_DIR=$env:USERPROFILE\powerbi-dbt\powerbi_dbt" `
  -e "DBT_PATH=$env:USERPROFILE\powerbi-dbt\.venv\Scripts\dbt.exe" `
  -e "DBT_PROFILES_DIR=$env:USERPROFILE\.dbt" `
  -- uvx dbt-mcp@latest
```

Check: `claude mcp list` should show `dbt` as connected.
