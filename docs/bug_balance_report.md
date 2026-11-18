# RELATORIO DE BALANCEAMENTO - TIPO INSETO
Data: 2026-06-09

## Objetivo
- Implementar Inseto como tipo completo, com 3 caminhos de build.
- Fazer o tipo conversar com Grass, Poison, Ground, Flying, Electric e Psychic.
- Evitar dano explosivo demais: Inseto vence por rotacao, controle e janelas pequenas.

## Arquétipos finais
1. **Tatica de Enxame**
   Identidade: alta rotacao, muitos golpes pequenos, dano constante.
   Perfil de atributos: HP baixo, ataque bom, defesa baixa, velocidade alta.
   Sinergias: VentoDeCauda, Envenenado, SedaPresa, Infestado.

2. **Casulo Rigido**
   Identidade: resistencia, sustentacao e golpes que melhoram quando protegido.
   Perfil de atributos: HP alto, ataque baixo/medio, defesa muito alta, velocidade baixa.
   Sinergias: CasuloRigido, Metamorfose, Enraizado, SedaPresa.

3. **Fio de Seda**
   Identidade: controle de cooldown e setup de combo.
   Perfil de atributos: equilibrado, levemente veloz, dano moderado.
   Sinergias: Enraizado, Envenenado, AreiaMovedica, Infestado.

## Status implementados
- **EnxameAtivo**: aura. Aumenta dano do usuario em 5% por 5.0s.
- **CasuloRigido**: aura. Aumenta defesa efetiva em 16% por 5.5s.
- **Metamorfose**: aura. Aumenta dano em 6% e defesa efetiva em 4% por 6.0s.
- **SedaPresa**: icone. Reduz ataque do afetado em 4%, defesa efetiva em 6% e combina com atraso de cooldown por 5.5s.
- **Infestado**: icone. Reduz ataque do afetado em 3%, defesa efetiva em 4% e prepara finalizadores por 6.0s.

## Habilidades - Tatica de Enxame
Lv  1 | 💥 Corte Furioso       | Dano 18 | CD  3.2s | Aplica EnxameAtivo no usuario.
Lv 10 | 🪄 Chamado do Enxame   | Dano  8 | CD  6.4s | EnxameAtivo + reduz cooldowns do usuario em 18%.
Lv 10 | 💥 Missil de Espinhos  | Dano 28 | CD  4.0s | +12% dano se o usuario esta com EnxameAtivo.
Lv 15 | 💥 Agulha Dupla        | Dano 32 | CD  4.4s | +10% contra Envenenado e aplica Infestado.
Lv 20 | 💥 Tesoura X           | Dano 44 | CD  5.8s | +14% com EnxameAtivo e +8% contra SedaPresa.
Lv 25 | 💥 Bate e Volta        | Dano 46 | CD  6.2s | Reduz cooldowns em 25% e ganha +8% com VentoDeCauda.
Lv 30 | 💥 Megacolonia         | Dano 62 | CD  8.6s | +18% com EnxameAtivo, +14% contra Infestado, reaplica EnxameAtivo.

## Habilidades - Casulo Rigido
Lv  1 | 💥 Investida de Casulo | Dano 18 | CD  4.8s | Aplica CasuloRigido no usuario.
Lv 10 | 🪄 Casulo Rigido       | Dano  8 | CD  7.4s | CasuloRigido + cura 3% do HP maximo.
Lv 10 | 💥 Mordida Blindada    | Dano 30 | CD  5.4s | +12% dano se o usuario esta com CasuloRigido.
Lv 15 | 🪄 Guarda de Pupa      | Dano 12 | CD  8.2s | CasuloRigido + cura 4% do HP maximo.
Lv 20 | 💥 Muda Pesada         | Dano 42 | CD  7.0s | +14% com CasuloRigido e aplica Metamorfose.
Lv 25 | 💥 Esmaga Casulo       | Dano 56 | CD  8.8s | +18% com CasuloRigido e +8% contra SedaPresa.
Lv 30 | 🪄 Muralha de Quitina  | Dano 58 | CD 10.2s | CasuloRigido + cura 5% + bonus defensivo.

