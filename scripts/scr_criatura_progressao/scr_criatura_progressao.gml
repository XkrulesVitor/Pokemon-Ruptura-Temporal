enum EstadoJogo {
    EXPLORACAO,
    BATALHA,
    DRAFT_HABILIDADE,
    EVENTO_NARRATIVO,
    GAME_OVER
}

function CriaturaLevelUpResult() constructor {
    LevelInicial = 1;
    LevelFinal = 1;
    SubiuNivel = false;
    GanhosPorNivel = [];
    DraftsGerados = [];
    Evolucoes = [];
}

function CriaturaStatGain(_level, _hp, _attack, _defense, _speed) constructor {
    Level = _level;
    Hp = _hp;
    Attack = _attack;
    Defense = _defense;
    Speed = _speed;
}

function CriaturaHabilidadeDraft(_criatura, _level, _opcoes) constructor {
    Criatura = _criatura;
    Level = _level;
    Opcoes = _opcoes;
    PrecisaSubstituir = criatura_habilidades_equipadas_quantidade(_criatura) >= 4;
    TipoDraft = criatura_draft_tipo_por_level(_level);
    Resolvido = false;
}

function criatura_level_marcos_draft() {
    return [10, 15, 20, 25, 30];
}

function criatura_draft_tipo_por_level(_level) {
    switch (_level) {
        case 20: return "slot_ou_upgrade";
        case 25:
        case 30:
            return "upgrade";
    }

    return "habilidade";
}

function criatura_level_eh_marco_draft(_level) {
    var _marcos = criatura_level_marcos_draft();

    for (var _i = 0; _i < array_length(_marcos); _i += 1) {
        if (_level == _marcos[_i]) {
            return true;
        }
    }

    return false;
}

function criatura_habilidades_equipadas_quantidade(_criatura) {
    if (!is_struct(_criatura)) {
        return 0;
    }

    var _total = 0;

    for (var _i = 0; _i < 4; _i += 1) {
        if (is_struct(_criatura.HabilidadesEquipadas[_i])) {
            _total += 1;
        }
    }

    return _total;
}

function criatura_tem_habilidade(_criatura, _habilidade_id) {
    if (!is_struct(_criatura)) {
        return false;
    }

    for (var _i = 0; _i < 4; _i += 1) {
        var _habilidade = _criatura.HabilidadesEquipadas[_i];

        if (is_struct(_habilidade) && _habilidade.ID == _habilidade_id) {
            return true;
        }
    }

    return false;
}

function criatura_habilidade_pool_disponivel(_criatura, _level) {
    var _pool = [];

    if (!is_struct(_criatura)) {
        return _pool;
    }

    for (var _i = 0; _i < array_length(_criatura.ListaHabilidadesDisponiveis); _i += 1) {
        var _habilidade = _criatura.ListaHabilidadesDisponiveis[_i];

        if (!is_struct(_habilidade)) {
            continue;
        }

        var _nivel_permitido = _habilidade.NivelAprendizado <= _level;

        if (_level == 20 && _habilidade.NivelAprendizado <= 25) {
            _nivel_permitido = true;
        }

        if (_nivel_permitido && !criatura_tem_habilidade(_criatura, _habilidade.ID)) {
            array_push(_pool, _habilidade);
        }
    }

    return _pool;
}

function criatura_sortear_habilidades_draft(_criatura, _level) {
    var _pool = criatura_habilidade_pool_disponivel(_criatura, _level);
    var _opcoes = [];

    repeat (min(2, array_length(_pool))) {
        var _index = irandom(array_length(_pool) - 1);
        array_push(_opcoes, _pool[_index]);
        array_delete(_pool, _index, 1);
    }

    if (array_length(_opcoes) < 2) {
        var _upgrades = criatura_sortear_upgrades_draft(_criatura);

        for (var _u = 0; _u < array_length(_upgrades) && array_length(_opcoes) < 2; _u += 1) {
            array_push(_opcoes, _upgrades[_u]);
        }
    }

    return _opcoes;
}

function criatura_habilidade_tier_nome(_tier) {
    switch (clamp(_tier, 0, 3)) {
        case 0: return "Bronze";
        case 1: return "Prata";
        case 2: return "Ouro";
        case 3: return "Diamante";
    }

    return "Bronze";
}

