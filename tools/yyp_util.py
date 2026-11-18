"""Edicoes simples no PokemonRogueLike.yyp sem abrir a IDE.

Uso:
  python tools/yyp_util.py add-script scr_nome
  python tools/yyp_util.py add-file datafiles/data/arquivo.json
  python tools/yyp_util.py remove-files-under datafiles/sprites/pokemon
  python tools/yyp_util.py list-files [prefixo]
"""

import os
import re
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
YYP = os.path.join(RAIZ, "PokemonRogueLike.yyp")


def ler():
    with open(YYP, "r", encoding="utf-8", newline="") as f:
        return f.read()


def gravar(texto):
    with open(YYP, "w", encoding="utf-8", newline="") as f:
        f.write(texto)


def add_script(nome):
    texto = ler()
    entrada = '    {"id":{"name":"%s","path":"scripts/%s/%s.yy",},},\n' % (nome, nome, nome)
    if '"name":"%s","path":"scripts/' % nome in texto:
        print("ja existe:", nome)
        return
    marcador = '  "resources":[\n'
    pos = texto.index(marcador) + len(marcador)
    gravar(texto[:pos] + entrada + texto[pos:])
    print("script adicionado:", nome)


def add_file(caminho):
    caminho = caminho.replace("\\", "/")
    pasta, nome = caminho.rsplit("/", 1)
    texto = ler()
    padrao = '"filePath":"%s","name":"%s"' % (pasta, nome)
    if padrao in texto:
        print("ja incluido:", caminho)
        return
    entrada = ('    {"$GMIncludedFile":"","%%Name":"%s","CopyToMask":-1,"filePath":"%s","name":"%s",'
               '"resourceType":"GMIncludedFile","resourceVersion":"2.0",},\n') % (nome, pasta, nome)
    marcador = '  "IncludedFiles":[\n'
    pos = texto.index(marcador) + len(marcador)
    gravar(texto[:pos] + entrada + texto[pos:])
    print("arquivo incluido:", caminho)


def remove_files_under(prefixo):
    prefixo = prefixo.replace("\\", "/").rstrip("/")
    texto = ler()
    linhas = texto.split("\n")
    saida = []
    removidas = 0
    for linha in linhas:
        m = re.search(r'"\$GMIncludedFile":"".*?"filePath":"([^"]+)"', linha)
        if m and (m.group(1) == prefixo or m.group(1).startswith(prefixo + "/")):
            removidas += 1
            continue
        saida.append(linha)
    gravar("\n".join(saida))
    print("entradas removidas:", removidas)


def list_files(prefixo=""):
    for m in re.finditer(r'"\$GMIncludedFile":"".*?"filePath":"([^"]+)","name":"([^"]+)"', ler()):
        caminho = m.group(1) + "/" + m.group(2)
        if caminho.startswith(prefixo):
            print(caminho)


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "add-script":
        add_script(sys.argv[2])
    elif cmd == "add-file":
        add_file(sys.argv[2])
    elif cmd == "remove-files-under":
        remove_files_under(sys.argv[2])
    elif cmd == "list-files":
        list_files(sys.argv[2] if len(sys.argv) > 2 else "")
    else:
        print(__doc__)
