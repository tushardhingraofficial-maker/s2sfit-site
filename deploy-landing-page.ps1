# ============================================================
#  S2S FIT — Deploy Landing Page
#  Double-click (or run in PowerShell) to push latest changes live.
#  Source: C:\Users\taar7\Downloads\s2sfit-landing-v1-updated_3.html
#  Live URL: https://s2sfit-sections.netlify.app/sections/landing-page.html
# ============================================================

$ErrorActionPreference = "Stop"
$repoRoot   = "$PSScriptRoot"
$srcFile    = "C:\Users\taar7\Downloads\s2sfit-landing-v1-updated_3.html"
$destFile   = "$repoRoot\highlevel\sections\landing-page.html"
$liveUrl    = "https://s2sfit-sections.netlify.app/sections/landing-page.html"

Write-Host "`n=== S2S Fit Landing Page Deploy ===" -ForegroundColor Cyan

# 1. Pull latest from GitHub first
Write-Host "`n[1/5] Pulling latest from GitHub..." -ForegroundColor Yellow
Set-Location $repoRoot
git pull origin main

# 2. Copy working copy into repo
Write-Host "`n[2/5] Copying landing page into repo..." -ForegroundColor Yellow
Copy-Item $srcFile $destFile -Force

# 3. Bump version string (date + incremental letter)
Write-Host "`n[3/5] Bumping version..." -ForegroundColor Yellow
$today   = (Get-Date).ToString("yyyy-MM-dd")
$content = [System.IO.File]::ReadAllText($destFile, [System.Text.Encoding]::UTF8)

# Find current version
$match = [regex]::Match($content, 'data-version="v([\d-]+)([a-z])"')
if ($match.Success) {
    $curDate   = $match.Groups[1].Value
    $curLetter = $match.Groups[2].Value
    if ($curDate -eq $today) {
        $newLetter = [char]([int][char]$curLetter + 1)
    } else {
        $newLetter = "a"
    }
} else {
    $newLetter = "a"
}
$newVersion = "v$today$newLetter"
$content = $content -replace 'data-version="v[^"]*"', "data-version=`"$newVersion`""
[System.IO.File]::WriteAllText($destFile, $content, [System.Text.Encoding]::UTF8)
Write-Host "   Version: $newVersion" -ForegroundColor Green

# 4. Commit and push
Write-Host "`n[4/5] Committing and pushing..." -ForegroundColor Yellow
git add "highlevel/sections/landing-page.html"
git commit -m "Landing page: deploy $newVersion

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
git push origin main

# 5. Done
Write-Host "`n[5/5] Verifying live URL (~30s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 35
try {
    $resp = Invoke-WebRequest -Uri $liveUrl -Method Head -UseBasicParsing -TimeoutSec 10
    if ($resp.StatusCode -eq 200) {
        Write-Host "`n✓ LIVE at $liveUrl" -ForegroundColor Green
        Write-Host "  Version: $newVersion  |  Ctrl+Shift+R to see changes" -ForegroundColor Green
    }
} catch {
    Write-Host "`n? URL check failed — Netlify may still be building. Check manually in 30s." -ForegroundColor Yellow
}

Write-Host "`nPress any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
