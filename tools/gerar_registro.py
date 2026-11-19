"""Gera docs/registro_de_mudancas.txt: o que foi trocado, por qual nome, e quais arquivos mudaram."""

import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from renomear_habilidades import TROCAS as HABILIDADES
from renomear_identificadores import RECURSOS

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SAIDA = os.path.join(RAIZ, "docs", "registro_de_mudancas.txt")

PERSONAGENS = [
    ("Mewtwo (vilao que rasga o tempo)", "Aeonox (psiquico/sombrio, lendario)"),
    ("Mew (guardiao na intro)", "Lumis (psiquico/fada, lendario)"),
    ("Celebi (guardiao na intro)", "Brotempo (grama/psiquico, lendario)"),
    ("Prof. Carvalho", "Prof. Sabia"),
    ("Mae", "Mae (mantida)"),
    ("Equipe Rocket", "Sindicato Eclipse"),
    ("Giovanni (chefe da equipe e ultimo lider)", "Vesper"),
    ("Brock (lider de Pedra)", "Tito Basalto"),
    ("Misty (lider de Agua)", "Ondina"),
    ("Lt. Surge (lider Eletrico)", "Capita Raia"),
    ("Blaine (lider de Fogo)", "Dr. Calidus"),
]

LUGARES = [
    ("Kanto (regiao)", "Vale de Cronaria"),
    ("Pallet Town", "Vila Alvorada"),
    ("Viridian City (2a cidade)", "Porto Raizes"),
    ("Pewter City", "Pedralia"),
    ("Cerulean City", "Marevia"),
    ("Vermilion City", "Voltara"),
    ("Cinnabar Island", "Ilha Brasa"),
    ("Viridian City (cidade final do Giovanni)", "Cidadela Fenda"),
    ("Mart de Viridian", "Mercado do Porto"),
    ("Museu de Pewter", "Museu de Pedralia"),
    ("Ponte Nugget", "Ponte das Gaivotas"),
    ("Porto do S.S. Anne", "Cais dos Cargueiros / Porto do Cargueiro Aurora"),
    ("Base Rocket", "Base do Eclipse"),
    ("Centro Pokemon", "Centro de Cura"),
    ("Liga Pokemon", "Liga do Vale"),
    ("Rota 1", "Trilha da Alvorada"),
    ("Rota 2 / Viridian Forest", "Bosque Verdejante"),
    ("Rota 22", "Caminho dos Desafiantes"),
    ("Rota 23", "Pantano das Fendas"),
    ("Rota 3 & 4 / Mt. Moon", "Gruta do Eco"),
    ("Rota 42", "Pico Congelado"),
    ("Rota 4 (Fenda de Ferro)", "Fenda de Ferro"),
    ("Rota 5 & 6", "Via Central"),
    ("Rota 115", "Vale Mistico"),
    ("Rota 9", "Desfiladeiro Ardente"),
    ("Rota 19 & 20", "Mar Aberto"),
    ("Rota 10", "Usinas Destruidas"),
    ("Rota 12", "Abismo das Fendas"),
    ("Rota 21", "Canal Vulcanico"),
]

TERMOS = [
    ("Pokemon (na tela)", "monstro / monstros"),
    ("Pokedex", "Bestiario"),
    ("PokeMart / PokeStore", "Mercado"),
    ("P$ (Pokedolar)", "M$ (moedas)"),
    ("Shiny", "variante cromatica"),
    ("Titulo: POKEMON ROGUELIKE", "RASGO TEMPORAL"),
    ("Filtro 'Geracao 1-5' do Bestiario", "Filtro 'Estagio 1-3'"),
]

