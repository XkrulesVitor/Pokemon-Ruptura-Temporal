$gml_file = 'd:\VITOR\Jogos\PokemonRogueLike\scripts\scr_pokemon_data\scr_pokemon_data.gml'
$content = Get-Content $gml_file -Raw
$index = $content.IndexOf("//========================================================")
if ($index -ge 0) {
    $content = $content.Substring(0, $index)
    Set-Content -Path $gml_file -Value $content -Encoding utf8
}
