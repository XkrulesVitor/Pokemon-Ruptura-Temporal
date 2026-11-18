enum PokemonTipo {
    NONE,
    NORMAL,
    FIRE,
    WATER,
    GRASS,
    ELECTRIC,
    ICE,
    FIGHTING,
    POISON,
    GROUND,
    FLYING,
    PSYCHIC,
    BUG,
    ROCK,
    GHOST,
    DRAGON,
    DARK,
    STEEL,
    FAIRY
}

enum PokemonRaridade {
    COMMON,
    UNCOMMON,
    RARE,
    EPIC,
    LEGENDARY,
    ULTRA_RARE
}

function pokemon_id_em_lista(_id, _lista) {
    if (!is_array(_lista)) {
        return false;
    }

    for (var _i = 0; _i < array_length(_lista); _i += 1) {
        if (_lista[_i] == _id) {
            return true;
        }
    }

    return false;
}

function pokemon_evolution_rules() {
    // Regras de evolucao derivadas de criaturas.json (campos evolui_de / nivel_evolucao).
    return conteudo_garantir().Evolucoes;
}

function pokemon_evolution_min_level_para_especie(_id) {
    var _rules = pokemon_evolution_rules();
    var _min_level = 0;

    for (var _i = 0; _i < array_length(_rules); _i += 1) {
        var _rule = _rules[_i];

        if (_rule.To != _id) {
            continue;
        }

        _min_level = _min_level <= 0 ? _rule.Level : min(_min_level, _rule.Level);
    }

    return _min_level;
}

function pokemon_evolution_rule_for_target(_rules, _target_id) {
    for (var _i = 0; _i < array_length(_rules); _i += 1) {
        if (_rules[_i].To == _target_id) {
            return _rules[_i];
        }
    }

    return undefined;
}

function pokemon_evolution_next_rule_for_pokemon(_pokemon) {
    if (!is_struct(_pokemon)) {
        return undefined;
    }

    var _rules = pokemon_evolution_rules();
    var _candidates = [];

    for (var _i = 0; _i < array_length(_rules); _i += 1) {
        var _rule = _rules[_i];

        if (_rule.From == _pokemon.ID && _pokemon.Level >= _rule.Level) {
            array_push(_candidates, _rule);
        }
    }

    var _total = array_length(_candidates);

    if (_total <= 0) {
        return undefined;
    }

    if (_total == 1) {
        return _candidates[0];
    }

    if (variable_struct_exists(_pokemon, "EvolutionTargetID")) {
        var _stored = pokemon_evolution_rule_for_target(_candidates, _pokemon.EvolutionTargetID);

        if (is_struct(_stored)) {
            return _stored;
        }
    }

    var _target_id = _candidates[irandom(_total - 1)].To;

    var _chosen = pokemon_evolution_rule_for_target(_candidates, _target_id);

    if (!is_struct(_chosen)) {
        _chosen = _candidates[0];
    }

    _pokemon.EvolutionTargetID = _chosen.To;
    return _chosen;
}

function pokemon_data_preservar_equipadas(_pokemon) {
    var _habilidades = array_create(4, noone);

    if (!is_struct(_pokemon) || !variable_struct_exists(_pokemon, "HabilidadesEquipadas") || !is_array(_pokemon.HabilidadesEquipadas)) {
        return _habilidades;
    }

    for (var _i = 0; _i < min(4, array_length(_pokemon.HabilidadesEquipadas)); _i += 1) {
        _habilidades[_i] = _pokemon.HabilidadesEquipadas[_i];
    }

    return _habilidades;
}

function pokemon_evoluir_se_necessario(_pokemon) {
    var _evolucoes = [];

    if (!is_struct(_pokemon) || !variable_global_exists("pokedex")) {
        return _evolucoes;
    }

    var _limit = 0;

    while (_limit < 3) {
        _limit += 1;
        var _rule = pokemon_evolution_next_rule_for_pokemon(_pokemon);

        if (!is_struct(_rule)) {
            break;
        }

        var _target_base = pokemon_db_get(global.pokedex, _rule.To);

        if (!is_struct(_target_base)) {
            break;
        }

        var _old_id = _pokemon.ID;
        var _old_name = _pokemon.Nome;
        var _old_level = _pokemon.Level;
        var _old_exp = variable_struct_exists(_pokemon, "ExpAtual") ? _pokemon.ExpAtual : 0;
        var _old_exp_need = variable_struct_exists(_pokemon, "ExpNecessaria") ? _pokemon.ExpNecessaria : pokemon_exp_necessaria(_old_level);
        var _hp_ratio = variable_struct_exists(_pokemon, "HpAtual") && variable_struct_exists(_pokemon, "HpMax")
            ? clamp(_pokemon.HpAtual / max(1, _pokemon.HpMax), 0, 1)
            : 1;
        var _habilidades = pokemon_data_preservar_equipadas(_pokemon);
        var _capturado = (variable_struct_exists(_pokemon, "Capturado") && _pokemon.Capturado) || (variable_struct_exists(_pokemon, "FoiCapturado") && _pokemon.FoiCapturado);
        var _is_shiny = variable_struct_exists(_pokemon, "IsShiny") && _pokemon.IsShiny;
        var _is_female = variable_struct_exists(_pokemon, "IsFemale") && _pokemon.IsFemale;
        var _slot4 = variable_struct_exists(_pokemon, "Slot4Trancado") && _pokemon.Slot4Trancado;
        var _passiva1 = variable_struct_exists(_pokemon, "Passiva1Desbloqueada") && _pokemon.Passiva1Desbloqueada;
        var _passiva2 = variable_struct_exists(_pokemon, "Passiva2Desbloqueada") && _pokemon.Passiva2Desbloqueada;
        var _bonus_lendario = variable_struct_exists(_pokemon, "BonusLendarioAplicado") && _pokemon.BonusLendarioAplicado;
        var _status = variable_struct_exists(_pokemon, "Status") ? _pokemon.Status : noone;
        var _desmaiado = variable_struct_exists(_pokemon, "Desmaiado") && _pokemon.Desmaiado;
        var _capture_bonus = variable_struct_exists(_pokemon, "CaptureChanceBonus") ? _pokemon.CaptureChanceBonus : 0;

        var _target = pokemon_data_clonar(_target_base, _old_level, false);

        if (!is_struct(_target)) {
            break;
        }

        _pokemon.ID = _target.ID;
        _pokemon.Nome = _target.Nome;
        _pokemon.Tipo1 = _target.Tipo1;
        _pokemon.Tipo2 = _target.Tipo2;
        _pokemon.BirthTags = variable_struct_exists(_target, "BirthTags") ? _target.BirthTags : pokemon_birth_tags_por_tipos(_target.Tipo1, _target.Tipo2);
        _pokemon.RaridadePadrao = variable_struct_exists(_target, "RaridadePadrao") ? _target.RaridadePadrao : PokemonRaridade.COMMON;
        _pokemon.RaridadeEfetiva = variable_struct_exists(_target, "RaridadeEfetiva") ? _target.RaridadeEfetiva : _pokemon.RaridadePadrao;
        _pokemon.RaridadeMultiplicador = pokemon_raridade_multiplicador(_pokemon.RaridadeEfetiva);
        _pokemon.BaseHpMax = _target.BaseHpMax;
        _pokemon.BaseAttack = _target.BaseAttack;
        _pokemon.BaseDefense = _target.BaseDefense;
        _pokemon.BaseSpeed = _target.BaseSpeed;
        _pokemon.HpMax = _target.HpMax;
        _pokemon.Attack = _target.Attack;
        _pokemon.Defense = _target.Defense;
        _pokemon.Speed = _target.Speed;
        _pokemon.GrowthHp = _target.GrowthHp;
        _pokemon.GrowthAttack = _target.GrowthAttack;
        _pokemon.GrowthDefense = _target.GrowthDefense;
        _pokemon.GrowthSpeed = _target.GrowthSpeed;
        _pokemon.GrowthHpCarry = variable_struct_exists(_target, "GrowthHpCarry") ? _target.GrowthHpCarry : 0;
        _pokemon.GrowthAttackCarry = variable_struct_exists(_target, "GrowthAttackCarry") ? _target.GrowthAttackCarry : 0;
        _pokemon.GrowthDefenseCarry = variable_struct_exists(_target, "GrowthDefenseCarry") ? _target.GrowthDefenseCarry : 0;
        _pokemon.GrowthSpeedCarry = variable_struct_exists(_target, "GrowthSpeedCarry") ? _target.GrowthSpeedCarry : 0;
        _pokemon.Arquetipo = variable_struct_exists(_target, "Arquetipo") ? _target.Arquetipo : "";
        _pokemon.TipoInicial = variable_struct_exists(_target, "TipoInicial") ? _target.TipoInicial : _target.Tipo1;
        _pokemon.PoisonArquetipo = variable_struct_exists(_target, "PoisonArquetipo") ? _target.PoisonArquetipo : "";
        _pokemon.FireArquetipo = variable_struct_exists(_target, "FireArquetipo") ? _target.FireArquetipo : "";
        _pokemon.WaterArquetipo = variable_struct_exists(_target, "WaterArquetipo") ? _target.WaterArquetipo : "";
        _pokemon.ElectricArquetipo = variable_struct_exists(_target, "ElectricArquetipo") ? _target.ElectricArquetipo : "";
        _pokemon.IceArquetipo = variable_struct_exists(_target, "IceArquetipo") ? _target.IceArquetipo : "";
        _pokemon.FightingArquetipo = variable_struct_exists(_target, "FightingArquetipo") ? _target.FightingArquetipo : "";
        _pokemon.GroundArquetipo = variable_struct_exists(_target, "GroundArquetipo") ? _target.GroundArquetipo : "";
        _pokemon.FlyingArquetipo = variable_struct_exists(_target, "FlyingArquetipo") ? _target.FlyingArquetipo : "";
        _pokemon.PsychicArquetipo = variable_struct_exists(_target, "PsychicArquetipo") ? _target.PsychicArquetipo : "";
        _pokemon.BugArquetipo = variable_struct_exists(_target, "BugArquetipo") ? _target.BugArquetipo : "";
        _pokemon.RockArquetipo = variable_struct_exists(_target, "RockArquetipo") ? _target.RockArquetipo : "";
        _pokemon.GhostArquetipo = variable_struct_exists(_target, "GhostArquetipo") ? _target.GhostArquetipo : "";
        _pokemon.DragonArquetipo = variable_struct_exists(_target, "DragonArquetipo") ? _target.DragonArquetipo : "";
        _pokemon.SteelArquetipo = variable_struct_exists(_target, "SteelArquetipo") ? _target.SteelArquetipo : "";
        _pokemon.DarkArquetipo = variable_struct_exists(_target, "DarkArquetipo") ? _target.DarkArquetipo : "";
        _pokemon.FairyArquetipo = variable_struct_exists(_target, "FairyArquetipo") ? _target.FairyArquetipo : "";
        _pokemon.NormalArquetipo = variable_struct_exists(_target, "NormalArquetipo") ? _target.NormalArquetipo : "";
        _pokemon.Passiva1Nome = variable_struct_exists(_target, "Passiva1Nome") ? _target.Passiva1Nome : "";
        _pokemon.Passiva1Descricao = variable_struct_exists(_target, "Passiva1Descricao") ? _target.Passiva1Descricao : "";
        _pokemon.Passiva2Nome = variable_struct_exists(_target, "Passiva2Nome") ? _target.Passiva2Nome : "";
        _pokemon.Passiva2Descricao = variable_struct_exists(_target, "Passiva2Descricao") ? _target.Passiva2Descricao : "";
        _pokemon.ListaHabilidadesDisponiveis = variable_struct_exists(_target, "ListaHabilidadesDisponiveis") ? _target.ListaHabilidadesDisponiveis : [];
        _pokemon.WildMinLevel = variable_struct_exists(_target, "WildMinLevel") ? _target.WildMinLevel : pokemon_wild_min_level_atualizar(_pokemon);
        _pokemon.Level = _old_level;
        _pokemon.ExpAtual = _old_exp;
        _pokemon.ExpNecessaria = _old_exp_need;
        _pokemon.HabilidadesEquipadas = _habilidades;
        _pokemon.Slot4Trancado = _slot4;
        _pokemon.Passiva1Desbloqueada = _passiva1;
        _pokemon.Passiva2Desbloqueada = _passiva2;
        _pokemon.BonusLendarioAplicado = _bonus_lendario;
        _pokemon.IsFemale = _is_female;
        _pokemon.FoiCapturado = _capturado;
        _pokemon.Capturado = _capturado;
        _pokemon.Status = _status;
        _pokemon.Desmaiado = _desmaiado;
        _pokemon.CaptureChanceBonus = _capture_bonus;
        _pokemon.HpAtual = max(1, min(_pokemon.HpMax, round(_pokemon.HpMax * _hp_ratio)));

        if (_is_shiny) {
            _pokemon.IsShiny = false;
            pokemon_data_aplicar_shiny(_pokemon);
        } else {
            _pokemon.IsShiny = false;
        }

        if (_capturado) {
            pokedex_capturar(_pokemon.ID);
        }

        array_push(_evolucoes, {
            DeID: _old_id,
            DeNome: _old_name,
            ParaID: _pokemon.ID,
            ParaNome: _pokemon.Nome,
            Level: _pokemon.Level
        });
    }

    return _evolucoes;
}

function pokemon_raridade_nome(_raridade) {
    switch (_raridade) {
        case PokemonRaridade.UNCOMMON: return "Incomum";
        case PokemonRaridade.RARE: return "Raro";
        case PokemonRaridade.EPIC: return "Epico";
        case PokemonRaridade.LEGENDARY: return "Lendario";
        case PokemonRaridade.ULTRA_RARE: return "Ultra Raro";
    }

    return "Comum";
}

function pokemon_raridade_multiplicador(_raridade) {
    switch (_raridade) {
        case PokemonRaridade.UNCOMMON: return 1.05;
        case PokemonRaridade.RARE: return 1.10;
        case PokemonRaridade.EPIC: return 1.20;
        case PokemonRaridade.LEGENDARY: return 1.35;
        case PokemonRaridade.ULTRA_RARE: return 1.40;
    }

    return 1.00;
}

function pokemon_evolution_min_level_por_id(_id) {
    var _min_level = pokemon_evolution_min_level_para_especie(_id);
    return _min_level > 0 ? _min_level : 1;
}

function pokemon_wild_min_level_por_id(_id, _raridade, _hp, _attack, _defense, _speed) {
    var _min_level = pokemon_evolution_min_level_por_id(_id);
    var _total = _hp + _attack + _defense + _speed;

    switch (_raridade) {
        case PokemonRaridade.UNCOMMON:
            _min_level = max(_min_level, 2);
            break;
        case PokemonRaridade.RARE:
            _min_level = max(_min_level, 4);
            break;
        case PokemonRaridade.EPIC:
            _min_level = max(_min_level, 12);
            break;
        case PokemonRaridade.LEGENDARY:
        case PokemonRaridade.ULTRA_RARE:
            _min_level = max(_min_level, 24);
            break;
    }

    if (_total >= 380) {
        _min_level = max(_min_level, 24);
    } else if (_total >= 330) {
        _min_level = max(_min_level, 18);
    } else if (_total >= 285) {
        _min_level = max(_min_level, 12);
    } else if (_total >= 245) {
        _min_level = max(_min_level, 6);
    }

    return clamp(_min_level, 1, 30);
}

function pokemon_wild_min_level_atualizar(_pokemon_data) {
    if (!is_struct(_pokemon_data)) {
        return 1;
    }

    var _raridade = variable_struct_exists(_pokemon_data, "RaridadePadrao") ? _pokemon_data.RaridadePadrao : PokemonRaridade.COMMON;
    var _hp = variable_struct_exists(_pokemon_data, "BaseHpMax") ? _pokemon_data.BaseHpMax : _pokemon_data.HpMax;
    var _atk = variable_struct_exists(_pokemon_data, "BaseAttack") ? _pokemon_data.BaseAttack : _pokemon_data.Attack;
    var _def = variable_struct_exists(_pokemon_data, "BaseDefense") ? _pokemon_data.BaseDefense : _pokemon_data.Defense;
    var _spd = variable_struct_exists(_pokemon_data, "BaseSpeed") ? _pokemon_data.BaseSpeed : _pokemon_data.Speed;

    _pokemon_data.WildMinLevel = pokemon_wild_min_level_por_id(_pokemon_data.ID, _raridade, _hp, _atk, _def, _spd);
    return _pokemon_data.WildMinLevel;
}

function pokemon_raridade_dinheiro_multiplicador(_raridade) {
    switch (_raridade) {
        case PokemonRaridade.UNCOMMON: return 1.15;
        case PokemonRaridade.RARE: return 1.35;
        case PokemonRaridade.EPIC: return 1.75;
        case PokemonRaridade.LEGENDARY: return 2.35;
        case PokemonRaridade.ULTRA_RARE: return 2.80;
    }

    return 1.00;
}

function pokemon_dinheiro_limite_por_encontro(_tipo_encontro) {
    switch (_tipo_encontro) {
        case "captura": return 160;
        case "treinador": return 360;
        case "rocket": return 520;
        case "ginasio": return 680;
        case "selvagem": return 220;
    }

    return 220;
}

function pokemon_dinheiro_multiplicador_encontro(_tipo_encontro) {
    switch (_tipo_encontro) {
        case "captura": return 0.75;
        case "treinador": return 1.70;
        case "rocket": return 2.40;
        case "ginasio": return 3.20;
        case "selvagem": return 1.00;
    }

    return 1.00;
}

function pokemon_recompensa_dinheiro(_pokemon, _tipo_encontro) {
    if (!is_struct(_pokemon)) {
        return 0;
    }

    var _level = variable_struct_exists(_pokemon, "Level") ? _pokemon.Level : 1;
    var _raridade = variable_struct_exists(_pokemon, "RaridadeEfetiva") ? _pokemon.RaridadeEfetiva : PokemonRaridade.COMMON;
    var _base = 8 + max(1, _level) * 3;
    var _bruto = _base * pokemon_dinheiro_multiplicador_encontro(_tipo_encontro) * pokemon_raridade_dinheiro_multiplicador(_raridade);
    return clamp(floor(_bruto), 5, pokemon_dinheiro_limite_por_encontro(_tipo_encontro));
}

function pokemon_raridade_padrao(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    var _info = criatura_info(_id);

    if (is_struct(_info)) {
        return _info.Raridade;
    }

    var _total = _hp + _attack + _defense + _speed;

    if (_total >= 360) {
        return PokemonRaridade.EPIC;
    }

    if (_total >= 280 || _tipo2 != PokemonTipo.NONE) {
        return PokemonRaridade.RARE;
    }

    if (_total >= 235) {
        return PokemonRaridade.UNCOMMON;
    }

    return PokemonRaridade.COMMON;
}

function pokemon_raridade_gem_asset(_raridade) {
    switch (_raridade) {
        case PokemonRaridade.UNCOMMON: return "GRASSGEM.png";
        case PokemonRaridade.RARE: return "ICEGEM.png";
        case PokemonRaridade.EPIC: return "GHOSTGEM.png";
        case PokemonRaridade.LEGENDARY: return "DRAGONGEM.png";
        case PokemonRaridade.ULTRA_RARE: return "PSYCHICGEM.png";
    }

    return "NORMALGEM.png";
}

function pokemon_raridade_cor(_raridade) {
    switch (_raridade) {
        case PokemonRaridade.UNCOMMON: return make_color_rgb(96, 204, 108);
        case PokemonRaridade.RARE: return make_color_rgb(108, 220, 250);
        case PokemonRaridade.EPIC: return make_color_rgb(148, 112, 232);
        case PokemonRaridade.LEGENDARY: return make_color_rgb(250, 188, 74);
        case PokemonRaridade.ULTRA_RARE: return make_color_rgb(238, 112, 236);
    }

    return make_color_rgb(238, 224, 224);
}

function pokemon_raridade_sprite_get(_raridade) {
    if (!variable_global_exists("pokemon_raridade_sprite_cache") || !is_struct(global.pokemon_raridade_sprite_cache)) {
        global.pokemon_raridade_sprite_cache = {};
    }

    var _key = string(_raridade);

    if (variable_struct_exists(global.pokemon_raridade_sprite_cache, _key)) {
        return variable_struct_get(global.pokemon_raridade_sprite_cache, _key);
    }

    var _sprite = demo_asset_sprite("datafiles/sprites/interface/raridade/" + pokemon_raridade_gem_asset(_raridade));
    variable_struct_set(global.pokemon_raridade_sprite_cache, _key, _sprite);
    return _sprite;
}

function pokemon_raridade_draw_icon(_raridade, _x, _y, _size) {
    var _cx = _x + (_size * 0.5);
    var _cy = _y + (_size * 0.5);
    var _r = _size * 0.5;
    var _base = pokemon_raridade_cor(_raridade);
    var _light = merge_color(_base, c_white, 0.42);
    var _shine = merge_color(_base, c_white, 0.78);
    var _dark = merge_color(_base, c_black, 0.34);
    var _deep = merge_color(_base, c_black, 0.62);
    var _edge = make_color_rgb(24, 22, 28);
    var _left = _cx - (_r * 0.86);
    var _right = _cx + (_r * 0.86);
    var _top = _cy - (_r * 0.78);
    var _bottom = _cy + (_r * 0.78);
    var _cut = max(2, _r * 0.22);

    draw_set_alpha(0.25);
    draw_set_color(c_black);
    draw_rectangle(_left + 2, _top + 2, _right + 2, _bottom + 2, false);
    draw_set_alpha(1);

    // Contorno octogonal quadrado, estilo gema lapidada de UI.
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_cx, _cy, _base, 1);
    draw_vertex_color(_left + _cut, _top, _edge, 1);
    draw_vertex_color(_right - _cut, _top, _edge, 1);
    draw_vertex_color(_right, _top + _cut, _edge, 1);
    draw_vertex_color(_right, _bottom - _cut, _edge, 1);
    draw_vertex_color(_right - _cut, _bottom, _edge, 1);
    draw_vertex_color(_left + _cut, _bottom, _edge, 1);
    draw_vertex_color(_left, _bottom - _cut, _edge, 1);
    draw_vertex_color(_left, _top + _cut, _edge, 1);
    draw_vertex_color(_left + _cut, _top, _edge, 1);
    draw_primitive_end();

    var _inset = max(2, _r * 0.18);
    var _il = _left + _inset;
    var _ir = _right - _inset;
    var _it = _top + _inset;
    var _ib = _bottom - _inset;
    var _ic = max(1, _cut - 1);

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_cx, _cy, _base, 1);
    draw_vertex_color(_il + _ic, _it, _shine, 1);
    draw_vertex_color(_ir - _ic, _it, _light, 1);
    draw_vertex_color(_ir, _it + _ic, _base, 1);
    draw_vertex_color(_ir, _ib - _ic, _dark, 1);
    draw_vertex_color(_ir - _ic, _ib, _deep, 1);
    draw_vertex_color(_il + _ic, _ib, _dark, 1);
    draw_vertex_color(_il, _ib - _ic, _base, 1);
    draw_vertex_color(_il, _it + _ic, _light, 1);
    draw_vertex_color(_il + _ic, _it, _shine, 1);
    draw_primitive_end();

    draw_set_alpha(0.58);
    draw_set_color(_shine);
    draw_rectangle(_il + 2, _it + 2, _cx + 1, _cy - 1, false);
    draw_set_color(_light);
    draw_triangle(_cx + 1, _it + 2, _ir - 2, _it + _ic + 1, _cx + 2, _cy - 1, false);
    draw_set_color(_dark);
    draw_triangle(_ir - 1, _cy, _ir - 1, _ib - _ic, _cx + 1, _cy + 1, false);
    draw_set_color(_deep);
    draw_triangle(_cx, _cy + 1, _ir - _ic, _ib - 1, _il + _ic, _ib - 1, false);
    draw_set_alpha(1);

    draw_set_alpha(0.76);
    draw_set_color(c_white);
    draw_rectangle(_il + 3, _it + 3, _il + max(4, _r * 0.62), _it + 4, false);
    draw_rectangle(_ir - max(3, _r * 0.22), _it + 4, _ir - 2, _it + max(6, _r * 0.42), false);
    draw_set_alpha(1);

    draw_set_alpha(0.62);
    draw_set_color(make_color_rgb(32, 28, 34));
    draw_line_width(_il + _ic, _it, _cx, _cy, 1);
    draw_line_width(_ir - _ic, _it, _cx, _cy, 1);
    draw_line_width(_il, _cy, _ir, _cy, 1);
    draw_line_width(_cx, _cy, _cx, _ib, 1);
    draw_set_alpha(1);
}

function pokemon_data_aplicar_multiplicador_atributos(_pokemon, _ratio) {
    if (!is_struct(_pokemon) || _ratio == 1) {
        return false;
    }

    var _hp_atual_pct = 1;

    if (variable_struct_exists(_pokemon, "HpAtual") && _pokemon.HpMax > 0) {
        _hp_atual_pct = clamp(_pokemon.HpAtual / _pokemon.HpMax, 0, 1);
    }

    _pokemon.HpMax = max(1, round(_pokemon.HpMax * _ratio));
    _pokemon.Attack = max(1, round(_pokemon.Attack * _ratio));
    _pokemon.Defense = max(1, round(_pokemon.Defense * _ratio));
    _pokemon.Speed = max(1, round(_pokemon.Speed * _ratio));

    if (variable_struct_exists(_pokemon, "HpAtual")) {
        _pokemon.HpAtual = max(1, min(_pokemon.HpMax, round(_pokemon.HpMax * _hp_atual_pct)));
    }

    return true;
}

function pokemon_data_aplicar_shiny(_pokemon) {
    if (!is_struct(_pokemon) || (variable_struct_exists(_pokemon, "IsShiny") && _pokemon.IsShiny)) {
        return false;
    }

    var _mult_atual = variable_struct_exists(_pokemon, "RaridadeMultiplicador") ? _pokemon.RaridadeMultiplicador : 1.0;
    var _mult_shiny = pokemon_raridade_multiplicador(PokemonRaridade.ULTRA_RARE);
    var _ratio = _mult_shiny / max(0.01, _mult_atual);

    pokemon_data_aplicar_multiplicador_atributos(_pokemon, _ratio);
    _pokemon.IsShiny = true;
    _pokemon.ShinyBonusAplicado = true;
    _pokemon.RaridadeEfetiva = PokemonRaridade.ULTRA_RARE;
    _pokemon.RaridadeMultiplicador = _mult_shiny;
    _pokemon.CaptureChanceBonus = 0.05;
    return true;
}

function pokemon_habilidade_cooldown_balanceado(_cooldown_segundos) {
    return clamp(_cooldown_segundos, 2.8, 10.8);
}

function pokemon_habilidade_dano_balanceado(_poder, _cooldown_segundos, _tags, _efeitos) {
    var _poder_final = _poder;

    if (_poder_final <= 0) {
        var _tem_efeito = is_array(_efeitos) && array_length(_efeitos) > 0;
        var _tem_tag_suporte = false;

        if (is_array(_tags)) {
            for (var _i = 0; _i < array_length(_tags); _i += 1) {
                var _tag = string(_tags[_i]);

                if (_tag == "buff" || _tag == "defense" || _tag == "control" || _tag == "heal" || _tag == "support" || _tag == "combo_setup") {
                    _tem_tag_suporte = true;
                    break;
                }
            }
        }

        return (_tem_efeito || _tem_tag_suporte) ? 6 : 0;
    }

    if (_cooldown_segundos <= 3.4) {
        _poder_final = min(_poder_final, 32);
    } else if (_cooldown_segundos <= 5.0) {
        _poder_final = min(_poder_final, 42);
    } else if (_cooldown_segundos <= 7.2) {
        _poder_final = min(_poder_final, 56);
    } else if (_cooldown_segundos <= 9.2) {
        _poder_final = min(_poder_final, 68);
    } else {
        _poder_final = min(_poder_final, 78);
    }

    return max(6, round(_poder_final));
}

function HabilidadeData(
    _id,
    _nome,
    _tipo,
    _nivel_aprendizado,
    _cooldown_segundos,
    _poder,
    _tags,
    _efeitos
) constructor {
    var _cooldown_balanceado = pokemon_habilidade_cooldown_balanceado(_cooldown_segundos);
    var _poder_balanceado = pokemon_habilidade_dano_balanceado(_poder, _cooldown_balanceado, _tags, _efeitos);

    ID = _id;
    Nome = _nome;
    Tipo = _tipo;
    TipoElementar = _tipo;
    NivelAprendizado = _nivel_aprendizado;
    CooldownSegundos = _cooldown_balanceado;
    TempoRecargaMax = _cooldown_balanceado;
    TempoRecargaAtual = _cooldown_balanceado;
    Poder = _poder_balanceado;
    DanoBase = _poder_balanceado;
    Tags = is_array(_tags) ? _tags : [];
    Efeitos = is_array(_efeitos) ? _efeitos : [];
    EfeitoEspecial = argument_count >= 9 ? argument[8] : "";
    ComboID = argument_count >= 10 ? argument[9] : "";
    Tier = argument_count >= 11 ? argument[10] : 0;
    UpgradeDanoPct = argument_count >= 12 ? argument[11] : 0;
    UpgradeCooldownPct = argument_count >= 13 ? argument[12] : 0;
    DanoBaseOriginal = _poder_balanceado;
    TempoRecargaBase = _cooldown_balanceado;
}

function habilidade_runtime_criar(_habilidade_data) {
    if (!is_struct(_habilidade_data)) {
        return noone;
    }

    var _habilidade = new HabilidadeData(
        _habilidade_data.ID,
        _habilidade_data.Nome,
        _habilidade_data.TipoElementar,
        _habilidade_data.NivelAprendizado,
        _habilidade_data.TempoRecargaMax,
        _habilidade_data.DanoBase,
        _habilidade_data.Tags,
        _habilidade_data.Efeitos,
        _habilidade_data.EfeitoEspecial,
        _habilidade_data.ComboID,
        variable_struct_exists(_habilidade_data, "Tier") ? _habilidade_data.Tier : 0,
        variable_struct_exists(_habilidade_data, "UpgradeDanoPct") ? _habilidade_data.UpgradeDanoPct : 0,
        variable_struct_exists(_habilidade_data, "UpgradeCooldownPct") ? _habilidade_data.UpgradeCooldownPct : 0
    );

    _habilidade.TempoRecargaAtual = _habilidade.TempoRecargaMax;
    return _habilidade;
}

