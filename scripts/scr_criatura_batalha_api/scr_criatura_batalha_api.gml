function criatura_batalha_injetar(_inst, _criatura_data) {
    if (!instance_exists(_inst) || !is_struct(_criatura_data)) {
        return false;
    }

    with (_inst) {
        criatura_data = _criatura_data;
        criatura_id = criatura_data.ID;
        criatura_nome = criatura_data.Nome;
        if (variable_struct_exists(criatura_data, "HpAtual")) {
            hp_atual = clamp(criatura_data.HpAtual, 1, criatura_data.HpMax);
        } else {
            criatura_data.HpAtual = criatura_data.HpMax;
            hp_atual = criatura_data.HpMax;
        }

        hp_max = criatura_data.HpMax;
        attack = criatura_data.Attack;
        defense = criatura_data.Defense;
        stat_speed = criatura_data.Speed;
        level = criatura_data.Level;
        is_shiny = variable_struct_exists(criatura_data, "IsShiny") && criatura_data.IsShiny;
        is_female = variable_struct_exists(criatura_data, "IsFemale") && criatura_data.IsFemale;
        capture_chance_bonus = variable_struct_exists(criatura_data, "CaptureChanceBonus") ? criatura_data.CaptureChanceBonus : 0;
        habilidades_equipadas = array_create(4, noone);

        for (var _i = 0; _i < 4; _i += 1) {
            if (is_struct(criatura_data.HabilidadesEquipadas[_i])) {
                habilidades_equipadas[_i] = habilidade_runtime_criar(criatura_data.HabilidadesEquipadas[_i]);
            }
        }

        sprite_idle = criatura_sprite_carregar_pose(criatura_id, "idle", sprite_idle, is_shiny, is_female);
        sprite_ataque = criatura_sprite_carregar_pose(criatura_id, "atk", sprite_ataque, is_shiny, is_female);
        sprite_dano = criatura_sprite_carregar_pose(criatura_id, "dmg", sprite_dano, is_shiny, is_female);
        sprite_dynamic = sprite_idle;

        if (sprite_exists(sprite_idle)) {
            sprite_index = sprite_idle;
            image_speed = 0;
        }
    }

    return true;
}

function criatura_batalha_sincronizar_stats(_inst) {
    if (!instance_exists(_inst)) {
        return false;
    }

    if (!is_struct(_inst.criatura_data)) {
        return false;
    }

    var _hp_percent = _inst.hp_max > 0 ? _inst.hp_atual / _inst.hp_max : 1;
    _inst.criatura_nome = _inst.criatura_data.Nome;
    _inst.hp_max = _inst.criatura_data.HpMax;
    _inst.hp_atual = clamp(ceil(_inst.hp_max * _hp_percent), 1, _inst.hp_max);
    _inst.attack = _inst.criatura_data.Attack;
    _inst.defense = _inst.criatura_data.Defense;
    _inst.stat_speed = _inst.criatura_data.Speed;
    _inst.level = _inst.criatura_data.Level;
    _inst.is_shiny = variable_struct_exists(_inst.criatura_data, "IsShiny") && _inst.criatura_data.IsShiny;
    _inst.is_female = variable_struct_exists(_inst.criatura_data, "IsFemale") && _inst.criatura_data.IsFemale;
    _inst.capture_chance_bonus = variable_struct_exists(_inst.criatura_data, "CaptureChanceBonus") ? _inst.criatura_data.CaptureChanceBonus : 0;

    return true;
}

function criatura_batalha_sincronizar_habilidades(_inst) {
    if (!instance_exists(_inst) || !is_struct(_inst.criatura_data)) {
        return false;
    }

    var _anteriores = _inst.habilidades_equipadas;
    var _novas = array_create(4, noone);

    for (var _i = 0; _i < 4; _i += 1) {
        var _base = _inst.criatura_data.HabilidadesEquipadas[_i];

        if (!is_struct(_base)) {
            continue;
        }

        var _runtime = habilidade_runtime_criar(_base);

        for (var _j = 0; _j < 4; _j += 1) {
            var _anterior = _anteriores[_j];

            if (is_struct(_anterior) && _anterior.ID == _runtime.ID) {
                _runtime.TempoRecargaAtual = _anterior.TempoRecargaAtual;
                break;
            }
        }

        _novas[_i] = _runtime;
    }

    _inst.habilidades_equipadas = _novas;
    return true;
}

function criatura_batalha_escalonar_cooldowns(_inst) {
    if (!instance_exists(_inst)) {
        return false;
    }

    var _lado_offset = _inst.lado_batalha == LadoBatalha.ALIADO ? 0.22 : 0.64;
    var _lado_jitter = _inst.lado_batalha == LadoBatalha.ALIADO ? 0.00 : 0.42;

    for (var _i = 0; _i < 4; _i += 1) {
        var _habilidade = _inst.habilidades_equipadas[_i];

        if (!is_struct(_habilidade)) {
            continue;
        }

        var _inicio = (_habilidade.TempoRecargaMax * _lado_offset) + (_i * 0.55) + _lado_jitter;
        _habilidade.TempoRecargaAtual = clamp(_inicio, 0.45, _habilidade.TempoRecargaMax);
    }

    return true;
}

function criatura_batalha_definir_lado(_inst, _lado) {
    if (!instance_exists(_inst)) {
        return false;
    }

    _inst.lado_batalha = _lado;
    criatura_batalha_escalonar_cooldowns(_inst);
    return true;
}

function criatura_batalha_trocar_ativo(_lado, _novo_ativo) {
    if (!instance_exists(_novo_ativo)) {
        return false;
    }

    with (obj_criatura_batalha) {
        if (lado_batalha == _lado && vivo) {
            batalha_ativo = false;
        }
    }

    _novo_ativo.lado_batalha = _lado;
    _novo_ativo.batalha_ativo = true;
    return true;
}

function criatura_batalha_criar(_x, _y, _criatura_data, _layer, _lado) {
    if (argument_count < 4) {
        _layer = "Instances";
    }

    if (argument_count < 5) {
        _lado = LadoBatalha.ALIADO;
    }

    var _inst = instance_create_layer(_x, _y, _layer, obj_criatura_batalha);
    criatura_batalha_injetar(_inst, _criatura_data);
    criatura_batalha_definir_lado(_inst, _lado);
    return _inst;
}
