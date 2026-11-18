enum EstadoJogo {
    EXPLORACAO,
    BATALHA,
    DRAFT_HABILIDADE,
    EVENTO_NARRATIVO,
    GAME_OVER
}

function PokemonLevelUpResult() constructor {
    LevelInicial = 1;
    LevelFinal = 1;
    SubiuNivel = false;
    GanhosPorNivel = [];
    DraftsGerados = [];
    Evolucoes = [];
}

function PokemonStatGain(_level, _hp, _attack, _defense, _speed) constructor {
    Level = _level;
    Hp = _hp;
    Attack = _attack;
    Defense = _defense;
    Speed = _speed;
}

function PokemonHabilidadeDraft(_pokemon, _level, _opcoes) constructor {
    Pokemon = _pokemon;
    Level = _level;
    Opcoes = _opcoes;
    PrecisaSubstituir = pokemon_habilidades_equipadas_quantidade(_pokemon) >= 4;
    TipoDraft = pokemon_draft_tipo_por_level(_level);
    Resolvido = false;
}

function pokemon_level_marcos_draft() {
    return [10, 15, 20, 25, 30];
}

function pokemon_draft_tipo_por_level(_level) {
    switch (_level) {
        case 20: return "slot_ou_upgrade";
        case 25:
        case 30:
            return "upgrade";
    }

    return "habilidade";
}

function pokemon_level_eh_marco_draft(_level) {
    var _marcos = pokemon_level_marcos_draft();

    for (var _i = 0; _i < array_length(_marcos); _i += 1) {
        if (_level == _marcos[_i]) {
            return true;
        }
    }

    return false;
}

function pokemon_habilidades_equipadas_quantidade(_pokemon) {
    if (!is_struct(_pokemon)) {
        return 0;
    }

    var _total = 0;

    for (var _i = 0; _i < 4; _i += 1) {
        if (is_struct(_pokemon.HabilidadesEquipadas[_i])) {
            _total += 1;
        }
    }

    return _total;
}

function pokemon_tem_habilidade(_pokemon, _habilidade_id) {
    if (!is_struct(_pokemon)) {
        return false;
    }

    for (var _i = 0; _i < 4; _i += 1) {
        var _habilidade = _pokemon.HabilidadesEquipadas[_i];

        if (is_struct(_habilidade) && _habilidade.ID == _habilidade_id) {
            return true;
        }
    }

    return false;
}

function pokemon_habilidade_pool_disponivel(_pokemon, _level) {
    var _pool = [];

    if (!is_struct(_pokemon)) {
        return _pool;
    }

    for (var _i = 0; _i < array_length(_pokemon.ListaHabilidadesDisponiveis); _i += 1) {
        var _habilidade = _pokemon.ListaHabilidadesDisponiveis[_i];

        if (!is_struct(_habilidade)) {
            continue;
        }

        var _nivel_permitido = _habilidade.NivelAprendizado <= _level;

        if (_level == 20 && _habilidade.NivelAprendizado <= 25) {
            _nivel_permitido = true;
        }

        if (_nivel_permitido && !pokemon_tem_habilidade(_pokemon, _habilidade.ID)) {
            array_push(_pool, _habilidade);
        }
    }

    return _pool;
}

function pokemon_sortear_habilidades_draft(_pokemon, _level) {
    var _pool = pokemon_habilidade_pool_disponivel(_pokemon, _level);
    var _opcoes = [];

    repeat (min(2, array_length(_pool))) {
        var _index = irandom(array_length(_pool) - 1);
        array_push(_opcoes, _pool[_index]);
        array_delete(_pool, _index, 1);
    }

    if (array_length(_opcoes) < 2) {
        var _upgrades = pokemon_sortear_upgrades_draft(_pokemon);

        for (var _u = 0; _u < array_length(_upgrades) && array_length(_opcoes) < 2; _u += 1) {
            array_push(_opcoes, _upgrades[_u]);
        }
    }

    return _opcoes;
}

function pokemon_habilidade_tier_nome(_tier) {
    switch (clamp(_tier, 0, 3)) {
        case 0: return "Bronze";
        case 1: return "Prata";
        case 2: return "Ouro";
        case 3: return "Diamante";
    }

    return "Bronze";
}