function habilidade_descricao_curta(_habilidade) {
    if (!is_struct(_habilidade)) {
        return "";
    }

    if (is_string(_habilidade.EfeitoEspecial) && _habilidade.EfeitoEspecial != "") {
        var _prefix = "aplicar_status:";

        if (string_pos(_prefix, _habilidade.EfeitoEspecial) == 1) {
            var _status = string_delete(_habilidade.EfeitoEspecial, 1, string_length(_prefix));
            return "Aplica " + _status + " e prepara combos.";
        }
    }

    if (is_array(_habilidade.Efeitos)) {
        for (var _e = 0; _e < array_length(_habilidade.Efeitos); _e += 1) {
            var _efeito = _habilidade.Efeitos[_e];

            if (!is_string(_efeito)) {
                continue;
            }

            if (string_pos("curar_dano:", _efeito) == 1) {
                return "Cura parte do dano causado.";
            }

            if (string_pos("curar_maxhp:", _efeito) == 1) {
                return "Recupera HP e prepara sinergia solar.";
            }

            if (string_pos("aplicar_status_usuario:Crescimento", _efeito) == 1) {
                return "Fortalece proximos golpes criticos.";
            }

            if (string_pos("aplicar_status_usuario:Fotossintese", _efeito) == 1) {
                return "Prepara golpes solares mais fortes.";
            }

            if (string_pos("aplicar_status_usuario:EstaticaAtiva", _efeito) == 1) {
                return "Acelera sua rotacao eletrica.";
            }

            if (string_pos("aplicar_status_usuario:MantoGelo", _efeito) == 1) {
                return "Aumenta resistencia, mas reduz o ritmo.";
            }

            if (string_pos("aplicar_status_usuario:FuriaDraconica", _efeito) == 1) {
                return "Prepara dano maior quando estiver ferido.";
            }

            if (string_pos("aplicar_status_usuario:EscamaImperial", _efeito) == 1) {
                return "Reforca defesa antes dos golpes de dragao.";
            }

            if (string_pos("aplicar_status_usuario:AscensaoDraconica", _efeito) == 1) {
                return "Carrega energia ancestral para golpes longos.";
            }

            if (string_pos("aplicar_status_usuario:Predador", _efeito) == 1) {
                return "Ganha pressao quando esta em vantagem de HP.";
            }

            if (string_pos("aplicar_status_usuario:EspinhosFerro", _efeito) == 1) {
                return "Devolve parte do dano recebido.";
            }

            if (string_pos("aplicar_status_usuario:Fortificado", _efeito) == 1) {
                return "Empilha defesa para segurar a luta.";
            }

            if (string_pos("aplicar_status_usuario:BlindagemMagnetica", _efeito) == 1) {
                return "Cria uma blindagem e acelera a rotacao.";
            }

            if (string_pos("aplicar_status_usuario:ImpactoPesado", _efeito) == 1) {
                return "Converte defesa e peso em dano.";
            }

            if (string_pos("aplicar_status_usuario:LigaPesada", _efeito) == 1) {
                return "Aumenta resistencia para golpes lentos.";
            }

            if (string_pos("aplicar_status_usuario:GolpeBaixo", _efeito) == 1) {
                return "Prepara punicao contra alvos carregando.";
            }

            if (string_pos("aplicar_status_usuario:JogoSujo", _efeito) == 1) {
                return "Transforma debuffs inimigos em pressao.";
            }

            if (string_pos("aplicar_status_usuario:CamuflagemSombria", _efeito) == 1) {
                return "Aumenta evasao enquanto o alvo esta marcado.";
            }

            if (string_pos("aplicar_status_usuario:CopiaSombria", _efeito) == 1) {
                return "Cria uma ilusao que pode absorver golpe.";
            }

            if (string_pos("aplicar_status_usuario:PerseguicaoSombria", _efeito) == 1) {
                return "Pune alvos evasivos ou fora de posicao.";
            }

            if (string_pos("aplicar_status_usuario:EncantoCarga", _efeito) == 1) {
                return "Carrega o proximo ciclo de dano feerico.";
            }

            if (string_pos("aplicar_status_usuario:LuzPurificadora", _efeito) == 1) {
                return "Purifica debuffs leves e sustenta o usuario.";
            }

            if (string_pos("aplicar_status_usuario:AuraMistica", _efeito) == 1) {
                return "Cria aura para dano e protecao leves.";
            }

            if (string_pos("aplicar_status_usuario:BarreiraFada", _efeito) == 1) {
                return "Cria uma barreira feerica contra atrito.";
            }

            if (string_pos("aplicar_status_usuario:ForcaNeutra", _efeito) == 1) {
                return "Mantem dano consistente sem setup complexo.";
            }

            if (string_pos("aplicar_status_usuario:EstoqueDefensivo", _efeito) == 1) {
                return "Empilha defesa para liberar dano depois.";
            }

            if (string_pos("aplicar_status_usuario:LegadoAtivo", _efeito) == 1) {
                return "Prepara um buff estavel para a equipe.";
            }

            if (string_pos("aplicar_status_usuario:MimetismoAtivo", _efeito) == 1) {
                return "Adapta o corpo para resistir melhor.";
            }

            if (string_pos("aplicar_status_usuario:ReciclagemAtiva", _efeito) == 1) {
                return "Reaproveita ritmo e acelera a rotacao.";
            }

            if (string_pos("bonus_dano_alvo_status:Envenenado", _efeito) == 1) {
                return "Causa bonus contra alvos envenenados.";
            }

            if (string_pos("bonus_dano_alvo_status:Enraizado", _efeito) == 1) {
                return "Causa bonus contra alvos enraizados.";
            }

            if (string_pos("bonus_dano_alvo_status:Corroendo", _efeito) == 1) {
                return "Explora defesa corroida do alvo.";
            }

            if (string_pos("bonus_dano_alvo_status:Queimando", _efeito) == 1) {
                return "Causa bonus contra alvos queimando.";
            }

            if (string_pos("bonus_dano_alvo_status:ArmaduraDerretida", _efeito) == 1) {
                return "Explora defesa derretida do alvo.";
            }

            if (string_pos("bonus_dano_alvo_status:Molhado", _efeito) == 1) {
                return "Causa bonus contra alvos molhados.";
            }

            if (string_pos("bonus_dano_alvo_status:Paralisado", _efeito) == 1) {
                return "Causa bonus contra alvos paralisados.";
            }

            if (string_pos("bonus_dano_alvo_status:Ofuscado", _efeito) == 1) {
                return "Causa bonus contra alvos ofuscados.";
            }

            if (string_pos("bonus_dano_alvo_status:Sobrecarregado", _efeito) == 1) {
                return "Explora carga eletrica acumulada.";
            }

            if (string_pos("bonus_dano_alvo_status:ErroEletrico", _efeito) == 1) {
                return "Pune inimigos que erraram ataques.";
            }

            if (string_pos("bonus_dano_alvo_status:Gelado", _efeito) == 1) {
                return "Causa bonus contra alvos gelados.";
            }

            if (string_pos("bonus_dano_alvo_status:Congelando", _efeito) == 1) {
                return "Causa bonus contra alvos quase congelados.";
            }

            if (string_pos("bonus_dano_alvo_status:Fragil", _efeito) == 1) {
                return "Explora alvos fragilizados pelo gelo.";
            }

            if (string_pos("bonus_dano_alvo_status:Fragmentado", _efeito) == 1) {
                return "Explora rachaduras abertas por golpes de pedra.";
            }

            if (string_pos("bonus_dano_alvo_status:Assombrado", _efeito) == 1) {
                return "Cresce contra alvos assombrados.";
            }

            if (string_pos("bonus_dano_alvo_status:Maldito", _efeito) == 1) {
                return "Drena melhor alvos marcados por maldicao.";
            }

            if (string_pos("bonus_dano_alvo_status:Amedrontado", _efeito) == 1) {
                return "Pune alvos amedrontados ou fora de ritmo.";
            }

            if (string_pos("bonus_dano_alvo_status:MarcadoSombrio", _efeito) == 1) {
                return "Pune alvos marcados por truques sombrios.";
            }

            if (string_pos("bonus_dano_alvo_status:BrilhoOfuscante", _efeito) == 1) {
                return "Explora alvo encantado e com dano reduzido.";
            }

            if (string_pos("bonus_dano_alvo_status:LegadoAtivo", _efeito) == 1) {
                return "Explora alvo fora do proprio ritmo.";
            }

            if (string_pos("bonus_dano_alvo_status:CopiaSombria", _efeito) == 1) {
                return "Explora alvos confundidos por ilusoes.";
            }

            if (string_pos("bonus_dano_alvo_status:BlindagemMagnetica", _efeito) == 1) {
                return "Explora alvos presos em campo magnetico.";
            }

            if (string_pos("bonus_dano_usuario_status:CascaRocha", _efeito) == 1) {
                return "Escala com a propria defesa de rocha.";
            }

            if (string_pos("bonus_dano_usuario_status:ImpactoGeologico", _efeito) == 1) {
                return "Fica mais forte apos preparar impacto.";
            }

            if (string_pos("bonus_dano_usuario_status:TerrorCrescente", _efeito) == 1) {
                return "Escala conforme o terror aumenta.";
            }

            if (string_pos("bonus_dano_usuario_status:EssenciaDrenada", _efeito) == 1) {
                return "Usa essencia roubada para bater melhor.";
            }

            if (string_pos("bonus_dano_usuario_status:FuriaDraconica", _efeito) == 1) {
                return "Escala quando a furia draconica esta ativa.";
            }

            if (string_pos("bonus_dano_usuario_status:EscamaImperial", _efeito) == 1) {
                return "Usa escamas reforcadas para bater melhor.";
            }

            if (string_pos("bonus_dano_usuario_status:AscensaoDraconica", _efeito) == 1) {
                return "Cresce apos preparar energia ancestral.";
            }

            if (string_pos("bonus_dano_usuario_status:Predador", _efeito) == 1) {
                return "Pune alvos quando esta em vantagem.";
            }

            if (string_pos("bonus_dano_usuario_status:EspinhosFerro", _efeito) == 1) {
                return "Converte protecao espinhosa em dano.";
            }

            if (string_pos("bonus_dano_usuario_status:Fortificado", _efeito) == 1) {
                return "Escala com a fortificacao ativa.";
            }

            if (string_pos("bonus_dano_usuario_status:ImpactoPesado", _efeito) == 1) {
                return "Usa peso metalico para aumentar o dano.";
            }

            if (string_pos("bonus_dano_usuario_status:BlindagemMagnetica", _efeito) == 1) {
                return "Ganha dano ao lutar sob blindagem magnetica.";
            }

            if (string_pos("bonus_dano_usuario_status:LigaPesada", _efeito) == 1) {
                return "Usa uma liga pesada para bater melhor.";
            }

            if (string_pos("bonus_dano_usuario_status:GolpeBaixo", _efeito) == 1) {
                return "Escala com a janela de golpe baixo ativa.";
            }

            if (string_pos("bonus_dano_usuario_status:JogoSujo", _efeito) == 1) {
                return "Bate melhor enquanto jogo sujo esta ativo.";
            }

            if (string_pos("bonus_dano_usuario_status:CamuflagemSombria", _efeito) == 1) {
                return "Ganha dano apos se camuflar.";
            }

            if (string_pos("bonus_dano_usuario_status:CopiaSombria", _efeito) == 1) {
                return "Usa ilusao ativa para aumentar impacto.";
            }

            if (string_pos("bonus_dano_usuario_status:PerseguicaoSombria", _efeito) == 1) {
                return "Pune melhor quando esta em perseguicao.";
            }

            if (string_pos("bonus_dano_usuario_status:EncantoCarga", _efeito) == 1) {
                return "Consome carga feerica para bater mais forte.";
            }

            if (string_pos("bonus_dano_usuario_status:LuzPurificadora", _efeito) == 1) {
                return "Bate melhor enquanto esta purificado.";
            }

            if (string_pos("bonus_dano_usuario_status:AuraMistica", _efeito) == 1) {
                return "Escala com a aura mistica ativa.";
            }

            if (string_pos("bonus_dano_usuario_status:ForcaNeutra", _efeito) == 1) {
                return "Ganha dano enquanto mantem ritmo neutro.";
            }

            if (string_pos("bonus_dano_usuario_status:EstoqueDefensivo", _efeito) == 1) {
                return "Libera defesa acumulada em dano.";
            }

            if (string_pos("bonus_dano_usuario_status:LegadoAtivo", _efeito) == 1) {
                return "Usa legado ativo para aumentar impacto.";
            }

            if (string_pos("bonus_dano_usuario_status:MimetismoAtivo", _efeito) == 1) {
                return "Bate melhor apos se adaptar.";
            }

            if (string_pos("bonus_dano_alvo_hp_baixo:", _efeito) == 1) {
                return "Finaliza melhor alvos com HP baixo.";
            }

            if (string_pos("bonus_dano_alvo_cd:", _efeito) == 1) {
                return "Escala com o cooldown atual do alvo.";
            }

            if (string_pos("reduzir_cooldowns_usuario:", _efeito) == 1) {
                return "Acelera a recarga das suas habilidades.";
            }

            if (string_pos("aumentar_cooldowns_alvo:", _efeito) == 1) {
                return "Atrasa os cooldowns do alvo.";
            }

            if (string_pos("sacrificar_hp_pct:", _efeito) == 1) {
                return "Consome um pouco de HP para aumentar o dano.";
            }

            if (string_pos("bonus_dano_sacrificio:", _efeito) == 1) {
                return "Golpe arriscado com dano maior.";
            }
        }
    }

    if (is_string(_habilidade.ComboID) && _habilidade.ComboID != "") {
        return "Causa bonus se o alvo estiver " + _habilidade.ComboID + ".";
    }

    if (is_array(_habilidade.Tags)) {
        for (var _i = 0; _i < array_length(_habilidade.Tags); _i += 1) {
            switch (_habilidade.Tags[_i]) {
                case "fast": return "Golpe rapido para manter pressao.";
                case "single_target": return "Ataque direto contra um alvo.";
                case "burn": return "Pode iniciar sinergias de queimadura.";
                case "melt": return "Derrete defesa e abre dano de fogo.";
                case "tempo": return "Manipula cooldowns durante a luta.";
                case "blind": return "Ofusca o alvo e pode forcar erro.";
                case "shock": return "Acumula carga eletrica para combos.";
                case "frost": return "Reduz o ritmo do alvo.";
                case "shatter": return "Quebra alvos fragilizados pelo gelo.";
                case "poison": return "Prepara ou explora veneno.";
                case "root": return "Prende o alvo para combos de grama.";
                case "drain": return "Drena HP durante rotas longas.";
                case "solar": return "Escala com Fotossintese.";
                case "sustain": return "Ajuda a sobreviver em rotas longas.";
                case "control": return "Atrasa e controla o inimigo.";
                case "defense": return "Aumenta sua resistencia.";
                case "combo": return "Escala quando a rotacao encaixa em sequencia.";
                case "guardbreak": return "Quebra postura e reduz defesa efetiva.";
                case "earth": return "Controla campo com lama, areia e impacto.";
                case "wind": return "Controla o ritmo com vento e mobilidade.";
                case "evade": return "Aumenta evasao e pressao de velocidade.";
                case "mind": return "Interrompe e enfraquece a mente do alvo.";
                case "interrupt": return "Atrasa ou quebra a rotacao inimiga.";
                case "spatial": return "Manipula defesa e tempo do alvo.";
                case "swarm": return "Pressiona com muitos golpes curtos.";
                case "silk": return "Atrasa cooldowns e prende o alvo.";
                case "cocoon": return "Ganha resistencia enquanto prepara golpes.";
                case "metamorph": return "Transforma defesa em pressao crescente.";
                case "stone": return "Golpe de pedra consistente e pesado.";
                case "impact": return "Troca risco por impacto alto.";
                case "shell": return "Converte defesa em estabilidade.";
                case "shard": return "Fragmenta o alvo para combos.";
                case "terror": return "Escala quanto mais a luta se prolonga.";
                case "curse": return "Marca o alvo para dreno e desgaste.";
                case "intangible": return "Cria janelas curtas de evasao.";
                case "essence": return "Rouba vida e buffs leves do alvo.";
                case "dragon": return "Golpe draconico de alto impacto e preparo.";
                case "fury": return "Escala melhor quando o usuario esta ferido.";
                case "scale": return "Reforca resistencia antes de bater.";
                case "breath": return "Golpe ancestral de cooldown mais longo.";
                case "predator": return "Pune alvos em desvantagem de HP.";
                case "steel": return "Golpe de aco estavel e defensivo.";
                case "thorns": return "Devolve parte do dano recebido.";
                case "fortify": return "Empilha defesa para segurar rotas longas.";
                case "heavy": return "Converte defesa e peso em dano.";
                case "magnetic": return "Usa campo magnetico para protecao.";
                case "dark": return "Golpe sombrio baseado em truques.";
                case "trick": return "Explora debuffs e janelas ruins do alvo.";
                case "lowblow": return "Pune alvo carregando cooldown.";
                case "dirty": return "Escala contra alvo ja enfraquecido.";
                case "camouflage": return "Usa evasao e ilusao defensiva.";
                case "pursuit": return "Persegue alvo evasivo ou atrasado.";
                case "shadowcopy": return "Cria copia para confundir o inimigo.";
                case "fairy": return "Golpe feerico de suporte e explosao.";
                case "charge": return "Carrega dano para o proximo ciclo.";
                case "purify": return "Remove pressao e sustenta a rota.";
                case "aura": return "Gera buff leve e sinergia elemental.";
                case "charm": return "Enfraquece o dano do alvo.";
                case "normal": return "Golpe normal consistente e flexivel.";
                case "stockpile": return "Acumula defesa para liberar depois.";
                case "legacy": return "Prepara continuidade e adaptacao.";
                case "mimic": return "Adapta defesa e ritmo.";
                case "recycle": return "Reaproveita recursos e cooldowns.";
            }
        }
    }

    return _habilidade.DanoBase > 0 ? "Dano simples e confiavel." : "Habilidade de suporte.";
}

function PokemonData(
    _id,
    _nome,
    _tipo1,
    _tipo2,
    _hp_max,
    _attack,
    _defense,
    _speed,
    _growth_hp,
    _growth_attack,
    _growth_defense,
    _growth_speed,
    _level,
    _exp_atual,
    _lista_habilidades_disponiveis
) constructor {
    ID = _id;
    Nome = _nome;
    Tipo1 = _tipo1;
    Tipo2 = _tipo2;
    BirthTags = argument_count >= 16 && is_array(argument[15]) ? argument[15] : [];
    RaridadePadrao = argument_count >= 17 ? argument[16] : pokemon_raridade_padrao(_id, _tipo1, _tipo2, _hp_max, _attack, _defense, _speed);
    RaridadeEfetiva = RaridadePadrao;
    RaridadeMultiplicador = pokemon_raridade_multiplicador(RaridadeEfetiva);
    var _aplicar_raridade = argument_count >= 18 ? argument[17] : true;
    var _rarity_mult = _aplicar_raridade ? RaridadeMultiplicador : 1.0;
    BaseHpMax = _hp_max;
    BaseAttack = _attack;
    BaseDefense = _defense;

    var _foco = "ataque";
    var _max_val = _attack;
    if (_defense > _max_val) { _foco = "defesa"; _max_val = _defense; }
    if (_speed > _max_val) { _foco = "velocidade"; }
    Foco = _foco;
    PassivaAtual = "passiva_" + pokemon_tipo_string(_tipo1) + "_" + _foco + "_1";
    BaseSpeed = _speed;
    WildMinLevel = pokemon_wild_min_level_por_id(ID, RaridadePadrao, BaseHpMax, BaseAttack, BaseDefense, BaseSpeed);
    HpMax = max(1, round(_hp_max * _rarity_mult));
    Attack = max(1, round(_attack * _rarity_mult));
    Defense = max(1, round(_defense * _rarity_mult));
    Speed = max(1, round(_speed * _rarity_mult));
    Arquetipo = "";
    TipoInicial = _tipo1;
    PoisonArquetipo = "";
    FireArquetipo = "";
    WaterArquetipo = "";
    ElectricArquetipo = "";
    IceArquetipo = "";
    FightingArquetipo = "";
    GroundArquetipo = "";
    FlyingArquetipo = "";
    PsychicArquetipo = "";
    BugArquetipo = "";
    RockArquetipo = "";
    GhostArquetipo = "";
    DragonArquetipo = "";
    SteelArquetipo = "";
    DarkArquetipo = "";
    FairyArquetipo = "";
    NormalArquetipo = "";
    Passiva1Nome = "";
    Passiva1Descricao = "";
    Passiva2Nome = "";
    Passiva2Descricao = "";
    GrowthHp = _growth_hp;
    GrowthAttack = _growth_attack;
    GrowthDefense = _growth_defense;
    GrowthSpeed = _growth_speed;
    GrowthHpCarry = 0;
    GrowthAttackCarry = 0;
    GrowthDefenseCarry = 0;
    GrowthSpeedCarry = 0;
    Level = clamp(_level, 1, 30);
    ExpAtual = max(0, _exp_atual);
    ExpNecessaria = pokemon_exp_necessaria(Level);
    ListaHabilidadesDisponiveis = is_array(_lista_habilidades_disponiveis)
        ? _lista_habilidades_disponiveis
        : [];
    HabilidadesEquipadas = array_create(4, noone);
    Slot4Trancado = false;
    EstagioEvolucao = 0;
    Passiva1Desbloqueada = false;
    Passiva2Desbloqueada = false;
    BonusLendarioAplicado = false;
    IsShiny = false;
    IsFemale = false;
    CaptureChanceBonus = 0;
    ShinyBonusAplicado = false;
    FoiCapturado = false;
    Capturado = false;

    static equipar_habilidade = function(_habilidade, _slot) {
        if (_slot < 0 || _slot >= 4) {
            show_debug_message("Slot de habilidade invalido: " + string(_slot));
            return false;
        }

        if (!is_struct(_habilidade)) {
            return false;
        }

        HabilidadesEquipadas[_slot] = habilidade_runtime_criar(_habilidade);
        return true;
    };

    static pode_subir_nivel = function() {
        return Level < 30 && ExpAtual >= ExpNecessaria;
    };

    static adicionar_exp = function(_valor) {
        return pokemon_ganhar_exp(self, _valor);
    };
}

function pokemon_exp_necessaria(_level) {
    var _lvl = clamp(_level, 1, 30);
    var _inicio_facil = 34 + power(_lvl, 1.45) * 15;
    var _freio_final = power(max(0, _lvl - 10), 2.12) * 8;
    return floor(_inicio_facil + _freio_final);
}

function pokemon_data_clonar(_pokemon_data, _level) {
    if (!is_struct(_pokemon_data)) {
        return undefined;
    }

    if (argument_count < 2) {
        _level = _pokemon_data.Level;
    }

    var _permitir_evolucao = argument_count >= 3 ? argument[2] : true;
    var _clone = new PokemonData(
        _pokemon_data.ID,
        _pokemon_data.Nome,
        _pokemon_data.Tipo1,
        _pokemon_data.Tipo2,
        _pokemon_data.HpMax,
        _pokemon_data.Attack,
        _pokemon_data.Defense,
        _pokemon_data.Speed,
        _pokemon_data.GrowthHp,
        _pokemon_data.GrowthAttack,
        _pokemon_data.GrowthDefense,
        _pokemon_data.GrowthSpeed,
        1,
        0,
        _pokemon_data.ListaHabilidadesDisponiveis,
        variable_struct_exists(_pokemon_data, "BirthTags") ? _pokemon_data.BirthTags : [],
        variable_struct_exists(_pokemon_data, "RaridadePadrao") ? _pokemon_data.RaridadePadrao : PokemonRaridade.COMMON,
        false
    );

    _clone.Arquetipo = variable_struct_exists(_pokemon_data, "Arquetipo") ? _pokemon_data.Arquetipo : "";
    _clone.TipoInicial = variable_struct_exists(_pokemon_data, "TipoInicial") ? _pokemon_data.TipoInicial : _pokemon_data.Tipo1;
    _clone.PoisonArquetipo = variable_struct_exists(_pokemon_data, "PoisonArquetipo") ? _pokemon_data.PoisonArquetipo : "";
    _clone.FireArquetipo = variable_struct_exists(_pokemon_data, "FireArquetipo") ? _pokemon_data.FireArquetipo : "";
    _clone.WaterArquetipo = variable_struct_exists(_pokemon_data, "WaterArquetipo") ? _pokemon_data.WaterArquetipo : "";
    _clone.ElectricArquetipo = variable_struct_exists(_pokemon_data, "ElectricArquetipo") ? _pokemon_data.ElectricArquetipo : "";
    _clone.IceArquetipo = variable_struct_exists(_pokemon_data, "IceArquetipo") ? _pokemon_data.IceArquetipo : "";
    _clone.FightingArquetipo = variable_struct_exists(_pokemon_data, "FightingArquetipo") ? _pokemon_data.FightingArquetipo : "";
    _clone.GroundArquetipo = variable_struct_exists(_pokemon_data, "GroundArquetipo") ? _pokemon_data.GroundArquetipo : "";
    _clone.FlyingArquetipo = variable_struct_exists(_pokemon_data, "FlyingArquetipo") ? _pokemon_data.FlyingArquetipo : "";
    _clone.PsychicArquetipo = variable_struct_exists(_pokemon_data, "PsychicArquetipo") ? _pokemon_data.PsychicArquetipo : "";
    _clone.BugArquetipo = variable_struct_exists(_pokemon_data, "BugArquetipo") ? _pokemon_data.BugArquetipo : "";
    _clone.RockArquetipo = variable_struct_exists(_pokemon_data, "RockArquetipo") ? _pokemon_data.RockArquetipo : "";
    _clone.GhostArquetipo = variable_struct_exists(_pokemon_data, "GhostArquetipo") ? _pokemon_data.GhostArquetipo : "";
    _clone.DragonArquetipo = variable_struct_exists(_pokemon_data, "DragonArquetipo") ? _pokemon_data.DragonArquetipo : "";
    _clone.SteelArquetipo = variable_struct_exists(_pokemon_data, "SteelArquetipo") ? _pokemon_data.SteelArquetipo : "";
    _clone.DarkArquetipo = variable_struct_exists(_pokemon_data, "DarkArquetipo") ? _pokemon_data.DarkArquetipo : "";
    _clone.FairyArquetipo = variable_struct_exists(_pokemon_data, "FairyArquetipo") ? _pokemon_data.FairyArquetipo : "";
    _clone.NormalArquetipo = variable_struct_exists(_pokemon_data, "NormalArquetipo") ? _pokemon_data.NormalArquetipo : "";
    _clone.Passiva1Nome = variable_struct_exists(_pokemon_data, "Passiva1Nome") ? _pokemon_data.Passiva1Nome : "";
    _clone.Passiva1Descricao = variable_struct_exists(_pokemon_data, "Passiva1Descricao") ? _pokemon_data.Passiva1Descricao : "";
    _clone.Passiva2Nome = variable_struct_exists(_pokemon_data, "Passiva2Nome") ? _pokemon_data.Passiva2Nome : "";
    _clone.Passiva2Descricao = variable_struct_exists(_pokemon_data, "Passiva2Descricao") ? _pokemon_data.Passiva2Descricao : "";
    _clone.RaridadePadrao = variable_struct_exists(_pokemon_data, "RaridadePadrao") ? _pokemon_data.RaridadePadrao : PokemonRaridade.COMMON;
    _clone.RaridadeEfetiva = _clone.RaridadePadrao;
    _clone.RaridadeMultiplicador = pokemon_raridade_multiplicador(_clone.RaridadeEfetiva);
    _clone.WildMinLevel = variable_struct_exists(_pokemon_data, "WildMinLevel") ? _pokemon_data.WildMinLevel : pokemon_wild_min_level_atualizar(_clone);

    var _target_level = clamp(_level, 1, 30);

    while (_clone.Level < _target_level) {
        _clone.Level += 1;
        pokemon_aplicar_ganho_atributos(_clone, _clone.Level);
        pokemon_progressao_marco_aplicar(_clone, _clone.Level);
    }

    _clone.ExpAtual = 0;
    _clone.ExpNecessaria = _clone.Level >= 30 ? 0 : pokemon_exp_necessaria(_clone.Level);

    if (_permitir_evolucao) {
        pokemon_evoluir_se_necessario(_clone);
    }

    for (var _i = 0; _i < min(1, array_length(_clone.ListaHabilidadesDisponiveis)); _i += 1) {
        var _habilidade = _clone.ListaHabilidadesDisponiveis[_i];

        if (is_struct(_habilidade) && _habilidade.NivelAprendizado <= 1) {
            _clone.equipar_habilidade(_habilidade, 0);
        }
    }

    return _clone;
}

function pokemon_db_criar() {
    var _db = {};
    pokemon_db_preencher_geracoes_1_5(_db);
    return _db;
}

function pokemon_tipo_por_tag(_tag) {
    switch (_tag) {
        case "normal": return PokemonTipo.NORMAL;
        case "fogo": return PokemonTipo.FIRE;
        case "agua": return PokemonTipo.WATER;
        case "grama":
        case "fazenda": return PokemonTipo.GRASS;
        case "eletrico": return PokemonTipo.ELECTRIC;
        case "gelo": return PokemonTipo.ICE;
        case "luta": return PokemonTipo.FIGHTING;
        case "veneno": return PokemonTipo.POISON;
        case "terra": return PokemonTipo.GROUND;
        case "voador": return PokemonTipo.FLYING;
        case "psiquico": return PokemonTipo.PSYCHIC;
        case "inseto": return PokemonTipo.BUG;
        case "pedra":
        case "caverna": return PokemonTipo.ROCK;
        case "fantasma": return PokemonTipo.GHOST;
        case "dragao": return PokemonTipo.DRAGON;
        case "sombrio": return PokemonTipo.DARK;
        case "aco": return PokemonTipo.STEEL;
        case "fada": return PokemonTipo.FAIRY;
    }

    return PokemonTipo.NORMAL;
}

function pokemon_tag_por_tipo(_tipo) {
    switch (_tipo) {
        case PokemonTipo.FIRE: return "fogo";
        case PokemonTipo.WATER: return "agua";
        case PokemonTipo.GRASS: return "grama";
        case PokemonTipo.ELECTRIC: return "eletrico";
        case PokemonTipo.ICE: return "gelo";
        case PokemonTipo.FIGHTING: return "luta";
        case PokemonTipo.POISON: return "veneno";
        case PokemonTipo.GROUND: return "terra";
        case PokemonTipo.FLYING: return "voador";
        case PokemonTipo.PSYCHIC: return "psiquico";
        case PokemonTipo.BUG: return "inseto";
        case PokemonTipo.ROCK: return "pedra";
        case PokemonTipo.GHOST: return "fantasma";
        case PokemonTipo.DRAGON: return "dragao";
        case PokemonTipo.DARK: return "sombrio";
        case PokemonTipo.STEEL: return "aco";
        case PokemonTipo.FAIRY: return "fada";
    }

    return "normal";
}

function pokemon_nome_tipo(_tipo) {
    switch (_tipo) {
        case PokemonTipo.FIRE: return "Fogo";
        case PokemonTipo.WATER: return "Agua";
        case PokemonTipo.GRASS: return "Grama";
        case PokemonTipo.ELECTRIC: return "Eletrico";
        case PokemonTipo.ICE: return "Gelo";
        case PokemonTipo.FIGHTING: return "Lutador";
        case PokemonTipo.POISON: return "Veneno";
        case PokemonTipo.GROUND: return "Terrestre";
        case PokemonTipo.FLYING: return "Voador";
        case PokemonTipo.PSYCHIC: return "Psiquico";
        case PokemonTipo.BUG: return "Inseto";
        case PokemonTipo.ROCK: return "Pedra";
        case PokemonTipo.GHOST: return "Fantasma";
        case PokemonTipo.DRAGON: return "Dragao";
        case PokemonTipo.DARK: return "Sombrio";
        case PokemonTipo.STEEL: return "Aco";
        case PokemonTipo.FAIRY: return "Fada";
    }

    return "Normal";
}

function pokemon_tipo_relacao_ofensiva(_tipo_ataque, _tipo_defesa) {
    if (_tipo_ataque == PokemonTipo.NONE || _tipo_defesa == PokemonTipo.NONE) {
        return 0;
    }

    switch (_tipo_ataque) {
        case PokemonTipo.NORMAL:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.ROCK, PokemonTipo.GHOST, PokemonTipo.STEEL])) return -1;
            break;

        case PokemonTipo.FIRE:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.GRASS, PokemonTipo.ICE, PokemonTipo.BUG, PokemonTipo.STEEL])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIRE, PokemonTipo.WATER, PokemonTipo.ROCK, PokemonTipo.DRAGON])) return -1;
            break;

        case PokemonTipo.WATER:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIRE, PokemonTipo.GROUND, PokemonTipo.ROCK])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.WATER, PokemonTipo.GRASS, PokemonTipo.DRAGON])) return -1;
            break;

        case PokemonTipo.GRASS:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.WATER, PokemonTipo.GROUND, PokemonTipo.ROCK])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIRE, PokemonTipo.GRASS, PokemonTipo.POISON, PokemonTipo.FLYING, PokemonTipo.BUG, PokemonTipo.DRAGON, PokemonTipo.STEEL])) return -1;
            break;

        case PokemonTipo.ELECTRIC:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.WATER, PokemonTipo.FLYING])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.ELECTRIC, PokemonTipo.GRASS, PokemonTipo.GROUND, PokemonTipo.DRAGON])) return -1;
            break;

        case PokemonTipo.ICE:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.GRASS, PokemonTipo.GROUND, PokemonTipo.FLYING, PokemonTipo.DRAGON])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIRE, PokemonTipo.WATER, PokemonTipo.ICE, PokemonTipo.STEEL])) return -1;
            break;

        case PokemonTipo.FIGHTING:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.NORMAL, PokemonTipo.ICE, PokemonTipo.ROCK, PokemonTipo.DARK, PokemonTipo.STEEL])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.POISON, PokemonTipo.FLYING, PokemonTipo.PSYCHIC, PokemonTipo.BUG, PokemonTipo.GHOST, PokemonTipo.FAIRY])) return -1;
            break;

        case PokemonTipo.POISON:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.GRASS, PokemonTipo.FAIRY])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.POISON, PokemonTipo.GROUND, PokemonTipo.ROCK, PokemonTipo.GHOST, PokemonTipo.STEEL])) return -1;
            break;

        case PokemonTipo.GROUND:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIRE, PokemonTipo.ELECTRIC, PokemonTipo.POISON, PokemonTipo.ROCK, PokemonTipo.STEEL])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.GRASS, PokemonTipo.FLYING, PokemonTipo.BUG])) return -1;
            break;

        case PokemonTipo.FLYING:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.GRASS, PokemonTipo.FIGHTING, PokemonTipo.BUG])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.ELECTRIC, PokemonTipo.ROCK, PokemonTipo.STEEL])) return -1;
            break;

        case PokemonTipo.PSYCHIC:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIGHTING, PokemonTipo.POISON])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.PSYCHIC, PokemonTipo.DARK, PokemonTipo.STEEL])) return -1;
            break;

        case PokemonTipo.BUG:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.GRASS, PokemonTipo.PSYCHIC, PokemonTipo.DARK])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIRE, PokemonTipo.FIGHTING, PokemonTipo.POISON, PokemonTipo.FLYING, PokemonTipo.GHOST, PokemonTipo.STEEL, PokemonTipo.FAIRY])) return -1;
            break;

        case PokemonTipo.ROCK:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIRE, PokemonTipo.ICE, PokemonTipo.FLYING, PokemonTipo.BUG])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIGHTING, PokemonTipo.GROUND, PokemonTipo.STEEL])) return -1;
            break;

        case PokemonTipo.GHOST:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.PSYCHIC, PokemonTipo.GHOST])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.NORMAL, PokemonTipo.DARK])) return -1;
            break;

        case PokemonTipo.DRAGON:
            if (_tipo_defesa == PokemonTipo.DRAGON) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.STEEL, PokemonTipo.FAIRY])) return -1;
            break;

        case PokemonTipo.DARK:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.PSYCHIC, PokemonTipo.GHOST])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIGHTING, PokemonTipo.DARK, PokemonTipo.FAIRY])) return -1;
            break;

        case PokemonTipo.STEEL:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.ICE, PokemonTipo.ROCK, PokemonTipo.FAIRY])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIRE, PokemonTipo.WATER, PokemonTipo.ELECTRIC, PokemonTipo.STEEL])) return -1;
            break;

        case PokemonTipo.FAIRY:
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIGHTING, PokemonTipo.DRAGON, PokemonTipo.DARK])) return 1;
            if (pokemon_id_em_lista(_tipo_defesa, [PokemonTipo.FIRE, PokemonTipo.POISON, PokemonTipo.STEEL])) return -1;
            break;
    }

    return 0;
}

function calcular_dano_elemental(_tipo_ataque, _tipo_defesa1, _tipo_defesa2) {
    var _score = pokemon_tipo_relacao_ofensiva(_tipo_ataque, _tipo_defesa1);

    if (_tipo_defesa2 != PokemonTipo.NONE && _tipo_defesa2 != _tipo_defesa1) {
        _score += pokemon_tipo_relacao_ofensiva(_tipo_ataque, _tipo_defesa2);
    }

    if (_score >= 2) {
        return 1.35;
    }

    if (_score > 0) {
        return 1.25;
    }

    if (_score <= -2) {
        return 0.65;
    }

    if (_score < 0) {
        return 0.75;
    }

    return 1.0;
}

function pokemon_habilidade_inicial_get(_pokemon_data) {
    if (!is_struct(_pokemon_data) || !is_array(_pokemon_data.ListaHabilidadesDisponiveis)) {
        return undefined;
    }

    for (var _i = 0; _i < array_length(_pokemon_data.ListaHabilidadesDisponiveis); _i += 1) {
        var _habilidade = _pokemon_data.ListaHabilidadesDisponiveis[_i];

        if (is_struct(_habilidade) && _habilidade.NivelAprendizado <= 1) {
            return _habilidade;
        }
    }

    return array_length(_pokemon_data.ListaHabilidadesDisponiveis) > 0 ? _pokemon_data.ListaHabilidadesDisponiveis[0] : undefined;
}

