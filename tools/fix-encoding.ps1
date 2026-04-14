$htmlDir = "..\article"
$files = Get-ChildItem "$htmlDir\*.html" -Exclude "*-f.html"

Write-Host "Cleaning encoding in $($files.Count) HTML files..."

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Encoding UTF8 -Raw
        $original = $content
        
        # Replace smart quotes
        $content = $content.Replace([char]0x201C, [char]0x0022)  # left double -> "
        $content = $content.Replace([char]0x201D, [char]0x0022)  # right double -> "
        $content = $content.Replace([char]0x2018, [char]0x0027)  # left single -> '
        $content = $content.Replace([char]0x2019, [char]0x0027)  # right single -> '
        
        # Replace dashes
        $content = $content.Replace([char]0x2013, [char]0x002D)  # en dash -> -
        $content = $content.Replace([char]0x2014, [char]0x002D)  # em dash -> -
        
        # Replace replacement character
        $content = $content.Replace([char]0xFFFD, [char]0x0020)  # FFFD -> space
        
        # Replace &nbsp;
        $content = $content.Replace("&nbsp;", " ")
        
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