function pokemon_habilidade_upgrade_option(_habilidade) {
    var _tier = is_struct(_habilidade) && variable_struct_exists(_habilidade, "Tier") ? _habilidade.Tier : 0;

    return {
        TipoOpcao: "upgrade",
        HabilidadeID: _habilidade.ID,
        Nome: "Upgrade: " + _habilidade.Nome,
        TipoElementar: _habilidade.TipoElementar,
        DanoBase: _habilidade.DanoBase,
        TempoRecargaMax: _habilidade.TempoRecargaMax,
        TierAtual: _tier,
        ProximoTier: min(3, _tier + 1),
        HabilidadeRef: _habilidade
    };
}

function pokemon_sortear_upgrades_draft(_pokemon) {
    var _pool = [];

    if (!is_struct(_pokemon)) {
        return _pool;
    }

    for (var _i = 0; _i < 4; _i += 1) {
        var _habilidade = _pokemon.HabilidadesEquipadas[_i];

        if (is_struct(_habilidade)) {
            var _tier = variable_struct_exists(_habilidade, "Tier") ? _habilidade.Tier : 0;

            if (_tier < 3) {
                array_push(_pool, pokemon_habilidade_upgrade_option(_habilidade));
            }
        }
    }

    var _opcoes = [];

    repeat (min(2, array_length(_pool))) {
        var _index = irandom(array_length(_pool) - 1);
        array_push(_opcoes, _pool[_index]);
        array_delete(_pool, _index, 1);
    }

    return _opcoes;
}

function pokemon_sortear_opcoes_draft(_pokemon, _level) {
    var _tipo = pokemon_draft_tipo_por_level(_level);

    if (_tipo == "upgrade") {
        return pokemon_sortear_upgrades_draft(_pokemon);
    }

    if (_tipo == "slot_ou_upgrade") {
        var _skills = pokemon_sortear_habilidades_draft(_pokemon, _level);
        var _upgrades = pokemon_sortear_upgrades_draft(_pokemon);
        var _opcoes = [];

        if (array_length(_skills) > 0 && pokemon_slot_desbloqueado(_pokemon, 3)) {
            array_push(_opcoes, _skills[0]);
        }

        if (array_length(_upgrades) > 0) {
            array_push(_opcoes, _upgrades[0]);
        }

        while (array_length(_opcoes) < 2 && array_length(_skills) > array_length(_opcoes)) {
            array_push(_opcoes, _skills[array_length(_opcoes)]);
        }

        return _opcoes;
    }

    return pokemon_sortear_habilidades_draft(_pokemon, _level);
}

function pokemon_draft_garantir_globals() {
    if (!variable_global_exists("estado_jogo")) {
        global.estado_jogo = EstadoJogo.EXPLORACAO;
    }

    if (!variable_global_exists("batalha_pausada")) {
        global.batalha_pausada = false;
    }

    if (!variable_global_exists("draft_habilidade_atual")) {
        global.draft_habilidade_atual = undefined;
    }

    if (!variable_global_exists("estado_jogo_antes_draft")) {
        global.estado_jogo_antes_draft = EstadoJogo.BATALHA;
    }

    if (!variable_global_exists("draft_habilidade_fila")) {
        global.draft_habilidade_fila = [];
    }
}

// Sorteios desta funcao sao deterministicos no Desafio Diario.
function pokemon_draft_disparar(_pokemon, _level) {
    var _escopo = diario_escopo("habilidade:" + string(is_struct(_pokemon) ? _pokemon.ID : 0) + ":" + string(_level));
    var _resultado = pokemon_draft_disparar_base(_pokemon, _level);
    diario_escopo_fim(_escopo);
    return _resultado;
}

function pokemon_draft_disparar_base(_pokemon, _level) {
    pokemon_draft_garantir_globals();

    var _opcoes = pokemon_sortear_opcoes_draft(_pokemon, _level);

    if (array_length(_opcoes) <= 0) {
        return undefined;
    }

    var _draft = new PokemonHabilidadeDraft(_pokemon, _level, _opcoes);
    array_push(global.draft_habilidade_fila, _draft);

    if (!is_struct(global.draft_habilidade_atual)) {
        pokemon_draft_proximo();
    }

    return _draft;
}

function pokemon_draft_inicial(_pokemon) {
    if (!is_struct(_pokemon)) {
        return undefined;
    }

    return pokemon_draft_disparar(_pokemon, 1);
}

