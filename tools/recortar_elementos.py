"""Gera PNGs com transparencia a partir dos elementos de rota em JPG (fundo liso).

Os JPG originais ficam intactos; o PNG sai ao lado com o mesmo nome.
O fundo e detectado pela cor dos cantos e removido por preenchimento a partir das bordas.
Uso: python tools/recortar_elementos.py
"""

import glob
import os
from collections import deque

from PIL import Image

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PASTA = os.path.join(RAIZ, "datafiles", "sprites", "overworld", "routes", "elements")
TOLERANCIA = 46
LADO_MAX = 256


def cor_fundo(img):
    w, h = img.size
    px = img.load()
    amostras = []
    for cx, cy in ((0, 0), (w - 12, 0), (0, h - 12), (w - 12, h - 12)):
        for x in range(cx, cx + 12):
            for y in range(cy, cy + 12):
                amostras.append(px[x, y])
    n = len(amostras)
    return tuple(sum(c[i] for c in amostras) // n for i in range(3))


def recortar(caminho):
    img = Image.open(caminho).convert("RGB")
    w, h = img.size
    px = img.load()
    fundo = cor_fundo(img)
    tol2 = TOLERANCIA * TOLERANCIA

    def parecido(c):
        return (c[0] - fundo[0]) ** 2 + (c[1] - fundo[1]) ** 2 + (c[2] - fundo[2]) ** 2 <= tol2

    removido = bytearray(w * h)
    fila = deque()
    for x in range(w):
        fila.append((x, 0))
        fila.append((x, h - 1))
    for y in range(h):
        fila.append((0, y))
        fila.append((w - 1, y))

    while fila:
        x, y = fila.popleft()
        i = y * w + x
        if removido[i] or not parecido(px[x, y]):
            continue
        removido[i] = 1
        if x > 0: fila.append((x - 1, y))
        if x < w - 1: fila.append((x + 1, y))
        if y > 0: fila.append((x, y - 1))
        if y < h - 1: fila.append((x, y + 1))

    # Segunda passada: se sobrou um "quadro" de fundo (ex.: vinheta escura), remove a partir dele.
    if sum(removido) < (w * h) * 0.25:
        ix, iy = int(w * 0.07), int(h * 0.07)
        fundo2 = px[ix, iy]
        tol2b = (TOLERANCIA * 0.8) ** 2

        def parecido2(c):
            return (c[0] - fundo2[0]) ** 2 + (c[1] - fundo2[1]) ** 2 + (c[2] - fundo2[2]) ** 2 <= tol2b

        fila = deque()
        for x in range(ix, w - ix):
            fila.append((x, iy))
            fila.append((x, h - iy - 1))
        for y in range(iy, h - iy):
            fila.append((ix, y))
            fila.append((w - ix - 1, y))
        while fila:
            x, y = fila.popleft()
            i = y * w + x
            if removido[i] or not parecido2(px[x, y]):
                continue
            removido[i] = 1
            if x > 0: fila.append((x - 1, y))
            if x < w - 1: fila.append((x + 1, y))
            if y > 0: fila.append((x, y - 1))
            if y < h - 1: fila.append((x, y + 1))
        # o que ficou fora do quadro interno tambem sai
        for y in range(h):
            for x in range(w):
                if x < ix or y < iy or x >= w - ix or y >= h - iy:
                    removido[y * w + x] = 1

    saida = Image.new("RGBA", (w, h))
    out = saida.load()
    for y in range(h):
        for x in range(w):
            r, g, b = px[x, y]
            out[x, y] = (r, g, b, 0 if removido[y * w + x] else 255)

    caixa = saida.getbbox()
    if caixa:
        x0, y0, x1, y1 = caixa
        saida = saida.crop((max(0, x0 - 4), max(0, y0 - 4), min(w, x1 + 4), min(h, y1 + 4)))

    escala = LADO_MAX / max(saida.size)
    if escala < 1:
        saida = saida.resize((max(1, round(saida.width * escala)), max(1, round(saida.height * escala))), Image.LANCZOS)

    destino = os.path.splitext(caminho)[0] + ".png"
    saida.save(destino)
    return destino, fundo, saida.size


def main():
    import sys
    filtro = sys.argv[1] if len(sys.argv) > 1 else "spr_*"
    for caminho in sorted(glob.glob(os.path.join(PASTA, filtro + ".jpg"))):
        destino, fundo, tamanho = recortar(caminho)
        print(os.path.basename(destino), "fundo", fundo, "tamanho", tamanho)


if __name__ == "__main__":
    main()
