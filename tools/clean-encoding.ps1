# Clean encoding issues in all HTML files
# Fixes: smart quotes, dashes, replacement characters, and nbsp

$htmlDir = "..\article"
$files = Get-ChildItem "$htmlDir\*.html" -Exclude "*-f.html"

Write-Host "🔧 Cleaning encoding in $($files.Count) HTML files..."

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Encoding UTF8 -Raw
        $original = $content
        
        # Replace smart quotes with straight quotes
        $content = $content.Replace([char]0x201C, '"')  # left double quote
        $content = $content.Replace([char]0x201D, '"')  # right double quote
        $content = $content.Replace([char]0x2018, "'")  # left single quote
        $content = $content.Replace([char]0x2019, "'")  # right single quote
        $content = $content.Replace([char]0x2033, '"')  # double prime
        
        # Replace dashes
        $content = $content.Replace([char]0x2013, '-')  # en dash
        $content = $content.Replace([char]0x2014, '-')  # em dash
        $content = $content.Replace([char]0x2010, '-')  # hyphen
        
        # Replace replacement character (U+FFFD)
        $content = $content.Replace([char]0xFFFD, ' ')
        
        # Replace &nbsp; with regular space
        $content = $content.Replace("&nbsp;", " ")
        
        if ($content -ne $original) {
            Set-Content $file.FullName -Value $content -Encoding UTF8
            Write-Host "✅ Fixed: $($file.Name)"
        }
        else {
            Write-Host "⏭️  No changes needed: $($file.Name)"
        }
    }
    catch {
        Write-Host "❌ Error processing $($file.Name): $_"
    }
}

Write-Host "`n✨ Encoding cleanup complete!"