function pokemon_progressao_auto_resolver_ate_level(_pokemon) {
    if (!is_struct(_pokemon)) {
        return;
    }

    var _marcos = pokemon_level_marcos_draft();

    for (var _m = 0; _m < array_length(_marcos); _m += 1) {
        var _level = _marcos[_m];

        if (_pokemon.Level < _level) {
            continue;
        }

        var _opcoes = pokemon_sortear_opcoes_draft(_pokemon, _level);

        if (array_length(_opcoes) <= 0) {
            continue;
        }

        var _choice = _opcoes[irandom(array_length(_opcoes) - 1)];

        if (is_struct(_choice) && variable_struct_exists(_choice, "TipoOpcao") && _choice.TipoOpcao == "upgrade") {
            pokemon_habilidade_aplicar_upgrade(_pokemon, _choice.HabilidadeID);

            if (_level == 20) {
                _pokemon.Slot4Trancado = true;
            }
        } else {
            var _slot = pokemon_primeiro_slot_habilidade_livre_desbloqueado(_pokemon);

            if (_slot >= 0) {
                _pokemon.HabilidadesEquipadas[_slot] = habilidade_runtime_criar(_choice);
            }
        }
    }
}

function pokemon_build_array_tem(_array, _valor) {
    if (!is_array(_array)) {
        return false;
    }

    for (var _i = 0; _i < array_length(_array); _i += 1) {
        if (_array[_i] == _valor) {
            return true;
        }
    }

    return false;
}

function pokemon_build_array_push_unico(_array, _valor) {
    if (!is_array(_array) || _valor == "") {
        return _array;
    }

    if (!pokemon_build_array_tem(_array, _valor)) {
        array_push(_array, _valor);
    }

    return _array;
}

function pokemon_build_efeito_args(_efeito, _prefixo) {
    var _args = [];

    if (!is_string(_efeito) || string_pos(_prefixo, _efeito) != 1) {
        return _args;
    }

    var _resto = string_copy(_efeito, string_length(_prefixo) + 1, string_length(_efeito));
    var _token = "";

    for (var _i = 1; _i <= string_length(_resto); _i += 1) {
        var _char = string_char_at(_resto, _i);

        if (_char == ":") {
            array_push(_args, _token);
            _token = "";
        } else {
            _token += _char;
        }
    }

    array_push(_args, _token);
    return _args;
}

function pokemon_build_efeitos_coletar(_habilidade) {
    var _efeitos = [];

    if (!is_struct(_habilidade)) {
        return _efeitos;
    }

    if (is_string(_habilidade.EfeitoEspecial) && _habilidade.EfeitoEspecial != "") {
        array_push(_efeitos, _habilidade.EfeitoEspecial);
    }

    if (is_array(_habilidade.Efeitos)) {
        for (var _i = 0; _i < array_length(_habilidade.Efeitos); _i += 1) {
            if (is_string(_habilidade.Efeitos[_i]) && _habilidade.Efeitos[_i] != "") {
                array_push(_efeitos, _habilidade.Efeitos[_i]);
            }
        }
    }

    return _efeitos;
}

function pokemon_build_statuses_aplicados(_habilidade, _usuario) {
    var _status = [];
    var _prefixo = _usuario ? "aplicar_status_usuario:" : "aplicar_status:";
    var _efeitos = pokemon_build_efeitos_coletar(_habilidade);

    for (var _i = 0; _i < array_length(_efeitos); _i += 1) {
        var _args = pokemon_build_efeito_args(_efeitos[_i], _prefixo);

        if (array_length(_args) >= 1) {
            _status = pokemon_build_array_push_unico(_status, _args[0]);
        }
    }

    return _status;
}

function pokemon_build_statuses_consumidos(_habilidade, _usuario) {
    var _status = [];

    if (!is_struct(_habilidade)) {
        return _status;
    }

    if (!_usuario && is_string(_habilidade.ComboID) && _habilidade.ComboID != "") {
        _status = pokemon_build_array_push_unico(_status, _habilidade.ComboID);
    }

    var _prefixo = _usuario ? "bonus_dano_usuario_status:" : "bonus_dano_alvo_status:";
    var _efeitos = pokemon_build_efeitos_coletar(_habilidade);

    for (var _i = 0; _i < array_length(_efeitos); _i += 1) {
        var _args = pokemon_build_efeito_args(_efeitos[_i], _prefixo);

        if (array_length(_args) >= 1) {
            _status = pokemon_build_array_push_unico(_status, _args[0]);
        }
    }

    return _status;
}

function pokemon_build_intersecao_quantidade(_a, _b) {
    if (!is_array(_a) || !is_array(_b)) {
        return 0;
    }

    var _total = 0;

    for (var _i = 0; _i < array_length(_a); _i += 1) {
        if (pokemon_build_array_tem(_b, _a[_i])) {
            _total += 1;
        }
    }

    return _total;
}

