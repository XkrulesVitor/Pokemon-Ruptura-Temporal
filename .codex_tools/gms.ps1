$env:LOCALAPPDATA = Join-Path $PSScriptRoot "localappdata"
& (Join-Path $PSScriptRoot "node_modules\.bin\gm-cli.cmd") @args
exit $LASTEXITCODE
