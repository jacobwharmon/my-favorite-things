# Codex CLI Setup (no admin)

Supplement to `laptop-setup.md`. Run that first (Git, Node, uv), then open a new **Windows PowerShell** in the repo folder:

```powershell
$b = (Resolve-Path .\laptop-setup-parts).Path
```

---

## 1. Codex CLI (global npm package → portable Node folder)

```powershell
npm install -g @openai/codex
```

## 2. Config (fresh laptop: writes `~\.codex\config.toml`)

Includes the context-mode hook flags and dbt-mcp.

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.codex" | Out-Null
@"
model = "gpt-6-sol"
model_reasoning_effort = "xhigh"
plan_mode_reasoning_effort = "xhigh"
approvals_reviewer = "auto_review"

[windows]
sandbox = "unelevated"

[features]
plugin_hooks = true
hooks = true

[tui]
theme = "monokai-extended-light"

[mcp_servers.dbt]
command = "uvx"
args = ["dbt-mcp@latest"]
startup_timeout_sec = 90.0

[mcp_servers.dbt.env]
DBT_PROJECT_DIR = '$env:USERPROFILE\powerbi-dbt\powerbi_dbt'
DBT_PATH = '$env:USERPROFILE\powerbi-dbt\.venv\Scripts\dbt.exe'
DBT_PROFILES_DIR = '$env:USERPROFILE\.dbt'
"@ | Set-Content "$env:USERPROFILE\.codex\config.toml" -Encoding ascii
```

## 3. Log in

```powershell
codex login   # browser sign-in
```

## 4. context-mode (plugin: MCP tools + hooks)

```powershell
codex plugin marketplace add mksglu/context-mode
codex plugin add context-mode@context-mode
```

Start `codex` and approve the context-mode hooks when prompted. Check: type `ctx stats`.

## 5. dbt-mcp (project, venv, profile)

```powershell
# dbt project + venv (dbt-snowflake). uv downloads Python 3.13 if it's missing
git clone https://github.com/bps-edm-operations/powerbi-dbt.git "$env:USERPROFILE\powerbi-dbt"
uv sync --directory "$env:USERPROFILE\powerbi-dbt"

# Snowflake profile (externalbrowser auth)
New-Item -ItemType Directory -Force "$env:USERPROFILE\.dbt" | Out-Null
Copy-Item "$b\profiles.yml" "$env:USERPROFILE\.dbt"
```

The MCP server entry is already in `config.toml` (step 2). Check: `codex mcp list`.