function pokemon_build_habilidade_score(_pokemon, _habilidade, _contexto) {
    if (!is_struct(_pokemon) || !is_struct(_habilidade)) {
        return 0;
    }

    var _score = 1.0 + random(0.35);
    var _tipo = variable_struct_exists(_habilidade, "TipoElementar") ? _habilidade.TipoElementar : _habilidade.Tipo;

    if (_pokemon.Tipo1 == _tipo || _pokemon.Tipo2 == _tipo) {
        _score += 0.18;
    }

    if (_habilidade.DanoBase > 0) {
        _score += clamp(_habilidade.DanoBase / 90, 0.04, 0.48);
    } else {
        _score -= 0.12;
    }

    _score += clamp((7.0 - _habilidade.TempoRecargaMax) * 0.035, -0.10, 0.18);

    var _cand_aplica_alvo = pokemon_build_statuses_aplicados(_habilidade, false);
    var _cand_aplica_self = pokemon_build_statuses_aplicados(_habilidade, true);
    var _cand_consum_alvo = pokemon_build_statuses_consumidos(_habilidade, false);
    var _cand_consum_self = pokemon_build_statuses_consumidos(_habilidade, true);

    if (array_length(_cand_aplica_alvo) > 0 || array_length(_cand_aplica_self) > 0) {
        _score += 0.16;
    }

    for (var _slot = 0; _slot < 4; _slot += 1) {
        var _equipada = _pokemon.HabilidadesEquipadas[_slot];

        if (!is_struct(_equipada)) {
            continue;
        }

        var _eq_aplica_alvo = pokemon_build_statuses_aplicados(_equipada, false);
        var _eq_aplica_self = pokemon_build_statuses_aplicados(_equipada, true);
        var _eq_consum_alvo = pokemon_build_statuses_consumidos(_equipada, false);
        var _eq_consum_self = pokemon_build_statuses_consumidos(_equipada, true);

        _score += pokemon_build_intersecao_quantidade(_cand_consum_alvo, _eq_aplica_alvo) * 0.90;
        _score += pokemon_build_intersecao_quantidade(_eq_consum_alvo, _cand_aplica_alvo) * 0.72;
        _score += pokemon_build_intersecao_quantidade(_cand_consum_self, _eq_aplica_self) * 0.55;
        _score += pokemon_build_intersecao_quantidade(_eq_consum_self, _cand_aplica_self) * 0.48;
        _score += pokemon_build_intersecao_quantidade(_cand_aplica_alvo, _eq_aplica_alvo) * 0.10;
    }

    switch (_contexto) {
        case "ginasio":
            _score += _habilidade.DanoBase > 0 ? 0.30 : -0.08;
            _score += (array_length(_cand_aplica_alvo) > 0 || array_length(_cand_consum_alvo) > 0) ? 0.22 : 0;
            break;

        case "rocket":
            _score += _habilidade.DanoBase > 0 ? 0.24 : -0.06;
            _score += array_length(_cand_aplica_alvo) > 0 ? 0.16 : 0;
            break;

        case "treinador":
            _score += _habilidade.DanoBase > 0 ? 0.16 : 0;
            break;

        case "selvagem":
            _score += _habilidade.DanoBase > 0 ? 0.12 : -0.04;
            break;
    }

    return max(0.05, _score);
}

function pokemon_build_escolher_habilidade(_pokemon, _pool, _contexto) {
    if (!is_array(_pool) || array_length(_pool) <= 0) {
        return noone;
    }

    var _pesos = [];
    var _total = 0;

    for (var _i = 0; _i < array_length(_pool); _i += 1) {
        var _peso = pokemon_build_habilidade_score(_pokemon, _pool[_i], _contexto);
        array_push(_pesos, _peso);
        _total += _peso;
    }

    var _roll = random(max(0.01, _total));

    for (var _j = 0; _j < array_length(_pool); _j += 1) {
        _roll -= _pesos[_j];

        if (_roll <= 0) {
            return _pool[_j];
        }
    }

    return _pool[array_length(_pool) - 1];
}

