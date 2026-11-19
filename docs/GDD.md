# Rasgo Temporal: Game Design Document

Versão de 19/11/2026, escrita depois da auditoria da Sprint 9. Descreve o jogo como ele está no código hoje e,
na seção 9, o que ainda falta para fechar a versão 1.0. Os números saem dos arquivos em `datafiles/data/`.

---

## 1. Visão

**Rasgo Temporal** é um roguelike auto-battler de criaturas colecionáveis. O jogador não controla golpe a golpe:
ele monta a equipe, escolhe habilidades nos drafts, decide rotas e itens, e assiste o combate em tempo real.

* **Plataforma**: Windows (GameMaker, GML). Resolução da interface: 1366x768.
* **Sessão**: uma run completa leva de 40 a 60 minutos; o Desafio Diário é a mesma run com semente fixa.
* **Público**: quem gosta de roguelikes curtos e de montar times com sinergias, sem exigência de reflexo.

### Pilares

1. **Decisões entre as lutas, não durante.** O peso está no draft de habilidades, na rota e na equipe.
2. **Sinergia legível.** Tipos, status e combos aparecem na tela com nome, cor e explicação no tooltip.
3. **Runs curtas e diferentes.** Rotas, encontros, drafts e missões são sorteados; a meta-progressão abre opções, não poder bruto.
4. **Conteúdo 100% original.** Nenhum nome, personagem, arte ou música de outra franquia.

## 2. Mundo e história

O **Sindicato Eclipse** libertou **Aeonox**, que rasgou o tempo sobre o **Vale de Cronaria**. Criaturas de outras eras
atravessam as fendas. Os guardiões **Lumis** e **Brotempo** tentaram contê-lo. O jogador sai da **Vila Alvorada** com um
parceiro dado pela **Prof. Sabia**, vence os líderes das cidades e fecha o rasgo derrotando Aeonox.

| Cidade | Líder (tipo) | Evento da cidade |
|---|---|---|
| Vila Alvorada | (nenhum) | Casa da Mãe |
| Porto Raízes | (nenhum) | Mercado do Porto |
| Pedralia | Tito Basalto (pedra) | Museu de Pedralia |
| Marévia | Ondina (água) | Ponte das Gaivotas |
| Voltara | Capitã Raia (elétrico) | Cais dos Cargueiros |
| Ilha Brasa | Dr. Calidus (fogo) | Laboratório Rachado |
| Cidadela Fenda | Vesper (terra) | Base do Eclipse |

## 3. Loops de jogo

### Loop da run
1. **Início**: introdução, escolha de 1 entre 3 iniciais do trio sorteado (ou o inicial fixo do Desafio Diário).
2. **Cidade**: mercado, centro (cura), laboratório, casa/evento, ginásio, NPC de missão. Autosave ao chegar.
3. **Draft de rota**: 2 a 3 rotas com bioma e tipos prováveis (escondidos no Hardcore).
4. **Rota**: 1 a N encontros (selvagens ou treinadores), drops de dinheiro e itens, chance de captura.
5. **Líder**: vencer dá insígnia, Fragmentos do Tempo e libera a próxima cidade.
6. **Chefe final**: Aeonox em 3 fases, todas no nível 30, com 25% de cura entre fases.
7. **Fim**: vitória (créditos, +12 fragmentos, libera o Buraco Negro) ou game over (equipe toda desmaiada).

### Loop de meta-progressão
Fragmentos do Tempo compram, na Loja Permanente, novos trios de iniciais e melhorias pequenas (dinheiro inicial,
kits de captura e cura, chance de treinador, dano da equipe). Conquistas liberam visuais do personagem.

## 4. Sistemas

### 4.1 Criaturas
* **129 criaturas**, **18 tipos**, 6 trios de iniciais (`criaturas.json`, gerado por `tools/gerar_conteudo.py`).
* **Raridade**: comum 16, incomum 26, rara 60, épica 24, lendária 3.
* **Estágios**: 68 no estágio 1, 42 no estágio 2, 19 no estágio 3 (evolução por nível).
* **Papéis** (definem a distribuição de atributos): bruto 29, veloz 28, equilibrado 21, muralha 19, tanque 17, vidro 15.
* Nível máximo 30. Variante cromática rara (chance aumentada pela melhoria Lente Cromática).

### 4.2 Combate
* Tempo real, automático. Cada criatura tem até 4 habilidades com recarga própria; a próxima a disparar fica destacada.
* Velocidades 1x, 1.5x, 2x e 3x, pausa, Bestiário, Mochila (pausa o combate), Trocar e Fugir.
* **Status**: Molhado, Enraizado, Queimado, Preso, Paralisado, Ofuscado, Envenenado, Corroendo, Fotossíntese,
  Crescimento, Armadura Derretida, Calor Concentrado/Escaldante, Fênix e outros, todos com tooltip.
