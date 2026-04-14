$htmlDir = "..\article"
$files = Get-ChildItem "$htmlDir\*.html"

Write-Host "Aggressive cleaning..."

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Encoding UTF8 -Raw
        $original = $content
        
        # Remove all non-ASCII printable characters except common HTML entities
        $cleaned = ""
        for ($i = 0; $i -lt $content.Length; $i++) {
            $char = $content[$i]
            $code = [int][char]$char
            
            # Keep ASCII printable range (32-126), plus standard whitespace (9=tab, 10=LF, 13=CR)
            # Plus common accented chars and special punctuation in Latin range
            if (($code -ge 32 -and $code -le 126) -or $code -eq 9 -or $code -eq 10 -or $code -eq 13 -or ($code -ge 192 -and $code -le 255)) {
                $cleaned += $char
            }
            elseif ($code -lt 32) {
                # Replace control characters with space (except tab, LF, CR)
                if ($code -eq 9 -or $code -eq 10 -or $code -eq 13) {
                    $cleaned += $char
                } else {
                    $cleaned += " "
                }
            }
            else {
                # Replace other Unicode with space
                $cleaned += " "
            }
        }
        
        # Final pass to clean up HTML entities
        $cleaned = $cleaned.Replace("&quot;", '"')
        $cleaned = $cleaned.Replace("&apos;", "'")
        
        # Clean up extra spaces
        $cleaned = $cleaned -replace '\s+', ' '
        $cleaned = $cleaned -replace '>\s+<', '><'
        
        if ($cleaned -ne $original) {
            Set-Content $file.FullName -Value $cleaned -Encoding UTF8
            Write-Host "Deep fixed: $($file.Name)"
        }
    }
    catch {
        Write-Host "Error in $($file.Name): $_"
    }
}

Write-Host "Aggressive cleanup complete!"