ITENS = [
    ("Pokebola", "Capsula Simples"),
    ("Great Ball / Grande Bola", "Capsula Reforcada"),
    ("Ultra Ball / Ultra Bola", "Capsula Avancada"),
    ("Master Ball / Bola Mestra", "Capsula Mestra"),
    ("Potion / Pocao", "Pocao (mantido)"),
    ("Super Potion / Super Pocao", "Pocao Forte"),
    ("Hyper Potion / Hiper Pocao", "Pocao Maxima"),
    ("Full Restore / Restaurador Total", "Elixir Total"),
    ("Full Heal / Cura Total", "Tonico Puro"),
    ("Antidote / Antidoto", "Antidoto (mantido)"),
    ("Burn Heal / Cura-Queimadura", "Pomada Fria"),
    ("Awakening / Despertador", "Sal de Despertar"),
    ("Oran Berry", "Fruta Anil"),
    ("Cheri Berry", "Fruta Rubra"),
    ("Leppa Berry", "Fruta Ambar"),
    ("Rare Candy / Doce Raro", "Cristal de Nivel"),
]

TREINADORES = [
    ("Youngster / Jovem Treinador", "Jovem Treinador"),
    ("Lass", "Estudante"),
    ("Picnicker", "Excursionista"),
    ("Aroma Lady", "Jardineira"),
    ("Bug Catcher / Cacador de Insetos", "Colecionador de Insetos"),
    ("Swimmer, Sailor / Nadador", "Nadador / Marinheira"),
    ("Camper, Burglar / Campista", "Campista"),
    ("Engineer, Scientist / Engenheiro", "Engenheiro / Cientista"),
    ("Hiker, Ruin Maniac / Montanhista", "Montanhista / Arqueologo"),
    ("Psychic / Psiquico", "Vidente"),
    ("Channeler / Medium", "Medium"),
    ("Cool Trainer / Treinador de Elite", "Veterano"),
    ("Bird Keeper / Criador de Passaros", "Falcoeira"),
    ("Black Belt / Faixa Preta", "Lutadora de Rua"),
    ("Rocket Grunt / Rocket Disfarcado", "Agente do Eclipse"),
]

PAPEIS_CRIATURA = [
    ("Trio inicial: Bulbasaur, Charmander, Squirtle", "Trio Elemental: Brotinho, Fagulho, Gotito"),
    ("Iniciais de Johto (Chikorita, Cyndaquil, Totodile)", "Trio da Tempestade: Zapito, Penugem, Flocolino"),
    ("Iniciais de Hoenn (Treecko, Torchic, Mudkip)", "Trio da Rocha: Pedrisco, Terrilho, Rebitim"),
    ("Iniciais de Sinnoh (Turtwig, Chimchar, Piplup)", "Trio das Sombras: Breuzinho, Vultinho, Peconhim"),
    ("Iniciais de Unova (Snivy, Tepig, Oshawott)", "Trio Arcano: Psilume, Encantilho, Escamito"),
    ("Iniciais Especiais (Pikachu, Eevee)", "Trio Selvagem: Pelucio, Larvinha, Socadinho"),
    ("Criatura do lider de Pedra (Geodude nv 10)", "Rochedao nv 10"),
    ("Criatura do lider de Agua (Staryu nv 14)", "Barbatao nv 14"),
    ("Criatura do lider Eletrico (Pikachu nv 19)", "Amperfelino nv 19"),
    ("Criatura do lider de Fogo (Growlithe nv 24)", "Brasilobo nv 24"),
    ("Criatura do ultimo lider (Nidoking nv 30)", "Sismodonte nv 30"),
]