## Habilidades - Fio de Seda
Lv  1 | 🪄 Tiro de Seda        | Dano 16 | CD  4.2s | Aplica SedaPresa e atrasa cooldowns do alvo em 15%.
Lv 10 | 🪄 Laco de Seda        | Dano 12 | CD  6.8s | Aplica SedaPresa e atrasa cooldowns em 25%.
Lv 10 | 💥 Larva Drenante      | Dano 26 | CD  5.4s | Cura 8% do dano causado e +8% contra Enraizado.
Lv 15 | 🪄 Infestacao          | Dano 28 | CD  7.2s | Aplica Infestado e +12% contra SedaPresa.
Lv 20 | 🪄 Armadilha de Seda   | Dano 22 | CD  8.0s | Aplica SedaPresa, atrasa 35% e +8% contra AreiaMovedica.
Lv 25 | 💥 Agulhas de Enxame   | Dano 44 | CD  6.4s | +12% contra Infestado e +10% contra Envenenado.
Lv 30 | 💥 Prisao de Teia      | Dano 60 | CD 10.0s | Aplica SedaPresa, atrasa 50%, +18% contra SedaPresa e +10% contra Enraizado.

## Passivas 🛡️
- **Tatica de Enxame**
  Passiva 1: Ritmo de Enxame - EnxameAtivo melhora golpes rapidos e mantem a barra girando.
  Passiva 2: Corte em Cadeia - Velocidade alta transforma dano leve em pressao constante.

- **Casulo Rigido**
  Passiva 1: Quitina Reforcada - CasuloRigido aumenta resistencia e sustenta rotas longas.
  Passiva 2: Muda Segura - Metamorfose converte defesa acumulada em pressao de contra-ataque.

- **Fio de Seda**
  Passiva 1: Teia Aderente - SedaPresa atrasa cooldowns e abre combos com Enraizado e AreiaMovedica.
  Passiva 2: Infestacao Oportunista - Infestado conversa com Veneno, Grama e finalizadores de controle.

## Distribuicao de Pokemon por perfil
- Tatica de Enxame: Butterfree, Scyther, Pinsir, Ledian, Yanma, Scizor, Beautifly, Masquerain, Ninjask, Volbeat, Illumise, Kricketune, Mothim, Yanmega, Leavanny, Karrablast, Accelgor, Durant, Genesect.
- Casulo Rigido: Metapod, Kakuna, Pineco, Forretress, Shuckle, Silcoon, Cascoon, Anorith, Armaldo, Burmy, Wormadam, Combee, Vespiquen, Dwebble, Crustle, Escavalier, Shelmet.
- Fio de Seda: Caterpie, Paras, Parasect, Venonat, Venomoth, Ledyba, Spinarak, Ariados, Wurmple, Dustox, Surskit, Nincada, Shedinja, Kricketot, Sewaddle, Swadloon, Venipede, Whirlipede, Scolipede, Joltik, Galvantula.

## Regras de dual-type
- Grass/Bug: tende a Fio de Seda para combinar Enraizado + SedaPresa; Leavanny e similares ainda podem puxar rotacao por Enxame nos drafts.
- Poison/Bug: Poison continua bom como identidade principal em linhas toxicas, mas recebe Agulha Dupla, Infestacao e Agulhas de Enxame como pontes.
- Bug/Flying: Inseto tem prioridade antes de Voador no DB para evitar que Butterfree/Yanmega virem apenas suporte de vento.
- Bug/Electric: Joltik/Galvantula herdam Electric como identidade quando a prioridade eletrica pegar, mas agora conseguem receber habilidades de seda como pool secundaria.
- Bug/Steel e Bug/Rock: entram muito bem em Casulo Rigido, com defesa alta e cooldowns longos.

## Ideias de build
- Enxame Veloz: Corte Furioso -> Chamado do Enxame -> Tesoura X -> Bate e Volta. Bom para speed e times com VentoDeCauda.
- Teia Toxica: Tiro de Seda -> Infestacao -> Agulhas de Enxame -> qualquer golpe Poison. Forte com Envenenado e Corroendo.
- Jardim Preso: Enraizar/Leech Seed + Tiro de Seda + Larva Drenante. Build de atrito Grass/Bug.
- Casulo de Boss: Casulo Rigido -> Guarda de Pupa -> Muda Pesada -> Muralha de Quitina. Build lenta para segurar lideres.
- Controle de Campo: Armadilha de Seda + AreiaMovedica + ParalisiaMental. Atrasa cooldowns sem criar stun permanente.