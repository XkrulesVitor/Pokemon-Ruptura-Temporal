# Estado Atual: Rasgo Temporal (auto-battler roguelike)

Guia de referência rápida para qualquer IA entender a estrutura, as mecânicas e o estado do projeto.
Quando pedirem para "continuar o checklist", leia este arquivo e pegue o próximo item não concluído.

## 1. Visão Geral
* **Gênero**: roguelike auto-battler de monstros colecionáveis.
* **Motor**: GameMaker (GML), projeto `PokemonRogueLike.yyp` (o nome do arquivo é legado; o jogo se chama Rasgo Temporal).
* **Conteúdo**: 100% original. Criaturas, região, personagens e arte não podem copiar nenhuma franquia existente.
  O conteúdo de Pokémon foi removido; veja `docs/registro_de_mudancas.txt`.

## 2. Lore
O Sindicato Eclipse libertou **Aeonox**, que rasgou o tempo sobre o **Vale de Cronaria**. Monstros de outras eras atravessam as fendas.
Os guardiões **Lumis** e **Brotempo** tentaram contê-lo. O jogador parte da **Vila Alvorada** com um parceiro da **Prof. Sabia**,
vence os líderes das cidades e precisa fechar o rasgo.

## 3. Onde fica cada coisa
* `datafiles/data/criaturas.json`: roster (129 criaturas, 18 tipos, 6 trios de iniciais). Gerado por `tools/gerar_conteudo.py`.
* `datafiles/data/mundo.json`: região, cidades, líderes, vilões e personagens. Também gerado por `tools/gerar_conteudo.py`.
* `scripts/scr_conteudo`: carrega os JSON (`criatura_info`, `criatura_ids`, `conteudo_pacote_iniciais`, `conteudo_cidades`...).
* `scripts/scr_placeholders`: desenha placeholders de criatura, treinador, cidade e item quando falta a arte.
* `scripts/scr_autoteste` + `tools/autoteste.ps1`: percorre as telas sozinho, salva screenshots e `log.txt`.
* `docs/como_adicionar_artes.txt`: onde colocar cada arte nova.
* Só pastas de arte original são carregadas (filtro em `project_asset_permitido`). Arte de terceiros fica em `_arquivo_terceiros/` e não entra no build.

## 4. Mecânicas (runs)
* Começa com um inicial sorteado dos trios liberados.
* Progressão linear: cidade → draft de rota → encontros (selvagens/treinadores) → próxima cidade → líder.
* Captura com cápsulas; equipe de até 4.
* Combate automático em tempo real; subir de nível em marcos abre draft de habilidades/upgrades.
* Game over quando a equipe inteira desmaia.
* Meta-progressão: Fragmentos do Tempo (vencendo líderes) compram trios de iniciais e melhorias permanentes.

## 5. Sprints
- [x] **Sprint 0: Fundação**: git com commit base, caminhos fixos removidos, scripts soltos em `tools/legacy`, autoteste com screenshots.
- [x] **Sprint 1/2 (parte 1): Troca de conteúdo**: roster e mundo originais em JSON, textos da tela trocados, placeholders no lugar da arte de terceiros.
- [x] **Sprint 1/2 (parte 2): Restante da troca**
  - Itens, lojas por cidade e ordem da mochila em `datafiles/data/itens.json`; rotas em `rotas.json`; classes de treinador em `treinadores.json`.
  - Identificadores internos renomeados (`tools/renomear_identificadores.py`): `pokemon_*` -> `criatura_*`, `Pokemon*` -> `Criatura*`, `pokedex_*` -> `bestiario_*`, recursos `scr_criatura_*`, `scr_bestiario`, `obj_criatura_batalha`. O arquivo do projeto continua `PokemonRogueLike.yyp` e os IDs internos de itens (ex.: `pokebola`) ficam iguais para nao quebrar saves.
  - Save da loja permanente migra sozinho de `pokemon_roguelike_meta.ini` para `meta_progresso.ini`.
  - Relatorios de balanceamento antigos movidos para `docs/legado/`.
  - Pendente: arte original (o usuario adiciona) e fontes livres em `datafiles/fonts_jogo/`.
