// Extras de combate (Sprint 5):
// - Sinergia cruzada entre habilidades equipadas (datafiles/data/sinergias.json)
// - Aviso grande de COMBO / DANO SINERGICO / SINERGIA na tela
// - Projetil e particulas de impacto por tipo

// ------------------------------------------------------------------ sinergia cruzada

function sinergias_db() {
    if (!variable_global_exists("sinergias_cache") || !is_array(global.sinergias_cache)) {
        var _json = conteudo_ler_json("datafiles/data/sinergias.json");
        var _lista = conteudo_struct_get(_json, "sinergias", []);
        global.sinergias_cache = [];

        for (var _i = 0; _i < array_length(_lista); _i += 1) {
            var _s = _lista[_i];
            array_push(global.sinergias_cache, {
                Tipo: conteudo_tipo_de_texto(_s.tipo),
                Requer: conteudo_tipo_de_texto(_s.requer),
                Efeito: string(_s.efeito),
                Chance: real(conteudo_struct_get(_s, "chance", 1)),
                Nome: string(conteudo_struct_get(_s, "nome", "Sinergia"))
            });
        }
    }

    return global.sinergias_cache;
}

function sinergia_tipo_habilidade(_habilidade) {
    if (!is_struct(_habilidade)) {
        return PokemonTipo.NONE;
    }

    return variable_struct_exists(_habilidade, "TipoElementar") ? _habilidade.TipoElementar : _habilidade.Tipo;
}

// Regras ativas para esta habilidade, dado o conjunto de habilidades equipadas (array de structs).
function sinergias_ativas(_equipadas, _habilidade) {
    var _ativas = [];
    var _tipo = sinergia_tipo_habilidade(_habilidade);

    if (_tipo == PokemonTipo.NONE || !is_array(_equipadas)) {
        return _ativas;
    }

    var _regras = sinergias_db();

    for (var _r = 0; _r < array_length(_regras); _r += 1) {
        var _regra = _regras[_r];

        if (_regra.Tipo != _tipo) {
            continue;
        }

        for (var _i = 0; _i < array_length(_equipadas); _i += 1) {
            var _outra = _equipadas[_i];

            if (is_struct(_outra) && _outra.ID != _habilidade.ID && sinergia_tipo_habilidade(_outra) == _regra.Requer) {
                array_push(_ativas, _regra);
                break;
            }
        }
    }

    return _ativas;
}

// Aplica os efeitos de sinergia de um golpe que acertou. Devolve quantos efeitos sairam.
function sinergia_aplicar(_atacante, _alvo, _habilidade) {
    if (!instance_exists(_atacante) || !instance_exists(_alvo) || !_alvo.vivo) {
        return 0;
    }

    var _equipadas = variable_instance_exists(_atacante, "habilidades_equipadas") ? _atacante.habilidades_equipadas : [];
    var _regras = sinergias_ativas(_equipadas, _habilidade);
    var _aplicadas = 0;

    for (var _i = 0; _i < array_length(_regras); _i += 1) {
        var _regra = _regras[_i];

        if (random(1) >= _regra.Chance) {
            continue;
        }

        pokemon_status_aplicar(_alvo, _regra.Efeito, pokemon_combate_status_duracao_padrao(_regra.Efeito));
        battle_log_push("SINERGIA (" + string_upper(_regra.Nome) + ")! " + string_upper(_alvo.pokemon_nome) + " ficou " + string_upper(_regra.Efeito) + "!");
        _aplicadas += 1;
    }

    return _aplicadas;
}

// Texto curto para cards/descricoes: "Sinergia: Ferrao toxico (Envenenado)".
function sinergia_texto(_equipadas, _habilidade) {
    var _regras = sinergias_ativas(_equipadas, _habilidade);
    var _partes = [];

    for (var _i = 0; _i < array_length(_regras); _i += 1) {
        array_push(_partes, _regras[_i].Nome + " (" + _regras[_i].Efeito + ")");
    }

    return array_length(_partes) > 0 ? "Sinergia: " + string_join_ext(", ", _partes) : "";
}

