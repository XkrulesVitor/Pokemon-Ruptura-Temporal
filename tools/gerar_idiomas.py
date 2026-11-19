"""Gera datafiles/data/idiomas/en.json (traducao PT -> EN da interface).

"exatos": a string inteira desenhada na tela vira a traducao.
"trechos": pedacos substituidos dentro de frases montadas (nomes e numeros no meio).
Ainda em portugues: nomes/descricoes de habilidades e passivas, falas de NPC e nomes proprios.
Uso: python tools/gerar_idiomas.py
"""

import json
import os

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

EXATOS = {
    # menu e opcoes
    "RASGO TEMPORAL": "TIME RIFT", "O ESPACO ESTILHACADO": "THE SHATTERED SPACE",
    "COMECAR RUN": "START RUN", "CONTINUAR": "CONTINUE", "LOJA DO ESPACO": "SPACE SHOP",
    "DESAFIO DIARIO": "DAILY CHALLENGE", "DIARIO (TREINO)": "DAILY (PRACTICE)",
    "FACIL": "EASY", "DIFICIL": "HARD", "LIGADO": "ON", "SO EFEITOS": "SFX ONLY", "MUDO": "MUTED",
    "PULAR": "SKIP", "Menu inicial": "Main menu", "VOLTAR": "BACK", "Voltar": "Back", "FECHAR": "CLOSE",
    "Compre melhorias permanentes para futuras runs.": "Buy permanent upgrades for future runs.",
    "Unico": "One-time", "Comprado": "Bought",
    "Lente Cromatica": "Chromatic Lens", "+0.4% de chance de variante cromatica por nivel.": "+0.4% chromatic variant chance per level.",
    "Radar de Treinadores": "Trainer Radar", "+4% de chance de encontrar treinador em cada rota por nivel.": "+4% chance to meet a trainer on each route per level.",
    "Bolsa de Vitorias": "Victory Purse", "+8% de dinheiro recebido em batalhas por nivel.": "+8% battle money per level.",
    "Ajuda da Mae": "Mom's Help", "Aumenta o dinheiro inicial: +50, +100, +150 e +200 M$.": "More starting money: +50, +100, +150 and +200 M$.",
    "Kit de Captura": "Capture Kit", "Comeca com Capsulas melhores conforme evolui este kit.": "Start with better Capsules as this kit levels up.",
    "Kit de Sobrevivencia": "Survival Kit", "Comeca a run com pocoes e curas melhores.": "Start the run with potions and better healing.",
    "Eco Ofensivo": "Offensive Echo", "+3% de dano para monstros aliados por nivel.": "+3% damage for allied monsters per level.",
    "Laco de Fenda": "Rift Bond", "+3% de chance plana de captura por nivel.": "+3% flat capture chance per level.",
    "Trio Elemental": "Elemental Trio", "Trio da Tempestade": "Storm Trio", "Trio da Rocha": "Rock Trio",
    "Trio das Sombras": "Shadow Trio", "Trio Arcano": "Arcane Trio", "Trio Selvagem": "Wild Trio",
    # intro
    "Na Ilha Brasa, Vesper manteve Aeonox preso em uma capsula de contencao.": "On Ember Isle, Vesper kept Aeonox locked in a containment capsule.",
    "A energia psiquica passou do limite. O laboratorio inteiro comecou a tremer.": "The psychic energy went past the limit. The whole lab began to shake.",
    "Lumis e Brotempo surgiram para conter Aeonox antes que Cronaria fosse engolida.": "Lumis and Brotempo appeared to hold Aeonox back before Cronaria was swallowed.",
    "O choque abriu uma fresta no espaco-tempo. Monstros de outras eras atravessaram.": "The clash opened a crack in space-time. Monsters from other eras crossed over.",
    "A noite caiu sobre Cronaria. Cada run comeca no rastro desse ceu estilhacado.": "Night fell over Cronaria. Every run begins in the wake of that shattered sky.",
    "ENTER / clique: continuar": "ENTER / click: continue",
    # escolha de inicial
    "ESCOLHA SEU MONSTRO INICIAL": "CHOOSE YOUR STARTER MONSTER", "Escolha seu monstro inicial": "Choose your starter monster",
    "Clique em um card ou pressione 1, 2 ou 3": "Click a card or press 1, 2 or 3", "Ataque inicial": "Starting attack",
    "VELOCIDADE": "SPEED", "DEFESA": "DEFENSE", "ATAQUE": "ATTACK", "EQUILIBRADO": "BALANCED", "VIDA": "HEALTH",
    "Comum": "Common", "Incomum": "Uncommon", "Raro": "Rare", "Epico": "Epic", "Lendario": "Legendary", "Ultra Raro": "Ultra Rare",
    # tipos
    "FOGO": "FIRE", "AGUA": "WATER", "GRAMA": "GRASS", "ELETRICO": "ELECTRIC", "VENENO": "POISON", "LUTADOR": "FIGHTING",
    "VOADOR": "FLYING", "TERRA": "GROUND", "PEDRA": "ROCK", "INSETO": "BUG", "FANTASMA": "GHOST", "ACO": "STEEL",
    "PSIQUICO": "PSYCHIC", "GELO": "ICE", "DRAGAO": "DRAGON", "SOMBRIO": "DARK", "FADA": "FAIRY", "TIPO": "TYPE",
    # cidade
    "Escolha um ponto no mapa": "Pick a spot on the map", "Mochila": "Bag", "Saida da cidade": "Leaving town",
    "Compras e suprimentos": "Shopping and supplies", "Casa da Mae": "Mom's House", "Lab. do Prof. Sabia": "Prof. Sabia's Lab",
    "Mercado": "Shop", "Centro de Cura": "Healing Center", "Equipe curada.": "Team healed.", "Mochila aberta.": "Bag opened.",
    "Mochila vazia": "Empty bag", "Clique em um item para comprar.": "Click an item to buy it.", "MISSOES": "QUESTS",
    "Sem ginasio": "No gym",
    # rota
    "ROTA EM ANDAMENTO": "ROUTE IN PROGRESS", "ENTER ou clique para avancar.": "ENTER or click to advance.",
    # batalha
    "BESTIARIO": "BESTIARY", "MOCHILA": "BAG", "TROCAR": "SWAP", "FUGIR": "FLEE", "Vazio": "Empty", "PRONTO": "READY",
    "TROCAR MONSTRO": "SWAP MONSTER", "Em campo": "In battle", "SUBSTITUIR": "REPLACE", "EQUIPE CHEIA": "TEAM FULL",
    "Clique para trocar": "Click to swap", "Combate pausado. Clique em um item para usar.": "Battle paused. Click an item to use it.",
    "COMBO!": "COMBO!", "DANO SINERGICO!": "SYNERGY DAMAGE!", "SINERGIA!": "SYNERGY!", "SINERGIA": "SYNERGY",
    "Combo executado!": "Combo performed!", "Vitoria!": "Victory!", "Game Over": "Game Over", "Captura realizada": "Capture complete",
    "A equipe recuperou um pouco de HP.": "The team recovered some HP.",
    "Encontro vencido. Pressione ENTER ou clique para continuar pela rota.": "Encounter won. Press ENTER or click to keep going.",
    "Todos os monstros da equipe foram derrotados.": "Your whole team was defeated.",
    "Escolha uma habilidade ou uma evolucao": "Pick a skill or an upgrade", "Escolha uma habilidade para evoluir": "Pick a skill to upgrade",
    "Upgrade de tier da habilidade equipada.": "Tier upgrade for an equipped skill.",
    "+CURA": "+HEAL", "VEL": "SPD",
    # game over / vitoria
    "GAME OVER": "GAME OVER", "VOLTAR AO MENU": "BACK TO MENU", "Slot vazio": "Empty slot", "Habilidades": "Skills",
    "Passivas": "Passives", "Sem passiva": "No passive", "O RASGO FOI FECHADO": "THE RIFT IS CLOSED",
    "MERGULHAR NO RASGO": "DIVE INTO THE RIFT", "O Rasgo Temporal foi fechado.": "The Time Rift is closed.",
    "A ultima Capsula caiu na grama enquanto a fenda continuava rasgando Cronaria. A run acabou, mas o eco dessa equipe ainda fica preso no tempo.":
        "The last Capsule fell on the grass while the rift kept tearing Cronaria apart. The run is over, but this team's echo stays trapped in time.",
    "Aeonox foi selado e o tempo voltou a correr no Vale de Cronaria. Lumis e Brotempo guardam a fenda agora, e o eco desta equipe fica gravado em todas as eras.":
        "Aeonox is sealed and time flows again in the Cronaria Valley. Lumis and Brotempo now guard the rift, and this team's echo is carved into every era.",
    "Treino do desafio: sem fragmentos": "Challenge practice: no fragments",
    # bestiario
    "Estagio": "Stage", "Raridade": "Rarity", "Todos": "All", "Todas": "All",
    "Nenhum monstro capturado neste filtro.": "No monster caught with this filter.",
    "Capture monstros nas rotas para liberar dados completos aqui.": "Catch monsters on routes to unlock their full data here.",
    # conquistas
    "CONQUISTA DESBLOQUEADA": "ACHIEVEMENT UNLOCKED",
    "Primeiro Laco": "First Bond", "Capture seu primeiro monstro.": "Catch your first monster.",
    "Colecionador": "Collector", "Tenha 25 monstros capturados no Bestiario.": "Have 25 monsters caught in the Bestiary.",
    "Enciclopedia Viva": "Living Encyclopedia", "Capture todos os monstros do Bestiario.": "Catch every monster in the Bestiary.",
    "Primeira Insignia": "First Badge", "Venca um lider de ginasio.": "Defeat a gym leader.",
    "Rasgo Fechado": "Rift Closed", "Venca Aeonox.": "Defeat Aeonox.",
    "Lobo Solitario": "Lone Wolf", "Venca Aeonox com apenas 1 monstro na equipe.": "Defeat Aeonox with only 1 monster on the team.",
    "Caminho Dificil": "Hard Road", "Venca Aeonox no Dificil ou no Hardcore.": "Defeat Aeonox on Hard or Hardcore.",
    "Sem Misericordia": "No Mercy", "Venca Aeonox no Hardcore.": "Defeat Aeonox on Hardcore.",
    "Sinergista": "Synergist", "Ative 25 sinergias cruzadas.": "Trigger 25 cross synergies.",
    "Mestre dos Combos": "Combo Master", "Faca 50 COMBOS ou DANOS SINERGICOS.": "Land 50 COMBOS or SYNERGY HITS.",
    "Lenda Capturada": "Legend Caught", "Capture um monstro lendario.": "Catch a legendary monster.",
    "Brilho Raro": "Rare Shine", "Capture uma variante cromatica.": "Catch a chromatic variant.",
    "Semana no Rasgo": "A Week in the Rift", "Complete 7 Desafios Diarios seguidos.": "Complete 7 Daily Challenges in a row.",
    "Horizonte de Eventos": "Event Horizon", "Chegue a onda 10 do Buraco Negro.": "Reach wave 10 of the Black Hole.",
    "Padrao": "Default", "Rubi": "Ruby", "Esmeralda": "Emerald", "Safira": "Sapphire", "Cometa": "Comet", "Obsidiana": "Obsidian",
    "PADRAO": "DEFAULT", "RUBI": "RUBY", "ESMERALDA": "EMERALD", "SAFIRA": "SAPPHIRE", "COMETA": "COMET", "OBSIDIANA": "OBSIDIAN",
    # dificuldade
    "A experiencia padrao.": "The standard experience.",
    "Inimigos 2 niveis abaixo, dano inimigo -15%, captura +15%.": "Enemies 2 levels lower, enemy damage -15%, capture +15%.",
    "Inimigos 2 niveis acima, dano inimigo +15%, +20% dinheiro, +50% fragmentos.": "Enemies 2 levels higher, enemy damage +15%, +20% money, +50% fragments.",
    "Rotas sem tipos visiveis, captura -40%, dano inimigo +35%, treinadores usam itens, fragmentos x2.": "Routes hide their types, capture -40%, enemy damage +35%, trainers use items, fragments x2.",
    # itens
    "Capsula Simples": "Basic Capsule", "Capsula Reforcada": "Sturdy Capsule", "Capsula Avancada": "Advanced Capsule", "Capsula Mestra": "Master Capsule",
    "Pocao": "Potion", "Pocao Forte": "Strong Potion", "Pocao Maxima": "Max Potion", "Elixir Total": "Full Elixir", "Antidoto": "Antidote",
    "Pomada Fria": "Cooling Salve", "Sal de Despertar": "Waking Salts", "Tonico Puro": "Pure Tonic", "Fruta Anil": "Indigo Fruit",
    "Fruta Rubra": "Crimson Fruit", "Fruta Ambar": "Amber Fruit", "Cristal de Nivel": "Level Crystal", "Po de Furia": "Fury Powder",
    "Po de Couraca": "Armor Powder", "Po de Vento": "Wind Powder",
    # interface da Sprint 9 (mercado, mochila, confirmacao, draft)
    "Clique em um item para usar. Alguns so funcionam em batalha.": "Click an item to use it. Some only work in battle.",
    "Usa sozinha": "Auto-use", "So em batalha": "Battle only", "Fora de batalha": "Not in battle",
    "Captura": "Capture", "Cura": "Healing", "Cura total": "Full heal", "Status": "Status",
    "Fruta automatica": "Auto fruit", "Batalha": "Battle", "Nivel": "Level",
    "RUN SALVA": "SAVED RUN", "Nova run": "New run", "Ir ao Diario": "Go to Daily", "Cancelar": "Cancel",
    "Voce tem uma run salva. Comecar uma nova run apaga esse progresso.": "You have a saved run. Starting a new run erases that progress.",
    "Voce tem uma run salva. Comecar o Desafio Diario apaga esse progresso.": "You have a saved run. Starting the Daily Challenge erases that progress.",
    "PAUSA": "PAUSED", "Sair para o menu": "Quit to menu", "Menu": "Menu",
    "A run fica salva nesta cidade e volta pelo botao CONTINUAR. Voltar ao menu inicial?": "The run is saved in this town and comes back through CONTINUE. Return to the main menu?",
    "Trancado": "Locked", "Slot trancado": "Slot locked", "Desmaiado": "Fainted", "Suporte": "Support",
    "Escolha uma nova habilidade": "Choose a new skill", "Escolha uma habilidade para evoluir": "Choose a skill to upgrade",
    "Escolha uma habilidade ou uma evolucao": "Choose a skill or an upgrade",
    "Evolui esta habilidade, aumentando dano, efeito ou reduzindo recarga.": "Upgrades this skill: more damage, stronger effect or shorter cooldown.",
}

