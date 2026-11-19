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
- [ ] **Sprint 1/2 (parte 2): Restante da troca**
  - Levar itens, rotas e classes de treinador para JSON (ainda estão no código, já com nomes próprios).
  - Renomear identificadores internos `pokemon_*` / `Pokemon*` e os recursos `scr_pokemon_*`, `obj_pokemon_batalha` (refatoração mecânica, sem mudar comportamento).
  - Revisar `docs/*_balance_report*` e `docs/type_archetype_skill_catalog.txt`, que ainda citam as espécies antigas.
  - Arte original de criaturas, treinadores, cidades, itens e interface (o usuário adiciona; o jogo já procura os arquivos).
  - Fontes com licença livre em `datafiles/fonts_jogo/`.
- [ ] **Sprint 3: Fechar a run**
  - [x] Chefe final: depois de vencer o último líder, aparece o marcador "Rasgo Temporal" (X) na última cidade. Aeonox luta em 3 fases (`chefe_fases` em `mundo.json`, todas no nível 30, que é o máximo do jogo). Entre fases a criatura ativa recupera 25% do HP. Usa o mesmo sistema de time dos treinadores (`battle_context == "chefe"`).
  - [x] Tela de vitória (`DemoEstado.VITORIA_FINAL`): céu com a fenda se fechando, equipe vencedora, créditos rolando (`creditos` em `mundo.json`), +12 Fragmentos. No Desafio Diário, vencer o chefe vale +5000 pontos.
  - [x] Save no meio da run (`scripts/scr_run_save`): autosave sempre que o estado vira CIDADE (`run_save_step`), botão "CONTINUAR" (ou tecla C) no menu com resumo, um slot só (`run_salva.json`), apagado no game over e na vitória final. Runs do Desafio Diário salvam o estado do diário junto. Ao carregar, `static_set` religa as criaturas ao construtor `PokemonData`.
  - [ ] Missões de NPC nas cidades (portar `scr_event_manager`, hoje sem uso).
- [x] **Sprint 4: Desafio Diário** (`scripts/scr_desafio_diario`)
  - Botão "DESAFIO DIARIO" no menu (ou tecla D). Semente = data em UTC (AAAAMMDD); para testar outra data use `RASGO_DIARIO_DATA=AAAAMMDD`.
  - Inicial do dia: criatura em estágio inicial de raridade comum, incomum ou rara (60 candidatas), escolhida por hash da data.
  - Sorteios em "escopos" (`diario_escopo`/`diario_escopo_fim`): cada evento usa `random_set_seed(hash(data|chave))` e depois `randomize()`, então efeitos visuais não desalinham a run. Escopos: inicial, drafts de rota, início de rota, encontro selvagem, treinador, drops, líder, draft de habilidade.
  - O combate em tempo real e as capturas continuam aleatórios.
  - Sem bônus da loja permanente; treino não rende fragmentos.
  - Uma tentativa oficial por dia, gravada ao começar (fechar o jogo no meio não devolve). Depois, só treino.
  - Pontos = insígnias×1000 + vitórias×40 + capturas×60 + soma dos níveis×10. Histórico, melhor marca e sequência de dias em `desafio_diario.json`.
  - Pendente: ranking online (hoje é só local).
- [ ] **Sprint 5: Combate**: captura pela fórmula de HP/status, sinergia cruzada entre golpes, aviso "COMBO!", VFX por tipo.
- [ ] **Sprint 6: Gráficos (tudo que não é criatura)**: elementos de rota em PNG com transparência, os 15 elementos que faltam do catálogo de biomas, kit de UI (9-slice, botões, ícones), transições e easing, mapas de cidade, áreas de clique compartilhadas entre Step e Draw.
- [ ] **Sprint 7: Rejogabilidade**: dificuldade, hardcore, modo Buraco Negro (infinito), conquistas, mais itens, skins.
- [ ] **Sprint 8: Lançamento**: BGM/SFX com licença livre, PT-BR/EN-US, balanceamento, build testado em máquina limpa.

## 6. Regras para a IA
* Leia `scr_conteudo`, `scr_pokemon_data`, `scr_pokemon_progressao` e `scr_demo_playable` antes de grandes refatorações.
* Depois de mudar código, compile (`.codex_tools\gms.cmd compile --target=windows --errors-only PokemonRogueLike.yyp`)
  e rode `tools\autoteste.ps1`; confira o `log.txt` e os screenshots.
* Novo conteúdo nunca pode copiar nomes, personagens, arte, músicas ou mapas de jogos existentes.
