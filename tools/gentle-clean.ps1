$htmlDir = "..\article"
$files = Get-ChildItem "$htmlDir\*.html"

Write-Host "Gentle cleaning (preserves formatting)..."

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Encoding UTF8
        $original = $content
        $updated = $false
        
        # Replace smart quotes
        if ($content -like "*" + [char]0x201C + "*" -or $content -like "*" + [char]0x201D + "*") {
            $content = $content.Replace([char]0x201C, '"')
            $content = $content.Replace([char]0x201D, '"')
            $updated = $true
        }
        if ($content -like "*" + [char]0x2018 + "*" -or $content -like "*" + [char]0x2019 + "*") {
            $content = $content.Replace([char]0x2018, "'")
            $content = $content.Replace([char]0x2019, "'")
            $updated = $true
        }
        
        # Replace dashes
        if ($content -like "*" + [char]0x2013 + "*" -or $content -like "*" + [char]0x2014 + "*") {
            $content = $content.Replace([char]0x2013, '-')
            $content = $content.Replace([char]0x2014, '-')
            $updated = $true
        }
        
        # Replace soft hyphens and other control chars
        if ($content -like "*" + [char]0x00AD + "*" -or $content -like "*" + [char]0xFFFD + "*") {
            $content = $content.Replace([char]0x00AD, '')
            $content = $content.Replace([char]0xFFFD, '')
            $updated = $true
        }
        
        # Replace various spaces
        if ($content -like "*" + [char]0x00A0 + "*") {  # Non-breaking space
            $content = $content.Replace([char]0x00A0, ' ')
            $updated = $true
        }
        if ($content -contains "&nbsp;") {
            $content = $content.Replace("&nbsp;", " ")
            $updated = $true
        }
        
        if ($updated) {
            Set-Content $file.FullName -Value $content -Encoding UTF8
            Write-Host "Clean: $($file.Name)"
        }
    }
    catch {
        Write-Host "Error in $($file.Name): $_"
    }
}

Write-Host "Gentle cleanup complete!"
