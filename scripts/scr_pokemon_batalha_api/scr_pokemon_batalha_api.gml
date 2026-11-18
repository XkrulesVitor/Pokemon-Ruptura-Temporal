function pokemon_batalha_injetar(_inst, _pokemon_data) {
    if (!instance_exists(_inst) || !is_struct(_pokemon_data)) {
        return false;
    }

    with (_inst) {
        pokemon_data = _pokemon_data;
        pokemon_id = pokemon_data.ID;
        pokemon_nome = pokemon_data.Nome;
        if (variable_struct_exists(pokemon_data, "HpAtual")) {
            hp_atual = clamp(pokemon_data.HpAtual, 1, pokemon_data.HpMax);
        } else {
            pokemon_data.HpAtual = pokemon_data.HpMax;
            hp_atual = pokemon_data.HpMax;
        }

        hp_max = pokemon_data.HpMax;
        attack = pokemon_data.Attack;
        defense = pokemon_data.Defense;
        stat_speed = pokemon_data.Speed;
        level = pokemon_data.Level;
        is_shiny = variable_struct_exists(pokemon_data, "IsShiny") && pokemon_data.IsShiny;
        is_female = variable_struct_exists(pokemon_data, "IsFemale") && pokemon_data.IsFemale;
        capture_chance_bonus = variable_struct_exists(pokemon_data, "CaptureChanceBonus") ? pokemon_data.CaptureChanceBonus : 0;
        habilidades_equipadas = array_create(4, noone);

        for (var _i = 0; _i < 4; _i += 1) {
            if (is_struct(pokemon_data.HabilidadesEquipadas[_i])) {
                habilidades_equipadas[_i] = habilidade_runtime_criar(pokemon_data.HabilidadesEquipadas[_i]);
            }
        }

        sprite_idle = pokemon_sprite_carregar_pose(pokemon_id, "idle", sprite_idle, is_shiny, is_female);
        sprite_ataque = pokemon_sprite_carregar_pose(pokemon_id, "atk", sprite_ataque, is_shiny, is_female);
        sprite_dano = pokemon_sprite_carregar_pose(pokemon_id, "dmg", sprite_dano, is_shiny, is_female);
        sprite_dynamic = sprite_idle;

        if (sprite_exists(sprite_idle)) {
            sprite_index = sprite_idle;
            image_speed = 0;
        }
    }

    return true;
}

function pokemon_batalha_sincronizar_stats(_inst) {
    if (!instance_exists(_inst)) {
        return false;
    }

    if (!is_struct(_inst.pokemon_data)) {
        return false;
    }

    var _hp_percent = _inst.hp_max > 0 ? _inst.hp_atual / _inst.hp_max : 1;
    _inst.pokemon_nome = _inst.pokemon_data.Nome;
    _inst.hp_max = _inst.pokemon_data.HpMax;
    _inst.hp_atual = clamp(ceil(_inst.hp_max * _hp_percent), 1, _inst.hp_max);
    _inst.attack = _inst.pokemon_data.Attack;
    _inst.defense = _inst.pokemon_data.Defense;
    _inst.stat_speed = _inst.pokemon_data.Speed;
    _inst.level = _inst.pokemon_data.Level;
    _inst.is_shiny = variable_struct_exists(_inst.pokemon_data, "IsShiny") && _inst.pokemon_data.IsShiny;
    _inst.is_female = variable_struct_exists(_inst.pokemon_data, "IsFemale") && _inst.pokemon_data.IsFemale;
    _inst.capture_chance_bonus = variable_struct_exists(_inst.pokemon_data, "CaptureChanceBonus") ? _inst.pokemon_data.CaptureChanceBonus : 0;

    return true;
}

function pokemon_batalha_sincronizar_habilidades(_inst) {
    if (!instance_exists(_inst) || !is_struct(_inst.pokemon_data)) {
        return false;
    }

    var _anteriores = _inst.habilidades_equipadas;
    var _novas = array_create(4, noone);

    for (var _i = 0; _i < 4; _i += 1) {
        var _base = _inst.pokemon_data.HabilidadesEquipadas[_i];

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

function pokemon_batalha_escalonar_cooldowns(_inst) {
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

function pokemon_batalha_definir_lado(_inst, _lado) {
    if (!instance_exists(_inst)) {
        return false;
    }

    _inst.lado_batalha = _lado;
    pokemon_batalha_escalonar_cooldowns(_inst);
    return true;
}

function pokemon_batalha_trocar_ativo(_lado, _novo_ativo) {
    if (!instance_exists(_novo_ativo)) {
        return false;
    }

    with (obj_pokemon_batalha) {
        if (lado_batalha == _lado && vivo) {
            batalha_ativo = false;
        }
    }

    _novo_ativo.lado_batalha = _lado;
    _novo_ativo.batalha_ativo = true;
    return true;
}

function pokemon_batalha_criar(_x, _y, _pokemon_data, _layer, _lado) {
    if (argument_count < 4) {
        _layer = "Instances";
    }

    if (argument_count < 5) {
        _lado = LadoBatalha.ALIADO;
    }

    var _inst = instance_create_layer(_x, _y, _layer, obj_pokemon_batalha);
    pokemon_batalha_injetar(_inst, _pokemon_data);
    pokemon_batalha_definir_lado(_inst, _lado);
    return _inst;
}
