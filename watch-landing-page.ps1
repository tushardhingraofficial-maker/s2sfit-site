# ============================================================
#  S2S FIT — Auto-Watcher for Landing Page
#  Monitors the working copy and auto-deploys every time you save.
#  Run once; leave the window open in the background.
#  Close the window to stop watching.
# ============================================================

$srcFile = "C:\Users\taar7\Downloads\s2sfit-landing-v1-updated_3.html"
$srcDir  = Split-Path $srcFile
$srcName = Split-Path $srcFile -Leaf
$deployScript = "$PSScriptRoot\deploy-landing-page.ps1"

Write-Host "=== S2S Fit Landing Page Auto-Watcher ===" -ForegroundColor Cyan
Write-Host "Watching: $srcFile" -ForegroundColor White
Write-Host "Will auto-deploy to Netlify on every save." -ForegroundColor White
Write-Host "Close this window to stop.`n" -ForegroundColor Gray

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path   = $srcDir
$watcher.Filter = $srcName
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite
$watcher.EnableRaisingEvents = $true

$lastDeploy = [datetime]::MinValue

while ($true) {
    $result = $watcher.WaitForChanged([System.IO.WatcherChangeTypes]::Changed, 2000)
    if (-not $result.TimedOut) {
        $now = Get-Date
        # Debounce: skip if deployed within last 10 seconds
        if (($now - $lastDeploy).TotalSeconds -gt 10) {
            $lastDeploy = $now
            Write-Host "`n[$($now.ToString('HH:mm:ss'))] Change detected — deploying..." -ForegroundColor Yellow
            # Run deploy in same process (shows output here)
            & $deployScript
        }
    }
}
