"""Gera os arquivos de conteudo original do jogo em datafiles/data/.

- criaturas.json: roster original (nomes, tipos, atributos, raridade, evolucoes)
- mundo.json: regiao, cidades, lideres, viloes e personagens

Edite as tabelas abaixo e rode:  python tools/gerar_conteudo.py
Os atributos sao gerados de forma deterministica a partir do "papel" e do total.
Nomes ficam sem acento porque a fonte padrao do jogo nao tem esses glifos.
"""

import json
import os

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAIDA = os.path.join(RAIZ, "datafiles", "data")

TIPOS = [
    "normal", "fogo", "agua", "grama", "eletrico", "gelo", "lutador", "veneno", "terra",
    "voador", "psiquico", "inseto", "pedra", "fantasma", "dragao", "sombrio", "aco", "fada",
]
RARIDADES = ["comum", "incomum", "raro", "epico", "lendario", "ultra_raro"]

# Fracoes do total de atributos (hp, ataque, defesa, velocidade) por papel.
PAPEIS = {
    "equilibrado": (0.25, 0.25, 0.25, 0.25),
    "tanque": (0.30, 0.20, 0.32, 0.18),
    "veloz": (0.21, 0.28, 0.18, 0.33),
    "bruto": (0.27, 0.33, 0.22, 0.18),
    "muralha": (0.24, 0.18, 0.38, 0.20),
    "vidro": (0.20, 0.34, 0.16, 0.30),
}

# Cada linha: (niveis_de_evolucao, [estagio, ...])
# estagio = (nome, tipo1, tipo2, raridade, papel, total_de_atributos)
INICIAIS = {
    "grama": ([12, 23], [("Brotinho", "grama", "", "raro", "tanque", 205), ("Folhagar", "grama", "", "raro", "tanque", 268), ("Selvagorn", "grama", "terra", "epico", "tanque", 330)]),
    "fogo": ([12, 23], [("Fagulho", "fogo", "", "raro", "veloz", 205), ("Brasante", "fogo", "", "raro", "veloz", 268), ("Infernhal", "fogo", "aco", "epico", "bruto", 330)]),
    "agua": ([12, 23], [("Gotito", "agua", "", "raro", "equilibrado", 205), ("Marolho", "agua", "", "raro", "equilibrado", 268), ("Abissauro", "agua", "pedra", "epico", "muralha", 330)]),
    "eletrico": ([12, 23], [("Zapito", "eletrico", "", "raro", "veloz", 205), ("Voltrino", "eletrico", "", "raro", "veloz", 268), ("Trovarca", "eletrico", "", "epico", "vidro", 330)]),
    "voador": ([12, 23], [("Penugem", "voador", "", "raro", "veloz", 205), ("Ventarola", "voador", "", "raro", "veloz", 268), ("Gaviarco", "voador", "lutador", "epico", "bruto", 330)]),
    "gelo": ([12, 23], [("Flocolino", "gelo", "", "raro", "equilibrado", 205), ("Geadeiro", "gelo", "", "raro", "equilibrado", 268), ("Glacimonte", "gelo", "terra", "epico", "tanque", 330)]),
    "pedra": ([12, 23], [("Pedrisco", "pedra", "", "raro", "muralha", 205), ("Rochedao", "pedra", "", "raro", "muralha", 268), ("Monolitao", "pedra", "lutador", "epico", "muralha", 330)]),
    "terra": ([12, 23], [("Terrilho", "terra", "", "raro", "bruto", 205), ("Barrancudo", "terra", "", "raro", "bruto", 268), ("Sismodonte", "terra", "dragao", "epico", "bruto", 330)]),
    "aco": ([12, 23], [("Rebitim", "aco", "", "raro", "muralha", 205), ("Ferrolhao", "aco", "", "raro", "muralha", 268), ("Couracante", "aco", "", "epico", "muralha", 330)]),
    "sombrio": ([12, 23], [("Breuzinho", "sombrio", "", "raro", "vidro", 205), ("Penumbrar", "sombrio", "", "raro", "vidro", 268), ("Eclipsauro", "sombrio", "dragao", "epico", "vidro", 330)]),
    "fantasma": ([12, 23], [("Vultinho", "fantasma", "", "raro", "veloz", 205), ("Assombrel", "fantasma", "", "raro", "veloz", 268), ("Espectronio", "fantasma", "psiquico", "epico", "vidro", 330)]),
    "veneno": ([12, 23], [("Peconhim", "veneno", "", "raro", "equilibrado", 205), ("Viperal", "veneno", "", "raro", "equilibrado", 268), ("Toxidrago", "veneno", "dragao", "epico", "bruto", 330)]),
    "psiquico": ([12, 23], [("Psilume", "psiquico", "", "raro", "vidro", 205), ("Mentaluz", "psiquico", "", "raro", "vidro", 268), ("Oraculyx", "psiquico", "", "epico", "vidro", 330)]),
    "fada": ([12, 23], [("Encantilho", "fada", "", "raro", "equilibrado", 205), ("Feerica", "fada", "", "raro", "equilibrado", 268), ("Sortilegia", "fada", "voador", "epico", "equilibrado", 330)]),
    "dragao": ([12, 23], [("Escamito", "dragao", "", "raro", "bruto", 205), ("Dracovento", "dragao", "", "raro", "bruto", 268), ("Draconarca", "dragao", "psiquico", "epico", "bruto", 330)]),
    "normal": ([12, 23], [("Pelucio", "normal", "", "raro", "tanque", 205), ("Pelagudo", "normal", "", "raro", "tanque", 268), ("Mamutao", "normal", "", "epico", "tanque", 330)]),
    "inseto": ([12, 23], [("Larvinha", "inseto", "", "raro", "equilibrado", 205), ("Casulante", "inseto", "", "raro", "muralha", 268), ("Mariposaria", "inseto", "voador", "epico", "veloz", 330)]),
    "lutador": ([12, 23], [("Socadinho", "lutador", "", "raro", "bruto", 205), ("Pugilar", "lutador", "", "raro", "bruto", 268), ("Campeonix", "lutador", "aco", "epico", "bruto", 330)]),
}

