$htmlDir = "..\article"
$files = Get-ChildItem "$htmlDir\*.html"

Write-Host "Deep cleaning encoding in $($files.Count) HTML files..."

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Encoding UTF8 -Raw
        $original = $content
        
        # Get hex representation to debug
        $originalBytes = [System.Text.Encoding]::UTF8.GetBytes($content)
        
        # Replace various problematic characters
        # Smart quotes
        $content = $content.Replace([char]0x201C, '"')  # left double
        $content = $content.Replace([char]0x201D, '"')  # right double
        $content = $content.Replace([char]0x2018, "'")  # left single
        $content = $content.Replace([char]0x2019, "'")  # right single
        
        # Dashes
        $content = $content.Replace([char]0x2013, '-')  # en dash
        $content = $content.Replace([char]0x2014, '-')  # em dash
        
        # Various problematic characters
        $content = $content.Replace([char]0xFFFD, ' ')  # replacement
        $content = $content.Replace([char]0x00AD, '')   # soft hyphen
        $content = $content.Replace([char]0x200B, '')   # zero width space
        $content = $content.Replace([char]0x200C, '')   # zero width non-joiner
        $content = $content.Replace([char]0x200D, '')   # zero width joiner
        $content = $content.Replace([char]0x2060, '')   # word joiner
        $content = $content.Replace([char]0xFEFF, '')   # zero width no-break space
        
        # &nbsp; and HTML entities
        $content = $content.Replace("&nbsp;", " ")
        $content = $content.Replace("&ndash;", "-")
        $content = $content.Replace("&mdash;", "-")
        
        # Replace actual replacement character bytes if any remain
        for ($i = 0; $i -lt 32; $i++) {
            if ($i -ne 9 -and $i -ne 10 -and $i -ne 13) {  # Keep tab, newline, carriage return
                $content = $content.Replace([char]$i, ' ')
            }
        }
        
        if ($content -ne $original) {
            Set-Content $file.FullName -Value $content -Encoding UTF8
            Write-Host "Fixed: $($file.Name)"
        }
    }
    catch {
        Write-Host "Error in $($file.Name): $_"
    }
}

Write-Host "Done!"
