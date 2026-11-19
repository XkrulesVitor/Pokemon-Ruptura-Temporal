"""Troca os nomes internos que ainda remetem a Pokemon (refatoracao mecanica).

- Identificadores GML: pokemon -> criatura, Pokemon -> Criatura, pokedex -> bestiario...
  (so em codigo; em strings so quando a string inteira e um identificador renomeado,
  como chaves de struct e nomes de variaveis globais; comentarios tambem sao ajustados).
- Recursos: scr_pokemon_* -> scr_criatura_*, scr_pokedex -> scr_bestiario,
  obj_pokemon_batalha -> obj_criatura_batalha (pastas, .yy, .yyp e pastas do IDE).
- O arquivo do projeto (PokemonRogueLike.yyp) e os IDs de itens (ex.: "pokebola") ficam.
Uso: python tools/renomear_identificadores.py [--aplicar]
"""

import glob
import os
import re
import subprocess
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

RECURSOS = {
    "scr_pokemon_data": "scr_criatura_data",
    "scr_pokemon_progressao": "scr_criatura_progressao",
    "scr_pokemon_combate": "scr_criatura_combate",
    "scr_pokemon_sprites": "scr_criatura_sprites",
    "scr_pokemon_batalha_api": "scr_criatura_batalha_api",
    "scr_pokedex": "scr_bestiario",
    "obj_pokemon_batalha": "obj_criatura_batalha",
}

TOKEN = re.compile(r'//[^\n]*|/\*.*?\*/|@"[^"]*"|"(?:\\.|[^"\\\n])*"|[A-Za-z_][A-Za-z0-9_]*', re.S)
PARTES = [("POKEMON", "CRIATURA"), ("Pokemon", "Criatura"), ("pokemon", "criatura"),
          ("POKEDEX", "BESTIARIO"), ("Pokedex", "Bestiario"), ("pokedex", "bestiario")]


def novo_nome(ident):
    if ident in RECURSOS:
        return RECURSOS[ident]
    if ident == "PokemonRogueLike":
        return ident
    novo = ident
    for a, b in PARTES:
        novo = novo.replace(a, b)
    return novo


def arquivos_gml():
    return sorted(glob.glob(os.path.join(RAIZ, "scripts", "*", "*.gml")) + glob.glob(os.path.join(RAIZ, "objects", "*", "*.gml")) + glob.glob(os.path.join(RAIZ, "rooms", "*", "*.gml")))


def main():
    aplicar = "--aplicar" in sys.argv
    textos = {f: open(f, encoding="utf-8", newline="").read() for f in arquivos_gml()}

    # 1) mapa de identificadores e checagem de colisao
    existentes = set()
    for t in textos.values():
        for m in TOKEN.finditer(t):
            tok = m.group(0)
            if not tok.startswith(("/", '"', "@")):
                existentes.add(tok)
    mapa = {i: novo_nome(i) for i in existentes if novo_nome(i) != i}
    colisoes = [(a, b) for a, b in mapa.items() if b in existentes and b not in mapa]
    if colisoes:
        print("COLISOES (nada foi alterado):")
        for a, b in colisoes:
            print("  ", a, "->", b)
        sys.exit(1)
    print("identificadores a renomear:", len(mapa))

    # 2) reescreve o GML
    total = 0
    for f, t in textos.items():
        def sub(m):
            tok = m.group(0)
            if tok.startswith("//") or tok.startswith("/*"):
                novo = tok
                for a, b in PARTES:
                    novo = novo.replace(a, b)
                return novo
            if tok.startswith('"') or tok.startswith('@"'):
                pre = "@" if tok.startswith("@") else ""
                corpo = tok[len(pre) + 1:-1]
                return pre + '"' + mapa.get(corpo, corpo) + '"' if corpo in mapa else tok
            return mapa.get(tok, tok)

        novo = TOKEN.sub(sub, t)
        if novo != t:
            total += 1
            if aplicar:
                open(f, "w", encoding="utf-8", newline="").write(novo)
    print("arquivos GML alterados:", total)

    if not aplicar:
        print("(simulacao: rode com --aplicar)")
        return

    # 3) recursos: pastas, arquivos e referencias nos .yy/.yyp
    for velho, novo in RECURSOS.items():
        base = "scripts" if velho.startswith("scr_") else "objects"
        pasta_velha = os.path.join(base, velho)
        pasta_nova = os.path.join(base, novo)
        if not os.path.isdir(os.path.join(RAIZ, pasta_velha)):
            continue
        subprocess.check_call(["git", "mv", pasta_velha, pasta_nova], cwd=RAIZ)
        for ext in (".gml", ".yy"):
            a = os.path.join(pasta_nova, velho + ext)
            if os.path.exists(os.path.join(RAIZ, a)):
                subprocess.check_call(["git", "mv", a, os.path.join(pasta_nova, novo + ext)], cwd=RAIZ)

    metas = glob.glob(os.path.join(RAIZ, "**", "*.yy"), recursive=True) + [os.path.join(RAIZ, "PokemonRogueLike.yyp")]
    for f in metas:
        if any(p in f for p in ("_arquivo_terceiros", "asset_library", "runtime_assets", ".gmcache", ".codex_tools")):
            continue
        t = open(f, encoding="utf-8", newline="").read()
        novo = t
        for velho, nv in RECURSOS.items():
            novo = re.sub(r"\b%s\b" % velho, nv, novo)
        if novo != t:
            open(f, "w", encoding="utf-8", newline="").write(novo)
    print("recursos renomeados")


if __name__ == "__main__":
    main()