# Trios de iniciais. "base" ja vem liberado; os outros sao comprados na loja permanente.
# As chaves batem com os IDs de melhoria salvos no meta-progresso.
PACOTES_INICIAIS = {
    "base": {"nome": "Trio Elemental", "tipos": ["grama", "fogo", "agua"]},
    "starter_gen2": {"nome": "Trio da Tempestade", "tipos": ["eletrico", "voador", "gelo"]},
    "starter_gen3": {"nome": "Trio da Rocha", "tipos": ["pedra", "terra", "aco"]},
    "starter_gen4": {"nome": "Trio das Sombras", "tipos": ["sombrio", "fantasma", "veneno"]},
    "starter_gen5": {"nome": "Trio Arcano", "tipos": ["psiquico", "fada", "dragao"]},
    "starter_special": {"nome": "Trio Selvagem", "tipos": ["normal", "inseto", "lutador"]},
}

LINHAS_COMUNS = [
    ([18], [("Rataco", "normal", "", "comum", "veloz", 195), ("Ratagao", "normal", "", "incomum", "bruto", 262)]),
    ([18], [("Pardalito", "normal", "voador", "comum", "veloz", 190), ("Gaviolento", "normal", "voador", "incomum", "veloz", 265)]),
    ([18], [("Orelhudo", "normal", "", "comum", "veloz", 188), ("Saltorelha", "normal", "lutador", "incomum", "veloz", 262)]),
    ([18], [("Folhoca", "grama", "", "comum", "equilibrado", 192), ("Ramagem", "grama", "", "incomum", "tanque", 260)]),
    ([18], [("Cactilho", "grama", "", "comum", "muralha", 200), ("Cactusao", "grama", "lutador", "incomum", "muralha", 270)]),
    ([18], [("Fungito", "grama", "veneno", "comum", "tanque", 198), ("Fungardo", "grama", "veneno", "incomum", "tanque", 266)]),
    ([7, 12], [("Taturinho", "inseto", "", "comum", "tanque", 165), ("Crisalio", "inseto", "", "comum", "muralha", 195), ("Borbolume", "inseto", "voador", "incomum", "veloz", 255)]),
    ([18], [("Formigo", "inseto", "pedra", "comum", "bruto", 200), ("Formigao", "inseto", "pedra", "incomum", "bruto", 270)]),
    ([18], [("Cinzelho", "fogo", "", "incomum", "veloz", 215), ("Brasilobo", "fogo", "", "raro", "bruto", 285)]),
    ([18], [("Peixote", "agua", "", "comum", "veloz", 185), ("Barbatao", "agua", "", "incomum", "bruto", 265)]),
    ([18], [("Gaivotela", "agua", "voador", "comum", "veloz", 192), ("Gaivotao", "agua", "voador", "incomum", "veloz", 262)]),
    ([18], [("Sapolodo", "agua", "veneno", "comum", "equilibrado", 198), ("Sapocetico", "agua", "veneno", "incomum", "tanque", 268)]),
    ([18], [("Estalito", "eletrico", "", "incomum", "veloz", 212), ("Amperfelino", "eletrico", "", "raro", "vidro", 282)]),
    ([18], [("Pinguito", "gelo", "agua", "incomum", "tanque", 215), ("Pinguardiao", "gelo", "agua", "raro", "tanque", 285)]),
    ([18], [("Murrinho", "lutador", "", "comum", "bruto", 205), ("Murraco", "lutador", "", "incomum", "bruto", 272)]),
    ([18], [("Gosmito", "veneno", "", "comum", "tanque", 200), ("Gosmaturo", "veneno", "", "incomum", "tanque", 268)]),
    ([18], [("Toupeiro", "terra", "", "comum", "bruto", 200), ("Toupeiraco", "terra", "", "incomum", "bruto", 270)]),
    ([18], [("Seixinho", "pedra", "terra", "comum", "muralha", 205), ("Pedregulhao", "pedra", "terra", "incomum", "muralha", 275)]),
    ([18], [("Lencolito", "fantasma", "", "incomum", "vidro", 212), ("Mortalhao", "fantasma", "", "raro", "vidro", 285)]),
    ([23], [("Lagartolho", "dragao", "agua", "raro", "equilibrado", 225), ("Serpendrago", "dragao", "agua", "epico", "equilibrado", 335)]),
    ([18], [("Gatunim", "sombrio", "", "incomum", "veloz", 212), ("Gatunoir", "sombrio", "", "raro", "veloz", 282)]),
    ([18], [("Engrenito", "aco", "eletrico", "incomum", "muralha", 215), ("Engrenador", "aco", "eletrico", "raro", "muralha", 288)]),
    ([18], [("Pirilim", "fada", "inseto", "incomum", "veloz", 205), ("Pirilumina", "fada", "inseto", "raro", "veloz", 275)]),
    ([18], [("Corujito", "psiquico", "voador", "incomum", "equilibrado", 210), ("Corujastral", "psiquico", "voador", "raro", "equilibrado", 284)]),
]

