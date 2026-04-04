param(
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Emit-Result {
    param(
        [bool]$CliAvailable,
        [bool]$ApiKeyAvailable,
        [string]$Mode,
        [string[]]$Notes
    )

    $result = [ordered]@{
        cli_available = $CliAvailable
        api_key_available = $ApiKeyAvailable
        recommended_mode = $Mode
        notes = $Notes
    }

    if ($Json) {
        $result | ConvertTo-Json -Depth 3
    } else {
        Write-Host ("cli_available      : {0}" -f $CliAvailable)
        Write-Host ("api_key_available  : {0}" -f $ApiKeyAvailable)
        Write-Host ("recommended_mode   : {0}" -f $Mode)
        if ($Notes.Count -gt 0) {
            Write-Host "notes:"
            foreach ($note in $Notes) {
                Write-Host ("- {0}" -f $note)
            }
        }
    }
}

$notes = New-Object System.Collections.Generic.List[string]

$cliCmd = Get-Command "modellix-cli" -ErrorAction SilentlyContinue
$cliAvailable = $null -ne $cliCmd
if (-not $cliAvailable) {
    $notes.Add("modellix-cli not found. Install with: npm install -g modellix-cli")
}

$apiKeyAvailable = -not [string]::IsNullOrWhiteSpace($env:MODELLIX_API_KEY)
if (-not $apiKeyAvailable) {
    $notes.Add("MODELLIX_API_KEY is not set. Configure it or pass --api-key per command.")
}

$mode = "rest"
if ($cliAvailable -and $apiKeyAvailable) {
    $mode = "cli"
    $notes.Add("CLI path is available. Use modellix-cli as primary path.")
} elseif ($apiKeyAvailable) {
    $notes.Add("REST fallback is available because API key exists.")
} else {
    $notes.Add("Neither CLI-auth nor REST-auth is ready. Configure API key first.")
}

Emit-Result -CliAvailable:$cliAvailable -ApiKeyAvailable:$apiKeyAvailable -Mode $mode -Notes $notes.ToArray()
