import re
import os

gml_file = r"d:\VITOR\Jogos\PokemonRogueLike\scripts\scr_pokemon_data\scr_pokemon_data.gml"

with open(gml_file, "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

# Extrair descricoes
desc_pattern = re.compile(r'case\s+"([^"]+)":\s*return\s+"([^"]+)";')
desc_map = dict(desc_pattern.findall(content))

# Extrair HabilidadeData
hab_pattern = re.compile(
    r'new\s+HabilidadeData\(\s*'
    r'"([^"]+)",\s*'      # ID 1
    r'"([^"]+)",\s*'      # Nome 2
    r'PokemonTipo\.([A-Z_]+),\s*' # Tipo 3
    r'(\d+),\s*'          # Nivel 4
    r'([\d\.]+),\s*'      # Cooldown 5
    r'(\d+),\s*'          # Dano 6
    r'\[(.*?)\]\s*,\s*'   # Tags 7
    r'\[(.*?)\]'          # Efeitos 8
)

habilidades = []
vistos = set()

for match in hab_pattern.finditer(content):
    h_id, h_nome, h_tipo, h_nivel, h_cd, h_dano, h_tags, h_efeitos = match.groups()
    if h_id not in vistos:
        vistos.add(h_id)
        desc = desc_map.get(h_id, "Sem descricao especifica encontrada.")
        
        # Limpar tags e efeitos
        h_tags = [t.strip().strip('"') for t in h_tags.split(',')] if h_tags.strip() else []
        h_efeitos = [e.strip().strip('"') for e in h_efeitos.split(',')] if h_efeitos.strip() else []
        
        habilidades.append({
            "id": h_id,
            "nome": h_nome,
            "tipo": h_tipo,
            "nivel": h_nivel,
            "cd": h_cd,
            "dano": h_dano,
            "tags": ", ".join(h_tags),
            "efeitos": ", ".join(h_efeitos),
            "desc": desc
        })

# Agrupar por tipo
por_tipo = {}
for hab in habilidades:
    t = hab["tipo"]
    if t not in por_tipo:
        por_tipo[t] = []
    por_tipo[t].append(hab)

# Output
print("# Habilidades Implementadas por Tipo\n")
for t in sorted(por_tipo.keys()):
    print(f"## Tipo: {t}")
    for hab in sorted(por_tipo[t], key=lambda x: int(x["nivel"])):
        print(f"- **{hab['nome']}** (Nvl {hab['nivel']}) | CD: {hab['cd']}s | Dano: {hab['dano']}")
        print(f"  - *Status/Tags:* {hab['tags']}")
        print(f"  - *Efeitos:* {hab['efeitos']}")
        print(f"  - *Descricao:* {hab['desc']}\n")