- [x] **Sprint 3: Fechar a run**
  - [x] Chefe final: depois de vencer o último líder, aparece o marcador "Rasgo Temporal" (X) na última cidade. Aeonox luta em 3 fases (`chefe_fases` em `mundo.json`, todas no nível 30, que é o máximo do jogo). Entre fases a criatura ativa recupera 25% do HP. Usa o mesmo sistema de time dos treinadores (`battle_context == "chefe"`).
  - [x] Tela de vitória (`DemoEstado.VITORIA_FINAL`): céu com a fenda se fechando, equipe vencedora, créditos rolando (`creditos` em `mundo.json`), +12 Fragmentos. No Desafio Diário, vencer o chefe vale +5000 pontos.
  - [x] Save no meio da run (`scripts/scr_run_save`): autosave sempre que o estado vira CIDADE (`run_save_step`), botão "CONTINUAR" (ou tecla C) no menu com resumo, um slot só (`run_salva.json`), apagado no game over e na vitória final. Runs do Desafio Diário salvam o estado do diário junto. Ao carregar, `static_set` religa as criaturas ao construtor `PokemonData`.
  - [x] Missões de NPC (`scripts/scr_missoes`, dados em `mundo.json` -> `missoes`): 12 missões, uma sorteada por cidade a cada run (segue a semente no Desafio Diário). O marcador de evento mostra "!" quando há missão nova. Tipos: capturar tipo, capturar qualquer, vencer tipo, vencer treinadores, entregar e nível. Até 3 ativas, lista na tela da cidade, recompensa na hora com aviso. Vai junto no save. O sistema antigo (`scr_event_manager`, `scr_roguelike_run`) foi removido.
- [x] **Sprint 4: Desafio Diário** (`scripts/scr_desafio_diario`)
  - Botão "DESAFIO DIARIO" no menu (ou tecla D). Semente = data em UTC (AAAAMMDD); para testar outra data use `RASGO_DIARIO_DATA=AAAAMMDD`.
  - Inicial do dia: criatura em estágio inicial de raridade comum, incomum ou rara (60 candidatas), escolhida por hash da data.
  - Sorteios em "escopos" (`diario_escopo`/`diario_escopo_fim`): cada evento usa `random_set_seed(hash(data|chave))` e depois `randomize()`, então efeitos visuais não desalinham a run. Escopos: inicial, drafts de rota, início de rota, encontro selvagem, treinador, drops, líder, draft de habilidade.
  - O combate em tempo real e as capturas continuam aleatórios.
  - Sem bônus da loja permanente; treino não rende fragmentos.
  - Uma tentativa oficial por dia, gravada ao começar (fechar o jogo no meio não devolve). Depois, só treino.
  - Pontos = insígnias×1000 + vitórias×40 + capturas×60 + soma dos níveis×10. Histórico, melhor marca e sequência de dias em `desafio_diario.json`.
  - Pendente: ranking online (hoje é só local).
- [x] **Sprint 5: Combate** (`scripts/scr_combate_extras`)
  - Captura: `(0.03 + forca_da_capsula * (0.15 + 0.85 * HP_perdido)) * mult_raridade + status`. Com HP cheio fica em ~7% (Capsula Simples, criatura comum); status de controle +15%, de dano +8%; Capsula Mestra sempre captura. `global.dificuldade_captura_mult` fica para a Sprint 7.
  - Sinergia cruzada (`datafiles/data/sinergias.json`, 21 regras): um golpe do tipo X ganha um efeito quando a criatura tem OUTRA habilidade equipada do tipo Y (ex.: Inseto + Veneno = envenena). Selo "SINERGIA" no slot e explicacao no tooltip.
  - Aviso grande e pulsante na tela: COMBO! (marca consumida), DANO SINERGICO! (golpe de tipo contra alvo enfraquecido, +X% no log), SINERGIA! (efeito cruzado), com tremida de tela.
  - VFX: projetil desenhado por tipo e particulas de impacto por tipo (sistema de particulas proprio).