function pokemon_habilidades_grass_pool() {
    return [
        new HabilidadeData("grass_absorb", "Absorver", PokemonTipo.GRASS, 1, 4.0, 18, ["single_target", "sustain", "drain"], ["curar_dano:0.10"]),
        new HabilidadeData("grass_solar_sprout", "Broto Solar", PokemonTipo.GRASS, 1, 4.8, 16, ["solar", "single_target"], ["aplicar_status_usuario:Fotossintese"]),
        new HabilidadeData("grass_foliage", "Folhagem", PokemonTipo.GRASS, 10, 3.1, 24, ["fast", "single_target"], []),
        new HabilidadeData("grass_ingrain", "Enraizar", PokemonTipo.GRASS, 10, 7.0, 8, ["control", "root", "combo_setup"], [], "aplicar_status:Enraizado", ""),
        new HabilidadeData("grass_growth", "Crescimento", PokemonTipo.GRASS, 10, 8.0, 6, ["buff", "crit", "combo_setup"], ["aplicar_status_usuario:Crescimento"]),
        new HabilidadeData("grass_mega_drain", "Dreno Vigoroso", PokemonTipo.GRASS, 15, 5.0, 28, ["sustain", "drain"], ["curar_dano:0.15", "curar_dano_status:Enraizado:0.25"], "", "Enraizado"),
        new HabilidadeData("grass_leech_seed", "Semente Parasita", PokemonTipo.GRASS, 15, 8.0, 14, ["debuff", "sustain", "root"], ["curar_dano:0.20"], "aplicar_status:Enraizado", ""),
        new HabilidadeData("grass_razor_leaf", "Folha Cortante", PokemonTipo.GRASS, 15, 4.4, 32, ["fast", "crit"], ["bonus_dano_usuario_status:Crescimento:0.10"]),
        new HabilidadeData("grass_sweet_scent", "Cheiro Doce", PokemonTipo.GRASS, 20, 8.0, 8, ["control", "setup"], [], "aplicar_status:Vulneravel", ""),
        new HabilidadeData("grass_giga_drain", "Dreno Profundo", PokemonTipo.GRASS, 20, 7.0, 38, ["sustain", "drain"], ["curar_dano:0.20", "curar_dano_status:Enraizado:0.30"], "", "Enraizado"),
        new HabilidadeData("grass_seed_bomb", "Bomba de Semente", PokemonTipo.GRASS, 20, 5.8, 42, ["burst", "single_target"], ["bonus_dano_alvo_status:Enraizado:0.12", "bonus_dano_alvo_status:Envenenado:0.10"]),
        new HabilidadeData("grass_synthesis", "Sintese", PokemonTipo.GRASS, 25, 10.0, 6, ["heal", "sustain"], ["curar_maxhp:0.08", "aplicar_status_usuario:Fotossintese"]),
        new HabilidadeData("grass_leaf_blade", "Lamina de Folha", PokemonTipo.GRASS, 25, 6.4, 50, ["crit", "finisher"], ["bonus_dano_usuario_status:Crescimento:0.16"]),
        new HabilidadeData("grass_solar_blade", "Lamina Solar", PokemonTipo.GRASS, 25, 7.2, 48, ["solar", "burst"], ["bonus_dano_usuario_status:Fotossintese:0.18"]),
        new HabilidadeData("grass_petal_dance", "Danca das Flores", PokemonTipo.GRASS, 30, 6.0, 38, ["combo", "sustain"], ["bonus_dano_usuario_status:Crescimento:0.10", "bonus_dano_alvo_status:Enraizado:0.10"]),
        new HabilidadeData("grass_petal_storm", "Tempestade Floral", PokemonTipo.GRASS, 30, 9.0, 58, ["multi_target", "finisher"], ["bonus_dano_alvo_status:Envenenado:0.12"]),
        new HabilidadeData("grass_solar_beam", "Feixe Solar", PokemonTipo.GRASS, 30, 11.0, 68, ["charged", "finisher", "solar"], ["bonus_dano_usuario_status:Fotossintese:0.22"])
    ];
}

function pokemon_habilidades_grass_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Florescencia Critica") {
        return [
            new HabilidadeData("grass_foliage", "Folhagem", PokemonTipo.GRASS, 1, 3.2, 22, ["fast", "single_target"], []),
            new HabilidadeData("grass_growth", "Crescimento", PokemonTipo.GRASS, 10, 8.0, 6, ["buff", "crit", "combo_setup"], ["aplicar_status_usuario:Crescimento"]),
            new HabilidadeData("grass_absorb", "Absorver", PokemonTipo.GRASS, 10, 4.2, 16, ["single_target", "sustain", "drain"], ["curar_dano:0.08"]),
            new HabilidadeData("grass_razor_leaf", "Folha Cortante", PokemonTipo.GRASS, 15, 4.2, 31, ["fast", "crit"], ["bonus_dano_usuario_status:Crescimento:0.10"]),
            new HabilidadeData("grass_seed_bomb", "Bomba de Semente", PokemonTipo.GRASS, 20, 5.8, 42, ["burst", "single_target"], ["bonus_dano_alvo_status:Enraizado:0.10", "bonus_dano_alvo_status:Envenenado:0.08"]),
            new HabilidadeData("grass_leaf_blade", "Lamina de Folha", PokemonTipo.GRASS, 25, 6.0, 48, ["crit", "finisher"], ["bonus_dano_usuario_status:Crescimento:0.16"]),
            new HabilidadeData("grass_petal_dance", "Danca das Flores", PokemonTipo.GRASS, 30, 6.0, 38, ["combo", "sustain"], ["bonus_dano_usuario_status:Crescimento:0.10", "bonus_dano_alvo_status:Enraizado:0.10"]),
            new HabilidadeData("grass_petal_storm", "Tempestade Floral", PokemonTipo.GRASS, 30, 8.8, 56, ["multi_target", "finisher"], ["bonus_dano_alvo_status:Envenenado:0.10"])
        ];
    }

    if (_arquetipo == "Energia Solar" || _arquetipo == "Fluxo Solar" || _arquetipo == "Rocha Solar" || _arquetipo == "Colosso Solar" || _arquetipo == "Casca de Espinhos") {
        return [
            new HabilidadeData("grass_solar_sprout", "Broto Solar", PokemonTipo.GRASS, 1, 4.8, 16, ["solar", "single_target"], ["aplicar_status_usuario:Fotossintese"]),
            new HabilidadeData("grass_absorb", "Absorver", PokemonTipo.GRASS, 10, 4.3, 17, ["single_target", "sustain", "drain"], ["curar_dano:0.10"]),
            new HabilidadeData("grass_ingrain", "Enraizar", PokemonTipo.GRASS, 10, 7.5, 8, ["control", "root", "combo_setup"], [], "aplicar_status:Enraizado", ""),
            new HabilidadeData("grass_synthesis", "Sintese", PokemonTipo.GRASS, 15, 10.0, 6, ["heal", "sustain"], ["curar_maxhp:0.08", "aplicar_status_usuario:Fotossintese"]),
            new HabilidadeData("grass_giga_drain", "Dreno Profundo", PokemonTipo.GRASS, 20, 7.2, 36, ["sustain", "drain"], ["curar_dano:0.18", "curar_dano_status:Enraizado:0.28"], "", "Enraizado"),
            new HabilidadeData("grass_solar_blade", "Lamina Solar", PokemonTipo.GRASS, 25, 7.4, 48, ["solar", "burst"], ["bonus_dano_usuario_status:Fotossintese:0.18"]),
            new HabilidadeData("grass_seed_bomb", "Bomba de Semente", PokemonTipo.GRASS, 25, 6.4, 40, ["burst", "single_target"], ["bonus_dano_alvo_status:Enraizado:0.12", "bonus_dano_alvo_status:Envenenado:0.08"]),
            new HabilidadeData("grass_solar_beam", "Feixe Solar", PokemonTipo.GRASS, 30, 11.0, 66, ["charged", "finisher", "solar"], ["bonus_dano_usuario_status:Fotossintese:0.22"])
        ];
    }

    return [
        new HabilidadeData("grass_absorb", "Absorver", PokemonTipo.GRASS, 1, 4.0, 18, ["single_target", "sustain", "drain"], ["curar_dano:0.10"]),
        new HabilidadeData("grass_ingrain", "Enraizar", PokemonTipo.GRASS, 10, 7.0, 8, ["control", "root", "combo_setup"], [], "aplicar_status:Enraizado", ""),
        new HabilidadeData("grass_foliage", "Folhagem", PokemonTipo.GRASS, 10, 3.4, 22, ["fast", "single_target"], []),
        new HabilidadeData("grass_leech_seed", "Semente Parasita", PokemonTipo.GRASS, 15, 8.0, 14, ["debuff", "sustain", "root"], ["curar_dano:0.20"], "aplicar_status:Enraizado", ""),
        new HabilidadeData("grass_mega_drain", "Dreno Vigoroso", PokemonTipo.GRASS, 15, 5.0, 28, ["sustain", "drain"], ["curar_dano:0.15", "curar_dano_status:Enraizado:0.25"], "", "Enraizado"),
        new HabilidadeData("grass_seed_bomb", "Bomba de Semente", PokemonTipo.GRASS, 20, 5.8, 42, ["burst", "single_target"], ["bonus_dano_alvo_status:Enraizado:0.12", "bonus_dano_alvo_status:Envenenado:0.10"]),
        new HabilidadeData("grass_giga_drain", "Dreno Profundo", PokemonTipo.GRASS, 20, 7.0, 38, ["sustain", "drain"], ["curar_dano:0.20", "curar_dano_status:Enraizado:0.30"], "", "Enraizado"),
        new HabilidadeData("grass_petal_storm", "Tempestade Floral", PokemonTipo.GRASS, 30, 9.0, 58, ["multi_target", "finisher"], ["bonus_dano_alvo_status:Envenenado:0.12"])
    ];
}

function pokemon_habilidades_poison_pool() {
    return pokemon_habilidades_poison_por_arquetipo("Peste Gradual");
}

function pokemon_habilidades_fire_pool() {
    return pokemon_habilidades_fire_por_arquetipo("Incandescencia");
}

function pokemon_habilidades_fire_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Explosao Termica") {
        return [
            new HabilidadeData("fire_heat_burst", "Estouro de Calor", PokemonTipo.FIRE, 1, 5.4, 32, ["single_target", "burst", "burn"], ["bonus_dano_alvo_status:ArmaduraDerretida:0.10"], "aplicar_status:Queimando", ""),
            new HabilidadeData("fire_ember", "Brasa", PokemonTipo.FIRE, 10, 4.2, 21, ["single_target", "burn"], [], "aplicar_status:Queimando", ""),
            new HabilidadeData("fire_thermal_charge", "Carga Termica", PokemonTipo.FIRE, 10, 7.2, 10, ["buff", "burst"], ["aplicar_status_usuario:CalorConcentrado"]),
            new HabilidadeData("fire_overheat", "Sobreaquecer", PokemonTipo.FIRE, 15, 8.4, 52, ["burst", "melt"], ["bonus_dano_usuario_status:CalorConcentrado:0.18"], "aplicar_status:ArmaduraDerretida", ""),
            new HabilidadeData("fire_flamethrower", "Jorro de Chamas", PokemonTipo.FIRE, 20, 6.8, 42, ["single_target", "burn"], ["bonus_dano_alvo_status:Queimando:0.16"], "", "Queimando"),
            new HabilidadeData("fire_thermal_explosion", "Explosao Termica", PokemonTipo.FIRE, 25, 10.0, 70, ["finisher", "burst"], ["bonus_dano_alvo_status:ArmaduraDerretida:0.18", "bonus_dano_alvo_status:Corroendo:0.10"]),
            new HabilidadeData("fire_inferno_core", "Nucleo Infernal", PokemonTipo.FIRE, 30, 10.8, 76, ["ultimate", "burst"], ["bonus_dano_usuario_status:CalorConcentrado:0.16", "bonus_dano_alvo_status:Queimando:0.16"])
        ];
    }

    if (_arquetipo == "Fenix Veloz") {
        return [
            new HabilidadeData("fire_quick_flame", "Chama Veloz", PokemonTipo.FIRE, 1, 3.2, 18, ["fast", "single_target", "burn"], ["bonus_dano_usuario_status:FenixAtiva:0.08"]),
            new HabilidadeData("fire_ember", "Brasa", PokemonTipo.FIRE, 10, 4.2, 21, ["single_target", "burn"], [], "aplicar_status:Queimando", ""),
            new HabilidadeData("fire_phoenix_stance", "Fenix", PokemonTipo.FIRE, 10, 7.4, 8, ["buff", "fast"], ["aplicar_status_usuario:FenixAtiva"]),
            new HabilidadeData("fire_flame_dash", "Avanco Flamejante", PokemonTipo.FIRE, 15, 3.8, 30, ["fast", "dash"], ["bonus_dano_usuario_status:FenixAtiva:0.14"]),
            new HabilidadeData("fire_wing_blaze", "Asa Ardente", PokemonTipo.FIRE, 20, 5.6, 40, ["fast", "burn"], ["bonus_dano_alvo_status:Queimando:0.12"], "", "Queimando"),
            new HabilidadeData("fire_blaze_rush", "Investida Ardente", PokemonTipo.FIRE, 25, 5.2, 46, ["burst", "fast"], ["bonus_dano_usuario_status:FenixAtiva:0.12", "bonus_dano_alvo_status:CalorEscaldante:0.10"]),
            new HabilidadeData("fire_phoenix_burst", "Surto Fenix", PokemonTipo.FIRE, 30, 7.2, 58, ["ultimate", "fast"], ["bonus_dano_usuario_status:FenixAtiva:0.22", "bonus_dano_alvo_status:Queimando:0.12"])
        ];
    }

    return [
        new HabilidadeData("fire_ember", "Brasa", PokemonTipo.FIRE, 1, 4.1, 20, ["single_target", "burn"], [], "aplicar_status:Queimando", ""),
        new HabilidadeData("fire_armor_melt", "Marca Incandescente", PokemonTipo.FIRE, 10, 6.5, 14, ["debuff", "melt"], ["bonus_dano_alvo_status:Envenenado:0.08"], "aplicar_status:ArmaduraDerretida", ""),
        new HabilidadeData("fire_flame_wheel", "Roda de Fogo", PokemonTipo.FIRE, 10, 4.6, 30, ["single_target", "burn"], ["bonus_dano_alvo_status:ArmaduraDerretida:0.10"]),
        new HabilidadeData("fire_flamethrower", "Jorro de Chamas", PokemonTipo.FIRE, 15, 6.8, 42, ["single_target", "burn"], ["bonus_dano_alvo_status:Queimando:0.16"], "", "Queimando"),
        new HabilidadeData("fire_scorching_heat", "Calor Escaldante", PokemonTipo.FIRE, 20, 8.4, 24, ["control", "burn"], [], "aplicar_status:CalorEscaldante", ""),
        new HabilidadeData("fire_molten_blast", "Rajada Derretida", PokemonTipo.FIRE, 25, 7.4, 50, ["burst", "melt"], ["bonus_dano_alvo_status:ArmaduraDerretida:0.14", "bonus_dano_alvo_status:Corroendo:0.12"]),
        new HabilidadeData("fire_inferno_core", "Nucleo Infernal", PokemonTipo.FIRE, 30, 10.8, 72, ["ultimate", "burn"], ["bonus_dano_alvo_status:Queimando:0.16", "bonus_dano_alvo_status:Corroendo:0.12"])
    ];
}

function pokemon_habilidades_water_pool() {
    return pokemon_habilidades_water_por_arquetipo("Fluxo Acelerado");
}

function pokemon_habilidades_water_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Mare Protelatoria") {
        return [
            new HabilidadeData("water_bubble", "Bolha", PokemonTipo.WATER, 1, 4.5, 16, ["single_target", "tempo"], ["aumentar_cooldowns_alvo:0.20"], "aplicar_status:Molhado", ""),
            new HabilidadeData("water_stagnant_mist", "Nevoa Estagnante", PokemonTipo.WATER, 10, 7.4, 8, ["control", "tempo"], ["aumentar_cooldowns_alvo:0.45"], "aplicar_status:NevoaEstagnante", ""),
            new HabilidadeData("water_whirlpool", "Redemoinho", PokemonTipo.WATER, 10, 6.8, 26, ["control", "combo_setup"], ["bonus_dano_alvo_status:Molhado:0.10"], "aplicar_status:Enraizado", ""),
            new HabilidadeData("water_slow_tide", "Mare Lenta", PokemonTipo.WATER, 15, 6.4, 34, ["tempo", "single_target"], ["aumentar_cooldowns_alvo:0.35", "bonus_dano_alvo_status:Molhado:0.12"]),
            new HabilidadeData("water_sea_wall", "Muralha de Mare", PokemonTipo.WATER, 20, 8.8, 24, ["defense", "tempo"], ["curar_maxhp:0.05", "aumentar_cooldowns_alvo:0.25"]),
            new HabilidadeData("water_mar_revolto", "Mar Revolto", PokemonTipo.WATER, 25, 8.4, 48, ["burst", "tempo"], ["bonus_dano_alvo_status:Molhado:0.16", "bonus_dano_alvo_cd:0.12"]),
            new HabilidadeData("water_tidal_lock", "Tranca de Mare", PokemonTipo.WATER, 30, 10.2, 60, ["ultimate", "control"], ["aumentar_cooldowns_alvo:0.65", "bonus_dano_alvo_status:NevoaEstagnante:0.15"])
        ];
    }

    if (_arquetipo == "Pressao Hidraulica") {
        return [
            new HabilidadeData("water_pulse", "Pulso d'Agua", PokemonTipo.WATER, 1, 4.8, 26, ["single_target", "tempo"], ["bonus_dano_alvo_cd:0.08"], "aplicar_status:Molhado", ""),
            new HabilidadeData("water_gun", "Jato d'Agua", PokemonTipo.WATER, 10, 4.0, 20, ["single_target", "tempo"], [], "aplicar_status:Molhado", ""),
            new HabilidadeData("water_pressure_cut", "Corte de Pressao", PokemonTipo.WATER, 10, 5.4, 34, ["burst", "tempo"], ["bonus_dano_alvo_cd:0.12"]),
            new HabilidadeData("water_hydraulic_press", "Pressao Hidraulica", PokemonTipo.WATER, 15, 6.2, 44, ["burst", "tempo"], ["bonus_dano_alvo_cd:0.18", "bonus_dano_alvo_status:Molhado:0.10"]),
            new HabilidadeData("water_surf_bash", "Onda Montante", PokemonTipo.WATER, 20, 7.0, 50, ["burst", "single_target"], ["bonus_dano_alvo_status:Molhado:0.16"], "", "Molhado"),
            new HabilidadeData("water_crushing_wave", "Onda Esmagadora", PokemonTipo.WATER, 25, 8.2, 58, ["finisher", "tempo"], ["bonus_dano_alvo_cd:0.18"]),
            new HabilidadeData("water_hydro_pump", "Canhao d'Agua", PokemonTipo.WATER, 30, 10.5, 72, ["ultimate", "burst"], ["bonus_dano_alvo_cd:0.20", "bonus_dano_alvo_status:Molhado:0.12"])
        ];
    }

    return [
        new HabilidadeData("water_gun", "Jato d'Agua", PokemonTipo.WATER, 1, 4.0, 20, ["single_target", "tempo"], [], "aplicar_status:Molhado", ""),
        new HabilidadeData("water_current", "Corrente Rapida", PokemonTipo.WATER, 10, 3.3, 22, ["fast", "tempo"], ["reduzir_cooldowns_usuario:0.35"]),
        new HabilidadeData("water_aqua_jet", "Jato Veloz", PokemonTipo.WATER, 10, 3.0, 28, ["fast", "dash"], ["aplicar_status_usuario:FluxoAcelerado"]),
        new HabilidadeData("water_flow_cutter", "Corte Correnteza", PokemonTipo.WATER, 15, 4.2, 38, ["fast", "tempo"], ["bonus_dano_alvo_status:Molhado:0.12"]),
        new HabilidadeData("water_renew_flow", "Renovar Fluxo", PokemonTipo.WATER, 20, 7.0, 14, ["buff", "tempo"], ["reduzir_cooldowns_usuario:0.65", "aplicar_status_usuario:FluxoAcelerado"]),
        new HabilidadeData("water_rapid_surge", "Surto Rapido", PokemonTipo.WATER, 25, 4.8, 46, ["burst", "fast"], ["bonus_dano_usuario_status:FluxoAcelerado:0.14", "bonus_dano_alvo_status:Molhado:0.10"]),
        new HabilidadeData("water_torrent_loop", "Ciclo Torrencial", PokemonTipo.WATER, 30, 7.8, 58, ["ultimate", "tempo"], ["reduzir_cooldowns_usuario:0.80", "bonus_dano_usuario_status:FluxoAcelerado:0.16"])
    ];
}

function pokemon_habilidades_electric_pool() {
    return pokemon_habilidades_electric_por_arquetipo("Sobrecarga");
}

function pokemon_habilidades_electric_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Curto-Circuito") {
        return [
            new HabilidadeData("electric_thundershock_blind", "Choque Ofuscante", PokemonTipo.ELECTRIC, 1, 3.8, 18, ["single_target", "blind", "shock"], [], "aplicar_status:Ofuscado", ""),
            new HabilidadeData("electric_flash", "Flash Eletrico", PokemonTipo.ELECTRIC, 10, 6.4, 10, ["control", "blind"], ["aumentar_cooldowns_alvo:0.18"], "aplicar_status:Ofuscado", ""),
            new HabilidadeData("electric_short_circuit", "Curto-Circuito", PokemonTipo.ELECTRIC, 10, 5.6, 28, ["control", "shock"], ["bonus_dano_alvo_status:Molhado:0.14"], "aplicar_status:Paralisado", "Molhado"),
            new HabilidadeData("electric_static_field", "Campo Estatico", PokemonTipo.ELECTRIC, 15, 7.2, 16, ["control", "blind"], ["aplicar_status_usuario:EstaticaAtiva", "aumentar_cooldowns_alvo:0.20"]),
            new HabilidadeData("electric_blinding_ray", "Raio Cegante", PokemonTipo.ELECTRIC, 20, 6.2, 36, ["single_target", "blind"], ["bonus_dano_alvo_status:Ofuscado:0.18"], "", "Ofuscado"),
            new HabilidadeData("electric_interference_pulse", "Pulso de Interferencia", PokemonTipo.ELECTRIC, 25, 8.2, 34, ["control", "tempo"], ["aumentar_cooldowns_alvo:0.45", "bonus_dano_alvo_status:ErroEletrico:0.12"], "aplicar_status:Ofuscado", ""),
            new HabilidadeData("electric_blackout", "Apagao", PokemonTipo.ELECTRIC, 30, 10.2, 62, ["ultimate", "blind"], ["bonus_dano_alvo_status:Ofuscado:0.18", "bonus_dano_alvo_status:Paralisado:0.14", "bonus_dano_alvo_status:ErroEletrico:0.12"])
        ];
    }

    if (_arquetipo == "Estatica Veloz") {
        return [
            new HabilidadeData("electric_spark_fast", "Faisca", PokemonTipo.ELECTRIC, 1, 3.2, 20, ["fast", "shock"], [], "aplicar_status:Paralisado", ""),
            new HabilidadeData("electric_static_charge", "Carga Estatica", PokemonTipo.ELECTRIC, 10, 6.8, 8, ["buff", "fast"], ["aplicar_status_usuario:EstaticaAtiva", "reduzir_cooldowns_usuario:0.25"]),
            new HabilidadeData("electric_volt_switch", "Recuo Eletrico", PokemonTipo.ELECTRIC, 10, 3.9, 30, ["fast", "dash"], ["bonus_dano_usuario_status:EstaticaAtiva:0.12"]),
            new HabilidadeData("electric_needle", "Agulha Eletrica", PokemonTipo.ELECTRIC, 15, 3.6, 32, ["fast", "shock"], ["bonus_dano_alvo_status:Molhado:0.10"]),
            new HabilidadeData("electric_overdrive", "Sobrerrotacao", PokemonTipo.ELECTRIC, 20, 7.2, 18, ["buff", "fast"], ["reduzir_cooldowns_usuario:0.60", "aplicar_status_usuario:EstaticaAtiva"]),
            new HabilidadeData("electric_lightning_dash", "Avanco Relampago", PokemonTipo.ELECTRIC, 25, 5.0, 48, ["burst", "fast"], ["bonus_dano_usuario_status:EstaticaAtiva:0.14", "bonus_dano_alvo_status:Paralisado:0.10"]),
            new HabilidadeData("electric_voltage_loop", "Circuito Veloz", PokemonTipo.ELECTRIC, 30, 7.4, 58, ["ultimate", "fast"], ["reduzir_cooldowns_usuario:0.70", "bonus_dano_usuario_status:EstaticaAtiva:0.18"])
        ];
    }

    return [
        new HabilidadeData("electric_charge_spark", "Faisca Condutora", PokemonTipo.ELECTRIC, 1, 4.4, 24, ["single_target", "shock"], [], "aplicar_status:Sobrecarregado", ""),
        new HabilidadeData("electric_conductor", "Condutor Eletrico", PokemonTipo.ELECTRIC, 10, 5.2, 20, ["shock", "combo_setup"], ["bonus_dano_alvo_status:Molhado:0.16"], "aplicar_status:Paralisado", "Molhado"),
        new HabilidadeData("electric_discharge", "Descarga", PokemonTipo.ELECTRIC, 10, 5.9, 36, ["single_target", "shock"], ["bonus_dano_alvo_status:Sobrecarregado:0.12", "bonus_dano_alvo_status:Molhado:0.10"]),
        new HabilidadeData("electric_overload", "Sobrecarga", PokemonTipo.ELECTRIC, 15, 7.0, 48, ["burst", "shock"], ["bonus_dano_alvo_status:Sobrecarregado:0.18", "bonus_dano_alvo_status:Ofuscado:0.10"]),
        new HabilidadeData("electric_chain", "Raio em Cadeia", PokemonTipo.ELECTRIC, 20, 6.8, 44, ["burst", "shock"], ["bonus_dano_alvo_status:Enraizado:0.10", "bonus_dano_alvo_status:Molhado:0.12"]),
        new HabilidadeData("electric_thunder", "Trovao", PokemonTipo.ELECTRIC, 25, 9.2, 64, ["finisher", "shock"], ["bonus_dano_alvo_status:Molhado:0.16", "bonus_dano_alvo_status:Paralisado:0.12"], "", "Molhado"),
        new HabilidadeData("electric_voltage_collapse", "Colapso Eletrico", PokemonTipo.ELECTRIC, 30, 10.6, 74, ["ultimate", "shock"], ["bonus_dano_alvo_status:Sobrecarregado:0.20", "bonus_dano_alvo_status:Molhado:0.12", "bonus_dano_alvo_status:ErroEletrico:0.12"])
    ];
}

function pokemon_habilidades_ice_pool() {
    return pokemon_habilidades_ice_por_arquetipo("Geada Acumulativa");
}

function pokemon_habilidades_ice_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Estilhacar") {
        return [
            new HabilidadeData("ice_shard", "Lasca de Gelo", PokemonTipo.ICE, 1, 3.8, 24, ["fast", "shatter"], ["bonus_dano_alvo_status:Gelado:0.08"], "aplicar_status:Gelado", ""),
            new HabilidadeData("ice_thin_ice", "Gelo Fino", PokemonTipo.ICE, 10, 6.8, 14, ["debuff", "shatter"], [], "aplicar_status:Fragil", ""),
            new HabilidadeData("ice_shatter", "Estilhacar", PokemonTipo.ICE, 10, 5.5, 38, ["burst", "shatter"], ["bonus_dano_alvo_status:Fragil:0.16", "bonus_dano_alvo_status:Gelado:0.10"]),
            new HabilidadeData("ice_spear", "Estacas de Gelo", PokemonTipo.ICE, 15, 4.8, 36, ["fast", "shatter"], ["bonus_dano_alvo_status:Fragil:0.10"]),
            new HabilidadeData("ice_frostbite", "Mordida Gelida", PokemonTipo.ICE, 20, 6.2, 46, ["single_target", "frost"], ["bonus_dano_alvo_status:Gelado:0.14", "bonus_dano_alvo_status:Enraizado:0.08"]),
            new HabilidadeData("ice_crystal_break", "Quebra-Cristal", PokemonTipo.ICE, 25, 7.4, 56, ["finisher", "shatter"], ["bonus_dano_alvo_status:Fragil:0.18", "bonus_dano_alvo_status:Congelando:0.12"]),
            new HabilidadeData("ice_absolute_zero", "Zero Absoluto", PokemonTipo.ICE, 30, 10.8, 68, ["ultimate", "shatter"], ["bonus_dano_alvo_status:Fragil:0.16", "bonus_dano_alvo_hp_baixo:0.30:0.20"])
        ];
    }

    if (_arquetipo == "Manto de Gelo") {
        return [
            new HabilidadeData("ice_firm_snow", "Neve Firme", PokemonTipo.ICE, 1, 4.8, 18, ["single_target", "frost"], [], "aplicar_status:Gelado", ""),
            new HabilidadeData("ice_ice_mantle", "Manto de Gelo", PokemonTipo.ICE, 10, 8.0, 8, ["defense", "frost"], ["aplicar_status_usuario:MantoGelo", "curar_maxhp:0.04"]),
            new HabilidadeData("ice_crystal_guard", "Guarda Cristalina", PokemonTipo.ICE, 10, 7.0, 18, ["defense", "control"], ["aumentar_cooldowns_alvo:0.18"], "aplicar_status:Gelado", ""),
            new HabilidadeData("ice_mirror_ice", "Espelho Gelido", PokemonTipo.ICE, 15, 6.4, 34, ["defense", "shatter"], ["bonus_dano_usuario_status:MantoGelo:0.12"]),
            new HabilidadeData("ice_hail_shell", "Casca de Granizo", PokemonTipo.ICE, 20, 8.8, 26, ["defense", "frost"], ["curar_maxhp:0.06"], "aplicar_status:Granizo", ""),
            new HabilidadeData("ice_avalanche", "Avalanche", PokemonTipo.ICE, 25, 8.0, 58, ["finisher", "defense"], ["bonus_dano_usuario_status:MantoGelo:0.14", "bonus_dano_alvo_status:Gelado:0.12"]),
            new HabilidadeData("ice_glacier_wall", "Muralha Glacial", PokemonTipo.ICE, 30, 10.4, 60, ["ultimate", "defense"], ["aplicar_status_usuario:MantoGelo", "bonus_dano_alvo_status:Fragil:0.14"])
        ];
    }

    return [
        new HabilidadeData("ice_icy_wind", "Vento Gelado", PokemonTipo.ICE, 1, 4.2, 18, ["single_target", "frost"], [], "aplicar_status:Gelado", ""),
        new HabilidadeData("ice_frost_layer", "Camada de Geada", PokemonTipo.ICE, 10, 6.2, 12, ["control", "frost"], ["aumentar_cooldowns_alvo:0.20"], "aplicar_status:Gelado", ""),
        new HabilidadeData("ice_cutting_snow", "Neve Cortante", PokemonTipo.ICE, 10, 4.8, 28, ["single_target", "frost"], ["bonus_dano_alvo_status:Gelado:0.12"]),
        new HabilidadeData("ice_freezing_prison", "Prisao Gelida", PokemonTipo.ICE, 15, 6.8, 32, ["control", "frost"], ["bonus_dano_alvo_status:Gelado:0.10"], "aplicar_status:Congelando", ""),
        new HabilidadeData("ice_slow_crystals", "Cristais Lentos", PokemonTipo.ICE, 20, 7.4, 38, ["control", "frost"], ["aumentar_cooldowns_alvo:0.35", "bonus_dano_alvo_status:Congelando:0.10"]),
        new HabilidadeData("ice_hail", "Granizo", PokemonTipo.ICE, 25, 8.8, 30, ["frost", "control"], ["bonus_dano_alvo_status:Gelado:0.12"], "aplicar_status:Granizo", ""),
        new HabilidadeData("ice_permafrost", "Permafrost", PokemonTipo.ICE, 30, 10.0, 62, ["ultimate", "frost"], ["bonus_dano_alvo_status:Congelando:0.18", "bonus_dano_alvo_status:Gelado:0.12"])
    ];
}

function pokemon_habilidades_fighting_pool() {
    return pokemon_habilidades_fighting_por_arquetipo("Impeto Ofensivo");
}

function pokemon_habilidades_fighting_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Quebra-Guarda") {
        return [
            new HabilidadeData("fighting_karate_chop", "Golpe de Mao Aberta", PokemonTipo.FIGHTING, 1, 4.1, 24, ["single_target", "guardbreak"], [], "aplicar_status:PosturaQuebrada", ""),
            new HabilidadeData("fighting_brick_break", "Quebra-Pedra", PokemonTipo.FIGHTING, 10, 5.6, 36, ["single_target", "guardbreak"], ["bonus_dano_alvo_status:PosturaQuebrada:0.14"]),
            new HabilidadeData("fighting_bulk_up", "Firmar Guarda", PokemonTipo.FIGHTING, 10, 7.4, 8, ["buff", "defense"], ["aplicar_status_usuario:ImpetoOfensivo", "curar_maxhp:0.03"]),
            new HabilidadeData("fighting_vital_throw", "Arremesso Vital", PokemonTipo.FIGHTING, 15, 6.4, 40, ["burst", "guardbreak"], ["bonus_dano_alvo_status:PosturaQuebrada:0.12", "bonus_dano_alvo_status:Corroendo:0.08"]),
            new HabilidadeData("fighting_cross_chop", "Corte Cruzado", PokemonTipo.FIGHTING, 20, 7.0, 52, ["burst", "guardbreak"], ["bonus_dano_alvo_status:Vulneravel:0.10"], "aplicar_status:PosturaQuebrada", ""),
            new HabilidadeData("fighting_close_combat", "Corpo a Corpo", PokemonTipo.FIGHTING, 25, 8.2, 62, ["finisher", "guardbreak"], ["sacrificar_hp_pct:0.03", "bonus_dano_alvo_status:PosturaQuebrada:0.18"]),
            new HabilidadeData("fighting_stance_breaker", "Ruptura de Postura", PokemonTipo.FIGHTING, 30, 10.0, 72, ["ultimate", "guardbreak"], ["bonus_dano_alvo_status:PosturaQuebrada:0.20", "bonus_dano_alvo_status:ArmaduraDerretida:0.10"])
        ];
    }

    if (_arquetipo == "Espirito de Luta") {
        return [
            new HabilidadeData("fighting_drain_punch", "Soco Drenante", PokemonTipo.FIGHTING, 1, 4.8, 22, ["single_target", "sustain"], ["curar_dano:0.10"]),
            new HabilidadeData("fighting_fighting_spirit", "Espirito de Luta", PokemonTipo.FIGHTING, 10, 7.2, 8, ["buff", "sustain"], ["aplicar_status_usuario:EspiritoLuta", "curar_maxhp:0.04"]),
            new HabilidadeData("fighting_counter", "Contra-Golpe", PokemonTipo.FIGHTING, 10, 5.4, 32, ["single_target", "combo"], ["bonus_dano_usuario_status:EspiritoLuta:0.12"]),
            new HabilidadeData("fighting_vital_throw_spirit", "Golpe Vital", PokemonTipo.FIGHTING, 15, 6.2, 38, ["burst", "sustain"], ["bonus_dano_usuario_hp_baixo:0.45:0.18", "curar_dano:0.08"]),
            new HabilidadeData("fighting_aura_palm", "Palma de Aura", PokemonTipo.FIGHTING, 20, 6.8, 44, ["single_target", "combo"], ["bonus_dano_usuario_status:EspiritoLuta:0.14", "bonus_dano_alvo_status:Enraizado:0.08"]),
            new HabilidadeData("fighting_resolve", "Resolucao", PokemonTipo.FIGHTING, 25, 8.0, 42, ["sustain", "buff"], ["aplicar_status_usuario:EspiritoLuta", "bonus_dano_usuario_hp_baixo:0.50:0.16", "curar_maxhp:0.05"]),
            new HabilidadeData("fighting_last_stand", "Ultimo Folego", PokemonTipo.FIGHTING, 30, 10.0, 66, ["ultimate", "sustain"], ["bonus_dano_usuario_hp_baixo:0.45:0.24", "bonus_dano_usuario_status:EspiritoLuta:0.14", "curar_dano:0.12"])
        ];
    }

    return [
        new HabilidadeData("fighting_jab", "Estocada", PokemonTipo.FIGHTING, 1, 3.3, 20, ["fast", "single_target", "combo"], ["aplicar_status_usuario:ImpetoOfensivo"]),
        new HabilidadeData("fighting_focus_stance", "Postura de Foco", PokemonTipo.FIGHTING, 10, 6.6, 8, ["buff", "combo"], ["aplicar_status_usuario:ImpetoOfensivo", "reduzir_cooldowns_usuario:0.20"]),
        new HabilidadeData("fighting_low_kick", "Rasteira", PokemonTipo.FIGHTING, 10, 4.6, 30, ["single_target", "guardbreak"], ["bonus_dano_alvo_status:Enraizado:0.10", "bonus_dano_alvo_status:AreiaMovedica:0.10"], "aplicar_status:PosturaQuebrada", ""),
        new HabilidadeData("fighting_combo_rush", "Sequencia Crescente", PokemonTipo.FIGHTING, 15, 4.2, 34, ["fast", "combo"], ["bonus_dano_usuario_status:ImpetoOfensivo:0.16"]),
        new HabilidadeData("fighting_guard_break", "Quebra-Guarda", PokemonTipo.FIGHTING, 20, 6.6, 42, ["guardbreak", "combo_setup"], ["bonus_dano_alvo_status:Vulneravel:0.08"], "aplicar_status:PosturaQuebrada", ""),
        new HabilidadeData("fighting_rising_blow", "Golpe Ascendente", PokemonTipo.FIGHTING, 25, 5.8, 50, ["burst", "combo"], ["bonus_dano_alvo_status:PosturaQuebrada:0.16", "bonus_dano_usuario_status:ImpetoOfensivo:0.10"]),
        new HabilidadeData("fighting_final_flurry", "Rajada Final", PokemonTipo.FIGHTING, 30, 8.6, 62, ["ultimate", "combo"], ["bonus_dano_usuario_status:ImpetoOfensivo:0.16", "bonus_dano_alvo_status:PosturaQuebrada:0.16"])
    ];
}

