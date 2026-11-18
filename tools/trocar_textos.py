"""Troca termos de Pokemon por termos originais SOMENTE dentro de strings GML.

Nao mexe em identificadores (PokemonTipo, pokemon_db_get...) nem em comentarios.
Uso:
  python tools/trocar_textos.py --listar   (mostra o que mudaria)
  python tools/trocar_textos.py --aplicar
"""

import glob
import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Ordem importa: termos compostos antes dos simples.
TROCAS = [
    (r"\bTreinador(es)? Pokemon\b", r"Treinador\1"),
    (r"\bCentro Pokemon\b", "Centro de Cura"),
    (r"\bLiga Pokemon\b", "Liga do Vale"),
    (r"\bPOKEMON ROGUELIKE\b", "RASGO TEMPORAL"),
    (r"\bPokemon ?Rogue[Ll]ike\b", "Rasgo Temporal"),
    # Plural: "os Pokemon", "4 Pokemon", "Pokemon selvagens"...
    (r"\b(os|Os|seus|Seus|dos|Dos|aos|nos|[0-9]+) Pokemon\b", r"\1 monstros"),
    (r"^ Pokemon!", " monstros!"),
    (r"(^|[.!?] )Pokemon (selvagens|aliados|parrudos|lentos|de outras eras)", r"\1Monstros \2"),
    (r"\bPokemon (selvagens|aliados|parrudos|lentos|de outras eras|nas rotas)", r"monstros \1"),
    (r"\bPokemons\b", "monstros"),
    (r"\bpokemons\b", "monstros"),
    # Singular: maiuscula so no inicio de frase.
    (r"(^|[.!?] )Pokemon\b", r"\1Monstro"),
    (r"\bPokemon\b", "monstro"),
    (r"\bPOKEMON\b", "MONSTRO"),
    (r"\bPokedex\b", "Bestiario"),
    (r"\bPOKEDEX\b", "BESTIARIO"),
    (r"\bPokebolas\b", "Capsulas"),
    (r"\bPokebola\b", "Capsula"),
    (r"\bPoke Bola\b", "Capsula"),
    (r"\bPokeMart\b|\bPokemart\b|\bPokeStore\b|\bPokestore\b|\bPOKESTORE\b|\bPOKEMART\b", "Mercado"),
    (r"P\$", "M$"),
    (r"\bProf\. Carvalho\b", "Prof. Sabia"),
    (r"\bProfessor Carvalho\b", "Professora Sabia"),
    (r"\bCarvalho\b", "Sabia"),
    (r"\bEquipe Rocket\b", "Sindicato Eclipse"),
    (r"\bTeam Rocket\b", "Sindicato Eclipse"),
    (r"\bRocket\b", "Eclipse"),
    (r"\bKanto\b", "Cronaria"),
    (r"\bMewtwo\b", "Aeonox"),
    (r"\bCelebi\b", "Brotempo"),
    (r"\bMew\b", "Lumis"),
    (r"\bGiovanni\b", "Vesper"),
    (r"\bLt\. Surge\b", "Capita Raia"),
    (r"\bBrock\b", "Tito Basalto"),
    (r"\bMisty\b", "Ondina"),
    (r"\bBlaine\b", "Dr. Calidus"),
    (r"\bIlha de Cinnabar\b", "Ilha Brasa"),
    (r"\bCidade de Pallet\b", "Vila Alvorada"),
    (r"\bViridian e o limite da run atual\b", "Cidadela Fenda e o limite da run atual"),
    (r"\bMart de Viridian\b", "Mercado do Porto"),
    (r"\bdo Mt\. Moon\b", "da Gruta do Eco"),
    (r"\bA Equipe Rocket\b", "O Sindicato Eclipse"),
    (r"\bEclipse Disfarcado\b|\bRocket Disfarcado\b", "Agente do Eclipse"),
    (r"\bna Bestiario\b|\bna Pokedex\b", "no Bestiario"),
    (r"\bDoce Raro\b", "Cristal de Nivel"),
    (r"\bPallet\b", "Vila Alvorada"),
    (r"\bViridian City\b", "Porto Raizes"),
    (r"\bViridian Forest\b", "Bosque Verdejante"),
    (r"\bViridian\b", "Porto Raizes"),
    (r"\bPewter City\b|\bPewter\b", "Pedralia"),
    (r"\bCerulean City\b|\bCerulean\b", "Marevia"),
    (r"\bVermilion City\b|\bVermilion\b", "Voltara"),
    (r"\bCinnabar Island\b|\bCinnabar\b", "Ilha Brasa"),
    (r"\bS\.S\. Anne\b", "Cargueiro Aurora"),
    (r"\bPonte Nugget\b", "Ponte das Gaivotas"),
    (r"\bMt\. Moon\b", "Gruta do Eco"),
    (r"\bShiny\b", "Cromatico"),
]

TOKEN = re.compile(
    r'//[^\n]*'              # comentario de linha
    r'|/\*.*?\*/'            # comentario de bloco
    r'|@"[^"]*"'             # string literal sem escapes
    r'|"(?:\\.|[^"\\\n])*"',  # string normal
    re.S,
)

# Strings que sao chaves internas, caminhos ou nomes de variavel: nao tocar.
def eh_tecnica(conteudo):
    if conteudo in ("Pokemon", "Pokebolas"):
        return True  # usadas como chave de struct
    if "/" in conteudo or "\\" in conteudo or conteudo.endswith(".png") or conteudo.endswith(".json"):
        return True
    if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", conteudo) and ("_" in conteudo or re.search(r"[a-z][A-Z]", conteudo)):
        return True
    return False


def trocar(texto):
    for padrao, novo in TROCAS:
        texto = re.sub(padrao, novo, texto)
    return texto


def processar(caminho, aplicar):
    src = open(caminho, "r", encoding="utf-8", newline="").read()
    mudancas = []

    def sub(m):
        tok = m.group(0)
        if tok.startswith("//") or tok.startswith("/*"):
            return tok
        prefixo = "@" if tok.startswith("@") else ""
        corpo = tok[len(prefixo) + 1:-1]
        if eh_tecnica(corpo):
            return tok
        novo = trocar(corpo)
        if novo != corpo:
            mudancas.append((corpo, novo))
        return prefixo + '"' + novo + '"'

    out = TOKEN.sub(sub, src)
    if aplicar and out != src:
        open(caminho, "w", encoding="utf-8", newline="").write(out)
    return mudancas


def main():
    aplicar = "--aplicar" in sys.argv
    arquivos = sorted(glob.glob(os.path.join(RAIZ, "scripts", "*", "*.gml")) + glob.glob(os.path.join(RAIZ, "objects", "*", "*.gml")))
    total = 0
    for arq in arquivos:
        mud = processar(arq, aplicar)
        if mud:
            print("==", os.path.relpath(arq, RAIZ), len(mud))
            for a, b in mud:
                print("   ", a[:110], "\n ->", b[:110])
            total += len(mud)
    print("total de strings alteradas:", total, "(aplicado)" if aplicar else "(simulacao)")


if __name__ == "__main__":
    main()