ARTE = [
    ("Sprites de criaturas (black-white, national, icons, Essentials)", "placeholder procedural por tipo/estagio; arte nova em datafiles/sprites/criaturas/"),
    ("Treinadores e lideres (Essentials)", "placeholder procedural; arte nova em datafiles/sprites/treinadores/"),
    ("Jogador andando (trainer_run.png)", "placeholder procedural; arte nova em datafiles/sprites/treinadores/jogador_andando.png"),
    ("Icones de itens", "placeholder procedural; arte nova em datafiles/sprites/itens/<id>.png"),
    ("Mapas de cidade (redesenhos de Kanto)", "placeholder procedural; arte nova em datafiles/sprites/cidades/"),
    ("Databox, painel, icone de pokebola, tipos (UI de batalha)", "painel desenhado por codigo; arte nova em datafiles/sprites/interface/"),
    ("Titulo, battlebacks e animacoes do Essentials", "fundos desenhados por codigo; arte nova em datafiles/sprites/interface/ e efeitos/"),
    ("Fontes Power Clear / Power Red-Blue", "fonte do Windows em desenvolvimento; fonte nova em datafiles/fonts_jogo/"),
    ("Temas, efeitos e elementos de rota (overworld/routes)", "MANTIDOS: sao arte original do projeto"),
    ("Horizonte destruido da intro (cutscene)", "MANTIDO: arte original do projeto"),
]


def secao(f, titulo, pares):
    f.write("\n" + titulo + "\n" + "-" * len(titulo) + "\n")
    largura = max(len(a) for a, _ in pares) + 2
    for antes, depois in pares:
        f.write("  " + antes.ljust(largura) + "->  " + depois + "\n")