UNICOS = [
    ("Lamacudo", "agua", "terra", "incomum", "tanque", 258),
    ("Bovolt", "normal", "eletrico", "incomum", "bruto", 262),
    ("Ciclopardo", "normal", "psiquico", "incomum", "equilibrado", 262),
    ("Raiomanta", "agua", "eletrico", "raro", "veloz", 292),
    ("Nevasco", "gelo", "fantasma", "raro", "vidro", 290),
    ("Cristalino", "pedra", "fada", "raro", "muralha", 292),
    ("Corvoturno", "sombrio", "voador", "raro", "veloz", 286),
    ("Teiamorte", "inseto", "fantasma", "raro", "vidro", 282),
    ("Sucateiro", "aco", "sombrio", "raro", "bruto", 290),
    ("Espinhaco", "grama", "lutador", "raro", "bruto", 288),
    ("Escorpiareia", "terra", "veneno", "raro", "bruto", 290),
    ("Totemistico", "psiquico", "pedra", "raro", "muralha", 292),
    ("Lanternil", "fogo", "fantasma", "raro", "vidro", 285),
    ("Auroril", "gelo", "fada", "raro", "equilibrado", 288),
    ("Serenissima", "agua", "fada", "raro", "equilibrado", 290),
    ("Gargulao", "pedra", "voador", "raro", "muralha", 292),
    ("Cervalume", "grama", "fada", "raro", "veloz", 288),
    ("Sinoeco", "aco", "fantasma", "raro", "muralha", 290),
    ("Vulcanossauro", "fogo", "pedra", "epico", "bruto", 345),
    ("Draguerreiro", "dragao", "lutador", "epico", "bruto", 350),
    ("Furacauda", "voador", "dragao", "epico", "veloz", 345),
    ("Martelaco", "aco", "lutador", "epico", "bruto", 345),
    ("Mandibrum", "agua", "sombrio", "epico", "bruto", 340),
]

