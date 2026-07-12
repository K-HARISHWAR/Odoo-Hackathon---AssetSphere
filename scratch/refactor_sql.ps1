$sqlFiles = Get-ChildItem -Path "database\sql" -Filter "*.sql"
foreach ($file in $sqlFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content

    # Fix Triggers
    $content = [regex]::Replace($content, '(?i)create trigger (\w+)\s+(before|after)\s+([^\n]+)\s+on\s+([a-zA-Z0-9_.]+)', {
        param($match)
        "drop trigger if exists $($match.Groups[1].Value) on $($match.Groups[4].Value);`ncreate trigger $($match.Groups[1].Value)`n$($match.Groups[2].Value) $($match.Groups[3].Value) on $($match.Groups[4].Value)"
    })

    # Fix Policies
    $content = [regex]::Replace($content, '(?i)create policy "([^"]+)" on ([a-zA-Z0-9_.]+)', {
        param($match)
        "drop policy if exists `"$($match.Groups[1].Value)`" on $($match.Groups[2].Value);`ncreate policy `"$($match.Groups[1].Value)`" on $($match.Groups[2].Value)"
    })

    # Fix Constraints (drop before add)
    $content = [regex]::Replace($content, '(?i)alter table ([a-zA-Z0-9_.]+)\s+add constraint (\w+)', {
        param($match)
        "alter table $($match.Groups[1].Value) drop constraint if exists $($match.Groups[2].Value);`nalter table $($match.Groups[1].Value)`nadd constraint $($match.Groups[2].Value)"
    })

    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Updated $($file.Name)"
    }
}
