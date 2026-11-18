# Compila e roda o jogo em modo autoteste: ele percorre as telas sozinho,
# salva screenshots e um log.txt na pasta de saida e fecha no final.
# Uso:  powershell -ExecutionPolicy Bypass -File tools\autoteste.ps1 [pasta_de_saida]
param([string]$Saida = "")

$raiz = Split-Path -Parent $PSScriptRoot
if ($Saida -eq "") { $Saida = Join-Path $raiz "autoteste_saida" }
if (Test-Path $Saida) { Remove-Item -Recurse -Force (Join-Path $Saida "*") }
New-Item -ItemType Directory -Force $Saida | Out-Null

$env:RASGO_AUTOTESTE = "1"
$env:RASGO_AUTOTESTE_DIR = $Saida
& (Join-Path $raiz ".codex_tools\gms.cmd") run --target=windows (Join-Path $raiz "PokemonRogueLike.yyp")
Write-Host "Saida do autoteste em: $Saida"
