@echo off
rem herdr default_shell wrapper: same startup as the Windows Terminal "Command Prompt" profile.
rem herdr's default_shell takes an executable only (no args), so this launches cmd + clink for it.
"%SystemRoot%\System32\cmd.exe" /k ""%USERPROFILE%\Tools\clink\clink.bat" inject"