function pokemon_build_upgrade_id_escolher(_pokemon) {
    if (!is_struct(_pokemon)) {
        return "";
    }

    var _ids = [];
    var _pesos = [];
    var _total = 0;

    for (var _i = 0; _i < 4; _i += 1) {
        var _habilidade = _pokemon.HabilidadesEquipadas[_i];

        if (!is_struct(_habilidade)) {
            continue;
        }

        var _tier = variable_struct_exists(_habilidade, "Tier") ? _habilidade.Tier : 0;

        if (_tier >= 3) {
            continue;
        }

        var _peso = 1.0 + clamp(_habilidade.DanoBase / 80, 0, 0.60) + clamp((7.5 - _habilidade.TempoRecargaMax) * 0.04, -0.08, 0.16);
        array_push(_ids, _habilidade.ID);
        array_push(_pesos, _peso);
        _total += _peso;
    }

    if (array_length(_ids) <= 0) {
        return "";
    }

    var _roll = random(max(0.01, _total));

    for (var _j = 0; _j < array_length(_ids); _j += 1) {
        _roll -= _pesos[_j];

        if (_roll <= 0) {
            return _ids[_j];
        }
    }

    return _ids[array_length(_ids) - 1];
}

function pokemon_build_aplicar_upgrade_ponderado(_pokemon) {
    var _id = pokemon_build_upgrade_id_escolher(_pokemon);

    if (_id == "") {
        return false;
    }

    return pokemon_habilidade_aplicar_upgrade(_pokemon, _id);
}

function pokemon_progressao_inimigo_bonus_contexto(_pokemon, _contexto) {
    if (!is_struct(_pokemon)) {
        return;
    }

    var _hp_mult = 1.0;
    var _atk_mult = 1.0;
    var _def_mult = 1.0;
    var _spd_mult = 1.0;

    switch (_contexto) {
        case "ginasio":
            _hp_mult = 1.12;
            _atk_mult = 1.08;
            _def_mult = 1.06;
            _spd_mult = 1.04;
            break;

        case "rocket":
            _hp_mult = 1.06;
            _atk_mult = 1.07;
            _def_mult = 1.03;
            _spd_mult = 1.04;
            break;

        case "treinador":
            _hp_mult = 1.04;
            _atk_mult = 1.04;
            _def_mult = 1.03;
            _spd_mult = 1.02;
            break;
    }

    _pokemon.HpMax = max(1, round(_pokemon.HpMax * _hp_mult));
    _pokemon.Attack = max(1, round(_pokemon.Attack * _atk_mult));
    _pokemon.Defense = max(1, round(_pokemon.Defense * _def_mult));
    _pokemon.Speed = max(1, round(_pokemon.Speed * _spd_mult));
    _pokemon.HpAtual = _pokemon.HpMax;
}

function pokemon_progressao_inimigo_randomizar_build(_pokemon, _contexto) {
    if (!is_struct(_pokemon)) {
        return;
    }

    if (argument_count < 2 || !is_string(_contexto) || _contexto == "") {
        _contexto = "selvagem";
    }

    for (var _slot_reset = 0; _slot_reset < 4; _slot_reset += 1) {
        _pokemon.HabilidadesEquipadas[_slot_reset] = noone;
    }

    _pokemon.Slot4Trancado = false;

    var _pool_inicial = [];

    for (var _i = 0; _i < array_length(_pokemon.ListaHabilidadesDisponiveis); _i += 1) {
        var _habilidade_inicial = _pokemon.ListaHabilidadesDisponiveis[_i];

        if (is_struct(_habilidade_inicial) && _habilidade_inicial.NivelAprendizado <= 1) {
            array_push(_pool_inicial, _habilidade_inicial);
        }
    }

    if (array_length(_pool_inicial) <= 0 && array_length(_pokemon.ListaHabilidadesDisponiveis) > 0) {
        array_push(_pool_inicial, _pokemon.ListaHabilidadesDisponiveis[0]);
    }

    var _primeira = pokemon_build_escolher_habilidade(_pokemon, _pool_inicial, _contexto);

    if (is_struct(_primeira)) {
        _pokemon.HabilidadesEquipadas[0] = habilidade_runtime_criar(_primeira);
    }

    var _marcos_skills = [10, 15, 20];

    for (var _m = 0; _m < array_length(_marcos_skills); _m += 1) {
        var _level = _marcos_skills[_m];

        if (_pokemon.Level < _level) {
            continue;
        }

        if (_level == 20) {
            var _chance_especializar = _contexto == "ginasio" ? 0.25 : (_contexto == "selvagem" ? 0.22 : 0.32);

            if (random(1) < _chance_especializar && pokemon_build_aplicar_upgrade_ponderado(_pokemon)) {
                _pokemon.Slot4Trancado = true;
                continue;
            }
        }

        var _slot = pokemon_primeiro_slot_habilidade_livre_desbloqueado(_pokemon);

        if (_slot < 0) {
            pokemon_build_aplicar_upgrade_ponderado(_pokemon);
            continue;
        }

        var _pool = pokemon_habilidade_pool_disponivel(_pokemon, _level);
        var _escolha = pokemon_build_escolher_habilidade(_pokemon, _pool, _contexto);

        if (is_struct(_escolha)) {
            _pokemon.HabilidadesEquipadas[_slot] = habilidade_runtime_criar(_escolha);
        } else {
            pokemon_build_aplicar_upgrade_ponderado(_pokemon);
        }
    }

    if (_pokemon.Level >= 25) {
        pokemon_build_aplicar_upgrade_ponderado(_pokemon);
    }

    if (_pokemon.Level >= 30) {
        pokemon_build_aplicar_upgrade_ponderado(_pokemon);
    }

    if (_contexto == "ginasio") {
        pokemon_build_aplicar_upgrade_ponderado(_pokemon);
    } else if (_contexto == "rocket" && _pokemon.Level >= 15) {
        pokemon_build_aplicar_upgrade_ponderado(_pokemon);
    }

    pokemon_progressao_inimigo_bonus_contexto(_pokemon, _contexto);
    _pokemon.BuildOrigem = _contexto;
    _pokemon.BuildSelvagemRolada = _contexto == "selvagem";
    _pokemon.BuildCongeladaAoCapturar = true;
}