# Guardioes do tempo. Aeonox e quem rasgou o tempo (chefe final da historia).
LENDARIOS = [
    ("Aeonox", "psiquico", "sombrio", "lendario", "vidro", 420),
    ("Lumis", "psiquico", "fada", "lendario", "equilibrado", 405),
    ("Brotempo", "grama", "psiquico", "lendario", "equilibrado", 405),
]

MUNDO = {
    "regiao": "Vale de Cronaria",
    "titulo_jogo": "Rasgo Temporal",
    "termo_criatura": "criatura",
    "termo_criaturas": "criaturas",
    "professor": "Prof. Sabia",
    "mae": "Mae",
    "equipe_vila": "Sindicato Eclipse",
    "chefe_final": "Aeonox",
    "guardioes": ["Lumis", "Brotempo"],
    # Batalha final: aparece na ultima cidade depois de vencer o ultimo lider.
    # Cada fase entra quando a anterior cai; entre fases a criatura ativa recupera "cura_entre_fases" do HP.
    # O nivel maximo do jogo e 30, entao as fases se diferenciam pelos multiplicadores.
    "chefe_fases": [
        {"nome": "Aeonox", "nivel": 30, "hp": 1.35, "ataque": 1.05, "defesa": 1.00, "velocidade": 1.00,
         "fala": "Aeonox: O tempo se curva diante de mim."},
        {"nome": "Aeonox Fendido", "nivel": 30, "hp": 1.60, "ataque": 1.20, "defesa": 1.15, "velocidade": 1.08,
         "fala": "Aeonox: Voce so abriu mais o rasgo!"},
        {"nome": "Aeonox Desperto", "nivel": 30, "hp": 1.90, "ataque": 1.35, "defesa": 1.20, "velocidade": 1.18,
         "fala": "Aeonox: Entao veja o fim de todas as eras!"},
    ],
    "chefe_cura_entre_fases": 0.25,
    "chefe_recompensa_fragmentos": 12,
    "texto_vitoria": "Aeonox foi selado e o tempo voltou a correr no Vale de Cronaria. Lumis e Brotempo guardam a fenda agora, e o eco desta equipe fica gravado em todas as eras.",
    "creditos": [
        "RASGO TEMPORAL",
        "Ideia, direcao e GDD: o criador do projeto",
        "Codigo e conteudo feitos com IA (Claude e Codex) no GameMaker",
        "Arte de rotas e cenarios gerada para o projeto",
        "Criaturas, mundo e historia originais",
        "Obrigado por jogar!",
    ],
    "cidades": [
        {"nome": "Vila Alvorada", "lider": "", "especialidade": "", "tipo": "", "evento": "Casa da Mae", "lider_criatura": "", "lider_nivel": 0, "sprite_lider": "", "sprite_cidade": "vila_alvorada.png"},
        {"nome": "Porto Raizes", "lider": "", "especialidade": "", "tipo": "", "evento": "Mercado do Porto", "lider_criatura": "", "lider_nivel": 0, "sprite_lider": "", "sprite_cidade": "porto_raizes.png"},
        {"nome": "Pedralia", "lider": "Tito Basalto", "especialidade": "Pedra", "tipo": "pedra", "evento": "Museu de Pedralia", "lider_criatura": "Rochedao", "lider_nivel": 10, "sprite_lider": "lider_tito.png", "sprite_cidade": "pedralia.png"},
        {"nome": "Marevia", "lider": "Ondina", "especialidade": "Agua", "tipo": "agua", "evento": "Ponte das Gaivotas", "lider_criatura": "Barbatao", "lider_nivel": 14, "sprite_lider": "lider_ondina.png", "sprite_cidade": "marevia.png"},
        {"nome": "Voltara", "lider": "Capita Raia", "especialidade": "Eletrico", "tipo": "eletrico", "evento": "Cais dos Cargueiros", "lider_criatura": "Amperfelino", "lider_nivel": 19, "sprite_lider": "lider_raia.png", "sprite_cidade": "voltara.png"},
        {"nome": "Ilha Brasa", "lider": "Dr. Calidus", "especialidade": "Fogo", "tipo": "fogo", "evento": "Laboratorio Rachado", "lider_criatura": "Brasilobo", "lider_nivel": 24, "sprite_lider": "lider_calidus.png", "sprite_cidade": "ilha_brasa.png"},
        {"nome": "Cidadela Fenda", "lider": "Vesper", "especialidade": "Terra / Eclipse", "tipo": "terra", "evento": "Base do Eclipse", "lider_criatura": "Sismodonte", "lider_nivel": 30, "sprite_lider": "lider_vesper.png", "sprite_cidade": "cidadela_fenda.png"},
    ],
}