// ------------------------------------------------------------------ aviso de combo

function battle_combo_push(_x, _y, _texto, _cor) {
    if (!variable_global_exists("battle_combo_texts") || !is_array(global.battle_combo_texts)) {
        global.battle_combo_texts = [];
    }

    // Um aviso por vez por alvo: o novo substitui o antigo se ainda estiver na tela.
    for (var _i = array_length(global.battle_combo_texts) - 1; _i >= 0; _i -= 1) {
        if (abs(global.battle_combo_texts[_i].X - _x) < 40) {
            array_delete(global.battle_combo_texts, _i, 1);
        }
    }

    array_push(global.battle_combo_texts, { X: _x, Y: _y, Texto: _texto, Cor: _cor, Timer: 1.1, Duracao: 1.1 });
}

function battle_combo_step(_dt) {
    if (!variable_global_exists("battle_combo_texts") || !is_array(global.battle_combo_texts)) {
        return;
    }

    for (var _i = array_length(global.battle_combo_texts) - 1; _i >= 0; _i -= 1) {
        var _item = global.battle_combo_texts[_i];
        _item.Timer -= _dt;
        _item.Y -= 14 * _dt;

        if (_item.Timer <= 0) {
            array_delete(global.battle_combo_texts, _i, 1);
        }
    }
}