function pokemon_slot_desbloqueado(_pokemon, _slot) {
    if (!is_struct(_pokemon)) {
        return false;
    }

    if (variable_struct_exists(_pokemon, "Slot4Trancado") && _pokemon.Slot4Trancado && _slot == 3) {
        return false;
    }

    switch (_slot) {
        case 0: return _pokemon.Level >= 1;
        case 1: return _pokemon.Level >= 10;
        case 2: return _pokemon.Level >= 15;
        case 3: return _pokemon.Level >= 20;
    }

    return false;
}

function pokemon_primeiro_slot_habilidade_livre_desbloqueado(_pokemon) {
    if (!is_struct(_pokemon)) {
        return -1;
    }

    for (var _i = 0; _i < 4; _i += 1) {
        if (pokemon_slot_desbloqueado(_pokemon, _i) && !is_struct(_pokemon.HabilidadesEquipadas[_i])) {
            return _i;
        }
    }

    return -1;
}

function pokemon_draft_proximo() {
    pokemon_draft_garantir_globals();

    if (array_length(global.draft_habilidade_fila) <= 0) {
        global.draft_habilidade_atual = undefined;
        global.batalha_pausada = false;
        global.estado_jogo = global.estado_jogo_antes_draft;
        return undefined;
    }

    if (global.estado_jogo != EstadoJogo.DRAFT_HABILIDADE) {
        global.estado_jogo_antes_draft = global.estado_jogo;
    }

    global.draft_habilidade_atual = global.draft_habilidade_fila[0];
    array_delete(global.draft_habilidade_fila, 0, 1);
    global.batalha_pausada = true;
    global.estado_jogo = EstadoJogo.DRAFT_HABILIDADE;

    return global.draft_habilidade_atual;
}

function pokemon_draft_escolher(_draft, _opcao_index, _slot_substituir) {
    if (!is_struct(_draft) || _draft.Resolvido) {
        return false;
    }

    if (_opcao_index < 0 || _opcao_index >= array_length(_draft.Opcoes)) {
        return false;
    }

    var _pokemon = _draft.Pokemon;
    var _habilidade = _draft.Opcoes[_opcao_index];

    if (is_struct(_habilidade) && variable_struct_exists(_habilidade, "TipoOpcao") && _habilidade.TipoOpcao == "upgrade") {
        var _ok_upgrade = pokemon_habilidade_aplicar_upgrade(_pokemon, _habilidade.HabilidadeID);

        if (_ok_upgrade && _draft.Level == 20) {
            _pokemon.Slot4Trancado = true;
        }

        _draft.Resolvido = true;
        pokemon_draft_proximo();
        return _ok_upgrade;
    }

    var _slot = _slot_substituir;

    if (argument_count < 3 || _slot < 0) {
        _slot = pokemon_primeiro_slot_habilidade_livre_desbloqueado(_pokemon);
    }

    if (_slot < 0 || _slot >= 4 || !pokemon_slot_desbloqueado(_pokemon, _slot)) {
        return false;
    }

    _pokemon.HabilidadesEquipadas[_slot] = habilidade_runtime_criar(_habilidade);
    _draft.Resolvido = true;
    pokemon_draft_proximo();
    return true;
}

