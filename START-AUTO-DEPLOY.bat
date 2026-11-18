@echo off
echo Starting S2S Fit Landing Page Auto-Watcher...
powershell -ExecutionPolicy Bypass -File "%~dp0watch-landing-page.ps1"
pause
