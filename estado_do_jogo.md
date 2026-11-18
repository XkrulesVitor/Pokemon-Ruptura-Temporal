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
- [ ] **Sprint 3: Fechar a run**: chefe final Aeonox com fases, tela de vitória e créditos, save no meio da run, missões de NPC nas cidades (portar `scr_event_manager`).
- [ ] **Sprint 4: Desafio Diário**
  - Semente = data em UTC (AAAAMMDD), gerador próprio só para a jogabilidade (o RNG global também é usado por efeitos visuais).
  - Inicial do dia: criatura em estágio inicial (`criatura_e_estagio_inicial`) de raridade comum, incomum ou rara.
  - A semente fixa inicial, drafts de rota, encontros, times de treinador e drops. O combate em tempo real ainda varia.
  - Sem bônus da meta-loja. Uma tentativa oficial por dia + treino. Histórico, pontuação e sequência em `daily.json`.
- [ ] **Sprint 5: Combate**: captura pela fórmula de HP/status, sinergia cruzada entre golpes, aviso "COMBO!", VFX por tipo.
- [ ] **Sprint 6: Gráficos (tudo que não é criatura)**: elementos de rota em PNG com transparência, os 15 elementos que faltam do catálogo de biomas, kit de UI (9-slice, botões, ícones), transições e easing, mapas de cidade, áreas de clique compartilhadas entre Step e Draw.
- [ ] **Sprint 7: Rejogabilidade**: dificuldade, hardcore, modo Buraco Negro (infinito), conquistas, mais itens, skins.
- [ ] **Sprint 8: Lançamento**: BGM/SFX com licença livre, PT-BR/EN-US, balanceamento, build testado em máquina limpa.

## 6. Regras para a IA
* Leia `scr_conteudo`, `scr_pokemon_data`, `scr_pokemon_progressao` e `scr_demo_playable` antes de grandes refatorações.
* Depois de mudar código, compile (`.codex_tools\gms.cmd compile --target=windows --errors-only PokemonRogueLike.yyp`)
  e rode `tools\autoteste.ps1`; confira o `log.txt` e os screenshots.
* Novo conteúdo nunca pode copiar nomes, personagens, arte, músicas ou mapas de jogos existentes.