function pokemon_primeiro_slot_habilidade_livre(_pokemon) {
    if (!is_struct(_pokemon)) {
        return -1;
    }

    for (var _i = 0; _i < 4; _i += 1) {
        if (!is_struct(_pokemon.HabilidadesEquipadas[_i])) {
            return _i;
        }
    }

    return -1;
}

function pokemon_habilidade_aplicar_upgrade(_pokemon, _habilidade_id) {
    if (!is_struct(_pokemon)) {
        return false;
    }

    for (var _i = 0; _i < 4; _i += 1) {
        var _habilidade = _pokemon.HabilidadesEquipadas[_i];

        if (!is_struct(_habilidade) || _habilidade.ID != _habilidade_id) {
            continue;
        }

        if (!variable_struct_exists(_habilidade, "Tier")) _habilidade.Tier = 0;
        if (!variable_struct_exists(_habilidade, "UpgradeDanoPct")) _habilidade.UpgradeDanoPct = 0;
        if (!variable_struct_exists(_habilidade, "UpgradeCooldownPct")) _habilidade.UpgradeCooldownPct = 0;

        if (_habilidade.Tier >= 3) {
            return false;
        }

        _habilidade.Tier += 1;

        switch (_habilidade.Tier) {
            case 1:
                if (irandom(1) == 0) _habilidade.UpgradeDanoPct += 0.10; else _habilidade.UpgradeCooldownPct += 0.10;
                break;
            case 2:
                if (irandom(1) == 0) _habilidade.UpgradeDanoPct += 0.15; else _habilidade.UpgradeCooldownPct += 0.15;
                break;
            case 3:
                _habilidade.UpgradeDanoPct = max(_habilidade.UpgradeDanoPct, 0.20);
                _habilidade.UpgradeCooldownPct = max(_habilidade.UpgradeCooldownPct, 0.20);
                break;
        }

        var _base_dano = variable_struct_exists(_habilidade, "DanoBaseOriginal") ? _habilidade.DanoBaseOriginal : _habilidade.DanoBase;
        var _base_cd = variable_struct_exists(_habilidade, "TempoRecargaBase") ? _habilidade.TempoRecargaBase : _habilidade.TempoRecargaMax;
        _habilidade.DanoBaseOriginal = _base_dano;
        _habilidade.TempoRecargaBase = _base_cd;
        _habilidade.DanoBase = floor(_base_dano * (1 + _habilidade.UpgradeDanoPct));
        _habilidade.TempoRecargaMax = max(0.4, _base_cd * (1 - _habilidade.UpgradeCooldownPct));
        _habilidade.TempoRecargaAtual = min(_habilidade.TempoRecargaAtual, _habilidade.TempoRecargaMax);
        return true;
    }

    return false;
}

function pokemon_aplicar_bonus_percentual(_pokemon, _pct) {
    if (!is_struct(_pokemon)) {
        return;
    }

    _pokemon.HpMax = floor(_pokemon.HpMax * (1 + _pct));
    _pokemon.Attack = floor(_pokemon.Attack * (1 + _pct));
    _pokemon.Defense = floor(_pokemon.Defense * (1 + _pct));
    _pokemon.Speed = floor(_pokemon.Speed * (1 + _pct));

    if (variable_struct_exists(_pokemon, "HpAtual")) {
        _pokemon.HpAtual = min(_pokemon.HpMax, floor(_pokemon.HpAtual * (1 + _pct)));
    }
}

function pokemon_progressao_marco_aplicar(_pokemon, _level) {
    if (!is_struct(_pokemon)) {
        return;
    }

    switch (_level) {
        case 12:
            pokemon_aplicar_bonus_percentual(_pokemon, 0.12);
            _pokemon.EstagioEvolucao = max(variable_struct_exists(_pokemon, "EstagioEvolucao") ? _pokemon.EstagioEvolucao : 0, 1);
            break;
        case 17:
            _pokemon.Passiva1Desbloqueada = true;
            break;
        case 23:
            pokemon_aplicar_bonus_percentual(_pokemon, 0.18);
            _pokemon.EstagioEvolucao = max(variable_struct_exists(_pokemon, "EstagioEvolucao") ? _pokemon.EstagioEvolucao : 0, 2);
            break;
        case 27:
            _pokemon.Passiva2Desbloqueada = true;
            break;
        case 30:
            if (!variable_struct_exists(_pokemon, "BonusLendarioAplicado") || !_pokemon.BonusLendarioAplicado) {
                pokemon_aplicar_bonus_percentual(_pokemon, 0.10);
                _pokemon.BonusLendarioAplicado = true;
            }
            break;
    }
}