function pokemon_habilidades_ground_pool() {
    return pokemon_habilidades_ground_por_arquetipo("Areia Movedica");
}

function pokemon_habilidades_ground_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Barreira de Lama") {
        return [
            new HabilidadeData("ground_mud_guard", "Guarda de Lama", PokemonTipo.GROUND, 1, 5.0, 16, ["single_target", "defense", "earth"], ["aplicar_status_usuario:BarreiraLama"]),
            new HabilidadeData("ground_mud_wall", "Muralha de Lama", PokemonTipo.GROUND, 10, 7.4, 10, ["defense", "earth"], ["aplicar_status_usuario:BarreiraLama", "curar_maxhp:0.04"]),
            new HabilidadeData("ground_bulldoze", "Pisotear", PokemonTipo.GROUND, 10, 5.8, 34, ["single_target", "earth"], ["bonus_dano_usuario_status:BarreiraLama:0.10"], "aplicar_status:AreiaMovedica", ""),
            new HabilidadeData("ground_mud_armor", "Armadura de Barro", PokemonTipo.GROUND, 15, 8.2, 16, ["defense", "sustain"], ["aplicar_status_usuario:BarreiraLama", "curar_maxhp:0.05"]),
            new HabilidadeData("ground_stomping_tantrum", "Pisao Teimoso", PokemonTipo.GROUND, 20, 6.6, 44, ["burst", "earth"], ["bonus_dano_usuario_status:BarreiraLama:0.14", "bonus_dano_alvo_status:PosturaQuebrada:0.08"]),
            new HabilidadeData("ground_earth_bulwark", "Baluarte Terrestre", PokemonTipo.GROUND, 25, 9.0, 36, ["defense", "earth"], ["aplicar_status_usuario:Aterrado", "bonus_dano_alvo_status:AreiaMovedica:0.12"]),
            new HabilidadeData("ground_living_earth", "Terra Viva", PokemonTipo.GROUND, 30, 10.6, 60, ["ultimate", "defense"], ["bonus_dano_usuario_status:BarreiraLama:0.18", "bonus_dano_usuario_status:Aterrado:0.12", "curar_maxhp:0.04"])
        ];
    }

    if (_arquetipo == "Desabamento") {
        return [
            new HabilidadeData("ground_rock_drop", "Queda de Rocha", PokemonTipo.GROUND, 1, 5.2, 28, ["single_target", "earth"], [], "aplicar_status:Desabando", ""),
            new HabilidadeData("ground_heavy_stomp", "Pisada Pesada", PokemonTipo.GROUND, 10, 6.2, 38, ["burst", "earth"], ["bonus_dano_alvo_status:Desabando:0.12"]),
            new HabilidadeData("ground_seismic_crack", "Fenda Sismica", PokemonTipo.GROUND, 10, 7.8, 30, ["control", "earth"], ["aumentar_cooldowns_alvo:0.28"], "aplicar_status:Desabando", ""),
            new HabilidadeData("ground_magnitude", "Magnitude", PokemonTipo.GROUND, 15, 7.2, 48, ["burst", "earth"], ["bonus_dano_usuario_status:Aterrado:0.10", "bonus_dano_alvo_status:Desabando:0.12"]),
            new HabilidadeData("ground_crushing_slam", "Impacto Esmagador", PokemonTipo.GROUND, 20, 8.0, 58, ["finisher", "earth"], ["bonus_dano_alvo_status:PosturaQuebrada:0.12", "bonus_dano_alvo_status:Desabando:0.14"]),
            new HabilidadeData("ground_tectonic_drop", "Queda Tectonica", PokemonTipo.GROUND, 25, 9.2, 66, ["finisher", "earth"], ["aumentar_cooldowns_alvo:0.35", "bonus_dano_alvo_status:AreiaMovedica:0.12"]),
            new HabilidadeData("ground_earthquake", "Terremoto", PokemonTipo.GROUND, 30, 11.2, 78, ["ultimate", "earth"], ["bonus_dano_alvo_status:Desabando:0.20", "bonus_dano_alvo_status:Enraizado:0.10"])
        ];
    }

    return [
        new HabilidadeData("ground_mud_slap", "Tapa de Lama", PokemonTipo.GROUND, 1, 4.2, 18, ["single_target", "control", "earth"], ["aumentar_cooldowns_alvo:0.15"], "aplicar_status:AreiaMovedica", ""),
        new HabilidadeData("ground_sand_trap", "Armadilha de Areia", PokemonTipo.GROUND, 10, 6.8, 12, ["control", "earth", "combo_setup"], ["aumentar_cooldowns_alvo:0.25"], "aplicar_status:AreiaMovedica", ""),
        new HabilidadeData("ground_mud_shot", "Tiro de Lama", PokemonTipo.GROUND, 10, 5.2, 32, ["single_target", "earth"], ["bonus_dano_alvo_status:Molhado:0.10", "aumentar_cooldowns_alvo:0.18"]),
        new HabilidadeData("ground_quicksand", "Areia Movedica", PokemonTipo.GROUND, 15, 7.4, 24, ["control", "earth"], ["bonus_dano_alvo_status:Enraizado:0.10", "aumentar_cooldowns_alvo:0.35"], "aplicar_status:AreiaMovedica", ""),
        new HabilidadeData("ground_earth_power", "Poder da Terra", PokemonTipo.GROUND, 20, 6.8, 48, ["burst", "earth"], ["bonus_dano_alvo_status:AreiaMovedica:0.14", "bonus_dano_alvo_status:Molhado:0.10"]),
        new HabilidadeData("ground_sand_collapse", "Colapso de Areia", PokemonTipo.GROUND, 25, 8.6, 54, ["finisher", "earth"], ["bonus_dano_alvo_status:AreiaMovedica:0.18", "bonus_dano_alvo_status:Enraizado:0.10"], "aplicar_status:Desabando", ""),
        new HabilidadeData("ground_land_lock", "Trava de Campo", PokemonTipo.GROUND, 30, 10.2, 64, ["ultimate", "control"], ["aumentar_cooldowns_alvo:0.55", "bonus_dano_alvo_status:AreiaMovedica:0.18", "bonus_dano_alvo_status:Congelando:0.08"])
    ];
}

function pokemon_habilidades_flying_pool() {
    return pokemon_habilidades_flying_por_arquetipo("Ataque Rasante");
}

function pokemon_habilidades_flying_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Turbulencia") {
        return [
            new HabilidadeData("flying_wing_attack", "Ataque de Asa", PokemonTipo.FLYING, 1, 4.0, 20, ["single_target", "wind", "control"], [], "aplicar_status:Turbulento", ""),
            new HabilidadeData("flying_turbulence", "Turbulencia", PokemonTipo.FLYING, 10, 6.6, 10, ["control", "wind", "interrupt"], ["aumentar_cooldowns_alvo:0.22"], "aplicar_status:Turbulento", ""),
            new HabilidadeData("flying_air_cutter", "Corte de Ar", PokemonTipo.FLYING, 10, 5.0, 32, ["single_target", "wind"], ["bonus_dano_alvo_status:Turbulento:0.12"]),
            new HabilidadeData("flying_feather_dance", "Danca de Penas", PokemonTipo.FLYING, 15, 7.0, 8, ["control", "evade", "wind"], ["aplicar_status_usuario:PenasLeves"], "aplicar_status:Turbulento", ""),
            new HabilidadeData("flying_cyclone", "Ciclone", PokemonTipo.FLYING, 20, 7.2, 42, ["burst", "wind", "control"], ["bonus_dano_alvo_status:AreiaMovedica:0.08", "bonus_dano_alvo_status:Turbulento:0.12"], "aplicar_status:Turbulento", ""),
            new HabilidadeData("flying_hurricane", "Furacao", PokemonTipo.FLYING, 25, 9.0, 56, ["finisher", "wind"], ["bonus_dano_alvo_status:Molhado:0.10", "bonus_dano_alvo_status:Turbulento:0.16"]),
            new HabilidadeData("flying_storm_lock", "Trava de Ventos", PokemonTipo.FLYING, 30, 10.0, 62, ["ultimate", "interrupt", "wind"], ["aumentar_cooldowns_alvo:0.45", "bonus_dano_alvo_status:Turbulento:0.18", "bonus_dano_alvo_status:Ofuscado:0.08"])
        ];
    }

    if (_arquetipo == "Vento de Cauda") {
        return [
            new HabilidadeData("flying_tail_breeze", "Brisa de Cauda", PokemonTipo.FLYING, 1, 4.2, 16, ["single_target", "wind", "evade"], ["aplicar_status_usuario:VentoDeCauda"]),
            new HabilidadeData("flying_quick_peck", "Bicada Rapida", PokemonTipo.FLYING, 10, 3.2, 26, ["fast", "single_target", "wind"], []),
            new HabilidadeData("flying_light_feather", "Penas Leves", PokemonTipo.FLYING, 10, 7.2, 8, ["buff", "evade", "wind"], ["aplicar_status_usuario:PenasLeves", "reduzir_cooldowns_usuario:0.18"]),
            new HabilidadeData("flying_follow_wind", "Seguir o Vento", PokemonTipo.FLYING, 15, 4.4, 30, ["fast", "wind"], ["bonus_dano_usuario_status:VentoDeCauda:0.12"]),
            new HabilidadeData("flying_updraft", "Corrente Ascendente", PokemonTipo.FLYING, 20, 6.4, 24, ["control", "wind"], ["aplicar_status_usuario:VentoDeCauda"], "aplicar_status:Turbulento", ""),
            new HabilidadeData("flying_sky_dance", "Danca do Ceu", PokemonTipo.FLYING, 25, 6.6, 46, ["combo", "evade", "wind"], ["bonus_dano_usuario_status:PenasLeves:0.12", "bonus_dano_usuario_status:VentoDeCauda:0.12"]),
            new HabilidadeData("flying_tailwind_loop", "Rota de Cauda", PokemonTipo.FLYING, 30, 8.8, 56, ["ultimate", "wind"], ["reduzir_cooldowns_usuario:0.60", "bonus_dano_usuario_status:VentoDeCauda:0.18"])
        ];
    }

    return [
        new HabilidadeData("flying_gust", "Rajada", PokemonTipo.FLYING, 1, 3.8, 18, ["single_target", "wind"], [], "aplicar_status:MarcadoRasante", ""),
        new HabilidadeData("flying_swoop", "Rasante", PokemonTipo.FLYING, 10, 4.4, 30, ["burst", "wind"], ["bonus_dano_alvo_status:MarcadoRasante:0.16"], "aplicar_status:MarcadoRasante", ""),
        new HabilidadeData("flying_tailwind", "Vento de Cauda", PokemonTipo.FLYING, 10, 7.0, 8, ["buff", "wind", "evade"], ["aplicar_status_usuario:VentoDeCauda", "reduzir_cooldowns_usuario:0.20"]),
        new HabilidadeData("flying_aerial_ace", "Asa Certeira", PokemonTipo.FLYING, 15, 4.8, 38, ["single_target", "wind"], ["bonus_dano_usuario_status:VentoDeCauda:0.12"]),
        new HabilidadeData("flying_first_dive", "Mergulho Inicial", PokemonTipo.FLYING, 20, 6.2, 48, ["burst", "wind"], ["bonus_dano_alvo_status:MarcadoRasante:0.18", "bonus_dano_alvo_status:Turbulento:0.08"]),
        new HabilidadeData("flying_brave_bird", "Ave Corajosa", PokemonTipo.FLYING, 25, 8.0, 62, ["finisher", "wind"], ["sacrificar_hp_pct:0.04", "bonus_dano_usuario_status:VentoDeCauda:0.14"]),
        new HabilidadeData("flying_skyfall", "Queda do Ceu", PokemonTipo.FLYING, 30, 9.8, 70, ["ultimate", "wind"], ["bonus_dano_alvo_status:MarcadoRasante:0.22", "bonus_dano_alvo_status:Turbulento:0.12"])
    ];
}

function pokemon_habilidades_psychic_pool() {
    return pokemon_habilidades_psychic_por_arquetipo("Paralisia Mental");
}

function pokemon_habilidades_psychic_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Escudo Cinetico") {
        return [
            new HabilidadeData("psychic_kinetic_push", "Empurrao Cinetico", PokemonTipo.PSYCHIC, 1, 4.8, 16, ["single_target", "mind", "defense"], ["aplicar_status_usuario:EscudoCinetico"]),
            new HabilidadeData("psychic_kinetic_shield", "Escudo Cinetico", PokemonTipo.PSYCHIC, 10, 7.6, 8, ["buff", "defense", "mind"], ["aplicar_status_usuario:EscudoCinetico", "curar_maxhp:0.03"]),
            new HabilidadeData("psychic_barrier_bash", "Barreira Pulsante", PokemonTipo.PSYCHIC, 10, 5.8, 28, ["single_target", "mind"], ["bonus_dano_usuario_status:EscudoCinetico:0.14"]),
            new HabilidadeData("psychic_light_screen", "Tela Mental", PokemonTipo.PSYCHIC, 15, 8.4, 12, ["defense", "mind"], ["aplicar_status_usuario:EscudoCinetico"], "aplicar_status:DistorcaoEspacial", ""),
            new HabilidadeData("psychic_force_field", "Campo de Forca", PokemonTipo.PSYCHIC, 20, 7.2, 36, ["control", "mind"], ["bonus_dano_usuario_status:EscudoCinetico:0.12", "aumentar_cooldowns_alvo:0.22"]),
            new HabilidadeData("psychic_mirror_guard", "Guarda Espelhada", PokemonTipo.PSYCHIC, 25, 8.0, 44, ["defense", "combo"], ["bonus_dano_alvo_status:ParalisiaMental:0.10", "aplicar_status_usuario:EscudoCinetico"]),
            new HabilidadeData("psychic_kinetic_crush", "Esmagamento Cinetico", PokemonTipo.PSYCHIC, 30, 10.0, 60, ["ultimate", "mind"], ["bonus_dano_usuario_status:EscudoCinetico:0.18", "bonus_dano_alvo_status:DistorcaoEspacial:0.16"])
        ];
    }

    if (_arquetipo == "Inversao Espacial") {
        return [
            new HabilidadeData("psychic_space_twist", "Torcer Espaco", PokemonTipo.PSYCHIC, 1, 4.6, 20, ["single_target", "spatial", "mind"], [], "aplicar_status:DistorcaoEspacial", ""),
            new HabilidadeData("psychic_amnesia", "Amnesia", PokemonTipo.PSYCHIC, 10, 7.2, 8, ["control", "mind", "interrupt"], ["aumentar_cooldowns_alvo:0.18"], "aplicar_status:AmnesiaInduzida", ""),
            new HabilidadeData("psychic_telekinesis", "Telecinese", PokemonTipo.PSYCHIC, 10, 5.5, 30, ["single_target", "spatial"], ["bonus_dano_alvo_status:DistorcaoEspacial:0.14"]),
            new HabilidadeData("psychic_focus", "Foco Psiquico", PokemonTipo.PSYCHIC, 15, 7.0, 10, ["buff", "mind"], ["aplicar_status_usuario:FocoPsiquico", "reduzir_cooldowns_usuario:0.20"]),
            new HabilidadeData("psychic_psyshock", "Impacto Psiquico", PokemonTipo.PSYCHIC, 20, 6.8, 44, ["burst", "spatial"], ["bonus_dano_alvo_status:DistorcaoEspacial:0.16", "bonus_dano_alvo_status:PosturaQuebrada:0.08"]),
            new HabilidadeData("psychic_spatial_swap", "Troca Espacial", PokemonTipo.PSYCHIC, 25, 8.8, 50, ["control", "spatial"], ["bonus_dano_alvo_cd:0.18"], "aplicar_status:DistorcaoEspacial", ""),
            new HabilidadeData("psychic_dimension_crush", "Colapso Dimensional", PokemonTipo.PSYCHIC, 30, 11.0, 68, ["ultimate", "spatial"], ["bonus_dano_alvo_status:DistorcaoEspacial:0.20", "bonus_dano_alvo_status:AmnesiaInduzida:0.12"])
        ];
    }

    return [
        new HabilidadeData("psychic_confusion", "Confusao", PokemonTipo.PSYCHIC, 1, 4.2, 18, ["single_target", "mind", "interrupt"], ["aumentar_cooldowns_alvo:0.12"], "aplicar_status:ParalisiaMental", ""),
        new HabilidadeData("psychic_mind_lock", "Trava Mental", PokemonTipo.PSYCHIC, 10, 6.8, 10, ["control", "interrupt", "mind"], ["aumentar_cooldowns_alvo:0.35"], "aplicar_status:ParalisiaMental", ""),
        new HabilidadeData("psychic_psybeam", "Raio Mental", PokemonTipo.PSYCHIC, 10, 5.2, 32, ["single_target", "mind"], ["bonus_dano_alvo_status:ParalisiaMental:0.14"]),
        new HabilidadeData("psychic_hypnosis_pulse", "Pulso Hipnotico", PokemonTipo.PSYCHIC, 15, 7.0, 18, ["control", "interrupt"], ["aumentar_cooldowns_alvo:0.25"], "aplicar_status:AmnesiaInduzida", ""),
        new HabilidadeData("psychic_psychic", "Psiquico", PokemonTipo.PSYCHIC, 20, 7.0, 46, ["burst", "mind"], ["bonus_dano_alvo_status:ParalisiaMental:0.16", "bonus_dano_alvo_status:AmnesiaInduzida:0.10"]),
        new HabilidadeData("psychic_mind_break", "Quebra Mental", PokemonTipo.PSYCHIC, 25, 8.4, 54, ["finisher", "mind"], ["bonus_dano_alvo_status:AmnesiaInduzida:0.16", "bonus_dano_alvo_status:Vulneravel:0.08"]),
        new HabilidadeData("psychic_total_lock", "Bloqueio Total", PokemonTipo.PSYCHIC, 30, 10.4, 62, ["ultimate", "interrupt"], ["aumentar_cooldowns_alvo:0.50", "bonus_dano_alvo_status:ParalisiaMental:0.20"], "aplicar_status:ParalisiaMental", "")
    ];
}

function pokemon_habilidades_bug_pool() {
    return pokemon_habilidades_bug_por_arquetipo("Tatica de Enxame");
}

function pokemon_habilidades_bug_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Casulo Rigido") {
        return [
            new HabilidadeData("bug_hardened_tackle", "Investida de Casulo", PokemonTipo.BUG, 1, 4.8, 18, ["single_target", "cocoon", "defense"], ["aplicar_status_usuario:CasuloRigido"]),
            new HabilidadeData("bug_harden", "Casulo Rigido", PokemonTipo.BUG, 10, 7.4, 8, ["buff", "cocoon", "defense"], ["aplicar_status_usuario:CasuloRigido", "curar_maxhp:0.03"]),
            new HabilidadeData("bug_bug_bite_shell", "Mordida Blindada", PokemonTipo.BUG, 10, 5.4, 30, ["single_target", "cocoon"], ["bonus_dano_usuario_status:CasuloRigido:0.12"]),
            new HabilidadeData("bug_pupa_guard", "Guarda de Pupa", PokemonTipo.BUG, 15, 8.2, 12, ["defense", "cocoon", "sustain"], ["aplicar_status_usuario:CasuloRigido", "curar_maxhp:0.04"]),
            new HabilidadeData("bug_heavy_molt", "Muda Pesada", PokemonTipo.BUG, 20, 7.0, 42, ["burst", "metamorph"], ["bonus_dano_usuario_status:CasuloRigido:0.14", "aplicar_status_usuario:Metamorfose"]),
            new HabilidadeData("bug_shell_crush", "Esmaga Casulo", PokemonTipo.BUG, 25, 8.8, 56, ["finisher", "cocoon"], ["bonus_dano_usuario_status:CasuloRigido:0.18", "bonus_dano_alvo_status:SedaPresa:0.08"]),
            new HabilidadeData("bug_chitin_wall", "Muralha de Quitina", PokemonTipo.BUG, 30, 10.2, 58, ["ultimate", "defense", "cocoon"], ["aplicar_status_usuario:CasuloRigido", "curar_maxhp:0.05", "bonus_dano_usuario_status:CasuloRigido:0.16"])
        ];
    }

    if (_arquetipo == "Fio de Seda") {
        return [
            new HabilidadeData("bug_string_shot", "Tiro de Seda", PokemonTipo.BUG, 1, 4.2, 16, ["single_target", "silk", "control"], ["aumentar_cooldowns_alvo:0.15"], "aplicar_status:SedaPresa", ""),
            new HabilidadeData("bug_silk_bind", "Laco de Seda", PokemonTipo.BUG, 10, 6.8, 12, ["control", "silk"], ["aumentar_cooldowns_alvo:0.25"], "aplicar_status:SedaPresa", ""),
            new HabilidadeData("bug_leech_larva", "Larva Drenante", PokemonTipo.BUG, 10, 5.4, 26, ["single_target", "silk", "drain"], ["curar_dano:0.08", "bonus_dano_alvo_status:Enraizado:0.08"]),
            new HabilidadeData("bug_infestation", "Infestacao", PokemonTipo.BUG, 15, 7.2, 28, ["control", "silk"], ["bonus_dano_alvo_status:SedaPresa:0.12"], "aplicar_status:Infestado", "SedaPresa"),
            new HabilidadeData("bug_silk_trap", "Armadilha de Seda", PokemonTipo.BUG, 20, 8.0, 22, ["control", "silk"], ["aumentar_cooldowns_alvo:0.35", "bonus_dano_alvo_status:AreiaMovedica:0.08"], "aplicar_status:SedaPresa", ""),
            new HabilidadeData("bug_needle_swarm", "Agulhas de Enxame", PokemonTipo.BUG, 25, 6.4, 44, ["burst", "swarm"], ["bonus_dano_alvo_status:Infestado:0.12", "bonus_dano_alvo_status:Envenenado:0.10"]),
            new HabilidadeData("bug_web_prison", "Prisao de Teia", PokemonTipo.BUG, 30, 10.0, 60, ["ultimate", "silk", "control"], ["aumentar_cooldowns_alvo:0.50", "bonus_dano_alvo_status:SedaPresa:0.18", "bonus_dano_alvo_status:Enraizado:0.10"], "aplicar_status:SedaPresa", "")
        ];
    }

    return [
        new HabilidadeData("bug_fury_cutter", "Corte Furioso", PokemonTipo.BUG, 1, 3.2, 18, ["fast", "swarm", "single_target"], ["aplicar_status_usuario:EnxameAtivo"]),
        new HabilidadeData("bug_swarm_call", "Chamado do Enxame", PokemonTipo.BUG, 10, 6.4, 8, ["buff", "swarm", "fast"], ["aplicar_status_usuario:EnxameAtivo", "reduzir_cooldowns_usuario:0.18"]),
        new HabilidadeData("bug_pin_missile", "Missil de Espinhos", PokemonTipo.BUG, 10, 4.0, 28, ["fast", "swarm"], ["bonus_dano_usuario_status:EnxameAtivo:0.12"]),
        new HabilidadeData("bug_twineedle", "Agulha Dupla", PokemonTipo.BUG, 15, 4.4, 32, ["fast", "swarm"], ["bonus_dano_alvo_status:Envenenado:0.10"], "aplicar_status:Infestado", ""),
        new HabilidadeData("bug_x_scissor", "Tesoura Cruzada", PokemonTipo.BUG, 20, 5.8, 44, ["burst", "swarm"], ["bonus_dano_usuario_status:EnxameAtivo:0.14", "bonus_dano_alvo_status:SedaPresa:0.08"]),
        new HabilidadeData("bug_u_turn", "Bate e Volta", PokemonTipo.BUG, 25, 6.2, 46, ["fast", "swarm"], ["reduzir_cooldowns_usuario:0.25", "bonus_dano_usuario_status:VentoDeCauda:0.08"]),
        new HabilidadeData("bug_megacolony", "Megacolonia", PokemonTipo.BUG, 30, 8.6, 62, ["ultimate", "swarm"], ["bonus_dano_usuario_status:EnxameAtivo:0.18", "bonus_dano_alvo_status:Infestado:0.14", "aplicar_status_usuario:EnxameAtivo"])
    ];
}

function pokemon_habilidades_rock_pool() {
    return pokemon_habilidades_rock_por_arquetipo("Fragmentacao");
}

function pokemon_habilidades_rock_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Impacto Geologico") {
        return [
            new HabilidadeData("rock_geological_hit", "Impacto Geologico", PokemonTipo.ROCK, 1, 5.2, 30, ["single_target", "stone", "impact"], ["sacrificar_hp_pct:0.03", "bonus_dano_sacrificio:0.10"], "aplicar_status_usuario:ImpactoGeologico", ""),
            new HabilidadeData("rock_smack_down", "Derrubada de Rocha", PokemonTipo.ROCK, 10, 5.8, 36, ["single_target", "stone", "impact"], ["bonus_dano_alvo_status:Turbulento:0.10"], "aplicar_status:Fragmentado", ""),
            new HabilidadeData("rock_self_crack", "Trinca Propria", PokemonTipo.ROCK, 10, 7.0, 12, ["buff", "impact"], ["sacrificar_hp_pct:0.04", "aplicar_status_usuario:ImpactoGeologico"]),
            new HabilidadeData("rock_head_smash", "Cabecada Rochosa", PokemonTipo.ROCK, 15, 7.4, 50, ["burst", "impact"], ["sacrificar_hp_pct:0.05", "bonus_dano_sacrificio:0.18", "bonus_dano_alvo_status:Fragmentado:0.10"]),
            new HabilidadeData("rock_rock_slide", "Deslizamento", PokemonTipo.ROCK, 20, 7.2, 48, ["stone", "impact", "control"], ["aumentar_cooldowns_alvo:0.20", "bonus_dano_alvo_status:AreiaMovedica:0.08"], "aplicar_status:Fragmentado", ""),
            new HabilidadeData("rock_meteor_crash", "Queda Meteorica", PokemonTipo.ROCK, 25, 9.2, 66, ["finisher", "impact"], ["bonus_dano_alvo_status:Fragmentado:0.18", "bonus_dano_alvo_status:Desabando:0.12"]),
            new HabilidadeData("rock_continental_crush", "Esmagamento Continental", PokemonTipo.ROCK, 30, 11.0, 78, ["ultimate", "impact"], ["sacrificar_hp_pct:0.06", "bonus_dano_sacrificio:0.20", "bonus_dano_alvo_status:Fragmentado:0.18"])
        ];
    }

    if (_arquetipo == "Casca de Rocha") {
        return [
            new HabilidadeData("rock_stone_shell", "Casca de Rocha", PokemonTipo.ROCK, 1, 5.0, 16, ["single_target", "stone", "shell", "defense"], ["aplicar_status_usuario:CascaRocha"]),
            new HabilidadeData("rock_harden_stone", "Endurecer Rocha", PokemonTipo.ROCK, 10, 7.4, 8, ["buff", "shell", "defense"], ["aplicar_status_usuario:CascaRocha", "curar_maxhp:0.03"]),
            new HabilidadeData("rock_guarded_throw", "Arremesso Guardado", PokemonTipo.ROCK, 10, 5.6, 32, ["single_target", "stone"], ["bonus_dano_usuario_status:CascaRocha:0.12"]),
            new HabilidadeData("rock_fossil_guard", "Guarda Fossil", PokemonTipo.ROCK, 15, 8.4, 12, ["defense", "shell"], ["aplicar_status_usuario:FossilVivo", "curar_maxhp:0.04"]),
            new HabilidadeData("rock_heavy_weight", "Peso de Pedra", PokemonTipo.ROCK, 20, 7.2, 46, ["burst", "shell"], ["bonus_dano_usuario_status:CascaRocha:0.14", "bonus_dano_alvo_status:PosturaQuebrada:0.08"]),
            new HabilidadeData("rock_stone_edge_guard", "Gume Rochoso", PokemonTipo.ROCK, 25, 8.6, 58, ["finisher", "stone"], ["bonus_dano_alvo_status:Fragmentado:0.12", "bonus_dano_usuario_status:CascaRocha:0.12"]),
            new HabilidadeData("rock_mountain_body", "Corpo de Montanha", PokemonTipo.ROCK, 30, 10.4, 62, ["ultimate", "defense", "shell"], ["aplicar_status_usuario:CascaRocha", "curar_maxhp:0.05", "bonus_dano_usuario_status:CascaRocha:0.18"])
        ];
    }

    return [
        new HabilidadeData("rock_rock_shard", "Estilhaco de Rocha", PokemonTipo.ROCK, 1, 4.0, 22, ["single_target", "stone", "shard"], [], "aplicar_status:Fragmentado", ""),
        new HabilidadeData("rock_sharp_stone", "Pedra Afiada", PokemonTipo.ROCK, 10, 4.6, 28, ["fast", "shard"], ["bonus_dano_alvo_status:Fragmentado:0.10"]),
        new HabilidadeData("rock_shard_field", "Campo de Estilhacos", PokemonTipo.ROCK, 10, 7.2, 12, ["control", "shard"], ["aumentar_cooldowns_alvo:0.18"], "aplicar_status:Fragmentado", ""),
        new HabilidadeData("rock_fragmentation", "Fragmentacao", PokemonTipo.ROCK, 15, 6.0, 36, ["burst", "shard"], ["bonus_dano_alvo_status:Fragmentado:0.16", "bonus_dano_alvo_status:Corroendo:0.08"]),
        new HabilidadeData("rock_mineral_break", "Ruptura Mineral", PokemonTipo.ROCK, 20, 6.6, 44, ["burst", "shard"], ["bonus_dano_alvo_status:Fragmentado:0.14", "bonus_dano_alvo_status:Fragil:0.08"]),
        new HabilidadeData("rock_stone_hail", "Granizo de Pedras", PokemonTipo.ROCK, 25, 8.2, 54, ["finisher", "shard", "control"], ["aumentar_cooldowns_alvo:0.25", "bonus_dano_alvo_status:Fragmentado:0.16"]),
        new HabilidadeData("rock_meteor_rain", "Chuva de Meteoros", PokemonTipo.ROCK, 30, 10.0, 66, ["ultimate", "shard"], ["bonus_dano_alvo_status:Fragmentado:0.20", "bonus_dano_alvo_status:Enraizado:0.10", "bonus_dano_alvo_status:SedaPresa:0.10"])
    ];
}

function pokemon_habilidades_ghost_pool() {
    return pokemon_habilidades_ghost_por_arquetipo("Assombracao");
}

