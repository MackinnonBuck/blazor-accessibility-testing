function Update-StringInFile([string]$FilePath, [string]$Prefix, [string]$Suffix, [string]$NewString) {
    $Content = Get-Content -Path $FilePath -Raw
    $Pattern = [regex]::Escape($Prefix) + "[\S\s]*?" + [regex]::Escape($Suffix)
    $NewContent = [regex]::Replace($Content, $Pattern, $NewString)

    if ($Content -eq $NewContent) {
        throw "Replacement in file `"$FilePath`" had no effect (May not have found `"$Prefix`"...`"$Suffix`")"
    }

    Set-Content -Path $FilePath -Value $NewContent
}

function Update-ExactStringInFile([string]$FilePath, [string]$OldString, [string]$NewString) {
    $Content = Get-Content -Path $FilePath -Raw
    $NewContent = $Content -replace [regex]::Escape($OldString), $NewString

    if ($Content -eq $NewContent) {
        throw "Replacement in file `"$FilePath`" had no effect (May not have found `"$OldString`")"
    }

    Set-Content -Path $FilePath -Value $NewContent
}