def atributos(papel, total, semente):
    fr = PAPEIS[papel]
    vals = [max(10, round(total * f)) for f in fr]
    # Pequena variacao deterministica para criaturas do mesmo papel nao ficarem identicas.
    ajuste = [(semente * 7) % 7 - 3, (semente * 11) % 7 - 3, (semente * 13) % 7 - 3, 0]
    vals = [v + a for v, a in zip(vals, ajuste)]
    vals[3] += total - sum(vals)
    return vals


def main():
    criaturas = []
    por_nome = {}

    def adicionar(estagio, evolui_de=0, nivel_evolucao=0, estagio_num=1):
        nome, t1, t2, rar, papel, total = estagio
        assert t1 in TIPOS and (t2 == "" or t2 in TIPOS), nome
        assert rar in RARIDADES, nome
        assert nome not in por_nome, "nome repetido: " + nome
        cid = len(criaturas) + 1
        hp, atk, df, spd = atributos(papel, total, cid)
        item = {
            "id": cid, "nome": nome, "tipo1": t1, "tipo2": t2, "raridade": rar, "papel": papel,
            "hp": hp, "ataque": atk, "defesa": df, "velocidade": spd,
            "estagio": estagio_num, "evolui_de": evolui_de, "nivel_evolucao": nivel_evolucao,
            "sprite": "",
        }
        criaturas.append(item)
        por_nome[nome] = item
        return cid

    def adicionar_linha(niveis, estagios):
        anterior = 0
        for i, est in enumerate(estagios):
            nivel = niveis[i - 1] if i > 0 else 0
            anterior = adicionar(est, anterior, nivel, i + 1)

    for tipo in TIPOS:
        niveis, estagios = INICIAIS[tipo]
        adicionar_linha(niveis, estagios)
    for niveis, estagios in LINHAS_COMUNS:
        adicionar_linha(niveis, estagios)
    for est in UNICOS + LENDARIOS:
        adicionar(est)

    pacotes = {}
    for chave, pacote in PACOTES_INICIAIS.items():
        ids = [por_nome[INICIAIS[t][1][0][0]]["id"] for t in pacote["tipos"]]
        nomes = [INICIAIS[t][1][0][0] for t in pacote["tipos"]]
        pacotes[chave] = {"nome": pacote["nome"], "ids": ids, "nomes": nomes}

    for cidade in MUNDO["cidades"]:
        nome = cidade["lider_criatura"]
        cidade["lider_criatura_id"] = por_nome[nome]["id"] if nome else 0

    os.makedirs(SAIDA, exist_ok=True)
    with open(os.path.join(SAIDA, "criaturas.json"), "w", encoding="utf-8") as f:
        json.dump({"versao": 1, "criaturas": criaturas, "pacotes_iniciais": pacotes}, f, ensure_ascii=True, indent=1)
    with open(os.path.join(SAIDA, "mundo.json"), "w", encoding="utf-8") as f:
        json.dump(MUNDO, f, ensure_ascii=True, indent=1)

    contagem = {r: sum(1 for c in criaturas if c["raridade"] == r) for r in RARIDADES}
    print("criaturas:", len(criaturas), contagem)
    for tipo in TIPOS:
        n = sum(1 for c in criaturas if tipo in (c["tipo1"], c["tipo2"]))
        print(f"  {tipo:9s} {n}")


if __name__ == "__main__":
    main()