function pokemon_habilidades_ghost_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Intangibilidade") {
        return [
            new HabilidadeData("ghost_evasive_shadow", "Sombra Evasiva", PokemonTipo.GHOST, 1, 4.0, 18, ["single_target", "intangible"], ["aplicar_status_usuario:Intangivel"]),
            new HabilidadeData("ghost_intangible", "Intangivel", PokemonTipo.GHOST, 10, 7.0, 8, ["buff", "intangible", "control"], ["aplicar_status_usuario:Intangivel", "reduzir_cooldowns_usuario:0.18"]),
            new HabilidadeData("ghost_sudden_scare", "Susto Abrupto", PokemonTipo.GHOST, 10, 5.2, 28, ["control", "terror"], ["aumentar_cooldowns_alvo:0.20"], "aplicar_status:Amedrontado", ""),
            new HabilidadeData("ghost_phantom_step", "Passo Fantasma", PokemonTipo.GHOST, 15, 4.4, 34, ["fast", "intangible"], ["bonus_dano_usuario_status:Intangivel:0.12"]),
            new HabilidadeData("ghost_null_vault", "Vulto Nulo", PokemonTipo.GHOST, 20, 7.6, 26, ["control", "intangible"], ["aplicar_status_usuario:Intangivel", "aumentar_cooldowns_alvo:0.22"]),
            new HabilidadeData("ghost_spectral_void", "Vazio Espectral", PokemonTipo.GHOST, 25, 8.2, 50, ["finisher", "terror"], ["bonus_dano_alvo_status:Amedrontado:0.16", "bonus_dano_alvo_status:Ofuscado:0.10"]),
            new HabilidadeData("ghost_vanish", "Desaparecer", PokemonTipo.GHOST, 30, 9.8, 60, ["ultimate", "intangible"], ["aplicar_status_usuario:Intangivel", "bonus_dano_usuario_status:Intangivel:0.18", "bonus_dano_alvo_status:Amedrontado:0.10"])
        ];
    }

    if (_arquetipo == "Dreno de Essencia") {
        return [
            new HabilidadeData("ghost_essence_drain", "Dreno de Essencia", PokemonTipo.GHOST, 1, 4.8, 18, ["single_target", "essence", "drain"], ["curar_dano:0.12"], "aplicar_status:Maldito", ""),
            new HabilidadeData("ghost_curse", "Maldicao", PokemonTipo.GHOST, 10, 7.8, 12, ["curse", "control"], ["aplicar_status_usuario:EssenciaDrenada"], "aplicar_status:Maldito", ""),
            new HabilidadeData("ghost_soul_steal", "Roubo de Alma", PokemonTipo.GHOST, 10, 5.6, 30, ["single_target", "essence"], ["curar_dano_status:Maldito:0.22"]),
            new HabilidadeData("ghost_shadow_bond", "Vinculo Sombrio", PokemonTipo.GHOST, 15, 6.8, 34, ["curse", "essence"], ["bonus_dano_alvo_status:Envenenado:0.08"], "aplicar_status:Maldito", ""),
            new HabilidadeData("ghost_absorb_fear", "Absorver Medo", PokemonTipo.GHOST, 20, 7.4, 40, ["sustain", "essence"], ["curar_dano_status:Amedrontado:0.22", "curar_dano_status:Maldito:0.18"]),
            new HabilidadeData("ghost_mirror_curse", "Maldicao Espelhada", PokemonTipo.GHOST, 25, 8.8, 50, ["finisher", "curse"], ["bonus_dano_alvo_status:Maldito:0.18", "aplicar_status_usuario:EssenciaDrenada"]),
            new HabilidadeData("ghost_soul_harvest", "Colheita de Alma", PokemonTipo.GHOST, 30, 10.2, 62, ["ultimate", "essence"], ["curar_dano:0.16", "bonus_dano_alvo_status:Maldito:0.18", "bonus_dano_alvo_status:Assombrado:0.10"])
        ];
    }

    return [
        new HabilidadeData("ghost_shadow_touch", "Toque Sombrio", PokemonTipo.GHOST, 1, 4.2, 20, ["single_target", "terror"], [], "aplicar_status:Assombrado", ""),
        new HabilidadeData("ghost_haunt", "Assombracao", PokemonTipo.GHOST, 10, 6.5, 12, ["terror", "control"], ["aplicar_status_usuario:TerrorCrescente"], "aplicar_status:Assombrado", ""),
        new HabilidadeData("ghost_growing_shadow", "Sombra Crescente", PokemonTipo.GHOST, 10, 5.0, 30, ["single_target", "terror"], ["bonus_dano_alvo_status:Assombrado:0.12", "bonus_dano_usuario_status:TerrorCrescente:0.10"]),
        new HabilidadeData("ghost_nightmare", "Pesadelo", PokemonTipo.GHOST, 15, 7.0, 38, ["control", "terror"], ["bonus_dano_alvo_status:ParalisiaMental:0.10", "bonus_dano_alvo_status:Assombrado:0.12"], "aplicar_status:Amedrontado", ""),
        new HabilidadeData("ghost_terror_clock", "Relogio do Terror", PokemonTipo.GHOST, 20, 7.4, 46, ["terror", "control"], ["aumentar_cooldowns_alvo:0.20", "bonus_dano_alvo_status:Assombrado:0.14"]),
        new HabilidadeData("ghost_voracious_specter", "Espectro Voraz", PokemonTipo.GHOST, 25, 8.4, 54, ["finisher", "terror"], ["bonus_dano_alvo_status:Amedrontado:0.14", "bonus_dano_alvo_status:Maldito:0.10"]),
        new HabilidadeData("ghost_haunted_end", "Fim Assombrado", PokemonTipo.GHOST, 30, 10.6, 66, ["ultimate", "terror"], ["bonus_dano_alvo_status:Assombrado:0.20", "bonus_dano_usuario_status:TerrorCrescente:0.14", "bonus_dano_alvo_status:AmnesiaInduzida:0.08"])
    ];
}

function pokemon_habilidades_dragon_pool() {
    return pokemon_habilidades_dragon_por_arquetipo("Furia Draconica");
}

function pokemon_habilidades_dragon_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Escama Imperial") {
        return [
            new HabilidadeData("dragon_scale_bash", "Golpe de Escama", PokemonTipo.DRAGON, 1, 4.8, 20, ["single_target", "dragon", "scale", "defense"], ["aplicar_status_usuario:EscamaImperial"]),
            new HabilidadeData("dragon_imperial_scale", "Escama Imperial", PokemonTipo.DRAGON, 10, 7.4, 8, ["buff", "scale", "defense"], ["aplicar_status_usuario:EscamaImperial", "curar_maxhp:0.03"]),
            new HabilidadeData("dragon_guarded_breath", "Bafo Guardado", PokemonTipo.DRAGON, 10, 5.8, 30, ["single_target", "dragon", "breath"], ["bonus_dano_usuario_status:EscamaImperial:0.12"]),
            new HabilidadeData("dragon_coil_guard", "Espiral Draconica", PokemonTipo.DRAGON, 15, 7.8, 18, ["buff", "scale", "defense"], ["aplicar_status_usuario:EscamaImperial", "aplicar_status_usuario:AscensaoDraconica"]),
            new HabilidadeData("dragon_dragon_tail", "Cauda Draconica", PokemonTipo.DRAGON, 20, 6.8, 42, ["single_target", "dragon", "scale"], ["bonus_dano_usuario_status:EscamaImperial:0.14"], "aplicar_status:Amedrontado", ""),
            new HabilidadeData("dragon_scale_crush", "Esmaga Escamas", PokemonTipo.DRAGON, 25, 8.4, 54, ["finisher", "dragon", "scale"], ["bonus_dano_usuario_status:EscamaImperial:0.16", "bonus_dano_alvo_status:Fragmentado:0.10"]),
            new HabilidadeData("dragon_imperial_roar", "Rugido Imperial", PokemonTipo.DRAGON, 30, 10.2, 62, ["ultimate", "dragon", "scale"], ["aplicar_status_usuario:EscamaImperial", "bonus_dano_alvo_status:Amedrontado:0.16"], "aplicar_status:Amedrontado", "")
        ];
    }

    if (_arquetipo == "Sopro Ancestral") {
        return [
            new HabilidadeData("dragon_twister", "Torvelinho", PokemonTipo.DRAGON, 1, 4.6, 24, ["single_target", "dragon", "breath"], ["aplicar_status_usuario:AscensaoDraconica"]),
            new HabilidadeData("dragon_ancient_breath", "Sopro Ancestral", PokemonTipo.DRAGON, 10, 6.8, 42, ["burst", "dragon", "breath"], ["bonus_dano_usuario_status:AscensaoDraconica:0.12"], "aplicar_status:Amedrontado", ""),
            new HabilidadeData("dragon_ascension", "Ascensao", PokemonTipo.DRAGON, 10, 7.6, 8, ["buff", "dragon", "breath"], ["aplicar_status_usuario:AscensaoDraconica", "reduzir_cooldowns_usuario:0.18"]),
            new HabilidadeData("dragon_pulse", "Pulso Ancestral", PokemonTipo.DRAGON, 15, 7.0, 48, ["single_target", "dragon", "breath"], ["bonus_dano_usuario_status:AscensaoDraconica:0.14", "bonus_dano_alvo_status:Assombrado:0.08"]),
            new HabilidadeData("dragon_predator_mark", "Marca Predadora", PokemonTipo.DRAGON, 20, 6.4, 34, ["single_target", "dragon", "predator"], ["aplicar_status_usuario:Predador", "bonus_dano_alvo_status:Vulneravel:0.08"]),
            new HabilidadeData("dragon_meteor", "Estrela Draconica", PokemonTipo.DRAGON, 25, 9.6, 68, ["finisher", "dragon", "breath"], ["bonus_dano_usuario_status:AscensaoDraconica:0.16", "bonus_dano_alvo_status:Fragil:0.10", "bonus_dano_alvo_status:Fragmentado:0.10"]),
            new HabilidadeData("dragon_ancient_collapse", "Colapso Ancestral", PokemonTipo.DRAGON, 30, 11.4, 78, ["ultimate", "dragon", "breath"], ["aumentar_cooldowns_alvo:0.30", "bonus_dano_usuario_status:AscensaoDraconica:0.18", "bonus_dano_alvo_status:Amedrontado:0.10"])
        ];
    }

    return [
        new HabilidadeData("dragon_dragon_claw", "Garra Draconica", PokemonTipo.DRAGON, 1, 4.8, 28, ["single_target", "dragon", "fury"], ["aplicar_status_usuario:FuriaDraconica"]),
        new HabilidadeData("dragon_rage_focus", "Ira Ancestral", PokemonTipo.DRAGON, 10, 5.6, 36, ["burst", "dragon", "fury"], ["bonus_dano_usuario_status:FuriaDraconica:0.12", "bonus_dano_usuario_hp_baixo:0.45:0.10"]),
        new HabilidadeData("dragon_battle_roar", "Rugido Draconico", PokemonTipo.DRAGON, 10, 7.2, 10, ["control", "dragon", "fury"], ["aplicar_status_usuario:FuriaDraconica"], "aplicar_status:Amedrontado", ""),
        new HabilidadeData("dragon_breaking_tail", "Cauda Quebrante", PokemonTipo.DRAGON, 15, 6.4, 44, ["single_target", "dragon", "fury"], ["bonus_dano_alvo_status:Fragmentado:0.14", "bonus_dano_alvo_status:PosturaQuebrada:0.08"]),
        new HabilidadeData("dragon_bloodrush", "Sangue de Dragao", PokemonTipo.DRAGON, 20, 7.2, 52, ["burst", "dragon", "fury"], ["sacrificar_hp_pct:0.04", "bonus_dano_sacrificio:0.16", "aplicar_status_usuario:FuriaDraconica"]),
        new HabilidadeData("dragon_fierce_rush", "Investida Feroz", PokemonTipo.DRAGON, 25, 8.6, 62, ["finisher", "dragon", "fury"], ["bonus_dano_usuario_status:FuriaDraconica:0.16", "bonus_dano_alvo_hp_baixo:0.40:0.14"]),
        new HabilidadeData("dragon_outrage", "Colera Draconica", PokemonTipo.DRAGON, 30, 10.6, 74, ["ultimate", "dragon", "fury"], ["bonus_dano_usuario_status:FuriaDraconica:0.18", "bonus_dano_usuario_hp_baixo:0.45:0.14", "aplicar_status_usuario:FuriaDraconica"])
    ];
}

function pokemon_habilidades_steel_pool() {
    return pokemon_habilidades_steel_por_arquetipo("Fortificacao Rigida");
}

function pokemon_habilidades_steel_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Espinhos de Ferro") {
        return [
            new HabilidadeData("steel_iron_barbs", "Espinhos de Ferro", PokemonTipo.STEEL, 1, 4.8, 16, ["single_target", "steel", "thorns", "defense"], ["aplicar_status_usuario:EspinhosFerro"]),
            new HabilidadeData("steel_spike_guard", "Guarda Espinhosa", PokemonTipo.STEEL, 10, 7.2, 8, ["buff", "steel", "thorns"], ["aplicar_status_usuario:EspinhosFerro", "aplicar_status_usuario:Fortificado"]),
            new HabilidadeData("steel_metal_claw", "Garra Metal", PokemonTipo.STEEL, 10, 4.8, 30, ["single_target", "steel", "thorns"], ["bonus_dano_alvo_status:Fragmentado:0.10"]),
            new HabilidadeData("steel_counter_spikes", "Contra Espinhos", PokemonTipo.STEEL, 15, 6.2, 34, ["single_target", "steel", "thorns"], ["bonus_dano_usuario_status:EspinhosFerro:0.14"]),
            new HabilidadeData("steel_iron_head", "Testada de Ferro", PokemonTipo.STEEL, 20, 6.8, 44, ["burst", "steel", "heavy"], ["bonus_dano_usuario_status:Fortificado:0.12", "bonus_dano_alvo_status:PosturaQuebrada:0.08"]),
            new HabilidadeData("steel_spike_storm", "Tempestade de Espinhos", PokemonTipo.STEEL, 25, 8.0, 52, ["finisher", "steel", "thorns"], ["aplicar_status_usuario:EspinhosFerro", "bonus_dano_alvo_status:SedaPresa:0.10", "bonus_dano_alvo_status:Enraizado:0.08"]),
            new HabilidadeData("steel_thorn_prison", "Prisao de Ferro", PokemonTipo.STEEL, 30, 9.6, 60, ["ultimate", "steel", "thorns"], ["bonus_dano_usuario_status:EspinhosFerro:0.18", "bonus_dano_alvo_status:Fragmentado:0.14", "bonus_dano_alvo_status:Enraizado:0.10"])
        ];
    }

    if (_arquetipo == "Impacto Pesado") {
        return [
            new HabilidadeData("steel_heavy_slam", "Impacto Pesado", PokemonTipo.STEEL, 1, 5.0, 24, ["single_target", "steel", "heavy"], ["aplicar_status_usuario:ImpactoPesado"]),
            new HabilidadeData("steel_magnetic_armor", "Blindagem Magnetica", PokemonTipo.STEEL, 10, 7.0, 8, ["buff", "steel", "magnetic"], ["aplicar_status_usuario:BlindagemMagnetica", "reduzir_cooldowns_usuario:0.12"]),
            new HabilidadeData("steel_bullet_punch", "Soco Projetil", PokemonTipo.STEEL, 10, 3.6, 26, ["fast", "steel", "heavy"], ["bonus_dano_usuario_status:ImpactoPesado:0.10"]),
            new HabilidadeData("steel_mirror_shot", "Disparo Espelhado", PokemonTipo.STEEL, 15, 5.8, 36, ["single_target", "steel", "magnetic"], ["bonus_dano_alvo_status:Ofuscado:0.10"], "aplicar_status_usuario:BlindagemMagnetica", ""),
            new HabilidadeData("steel_smart_strike", "Ataque Inteligente", PokemonTipo.STEEL, 20, 6.2, 44, ["burst", "steel", "heavy"], ["bonus_dano_alvo_status:Paralisado:0.10", "bonus_dano_alvo_status:Fragmentado:0.10"]),
            new HabilidadeData("steel_heavy_press", "Prensa Pesada", PokemonTipo.STEEL, 25, 8.4, 58, ["finisher", "steel", "heavy"], ["bonus_dano_usuario_status:ImpactoPesado:0.16", "bonus_dano_usuario_status:Fortificado:0.10"]),
            new HabilidadeData("steel_meteor_mash", "Soco Meteoro", PokemonTipo.STEEL, 30, 10.0, 70, ["ultimate", "steel", "heavy"], ["aplicar_status_usuario:ImpactoPesado", "bonus_dano_usuario_status:BlindagemMagnetica:0.14", "bonus_dano_alvo_status:Fragmentado:0.12"])
        ];
    }

    return [
        new HabilidadeData("steel_fortified_hit", "Impacto Fortificado", PokemonTipo.STEEL, 1, 5.0, 18, ["single_target", "steel", "fortify", "defense"], ["aplicar_status_usuario:Fortificado"]),
        new HabilidadeData("steel_iron_defense", "Defesa de Ferro", PokemonTipo.STEEL, 10, 7.4, 8, ["buff", "steel", "fortify"], ["aplicar_status_usuario:Fortificado", "curar_maxhp:0.03"]),
        new HabilidadeData("steel_gyro_ball", "Giro de Aco", PokemonTipo.STEEL, 10, 5.8, 32, ["single_target", "steel", "heavy"], ["bonus_dano_usuario_status:Fortificado:0.12"]),
        new HabilidadeData("steel_alloy_wall", "Muralha de Liga", PokemonTipo.STEEL, 15, 8.2, 12, ["defense", "steel", "fortify"], ["aplicar_status_usuario:LigaPesada", "aplicar_status_usuario:Fortificado"]),
        new HabilidadeData("steel_anchor_press", "Prensa de Aco", PokemonTipo.STEEL, 20, 7.0, 42, ["burst", "steel", "heavy"], ["bonus_dano_usuario_status:LigaPesada:0.12", "bonus_dano_alvo_status:AreiaMovedica:0.08"]),
        new HabilidadeData("steel_registeel_core", "Nucleo Blindado", PokemonTipo.STEEL, 25, 8.8, 48, ["sustain", "steel", "fortify"], ["aplicar_status_usuario:Fortificado", "curar_maxhp:0.04"]),
        new HabilidadeData("steel_immovable_body", "Corpo Imovel", PokemonTipo.STEEL, 30, 10.2, 58, ["ultimate", "steel", "fortify"], ["aplicar_status_usuario:Fortificado", "aplicar_status_usuario:LigaPesada", "bonus_dano_usuario_status:Fortificado:0.16"])
    ];
}

function pokemon_habilidades_dark_pool() {
    return pokemon_habilidades_dark_por_arquetipo("Golpe Traicoeiro");
}

function pokemon_habilidades_dark_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Golpe Baixo") {
        return [
            new HabilidadeData("dark_bite", "Mordida", PokemonTipo.DARK, 1, 4.0, 22, ["single_target", "dark", "lowblow"], ["bonus_dano_alvo_cd:0.10"], "aplicar_status:MarcadoSombrio", ""),
            new HabilidadeData("dark_low_blow", "Golpe Baixo", PokemonTipo.DARK, 10, 4.8, 34, ["single_target", "dark", "lowblow"], ["bonus_dano_alvo_cd:0.18", "bonus_dano_alvo_status:MarcadoSombrio:0.10"], "aplicar_status_usuario:GolpeBaixo", ""),
            new HabilidadeData("dark_feint", "Finta Sombria", PokemonTipo.DARK, 10, 6.8, 14, ["control", "dark", "trick"], ["aumentar_cooldowns_alvo:0.18"], "aplicar_status:MarcadoSombrio", ""),
            new HabilidadeData("dark_ambush", "Emboscada", PokemonTipo.DARK, 15, 5.8, 40, ["burst", "dark", "lowblow"], ["bonus_dano_usuario_status:GolpeBaixo:0.12", "bonus_dano_alvo_status:Amedrontado:0.08"]),
            new HabilidadeData("dark_night_slash", "Corte Noturno", PokemonTipo.DARK, 20, 6.4, 48, ["burst", "dark", "lowblow"], ["bonus_dano_alvo_status:MarcadoSombrio:0.14", "bonus_dano_alvo_status:Ofuscado:0.08"]),
            new HabilidadeData("dark_opportunist", "Punicao Oportuna", PokemonTipo.DARK, 25, 7.8, 58, ["finisher", "dark", "lowblow"], ["bonus_dano_alvo_cd:0.20", "bonus_dano_alvo_status:PosturaQuebrada:0.10", "bonus_dano_alvo_status:Vulneravel:0.08"]),
            new HabilidadeData("dark_checkmate", "Xeque Sombrio", PokemonTipo.DARK, 30, 9.6, 68, ["ultimate", "dark", "lowblow"], ["bonus_dano_usuario_status:GolpeBaixo:0.16", "bonus_dano_alvo_status:MarcadoSombrio:0.18", "bonus_dano_alvo_cd:0.18"])
        ];
    }

    if (_arquetipo == "Copia Sombria") {
        return [
            new HabilidadeData("dark_shadow_copy", "Copia Sombria", PokemonTipo.DARK, 1, 5.0, 16, ["single_target", "dark", "shadowcopy"], ["aplicar_status_usuario:CopiaSombria"], "aplicar_status:MarcadoSombrio", ""),
            new HabilidadeData("dark_camouflage", "Camuflagem", PokemonTipo.DARK, 10, 7.2, 8, ["buff", "dark", "camouflage"], ["aplicar_status_usuario:CamuflagemSombria", "reduzir_cooldowns_usuario:0.10"]),
            new HabilidadeData("dark_pursuit", "Perseguicao", PokemonTipo.DARK, 10, 5.2, 30, ["single_target", "dark", "pursuit"], ["bonus_dano_alvo_status:Evasivo:0.14", "bonus_dano_alvo_status:Intangivel:0.14", "bonus_dano_alvo_cd:0.08"]),
            new HabilidadeData("dark_false_shadow", "Sombra Falsa", PokemonTipo.DARK, 15, 6.0, 34, ["trick", "dark", "shadowcopy"], ["aplicar_status_usuario:CopiaSombria", "bonus_dano_alvo_status:MarcadoSombrio:0.08"], "aplicar_status:MarcadoSombrio", ""),
            new HabilidadeData("dark_night_step", "Passo Noturno", PokemonTipo.DARK, 20, 5.8, 42, ["burst", "dark", "camouflage"], ["bonus_dano_usuario_status:CamuflagemSombria:0.14", "bonus_dano_alvo_status:Ofuscado:0.08"]),
            new HabilidadeData("dark_shadow_hunt", "Caca nas Sombras", PokemonTipo.DARK, 25, 7.8, 54, ["finisher", "dark", "pursuit"], ["aplicar_status_usuario:PerseguicaoSombria", "bonus_dano_alvo_status:VentoDeCauda:0.10", "bonus_dano_alvo_status:PenasLeves:0.10", "bonus_dano_alvo_status:Evasivo:0.14"]),
            new HabilidadeData("dark_final_illusion", "Ilusao Final", PokemonTipo.DARK, 30, 9.8, 62, ["ultimate", "dark", "shadowcopy"], ["bonus_dano_usuario_status:CopiaSombria:0.16", "bonus_dano_usuario_status:CamuflagemSombria:0.12", "bonus_dano_alvo_status:MarcadoSombrio:0.14"])
        ];
    }

    return [
        new HabilidadeData("dark_foul_play", "Golpe Traicoeiro", PokemonTipo.DARK, 1, 4.8, 20, ["single_target", "dark", "dirty"], ["bonus_dano_alvo_status:Corroendo:0.08", "bonus_dano_alvo_status:ArmaduraDerretida:0.08"], "aplicar_status_usuario:JogoSujo", ""),
        new HabilidadeData("dark_dirty_taunt", "Provocacao Suja", PokemonTipo.DARK, 10, 7.0, 12, ["control", "dark", "trick"], ["aumentar_cooldowns_alvo:0.18"], "aplicar_status:MarcadoSombrio", ""),
        new HabilidadeData("dark_cruel_bite", "Mordida Cruel", PokemonTipo.DARK, 10, 5.0, 30, ["single_target", "dark", "dirty"], ["bonus_dano_alvo_status:Envenenado:0.12", "bonus_dano_alvo_status:Corroendo:0.10"]),
        new HabilidadeData("dark_power_theft", "Roubo de Forca", PokemonTipo.DARK, 15, 6.4, 32, ["sustain", "dark", "dirty"], ["curar_dano:0.08", "bonus_dano_alvo_status:Vulneravel:0.10", "bonus_dano_usuario_status:JogoSujo:0.10"]),
        new HabilidadeData("dark_dirty_trick", "Truque Sujo", PokemonTipo.DARK, 20, 6.8, 44, ["burst", "dark", "trick"], ["bonus_dano_alvo_status:MarcadoSombrio:0.12", "bonus_dano_alvo_status:AmnesiaInduzida:0.08", "bonus_dano_alvo_status:ParalisiaMental:0.08"]),
        new HabilidadeData("dark_punishment", "Punicao", PokemonTipo.DARK, 25, 8.2, 54, ["finisher", "dark", "dirty"], ["bonus_dano_alvo_status:ArmaduraDerretida:0.14", "bonus_dano_alvo_status:Fragmentado:0.12", "bonus_dano_alvo_status:PosturaQuebrada:0.10"]),
        new HabilidadeData("dark_moral_collapse", "Colapso Moral", PokemonTipo.DARK, 30, 10.0, 64, ["ultimate", "dark", "dirty"], ["aplicar_status_usuario:JogoSujo", "bonus_dano_alvo_status:Envenenado:0.12", "bonus_dano_alvo_status:Corroendo:0.14", "bonus_dano_alvo_status:MarcadoSombrio:0.14"])
    ];
}

function pokemon_habilidades_fairy_pool() {
    return pokemon_habilidades_fairy_por_arquetipo("Aura Mistica");
}

function pokemon_habilidades_fairy_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Encantamento de Carga") {
        return [
            new HabilidadeData("fairy_fairy_wind", "Vento Feerico", PokemonTipo.FAIRY, 1, 4.2, 22, ["single_target", "fairy", "charm"], [], "aplicar_status:BrilhoOfuscante", ""),
            new HabilidadeData("fairy_charged_charm", "Carga Encantada", PokemonTipo.FAIRY, 10, 7.2, 8, ["buff", "fairy", "charge"], ["aplicar_status_usuario:EncantoCarga", "reduzir_cooldowns_usuario:0.10"]),
            new HabilidadeData("fairy_draining_kiss", "Beijo Drenante", PokemonTipo.FAIRY, 10, 5.6, 24, ["single_target", "fairy", "sustain"], ["curar_dano:0.12", "bonus_dano_alvo_status:BrilhoOfuscante:0.10"]),
            new HabilidadeData("fairy_light_burst", "Explosao de Luz", PokemonTipo.FAIRY, 15, 7.2, 42, ["burst", "fairy", "charge"], ["bonus_dano_usuario_status:EncantoCarga:0.16"]),
            new HabilidadeData("fairy_moon_cut", "Corte Lunar", PokemonTipo.FAIRY, 20, 6.6, 44, ["burst", "fairy", "charge"], ["bonus_dano_alvo_status:Ofuscado:0.08", "bonus_dano_alvo_status:BrilhoOfuscante:0.12"]),
            new HabilidadeData("fairy_enchanted_beam", "Feixe Encantado", PokemonTipo.FAIRY, 25, 8.4, 56, ["finisher", "fairy", "charge"], ["bonus_dano_usuario_status:AuraMistica:0.08", "bonus_dano_usuario_status:EncantoCarga:0.18"]),
            new HabilidadeData("fairy_prismatic_burst", "Estouro Prismatico", PokemonTipo.FAIRY, 30, 10.0, 66, ["ultimate", "fairy", "charge"], ["aplicar_status_usuario:EncantoCarga", "bonus_dano_usuario_status:EncantoCarga:0.16"])
        ];
    }

    if (_arquetipo == "Luz Purificadora") {
        return [
            new HabilidadeData("fairy_serene_light", "Luz Serena", PokemonTipo.FAIRY, 1, 5.2, 16, ["single_target", "fairy", "purify", "sustain"], ["aplicar_status_usuario:LuzPurificadora", "curar_maxhp:0.04"]),
            new HabilidadeData("fairy_purify", "Purificar", PokemonTipo.FAIRY, 10, 8.0, 8, ["buff", "fairy", "purify"], ["aplicar_status_usuario:LuzPurificadora", "curar_maxhp:0.07"]),
            new HabilidadeData("fairy_clear_vow", "Voto Claro", PokemonTipo.FAIRY, 10, 5.8, 26, ["single_target", "fairy", "purify"], ["bonus_dano_usuario_status:LuzPurificadora:0.10", "bonus_dano_alvo_status:Envenenado:0.08", "bonus_dano_alvo_status:Queimando:0.08"]),
            new HabilidadeData("fairy_fairy_barrier", "Barreira Feerica", PokemonTipo.FAIRY, 15, 8.5, 12, ["defense", "fairy", "purify"], ["aplicar_status_usuario:BarreiraFada", "curar_maxhp:0.05"]),
            new HabilidadeData("fairy_restoring_light", "Luz Restauradora", PokemonTipo.FAIRY, 20, 7.8, 30, ["sustain", "fairy", "purify"], ["aplicar_status_usuario:LuzPurificadora", "curar_maxhp:0.08"]),
            new HabilidadeData("fairy_lunar_blessing", "Bencao Lunar", PokemonTipo.FAIRY, 25, 8.8, 40, ["sustain", "fairy", "aura"], ["aplicar_status_usuario:AuraMistica", "curar_maxhp:0.07"]),
            new HabilidadeData("fairy_fairy_miracle", "Milagre Feerico", PokemonTipo.FAIRY, 30, 11.0, 52, ["ultimate", "fairy", "purify"], ["aplicar_status_usuario:BarreiraFada", "bonus_dano_usuario_status:LuzPurificadora:0.18"])
        ];
    }

    return [
        new HabilidadeData("fairy_charm", "Charme", PokemonTipo.FAIRY, 1, 5.0, 14, ["single_target", "fairy", "charm"], [], "aplicar_status:BrilhoOfuscante", ""),
        new HabilidadeData("fairy_mystic_song", "Canto Mistico", PokemonTipo.FAIRY, 10, 6.2, 22, ["single_target", "fairy", "aura"], ["aplicar_status_usuario:AuraMistica", "bonus_dano_alvo_status:Amedrontado:0.08"]),
        new HabilidadeData("fairy_dazzling_glow", "Brilho Ofuscante", PokemonTipo.FAIRY, 10, 6.4, 26, ["single_target", "fairy", "charm"], [], "aplicar_status:Ofuscado", ""),
        new HabilidadeData("fairy_mystic_aura", "Aura Mistica", PokemonTipo.FAIRY, 15, 8.0, 18, ["buff", "fairy", "aura"], ["aplicar_status_usuario:AuraMistica", "reduzir_cooldowns_usuario:0.08"]),
        new HabilidadeData("fairy_charming_bond", "Laco Encantado", PokemonTipo.FAIRY, 20, 6.8, 38, ["burst", "fairy", "charm"], ["bonus_dano_alvo_status:MarcadoSombrio:0.08", "bonus_dano_alvo_status:ParalisiaMental:0.08", "bonus_dano_alvo_status:BrilhoOfuscante:0.12"]),
        new HabilidadeData("fairy_guardian_light", "Guardiao Feerico", PokemonTipo.FAIRY, 25, 8.2, 36, ["defense", "fairy", "aura"], ["aplicar_status_usuario:BarreiraFada", "bonus_dano_usuario_status:AuraMistica:0.10"]),
        new HabilidadeData("fairy_prismatic_aura", "Aura Prismatica", PokemonTipo.FAIRY, 30, 10.2, 58, ["ultimate", "fairy", "aura"], ["aplicar_status_usuario:AuraMistica", "bonus_dano_usuario_status:AuraMistica:0.18"])
    ];
}

function pokemon_habilidades_normal_pool() {
    return pokemon_habilidades_normal_por_arquetipo("Forca Neutra");
}

function pokemon_habilidades_normal_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Estocar") {
        return [
            new HabilidadeData("normal_body_slam", "Encontrao", PokemonTipo.NORMAL, 1, 4.4, 22, ["single_target", "normal", "stockpile"], ["aplicar_status_usuario:EstoqueDefensivo"]),
            new HabilidadeData("normal_stockpile", "Estocar", PokemonTipo.NORMAL, 10, 7.2, 6, ["buff", "normal", "stockpile", "defense"], ["aplicar_status_usuario:EstoqueDefensivo", "curar_maxhp:0.04"]),
            new HabilidadeData("normal_defense_curl", "Enrolar", PokemonTipo.NORMAL, 10, 6.8, 8, ["defense", "normal", "stockpile"], ["aplicar_status_usuario:EstoqueDefensivo"]),
            new HabilidadeData("normal_spit_up", "Liberar", PokemonTipo.NORMAL, 15, 6.8, 38, ["burst", "normal", "stockpile"], ["bonus_dano_usuario_status:EstoqueDefensivo:0.16"]),
            new HabilidadeData("normal_hold_down", "Agarrar", PokemonTipo.NORMAL, 20, 6.4, 36, ["single_target", "normal", "stockpile"], ["bonus_dano_alvo_status:Enraizado:0.08", "bonus_dano_alvo_status:SedaPresa:0.08", "bonus_dano_alvo_status:AreiaMovedica:0.08"]),
            new HabilidadeData("normal_heavy_body", "Corpo Pesado", PokemonTipo.NORMAL, 25, 8.0, 50, ["finisher", "normal", "stockpile"], ["bonus_dano_usuario_status:EstoqueDefensivo:0.18", "bonus_dano_usuario_status:Fortificado:0.08"]),
            new HabilidadeData("normal_stored_blast", "Explosao Guardada", PokemonTipo.NORMAL, 30, 10.5, 68, ["ultimate", "normal", "stockpile"], ["bonus_dano_usuario_status:EstoqueDefensivo:0.22"])
        ];
    }

    if (_arquetipo == "Legado") {
        return [
            new HabilidadeData("normal_mimicry", "Mimetismo", PokemonTipo.NORMAL, 1, 5.0, 18, ["single_target", "normal", "mimic"], ["aplicar_status_usuario:MimetismoAtivo"]),
            new HabilidadeData("normal_recycle", "Reciclagem", PokemonTipo.NORMAL, 10, 8.0, 8, ["buff", "normal", "recycle"], ["aplicar_status_usuario:ReciclagemAtiva", "reduzir_cooldowns_usuario:0.14"]),
            new HabilidadeData("normal_adaptive_echo", "Eco Adaptavel", PokemonTipo.NORMAL, 10, 5.6, 26, ["single_target", "normal", "mimic"], ["bonus_dano_usuario_status:MimetismoAtivo:0.12"]),
            new HabilidadeData("normal_baton_shift", "Revezamento", PokemonTipo.NORMAL, 15, 7.0, 28, ["support", "normal", "legacy"], ["aplicar_status_usuario:LegadoAtivo", "curar_maxhp:0.04"]),
            new HabilidadeData("normal_rhythm_copy", "Copia de Ritmo", PokemonTipo.NORMAL, 20, 6.6, 34, ["single_target", "normal", "recycle"], ["bonus_dano_usuario_status:ReciclagemAtiva:0.12", "bonus_dano_alvo_status:MarcadoSombrio:0.08"]),
            new HabilidadeData("normal_legacy", "Legado", PokemonTipo.NORMAL, 25, 9.0, 22, ["support", "normal", "legacy"], ["aplicar_status_usuario:LegadoAtivo", "curar_maxhp:0.06"]),
            new HabilidadeData("normal_heroic_heritage", "Heranca Heroica", PokemonTipo.NORMAL, 30, 10.0, 54, ["ultimate", "normal", "legacy"], ["bonus_dano_usuario_status:LegadoAtivo:0.18", "bonus_dano_usuario_status:MimetismoAtivo:0.10"])
        ];
    }

    return [
        new HabilidadeData("normal_tackle", "Investida", PokemonTipo.NORMAL, 1, 3.8, 24, ["single_target", "normal"], ["aplicar_status_usuario:ForcaNeutra"]),
        new HabilidadeData("normal_quick_attack", "Ataque Rapido", PokemonTipo.NORMAL, 10, 2.9, 24, ["fast", "normal"], ["bonus_dano_usuario_status:ForcaNeutra:0.08"]),
        new HabilidadeData("normal_simple_focus", "Foco Simples", PokemonTipo.NORMAL, 10, 7.0, 8, ["buff", "normal"], ["aplicar_status_usuario:ForcaNeutra", "reduzir_cooldowns_usuario:0.10"]),
        new HabilidadeData("normal_sure_hit", "Golpe Certo", PokemonTipo.NORMAL, 15, 5.2, 36, ["single_target", "normal"], ["bonus_dano_usuario_status:ForcaNeutra:0.12"]),
        new HabilidadeData("normal_neutral_force", "Forca Neutra", PokemonTipo.NORMAL, 20, 6.0, 46, ["burst", "normal"], ["bonus_dano_usuario_status:ForcaNeutra:0.14"]),
        new HabilidadeData("normal_constant_rhythm", "Ritmo Constante", PokemonTipo.NORMAL, 25, 5.4, 42, ["fast", "normal"], ["aplicar_status_usuario:ForcaNeutra", "reduzir_cooldowns_usuario:0.08"]),
        new HabilidadeData("normal_perfect_impact", "Impacto Perfeito", PokemonTipo.NORMAL, 30, 8.8, 62, ["ultimate", "normal"], ["bonus_dano_usuario_status:ForcaNeutra:0.18"])
    ];
}