function battle_combo_draw_gui() {
    if (!variable_global_exists("battle_combo_texts") || !is_array(global.battle_combo_texts)) {
        return;
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    for (var _i = 0; _i < array_length(global.battle_combo_texts); _i += 1) {
        var _item = global.battle_combo_texts[_i];
        var _vida = 1 - (_item.Timer / _item.Duracao);
        var _escala = _vida < 0.18 ? lerp(2.4, 1.5, _vida / 0.18) : 1.5 + (sin(current_time * 0.03) * 0.05);
        var _alpha = clamp(_item.Timer / 0.35, 0, 1);
        var _piscar = (floor(current_time / 70) mod 2 == 0) ? _item.Cor : merge_color(_item.Cor, c_white, 0.55);

        draw_set_alpha(_alpha);
        draw_set_color(c_black);
        draw_text_transformed(_item.X + 3, _item.Y + 3, _item.Texto, _escala, _escala, -4);
        draw_set_color(_piscar);
        draw_text_transformed(_item.X, _item.Y, _item.Texto, _escala, _escala, -4);
    }

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// ------------------------------------------------------------------ VFX por tipo

function battle_particulas_sistema() {
    if (!variable_global_exists("battle_part_sys") || !part_system_exists(global.battle_part_sys)) {
        global.battle_part_sys = part_system_create();
        part_system_depth(global.battle_part_sys, -2000);
        global.battle_part_tipos = {};
    }

    return global.battle_part_sys;
}

function battle_particula_tipo(_tipo) {
    battle_particulas_sistema();
    var _chave = string(_tipo);

    if (variable_struct_exists(global.battle_part_tipos, _chave)) {
        return variable_struct_get(global.battle_part_tipos, _chave);
    }

    var _pt = part_type_create();
    var _cor = battle_ui_type_color(_tipo);
    var _shape = pt_shape_flare;
    var _gravidade = 0;
    var _vel_min = 1.5;
    var _vel_max = 4.5;

    switch (_tipo) {
        case PokemonTipo.FIRE: _shape = pt_shape_flare; _gravidade = -0.06; break;
        case PokemonTipo.WATER: _shape = pt_shape_disk; _gravidade = 0.12; break;
        case PokemonTipo.GRASS: _shape = pt_shape_square; _gravidade = 0.03; break;
        case PokemonTipo.ELECTRIC: _shape = pt_shape_spark; _vel_min = 3; _vel_max = 7; break;
        case PokemonTipo.ICE: _shape = pt_shape_snow; _gravidade = 0.04; break;
        case PokemonTipo.POISON: _shape = pt_shape_sphere; _gravidade = -0.03; _vel_max = 2.5; break;
        case PokemonTipo.GROUND: _shape = pt_shape_smoke; _gravidade = 0.08; break;
        case PokemonTipo.ROCK: _shape = pt_shape_square; _gravidade = 0.18; break;
        case PokemonTipo.FLYING: _shape = pt_shape_line; _vel_min = 3; _vel_max = 6; break;
        case PokemonTipo.PSYCHIC: _shape = pt_shape_ring; _vel_max = 2.5; break;
        case PokemonTipo.BUG: _shape = pt_shape_pixel; _vel_min = 2; _vel_max = 5; break;
        case PokemonTipo.GHOST: _shape = pt_shape_cloud; _gravidade = -0.05; _vel_max = 2; break;
        case PokemonTipo.DRAGON: _shape = pt_shape_explosion; break;
        case PokemonTipo.DARK: _shape = pt_shape_smoke; _vel_max = 3; break;
        case PokemonTipo.STEEL: _shape = pt_shape_star; _gravidade = 0.06; break;
        case PokemonTipo.FAIRY: _shape = pt_shape_star; _gravidade = -0.02; _vel_max = 3; break;
        case PokemonTipo.FIGHTING: _shape = pt_shape_explosion; _vel_max = 3.5; break;
    }

    part_type_shape(_pt, _shape);
    part_type_size(_pt, 0.18, 0.42, -0.006, 0);
    part_type_colour3(_pt, merge_color(_cor, c_white, 0.6), _cor, merge_color(_cor, c_black, 0.3));
    part_type_alpha3(_pt, 1, 0.85, 0);
    part_type_speed(_pt, _vel_min, _vel_max, -0.08, 0);
    part_type_direction(_pt, 0, 360, 0, 6);
    part_type_orientation(_pt, 0, 360, 4, 0, false);
    part_type_life(_pt, 18, 34);

    if (_gravidade != 0) {
        part_type_gravity(_pt, abs(_gravidade), _gravidade > 0 ? 270 : 90);
    }

    if (_tipo == PokemonTipo.FIRE || _tipo == PokemonTipo.ELECTRIC || _tipo == PokemonTipo.FAIRY || _tipo == PokemonTipo.PSYCHIC || _tipo == PokemonTipo.DRAGON) {
        part_type_blend(_pt, true);
    }

    variable_struct_set(global.battle_part_tipos, _chave, _pt);
    return _pt;
}

function battle_vfx_impacto(_x, _y, _tipo, _forte) {
    var _sys = battle_particulas_sistema();
    part_particles_create(_sys, _x, _y, battle_particula_tipo(_tipo), _forte ? 28 : 14);
}

function battle_vfx_draw_projetil(_x, _y, _tipo, _direcao, _t) {
    var _cor = battle_ui_type_color(_tipo);
    var _claro = merge_color(_cor, c_white, 0.55);
    var _escuro = merge_color(_cor, c_black, 0.45);
    var _d = _direcao == 0 ? 1 : _direcao;

    switch (_tipo) {
        case PokemonTipo.FIRE:
            for (var _f = 3; _f >= 0; _f -= 1) {
                draw_set_alpha(0.25 + (0.18 * (3 - _f)));
                draw_set_color(_f > 1 ? _cor : make_color_rgb(255, 230, 120));
                draw_circle(_x - (_d * _f * 9), _y + (sin(_t + _f) * 2), 9 - (_f * 1.5) + (sin(_t * 3) * 1.5), false);
            }
            break;

        case PokemonTipo.WATER:
            draw_set_color(_cor);
            draw_circle(_x, _y, 7, false);
            draw_triangle(_x - (_d * 4), _y - 6, _x - (_d * 4), _y + 6, _x - (_d * 16), _y, false);
            draw_set_color(_claro);
            draw_circle(_x + (_d * 2), _y - 2, 2.5, false);
            break;

        case PokemonTipo.GRASS:
        case PokemonTipo.BUG:
            for (var _g = 0; _g < 3; _g += 1) {
                var _ang = (_t * 4) + (_g * 120);
                var _gx = _x + lengthdir_x(9, _ang);
                var _gy = _y + lengthdir_y(9, _ang);
                draw_set_color(_g == 0 ? _claro : _cor);
                draw_triangle(_gx, _gy - 5, _gx + 5, _gy, _gx - 5, _gy + 3, false);
            }
            break;

        case PokemonTipo.ELECTRIC:
            draw_set_color(_cor);
            var _px = _x - 18;
            var _py = _y;

            for (var _e = 1; _e <= 5; _e += 1) {
                var _nx = _x - 18 + (_e * 7);
                var _ny = _y + irandom_range(-6, 6);
                draw_line_width(_px, _py, _nx, _ny, 3);
                _px = _nx;
                _py = _ny;
            }

            draw_set_color(c_white);
            draw_circle(_x, _y, 3, false);
            break;

        case PokemonTipo.ICE:
        case PokemonTipo.STEEL:
            draw_set_color(_cor);
            draw_triangle(_x, _y - 9, _x + 7, _y, _x, _y + 9, false);
            draw_triangle(_x, _y - 9, _x - 7, _y, _x, _y + 9, false);
            draw_set_color(_claro);
            draw_triangle(_x, _y - 6, _x + 3, _y, _x, _y + 2, false);
            break;

        case PokemonTipo.POISON:
        case PokemonTipo.GHOST:
            for (var _p = 0; _p < 4; _p += 1) {
                draw_set_alpha(0.75 - (_p * 0.15));
                draw_set_color(_p == 0 ? _claro : _cor);
                draw_circle(_x - (_d * _p * 7), _y + (sin(_t * 2 + _p) * 4), 6 - _p, false);
            }
            break;

        case PokemonTipo.GROUND:
        case PokemonTipo.ROCK:
            draw_set_color(_escuro);
            draw_circle(_x, _y, 8, false);
            draw_set_color(_cor);
            draw_triangle(_x - 6, _y - 5, _x + 7, _y - 3, _x + 1, _y + 6, false);
            break;

        case PokemonTipo.FLYING:
            draw_set_color(c_white);
            draw_line_width(_x - (_d * 18), _y - 6, _x + (_d * 4), _y - 2, 2);
            draw_line_width(_x - (_d * 14), _y + 5, _x + (_d * 6), _y + 2, 2);
            draw_set_color(_claro);
            draw_circle(_x + (_d * 4), _y, 4, false);
            break;

        case PokemonTipo.PSYCHIC:
        case PokemonTipo.FAIRY:
            draw_set_color(_cor);
            draw_circle(_x, _y, 6 + (sin(_t * 3) * 2), true);
            draw_circle(_x, _y, 11 + (sin(_t * 3 + 1) * 2), true);
            draw_set_color(_claro);
            draw_circle(_x, _y, 3, false);
            break;

        case PokemonTipo.DRAGON:
            draw_set_alpha(0.5);
            draw_set_color(make_color_rgb(255, 150, 70));
            draw_circle(_x, _y, 12, false);
            draw_set_alpha(1);
            draw_set_color(_cor);
            draw_circle(_x, _y, 8, false);
            break;

        case PokemonTipo.DARK:
            draw_set_color(_escuro);
            draw_line_width(_x - 10, _y + 10, _x + 10, _y - 10, 5);
            draw_set_color(_cor);
            draw_line_width(_x - 8, _y + 8, _x + 8, _y - 8, 2);
            break;

        case PokemonTipo.FIGHTING:
            draw_set_color(_cor);
            draw_circle(_x, _y, 8, false);
            draw_set_color(c_white);

            for (var _l = 0; _l < 4; _l += 1) {
                var _la = (_l * 90) + 45;
                draw_line(_x + lengthdir_x(9, _la), _y + lengthdir_y(9, _la), _x + lengthdir_x(14, _la), _y + lengthdir_y(14, _la));
            }
            break;

        default:
            draw_set_color(make_color_rgb(96, 232, 255));
            draw_circle(_x, _y, 5, false);
            draw_set_color(c_white);
            draw_circle(_x, _y, 2, false);
            break;
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}