- [x] **Sprint 6: Graficos (tudo que nao e criatura)**
  - Elementos de rota recortados em PNG com transparencia (`tools/recortar_elementos.py`; os JPG originais continuam la).
  - Biomas montados: chao + ate 16 elementos espalhados fora da trilha (posicoes fixas por rota), com sombra e balanco leve nas plantas. O personagem anda sobre a trilha de cada chao. O segundo personagem parado foi removido.
  - Cidades geradas a partir dos marcadores: predio certo embaixo de cada um (ginasio na cor do tipo do lider, centro, loja, laboratorio, casa, barraca dos NPCs de missao), trilhas ligando tudo e casas de enfeite so nos espacos livres.
  - Interface: painel de reserva com degrade, brilho e cantos; botoes crescem com easing e afundam ao clicar; fade curto ao trocar de tela principal.
  - Pendente: os 15 elementos do catalogo que ainda nao existem (precisam de arte), e unificar as areas de clique entre Step e Draw.
- [x] **Sprint 7: Rejogabilidade** (`scripts/scr_rejogabilidade`, progresso permanente em `progresso.json`)
  - Dificuldade (botao no canto do menu): Facil (-2 niveis, dano inimigo -15%, captura +15%), Normal, Dificil (+2 niveis, dano +15%, +20% dinheiro, +50% fragmentos), Hardcore (+3 niveis, dano +35%, captura -40%, rotas sem tipos visiveis, treinadores/lideres/chefe usam uma cura forte por batalha, fragmentos x2). O Desafio Diario sempre roda no Normal.
  - Modo Buraco Negro: liberado ao vencer Aeonox; botao "MERGULHAR NO RASGO" na tela de vitoria (fora do Desafio Diario). Ondas infinitas no nivel 30, com +10% de forca por onda e ate 4 inimigos; a equipe recupera 35% entre ondas. Recorde salvo e mostrado no game over.
  - 14 conquistas com aviso na tela e tela propria (botao no menu). Contadores de sinergias e combos.
  - Visuais do jogador (botao no menu): 6 paletas do personagem do mapa, liberadas por conquistas.
  - Itens de batalha novos: Po de Furia (Impeto Ofensivo), Po de Couraca (Fortificado), Po de Vento (recargas mais rapidas), vendidos a partir de Pedralia.
- [x] **Sprint 8: Audio, idiomas e build** (parcial: ver pendencias)
  - Audio sintetizado no proprio jogo (`scripts/scr_audio`): 7 musicas em loop (menu, cidade, rota, batalha, chefe, Buraco Negro, vitoria final) geradas aos poucos em segundo plano e 12 efeitos (golpe, combo, cura, captura, nivel, vitoria, derrota, conquista, missao, clique). Arquivos .ogg em `datafiles/audio/` substituem os sintetizados. Opcao SOM no menu (ligado / so efeitos / mudo).
  - Idiomas (`scripts/scr_idiomas`): PT-BR e EN-US, opcao IDIOMA no menu. Toda chamada de desenho de texto passa por `i18n_*`; dicionario em `datafiles/data/idiomas/en.json` (gerado por `tools/gerar_idiomas.py`). Interface principal traduzida; nomes e descricoes de habilidades/passivas e falas de NPC ainda so em portugues.
  - Build: `gm-cli package` recusa com a licenca de convidado ("Unable to obtain permission to execute"). Para exportar o .exe e preciso entrar com a conta GameMaker (IDE ou `gm-cli login`). O jogo compilado ja roda fora da pasta do projeto (cache do GameMaker) com todos os dados carregando.
  - Pendente: traducao de habilidades/passivas/falas, balanceamento jogando runs completas, exportacao do .exe com a conta do usuario, fontes com licenca livre.

## 6. Regras para a IA
* Leia `scr_conteudo`, `scr_criatura_data`, `scr_criatura_progressao` e `scr_demo_playable` antes de grandes refatorações.
* Depois de mudar código, compile (`.codex_tools\gms.cmd compile --target=windows --errors-only PokemonRogueLike.yyp`)
  e rode `tools\autoteste.ps1`; confira o `log.txt` e os screenshots.
* Novo conteúdo nunca pode copiar nomes, personagens, arte, músicas ou mapas de jogos existentes.