function pokemon_habilidades_poison_por_arquetipo(_arquetipo) {
    if (_arquetipo == "Toxina Autodestrutiva") {
        return [
            new HabilidadeData("poison_fang", "Presa Venenosa", PokemonTipo.POISON, 1, 4.4, 24, ["single_target", "poison"], [], "aplicar_status:Envenenado", ""),
            new HabilidadeData("toxic_blood", "Sangue Toxico", PokemonTipo.POISON, 10, 5.8, 30, ["sacrifice", "burst", "poison"], ["sacrificar_hp_pct:0.04", "bonus_dano_sacrificio:0.18"]),
            new HabilidadeData("poison_jab", "Golpe Venenoso", PokemonTipo.POISON, 15, 6.2, 40, ["burst", "poison"], ["bonus_dano_alvo_status:Envenenado:0.16"], "", "Envenenado"),
            new HabilidadeData("acid_spray", "Acido Diluidor", PokemonTipo.POISON, 15, 5.2, 22, ["debuff", "single_target"], [], "aplicar_status:Corroendo", ""),
            new HabilidadeData("toxic_burst", "Explosao Toxica", PokemonTipo.POISON, 20, 9.0, 56, ["sacrifice", "finisher"], ["sacrificar_hp_pct:0.07", "bonus_dano_sacrificio:0.22", "bonus_dano_usuario_status:ToxinaAtiva:0.12"], "aplicar_status:Envenenado", ""),
            new HabilidadeData("reverse_antidote", "Antidoto Reverso", PokemonTipo.POISON, 25, 8.0, 34, ["sacrifice", "buff"], ["sacrificar_hp_pct:0.03", "aplicar_status_usuario:ToxinaAtiva"]),
            new HabilidadeData("venom_drain", "Seiva Toxica", PokemonTipo.POISON, 25, 7.4, 34, ["sustain", "poison"], ["curar_dano_status:Envenenado:0.20", "curar_dano_status:Enraizado:0.15"]),
            new HabilidadeData("venom_implosion", "Implosao Venenosa", PokemonTipo.POISON, 30, 11.0, 68, ["ultimate", "sacrifice"], ["sacrificar_hp_pct:0.10", "bonus_dano_sacrificio:0.25", "bonus_dano_alvo_status:Envenenado:0.18", "bonus_dano_usuario_status:ToxinaAtiva:0.15"])
        ];
    }

    if (_arquetipo == "Corrosao Organica") {
        return [
            new HabilidadeData("acid", "Acido", PokemonTipo.POISON, 1, 4.4, 20, ["single_target", "corrosion"], [], "aplicar_status:Corroendo", ""),
            new HabilidadeData("acid_spray", "Acido Diluidor", PokemonTipo.POISON, 10, 5.2, 24, ["debuff", "single_target"], [], "aplicar_status:Corroendo", ""),
            new HabilidadeData("poison_powder", "Po de Veneno", PokemonTipo.POISON, 10, 8.4, 7, ["debuff", "poison", "combo_setup"], [], "aplicar_status:Envenenado", ""),
            new HabilidadeData("toxic_mud", "Lama Toxica", PokemonTipo.POISON, 15, 6.2, 32, ["corrosion", "poison"], ["bonus_dano_alvo_status:Corroendo:0.16", "bonus_dano_alvo_status:Enraizado:0.08"]),
            new HabilidadeData("sludge", "Lodo", PokemonTipo.POISON, 20, 7.0, 42, ["single_target", "poison"], ["bonus_dano_alvo_status:Enraizado:0.14", "bonus_dano_alvo_status:Corroendo:0.12"]),
            new HabilidadeData("toxic_gas", "Gas Corrosivo", PokemonTipo.POISON, 25, 9.0, 18, ["control", "corrosion"], ["bonus_dano_alvo_status:Envenenado:0.10"], "aplicar_status:Vulneravel", "Corroendo"),
            new HabilidadeData("toxic_bind", "Vinhas Toxicas", PokemonTipo.POISON, 25, 7.8, 24, ["root", "poison", "combo_setup"], [], "aplicar_status:Enraizado", "Envenenado"),
            new HabilidadeData("toxic_wave", "Onda Toxica", PokemonTipo.POISON, 30, 10.0, 60, ["ultimate", "corrosion"], ["bonus_dano_alvo_status:Corroendo:0.20", "bonus_dano_alvo_status:Envenenado:0.14"])
        ];
    }

    return [
        new HabilidadeData("poison_sting", "Agulhao Venenoso", PokemonTipo.POISON, 1, 3.8, 18, ["fast", "poison"], [], "aplicar_status:Envenenado", ""),
        new HabilidadeData("poison_powder", "Po de Veneno", PokemonTipo.POISON, 10, 8.5, 7, ["debuff", "poison", "combo_setup"], [], "aplicar_status:Envenenado", ""),
        new HabilidadeData("acid_spray", "Acido Diluidor", PokemonTipo.POISON, 10, 5.2, 24, ["debuff", "single_target"], [], "aplicar_status:Corroendo", ""),
        new HabilidadeData("venoshock", "Choque Venenoso", PokemonTipo.POISON, 15, 6.0, 36, ["burst", "poison"], ["bonus_dano_alvo_status:Envenenado:0.22"], "", "Envenenado"),
        new HabilidadeData("toxic_spores", "Esporos Toxicos", PokemonTipo.POISON, 15, 8.8, 12, ["control", "poison"], ["bonus_dano_alvo_status:Enraizado:0.12"], "aplicar_status:Envenenado", ""),
        new HabilidadeData("sludge", "Lodo", PokemonTipo.POISON, 20, 7.0, 42, ["single_target", "poison"], ["bonus_dano_alvo_status:Enraizado:0.14", "bonus_dano_alvo_status:Corroendo:0.10"]),
        new HabilidadeData("toxic_bind", "Vinhas Toxicas", PokemonTipo.POISON, 20, 7.8, 24, ["root", "poison", "combo_setup"], [], "aplicar_status:Enraizado", "Envenenado"),
        new HabilidadeData("venom_drain", "Seiva Toxica", PokemonTipo.POISON, 25, 7.6, 34, ["sustain", "poison"], ["curar_dano_status:Envenenado:0.22", "curar_dano_status:Enraizado:0.18"]),
        new HabilidadeData("toxic_bloom", "Floracao Toxica", PokemonTipo.POISON, 30, 10.5, 56, ["finisher", "poison"], ["bonus_dano_alvo_status:Envenenado:0.20", "bonus_dano_alvo_status:Enraizado:0.15"])
    ];
}

function pokemon_skill_pool_mesclar(_base, _extra, _tipo_secundario) {
    var _pool = [];

    for (var _i = 0; _i < array_length(_base); _i += 1) {
        array_push(_pool, _base[_i]);
    }

    for (var _j = 0; _j < array_length(_extra); _j += 1) {
        var _skill = _extra[_j];

        if (!is_struct(_skill)) {
            continue;
        }

        if (_tipo_secundario && _skill.NivelAprendizado <= 1) {
            _skill.NivelAprendizado = 10;
        }

        var _existe = false;

        for (var _k = 0; _k < array_length(_pool); _k += 1) {
            if (is_struct(_pool[_k]) && _pool[_k].ID == _skill.ID) {
                _existe = true;
                break;
            }
        }

        if (!_existe) {
            array_push(_pool, _skill);
        }
    }

    return _pool;
}

function pokemon_habilidades_genericas_por_tipo(_tipo) {
    if (_tipo == PokemonTipo.NORMAL) {
        return pokemon_habilidades_normal_pool();
    }

    if (_tipo == PokemonTipo.GRASS) {
        return pokemon_habilidades_grass_pool();
    }

    if (_tipo == PokemonTipo.POISON) {
        return pokemon_habilidades_poison_pool();
    }

    if (_tipo == PokemonTipo.FIRE) {
        return pokemon_habilidades_fire_pool();
    }

    if (_tipo == PokemonTipo.WATER) {
        return pokemon_habilidades_water_pool();
    }

    if (_tipo == PokemonTipo.ELECTRIC) {
        return pokemon_habilidades_electric_pool();
    }

    if (_tipo == PokemonTipo.ICE) {
        return pokemon_habilidades_ice_pool();
    }

    if (_tipo == PokemonTipo.FIGHTING) {
        return pokemon_habilidades_fighting_pool();
    }

    if (_tipo == PokemonTipo.GROUND) {
        return pokemon_habilidades_ground_pool();
    }

    if (_tipo == PokemonTipo.ROCK) {
        return pokemon_habilidades_rock_pool();
    }

    if (_tipo == PokemonTipo.GHOST) {
        return pokemon_habilidades_ghost_pool();
    }

    if (_tipo == PokemonTipo.STEEL) {
        return pokemon_habilidades_steel_pool();
    }

    if (_tipo == PokemonTipo.DRAGON) {
        return pokemon_habilidades_dragon_pool();
    }

    if (_tipo == PokemonTipo.DARK) {
        return pokemon_habilidades_dark_pool();
    }

    if (_tipo == PokemonTipo.PSYCHIC) {
        return pokemon_habilidades_psychic_pool();
    }

    if (_tipo == PokemonTipo.FLYING) {
        return pokemon_habilidades_flying_pool();
    }

    if (_tipo == PokemonTipo.BUG) {
        return pokemon_habilidades_bug_pool();
    }

    if (_tipo == PokemonTipo.FAIRY) {
        return pokemon_habilidades_fairy_pool();
    }

    var _nome_tipo = pokemon_nome_tipo(_tipo);
    var _tag = pokemon_tag_por_tipo(_tipo);
    var _status = "";

    switch (_tipo) {
        case PokemonTipo.FIRE: _status = "Queimando"; break;
        case PokemonTipo.WATER: _status = "Molhado"; break;
        case PokemonTipo.ELECTRIC: _status = "Paralisado"; break;
        case PokemonTipo.ICE: _status = "Congelado"; break;
        default: _status = ""; break;
    }

    var _efeito = _status == "" ? "" : "aplicar_status:" + _status;
    var _combo = _status;

    return [
        new HabilidadeData("generic_" + _tag + "_hit", "Golpe " + _nome_tipo, _tipo, 1, 4.2, 34, ["single_target"], [], _efeito, ""),
        new HabilidadeData("generic_" + _tag + "_quick", "Ataque Rapido", PokemonTipo.NORMAL, 10, 3.4, 30, ["fast"], [], "", _combo),
        new HabilidadeData("generic_" + _tag + "_burst", "Rajada " + _nome_tipo, _tipo, 15, 6.2, 48, ["burst"], []),
        new HabilidadeData("generic_" + _tag + "_guard", "Instinto", PokemonTipo.NORMAL, 20, 10.0, 4, ["defense"], [])
    ];
}

function pokemon_habilidades_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.GRASS)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _grass_pool = pokemon_habilidades_grass_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.GRASS || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_grass = _grass_pool;

        if (_tipo1 != PokemonTipo.GRASS && _tipo1 != PokemonTipo.NONE) {
            _pool_grass = pokemon_skill_pool_mesclar(_pool_grass, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.GRASS && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_grass = pokemon_skill_pool_mesclar(_pool_grass, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_grass;
    }

    var _pool;

    if (_tipo_inicial == PokemonTipo.POISON) {
        _pool = pokemon_habilidades_poison_por_arquetipo(pokemon_poison_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.FIGHTING) {
        _pool = pokemon_habilidades_fighting_por_arquetipo(pokemon_fighting_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.GROUND) {
        _pool = pokemon_habilidades_ground_por_arquetipo(pokemon_ground_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.ROCK) {
        _pool = pokemon_habilidades_rock_por_arquetipo(pokemon_rock_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.GHOST) {
        _pool = pokemon_habilidades_ghost_por_arquetipo(pokemon_ghost_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.STEEL) {
        _pool = pokemon_habilidades_steel_por_arquetipo(pokemon_steel_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.DRAGON) {
        _pool = pokemon_habilidades_dragon_por_arquetipo(pokemon_dragon_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.DARK) {
        _pool = pokemon_habilidades_dark_por_arquetipo(pokemon_dark_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.FLYING) {
        _pool = pokemon_habilidades_flying_por_arquetipo(pokemon_flying_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.PSYCHIC) {
        _pool = pokemon_habilidades_psychic_por_arquetipo(pokemon_psychic_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.BUG) {
        _pool = pokemon_habilidades_bug_por_arquetipo(pokemon_bug_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.FAIRY) {
        _pool = pokemon_habilidades_fairy_por_arquetipo(pokemon_fairy_arquetipo_por_grass_perfil(_arquetipo));
    } else if (_tipo_inicial == PokemonTipo.NORMAL) {
        _pool = pokemon_habilidades_normal_por_arquetipo(pokemon_normal_arquetipo_por_grass_perfil(_arquetipo));
    } else {
        _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    }

    _pool = pokemon_skill_pool_mesclar(_pool, _grass_pool, true);
    return _pool;
}

function pokemon_habilidades_poison_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.POISON)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _poison_pool = pokemon_habilidades_poison_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.POISON || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_poison = _poison_pool;

        if (_tipo1 != PokemonTipo.POISON && _tipo1 != PokemonTipo.NONE) {
            _pool_poison = pokemon_skill_pool_mesclar(_pool_poison, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.POISON && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_poison = pokemon_skill_pool_mesclar(_pool_poison, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_poison;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _poison_pool, true);
    return _pool;
}

function pokemon_habilidades_fire_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.FIRE)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _fire_pool = pokemon_habilidades_fire_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.FIRE || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_fire = _fire_pool;

        if (_tipo1 != PokemonTipo.FIRE && _tipo1 != PokemonTipo.NONE) {
            _pool_fire = pokemon_skill_pool_mesclar(_pool_fire, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.FIRE && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_fire = pokemon_skill_pool_mesclar(_pool_fire, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_fire;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _fire_pool, true);
    return _pool;
}

function pokemon_habilidades_water_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.WATER)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _water_pool = pokemon_habilidades_water_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.WATER || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_water = _water_pool;

        if (_tipo1 != PokemonTipo.WATER && _tipo1 != PokemonTipo.NONE) {
            _pool_water = pokemon_skill_pool_mesclar(_pool_water, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.WATER && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_water = pokemon_skill_pool_mesclar(_pool_water, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_water;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _water_pool, true);
    return _pool;
}

function pokemon_habilidades_electric_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.ELECTRIC)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _electric_pool = pokemon_habilidades_electric_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.ELECTRIC || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_electric = _electric_pool;

        if (_tipo1 != PokemonTipo.ELECTRIC && _tipo1 != PokemonTipo.NONE) {
            _pool_electric = pokemon_skill_pool_mesclar(_pool_electric, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.ELECTRIC && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_electric = pokemon_skill_pool_mesclar(_pool_electric, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_electric;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _electric_pool, true);
    return _pool;
}

function pokemon_habilidades_ice_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.ICE)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _ice_pool = pokemon_habilidades_ice_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.ICE || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_ice = _ice_pool;

        if (_tipo1 != PokemonTipo.ICE && _tipo1 != PokemonTipo.NONE) {
            _pool_ice = pokemon_skill_pool_mesclar(_pool_ice, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.ICE && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_ice = pokemon_skill_pool_mesclar(_pool_ice, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_ice;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _ice_pool, true);
    return _pool;
}

function pokemon_habilidades_fighting_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.FIGHTING)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _fighting_pool = pokemon_habilidades_fighting_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.FIGHTING || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_fighting = _fighting_pool;

        if (_tipo1 != PokemonTipo.FIGHTING && _tipo1 != PokemonTipo.NONE) {
            _pool_fighting = pokemon_skill_pool_mesclar(_pool_fighting, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.FIGHTING && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_fighting = pokemon_skill_pool_mesclar(_pool_fighting, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_fighting;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _fighting_pool, true);
    return _pool;
}

function pokemon_habilidades_ground_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.GROUND)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _ground_pool = pokemon_habilidades_ground_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.GROUND || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_ground = _ground_pool;

        if (_tipo1 != PokemonTipo.GROUND && _tipo1 != PokemonTipo.NONE) {
            _pool_ground = pokemon_skill_pool_mesclar(_pool_ground, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.GROUND && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_ground = pokemon_skill_pool_mesclar(_pool_ground, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_ground;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _ground_pool, true);
    return _pool;
}

function pokemon_habilidades_flying_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.FLYING)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _flying_pool = pokemon_habilidades_flying_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.FLYING || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_flying = _flying_pool;

        if (_tipo1 != PokemonTipo.FLYING && _tipo1 != PokemonTipo.NONE) {
            _pool_flying = pokemon_skill_pool_mesclar(_pool_flying, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.FLYING && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_flying = pokemon_skill_pool_mesclar(_pool_flying, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_flying;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _flying_pool, true);
    return _pool;
}

function pokemon_habilidades_psychic_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.PSYCHIC)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _psychic_pool = pokemon_habilidades_psychic_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.PSYCHIC || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_psychic = _psychic_pool;

        if (_tipo1 != PokemonTipo.PSYCHIC && _tipo1 != PokemonTipo.NONE) {
            _pool_psychic = pokemon_skill_pool_mesclar(_pool_psychic, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.PSYCHIC && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_psychic = pokemon_skill_pool_mesclar(_pool_psychic, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_psychic;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _psychic_pool, true);
    return _pool;
}

function pokemon_habilidades_bug_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.BUG)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _bug_pool = pokemon_habilidades_bug_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.BUG || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_bug = _bug_pool;

        if (_tipo1 != PokemonTipo.BUG && _tipo1 != PokemonTipo.NONE) {
            _pool_bug = pokemon_skill_pool_mesclar(_pool_bug, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.BUG && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_bug = pokemon_skill_pool_mesclar(_pool_bug, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_bug;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _bug_pool, true);
    return _pool;
}

function pokemon_habilidades_rock_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.ROCK)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _rock_pool = pokemon_habilidades_rock_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.ROCK || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_rock = _rock_pool;

        if (_tipo1 != PokemonTipo.ROCK && _tipo1 != PokemonTipo.NONE) {
            _pool_rock = pokemon_skill_pool_mesclar(_pool_rock, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.ROCK && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_rock = pokemon_skill_pool_mesclar(_pool_rock, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_rock;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _rock_pool, true);
    return _pool;
}

function pokemon_habilidades_ghost_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.GHOST)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _ghost_pool = pokemon_habilidades_ghost_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.GHOST || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_ghost = _ghost_pool;

        if (_tipo1 != PokemonTipo.GHOST && _tipo1 != PokemonTipo.NONE) {
            _pool_ghost = pokemon_skill_pool_mesclar(_pool_ghost, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.GHOST && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_ghost = pokemon_skill_pool_mesclar(_pool_ghost, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_ghost;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _ghost_pool, true);
    return _pool;
}

function pokemon_habilidades_dragon_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.DRAGON)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _dragon_pool = pokemon_habilidades_dragon_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.DRAGON || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_dragon = _dragon_pool;

        if (_tipo1 != PokemonTipo.DRAGON && _tipo1 != PokemonTipo.NONE) {
            _pool_dragon = pokemon_skill_pool_mesclar(_pool_dragon, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.DRAGON && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_dragon = pokemon_skill_pool_mesclar(_pool_dragon, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_dragon;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _dragon_pool, true);
    return _pool;
}

function pokemon_habilidades_steel_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.STEEL)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _steel_pool = pokemon_habilidades_steel_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.STEEL || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_steel = _steel_pool;

        if (_tipo1 != PokemonTipo.STEEL && _tipo1 != PokemonTipo.NONE) {
            _pool_steel = pokemon_skill_pool_mesclar(_pool_steel, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.STEEL && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_steel = pokemon_skill_pool_mesclar(_pool_steel, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_steel;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _steel_pool, true);
    return _pool;
}

function pokemon_habilidades_dark_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.DARK)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _dark_pool = pokemon_habilidades_dark_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.DARK || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_dark = _dark_pool;

        if (_tipo1 != PokemonTipo.DARK && _tipo1 != PokemonTipo.NONE) {
            _pool_dark = pokemon_skill_pool_mesclar(_pool_dark, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.DARK && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_dark = pokemon_skill_pool_mesclar(_pool_dark, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_dark;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _dark_pool, true);
    return _pool;
}

function pokemon_habilidades_fairy_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.FAIRY)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _fairy_pool = pokemon_habilidades_fairy_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.FAIRY || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_fairy = _fairy_pool;

        if (_tipo1 != PokemonTipo.FAIRY && _tipo1 != PokemonTipo.NONE) {
            _pool_fairy = pokemon_skill_pool_mesclar(_pool_fairy, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.FAIRY && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_fairy = pokemon_skill_pool_mesclar(_pool_fairy, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_fairy;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _fairy_pool, true);
    return _pool;
}

function pokemon_habilidades_normal_por_perfil(_tipo1, _tipo2, _arquetipo, _tipo_inicial) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.NORMAL)) {
        return pokemon_habilidades_por_tipos(_tipo1, _tipo2);
    }

    var _normal_pool = pokemon_habilidades_normal_por_arquetipo(_arquetipo);

    if (_tipo_inicial == PokemonTipo.NORMAL || _tipo_inicial == PokemonTipo.NONE) {
        var _pool_normal = _normal_pool;

        if (_tipo1 != PokemonTipo.NORMAL && _tipo1 != PokemonTipo.NONE) {
            _pool_normal = pokemon_skill_pool_mesclar(_pool_normal, pokemon_habilidades_genericas_por_tipo(_tipo1), true);
        }

        if (_tipo2 != PokemonTipo.NORMAL && _tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
            _pool_normal = pokemon_skill_pool_mesclar(_pool_normal, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
        }

        return _pool_normal;
    }

    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo_inicial);
    _pool = pokemon_skill_pool_mesclar(_pool, _normal_pool, true);
    return _pool;
}

function pokemon_habilidades_por_tipos(_tipo1, _tipo2) {
    var _pool = pokemon_habilidades_genericas_por_tipo(_tipo1);

    if (_tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
        _pool = pokemon_skill_pool_mesclar(_pool, pokemon_habilidades_genericas_por_tipo(_tipo2), true);
    }

    return _pool;
}

function pokemon_db_tipo_sugerido(_pokemon_id) {
    var _cycle = [
        PokemonTipo.NORMAL, PokemonTipo.GRASS, PokemonTipo.BUG, PokemonTipo.FLYING,
        PokemonTipo.POISON, PokemonTipo.WATER, PokemonTipo.GROUND, PokemonTipo.ROCK,
        PokemonTipo.FIRE, PokemonTipo.ELECTRIC, PokemonTipo.PSYCHIC, PokemonTipo.FIGHTING,
        PokemonTipo.ICE, PokemonTipo.GHOST, PokemonTipo.DRAGON, PokemonTipo.DARK,
        PokemonTipo.STEEL, PokemonTipo.FAIRY
    ];

    return _cycle[(_pokemon_id - 1) mod array_length(_cycle)];
}

function pokemon_birth_tags_por_tipo(_tipo) {
    var _tag = pokemon_tag_por_tipo(_tipo);
    var _tags = [_tag];

    switch (_tipo) {
        case PokemonTipo.NORMAL:
            array_push(_tags, "fazenda");
            break;
        case PokemonTipo.GRASS:
            array_push(_tags, "fazenda");
            break;
        case PokemonTipo.ROCK:
            array_push(_tags, "caverna");
            break;
        case PokemonTipo.GHOST:
            array_push(_tags, "fantasma");
            array_push(_tags, "noturno");
            break;
        case PokemonTipo.GROUND:
            array_push(_tags, "terra");
            break;
        case PokemonTipo.FLYING:
            array_push(_tags, "voador");
            break;
        case PokemonTipo.BUG:
            array_push(_tags, "floresta");
            array_push(_tags, "grama");
            break;
        case PokemonTipo.DRAGON:
            array_push(_tags, "dragao");
            array_push(_tags, "caverna");
            break;
        case PokemonTipo.DARK:
            array_push(_tags, "noturno");
            array_push(_tags, "fantasma");
            break;
        case PokemonTipo.STEEL:
            array_push(_tags, "aco");
            array_push(_tags, "caverna");
            break;
    }

    return _tags;
}

function pokemon_array_push_unico(_array, _valor) {
    for (var _i = 0; _i < array_length(_array); _i += 1) {
        if (_array[_i] == _valor) {
            return _array;
        }
    }

    array_push(_array, _valor);
    return _array;
}

function pokemon_birth_tags_por_tipos(_tipo1, _tipo2) {
    var _tags = [];
    var _primarias = pokemon_birth_tags_por_tipo(_tipo1);

    for (var _i = 0; _i < array_length(_primarias); _i += 1) {
        _tags = pokemon_array_push_unico(_tags, _primarias[_i]);
    }

    if (_tipo2 != PokemonTipo.NONE && _tipo2 != _tipo1) {
        var _secundarias = pokemon_birth_tags_por_tipo(_tipo2);

        for (var _j = 0; _j < array_length(_secundarias); _j += 1) {
            _tags = pokemon_array_push_unico(_tags, _secundarias[_j]);
        }
    }

    return _tags;
}

function pokemon_tem_tipo(_tipo1, _tipo2, _tipo_busca) {
    return _tipo1 == _tipo_busca || _tipo2 == _tipo_busca;
}

function PokemonGrassPerfil(_arquetipo, _tipo_inicial, _hp_mul, _attack_mul, _defense_mul, _speed_mul, _growth_hp_mul, _growth_attack_mul, _growth_defense_mul, _growth_speed_mul) constructor {
    Arquetipo = _arquetipo;
    TipoInicial = _tipo_inicial;
    HpMul = _hp_mul;
    AttackMul = _attack_mul;
    DefenseMul = _defense_mul;
    SpeedMul = _speed_mul;
    GrowthHpMul = _growth_hp_mul;
    GrowthAttackMul = _growth_attack_mul;
    GrowthDefenseMul = _growth_defense_mul;
    GrowthSpeedMul = _growth_speed_mul;
}

function PokemonPoisonPerfil(_arquetipo, _tipo_inicial, _hp_mul, _attack_mul, _defense_mul, _speed_mul, _growth_hp_mul, _growth_attack_mul, _growth_defense_mul, _growth_speed_mul) constructor {
    Arquetipo = _arquetipo;
    TipoInicial = _tipo_inicial;
    HpMul = _hp_mul;
    AttackMul = _attack_mul;
    DefenseMul = _defense_mul;
    SpeedMul = _speed_mul;
    GrowthHpMul = _growth_hp_mul;
    GrowthAttackMul = _growth_attack_mul;
    GrowthDefenseMul = _growth_defense_mul;
    GrowthSpeedMul = _growth_speed_mul;
}

function PokemonTypePerfil(_arquetipo, _tipo_inicial, _hp_mul, _attack_mul, _defense_mul, _speed_mul, _growth_hp_mul, _growth_attack_mul, _growth_defense_mul, _growth_speed_mul) constructor {
    Arquetipo = _arquetipo;
    TipoInicial = _tipo_inicial;
    HpMul = _hp_mul;
    AttackMul = _attack_mul;
    DefenseMul = _defense_mul;
    SpeedMul = _speed_mul;
    GrowthHpMul = _growth_hp_mul;
    GrowthAttackMul = _growth_attack_mul;
    GrowthDefenseMul = _growth_defense_mul;
    GrowthSpeedMul = _growth_speed_mul;
}

function pokemon_poison_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Veneno Agressivo": return "Toxina Autodestrutiva";
        case "Veneno Dormente": return "Corrosao Organica";
        case "Veneno Floral": return "Peste Gradual";
        case "Parasita Parrudo": return "Peste Gradual";
    }

    return "Peste Gradual";
}

function pokemon_fighting_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Lutador Natural": return "Quebra-Guarda";
        case "Florescencia Critica": return "Impeto Ofensivo";
    }

    return "Impeto Ofensivo";
}

function pokemon_ground_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Colosso Solar": return "Barreira de Lama";
        case "Raiz Pesada": return "Barreira de Lama";
        case "Rocha Solar": return "Desabamento";
    }

    return "Areia Movedica";
}

function pokemon_rock_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Rocha Solar": return "Casca de Rocha";
        case "Colosso Solar": return "Casca de Rocha";
        case "Raiz Pesada": return "Casca de Rocha";
        case "Florescencia Critica": return "Fragmentacao";
    }

    return "Fragmentacao";
}

function pokemon_ghost_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Parasita": return "Dreno de Essencia";
        case "Parasita Parrudo": return "Dreno de Essencia";
        case "Florescencia Critica": return "Intangibilidade";
    }

    return "Assombracao";
}

function pokemon_flying_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Florescencia Critica": return "Vento de Cauda";
        case "Energia Solar": return "Vento de Cauda";
        case "Parasita": return "Turbulencia";
    }

    return "Vento de Cauda";
}

function pokemon_psychic_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Energia Solar": return "Inversao Espacial";
        case "Parasita Parrudo": return "Escudo Cinetico";
        case "Parasita": return "Paralisia Mental";
    }

    return "Inversao Espacial";
}

function pokemon_bug_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Inseto de Pressao": return "Fio de Seda";
        case "Florescencia Critica": return "Tatica de Enxame";
        case "Energia Solar": return "Casulo Rigido";
        case "Parasita Parrudo": return "Casulo Rigido";
        case "Parasita": return "Fio de Seda";
    }

    return "Fio de Seda";
}

function pokemon_dragon_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Florescencia Critica": return "Furia Draconica";
        case "Energia Solar": return "Escama Imperial";
        case "Colosso Solar": return "Escama Imperial";
        case "Parasita Parrudo": return "Escama Imperial";
    }

    return "Escama Imperial";
}

function pokemon_steel_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Casca de Espinhos": return "Espinhos de Ferro";
        case "Colosso Solar": return "Fortificacao Rigida";
        case "Raiz Pesada": return "Fortificacao Rigida";
        case "Florescencia Critica": return "Impacto Pesado";
    }

    return "Espinhos de Ferro";
}

function pokemon_dark_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Florescencia Critica": return "Golpe Baixo";
        case "Veneno Agressivo": return "Golpe Traicoeiro";
        case "Veneno Dormente": return "Golpe Traicoeiro";
        case "Parasita": return "Copia Sombria";
        case "Parasita Parrudo": return "Copia Sombria";
    }

    return "Golpe Traicoeiro";
}

function pokemon_fairy_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Florescencia Critica": return "Encantamento de Carga";
        case "Energia Solar": return "Luz Purificadora";
        case "Colosso Solar": return "Luz Purificadora";
        case "Parasita Parrudo": return "Luz Purificadora";
        case "Parasita": return "Aura Mistica";
    }

    return "Aura Mistica";
}

function pokemon_normal_arquetipo_por_grass_perfil(_arquetipo_grass) {
    switch (_arquetipo_grass) {
        case "Florescencia Critica": return "Forca Neutra";
        case "Energia Solar": return "Legado";
        case "Parasita Parrudo": return "Estocar";
        case "Raiz Pesada": return "Estocar";
    }

    return "Forca Neutra";
}

function pokemon_poison_passivas_aplicar(_pokemon_data, _arquetipo_poison) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.PoisonArquetipo = _arquetipo_poison;

    switch (_arquetipo_poison) {
        case "Toxina Autodestrutiva":
            _pokemon_data.Passiva1Nome = "Sangue Caustico";
            _pokemon_data.Passiva1Descricao = "Habilidades de sacrificio convertem HP em picos de dano.";
            _pokemon_data.Passiva2Nome = "Surto Terminal";
            _pokemon_data.Passiva2Descricao = "Quando esta ferido, o monstro prioriza golpes toxicos de alto impacto.";
            break;

        case "Corrosao Organica":
            _pokemon_data.Passiva1Nome = "Pele Acida";
            _pokemon_data.Passiva1Descricao = "Corroendo reduz a defesa efetiva do alvo durante o combate.";
            _pokemon_data.Passiva2Nome = "Nuvem Organica";
            _pokemon_data.Passiva2Descricao = "Alvos corroidos ou vulneraveis alimentam finalizadores toxicos.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Fermentacao Toxica";
            _pokemon_data.Passiva1Descricao = "Envenenado acumula stacks e causa dano por tempo.";
            _pokemon_data.Passiva2Nome = "Peste Terminal";
            _pokemon_data.Passiva2Descricao = "Finalizadores ganham valor contra alvos ja envenenados.";
            break;
    }
}

function pokemon_fairy_passivas_aplicar(_pokemon_data, _arquetipo_fairy) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.FairyArquetipo = _arquetipo_fairy;

    switch (_arquetipo_fairy) {
        case "Encantamento de Carga":
            _pokemon_data.Passiva1Nome = "Carga Feerica";
            _pokemon_data.Passiva1Descricao = "Encanto Carga cria janelas curtas de burst sem depender de quatro habilidades.";
            _pokemon_data.Passiva2Nome = "Brilho de Ruptura";
            _pokemon_data.Passiva2Descricao = "Brilho Ofuscante conversa com controle eletrico, psiquico e sombrio.";
            break;

        case "Luz Purificadora":
            _pokemon_data.Passiva1Nome = "Pulso Purificador";
            _pokemon_data.Passiva1Descricao = "Luz Purificadora e Barreira Fada seguram veneno, queimadura e lutas longas.";
            _pokemon_data.Passiva2Nome = "Bencao Serena";
            _pokemon_data.Passiva2Descricao = "Pequenas curas tornam builds de atrito mais justas sem virar imortalidade.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Aura Mistica";
            _pokemon_data.Passiva1Descricao = "Auras leves melhoram rotacoes hibridas de Fada com Psiquico, Voador e Grama.";
            _pokemon_data.Passiva2Nome = "Charme de Fenda";
            _pokemon_data.Passiva2Descricao = "Charme e Ofuscado reduzem pressao inimiga e abrem combos seguros.";
            break;
    }
}

