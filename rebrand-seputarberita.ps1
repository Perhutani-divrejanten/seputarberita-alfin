# ============================================================================
# Rebranding Script: Warta Janten -> Seputar Berita
# ============================================================================

param([string]$WorkspacePath = (Get-Location).Path, [switch]$DryRun = $false)

$Timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$LogFile = Join-Path $WorkspacePath "rebrand-$Timestamp.log"

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $LogMessage = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage -Encoding UTF8
    $Color = @{'INFO'='White'; 'SUCCESS'='Green'; 'WARNING'='Yellow'; 'ERROR'='Red'}
    Write-Host $LogMessage -ForegroundColor $Color[$Level]
}

function Replace-FileContent {
    param([string]$FilePath, [string]$OldValue, [string]$NewValue, [string]$Description)
    
    if (-not (Test-Path $FilePath)) { return $false }
    try {
        $Content = Get-Content -Path $FilePath -Raw -Encoding UTF8
        if ($Content.Contains($OldValue)) {
            $Content = $Content.Replace($OldValue, $NewValue)
            if (-not $DryRun) {
                Set-Content -Path $FilePath -Value $Content -Encoding UTF8 -Force
            }
            Write-Log "Updated: $(Split-Path -Leaf $FilePath) - $Description" -Level SUCCESS
            return $true
        }
    } catch {
        Write-Log "Error in $(Split-Path -Leaf $FilePath): $_" -Level ERROR
    }
    return $false
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  REBRANDING: Warta Janten -> Seputar Berita" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Log "Starting rebranding process..." -Level INFO
Write-Log "Workspace: $WorkspacePath" -Level INFO

$Stats = @{MainPages = 0; Articles = 0; Css = 0; Package = 0; Docs = 0; Backups = 0}

# STEP 1: Backup articles.json
Write-Host "`n--- Backup articles.json ---" -ForegroundColor Cyan
$ArticlesJson = Join-Path $WorkspacePath "articles.json"
if (Test-Path $ArticlesJson) {
    $BackupPath = "$ArticlesJson.bak.$Timestamp"
    if (-not $DryRun) { Copy-Item -Path $ArticlesJson -Destination $BackupPath -Force }
    Write-Log "Backup: $(Split-Path -Leaf $BackupPath)" -Level SUCCESS
    $Stats['Backups']++
}

# STEP 2: Process HTML Main Pages
Write-Host "`n--- Main HTML Pages ---" -ForegroundColor Cyan
$MainPages = @('index.html', 'news.html', 'contact.html', 'search.html', 'login.html', 'register.html', 'testauth.html')

foreach ($Page in $MainPages) {
    $PagePath = Join-Path $WorkspacePath $Page
    if (Test-Path $PagePath) {
        if (Replace-FileContent $PagePath "Warta Janten" "Seputar Berita" "Brand") { $Stats['MainPages']++ }
        Replace-FileContent $PagePath "WartaJanten" "SeputarBerita" "Brand"
        Replace-FileContent $PagePath "wartajanten" "seputarberita" "Brand"
        Replace-FileContent $PagePath "info@wartajanten.com" "seputarberita@gmail.com" "Email"
        Replace-FileContent $PagePath "instagram.com/wartajanten" "instagram.com/seputarberita" "Social"
        Replace-FileContent $PagePath "twitter.com/wartajanten" "twitter.com/seputarberita" "Social"
        Replace-FileContent $PagePath "facebook.com/wartajanten" "facebook.com/seputarberita" "Social"
        Replace-FileContent $PagePath "- Warta Janten" "- Seputar Berita" "Title"
    }
}

# STEP 3: Process Article HTML Files
Write-Host "`n--- Article HTML Files ---" -ForegroundColor Cyan
$ArticleFolder = Join-Path $WorkspacePath "article"
if (Test-Path $ArticleFolder) {
    $Articles = @(Get-ChildItem -Path $ArticleFolder -Filter "*.html")
    Write-Log "Processing $($Articles.Count) article files..." -Level INFO
    
    foreach ($Article in $Articles) {
        if (Replace-FileContent $Article.FullName "Warta Janten" "Seputar Berita" "Brand") {
            $Stats['Articles']++
        }
        Replace-FileContent $Article.FullName "wartajanten" "seputarberita" "Brand"
        Replace-FileContent $Article.FullName "info@wartajanten.com" "seputarberita@gmail.com" "Email"
        Replace-FileContent $Article.FullName "- Warta Janten" "- Seputar Berita" "Title"
    }
}

# STEP 4: Update CSS with New Colors
Write-Host "`n--- CSS Color Theme Update ---" -ForegroundColor Cyan
$CssFiles = @(Get-ChildItem -Path $WorkspacePath -Recurse -Filter "*.css")

foreach ($CssFile in $CssFiles) {
    if (Replace-FileContent $CssFile.FullName "#065F46" "#9333EA" "Primary") { $Stats['Css']++ }
    Replace-FileContent $CssFile.FullName "#022C22" "#4C1D95" "Dark"
    Replace-FileContent $CssFile.FullName "#1E3A5F" "#5F1F7F" "Secondary"
    Replace-FileContent $CssFile.FullName "Warta Janten" "Seputar Berita" "Brand"
    Replace-FileContent $CssFile.FullName "wartajanten" "seputarberita" "Brand"
}

# STEP 5: Update package.json Files
Write-Host "`n--- Package JSON Files ---" -ForegroundColor Cyan
$PackageFiles = @(
    (Join-Path -Path $WorkspacePath -ChildPath "package.json"),
    (Join-Path -Path $WorkspacePath -ChildPath "tools" -ChildPath "package.json")
)

foreach ($PkgFile in $PackageFiles) {
    if (Test-Path $PkgFile) {
        if (Replace-FileContent $PkgFile '"name": "wartajanten"' '"name": "seputarberita"' "Name") {
            $Stats['Package']++
        }
        Replace-FileContent $PkgFile "Warta Janten" "Seputar Berita" "Brand"
        Replace-FileContent $PkgFile "wartajanten" "seputarberita" "Brand"
    }
}

# STEP 6: Update Documentation Files
Write-Host "`n--- Documentation Files ---" -ForegroundColor Cyan
$DocFiles = @(
    'AUTOMATION_README.md',
    'GOOGLE_DRIVE_GUIDE.md',
    'TROUBLESHOOTING.md',
    'PERBAIKAN_STATUS.md',
    'REBRAND_SUMMARY.txt',
    'README.md'
)

foreach ($DocFile in $DocFiles) {
    $DocPath = Join-Path $WorkspacePath $DocFile
    if (Test-Path $DocPath) {
        if (Replace-FileContent $DocPath "Warta Janten" "Seputar Berita" "Brand") {
            $Stats['Docs']++
        }
        Replace-FileContent $DocPath "wartajanten" "seputarberita" "Brand"
    }
}

# STEP 7: Configuration Files
Write-Host "`n--- Configuration Files ---" -ForegroundColor Cyan
$ConfigFiles = @('netlify.toml', 'deploy-to-cpanel.yml')
foreach ($ConfigFile in $ConfigFiles) {
    $ConfigPath = Join-Path $WorkspacePath $ConfigFile
    if (Test-Path $ConfigPath) {
        Replace-FileContent $ConfigPath "Warta Janten" "Seputar Berita" "Config"
        Replace-FileContent $ConfigPath "wartajanten" "seputarberita" "Config"
    }
}

# STEP 8: Verification
Write-Host "`n--- Verification ---" -ForegroundColor Cyan

$SearchTerms = @('Warta Janten', 'WartaJanten', 'wartajanten')
$RemainingCount = 0

foreach ($Term in $SearchTerms) {
    $Matches = @(Get-ChildItem -Path $WorkspacePath -Recurse -Include "*.html", "*.css", "*.json", "*.md" -ErrorAction SilentlyContinue | 
        Select-String -Pattern ([regex]::Escape($Term)) -ErrorAction SilentlyContinue)
    if ($Matches.Count -gt 0) {
        Write-Log "$Term found in $($Matches.Count) location(s)" -Level WARNING
        $RemainingCount += $Matches.Count
    }
}

if ($RemainingCount -eq 0) {
    Write-Log "All old brand names successfully removed!" -Level SUCCESS
}

# FINAL REPORT
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  REBRANDING SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Files Updated:" -ForegroundColor Yellow
Write-Host "  Main pages:     $($Stats['MainPages'])" -ForegroundColor White
Write-Host "  Articles:       $($Stats['Articles'])" -ForegroundColor White
Write-Host "  CSS files:      $($Stats['Css'])" -ForegroundColor White
Write-Host "  Package files:  $($Stats['Package'])" -ForegroundColor White
Write-Host "  Doc files:      $($Stats['Docs'])" -ForegroundColor White
Write-Host "  Backups:        $($Stats['Backups'])" -ForegroundColor White

Write-Host "`nRebranding Status:                        [OK]" -ForegroundColor Green

if (-not $DryRun) {
    Write-Host "`nRebrand Seputar Berita selesai [OK]`n" -ForegroundColor Green
} else {
    Write-Host "`n[DRY RUN] No files modified.`n" -ForegroundColor Yellow
}

Write-Log "Rebranding completed successfully!" -Level SUCCESS
