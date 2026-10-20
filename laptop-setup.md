# Laptop Setup (no admin)

Run everything in **Windows PowerShell**, top to bottom, in one window. Open a new terminal at the end so PATH changes apply.
Config files live in `laptop-setup-parts/` next to this file. AI CLIs: see `claude-setup.md` and `codex-setup.md`.

```powershell
# Helper used below: add a folder to the *user* PATH (no admin)
function Add-UserPath($p) { $u = [Environment]::GetEnvironmentVariable('Path','User'); if (($u -split ';') -notcontains $p) { [Environment]::SetEnvironmentVariable('Path', "$u;$p", 'User') }; $env:Path += ";$p" }
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force   # lets npm.ps1 / npx.ps1 run
$W = '--scope','user','--source','winget','--accept-package-agreements','--accept-source-agreements'
```

---

## 1. Git + this repo

```powershell
winget install -e --id Git.Git @W
$env:Path += ";$env:LOCALAPPDATA\Programs\Git\cmd"
git clone <repo-url> "$env:USERPROFILE\<repo>"; cd "$env:USERPROFILE\<repo>"   # folder containing laptop-setup.md
$b = (Resolve-Path .\laptop-setup-parts).Path
Copy-Item "$b\.gitconfig" $env:USERPROFILE   # name/email
```

## 2. Oh My Posh + Nerd Fonts

```powershell
winget install -e --id JanDeDobbeleer.OhMyPosh @W
$env:Path += ";$env:LOCALAPPDATA\Microsoft\WindowsApps"
oh-my-posh font install Meslo --headless          # MesloLGSDZ Nerd Font Propo (used by Windows Terminal); installs per-user
oh-my-posh font install CascadiaCode --headless   # CaskaydiaCove Nerd Font
```

## 3. Clink (portable → `~\Tools\clink`) + oh-my-posh prompt

```powershell
$a = (Invoke-RestMethod https://api.github.com/repos/chrisant996/clink/releases/latest).assets | Where-Object name -match '^clink\.[\d.]+\.[0-9a-f]+\.zip$'
Invoke-WebRequest $a.browser_download_url -OutFile "$env:TEMP\clink.zip"
Expand-Archive "$env:TEMP\clink.zip" "$env:USERPROFILE\Tools\clink" -Force
Copy-Item "$b\oh-my-posh.lua" "$env:USERPROFILE\Tools\clink"   # jandedobbeleer theme
```

## 4. Doskey aliases (auto-load in every cmd)

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\cmd" | Out-Null
Copy-Item "$b\cmdrc.cmd" "$env:USERPROFILE\cmd"
reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "$env:USERPROFILE\cmd\cmdrc.cmd" /f
```

## 5. Windows Terminal → cmd + clink by default

Open Windows Terminal once first (creates `settings.json`). Then **either** restore the saved settings:

```powershell
Copy-Item "$b\settings.json" "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Force
```

**or** patch the fresh file:

```powershell
$f = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$j = Get-Content $f -Raw | ConvertFrom-Json
$cmd = '{0caa0dad-35be-5f56-a8ff-afceeeaa6101}'   # built-in "Command Prompt" profile
$j.defaultProfile = $cmd
$p = $j.profiles.list | Where-Object guid -eq $cmd
@{ commandline = '%SystemRoot%\System32\cmd.exe /k "%USERPROFILE%\Tools\clink\clink.bat" inject'
   font = @{ face = 'MesloLGSDZ Nerd Font Propo'; size = 11 }
   colorScheme = 'Tango Dark'; cursorShape = 'filledBox'; opacity = 80; useAcrylic = $false
}.GetEnumerator() | ForEach-Object { $p | Add-Member -Force $_.Key $_.Value }
$j | ConvertTo-Json -Depth 20 | Set-Content $f -Encoding utf8
```

## 6. Node / npm / npx (portable → `~\tools\node`)

```powershell
$v = ((Invoke-RestMethod https://nodejs.org/dist/index.json) | Where-Object { $_.version -like 'v22.*' } | Select-Object -First 1).version
Invoke-WebRequest "https://nodejs.org/dist/$v/node-$v-win-x64.zip" -OutFile "$env:TEMP\node.zip"
Expand-Archive "$env:TEMP\node.zip" "$env:USERPROFILE\tools\node" -Force
Add-UserPath "$env:USERPROFILE\tools\node\node-$v-win-x64"
```

## 7. uv (→ `~\.local\bin`)

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

## 8. lazygit, eza, fzf

```powershell
winget install -e --id JesseDuffield.lazygit @W
winget install -e --id eza-community.eza @W
winget install -e --id junegunn.fzf @W
# Optional, used by aliases: ffplay for `lockin`, plus bat
winget install -e --id Gyan.FFmpeg @W
winget install -e --id sharkdp.bat @W
```

## 9. tree

Built into Windows (`tree /f`). `tree2` / `tree3` aliases use eza (step 8).

## 10. herdr (default pane = cmd + clink)

```powershell
cmd /c "curl.exe -fsSLo %TEMP%\herdr-install.cmd https://herdr.dev/install.cmd && %TEMP%\herdr-install.cmd"
New-Item -ItemType Directory -Force "$env:APPDATA\herdr" | Out-Null
Copy-Item "$b\config.toml", "$b\cmd-clink.cmd" "$env:APPDATA\herdr"   # config.toml points default_shell at cmd-clink.cmd
```

---

## Refresh `laptop-setup-parts/` (on the current laptop, before committing)

```powershell
Copy-Item -Destination .\laptop-setup-parts -Path `
  "$env:USERPROFILE\cmd\cmdrc.cmd", `
  "$env:USERPROFILE\Tools\clink\oh-my-posh.lua", `
  "$env:APPDATA\herdr\config.toml", `
  "$env:APPDATA\herdr\cmd-clink.cmd", `
  "$env:USERPROFILE\.gitconfig", `
  "$env:USERPROFILE\.dbt\profiles.yml", `
  "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
```

## Verify (new terminal)

```powershell
'git','oh-my-posh','node','npm','npx','uv','lazygit','eza','fzf','herdr' | ForEach-Object { '{0,-11} {1}' -f $_, ((& $_ --version 2>&1) | Select-Object -First 1) }
& "$env:USERPROFILE\Tools\clink\clink_x64.exe" --version
```

Open Windows Terminal: you should see the oh-my-posh prompt; `cd` into a repo to check the git branch and status. Run `herdr config check` to validate herdr's config.