function pokemon_normal_passivas_aplicar(_pokemon_data, _arquetipo_normal) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.NormalArquetipo = _arquetipo_normal;

    switch (_arquetipo_normal) {
        case "Estocar":
            _pokemon_data.Passiva1Nome = "Reserva Defensiva";
            _pokemon_data.Passiva1Descricao = "Estoque Defensivo aumenta resistencia e prepara Liberar sem dano explosivo injusto.";
            _pokemon_data.Passiva2Nome = "Corpo Guardado";
            _pokemon_data.Passiva2Descricao = "Monstros parrudos convertem tempo de luta em finalizadores moderados.";
            break;

        case "Legado":
            _pokemon_data.Passiva1Nome = "Instinto Adaptavel";
            _pokemon_data.Passiva1Descricao = "Mimetismo Ativo ajuda o monstro a sobreviver contra rotas variadas.";
            _pokemon_data.Passiva2Nome = "Ritmo Herdado";
            _pokemon_data.Passiva2Descricao = "Legado e Reciclagem mantem utilidade mesmo quando a build veio estranha.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Forca Neutra";
            _pokemon_data.Passiva1Descricao = "Golpes normais mantem dano confiavel e cooldowns curtos.";
            _pokemon_data.Passiva2Nome = "Ritmo Constante";
            _pokemon_data.Passiva2Descricao = "Velocidade e dano medio criam uma base boa para qualquer segundo tipo.";
            break;
    }
}

function pokemon_grass_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.GRASS)) {
        return undefined;
    }

    if (_hp + _defense >= 170 || _defense >= 105) {
        return new PokemonGrassPerfil("Energia Solar", PokemonTipo.GRASS, 1.10, 0.94, 1.12, 0.90, 1.10, 0.94, 1.10, 0.92);
    }

    if (_speed >= 85 || _attack >= 90) {
        return new PokemonGrassPerfil("Florescencia Critica", PokemonTipo.GRASS, 0.94, 1.06, 0.94, 1.10, 0.94, 1.06, 0.94, 1.08);
    }

    return new PokemonGrassPerfil("Parasita", PokemonTipo.GRASS, 1.04, 0.98, 1.04, 0.94, 1.04, 0.98, 1.04, 0.94);
}

function pokemon_grass_perfil_aplicar(_pokemon_data, _perfil) {
    if (!is_struct(_pokemon_data) || !is_struct(_perfil)) {
        return;
    }

    _pokemon_data.HpMax = max(20, round(_pokemon_data.HpMax * _perfil.HpMul));
    _pokemon_data.Attack = max(15, round(_pokemon_data.Attack * _perfil.AttackMul));
    _pokemon_data.Defense = max(15, round(_pokemon_data.Defense * _perfil.DefenseMul));
    _pokemon_data.Speed = max(10, round(_pokemon_data.Speed * _perfil.SpeedMul));
    _pokemon_data.GrowthHp = max(0.8, _pokemon_data.GrowthHp * _perfil.GrowthHpMul);
    _pokemon_data.GrowthAttack = max(0.8, _pokemon_data.GrowthAttack * _perfil.GrowthAttackMul);
    _pokemon_data.GrowthDefense = max(0.8, _pokemon_data.GrowthDefense * _perfil.GrowthDefenseMul);
    _pokemon_data.GrowthSpeed = max(0.8, _pokemon_data.GrowthSpeed * _perfil.GrowthSpeedMul);
    _pokemon_data.Arquetipo = _perfil.Arquetipo;
    _pokemon_data.TipoInicial = _perfil.TipoInicial;
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);

    if (pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.POISON)) {
        pokemon_poison_passivas_aplicar(_pokemon_data, pokemon_poison_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.FIGHTING && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.FIGHTING)) {
        pokemon_fighting_passivas_aplicar(_pokemon_data, pokemon_fighting_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.GROUND && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.GROUND)) {
        pokemon_ground_passivas_aplicar(_pokemon_data, pokemon_ground_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.ROCK && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.ROCK)) {
        pokemon_rock_passivas_aplicar(_pokemon_data, pokemon_rock_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.GHOST && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.GHOST)) {
        pokemon_ghost_passivas_aplicar(_pokemon_data, pokemon_ghost_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.STEEL && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.STEEL)) {
        pokemon_steel_passivas_aplicar(_pokemon_data, pokemon_steel_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.DRAGON && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.DRAGON)) {
        pokemon_dragon_passivas_aplicar(_pokemon_data, pokemon_dragon_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.FLYING && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.FLYING)) {
        pokemon_flying_passivas_aplicar(_pokemon_data, pokemon_flying_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.PSYCHIC && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.PSYCHIC)) {
        pokemon_psychic_passivas_aplicar(_pokemon_data, pokemon_psychic_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.BUG && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.BUG)) {
        pokemon_bug_passivas_aplicar(_pokemon_data, pokemon_bug_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.DARK && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.DARK)) {
        pokemon_dark_passivas_aplicar(_pokemon_data, pokemon_dark_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.FAIRY && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.FAIRY)) {
        pokemon_fairy_passivas_aplicar(_pokemon_data, pokemon_fairy_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }

    if (_perfil.TipoInicial == PokemonTipo.NORMAL && pokemon_tem_tipo(_pokemon_data.Tipo1, _pokemon_data.Tipo2, PokemonTipo.NORMAL)) {
        pokemon_normal_passivas_aplicar(_pokemon_data, pokemon_normal_arquetipo_por_grass_perfil(_perfil.Arquetipo));
    }
}

function pokemon_poison_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.POISON)) {
        return undefined;
    }

    if (pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.GHOST)) {
        return undefined;
    }

    if (_hp + _defense >= 165 || _defense >= 95) {
        return new PokemonPoisonPerfil("Corrosao Organica", PokemonTipo.POISON, 1.10, 0.94, 1.12, 0.84, 1.10, 0.94, 1.10, 0.86);
    }

    if (_attack >= 90 || _speed >= 90) {
        return new PokemonPoisonPerfil("Toxina Autodestrutiva", PokemonTipo.POISON, 0.94, 1.10, 0.92, 1.08, 0.94, 1.10, 0.92, 1.06);
    }

    return new PokemonPoisonPerfil("Peste Gradual", PokemonTipo.POISON, 1.02, 0.98, 1.00, 1.04, 1.02, 0.98, 1.00, 1.04);
}

function pokemon_poison_perfil_aplicar(_pokemon_data, _perfil) {
    if (!is_struct(_pokemon_data) || !is_struct(_perfil)) {
        return;
    }

    _pokemon_data.HpMax = max(20, round(_pokemon_data.HpMax * _perfil.HpMul));
    _pokemon_data.Attack = max(15, round(_pokemon_data.Attack * _perfil.AttackMul));
    _pokemon_data.Defense = max(15, round(_pokemon_data.Defense * _perfil.DefenseMul));
    _pokemon_data.Speed = max(10, round(_pokemon_data.Speed * _perfil.SpeedMul));
    _pokemon_data.GrowthHp = max(0.8, _pokemon_data.GrowthHp * _perfil.GrowthHpMul);
    _pokemon_data.GrowthAttack = max(0.8, _pokemon_data.GrowthAttack * _perfil.GrowthAttackMul);
    _pokemon_data.GrowthDefense = max(0.8, _pokemon_data.GrowthDefense * _perfil.GrowthDefenseMul);
    _pokemon_data.GrowthSpeed = max(0.8, _pokemon_data.GrowthSpeed * _perfil.GrowthSpeedMul);
    _pokemon_data.Arquetipo = _perfil.Arquetipo;
    _pokemon_data.TipoInicial = _perfil.TipoInicial;
    pokemon_poison_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_poison_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil) {
    if (!is_struct(_pokemon_data) || !is_struct(_perfil)) {
        return false;
    }

    _pokemon_data.HpMax = max(20, round(_pokemon_data.HpMax * _perfil.HpMul));
    _pokemon_data.Attack = max(15, round(_pokemon_data.Attack * _perfil.AttackMul));
    _pokemon_data.Defense = max(15, round(_pokemon_data.Defense * _perfil.DefenseMul));
    _pokemon_data.Speed = max(10, round(_pokemon_data.Speed * _perfil.SpeedMul));
    _pokemon_data.GrowthHp = max(0.8, _pokemon_data.GrowthHp * _perfil.GrowthHpMul);
    _pokemon_data.GrowthAttack = max(0.8, _pokemon_data.GrowthAttack * _perfil.GrowthAttackMul);
    _pokemon_data.GrowthDefense = max(0.8, _pokemon_data.GrowthDefense * _perfil.GrowthDefenseMul);
    _pokemon_data.GrowthSpeed = max(0.8, _pokemon_data.GrowthSpeed * _perfil.GrowthSpeedMul);
    _pokemon_data.Arquetipo = _perfil.Arquetipo;
    _pokemon_data.TipoInicial = _perfil.TipoInicial;
    return true;
}

function pokemon_fire_passivas_aplicar(_pokemon_data, _arquetipo_fire) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.FireArquetipo = _arquetipo_fire;

    switch (_arquetipo_fire) {
        case "Explosao Termica":
            _pokemon_data.Passiva1Nome = "Calor Concentrado";
            _pokemon_data.Passiva1Descricao = "Preparos de fogo aumentam o valor dos proximos golpes pesados.";
            _pokemon_data.Passiva2Nome = "Pavio Curto";
            _pokemon_data.Passiva2Descricao = "Finalizadores de fogo aproveitam melhor alvos queimando ou com defesa derretida.";
            break;

        case "Fenix Veloz":
            _pokemon_data.Passiva1Nome = "Chama de Retorno";
            _pokemon_data.Passiva1Descricao = "Buffs de Fenix favorecem rotacoes rapidas e golpes em sequencia.";
            _pokemon_data.Passiva2Nome = "Passo Incandescente";
            _pokemon_data.Passiva2Descricao = "A velocidade alta transforma cooldown curto em pressao constante.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Brasas Persistentes";
            _pokemon_data.Passiva1Descricao = "Queimando e Armadura Derretida deixam o alvo vulneravel a combos.";
            _pokemon_data.Passiva2Nome = "Forno Aberto";
            _pokemon_data.Passiva2Descricao = "Dano de fogo conversa melhor com Corroendo e outros debuffs defensivos.";
            break;
    }
}

function pokemon_water_passivas_aplicar(_pokemon_data, _arquetipo_water) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.WaterArquetipo = _arquetipo_water;

    switch (_arquetipo_water) {
        case "Mare Protelatoria":
            _pokemon_data.Passiva1Nome = "Pressao de Mare";
            _pokemon_data.Passiva1Descricao = "Habilidades de agua atrasam cooldowns e compram tempo para a equipe.";
            _pokemon_data.Passiva2Nome = "Nevoa Tardia";
            _pokemon_data.Passiva2Descricao = "Alvos molhados ou lentos sofrem mais em lutas longas.";
            break;

        case "Pressao Hidraulica":
            _pokemon_data.Passiva1Nome = "Carga Hidraulica";
            _pokemon_data.Passiva1Descricao = "Golpes fortes causam mais dano quando o alvo esta com cooldowns carregados.";
            _pokemon_data.Passiva2Nome = "Impacto de Ressaca";
            _pokemon_data.Passiva2Descricao = "Molhado prepara finalizadores pesados sem dobrar dano demais.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Ritmo de Correnteza";
            _pokemon_data.Passiva1Descricao = "Fluxo Acelerado reduz cooldowns e cria rotacoes muito constantes.";
            _pokemon_data.Passiva2Nome = "Retorno Liquido";
            _pokemon_data.Passiva2Descricao = "Aceleracoes de agua ajudam builds hibridas a manter dois tipos ativos.";
            break;
    }
}

function pokemon_electric_passivas_aplicar(_pokemon_data, _arquetipo_electric) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.ElectricArquetipo = _arquetipo_electric;

    switch (_arquetipo_electric) {
        case "Curto-Circuito":
            _pokemon_data.Passiva1Nome = "Circuito Instavel";
            _pokemon_data.Passiva1Descricao = "Ofuscado pode fazer o alvo desperdicar o proximo golpe.";
            _pokemon_data.Passiva2Nome = "Erro Punido";
            _pokemon_data.Passiva2Descricao = "Inimigos que erram viram alvo de combos eletricos.";
            break;

        case "Estatica Veloz":
            _pokemon_data.Passiva1Nome = "Pele Estatica";
            _pokemon_data.Passiva1Descricao = "Estatica Ativa acelera a rotacao das habilidades.";
            _pokemon_data.Passiva2Nome = "Voltagem Continua";
            _pokemon_data.Passiva2Descricao = "Velocidade alta transforma golpes pequenos em pressao constante.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Carga Acumulada";
            _pokemon_data.Passiva1Descricao = "Sobrecarregado prepara golpes eletricos mais fortes.";
            _pokemon_data.Passiva2Nome = "Condutor Natural";
            _pokemon_data.Passiva2Descricao = "Molhado e Enraizado ajudam eletrico a encaixar finalizadores.";
            break;
    }
}

function pokemon_ice_passivas_aplicar(_pokemon_data, _arquetipo_ice) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.IceArquetipo = _arquetipo_ice;

    switch (_arquetipo_ice) {
        case "Estilhacar":
            _pokemon_data.Passiva1Nome = "Gelo Fino";
            _pokemon_data.Passiva1Descricao = "Fragil prepara golpes de estouro sem dobrar dano demais.";
            _pokemon_data.Passiva2Nome = "Quebra Precisa";
            _pokemon_data.Passiva2Descricao = "Alvos gelados ou com HP baixo sofrem finalizadores melhores.";
            break;

        case "Manto de Gelo":
            _pokemon_data.Passiva1Nome = "Casca Glacial";
            _pokemon_data.Passiva1Descricao = "Manto de Gelo aumenta a resistencia e sustenta lutas longas.";
            _pokemon_data.Passiva2Nome = "Avalanche Lenta";
            _pokemon_data.Passiva2Descricao = "Defesa alta vira janela de contra-ataque gelado.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Geada Acumulada";
            _pokemon_data.Passiva1Descricao = "Gelado e Congelando reduzem o ritmo do alvo.";
            _pokemon_data.Passiva2Nome = "Frio Progressivo";
            _pokemon_data.Passiva2Descricao = "Controle de gelo combina bem com veneno, grama e agua.";
            break;
    }
}

function pokemon_fighting_passivas_aplicar(_pokemon_data, _arquetipo_fighting) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.FightingArquetipo = _arquetipo_fighting;

    switch (_arquetipo_fighting) {
        case "Quebra-Guarda":
            _pokemon_data.Passiva1Nome = "Leitura de Postura";
            _pokemon_data.Passiva1Descricao = "Postura Quebrada reduz a defesa efetiva e abre janelas para finalizadores.";
            _pokemon_data.Passiva2Nome = "Ruptura Marcial";
            _pokemon_data.Passiva2Descricao = "Golpes pesados de lutador conversam com Corroendo, Vulneravel e Armadura Derretida.";
            break;

        case "Espirito de Luta":
            _pokemon_data.Passiva1Nome = "Folego Teimoso";
            _pokemon_data.Passiva1Descricao = "Quanto menor o HP, melhor ficam golpes de sustentacao e contra-ataque.";
            _pokemon_data.Passiva2Nome = "Punho Resoluto";
            _pokemon_data.Passiva2Descricao = "Espirito de Luta transforma lutas longas em recuperacao e dano moderado.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Impeto Ofensivo";
            _pokemon_data.Passiva1Descricao = "Sequencias rapidas acumulam pressao sem depender de um unico golpe gigante.";
            _pokemon_data.Passiva2Nome = "Ritmo de Combo";
            _pokemon_data.Passiva2Descricao = "A rotacao melhora quando o alvo esta preso, lento ou com postura quebrada.";
            break;
    }
}

function pokemon_ground_passivas_aplicar(_pokemon_data, _arquetipo_ground) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.GroundArquetipo = _arquetipo_ground;

    switch (_arquetipo_ground) {
        case "Barreira de Lama":
            _pokemon_data.Passiva1Nome = "Casca de Barro";
            _pokemon_data.Passiva1Descricao = "Barreira de Lama aumenta a resistencia e segura rotas longas.";
            _pokemon_data.Passiva2Nome = "Base Aterrada";
            _pokemon_data.Passiva2Descricao = "Aterrado converte defesa em golpes mais consistentes.";
            break;

        case "Desabamento":
            _pokemon_data.Passiva1Nome = "Peso Sismico";
            _pokemon_data.Passiva1Descricao = "Desabando pressiona cooldowns e enfraquece alvos pesados.";
            _pokemon_data.Passiva2Nome = "Impacto de Placa";
            _pokemon_data.Passiva2Descricao = "Finalizadores terrestres crescem contra alvos lentos, presos ou quebrados.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Areia Movedica";
            _pokemon_data.Passiva1Descricao = "Lama e areia atrasam cooldowns do alvo sem travar totalmente a batalha.";
            _pokemon_data.Passiva2Nome = "Campo Fechado";
            _pokemon_data.Passiva2Descricao = "Areia Movedica conversa com Enraizado, Molhado e controle de gelo.";
            break;
    }
}

function pokemon_flying_passivas_aplicar(_pokemon_data, _arquetipo_flying) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.FlyingArquetipo = _arquetipo_flying;

    switch (_arquetipo_flying) {
        case "Turbulencia":
            _pokemon_data.Passiva1Nome = "Corrente Instavel";
            _pokemon_data.Passiva1Descricao = "Turbulento reduz a defesa efetiva e atrasa a rotacao do alvo.";
            _pokemon_data.Passiva2Nome = "Olho do Furacao";
            _pokemon_data.Passiva2Descricao = "Alvos molhados, ofuscados ou lentos sofrem melhor com golpes de vento.";
            break;

        case "Vento de Cauda":
            _pokemon_data.Passiva1Nome = "Ritmo de Cauda";
            _pokemon_data.Passiva1Descricao = "Vento de Cauda reduz cooldowns e melhora rotacoes hibridas.";
            _pokemon_data.Passiva2Nome = "Penas Leves";
            _pokemon_data.Passiva2Descricao = "Buffs de evasao viram pressao constante sem depender de dano alto.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Rasante Marcado";
            _pokemon_data.Passiva1Descricao = "Marcado Rasante abre janelas curtas para golpes aereos de burst.";
            _pokemon_data.Passiva2Nome = "Altura de Impacto";
            _pokemon_data.Passiva2Descricao = "Golpes finais de voador melhoram quando o alvo esta marcado ou turbulento.";
            break;
    }
}

function pokemon_psychic_passivas_aplicar(_pokemon_data, _arquetipo_psychic) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.PsychicArquetipo = _arquetipo_psychic;

    switch (_arquetipo_psychic) {
        case "Escudo Cinetico":
            _pokemon_data.Passiva1Nome = "Campo Cinetico";
            _pokemon_data.Passiva1Descricao = "Escudo Cinetico aumenta a resistencia e converte defesa em dano moderado.";
            _pokemon_data.Passiva2Nome = "Barreira Reflexiva";
            _pokemon_data.Passiva2Descricao = "A protecao mental sustenta equipes lentas ou de controle.";
            break;

        case "Inversao Espacial":
            _pokemon_data.Passiva1Nome = "Dobra Espacial";
            _pokemon_data.Passiva1Descricao = "Distorcao Espacial enfraquece defesa e prepara psicochoques.";
            _pokemon_data.Passiva2Nome = "Tempo Repartido";
            _pokemon_data.Passiva2Descricao = "Manipular cooldown do alvo conversa com agua, gelo e terra.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Fenda Mental";
            _pokemon_data.Passiva1Descricao = "Paralisia Mental atrasa cooldowns sem desligar totalmente o inimigo.";
            _pokemon_data.Passiva2Nome = "Memoria Quebrada";
            _pokemon_data.Passiva2Descricao = "Amnesia Induzida melhora finalizadores psiquicos e controle de turno.";
            break;
    }
}

function pokemon_bug_passivas_aplicar(_pokemon_data, _arquetipo_bug) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.BugArquetipo = _arquetipo_bug;

    switch (_arquetipo_bug) {
        case "Casulo Rigido":
            _pokemon_data.Passiva1Nome = "Quitina Reforcada";
            _pokemon_data.Passiva1Descricao = "Casulo Rigido aumenta resistencia e sustenta rotas longas.";
            _pokemon_data.Passiva2Nome = "Muda Segura";
            _pokemon_data.Passiva2Descricao = "Metamorfose converte defesa acumulada em pressao de contra-ataque.";
            break;

        case "Fio de Seda":
            _pokemon_data.Passiva1Nome = "Teia Aderente";
            _pokemon_data.Passiva1Descricao = "Seda Presa atrasa cooldowns e abre combos com Enraizado e Areia Movedica.";
            _pokemon_data.Passiva2Nome = "Infestacao Oportunista";
            _pokemon_data.Passiva2Descricao = "Infestado conversa com Veneno, Grama e finalizadores de controle.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Ritmo de Enxame";
            _pokemon_data.Passiva1Descricao = "Enxame Ativo melhora golpes rapidos e mantem a barra girando.";
            _pokemon_data.Passiva2Nome = "Corte em Cadeia";
            _pokemon_data.Passiva2Descricao = "Velocidade alta transforma dano leve em pressao constante.";
            break;
    }
}

function pokemon_rock_passivas_aplicar(_pokemon_data, _arquetipo_rock) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.RockArquetipo = _arquetipo_rock;

    switch (_arquetipo_rock) {
        case "Impacto Geologico":
            _pokemon_data.Passiva1Nome = "Peso de Colisao";
            _pokemon_data.Passiva1Descricao = "Golpes de impacto convertem um pouco de HP em dano extra sem explodir o balanceamento.";
            _pokemon_data.Passiva2Nome = "Falha de Placa";
            _pokemon_data.Passiva2Descricao = "Fragmentado e Desabando tornam finalizadores de pedra mais confiaveis.";
            break;

        case "Casca de Rocha":
            _pokemon_data.Passiva1Nome = "Carapaca Mineral";
            _pokemon_data.Passiva1Descricao = "Casca de Rocha aumenta resistencia e ajuda a sobreviver a rotas longas.";
            _pokemon_data.Passiva2Nome = "Fossil Persistente";
            _pokemon_data.Passiva2Descricao = "Defesa alta vira pressao gradual e pequenas curas em janelas certas.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Trinca Aberta";
            _pokemon_data.Passiva1Descricao = "Fragmentado reduz a defesa efetiva do alvo e prepara combos de pedra.";
            _pokemon_data.Passiva2Nome = "Chuva de Estilhacos";
            _pokemon_data.Passiva2Descricao = "Alvos presos, enraizados ou envolvidos por seda sofrem mais com fragmentos.";
            break;
    }
}

function pokemon_ghost_passivas_aplicar(_pokemon_data, _arquetipo_ghost) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.GhostArquetipo = _arquetipo_ghost;

    switch (_arquetipo_ghost) {
        case "Intangibilidade":
            _pokemon_data.Passiva1Nome = "Vulto Instavel";
            _pokemon_data.Passiva1Descricao = "Intangivel cria pequenas janelas de evasao e evita picos injustos de dano.";
            _pokemon_data.Passiva2Nome = "Passo Fora de Fase";
            _pokemon_data.Passiva2Descricao = "A velocidade alta transforma controle fantasma em rotacao segura.";
            break;

        case "Dreno de Essencia":
            _pokemon_data.Passiva1Nome = "Alma Sugadora";
            _pokemon_data.Passiva1Descricao = "Maldito e Essencia Drenada sustentam lutas longas com roubo de vida moderado.";
            _pokemon_data.Passiva2Nome = "Eco da Maldicao";
            _pokemon_data.Passiva2Descricao = "Dreno conversa com Veneno, medo e alvos ja marcados por outros debuffs.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Terror Crescente";
            _pokemon_data.Passiva1Descricao = "Assombrado abre dano progressivo conforme a luta se prolonga.";
            _pokemon_data.Passiva2Nome = "Relogio da Fenda";
            _pokemon_data.Passiva2Descricao = "Controle fantasma atrasa cooldowns e combina com psiquico, gelo e agua.";
            break;
    }
}

function pokemon_dragon_passivas_aplicar(_pokemon_data, _arquetipo_dragon) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.DragonArquetipo = _arquetipo_dragon;

    switch (_arquetipo_dragon) {
        case "Escama Imperial":
            _pokemon_data.Passiva1Nome = "Escama Imperial";
            _pokemon_data.Passiva1Descricao = "Escamas ativas aumentam a resistencia e mantem dano consistente.";
            _pokemon_data.Passiva2Nome = "Presenca Ancestral";
            _pokemon_data.Passiva2Descricao = "Amedrontado e Fragmentado abrem janelas para finalizadores de dragao.";
            break;

        case "Sopro Ancestral":
            _pokemon_data.Passiva1Nome = "Ascensao";
            _pokemon_data.Passiva1Descricao = "Ascensao Draconica melhora golpes longos e acelera a rotacao.";
            _pokemon_data.Passiva2Nome = "Pulso Primordial";
            _pokemon_data.Passiva2Descricao = "Sopros conversam com controle de cooldown, medo, gelo e rachaduras.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Furia Draconica";
            _pokemon_data.Passiva1Descricao = "Quanto mais ferido, mais perigoso ficam os golpes de dragao.";
            _pokemon_data.Passiva2Nome = "Instinto Predador";
            _pokemon_data.Passiva2Descricao = "HP em vantagem ou alvo fragilizado aumenta o valor dos finalizadores.";
            break;
    }
}

function pokemon_steel_passivas_aplicar(_pokemon_data, _arquetipo_steel) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.SteelArquetipo = _arquetipo_steel;

    switch (_arquetipo_steel) {
        case "Espinhos de Ferro":
            _pokemon_data.Passiva1Nome = "Espinhos de Ferro";
            _pokemon_data.Passiva1Descricao = "Receber dano devolve uma pequena parte ao atacante.";
            _pokemon_data.Passiva2Nome = "Prisao Ferrenha";
            _pokemon_data.Passiva2Descricao = "Enraizado, Seda Presa e Fragmentado tornam espinhos mais valiosos.";
            break;

        case "Impacto Pesado":
            _pokemon_data.Passiva1Nome = "Peso de Liga";
            _pokemon_data.Passiva1Descricao = "Defesa e blindagem magnetica viram dano moderado em golpes pesados.";
            _pokemon_data.Passiva2Nome = "Campo Magnetico";
            _pokemon_data.Passiva2Descricao = "Paralisado, Ofuscado e Fragmentado abrem combos de precisao metalica.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Fortificacao Rigida";
            _pokemon_data.Passiva1Descricao = "Fortificado empilha defesa e estabiliza lutas de atrito.";
            _pokemon_data.Passiva2Nome = "Liga Pesada";
            _pokemon_data.Passiva2Descricao = "Monstros lentos e resistentes transformam defesa em dano confiavel.";
            break;
    }
}

function pokemon_dark_passivas_aplicar(_pokemon_data, _arquetipo_dark) {
    if (!is_struct(_pokemon_data)) {
        return;
    }

    _pokemon_data.DarkArquetipo = _arquetipo_dark;

    switch (_arquetipo_dark) {
        case "Golpe Baixo":
            _pokemon_data.Passiva1Nome = "Oportunista";
            _pokemon_data.Passiva1Descricao = "Golpes sombrios punem melhor alvos com cooldown alto ou marcados.";
            _pokemon_data.Passiva2Nome = "Ataque de Janela";
            _pokemon_data.Passiva2Descricao = "Ofuscado, medo e postura quebrada abrem dano extra sem exigir quatro skills.";
            break;

        case "Copia Sombria":
            _pokemon_data.Passiva1Nome = "Ilusao Defensiva";
            _pokemon_data.Passiva1Descricao = "Copia Sombria e Camuflagem podem evitar golpes e manter a rotacao viva.";
            _pokemon_data.Passiva2Nome = "Cacador de Fuga";
            _pokemon_data.Passiva2Descricao = "Perseguicao pune alvos evasivos, intangiveis ou acelerados por vento.";
            break;

        default:
            _pokemon_data.Passiva1Nome = "Maldade Calculada";
            _pokemon_data.Passiva1Descricao = "Debuffs como veneno, corrosao, queimadura e quebra de postura viram dano sombrio.";
            _pokemon_data.Passiva2Nome = "Roubo de Ritmo";
            _pokemon_data.Passiva2Descricao = "Jogo Sujo atrasa cooldowns e transforma alvos enfraquecidos em vantagem.";
            break;
    }
}

function pokemon_fire_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.FIRE)) {
        return undefined;
    }

    if (_attack >= 105 && _speed < 80) {
        return new PokemonTypePerfil("Explosao Termica", PokemonTipo.FIRE, 1.06, 1.14, 0.96, 0.82, 1.04, 1.10, 0.96, 0.84);
    }

    if (_speed >= 90) {
        return new PokemonTypePerfil("Fenix Veloz", PokemonTipo.FIRE, 0.94, 1.10, 0.90, 1.12, 0.94, 1.08, 0.90, 1.10);
    }

    if (_hp + _defense >= 170) {
        return new PokemonTypePerfil("Incandescencia", PokemonTipo.FIRE, 1.06, 1.04, 1.04, 0.90, 1.06, 1.04, 1.02, 0.92);
    }

    return new PokemonTypePerfil("Incandescencia", PokemonTipo.FIRE, 1.00, 1.06, 0.96, 1.02, 1.00, 1.06, 0.96, 1.00);
}

function pokemon_fire_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_fire_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_fire_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_water_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.WATER)) {
        return undefined;
    }

    if (_hp + _defense >= 175 || _hp >= 100) {
        return new PokemonTypePerfil("Mare Protelatoria", PokemonTipo.WATER, 1.12, 0.94, 1.08, 0.88, 1.10, 0.94, 1.08, 0.90);
    }

    if (_speed >= 85) {
        return new PokemonTypePerfil("Fluxo Acelerado", PokemonTipo.WATER, 0.96, 1.02, 0.94, 1.10, 0.96, 1.02, 0.94, 1.10);
    }

    return new PokemonTypePerfil("Pressao Hidraulica", PokemonTipo.WATER, 1.04, 1.04, 1.00, 0.96, 1.04, 1.04, 1.00, 0.96);
}

function pokemon_water_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_water_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_water_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_electric_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.ELECTRIC)) {
        return undefined;
    }

    if (_speed >= 105) {
        return new PokemonTypePerfil("Estatica Veloz", PokemonTipo.ELECTRIC, 0.94, 1.04, 0.90, 1.14, 0.94, 1.04, 0.90, 1.12);
    }

    if (_attack >= 95) {
        return new PokemonTypePerfil("Sobrecarga", PokemonTipo.ELECTRIC, 0.98, 1.12, 0.94, 1.02, 0.98, 1.08, 0.94, 1.02);
    }

    if (_defense >= 85 || _hp >= 80) {
        return new PokemonTypePerfil("Curto-Circuito", PokemonTipo.ELECTRIC, 1.04, 1.00, 1.06, 0.96, 1.04, 1.00, 1.04, 0.96);
    }

    return new PokemonTypePerfil("Sobrecarga", PokemonTipo.ELECTRIC, 0.98, 1.08, 0.94, 1.04, 0.98, 1.06, 0.94, 1.04);
}

function pokemon_electric_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_electric_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_electric_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_ice_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.ICE)) {
        return undefined;
    }

    if (_hp + _defense >= 175 || _defense >= 100) {
        return new PokemonTypePerfil("Manto de Gelo", PokemonTipo.ICE, 1.12, 0.96, 1.10, 0.84, 1.10, 0.96, 1.08, 0.86);
    }

    if (_speed >= 90 || _attack >= 100) {
        return new PokemonTypePerfil("Estilhacar", PokemonTipo.ICE, 0.94, 1.10, 0.90, 1.08, 0.94, 1.08, 0.90, 1.06);
    }

    return new PokemonTypePerfil("Geada Acumulativa", PokemonTipo.ICE, 1.00, 1.02, 1.00, 0.98, 1.00, 1.02, 1.00, 0.98);
}

function pokemon_ice_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_ice_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_ice_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_fighting_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.FIGHTING)) {
        return undefined;
    }

    if (_attack >= 115 && _speed < 80) {
        return new PokemonTypePerfil("Quebra-Guarda", PokemonTipo.FIGHTING, 1.04, 1.12, 1.02, 0.90, 1.04, 1.08, 1.02, 0.92);
    }

    if (_speed >= 95) {
        return new PokemonTypePerfil("Impeto Ofensivo", PokemonTipo.FIGHTING, 0.94, 1.08, 0.92, 1.12, 0.94, 1.06, 0.92, 1.10);
    }

    if (_hp + _defense >= 165 || _hp >= 95) {
        return new PokemonTypePerfil("Espirito de Luta", PokemonTipo.FIGHTING, 1.08, 1.04, 1.04, 0.94, 1.08, 1.02, 1.04, 0.94);
    }

    return new PokemonTypePerfil("Impeto Ofensivo", PokemonTipo.FIGHTING, 0.98, 1.06, 0.96, 1.04, 0.98, 1.04, 0.96, 1.04);
}

function pokemon_fighting_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_fighting_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_fighting_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_ground_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.GROUND)) {
        return undefined;
    }

    if (_hp + _defense >= 180 || _defense >= 110) {
        return new PokemonTypePerfil("Barreira de Lama", PokemonTipo.GROUND, 1.14, 0.94, 1.12, 0.82, 1.12, 0.94, 1.10, 0.84);
    }

    if (_attack >= 110) {
        return new PokemonTypePerfil("Desabamento", PokemonTipo.GROUND, 1.02, 1.12, 1.00, 0.94, 1.02, 1.08, 1.00, 0.94);
    }

    return new PokemonTypePerfil("Areia Movedica", PokemonTipo.GROUND, 1.02, 1.00, 1.02, 0.98, 1.02, 1.00, 1.02, 0.98);
}

function pokemon_ground_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_ground_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_ground_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_flying_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.FLYING)) {
        return undefined;
    }

    if (_speed >= 105 || (_attack >= 100 && _speed >= 85)) {
        return new PokemonTypePerfil("Ataque Rasante", PokemonTipo.FLYING, 0.94, 1.08, 0.90, 1.12, 0.94, 1.06, 0.90, 1.10);
    }

    if (_hp + _defense >= 170 || _defense >= 95) {
        return new PokemonTypePerfil("Vento de Cauda", PokemonTipo.FLYING, 1.04, 0.98, 1.04, 0.98, 1.04, 0.98, 1.04, 0.98);
    }

    return new PokemonTypePerfil("Turbulencia", PokemonTipo.FLYING, 0.98, 1.02, 0.96, 1.06, 0.98, 1.02, 0.96, 1.06);
}

function pokemon_flying_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_flying_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_flying_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_psychic_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.PSYCHIC)) {
        return undefined;
    }

    if (_defense >= 95 || _hp >= 95) {
        return new PokemonTypePerfil("Escudo Cinetico", PokemonTipo.PSYCHIC, 1.08, 0.96, 1.10, 0.90, 1.08, 0.96, 1.08, 0.92);
    }

    if (_speed >= 95) {
        return new PokemonTypePerfil("Paralisia Mental", PokemonTipo.PSYCHIC, 0.94, 1.06, 0.90, 1.10, 0.94, 1.04, 0.90, 1.08);
    }

    if (_attack >= 105) {
        return new PokemonTypePerfil("Inversao Espacial", PokemonTipo.PSYCHIC, 0.98, 1.10, 0.96, 1.02, 0.98, 1.08, 0.96, 1.02);
    }

    return new PokemonTypePerfil("Paralisia Mental", PokemonTipo.PSYCHIC, 0.98, 1.04, 0.96, 1.04, 0.98, 1.04, 0.96, 1.04);
}