function pokemon_aplicar_ganho_atributos(_pokemon, _level) {
    _pokemon.GrowthHpCarry += _pokemon.GrowthHp;
    _pokemon.GrowthAttackCarry += _pokemon.GrowthAttack;
    _pokemon.GrowthDefenseCarry += _pokemon.GrowthDefense;
    _pokemon.GrowthSpeedCarry += _pokemon.GrowthSpeed;

    var _hp_gain = max(1, floor(_pokemon.GrowthHpCarry));
    var _attack_gain = max(1, floor(_pokemon.GrowthAttackCarry));
    var _defense_gain = max(1, floor(_pokemon.GrowthDefenseCarry));
    var _speed_gain = max(1, floor(_pokemon.GrowthSpeedCarry));

    _pokemon.GrowthHpCarry = max(0, _pokemon.GrowthHpCarry - _hp_gain);
    _pokemon.GrowthAttackCarry = max(0, _pokemon.GrowthAttackCarry - _attack_gain);
    _pokemon.GrowthDefenseCarry = max(0, _pokemon.GrowthDefenseCarry - _defense_gain);
    _pokemon.GrowthSpeedCarry = max(0, _pokemon.GrowthSpeedCarry - _speed_gain);

    _pokemon.HpMax += _hp_gain;
    _pokemon.Attack += _attack_gain;
    _pokemon.Defense += _defense_gain;
    _pokemon.Speed += _speed_gain;

    if (variable_struct_exists(_pokemon, "HpAtual")) {
        _pokemon.HpAtual = min(_pokemon.HpMax, _pokemon.HpAtual + _hp_gain);
    }

    return new PokemonStatGain(_level, _hp_gain, _attack_gain, _defense_gain, _speed_gain);
}

function pokemon_ganhar_exp(_arg0, _arg1) {
    var _pokemon = undefined;
    var _quantidade = 0;

    if (argument_count == 1) {
        _quantidade = _arg0;

        if (variable_instance_exists(id, "pokemon_data")) {
            _pokemon = pokemon_data;
        }
    } else {
        _pokemon = _arg0;
        _quantidade = _arg1;
    }

    var _resultado = new PokemonLevelUpResult();

    if (!is_struct(_pokemon) || _quantidade <= 0 || _pokemon.Level >= 30) {
        if (is_struct(_pokemon)) {
            _resultado.LevelInicial = _pokemon.Level;
            _resultado.LevelFinal = _pokemon.Level;
        }

        return _resultado;
    }

    _resultado.LevelInicial = _pokemon.Level;
    _pokemon.ExpAtual += _quantidade;

    while (_pokemon.Level < 30 && _pokemon.ExpAtual >= _pokemon.ExpNecessaria) {
        _pokemon.ExpAtual -= _pokemon.ExpNecessaria;
        _pokemon.Level += 1;
        _resultado.SubiuNivel = true;

        var _ganho = pokemon_aplicar_ganho_atributos(_pokemon, _pokemon.Level);
        array_push(_resultado.GanhosPorNivel, _ganho);
        pokemon_progressao_marco_aplicar(_pokemon, _pokemon.Level);
        var _evolucoes = pokemon_evoluir_se_necessario(_pokemon);

        for (var _e = 0; _e < array_length(_evolucoes); _e += 1) {
            array_push(_resultado.Evolucoes, _evolucoes[_e]);
        }

        if (pokemon_level_eh_marco_draft(_pokemon.Level)) {
            var _draft = pokemon_draft_disparar(_pokemon, _pokemon.Level);

            if (is_struct(_draft)) {
                array_push(_resultado.DraftsGerados, _draft);
            }
        }

        _pokemon.ExpNecessaria = pokemon_exp_necessaria(_pokemon.Level);
    }

    if (_pokemon.Level >= 30) {
        _pokemon.Level = 30;
        _pokemon.ExpAtual = 0;
        _pokemon.ExpNecessaria = 0;
    }

    _resultado.LevelFinal = _pokemon.Level;
    return _resultado;
}