* **Combos**: golpes que consomem marcas aplicadas por outros golpes. Avisos grandes na tela: COMBO!, DANO SINÉRGICO!, SINERGIA!
* **Sinergia cruzada** (`sinergias.json`, 21 regras): um golpe do tipo X ganha efeito quando a criatura tem outra habilidade do tipo Y.

### 4.3 Habilidades e draft
* Ao atingir os níveis **10, 15, 20, 25 e 30** abre um draft: 2 ou 3 opções entre habilidade nova e upgrade de tier.
* Tiers de habilidade: Bronze, Prata, Ouro e Diamante (mais dano ou recarga menor).
* Slots de habilidade abrem nos níveis 1, 10, 15 e 20; o slot ainda fechado mostra em que nível abre.
* Sem slot livre, o jogador escolhe qual habilidade substituir.

### 4.4 Captura e equipe
* Equipe de até 4 criaturas. Capturar com equipe cheia abre a tela de substituição.
* Chance: `(0.03 + força_da_cápsula * (0.15 + 0.85 * HP_perdido)) * mult_raridade + bônus de status`.
  Com HP cheio fica em torno de 7%; a Cápsula Mestra sempre captura.

### 4.5 Itens e economia
* **19 itens** (`itens.json`): cápsulas, poções, curas de status, frutas automáticas, cristal de nível e pós de batalha.
* Cada cidade tem sua lista de venda (`lojas_por_cidade`); os pós de batalha aparecem a partir de Pedralia.
* Dinheiro (M$) vem de vitórias e drops; a melhoria Bolsa de Vitórias aumenta o ganho.

### 4.6 Rotas, encontros e treinadores
* **52 rotas** em `rotas.json`, com biomas, descrição e faixa de encontros.
* Biomas montados com chão e até 16 elementos de cenário fora da trilha.
* Treinadores por bioma em `treinadores.json` (16 classes; uma delas é o agente do Sindicato Eclipse).

### 4.7 Missões
12 missões de NPC (`mundo.json`); uma é sorteada por cidade. Tipos: capturar tipo, capturar qualquer, vencer tipo,
vencer treinadores, entregar item e atingir nível. Até 3 ativas; recompensa na hora com aviso.

### 4.8 Modos e dificuldade
* **Dificuldades**: Fácil, Normal, Difícil e Hardcore. O Hardcore esconde os tipos das rotas, e os inimigos importantes usam uma cura forte por batalha.
* **Desafio Diário**: semente pela data (UTC); o inicial do dia é um estágio 1 comum, incomum ou raro.
  Uma tentativa oficial por dia, pontuação, histórico e sequência local.
* **Buraco Negro**: liberado ao vencer Aeonox. Ondas infinitas no nível 30, +10% de força por onda, com recorde salvo.

### 4.9 Meta-progressão
* Loja Permanente com **14 entradas**: 5 trios de iniciais e 9 melhorias com níveis
  (Lente Cromática, Radar de Treinadores, Bolsa de Vitórias, Ajuda da Mãe, Kit de Captura, Kit de Sobrevivência, Eco Ofensivo, Laço de Fenda).
* **14 conquistas** com aviso e tela própria; liberam 6 paletas do personagem do mapa.

### 4.10 Save, áudio e idiomas
* Autosave da run ao entrar na cidade (um slot); progresso permanente em `progresso.json` e `meta_progresso.ini`.
* Áudio sintetizado pelo próprio jogo: 7 músicas e 12 efeitos. Arquivos `.ogg` em `datafiles/audio/` substituem os sintetizados.
* Idiomas PT-BR e EN-US (interface). Habilidades, passivas e falas ainda só em português.

## 5. Interface (estado após a Sprint 9)

* **Kit de UI** (`scripts/scr_ui_kit`): paleta única (papel, tinta, ouro, vermelho, noite, ciano), painel de papel com
  sombra, faixa de título vermelha, cartões que sobem no hover, etiquetas de categoria, selo de moedas e a
  **borda de seleção** (brilho dourado pulsante com cantoneiras animadas), usada em todo elemento clicável.
* **Telas da cidade**: mercado em cartões de 2 colunas (preço verde/vermelho, quantos você tem, categoria);
  mochila em 4 colunas (quantidade em selo, "Usa sozinha" / "Só em batalha"); diálogos com retrato e título.
* **Batalha**: mochila em cartões no tema escuro, troca de criatura com contorno do ativo, slot da próxima habilidade pulsando em ciano.
* **Draft de habilidade**: cartões com borda de seleção; texto da descrição claro sobre o painel escuro.
* **Confirmação**: começar uma run nova ou o Diário com uma run salva pede confirmação (Enter confirma, Esc cancela).
* **Pausa na cidade**: botão Menu (ou Esc) salva a run e volta ao menu inicial; ela continua pelo botão CONTINUAR.
* **Texto**: fontes do sistema (Segoe UI) até chegarem fontes livres. Texto pequeno ou grande não é mais esticado:
  o jogo gera a fonte no tamanho final (com cache) e desenha nela, por isso etiquetas e selos ficam nítidos.