function pokemon_psychic_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_psychic_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_psychic_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_bug_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.BUG)) {
        return undefined;
    }

    if (_defense >= 100 || _hp + _defense >= 175) {
        return new PokemonTypePerfil("Casulo Rigido", PokemonTipo.BUG, 1.10, 0.96, 1.14, 0.82, 1.08, 0.96, 1.12, 0.84);
    }

    if (_speed >= 95 || _attack >= 105) {
        return new PokemonTypePerfil("Tatica de Enxame", PokemonTipo.BUG, 0.94, 1.06, 0.92, 1.12, 0.94, 1.04, 0.92, 1.10);
    }

    return new PokemonTypePerfil("Fio de Seda", PokemonTipo.BUG, 1.00, 1.00, 1.00, 1.02, 1.00, 1.00, 1.00, 1.02);
}

function pokemon_bug_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_bug_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_bug_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_rock_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.ROCK)) {
        return undefined;
    }

    if (_hp + _defense >= 180 || _defense >= 110) {
        return new PokemonTypePerfil("Casca de Rocha", PokemonTipo.ROCK, 1.14, 0.94, 1.14, 0.82, 1.12, 0.94, 1.12, 0.84);
    }

    if (_attack >= 110) {
        return new PokemonTypePerfil("Impacto Geologico", PokemonTipo.ROCK, 1.00, 1.14, 0.98, 0.94, 1.00, 1.10, 0.98, 0.94);
    }

    return new PokemonTypePerfil("Fragmentacao", PokemonTipo.ROCK, 1.02, 1.02, 1.02, 0.98, 1.02, 1.02, 1.02, 0.98);
}

function pokemon_rock_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_rock_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_rock_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_ghost_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.GHOST)) {
        return undefined;
    }

    if (_speed >= 95) {
        return new PokemonTypePerfil("Intangibilidade", PokemonTipo.GHOST, 0.94, 1.04, 0.92, 1.12, 0.94, 1.04, 0.92, 1.10);
    }

    if (_hp + _defense >= 165 || _hp >= 95) {
        return new PokemonTypePerfil("Dreno de Essencia", PokemonTipo.GHOST, 1.08, 1.00, 1.06, 0.94, 1.08, 1.00, 1.06, 0.94);
    }

    if (_attack >= 105) {
        return new PokemonTypePerfil("Assombracao", PokemonTipo.GHOST, 0.98, 1.10, 0.94, 1.02, 0.98, 1.08, 0.94, 1.02);
    }

    return new PokemonTypePerfil("Assombracao", PokemonTipo.GHOST, 0.98, 1.04, 0.96, 1.04, 0.98, 1.04, 0.96, 1.04);
}

function pokemon_ghost_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_ghost_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_ghost_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_steel_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.STEEL)) {
        return undefined;
    }

    if (_defense >= 120 || _hp + _defense >= 190) {
        return new PokemonTypePerfil("Fortificacao Rigida", PokemonTipo.STEEL, 1.12, 0.94, 1.18, 0.78, 1.10, 0.94, 1.14, 0.82);
    }

    if (_attack >= 105 || _speed >= 90) {
        return new PokemonTypePerfil("Impacto Pesado", PokemonTipo.STEEL, 1.00, 1.10, 1.06, 0.98, 1.00, 1.08, 1.04, 0.98);
    }

    return new PokemonTypePerfil("Espinhos de Ferro", PokemonTipo.STEEL, 1.04, 1.00, 1.10, 0.90, 1.04, 1.00, 1.08, 0.90);
}

function pokemon_steel_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_steel_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_steel_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_dragon_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.DRAGON)) {
        return undefined;
    }

    if (_attack >= 120 || _speed >= 100) {
        return new PokemonTypePerfil("Furia Draconica", PokemonTipo.DRAGON, 0.98, 1.12, 0.94, 1.06, 0.98, 1.10, 0.94, 1.04);
    }

    if (_hp + _defense >= 175 || _defense >= 100) {
        return new PokemonTypePerfil("Escama Imperial", PokemonTipo.DRAGON, 1.08, 1.02, 1.08, 0.94, 1.08, 1.02, 1.06, 0.94);
    }

    return new PokemonTypePerfil("Sopro Ancestral", PokemonTipo.DRAGON, 1.00, 1.08, 1.00, 1.00, 1.00, 1.06, 1.00, 1.00);
}

function pokemon_dragon_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_dragon_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_dragon_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_dark_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.DARK)) {
        return undefined;
    }

    if (_speed >= 100 || (_attack >= 105 && _speed >= 85)) {
        return new PokemonTypePerfil("Golpe Baixo", PokemonTipo.DARK, 0.94, 1.10, 0.90, 1.12, 0.94, 1.08, 0.90, 1.10);
    }

    if (_hp + _defense >= 170 || _defense >= 100) {
        return new PokemonTypePerfil("Golpe Traicoeiro", PokemonTipo.DARK, 1.10, 0.98, 1.10, 0.88, 1.10, 0.98, 1.08, 0.90);
    }

    return new PokemonTypePerfil("Copia Sombria", PokemonTipo.DARK, 1.00, 1.04, 0.98, 1.04, 1.00, 1.04, 0.98, 1.04);
}

function pokemon_dark_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_dark_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_dark_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_fairy_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.FAIRY)) {
        return undefined;
    }

    // Hibridos com fada como tipo secundario seguem o perfil do tipo principal.
    if (_tipo1 != PokemonTipo.FAIRY) {
        return undefined;
    }

    if (_hp + _defense >= 165 || _defense >= 95) {
        return new PokemonTypePerfil("Luz Purificadora", PokemonTipo.FAIRY, 1.08, 0.96, 1.10, 0.92, 1.08, 0.96, 1.08, 0.92);
    }

    if (_speed >= 85 || _attack >= 90) {
        return new PokemonTypePerfil("Encantamento de Carga", PokemonTipo.FAIRY, 0.96, 1.08, 0.94, 1.08, 0.96, 1.06, 0.94, 1.06);
    }

    return new PokemonTypePerfil("Aura Mistica", PokemonTipo.FAIRY, 1.00, 1.02, 1.00, 1.02, 1.00, 1.02, 1.00, 1.02);
}

function pokemon_fairy_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_fairy_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_fairy_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_normal_perfil_get(_id, _tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.NORMAL)) {
        return undefined;
    }

    // Normal/Flying, Normal/Fairy e Normal/Psychic ja ganham identidade melhor no outro tipo.
    if (_tipo2 != PokemonTipo.NONE) {
        return undefined;
    }

    if (_hp + _defense >= 170 || _hp >= 100) {
        return new PokemonTypePerfil("Estocar", PokemonTipo.NORMAL, 1.12, 0.96, 1.10, 0.88, 1.10, 0.96, 1.08, 0.90);
    }

    if (_speed >= 90 || _attack >= 95) {
        return new PokemonTypePerfil("Forca Neutra", PokemonTipo.NORMAL, 0.98, 1.06, 0.96, 1.06, 0.98, 1.04, 0.96, 1.04);
    }

    return new PokemonTypePerfil("Legado", PokemonTipo.NORMAL, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00);
}

function pokemon_normal_perfil_aplicar(_pokemon_data, _perfil) {
    if (!pokemon_type_perfil_stats_aplicar(_pokemon_data, _perfil)) {
        return;
    }

    pokemon_normal_passivas_aplicar(_pokemon_data, _perfil.Arquetipo);
    _pokemon_data.ListaHabilidadesDisponiveis = pokemon_habilidades_normal_por_perfil(_pokemon_data.Tipo1, _pokemon_data.Tipo2, _perfil.Arquetipo, _perfil.TipoInicial);
}

function pokemon_grass_arquetipo(_tipo1, _tipo2, _hp, _attack, _defense, _speed) {
    if (!pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.GRASS)) {
        return "";
    }

    if (pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.POISON)) {
        return "Parasita";
    }

    if (pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.WATER) || pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.GROUND) || pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.ROCK)) {
        return "Energia Solar";
    }

    if (_hp + _defense >= 170 || _defense >= 105) {
        return "Energia Solar";
    }

    if (pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.BUG) || pokemon_tem_tipo(_tipo1, _tipo2, PokemonTipo.FLYING)) {
        return "Florescencia Critica";
    }

    if (_speed >= 90 || _attack >= 90) {
        return "Florescencia Critica";
    }

    return "Parasita";
}

function pokemon_species_info_gen5(_id) {
    // Dados das especies agora vem de datafiles/data/criaturas.json (scr_conteudo).
    var _info = criatura_info(_id);

    if (!is_struct(_info)) {
        return undefined;
    }

    return {
        Nome: _info.Nome,
        Tipo1: _info.Tipo1,
        Tipo2: _info.Tipo2,
        Hp: _info.Hp,
        Attack: _info.Attack,
        Defense: _info.Defense,
        Speed: _info.Speed
    };
}
function pokemon_db_preencher_geracoes_1_5(_db) {
    var _ids_criaturas = criatura_ids();

    for (var _idx = 0; _idx < array_length(_ids_criaturas); _idx += 1) {
        var _id = _ids_criaturas[_idx];
        var _key = string(_id);

        var _species = pokemon_species_info_gen5(_id);
        var _tipo = is_struct(_species) ? _species.Tipo1 : pokemon_db_tipo_sugerido(_id);
        var _tipo2 = is_struct(_species) ? _species.Tipo2 : PokemonTipo.NONE;
        var _hp = is_struct(_species) ? _species.Hp : 34 + ((_id * 7) mod 32);
        var _atk = is_struct(_species) ? _species.Attack : 34 + ((_id * 11) mod 34);
        var _def = is_struct(_species) ? _species.Defense : 32 + ((_id * 13) mod 36);
        var _spd = is_struct(_species) ? _species.Speed : 30 + ((_id * 17) mod 42);
        var _growth_hp = 1.8 + ((_hp - 34) / 32) * 1.7 + (((_id * 5) mod 7) * 0.05);
        var _growth_atk = 1.6 + ((_atk - 34) / 34) * 1.4 + (((_id * 3) mod 7) * 0.04);
        var _growth_def = 1.6 + ((_def - 32) / 36) * 1.4 + (((_id * 4) mod 7) * 0.04);
        var _growth_spd = 1.3 + ((_spd - 30) / 42) * 1.5 + (((_id * 2) mod 7) * 0.04);
        var _skills = pokemon_habilidades_por_tipos(_tipo, _tipo2);
        var _numero = string(_id);

        while (string_length(_numero) < 3) {
            _numero = "0" + _numero;
        }

        var _name = is_struct(_species) ? _species.Nome : "Criatura " + _numero;

        var _pokemon_data = new PokemonData(
            _id,
            _name,
            _tipo,
            _tipo2,
            _hp,
            _atk,
            _def,
            _spd,
            _growth_hp,
            _growth_atk,
            _growth_def,
            _growth_spd,
            1,
            0,
            _skills,
            pokemon_birth_tags_por_tipos(_tipo, _tipo2)
        );

        var _perfil_grass = pokemon_grass_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

        if (is_struct(_perfil_grass)) {
            pokemon_grass_perfil_aplicar(_pokemon_data, _perfil_grass);
        } else {
            var _perfil_poison = pokemon_poison_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

            if (is_struct(_perfil_poison)) {
                pokemon_poison_perfil_aplicar(_pokemon_data, _perfil_poison);
            } else {
                var _perfil_fire = pokemon_fire_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                if (is_struct(_perfil_fire)) {
                    pokemon_fire_perfil_aplicar(_pokemon_data, _perfil_fire);
                } else {
                    var _perfil_water = pokemon_water_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                    if (is_struct(_perfil_water)) {
                        pokemon_water_perfil_aplicar(_pokemon_data, _perfil_water);
                    } else {
                        var _perfil_electric = pokemon_electric_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                        if (is_struct(_perfil_electric)) {
                            pokemon_electric_perfil_aplicar(_pokemon_data, _perfil_electric);
                        } else {
                            var _perfil_ice = pokemon_ice_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                            if (is_struct(_perfil_ice)) {
                                pokemon_ice_perfil_aplicar(_pokemon_data, _perfil_ice);
                            } else {
                                var _perfil_fighting = pokemon_fighting_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                                if (is_struct(_perfil_fighting)) {
                                    pokemon_fighting_perfil_aplicar(_pokemon_data, _perfil_fighting);
                                } else {
                                    var _perfil_rock = pokemon_rock_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                                    if (is_struct(_perfil_rock)) {
                                        pokemon_rock_perfil_aplicar(_pokemon_data, _perfil_rock);
                                    } else {
                                        var _perfil_ghost = pokemon_ghost_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                                        if (is_struct(_perfil_ghost)) {
                                            pokemon_ghost_perfil_aplicar(_pokemon_data, _perfil_ghost);
                                        } else {
                                            var _perfil_steel = pokemon_steel_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                                            if (is_struct(_perfil_steel)) {
                                                pokemon_steel_perfil_aplicar(_pokemon_data, _perfil_steel);
                                            } else {
                                                var _perfil_dragon = pokemon_dragon_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                                                if (is_struct(_perfil_dragon)) {
                                                    pokemon_dragon_perfil_aplicar(_pokemon_data, _perfil_dragon);
                                                } else {
                                                    var _perfil_ground = pokemon_ground_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                                                    if (is_struct(_perfil_ground)) {
                                                        pokemon_ground_perfil_aplicar(_pokemon_data, _perfil_ground);
                                                    } else {
                                                        var _perfil_psychic = pokemon_psychic_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                                                        if (is_struct(_perfil_psychic)) {
                                                            pokemon_psychic_perfil_aplicar(_pokemon_data, _perfil_psychic);
                                                        } else {
                                                            var _perfil_bug = pokemon_bug_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                                                            if (is_struct(_perfil_bug)) {
                                                                pokemon_bug_perfil_aplicar(_pokemon_data, _perfil_bug);
                                                            } else {
                                                                var _perfil_flying = pokemon_flying_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

                                                                if (is_struct(_perfil_flying)) {
                                                                    pokemon_flying_perfil_aplicar(_pokemon_data, _perfil_flying);
                                                                } else {
                                                                    _pokemon_data.Arquetipo = "";
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        if (_pokemon_data.Tipo1 == PokemonTipo.DARK) {
            var _perfil_dark_primary = pokemon_dark_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

            if (is_struct(_perfil_dark_primary)) {
                pokemon_dark_perfil_aplicar(_pokemon_data, _perfil_dark_primary);
            }
        }

        var _perfil_fairy = pokemon_fairy_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

        if (is_struct(_perfil_fairy)) {
            pokemon_fairy_perfil_aplicar(_pokemon_data, _perfil_fairy);
        } else {
            var _perfil_normal = pokemon_normal_perfil_get(-1, _tipo, _tipo2, _hp, _atk, _def, _spd);

            if (is_struct(_perfil_normal)) {
                pokemon_normal_perfil_aplicar(_pokemon_data, _perfil_normal);
            }
        }

        pokemon_wild_min_level_atualizar(_pokemon_data);

        variable_struct_set(_db, _key, _pokemon_data);
    }
}

function pokemon_db_get(_db, _pokemon_id) {
    var _key = string(_pokemon_id);

    if (!is_struct(_db) || !variable_struct_exists(_db, _key)) {
        show_debug_message("Monstro nao encontrado no Bestiario: " + _key);
        return undefined;
    }

    return variable_struct_get(_db, _key);
}

//========================================================
// SISTEMA DE PASSIVAS (GERADO)
//========================================================
function pokemon_tipo_string(_tipo) {
    switch(_tipo) {
        case PokemonTipo.NORMAL: return "normal";
        case PokemonTipo.FIRE: return "fire";
        case PokemonTipo.WATER: return "water";
        case PokemonTipo.GRASS: return "grass";
        case PokemonTipo.ELECTRIC: return "electric";
        case PokemonTipo.ICE: return "ice";
        case PokemonTipo.FIGHTING: return "fighting";
        case PokemonTipo.POISON: return "poison";
        case PokemonTipo.GROUND: return "ground";
        case PokemonTipo.FLYING: return "flying";
        case PokemonTipo.PSYCHIC: return "psychic";
        case PokemonTipo.BUG: return "bug";
        case PokemonTipo.ROCK: return "rock";
        case PokemonTipo.GHOST: return "ghost";
        case PokemonTipo.DRAGON: return "dragon";
        case PokemonTipo.DARK: return "dark";
        case PokemonTipo.STEEL: return "steel";
        case PokemonTipo.FAIRY: return "fairy";
        default: return "normal";
    }
}

global.passivas_db = {
    passiva_normal_ataque_1 : { Nivel: 1, Descricao: "Dano de ataques basicos aumenta em 15% se atacou o mesmo alvo 3x." },
    passiva_normal_ataque_2 : { Nivel: 2, Descricao: "Dano de ataques basicos aumenta em 22% se atacou o mesmo alvo 6x." },
    passiva_normal_defesa_1 : { Nivel: 1, Descricao: "Ignora debuffs leves de status ao ficar abaixo de 50% HP." },
    passiva_normal_defesa_2 : { Nivel: 2, Descricao: "Ignora debuffs leves de status ao ficar abaixo de 75% HP." },
    passiva_normal_velocidade_1 : { Nivel: 1, Descricao: "Se ficar 4s sem atacar, a proxima skill eh instantanea." },
    passiva_normal_velocidade_2 : { Nivel: 2, Descricao: "Se ficar 8s sem atacar, a proxima skill eh instantanea." },
    passiva_fire_ataque_1 : { Nivel: 1, Descricao: "Dano critico +10% contra alvos Queimando." },
    passiva_fire_ataque_2 : { Nivel: 2, Descricao: "Dano critico +15% contra alvos Queimando." },
    passiva_fire_defesa_1 : { Nivel: 1, Descricao: "Toma 10% a menos de dano de alvos Queimando." },
    passiva_fire_defesa_2 : { Nivel: 2, Descricao: "Toma 15% a menos de dano de alvos Queimando." },
    passiva_fire_velocidade_1 : { Nivel: 1, Descricao: "Ataques basicos em alvos sem armadura aceleram habilidades em 5%." },
    passiva_fire_velocidade_2 : { Nivel: 2, Descricao: "Ataques basicos em alvos sem armadura aceleram habilidades em 7%." },
    passiva_water_ataque_1 : { Nivel: 1, Descricao: "Habilidades causam +10% dano se o oponente tiver o CD maior que o seu." },
    passiva_water_ataque_2 : { Nivel: 2, Descricao: "Habilidades causam +15% dano se o oponente tiver o CD maior que o seu." },
    passiva_water_defesa_1 : { Nivel: 1, Descricao: "Cria escudo de 2% ao aplicar Molhado." },
    passiva_water_defesa_2 : { Nivel: 2, Descricao: "Cria escudo de 4% ao aplicar Molhado." },
    passiva_water_velocidade_1 : { Nivel: 1, Descricao: "Ao ser atingido, tem chance de resetar 1s de um golpe de Agua." },
    passiva_water_velocidade_2 : { Nivel: 2, Descricao: "Ao ser atingido, tem chance de resetar 2s de um golpe de Agua." },
    passiva_grass_ataque_1 : { Nivel: 1, Descricao: "Inimigos Enraizados sofrem +5% dano verdadeiro basico." },
    passiva_grass_ataque_2 : { Nivel: 2, Descricao: "Inimigos Enraizados sofrem +7% dano verdadeiro basico." },
    passiva_grass_defesa_1 : { Nivel: 1, Descricao: "Cura +2% HP max sempre que aplicar debuff de Planta." },
    passiva_grass_defesa_2 : { Nivel: 2, Descricao: "Cura +4% HP max sempre que aplicar debuff de Planta." },
    passiva_grass_velocidade_1 : { Nivel: 1, Descricao: "Cada vez que curar, reduz Cooldown Global em 0.2s." },
    passiva_grass_velocidade_2 : { Nivel: 2, Descricao: "Cada vez que curar, reduz Cooldown Global em 0.4s." },
    passiva_electric_ataque_1 : { Nivel: 1, Descricao: "Causa 10% a mais de dano se o alvo falhou um ataque recentemente." },
    passiva_electric_ataque_2 : { Nivel: 2, Descricao: "Causa 15% a mais de dano se o alvo falhou um ataque recentemente." },
    passiva_electric_defesa_1 : { Nivel: 1, Descricao: "Quando atacado, tem 5% de chance de Cegar o atacante." },
    passiva_electric_defesa_2 : { Nivel: 2, Descricao: "Quando atacado, tem 7% de chance de Cegar o atacante." },
    passiva_electric_velocidade_1 : { Nivel: 1, Descricao: "Se o alvo for Cegado, ganha um burst de 15% MoveSpeed." },
    passiva_electric_velocidade_2 : { Nivel: 2, Descricao: "Se o alvo for Cegado, ganha um burst de 22% MoveSpeed." },
    passiva_ice_ataque_1 : { Nivel: 1, Descricao: "Ataques basicos contra alvos com Frio causam dano duplo de quebra." },
    passiva_ice_ataque_2 : { Nivel: 2, Descricao: "Ataques basicos contra alvos com Frio causam dano duplo de quebra. (Efeito Dobrado)." },
    passiva_ice_defesa_1 : { Nivel: 1, Descricao: "Aumenta a Armadura em 10% se houver Granizo no campo." },
    passiva_ice_defesa_2 : { Nivel: 2, Descricao: "Aumenta a Armadura em 15% se houver Granizo no campo." },
    passiva_ice_velocidade_1 : { Nivel: 1, Descricao: "Retarda o tempo de canalizacao do inimigo em 5% por hit." },
    passiva_ice_velocidade_2 : { Nivel: 2, Descricao: "Retarda o tempo de canalizacao do inimigo em 7% por hit." },
    passiva_fighting_ataque_1 : { Nivel: 1, Descricao: "Ganha 1% de Dano acumulativo para cada ataque consecutivo no mesmo alvo." },
    passiva_fighting_ataque_2 : { Nivel: 2, Descricao: "Ganha 2% de Dano acumulativo para cada ataque consecutivo no mesmo alvo." },
    passiva_fighting_defesa_1 : { Nivel: 1, Descricao: "Ao bloquear ou esquivar, cura 3% do HP perdido." },
    passiva_fighting_defesa_2 : { Nivel: 2, Descricao: "Ao bloquear ou esquivar, cura 6% do HP perdido." },
    passiva_fighting_velocidade_1 : { Nivel: 1, Descricao: "Inimigos com Postura Quebrada sao atrasados em 0.3s a cada hit." },
    passiva_fighting_velocidade_2 : { Nivel: 2, Descricao: "Inimigos com Postura Quebrada sao atrasados em 0.6s a cada hit." },
    passiva_poison_ataque_1 : { Nivel: 1, Descricao: "Inimigos recebem +10% de dano final de todos os DoTs." },
    passiva_poison_ataque_2 : { Nivel: 2, Descricao: "Inimigos recebem +15% de dano final de todos os DoTs." },
    passiva_poison_defesa_1 : { Nivel: 1, Descricao: "Gera regeneracao de vida baseada na quantidade de veneno em campo." },
    passiva_poison_defesa_2 : { Nivel: 2, Descricao: "Gera regeneracao de vida baseada na quantidade de veneno em campo. (Efeito Dobrado)." },
    passiva_poison_velocidade_1 : { Nivel: 1, Descricao: "Movimenta-se 10% mais rapido para cada inimigo Envenenado." },
    passiva_poison_velocidade_2 : { Nivel: 2, Descricao: "Movimenta-se 15% mais rapido para cada inimigo Envenenado." },
    passiva_ground_ataque_1 : { Nivel: 1, Descricao: "Causa 10% a mais de dano contra alvos com Areia Movedica." },
    passiva_ground_ataque_2 : { Nivel: 2, Descricao: "Causa 15% a mais de dano contra alvos com Areia Movedica." },
    passiva_ground_defesa_1 : { Nivel: 1, Descricao: "Dano fisico recebido eh reduzido em 5% (15% se estiver Aterrado)." },
    passiva_ground_defesa_2 : { Nivel: 2, Descricao: "Dano fisico recebido eh reduzido em 7% (22% se estiver Aterrado)." },
    passiva_ground_velocidade_1 : { Nivel: 1, Descricao: "Passos pesados reduzem a velocidade de recarga do inimigo ao longo do tempo." },
    passiva_ground_velocidade_2 : { Nivel: 2, Descricao: "Passos pesados reduzem a velocidade de recarga do inimigo ao longo do tempo. (Efeito Dobrado)." },
    passiva_flying_ataque_1 : { Nivel: 1, Descricao: "Dano de Mergulho aumenta em 15% nos primeiros 5s de luta." },
    passiva_flying_ataque_2 : { Nivel: 2, Descricao: "Dano de Mergulho aumenta em 22% nos primeiros 7s de luta." },
    passiva_flying_defesa_1 : { Nivel: 1, Descricao: "Evasao aumenta em 10% quando tem menos de 30% de HP." },
    passiva_flying_defesa_2 : { Nivel: 2, Descricao: "Evasao aumenta em 15% quando tem menos de 45% de HP." },
    passiva_flying_velocidade_1 : { Nivel: 1, Descricao: "Cada habilidade voadora conjurada reduz o proprio CD em 0.1s." },
    passiva_flying_velocidade_2 : { Nivel: 2, Descricao: "Cada habilidade voadora conjurada reduz o proprio CD em 0.2s." },
    passiva_psychic_ataque_1 : { Nivel: 1, Descricao: "Ataques psiquicos causam lentidao mental, aumentando CDs do inimigo." },
    passiva_psychic_ataque_2 : { Nivel: 2, Descricao: "Ataques psiquicos causam lentidao mental, aumentando CDs do inimigo. (Efeito Dobrado)." },
    passiva_psychic_defesa_1 : { Nivel: 1, Descricao: "Cria um escudo cinetico automatico ao receber dano critico." },
    passiva_psychic_defesa_2 : { Nivel: 2, Descricao: "Cria um escudo cinetico automatico ao receber dano critico. (Efeito Dobrado)." },
    passiva_psychic_velocidade_1 : { Nivel: 1, Descricao: "Inverte buffs de velocidade do inimigo para lentidao temporaria." },
    passiva_psychic_velocidade_2 : { Nivel: 2, Descricao: "Inverte buffs de velocidade do inimigo para lentidao temporaria. (Efeito Dobrado)." },
    passiva_bug_ataque_1 : { Nivel: 1, Descricao: "O dano de Picada escala com o numero de habilidades lancadas na batalha." },
    passiva_bug_ataque_2 : { Nivel: 2, Descricao: "O dano de Picada escala com o numero de habilidades lancadas na batalha. (Efeito Dobrado)." },
    passiva_bug_defesa_1 : { Nivel: 1, Descricao: "Quando sofre controle de grupo, fortalece a armadura natural em 15%." },
    passiva_bug_defesa_2 : { Nivel: 2, Descricao: "Quando sofre controle de grupo, fortalece a armadura natural em 22%." },
    passiva_bug_velocidade_1 : { Nivel: 1, Descricao: "Cada ataque basico reduz cooldowns da mesma tipagem em 0.05s." },
    passiva_bug_velocidade_2 : { Nivel: 2, Descricao: "Cada ataque basico reduz cooldowns da mesma tipagem em 0.7s." },
    passiva_rock_ataque_1 : { Nivel: 1, Descricao: "Ignora 10% da defesa inimiga passivamente." },
    passiva_rock_ataque_2 : { Nivel: 2, Descricao: "Ignora 15% da defesa inimiga passivamente." },
    passiva_rock_defesa_1 : { Nivel: 1, Descricao: "Dano verdadeiro ou critico recebido eh limitado a 15% do seu HP Max." },
    passiva_rock_defesa_2 : { Nivel: 2, Descricao: "Dano verdadeiro ou critico recebido eh limitado a 22% do seu HP Max." },
    passiva_rock_velocidade_1 : { Nivel: 1, Descricao: "Habilidades com CD acima de 10s carregam 10% mais rapido." },
    passiva_rock_velocidade_2 : { Nivel: 2, Descricao: "Habilidades com CD acima de 15s carregam 15% mais rapido." },
    passiva_ghost_ataque_1 : { Nivel: 1, Descricao: "Ataques basicos aumentam o dano em 1% para cada segundo de luta." },
    passiva_ghost_ataque_2 : { Nivel: 2, Descricao: "Ataques basicos aumentam o dano em 2% para cada segundo de luta." },
    passiva_ghost_defesa_1 : { Nivel: 1, Descricao: "Toma 15% a menos de dano nos primeiros 5 segundos da partida." },
    passiva_ghost_defesa_2 : { Nivel: 2, Descricao: "Toma 22% a menos de dano nos primeiros 7 segundos da partida." },
    passiva_ghost_velocidade_1 : { Nivel: 1, Descricao: "Evasivos: Tem pequena chance de anular completamente habilidades altas." },
    passiva_ghost_velocidade_2 : { Nivel: 2, Descricao: "Evasivos: Tem pequena chance de anular completamente habilidades altas. (Efeito Dobrado)." },
    passiva_dragon_ataque_1 : { Nivel: 1, Descricao: "Seu dano aumenta em ate 20% dependendo de quanto HP perdeu." },
    passiva_dragon_ataque_2 : { Nivel: 2, Descricao: "Seu dano aumenta em ate 30% dependendo de quanto HP perdeu." },
    passiva_dragon_defesa_1 : { Nivel: 1, Descricao: "Resiste a debuffs de reducao de status." },
    passiva_dragon_defesa_2 : { Nivel: 2, Descricao: "Resiste a debuffs de reducao de status. (Efeito Dobrado)." },
    passiva_dragon_velocidade_1 : { Nivel: 1, Descricao: "Habilidades de dano macico carregam um pouco mais rapido quanto mais o HP desce." },
    passiva_dragon_velocidade_2 : { Nivel: 2, Descricao: "Habilidades de dano macico carregam um pouco mais rapido quanto mais o HP desce. (Efeito Dobrado)." },
    passiva_dark_ataque_1 : { Nivel: 1, Descricao: "Dano aumentado em 15% em alvos sob qualquer debuff." },
    passiva_dark_ataque_2 : { Nivel: 2, Descricao: "Dano aumentado em 22% em alvos sob qualquer debuff." },
    passiva_dark_defesa_1 : { Nivel: 1, Descricao: "Esquivas convertem 5% do HP do alvo para si." },
    passiva_dark_defesa_2 : { Nivel: 2, Descricao: "Esquivas convertem 7% do HP do alvo para si." },
    passiva_dark_velocidade_1 : { Nivel: 1, Descricao: "Aproveita o CD alto do alvo para atacar mais rapido." },
    passiva_dark_velocidade_2 : { Nivel: 2, Descricao: "Aproveita o CD alto do alvo para atacar mais rapido. (Efeito Dobrado)." },
    passiva_steel_ataque_1 : { Nivel: 1, Descricao: "Converte 5% da Defesa total em bonus de Ataque base." },
    passiva_steel_ataque_2 : { Nivel: 2, Descricao: "Converte 7% da Defesa total em bonus de Ataque base." },
    passiva_steel_defesa_1 : { Nivel: 1, Descricao: "Bloqueia e reflete passivamente 5% do dano basico recebido." },
    passiva_steel_defesa_2 : { Nivel: 2, Descricao: "Bloqueia e reflete passivamente 7% do dano basico recebido." },
    passiva_steel_velocidade_1 : { Nivel: 1, Descricao: "Nao sofre penalidades de lentidao por terreno ou status leves." },
    passiva_steel_velocidade_2 : { Nivel: 2, Descricao: "Nao sofre penalidades de lentidao por terreno ou status leves. (Efeito Dobrado)." },
    passiva_fairy_ataque_1 : { Nivel: 1, Descricao: "Punicoes e habilidades Ofuscantes tem +10% de eficiendia." },
    passiva_fairy_ataque_2 : { Nivel: 2, Descricao: "Punicoes e habilidades Ofuscantes tem +15% de eficiendia." },
    passiva_fairy_defesa_1 : { Nivel: 1, Descricao: "Luz Purificadora aumenta curas recebidas em 15%." },
    passiva_fairy_defesa_2 : { Nivel: 2, Descricao: "Luz Purificadora aumenta curas recebidas em 22%." },
    passiva_fairy_velocidade_1 : { Nivel: 1, Descricao: "Aplica um Ofuscado passivo ao ser alvo de finalizadores." },
    passiva_fairy_velocidade_2 : { Nivel: 2, Descricao: "Aplica um Ofuscado passivo ao ser alvo de finalizadores. (Efeito Dobrado)." },
};

function pokemon_get_passiva_data(_passiva_id) {
    if (variable_struct_exists(global.passivas_db, _passiva_id)) {
        return variable_struct_get(global.passivas_db, _passiva_id);
    }
    return undefined;
}

function pokemon_get_opcoes_passiva_draft(_pokemon_data) {
    if (!is_struct(_pokemon_data)) return [];
    
    var _atual = variable_struct_exists(_pokemon_data, "PassivaAtual") ? _pokemon_data.PassivaAtual : "";
    if (_atual == "") return [];
    
    var _split = string_split(_atual, "_");
    // Formato: passiva_fire_ataque_1
    if (array_length(_split) < 4) return [];
    
    var _tipo_str = _split[1];
    var _foco_str = _split[2];
    var _nivel = real(_split[3]);
    
    if (_nivel >= 2) return []; // Já está no máximo
    
    var _opcoes = [];
    
    // Opção A: Aprimorar a passiva atual
    var _opcao_a = "passiva_" + _tipo_str + "_" + _foco_str + "_2";
    array_push(_opcoes, _opcao_a);
    
    // Opção B: Pegar passiva secundária (Outro tipo ou Outro Foco)
    var _tipo2_str = pokemon_tipo_string(_pokemon_data.Tipo2);
    
    if (_pokemon_data.Tipo2 != PokemonTipo.NONE && _tipo2_str != "normal" && _tipo2_str != "") {
        // Pega do tipo 2, mantendo o mesmo foco da criatura (ex: se é tanque fogo/pedra, pega pedra_defesa)
        var _opcao_b = "passiva_" + _tipo2_str + "_" + _foco_str + "_1";
        array_push(_opcoes, _opcao_b);
    } else {
        // Se não tem tipo 2, pega um foco diferente do Tipo 1 aleatoriamente
        var _focos_alt = ["ataque", "defesa", "velocidade"];
        var _alt = _focos_alt[irandom(2)];
        while (_alt == _foco_str) {
            _alt = _focos_alt[irandom(2)];
        }
        var _opcao_b = "passiva_" + _tipo_str + "_" + _alt + "_1";
        array_push(_opcoes, _opcao_b);
    }
    
    return _opcoes;
}