TRECHOS = [
    ("DIFICULDADE: ", "DIFFICULTY: "), ("CONQUISTAS ", "ACHIEVEMENTS "), ("VISUAL: ", "LOOK: "), ("SOM: ", "SOUND: "),
    ("IDIOMA: ", "LANGUAGE: "),
    (": PADRAO", ": DEFAULT"), (": RUBI", ": RUBY"), (": ESMERALDA", ": EMERALD"), (": SAFIRA", ": SAPPHIRE"),
    (": COMETA", ": COMET"), (": OBSIDIANA", ": OBSIDIAN"), (": LIGADO", ": ON"), (": SO EFEITOS", ": SFX ONLY"),
    (": MUDO", ": MUTED"), (": FACIL", ": EASY"), (": DIFICIL", ": HARD"), ("Um CROMATICO ", "A wild CHROMATIC "),
    ("Um ", "A wild "), (": VELOCIDADE", ": SPEED"), (": DEFESA", ": DEFENSE"), (": ATAQUE", ": ATTACK"),
    (": EQUILIBRADO", ": BALANCED"), (": VIDA", ": HEALTH"), (" CROMATICO ", " CHROMATIC "), ("CROMATICO ", "CHROMATIC "), ("Hoje ", "Today "), (" | sua marca: ", " | your score: "), (" | sequencia: ", " | streak: "),
    (" insignias | ", " badges | "), (" e mais ", " + "), ("Diario | ", "Daily | "),
    ("Foco: ", "Focus: "), ("Voce chegou a ", "You arrived at "), ("Escolha a rota para voltar a ", "Choose the route back to "),
    ("Escolha a rota para ", "Choose the route to "), ("Bem-vindo ao Mercado de ", "Welcome to the shop of "),
    ("Comprou ", "Bought "), ("Voce usou ", "You used "), ("Missao aceita: ", "Quest accepted: "), ("Recompensa: ", "Reward: "),
    ("Missao concluida (", "Quest complete ("), ("Ainda conto com voce. ", "Still counting on you. "),
    ("Obrigado pela ajuda! A cidade fica te devendo essa.", "Thanks for the help! The town owes you one."),
    (" monstro(s) do tipo ", " monster(s) of type "), (" monstros do tipo ", " monsters of type "), (" treinadores (", " trainers ("),
    ("Leve a encomenda ate ", "Deliver the package to "), ("Tenha um monstro no nivel ", "Have a monster at level "),
    ("Run retomada em ", "Run resumed at "), ("Ginasio ", "Gym "), ("Estagio da rota: ", "Route stage: "),
    ("Encontros do caminho: ", "Encounters on the way: "), ("Avancar: ", "Go: "), ("Voltar para ", "Back to "), ("Ir para ", "Go to "),
    ("Biomas: ", "Biomes: "), (" encontros.", " encounters."), ("Destino: ", "Destination: "), ("Trecho: ", "Stretch: "),
    ("Selvagens: ", "Wild: "), ("Dano ", "Damage "), (" Foi super efetivo!", " It's super effective!"), (" Foi efetivo!", " It's effective!"),
    (" Nao foi muito efetivo.", " It's not very effective."), (" usou ", " used "), (" ficou ", " is now "), (" sofreu ", " took "),
    (" de VENENO!", " POISON damage!"), (" de QUEIMADURA!", " BURN damage!"), (" de ESPINHOS!", " THORN damage!"), (" recuperou ", " recovered "),
    (" ativou ", " activated "), (" selvagem apareceu!", " appeared!"), (" te desafiou com ", " challenged you with "),
    (" enviou ", " sent out "), (" escapou da Capsula!", " broke free from the Capsule!"), ("Voce arremessou ", "You threw "),
    ("Capturou ", "Caught "), (" foi capturado! ", " was caught! "), ("Rota concluida! Pressione ENTER ou clique para chegar a ", "Route complete! Press ENTER or click to reach "),
    ("Pressione ENTER ou clique para continuar.", "Press ENTER or click to continue."), ("A trilha ate ", "The trail to "),
    (" continua. Clique ou pressione ENTER para avancar.", " goes on. Click or press ENTER to advance."), ("Vitoria contra ", "Victory against "),
    (" subiu para o Lv. ", " grew to Lv. "), ("Evoluiu: ", "Evolved: "), ("Upgrade: ", "Upgrade: "), ("Libera ", "Unlocks "),
    ("Equipe final: ", "Final team: "), ("Equipe vencedora: ", "Winning team: "), (" Fragmentos do Espaco", " Space Fragments"),
    ("DESAFIO DIARIO ", "DAILY CHALLENGE "), (" pontos  |  ", " points  |  "), (" insignias  |  ", " badges  |  "),
    (" vitorias  |  ", " wins  |  "), (" capturas", " catches"), ("Melhor marca: ", "Best score: "), ("   Sequencia de dias: ", "   Day streak: "),
    (" (treino, nao conta)", " (practice, doesn't count)"), (" - RASGO FECHADO!", " - RIFT CLOSED!"), ("BURACO NEGRO", "BLACK HOLE"),
    (" - NOVO RECORDE!", " - NEW RECORD!"), (" ondas vencidas  |  recorde: ", " waves cleared  |  record: "),
    ("Buraco Negro - onda ", "Black Hole - wave "), (" monstro(s) surgem do rasgo!", " monster(s) burst out of the rift!"),
    ("Onda ", "Wave "), (" vencida! O rasgo puxa voce mais fundo. Pressione ENTER ou clique.", " cleared! The rift pulls you deeper. Press ENTER or click."),
    ("O Rasgo Temporal se abre!", "The Time Rift opens!"), ("O rasgo se alarga: ", "The rift widens: "),
    (" caiu! O Rasgo Temporal esta se fechando. Pressione ENTER ou clique.", " fell! The Time Rift is closing. Press ENTER or click."),
    (" renovam sua equipe.", " restore your team."), ("CONQUISTAS  ", "ACHIEVEMENTS  "), ("Novo visual: ", "New look: "),
    ("  (libera o visual ", "  (unlocks the look "), ("Sinergias: ", "Synergies: "), ("   Combos: ", "   Combos: "),
    ("   Recorde do Buraco Negro: ", "   Black Hole record: "), (" ondas", " waves"), ("Capturados: ", "Caught: "), ("   P: fechar", "   P: close"),
    ("Inicial: ", "Starting skill: "), ("Raridade: ", "Rarity: "), ("Mostrando ", "Showing "), ("Use os filtros para afinar a lista.", "Use the filters to narrow the list."),
    ("Custo ", "Cost "), ("Desafio Diario ", "Daily Challenge "), (" (tentativa oficial)", " (official attempt)"), (" (treino)", " (practice)"),
    ("Sinergia: ", "Synergy: "), ("SINERGIA (", "SYNERGY ("), ("Monstro ", "Monster "), (" monstros!", " monsters!"),
    ("MERCADO - ", "SHOP - "), ("Voce tem: ", "Owned: "), ("Abre no nivel ", "Opens at level "), ("Ginasio de ", "Gym of "),
    (" - NIVEL ", " - LEVEL "), ("Bronze > Prata", "Bronze > Silver"), ("Prata > Ouro", "Silver > Gold"), ("Ouro > Diamante", "Gold > Diamond"),
    ("Prof. Sabia: O ", "Prof. Sabia: The "), (" libertou ", " freed "), (", e o tempo se rasgou sobre o ", ", and time tore open over the "),
    (". Monstros de outras eras estao atravessando as fendas. Leve este parceiro, venca os lideres e feche o rasgo antes que ele engula tudo.",
     ". Monsters from other eras are crossing through the cracks. Take this partner, beat the leaders and close the rift before it swallows everything."),
]


def main():
    destino = os.path.join(RAIZ, "datafiles", "data", "idiomas")
    os.makedirs(destino, exist_ok=True)
    trechos = sorted(TRECHOS, key=lambda par: -len(par[0]))
    with open(os.path.join(destino, "en.json"), "w", encoding="utf-8") as f:
        json.dump({"idioma": "en", "nome": "ENGLISH", "exatos": EXATOS, "trechos": trechos}, f, ensure_ascii=True, indent=1)
    print("exatos:", len(EXATOS), "trechos:", len(trechos))


if __name__ == "__main__":
    main()
