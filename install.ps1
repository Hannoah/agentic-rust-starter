# Run from the root of your Rust project. Never overwrites existing files.
# Usage: irm https://raw.githubusercontent.com/Hannoah/agentic-rust-starter/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'

$repo   = 'Hannoah/agentic-rust-starter'
$branch = 'main'
$files  = @('CONVENTIONS.md', '.aider.conf.yml', 'ai-verify.sh', 'clippy.toml', 'Cargo.toml', 'docs/ai_context/crate_cheatsheet.md')

$tmp = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $zip = Join-Path $tmp 'src.zip'
    Invoke-WebRequest "https://github.com/$repo/archive/refs/heads/$branch.zip" -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $tmp
    $root = (Get-ChildItem -Path $tmp -Directory | Select-Object -First 1).FullName

    foreach ($f in $files) {
        if (Test-Path $f) {
            Write-Host "skip (already exists): $f"
        } else {
            $dir = Split-Path $f -Parent
            if ($dir) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
            Copy-Item (Join-Path $root $f) $f
            Write-Host "added: $f"
        }
    }

    if ((Test-Path Cargo.toml) -and -not (Select-String -Path Cargo.toml -Pattern '^\[lints' -Quiet)) {
        Write-Host ""
        Write-Host "NOTE: your Cargo.toml has no [lints] section. Merge the [lints.rust] / [lints.clippy]"
        Write-Host "blocks from https://github.com/$repo#기존-프로젝트에-적용"
    }
    if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
        Write-Host ""
        Write-Host "NOTE: 'bash' is not on PATH. ai-verify.sh needs it (install Git for Windows)."
    }
    Write-Host "Done. Start with: aider"
} finally {
    Remove-Item -Recurse -Force $tmp
}