function criatura_habilidade_upgrade_option(_habilidade) {
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

function criatura_sortear_upgrades_draft(_criatura) {
    var _pool = [];

    if (!is_struct(_criatura)) {
        return _pool;
    }

    for (var _i = 0; _i < 4; _i += 1) {
        var _habilidade = _criatura.HabilidadesEquipadas[_i];

        if (is_struct(_habilidade)) {
            var _tier = variable_struct_exists(_habilidade, "Tier") ? _habilidade.Tier : 0;

            if (_tier < 3) {
                array_push(_pool, criatura_habilidade_upgrade_option(_habilidade));
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

function criatura_sortear_opcoes_draft(_criatura, _level) {
    var _tipo = criatura_draft_tipo_por_level(_level);

    if (_tipo == "upgrade") {
        return criatura_sortear_upgrades_draft(_criatura);
    }

    if (_tipo == "slot_ou_upgrade") {
        var _skills = criatura_sortear_habilidades_draft(_criatura, _level);
        var _upgrades = criatura_sortear_upgrades_draft(_criatura);
        var _opcoes = [];

        if (array_length(_skills) > 0 && criatura_slot_desbloqueado(_criatura, 3)) {
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

    return criatura_sortear_habilidades_draft(_criatura, _level);
}

function criatura_draft_garantir_globals() {
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
function criatura_draft_disparar(_criatura, _level) {
    var _escopo = diario_escopo("habilidade:" + string(is_struct(_criatura) ? _criatura.ID : 0) + ":" + string(_level));
    var _resultado = criatura_draft_disparar_base(_criatura, _level);
    diario_escopo_fim(_escopo);
    return _resultado;
}

function criatura_draft_disparar_base(_criatura, _level) {
    criatura_draft_garantir_globals();

    var _opcoes = criatura_sortear_opcoes_draft(_criatura, _level);

    if (array_length(_opcoes) <= 0) {
        return undefined;
    }

    var _draft = new CriaturaHabilidadeDraft(_criatura, _level, _opcoes);
    array_push(global.draft_habilidade_fila, _draft);

    if (!is_struct(global.draft_habilidade_atual)) {
        criatura_draft_proximo();
    }

    return _draft;
}

function criatura_draft_inicial(_criatura) {
    if (!is_struct(_criatura)) {
        return undefined;
    }

    return criatura_draft_disparar(_criatura, 1);
}

function criatura_progressao_auto_resolver_ate_level(_criatura) {
    if (!is_struct(_criatura)) {
        return;
    }

    var _marcos = criatura_level_marcos_draft();

    for (var _m = 0; _m < array_length(_marcos); _m += 1) {
        var _level = _marcos[_m];

        if (_criatura.Level < _level) {
            continue;
        }

        var _opcoes = criatura_sortear_opcoes_draft(_criatura, _level);

        if (array_length(_opcoes) <= 0) {
            continue;
        }

        var _choice = _opcoes[irandom(array_length(_opcoes) - 1)];

        if (is_struct(_choice) && variable_struct_exists(_choice, "TipoOpcao") && _choice.TipoOpcao == "upgrade") {
            criatura_habilidade_aplicar_upgrade(_criatura, _choice.HabilidadeID);

            if (_level == 20) {
                _criatura.Slot4Trancado = true;
            }
        } else {
            var _slot = criatura_primeiro_slot_habilidade_livre_desbloqueado(_criatura);

            if (_slot >= 0) {
                _criatura.HabilidadesEquipadas[_slot] = habilidade_runtime_criar(_choice);
            }
        }
    }
}

function criatura_build_array_tem(_array, _valor) {
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

function criatura_build_array_push_unico(_array, _valor) {
    if (!is_array(_array) || _valor == "") {
        return _array;
    }

    if (!criatura_build_array_tem(_array, _valor)) {
        array_push(_array, _valor);
    }

    return _array;
}

function criatura_build_efeito_args(_efeito, _prefixo) {
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

function criatura_build_efeitos_coletar(_habilidade) {
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

function criatura_build_statuses_aplicados(_habilidade, _usuario) {
    var _status = [];
    var _prefixo = _usuario ? "aplicar_status_usuario:" : "aplicar_status:";
    var _efeitos = criatura_build_efeitos_coletar(_habilidade);

    for (var _i = 0; _i < array_length(_efeitos); _i += 1) {
        var _args = criatura_build_efeito_args(_efeitos[_i], _prefixo);

        if (array_length(_args) >= 1) {
            _status = criatura_build_array_push_unico(_status, _args[0]);
        }
    }

    return _status;
}

function criatura_build_statuses_consumidos(_habilidade, _usuario) {
    var _status = [];

    if (!is_struct(_habilidade)) {
        return _status;
    }

    if (!_usuario && is_string(_habilidade.ComboID) && _habilidade.ComboID != "") {
        _status = criatura_build_array_push_unico(_status, _habilidade.ComboID);
    }

    var _prefixo = _usuario ? "bonus_dano_usuario_status:" : "bonus_dano_alvo_status:";
    var _efeitos = criatura_build_efeitos_coletar(_habilidade);

    for (var _i = 0; _i < array_length(_efeitos); _i += 1) {
        var _args = criatura_build_efeito_args(_efeitos[_i], _prefixo);

        if (array_length(_args) >= 1) {
            _status = criatura_build_array_push_unico(_status, _args[0]);
        }
    }

    return _status;
}

function criatura_build_intersecao_quantidade(_a, _b) {
    if (!is_array(_a) || !is_array(_b)) {
        return 0;
    }

    var _total = 0;

    for (var _i = 0; _i < array_length(_a); _i += 1) {
        if (criatura_build_array_tem(_b, _a[_i])) {
            _total += 1;
        }
    }

    return _total;
}

function criatura_build_habilidade_score(_criatura, _habilidade, _contexto) {
    if (!is_struct(_criatura) || !is_struct(_habilidade)) {
        return 0;
    }

    var _score = 1.0 + random(0.35);
    var _tipo = variable_struct_exists(_habilidade, "TipoElementar") ? _habilidade.TipoElementar : _habilidade.Tipo;

    if (_criatura.Tipo1 == _tipo || _criatura.Tipo2 == _tipo) {
        _score += 0.18;
    }

    if (_habilidade.DanoBase > 0) {
        _score += clamp(_habilidade.DanoBase / 90, 0.04, 0.48);
    } else {
        _score -= 0.12;
    }

    _score += clamp((7.0 - _habilidade.TempoRecargaMax) * 0.035, -0.10, 0.18);

    var _cand_aplica_alvo = criatura_build_statuses_aplicados(_habilidade, false);
    var _cand_aplica_self = criatura_build_statuses_aplicados(_habilidade, true);
    var _cand_consum_alvo = criatura_build_statuses_consumidos(_habilidade, false);
    var _cand_consum_self = criatura_build_statuses_consumidos(_habilidade, true);

    if (array_length(_cand_aplica_alvo) > 0 || array_length(_cand_aplica_self) > 0) {
        _score += 0.16;
    }

    for (var _slot = 0; _slot < 4; _slot += 1) {
        var _equipada = _criatura.HabilidadesEquipadas[_slot];

        if (!is_struct(_equipada)) {
            continue;
        }

        var _eq_aplica_alvo = criatura_build_statuses_aplicados(_equipada, false);
        var _eq_aplica_self = criatura_build_statuses_aplicados(_equipada, true);
        var _eq_consum_alvo = criatura_build_statuses_consumidos(_equipada, false);
        var _eq_consum_self = criatura_build_statuses_consumidos(_equipada, true);

        _score += criatura_build_intersecao_quantidade(_cand_consum_alvo, _eq_aplica_alvo) * 0.90;
        _score += criatura_build_intersecao_quantidade(_eq_consum_alvo, _cand_aplica_alvo) * 0.72;
        _score += criatura_build_intersecao_quantidade(_cand_consum_self, _eq_aplica_self) * 0.55;
        _score += criatura_build_intersecao_quantidade(_eq_consum_self, _cand_aplica_self) * 0.48;
        _score += criatura_build_intersecao_quantidade(_cand_aplica_alvo, _eq_aplica_alvo) * 0.10;
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

function criatura_build_escolher_habilidade(_criatura, _pool, _contexto) {
    if (!is_array(_pool) || array_length(_pool) <= 0) {
        return noone;
    }

    var _pesos = [];
    var _total = 0;

    for (var _i = 0; _i < array_length(_pool); _i += 1) {
        var _peso = criatura_build_habilidade_score(_criatura, _pool[_i], _contexto);
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

function criatura_build_upgrade_id_escolher(_criatura) {
    if (!is_struct(_criatura)) {
        return "";
    }

    var _ids = [];
    var _pesos = [];
    var _total = 0;

    for (var _i = 0; _i < 4; _i += 1) {
        var _habilidade = _criatura.HabilidadesEquipadas[_i];

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

function criatura_build_aplicar_upgrade_ponderado(_criatura) {
    var _id = criatura_build_upgrade_id_escolher(_criatura);

    if (_id == "") {
        return false;
    }

    return criatura_habilidade_aplicar_upgrade(_criatura, _id);
}

function criatura_progressao_inimigo_bonus_contexto(_criatura, _contexto) {
    if (!is_struct(_criatura)) {
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

    _criatura.HpMax = max(1, round(_criatura.HpMax * _hp_mult));
    _criatura.Attack = max(1, round(_criatura.Attack * _atk_mult));
    _criatura.Defense = max(1, round(_criatura.Defense * _def_mult));
    _criatura.Speed = max(1, round(_criatura.Speed * _spd_mult));
    _criatura.HpAtual = _criatura.HpMax;
}

function criatura_progressao_inimigo_randomizar_build(_criatura, _contexto) {
    if (!is_struct(_criatura)) {
        return;
    }

    if (argument_count < 2 || !is_string(_contexto) || _contexto == "") {
        _contexto = "selvagem";
    }

    for (var _slot_reset = 0; _slot_reset < 4; _slot_reset += 1) {
        _criatura.HabilidadesEquipadas[_slot_reset] = noone;
    }

    _criatura.Slot4Trancado = false;

    var _pool_inicial = [];

    for (var _i = 0; _i < array_length(_criatura.ListaHabilidadesDisponiveis); _i += 1) {
        var _habilidade_inicial = _criatura.ListaHabilidadesDisponiveis[_i];

        if (is_struct(_habilidade_inicial) && _habilidade_inicial.NivelAprendizado <= 1) {
            array_push(_pool_inicial, _habilidade_inicial);
        }
    }

    if (array_length(_pool_inicial) <= 0 && array_length(_criatura.ListaHabilidadesDisponiveis) > 0) {
        array_push(_pool_inicial, _criatura.ListaHabilidadesDisponiveis[0]);
    }

    var _primeira = criatura_build_escolher_habilidade(_criatura, _pool_inicial, _contexto);

    if (is_struct(_primeira)) {
        _criatura.HabilidadesEquipadas[0] = habilidade_runtime_criar(_primeira);
    }

    var _marcos_skills = [10, 15, 20];

    for (var _m = 0; _m < array_length(_marcos_skills); _m += 1) {
        var _level = _marcos_skills[_m];

        if (_criatura.Level < _level) {
            continue;
        }

        if (_level == 20) {
            var _chance_especializar = _contexto == "ginasio" ? 0.25 : (_contexto == "selvagem" ? 0.22 : 0.32);

            if (random(1) < _chance_especializar && criatura_build_aplicar_upgrade_ponderado(_criatura)) {
                _criatura.Slot4Trancado = true;
                continue;
            }
        }

        var _slot = criatura_primeiro_slot_habilidade_livre_desbloqueado(_criatura);

        if (_slot < 0) {
            criatura_build_aplicar_upgrade_ponderado(_criatura);
            continue;
        }

        var _pool = criatura_habilidade_pool_disponivel(_criatura, _level);
        var _escolha = criatura_build_escolher_habilidade(_criatura, _pool, _contexto);

        if (is_struct(_escolha)) {
            _criatura.HabilidadesEquipadas[_slot] = habilidade_runtime_criar(_escolha);
        } else {
            criatura_build_aplicar_upgrade_ponderado(_criatura);
        }
    }

    if (_criatura.Level >= 25) {
        criatura_build_aplicar_upgrade_ponderado(_criatura);
    }

    if (_criatura.Level >= 30) {
        criatura_build_aplicar_upgrade_ponderado(_criatura);
    }

    if (_contexto == "ginasio") {
        criatura_build_aplicar_upgrade_ponderado(_criatura);
    } else if (_contexto == "rocket" && _criatura.Level >= 15) {
        criatura_build_aplicar_upgrade_ponderado(_criatura);
    }

    criatura_progressao_inimigo_bonus_contexto(_criatura, _contexto);
    _criatura.BuildOrigem = _contexto;
    _criatura.BuildSelvagemRolada = _contexto == "selvagem";
    _criatura.BuildCongeladaAoCapturar = true;
}

function criatura_slot_desbloqueado(_criatura, _slot) {
    if (!is_struct(_criatura)) {
        return false;
    }

    if (variable_struct_exists(_criatura, "Slot4Trancado") && _criatura.Slot4Trancado && _slot == 3) {
        return false;
    }

    switch (_slot) {
        case 0: return _criatura.Level >= 1;
        case 1: return _criatura.Level >= 10;
        case 2: return _criatura.Level >= 15;
        case 3: return _criatura.Level >= 20;
    }

    return false;
}

function criatura_primeiro_slot_habilidade_livre_desbloqueado(_criatura) {
    if (!is_struct(_criatura)) {
        return -1;
    }

    for (var _i = 0; _i < 4; _i += 1) {
        if (criatura_slot_desbloqueado(_criatura, _i) && !is_struct(_criatura.HabilidadesEquipadas[_i])) {
            return _i;
        }
    }

    return -1;
}

function criatura_draft_proximo() {
    criatura_draft_garantir_globals();

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

function criatura_draft_escolher(_draft, _opcao_index, _slot_substituir) {
    if (!is_struct(_draft) || _draft.Resolvido) {
        return false;
    }

    if (_opcao_index < 0 || _opcao_index >= array_length(_draft.Opcoes)) {
        return false;
    }

    var _criatura = _draft.Criatura;
    var _habilidade = _draft.Opcoes[_opcao_index];

    if (is_struct(_habilidade) && variable_struct_exists(_habilidade, "TipoOpcao") && _habilidade.TipoOpcao == "upgrade") {
        var _ok_upgrade = criatura_habilidade_aplicar_upgrade(_criatura, _habilidade.HabilidadeID);

        if (_ok_upgrade && _draft.Level == 20) {
            _criatura.Slot4Trancado = true;
        }

        _draft.Resolvido = true;
        criatura_draft_proximo();
        return _ok_upgrade;
    }

    var _slot = _slot_substituir;

    if (argument_count < 3 || _slot < 0) {
        _slot = criatura_primeiro_slot_habilidade_livre_desbloqueado(_criatura);
    }

    if (_slot < 0 || _slot >= 4 || !criatura_slot_desbloqueado(_criatura, _slot)) {
        return false;
    }

    _criatura.HabilidadesEquipadas[_slot] = habilidade_runtime_criar(_habilidade);
    _draft.Resolvido = true;
    criatura_draft_proximo();
    return true;
}

function criatura_primeiro_slot_habilidade_livre(_criatura) {
    if (!is_struct(_criatura)) {
        return -1;
    }

    for (var _i = 0; _i < 4; _i += 1) {
        if (!is_struct(_criatura.HabilidadesEquipadas[_i])) {
            return _i;
        }
    }

    return -1;
}

function criatura_habilidade_aplicar_upgrade(_criatura, _habilidade_id) {
    if (!is_struct(_criatura)) {
        return false;
    }

    for (var _i = 0; _i < 4; _i += 1) {
        var _habilidade = _criatura.HabilidadesEquipadas[_i];

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

function criatura_aplicar_bonus_percentual(_criatura, _pct) {
    if (!is_struct(_criatura)) {
        return;
    }

    _criatura.HpMax = floor(_criatura.HpMax * (1 + _pct));
    _criatura.Attack = floor(_criatura.Attack * (1 + _pct));
    _criatura.Defense = floor(_criatura.Defense * (1 + _pct));
    _criatura.Speed = floor(_criatura.Speed * (1 + _pct));

    if (variable_struct_exists(_criatura, "HpAtual")) {
        _criatura.HpAtual = min(_criatura.HpMax, floor(_criatura.HpAtual * (1 + _pct)));
    }
}

function criatura_progressao_marco_aplicar(_criatura, _level) {
    if (!is_struct(_criatura)) {
        return;
    }

    switch (_level) {
        case 12:
            criatura_aplicar_bonus_percentual(_criatura, 0.12);
            _criatura.EstagioEvolucao = max(variable_struct_exists(_criatura, "EstagioEvolucao") ? _criatura.EstagioEvolucao : 0, 1);
            break;
        case 17:
            _criatura.Passiva1Desbloqueada = true;
            break;
        case 23:
            criatura_aplicar_bonus_percentual(_criatura, 0.18);
            _criatura.EstagioEvolucao = max(variable_struct_exists(_criatura, "EstagioEvolucao") ? _criatura.EstagioEvolucao : 0, 2);
            break;
        case 27:
            _criatura.Passiva2Desbloqueada = true;
            break;
        case 30:
            if (!variable_struct_exists(_criatura, "BonusLendarioAplicado") || !_criatura.BonusLendarioAplicado) {
                criatura_aplicar_bonus_percentual(_criatura, 0.10);
                _criatura.BonusLendarioAplicado = true;
            }
            break;
    }
}

function criatura_aplicar_ganho_atributos(_criatura, _level) {
    _criatura.GrowthHpCarry += _criatura.GrowthHp;
    _criatura.GrowthAttackCarry += _criatura.GrowthAttack;
    _criatura.GrowthDefenseCarry += _criatura.GrowthDefense;
    _criatura.GrowthSpeedCarry += _criatura.GrowthSpeed;

    var _hp_gain = max(1, floor(_criatura.GrowthHpCarry));
    var _attack_gain = max(1, floor(_criatura.GrowthAttackCarry));
    var _defense_gain = max(1, floor(_criatura.GrowthDefenseCarry));
    var _speed_gain = max(1, floor(_criatura.GrowthSpeedCarry));

    _criatura.GrowthHpCarry = max(0, _criatura.GrowthHpCarry - _hp_gain);
    _criatura.GrowthAttackCarry = max(0, _criatura.GrowthAttackCarry - _attack_gain);
    _criatura.GrowthDefenseCarry = max(0, _criatura.GrowthDefenseCarry - _defense_gain);
    _criatura.GrowthSpeedCarry = max(0, _criatura.GrowthSpeedCarry - _speed_gain);

    _criatura.HpMax += _hp_gain;
    _criatura.Attack += _attack_gain;
    _criatura.Defense += _defense_gain;
    _criatura.Speed += _speed_gain;

    if (variable_struct_exists(_criatura, "HpAtual")) {
        _criatura.HpAtual = min(_criatura.HpMax, _criatura.HpAtual + _hp_gain);
    }

    return new CriaturaStatGain(_level, _hp_gain, _attack_gain, _defense_gain, _speed_gain);
}

function criatura_ganhar_exp(_arg0, _arg1) {
    var _criatura = undefined;
    var _quantidade = 0;

    if (argument_count == 1) {
        _quantidade = _arg0;

        if (variable_instance_exists(id, "criatura_data")) {
            _criatura = criatura_data;
        }
    } else {
        _criatura = _arg0;
        _quantidade = _arg1;
    }

    var _resultado = new CriaturaLevelUpResult();

    if (!is_struct(_criatura) || _quantidade <= 0 || _criatura.Level >= 30) {
        if (is_struct(_criatura)) {
            _resultado.LevelInicial = _criatura.Level;
            _resultado.LevelFinal = _criatura.Level;
        }

        return _resultado;
    }

    _resultado.LevelInicial = _criatura.Level;
    _criatura.ExpAtual += _quantidade;

    while (_criatura.Level < 30 && _criatura.ExpAtual >= _criatura.ExpNecessaria) {
        _criatura.ExpAtual -= _criatura.ExpNecessaria;
        _criatura.Level += 1;
        _resultado.SubiuNivel = true;

        var _ganho = criatura_aplicar_ganho_atributos(_criatura, _criatura.Level);
        array_push(_resultado.GanhosPorNivel, _ganho);
        criatura_progressao_marco_aplicar(_criatura, _criatura.Level);
        var _evolucoes = criatura_evoluir_se_necessario(_criatura);

        for (var _e = 0; _e < array_length(_evolucoes); _e += 1) {
            array_push(_resultado.Evolucoes, _evolucoes[_e]);
        }

        if (criatura_level_eh_marco_draft(_criatura.Level)) {
            var _draft = criatura_draft_disparar(_criatura, _criatura.Level);

            if (is_struct(_draft)) {
                array_push(_resultado.DraftsGerados, _draft);
            }
        }

        _criatura.ExpNecessaria = criatura_exp_necessaria(_criatura.Level);
    }

    if (_criatura.Level >= 30) {
        _criatura.Level = 30;
        _criatura.ExpAtual = 0;
        _criatura.ExpNecessaria = 0;
    }

    _resultado.LevelFinal = _criatura.Level;
    return _resultado;
}