## 6. Direção de arte

* Visual 2D visto de cima nas cidades e rotas; batalha lateral com plataformas.
* Hoje quase tudo é placeholder procedural (criaturas por tipo/estágio/papel, treinadores, cidades, ícones de item).
* Tamanhos de referência e nomes de arquivo: `docs/como_adicionar_artes.txt`.

## 7. Conteúdo em números

| Item | Quantidade | Fonte |
|---|---|---|
| Criaturas | 129 | `criaturas.json` |
| Tipos | 18 | `criaturas.json` |
| Trios de iniciais | 6 | `criaturas.json` |
| Cidades | 7 | `mundo.json` |
| Líderes | 5 + chefe em 3 fases | `mundo.json` |
| Rotas | 52 | `rotas.json` |
| Itens | 19 | `itens.json` |
| Sinergias cruzadas | 21 | `sinergias.json` |
| Missões | 12 | `mundo.json` |
| Conquistas | 14 | `scr_rejogabilidade` |
| Melhorias permanentes | 14 | `scr_demo_playable` |
| Músicas / efeitos | 7 / 12 | `scr_audio` |

## 8. Ferramentas

* `tools/autoteste.ps1`: roda o jogo sozinho, tira 58 screenshots e grava `log.txt`.
* `tools/gerar_conteudo.py`, `tools/gerar_idiomas.py`, `tools/gerar_registro.py`: geram os JSON, o dicionário EN e o registro de mudanças.

## 9. Lacunas: o que falta para a 1.0

Prioridade: **A** = bloqueia lançamento, **B** = importante, **C** = desejável.

| # | Prio | Lacuna | Proposta |
|---|---|---|---|
| 1 | A | **Arte final**: as 129 criaturas (frente, costas, ícone), treinadores, cidades, interface e os 15 elementos de rota que faltam no catálogo. | O usuário adiciona aos poucos; o jogo já troca o placeholder pelo arquivo. |
| 2 | A | **Fontes livres**: hoje usa Segoe UI do Windows, que não pode ser distribuída e não existe fora do Windows. | Colocar uma fonte OFL legível (título e corpo) em `datafiles/fonts_jogo/`. Precisa da autorização do usuário para baixar. |
| 3 | A | **Balanceamento jogando**: curva de níveis por cidade, preços, chance de captura e força dos líderes só foram checados por autoteste. | 5 a 10 runs completas por dificuldade; anotar onde a run trava ou fica fácil. |
| 4 | A | **Exportar o .exe**: a licença de convidado não empacota. | O usuário entra com a conta GameMaker e roda o package. |
| 5 | B | **Tutorial / primeira run**: nada explica auto-battle, draft, sinergia e status. | Dicas contextuais na primeira vez de cada tela (draft, captura, sinergia), com opção de desligar. |
| 6 | B | **Tela de configurações**: som, idioma, dificuldade e visual são botões soltos no menu; não há volume separado nem tela cheia. | Uma tela única: volume de música e efeitos, tela cheia, velocidade padrão da batalha, idioma, tremida de tela. |
| 7 | B | **Pausa fora da cidade**: a cidade já tem "Sair para o menu" (Sprint 9), mas na rota e na batalha não há pausa com opções. | Esc abre pausa: continuar e configurações; sair só pela cidade, onde a run é salva. |
| 8 | B | **Navegação por teclado e controle**: quase tudo é só mouse. | Foco navegável com setas e Enter, usando a mesma borda de seleção. |
| 9 | B | **Tradução completa**: habilidades, passivas, falas e missões ainda em português no modo EN. | Mover esses textos para os JSON e gerar as chaves no `gerar_idiomas.py`. |
| 10 | B | **História entre cidades**: líderes não falam antes da luta; o Sindicato Eclipse quase não aparece. | Falas curtas de pré e pós-luta por líder em `mundo.json`; 2 encontros com o Eclipse no caminho. |
| 11 | C | **Acessibilidade**: tipos e status dependem de cor; texto não escala. | Ícone/letra em cada tipo, opção de texto maior, opção de reduzir tremida e flashes. |
| 12 | C | **Ranking online do Diário**: hoje só local. | Exige servidor; fora do escopo de um fan game offline. |
| 13 | C | **Dívida técnica**: `scr_demo_playable` tem ~7900 linhas; algumas telas antigas ainda calculam áreas de clique no Step e no Draw separadamente. | Dividir por tela (menu, cidade, rota, resultado) e usar funções de retângulo compartilhadas, como já foi feito na loja e na mochila. |
| 14 | C | **Áudio composto**: a trilha sintetizada funciona, mas é simples. | Trocar por `.ogg` com licença livre (CC0) quando houver. |