def main():
    criaturas = json.load(open(os.path.join(RAIZ, "datafiles", "data", "criaturas.json"), encoding="utf-8"))
    lista = criaturas["criaturas"]
    por_id = {c["id"]: c for c in lista}

    with open(SAIDA, "w", encoding="utf-8") as f:
        f.write("REGISTRO DE MUDANCAS - troca do conteudo de Pokemon por conteudo original\n")
        f.write("=" * 74 + "\n")
        f.write("Formato: ANTES -> DEPOIS. Gerado por tools/gerar_registro.py.\n")
        f.write("A branch local base-original-local (nao enviada ao GitHub) guarda o estado original.\n")

        secao(f, "PERSONAGENS E HISTORIA", PERSONAGENS)
        secao(f, "LUGARES E ROTAS", LUGARES)
        secao(f, "TERMOS DA INTERFACE", TERMOS)
        secao(f, "ITENS (o ID interno no codigo continua o mesmo)", ITENS)
        secao(f, "CLASSES DE TREINADOR", TREINADORES)
        secao(f, "PAPEIS DE CRIATURA COM EQUIVALENTE DIRETO", PAPEIS_CRIATURA)
        secao(f, "HABILIDADES RENOMEADAS (nomes que vinham de golpes de Pokemon)", sorted(HABILIDADES.items()))
        secao(f, "RECURSOS DO PROJETO RENOMEADOS", sorted(RECURSOS.items()))
        secao(f, "NOMES INTERNOS NO CODIGO (tools/renomear_identificadores.py)", [
            ("pokemon_* (funcoes e variaveis)", "criatura_*"),
            ("Pokemon* (construtores e enums: PokemonData, PokemonTipo...)", "Criatura* (CriaturaData, CriaturaTipo...)"),
            ("pokedex_* / global.pokedex", "bestiario_* / global.bestiario"),
            ("Save pokemon_roguelike_meta.ini", "meta_progresso.ini (migrado sozinho)"),
            ("Mantidos", "PokemonRogueLike.yyp (arquivo do projeto) e IDs de itens como pokebola"),
        ])
        secao(f, "ARTE", ARTE)

        f.write("\nROSTER DE CRIATURAS\n-------------------\n")
        f.write("ANTES: 649 especies das geracoes 1 a 5 (nomes, tipos, atributos e evolucoes copiados dos jogos).\n")
        f.write("DEPOIS: %d criaturas originais. Nao existe correspondencia uma-a-uma: o roster antigo foi\n" % len(lista))
        f.write("removido inteiro e este foi criado do zero (tipos, atributos e linhas evolutivas novos).\n")
        f.write("Fonte editavel: datafiles/data/criaturas.json (gerado por tools/gerar_conteudo.py).\n\n")
        f.write("  %-4s %-14s %-20s %-9s %-11s %s\n" % ("ID", "NOME", "TIPOS", "RARIDADE", "PAPEL", "EVOLUCAO"))
        for c in lista:
            tipos = c["tipo1"] + ("/" + c["tipo2"] if c["tipo2"] else "")
            evo = ""
            if c["evolui_de"]:
                evo = "evolui de %s no nv %d" % (por_id[c["evolui_de"]]["nome"], c["nivel_evolucao"])
            f.write("  %-4d %-14s %-20s %-9s %-11s %s\n" % (c["id"], c["nome"], tipos, c["raridade"], c["papel"], evo))

        f.write("\nCODIGO REMOVIDO OU SUBSTITUIDO\n------------------------------\n")
        f.write("  - Tabelas fixas com os 649 nomes, tipos e atributos (pokemon_species_info_gen5) -> leitura do JSON\n")
        f.write("  - Lista fixa de evolucoes por numero da Pokedex (pokemon_evolution_rules) -> campos evolui_de/nivel_evolucao\n")
        f.write("  - Evolucoes ramificadas fixas (Eevee, Tyrogue, Wurmple, Burmy...) -> sorteio entre os candidatos\n")
        f.write("  - Listas de raridade e de nivel minimo por numero da Pokedex -> campo raridade do JSON\n")
        f.write("  - 68 blocos de perfil por numero da Pokedex (ex.: 'Chikorita foi reposicionada...') -> perfil pelos atributos\n")
        f.write("  - Entradas especiais de Bulbasaur/Charmander/Squirtle e seus desenhos procedurais\n")
        f.write("  - Caminhos fixos D:/GAME-MAKER/PokemonRogueLike e d:/VITOR/Jogos/... -> caminhos relativos\n")

        f.write("\nARQUIVOS ALTERADOS (desde o commit base)\n----------------------------------------\n")
        try:
            # O estado original fica na branch local base-original-local (nao vai para o GitHub).
            if subprocess.call(["git", "rev-parse", "--verify", "-q", "base-original-local"], cwd=RAIZ, stdout=subprocess.DEVNULL) == 0:
                base = "base-original-local"
            else:
                base = subprocess.check_output(["git", "rev-list", "--max-parents=0", "HEAD"], cwd=RAIZ, text=True).strip().splitlines()[0]
            # intent-to-add faz os arquivos novos aparecerem no diff sem adicionar conteudo ao indice
            subprocess.call(["git", "add", "-A", "--intent-to-add", "."], cwd=RAIZ, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            linhas = subprocess.check_output(["git", "diff", "-M", "--numstat", base], cwd=RAIZ, text=True).splitlines()
            movidos = {}
            f.write("  %-66s %s\n" % ("ARQUIVO", "LINHAS +ADICIONADAS -REMOVIDAS"))
            for linha in linhas:
                add, rem, caminho = linha.split("\t", 2)
                if "registro_de_mudancas.txt" in caminho:
                    continue
                if "_arquivo_terceiros" in caminho:
                    m = re.match(r"(.*)\{(.*) => .*\}(.*)", caminho)
                    origem = (m.group(1) + m.group(2) + m.group(3)) if m else caminho.split(" => ")[0]
                    pasta = "/".join(origem.split("/")[:3])
                    movidos[pasta] = movidos.get(pasta, 0) + 1
                    continue
                f.write("  %-66s +%s -%s\n" % (caminho, add, rem))
            if movidos:
                f.write("\n  Arte de terceiros movida de datafiles/ para _arquivo_terceiros/datafiles/ (nada foi apagado):\n")
                for pasta, n in sorted(movidos.items()):
                    f.write("    %-50s %d arquivo(s)\n" % (pasta, n))
        except Exception as erro:
            f.write("  (nao foi possivel ler o git: %s)\n" % erro)

    print("gerado:", SAIDA)


if __name__ == "__main__":
    main()
