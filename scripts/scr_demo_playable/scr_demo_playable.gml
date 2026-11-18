enum DemoEstado {
    MENU,
    META_LOJA,
    INTRO,
    ESCOLHA_INICIAL,
    CIDADE,
    POKESTORE,
    LAB_CARVALHO,
    MOCHILA,
    GINASIO,
    CASA_MAE,
    SAIR_CIDADE,
    ROTA,
    BATALHA,
    CAPTURA,
    VITORIA,
    DERROTA,
    GAME_OVER
}

function demo_draw_sprite_cover(_spr, _x, _y, _w, _h, _alpha) {
    if (!sprite_exists(_spr)) {
        return;
    }

    var _scale = max(_w / max(1, sprite_get_width(_spr)), _h / max(1, sprite_get_height(_spr)));
    var _draw_w = sprite_get_width(_spr) * _scale;
    var _draw_h = sprite_get_height(_spr) * _scale;
    draw_sprite_ext(_spr, 0, _x + ((_w - _draw_w) * 0.5), _y + ((_h - _draw_h) * 0.5), _scale, _scale, 0, c_white, _alpha);
}

function demo_draw_sprite_stretch(_spr, _x, _y, _w, _h, _alpha) {
    if (!sprite_exists(_spr)) {
        return;
    }

    draw_sprite_stretched_ext(_spr, 0, _x, _y, _w, _h, c_white, _alpha);
}

function demo_draw_sprite_grounded(_spr, _x, _ground_y, _scale, _face_dir, _blend, _alpha) {
    if (!sprite_exists(_spr)) {
        return;
    }

    var _sx = _scale * _face_dir;
    var _sy = _scale;
    var _bbox_center_x = (sprite_get_bbox_left(_spr) + sprite_get_bbox_right(_spr)) * 0.5;
    var _bbox_bottom = sprite_get_bbox_bottom(_spr);
    var _draw_x = _x - ((_bbox_center_x - sprite_get_xoffset(_spr)) * _sx);
    var _draw_y = _ground_y - ((_bbox_bottom - sprite_get_yoffset(_spr)) * _sy);

    draw_sprite_ext(_spr, 0, _draw_x, _draw_y, _sx, _sy, 0, _blend, _alpha);
}

function demo_draw_external_pokemon_sprite(_spr, _x, _ground_y, _scale, _face_dir, _blend, _alpha) {
    demo_draw_sprite_grounded(_spr, _x, _ground_y, _scale, _face_dir, _blend, _alpha);
}

function demo_intro_id_chefe() {
    return criatura_id_por_nome(conteudo_mundo_texto("chefe_final", "Aeonox"));
}

function demo_intro_id_guardiao(_indice) {
    var _guardioes = conteudo_struct_get(conteudo_garantir().Mundo, "guardioes", []);

    if (_indice >= 0 && _indice < array_length(_guardioes)) {
        return criatura_id_por_nome(_guardioes[_indice]);
    }

    return 0;
}

function demo_intro_pokemon_bob(_pokemon_id, _scale) {
    return sin(current_time * 0.004 + (_pokemon_id * 0.21)) * 4 * _scale;
}

function demo_draw_intro_pokemon(_spr, _pokemon_id, _x, _ground_y, _scale, _face_dir, _blend, _alpha) {
    var _bob = demo_intro_pokemon_bob(_pokemon_id, _scale);
    var _breath = 1 + (sin(current_time * 0.005 + (_pokemon_id * 0.13)) * 0.025);
    var _draw_y = _ground_y + _bob;
    var _glow = make_color_rgb(180, 220, 255);

    if (_pokemon_id == demo_intro_id_chefe()) {
        _glow = make_color_rgb(190, 112, 255);
    } else if (_pokemon_id == demo_intro_id_guardiao(0)) {
        _glow = make_color_rgb(255, 142, 226);
    } else if (_pokemon_id == demo_intro_id_guardiao(1)) {
        _glow = make_color_rgb(168, 255, 126);
    }

    draw_set_alpha(_alpha * 0.24);
    draw_set_color(c_black);
    draw_ellipse(_x - 34 * _scale, _ground_y - 10 * _scale, _x + 34 * _scale, _ground_y + 8 * _scale, false);
    draw_set_alpha(1);

    if (sprite_exists(_spr)) {
        draw_set_alpha(_alpha * (0.20 + (sin(current_time * 0.006 + _pokemon_id) * 0.05)));
        draw_set_color(_glow);
        draw_circle(_x, _draw_y - 62 * _scale, 38 * _scale, true);
        draw_set_alpha(1);

        demo_draw_external_pokemon_sprite(_spr, _x - (2 * _face_dir), _draw_y - 1, _scale * _breath * 1.08, _face_dir, c_black, _alpha * 0.22);
        demo_draw_external_pokemon_sprite(_spr, _x + (2 * _face_dir), _draw_y + 1, _scale * _breath * 1.07, _face_dir, _glow, _alpha * 0.26);
        demo_draw_external_pokemon_sprite(_spr, _x, _draw_y, _scale * _breath, _face_dir, _blend, _alpha);
        return;
    }

    draw_set_alpha(_alpha);
    demo_draw_pokemon_sprite(_pokemon_id, _x, _draw_y, _scale * _breath, _face_dir, 0);
    draw_set_alpha(1);
}

function demo_draw_sheet_frame_centered(_spr, _cols, _rows, _frame, _cx, _cy, _scale, _blend, _alpha) {
    if (!sprite_exists(_spr)) {
        return;
    }

    _cols = max(1, floor(_cols));
    _rows = max(1, floor(_rows));
    var _fw = sprite_get_width(_spr) / _cols;
    var _fh = sprite_get_height(_spr) / _rows;
    var _total = _cols * _rows;
    var _index = floor(_frame) mod _total;
    var _col = _index mod _cols;
    var _row = _index div _cols;
    var _draw_w = _fw * _scale;
    var _draw_h = _fh * _scale;

    draw_sprite_part_ext(_spr, 0, _col * _fw, _row * _fh, _fw, _fh, _cx - (_draw_w * 0.5), _cy - (_draw_h * 0.5), _scale, _scale, _blend, _alpha);
}

function demo_draw_title_energy_beam(_x1, _y1, _x2, _y2, _color_outer, _color_inner, _alpha, _jitter) {
    _alpha = clamp(_alpha, 0, 1);
    var _time = current_time * 0.001;
    var _seed = (_x1 * 0.013) + (_y1 * 0.017) + (_x2 * 0.011) + (_y2 * 0.019);
    var _surge = power(max(0, sin((_time * 5.8) + _seed)), 8);
    var _pulse = 0.82 + (sin((_time * 18.0) + _seed) * 0.18) + (_surge * 0.42);
    var _wide = 16 + (_jitter * 1.08) + (_surge * 24);
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _len = max(1, point_distance(_x1, _y1, _x2, _y2));
    var _nx = -_dy / _len;
    var _ny = _dx / _len;
    var _wobble = 4 + (_jitter * 0.72) + (_surge * 8);
    var _mx = (_x1 + _x2) * 0.5 + (_nx * sin((_time * 13.0) + _seed) * _wobble);
    var _my = (_y1 + _y2) * 0.5 + (_ny * cos((_time * 12.0) + _seed) * _wobble);

    draw_set_alpha(_alpha * 0.24 * _pulse);
    draw_set_color(_color_outer);
    draw_line_width(_x1, _y1, _mx, _my, _wide + 10);
    draw_line_width(_mx, _my, _x2, _y2, _wide + 10);
    draw_set_alpha(_alpha * 0.48 * _pulse);
    draw_line_width(_x1, _y1, _mx, _my, _wide);
    draw_line_width(_mx, _my, _x2, _y2, _wide);
    draw_set_alpha(_alpha * 0.76);
    draw_line_width(_x1, _y1, _mx, _my, 8 + (_jitter * 0.55) + (_surge * 8));
    draw_line_width(_mx, _my, _x2, _y2, 8 + (_jitter * 0.55) + (_surge * 8));
    draw_set_alpha(_alpha);
    draw_set_color(_color_inner);
    draw_line_width(_x1, _y1, _mx, _my, 4 + (_surge * 3));
    draw_line_width(_mx, _my, _x2, _y2, 4 + (_surge * 3));
    draw_set_alpha(_alpha * 0.40);
    draw_set_color(c_white);
    draw_line_width(_x1 + 2, _y1 - 2, _mx + 2, _my - 2, 2);
    draw_line_width(_mx + 2, _my - 2, _x2 + 2, _y2 - 2, 2);

    for (var _i = 0; _i < 8; _i += 1) {
        var _t = frac((_time * (0.72 + (_surge * 0.35))) + (_i / 8) + (_seed * 0.11));
        var _spark_x = lerp(_x1, _x2, _t) + (_nx * sin((_time * 20.0) + _i + _seed) * (_wobble + 4));
        var _spark_y = lerp(_y1, _y2, _t) + (_ny * cos((_time * 18.0) + (_i * 1.31) + _seed) * (_wobble + 4));
        var _spark_len = 8 + (_surge * 12) + ((_i mod 3) * 3);
        var _spark_alpha = _alpha * clamp(0.32 + (sin((_time * 16.0) + _i + _seed) * 0.35) + (_surge * 0.32), 0.16, 0.92);

        draw_set_alpha(_spark_alpha);
        draw_set_color((_i mod 2) == 0 ? _color_inner : c_white);
        draw_line_width(
            _spark_x - (_nx * _spark_len),
            _spark_y - (_ny * _spark_len),
            _spark_x + (_nx * _spark_len),
            _spark_y + (_ny * _spark_len),
            2 + (_surge * 2)
        );

        if ((_i mod 3) == 0) {
            draw_set_alpha(_spark_alpha * 0.55);
            draw_set_color(_color_outer);
            draw_circle(_spark_x, _spark_y, 3 + (_surge * 5), false);
        }
    }

    draw_set_alpha(1);
}

function demo_draw_title_spark_field(_cx, _cy, _radius, _color, _alpha, _count) {
    var _time = current_time * 0.001;

    for (var _i = 0; _i < _count; _i += 1) {
        var _angle = (_i * 2.399) + (_time * (2.8 + ((_i mod 3) * 0.45)));
        var _dist = _radius * clamp(0.62 + (sin((_time * 4.6) + _i) * 0.30), 0.25, 1.0);
        var _sx = _cx + (cos(_angle) * _dist);
        var _sy = _cy + (sin(_angle) * (_dist * 0.55));
        var _len = 8 + (sin((_time * 7.0) + (_i * 1.7)) * 4);
        var _spark_alpha = _alpha * clamp(0.45 + (sin((_time * 8.0) + _i) * 0.45), 0.12, 0.95);

        draw_set_alpha(_spark_alpha);
        draw_set_color(_color);
        draw_line_width(_sx - (_len * 0.5), _sy, _sx + (_len * 0.5), _sy + (sin(_angle) * 4), 2);

        if ((_i mod 4) == 0) {
            draw_set_alpha(_spark_alpha * 0.70);
            draw_set_color(c_white);
            draw_rectangle(_sx - 2, _sy - 2, _sx + 2, _sy + 2, false);
        }
    }

    draw_set_alpha(1);
}

function demo_draw_space_crack(_cx, _cy, _height, _alpha, _power) {
    var _time = current_time * 0.001;
    var _points = 11;
    var _prev_x = _cx;
    var _prev_y = _cy - (_height * 0.5);
    var _glow = 0.35 + (sin(_time * 5.0) * 0.10);

    draw_set_alpha(_alpha * (0.18 + (_power * 0.20)));
    draw_set_color(make_color_rgb(72, 224, 232));
    draw_circle(_cx, _cy, 108 + (sin(_time * 3.4) * 8) + (_power * 34), true);
    draw_set_alpha(_alpha * (0.12 + (_power * 0.16)));
    draw_set_color(make_color_rgb(255, 96, 196));
    draw_circle(_cx, _cy, 148 + (sin(_time * 2.2) * 10) + (_power * 48), true);

    for (var _layer = 0; _layer < 3; _layer += 1) {
        _prev_x = _cx;
        _prev_y = _cy - (_height * 0.5);
        var _line_w = _layer == 0 ? 10 : (_layer == 1 ? 5 : 2);
        var _line_alpha = _alpha * (_layer == 0 ? 0.16 : (_layer == 1 ? 0.44 : 0.95));
        var _color = _layer == 2 ? c_white : (_layer == 1 ? make_color_rgb(96, 246, 238) : make_color_rgb(44, 144, 178));

        draw_set_alpha(_line_alpha * (0.86 + _glow));
        draw_set_color(_color);

        for (var _i = 1; _i <= _points; _i += 1) {
            var _p = _i / _points;
            var _offset = sin((_i * 1.74) + (_time * 4.1)) * (20 + (_power * 10));
            var _nx = _cx + _offset + (sin(_i * 4.7) * 10);
            var _ny = _cy - (_height * 0.5) + (_height * _p);

            draw_line_width(_prev_x, _prev_y, _nx, _ny, _line_w);

            if (_layer == 2 && (_i == 3 || _i == 5 || _i == 8 || _i == 10)) {
                var _dir = ((_i mod 2) == 0) ? 1 : -1;
                var _branch_len = 42 + (_i * 4) + (sin(_time * 6 + _i) * 9);
                var _branch_y = _ny + (sin(_time * 3 + _i) * 7);

                draw_set_alpha(_alpha * 0.72);
                draw_set_color(((_i mod 3) == 0) ? make_color_rgb(255, 116, 204) : make_color_rgb(92, 246, 238));
                draw_line_width(_nx, _ny, _nx + (_dir * _branch_len), _branch_y - 18, 2);
                draw_set_alpha(_line_alpha * (0.86 + _glow));
                draw_set_color(_color);
            }

            _prev_x = _nx;
            _prev_y = _ny;
        }
    }

    for (var _s = 0; _s < 14; _s += 1) {
        var _spark_p = (_s + 1) / 15;
        var _spark_x = _cx + (sin((_s * 2.1) + (_time * 2.8)) * (92 + (_power * 36)));
        var _spark_y = _cy - (_height * 0.45) + (_height * _spark_p) + (sin(_time * 5 + _s) * 10);
        var _spark_a = _alpha * (0.18 + (0.18 * sin(_time * 7 + _s)));

        draw_set_alpha(clamp(_spark_a, 0.08, 0.42));
        draw_set_color(((_s mod 2) == 0) ? make_color_rgb(98, 238, 232) : make_color_rgb(255, 120, 208));
        draw_rectangle(_spark_x - 5, _spark_y - 1, _spark_x + 5, _spark_y + 1, false);
    }

    draw_set_alpha(1);
}

function demo_menu_start_button_rect() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _w = 300;
    var _h = 58;

    return {
        X: (_gw * 0.5) - 310,
        Y: _gh - 166,
        W: _w,
        H: _h
    };
}

function demo_menu_shop_button_rect() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _w = 380;
    var _h = 58;

    return {
        X: (_gw - _w) * 0.5,
        Y: _gh - 96,
        W: _w,
        H: _h
    };
}

function demo_draw_title_button(_rect, _label, _hover) {
    var _draw_rect = demo_hover_grow_rect(_rect.X, _rect.Y, _rect.W, _rect.H, _hover, 3);

    draw_set_halign(fa_left);
    draw_set_color(make_color_rgb(92, 58, 30));
    draw_rectangle(_draw_rect.X - 4, _draw_rect.Y + 5, _draw_rect.X + _draw_rect.W + 4, _draw_rect.Y + _draw_rect.H + 7, false);
    draw_set_color(_hover ? make_color_rgb(255, 232, 88) : make_color_rgb(242, 235, 208));
    draw_rectangle(_draw_rect.X, _draw_rect.Y, _draw_rect.X + _draw_rect.W, _draw_rect.Y + _draw_rect.H, false);
    draw_set_color(_hover ? make_color_rgb(255, 232, 88) : make_color_rgb(94, 84, 92));
    draw_rectangle(_draw_rect.X, _draw_rect.Y, _draw_rect.X + _draw_rect.W, _draw_rect.Y + _draw_rect.H, true);
    draw_rectangle(_draw_rect.X + 5, _draw_rect.Y + 5, _draw_rect.X + _draw_rect.W - 5, _draw_rect.Y + _draw_rect.H - 5, true);

    if (_hover) {
        draw_set_alpha(0.18);
        draw_set_color(c_white);
        draw_rectangle(_draw_rect.X + 8, _draw_rect.Y + 8, _draw_rect.X + _draw_rect.W - 8, _draw_rect.Y + _draw_rect.H - 8, false);
        draw_set_alpha(1);
    }

    draw_set_color(make_color_rgb(36, 30, 28));
    draw_set_valign(fa_middle);
    draw_text(_draw_rect.X + ((_draw_rect.W - string_width(_label)) * 0.5), _draw_rect.Y + (_draw_rect.H * 0.5), _label);
    draw_set_valign(fa_top);
}

function demo_meta_save_path() {
    // Nome antigo mantido para nao perder o progresso ja salvo.
    return (autoteste_ativo() ? "autoteste_" : "") + "pokemon_roguelike_meta.ini";
}

function demo_meta_default() {
    return {
        FragmentosEspaco: 0,
        starter_gen2: 0,
        starter_gen3: 0,
        starter_gen4: 0,
        starter_gen5: 0,
        starter_special: 0,
        shiny_chance: 0,
        trainer_chance: 0,
        money_gain: 0,
        start_money: 0,
        start_balls: 0,
        start_potions: 0,
        team_damage: 0,
        capture_focus: 0
    };
}

function demo_meta_upgrade_ids() {
    return [
        "starter_gen2", "starter_gen3", "starter_gen4", "starter_gen5", "starter_special",
        "shiny_chance", "trainer_chance", "money_gain", "start_money", "start_balls", "start_potions",
        "team_damage", "capture_focus"
    ];
}

function demo_meta_shop_entries() {
    return [
        { ID: "starter_gen2", Nome: conteudo_pacote_nome("starter_gen2"), Max: 1, Custos: [3], Descricao: demo_meta_starter_descricao("starter_gen2") },
        { ID: "starter_gen3", Nome: conteudo_pacote_nome("starter_gen3"), Max: 1, Custos: [4], Descricao: demo_meta_starter_descricao("starter_gen3") },
        { ID: "starter_gen4", Nome: conteudo_pacote_nome("starter_gen4"), Max: 1, Custos: [5], Descricao: demo_meta_starter_descricao("starter_gen4") },
        { ID: "starter_gen5", Nome: conteudo_pacote_nome("starter_gen5"), Max: 1, Custos: [6], Descricao: demo_meta_starter_descricao("starter_gen5") },
        { ID: "starter_special", Nome: conteudo_pacote_nome("starter_special"), Max: 1, Custos: [5], Descricao: demo_meta_starter_descricao("starter_special") },
        { ID: "shiny_chance", Nome: "Lente Cromatica", Max: 5, Custos: [2, 3, 5, 8, 12], Descricao: "+0.4% de chance de variante cromatica por nivel." },
        { ID: "trainer_chance", Nome: "Radar de Treinadores", Max: 4, Custos: [1, 2, 3, 5], Descricao: "+4% de chance de encontrar treinador em cada rota por nivel." },
        { ID: "money_gain", Nome: "Bolsa de Vitorias", Max: 5, Custos: [1, 2, 4, 6, 9], Descricao: "+8% de dinheiro recebido em batalhas por nivel." },
        { ID: "start_money", Nome: "Ajuda da Mae", Max: 4, Custos: [1, 2, 4, 6], Descricao: "Aumenta o dinheiro inicial: +50, +100, +150 e +200 M$." },
        { ID: "start_balls", Nome: "Kit de Captura", Max: 5, Custos: [1, 2, 4, 5, 8], Descricao: "Comeca com Capsulas melhores conforme evolui este kit." },
        { ID: "start_potions", Nome: "Kit de Sobrevivencia", Max: 5, Custos: [1, 2, 4, 6, 9], Descricao: "Comeca a run com pocoes e curas melhores." },
        { ID: "team_damage", Nome: "Eco Ofensivo", Max: 5, Custos: [2, 3, 5, 8, 13], Descricao: "+3% de dano para monstros aliados por nivel." },
        { ID: "capture_focus", Nome: "Laco de Fenda", Max: 4, Custos: [2, 3, 5, 8], Descricao: "+3% de chance plana de captura por nivel." }
    ];
}

function demo_meta_shop_entry_get(_id_upgrade) {
    var _entries = demo_meta_shop_entries();

    for (var _i = 0; _i < array_length(_entries); _i += 1) {
        if (_entries[_i].ID == _id_upgrade) {
            return _entries[_i];
        }
    }

    return undefined;
}

function demo_meta_upgrade_level(_meta, _id_upgrade) {
    if (!is_struct(_meta) || !variable_struct_exists(_meta, _id_upgrade)) {
        return 0;
    }

    return max(0, floor(real(variable_struct_get(_meta, _id_upgrade))));
}

function demo_meta_upgrade_cost(_meta, _entry) {
    if (!is_struct(_entry)) {
        return -1;
    }

    var _level = demo_meta_upgrade_level(_meta, _entry.ID);

    if (_level >= _entry.Max) {
        return -1;
    }

    return _entry.Custos[clamp(_level, 0, array_length(_entry.Custos) - 1)];
}

function demo_meta_percent_text(_value) {
    var _percent = _value * 100;

    if (abs(_percent - round(_percent)) < 0.01) {
        return string(round(_percent)) + "%";
    }

    return string_format(_percent, 1, 1) + "%";
}

function demo_meta_entry_description(_entry, _level) {
    if (!is_struct(_entry)) {
        return "";
    }

    if (_entry.ID == "shiny_chance") {
        var _chance = clamp(0.01 + (max(0, _level) * 0.004), 0.01, 0.035);
        return _entry.Descricao + "\nBase atual: " + demo_meta_percent_text(_chance) + ".";
    }

    return _entry.Descricao;
}

function demo_meta_carregar() {
    var _meta = demo_meta_default();
    var _path = demo_meta_save_path();

    if (file_exists(_path)) {
        ini_open(_path);
        _meta.FragmentosEspaco = max(0, floor(ini_read_real("meta", "fragmentos_espaco", 0)));

        var _ids = demo_meta_upgrade_ids();

        for (var _i = 0; _i < array_length(_ids); _i += 1) {
            var _id = _ids[_i];
            variable_struct_set(_meta, _id, max(0, floor(ini_read_real("upgrades", _id, 0))));
        }

        ini_close();
    }

    return _meta;
}

function demo_meta_salvar(_meta) {
    if (!is_struct(_meta)) {
        return false;
    }

    ini_open(demo_meta_save_path());
    ini_write_real("meta", "fragmentos_espaco", max(0, floor(_meta.FragmentosEspaco)));

    var _ids = demo_meta_upgrade_ids();

    for (var _i = 0; _i < array_length(_ids); _i += 1) {
        var _id = _ids[_i];
        ini_write_real("upgrades", _id, demo_meta_upgrade_level(_meta, _id));
    }

    ini_close();
    return true;
}

function demo_meta_sincronizar_globals(_meta) {
    if (!is_struct(_meta)) {
        _meta = demo_meta_default();
    }

    global.demo_meta_progresso = _meta;
    global.demo_meta_shiny_bonus = demo_meta_upgrade_level(_meta, "shiny_chance") * 0.004;
    global.demo_meta_trainer_chance_bonus = demo_meta_upgrade_level(_meta, "trainer_chance") * 0.04;
    global.demo_meta_money_mult = 1 + (demo_meta_upgrade_level(_meta, "money_gain") * 0.08);
    global.demo_meta_team_damage_mult = 1 + (demo_meta_upgrade_level(_meta, "team_damage") * 0.03);
    global.demo_meta_capture_bonus = demo_meta_upgrade_level(_meta, "capture_focus") * 0.03;
}

function demo_meta_dinheiro_aplicar(_controller, _valor) {
    var _mult = variable_global_exists("demo_meta_money_mult") ? global.demo_meta_money_mult : 1;
    return max(0, floor(_valor * _mult));
}

function demo_meta_dinheiro_inicial_bonus(_meta) {
    if (diario_ativo()) {
        return 0;
    }

    switch (demo_meta_upgrade_level(_meta, "start_money")) {
        case 1: return 50;
        case 2: return 100;
        case 3: return 150;
        case 4: return 200;
    }

    return 0;
}

function demo_meta_fragmentos_ginasio(_cidade_index) {
    if (_cidade_index >= 6) {
        return 10;
    }

    return max(1, _cidade_index - 1);
}

function demo_meta_fragmentos_adicionar(_controller, _qtd) {
    if (!instance_exists(_controller) || _qtd <= 0) {
        return 0;
    }

    if (diario_ativo() && !global.diario.Oficial) {
        return 0;
    }

    if (!is_struct(_controller.meta_progresso)) {
        _controller.meta_progresso = demo_meta_carregar();
    }

    _controller.meta_progresso.FragmentosEspaco = max(0, floor(_controller.meta_progresso.FragmentosEspaco + _qtd));
    demo_meta_salvar(_controller.meta_progresso);
    demo_meta_sincronizar_globals(diario_ativo() ? demo_meta_default() : _controller.meta_progresso);

    return _qtd;
}

function demo_meta_pool_push_all(_pool, _ids) {
    for (var _i = 0; _i < array_length(_ids); _i += 1) {
        array_push(_pool, _ids[_i]);
    }

    return _pool;
}

function demo_meta_starter_pacotes() {
    return ["starter_gen2", "starter_gen3", "starter_gen4", "starter_gen5", "starter_special"];
}

function demo_meta_starter_pool(_meta) {
    var _pool = conteudo_pacote_iniciais("base");
    var _pacotes = demo_meta_starter_pacotes();

    for (var _i = 0; _i < array_length(_pacotes); _i += 1) {
        if (demo_meta_upgrade_level(_meta, _pacotes[_i]) > 0) {
            _pool = demo_meta_pool_push_all(_pool, conteudo_pacote_iniciais(_pacotes[_i]));
        }
    }

    return _pool;
}

function demo_randomize_run_roll() {
    randomize();

    var _burn = 3 + (current_time mod 7);

    for (var _i = 0; _i < _burn; _i += 1) {
        irandom(1000000);
    }
}

function demo_meta_starter_roll(_meta) {
    demo_randomize_run_roll();

    var _pool = demo_meta_starter_pool(_meta);
    var _resultado = [];
    array_shuffle(_pool);

    while (array_length(_resultado) < 3 && array_length(_pool) > 0) {
        var _pick = irandom(array_length(_pool) - 1);
        array_push(_resultado, _pool[_pick]);
        array_delete(_pool, _pick, 1);
    }

    var _arr_fallback = conteudo_pacote_iniciais("base");
    while (array_length(_resultado) < 3 && array_length(_resultado) < array_length(_arr_fallback)) {
        array_push(_resultado, _arr_fallback[array_length(_resultado)]);
    }

    return _resultado;
}

function demo_meta_starter_entry_ids(_id_upgrade) {
    if (_id_upgrade == "base") {
        return [];
    }

    return conteudo_pacote_iniciais(_id_upgrade);
}

function demo_meta_starter_descricao(_id_upgrade) {
    var _ids = conteudo_pacote_iniciais(_id_upgrade);
    var _texto = "Libera ";

    for (var _i = 0; _i < array_length(_ids); _i += 1) {
        if (_i > 0) {
            _texto += (_i == array_length(_ids) - 1) ? " e " : ", ";
        }

        _texto += demo_pokemon_nome(_ids[_i]);
    }

    return _texto + ".";
}

function demo_meta_entry_is_starter(_entry) {
    if (!is_struct(_entry)) {
        return false;
    }

    return array_length(demo_meta_starter_entry_ids(_entry.ID)) > 0;
}

function demo_pokemon_preview_get(_pokemon_id) {
    if (!variable_global_exists("pokedex") || !is_struct(global.pokedex)) {
        return undefined;
    }

    return pokemon_db_get(global.pokedex, _pokemon_id);
}

function demo_pokemon_stat_base(_pokemon, _stat) {
    if (!is_struct(_pokemon)) {
        return 0;
    }

    switch (_stat) {
        case "hp": return variable_struct_exists(_pokemon, "BaseHpMax") ? _pokemon.BaseHpMax : _pokemon.HpMax;
        case "atk": return variable_struct_exists(_pokemon, "BaseAttack") ? _pokemon.BaseAttack : _pokemon.Attack;
        case "def": return variable_struct_exists(_pokemon, "BaseDefense") ? _pokemon.BaseDefense : _pokemon.Defense;
        case "spd": return variable_struct_exists(_pokemon, "BaseSpeed") ? _pokemon.BaseSpeed : _pokemon.Speed;
    }

    return 0;
}

function demo_pokemon_focus_label(_pokemon) {
    var _hp = demo_pokemon_stat_base(_pokemon, "hp");
    var _atk = demo_pokemon_stat_base(_pokemon, "atk");
    var _def = demo_pokemon_stat_base(_pokemon, "def");
    var _spd = demo_pokemon_stat_base(_pokemon, "spd");
    var _max_stat = max(max(_hp, _atk), max(_def, _spd));
    var _min_stat = min(min(_hp, _atk), min(_def, _spd));

    if (_max_stat - _min_stat <= 12) {
        return "EQUILIBRADO";
    }

    if (_max_stat == _hp) return "VIDA";
    if (_max_stat == _atk) return "ATAQUE";
    if (_max_stat == _def) return "DEFESA";
    return "VELOCIDADE";
}

function demo_pokemon_stat_pct(_pokemon, _stat) {
    var _value = demo_pokemon_stat_base(_pokemon, _stat);
    var _max_ref = _stat == "hp" ? 125 : 120;
    return clamp(_value / _max_ref, 0.08, 1);
}

function demo_draw_stat_bar(_label, _pct, _x, _y, _w, _color_fill) {
    draw_set_color(make_color_rgb(60, 50, 46));
    draw_text(_x, _y - 2, _label);
    draw_set_color(make_color_rgb(190, 184, 166));
    draw_rectangle(_x + 44, _y, _x + 44 + _w, _y + 10, false);
    draw_set_color(make_color_rgb(96, 82, 74));
    draw_rectangle(_x + 44, _y, _x + 44 + _w, _y + 10, true);
    draw_set_color(_color_fill);
    draw_rectangle(_x + 46, _y + 2, _x + 46 + ((_w - 4) * _pct), _y + 8, false);
}

function demo_draw_pokemon_stat_bars(_pokemon, _x, _y, _w, _compact) {
    if (!is_struct(_pokemon)) {
        return;
    }

    if (_compact) {
        var _labels = ["HP", "ATK", "DEF", "VEL"];
        var _stats = ["hp", "atk", "def", "spd"];
        var _colors = [
            make_color_rgb(104, 210, 96),
            make_color_rgb(232, 88, 72),
            make_color_rgb(88, 146, 224),
            make_color_rgb(242, 206, 78)
        ];
        var _bar_x = _x + 54;
        var _bar_w_compact = max(116, _w - 62);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(make_color_rgb(36, 30, 28));
        draw_text_transformed(_x, _y, "Foco: " + demo_pokemon_focus_label(_pokemon), 0.70, 0.70, 0);

        for (var _si = 0; _si < 4; _si += 1) {
            var _yy = _y + 24 + (_si * 14);
            draw_set_color(make_color_rgb(60, 50, 46));
            draw_text_transformed(_x, _yy - 3, _labels[_si], 0.54, 0.54, 0);
            draw_set_color(make_color_rgb(190, 184, 166));
            draw_rectangle(_bar_x, _yy, _bar_x + _bar_w_compact, _yy + 8, false);
            draw_set_color(make_color_rgb(96, 82, 74));
            draw_rectangle(_bar_x, _yy, _bar_x + _bar_w_compact, _yy + 8, true);
            draw_set_color(_colors[_si]);
            draw_rectangle(_bar_x + 2, _yy + 2, _bar_x + 2 + ((_bar_w_compact - 4) * demo_pokemon_stat_pct(_pokemon, _stats[_si])), _yy + 6, false);
        }

        return;
    }

    var _bar_w = max(52, _w - 52);
    var _line_h = _compact ? 12 : 16;
    var _old_halign = fa_left;
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(36, 30, 28));
    draw_text(_x, _y, "Foco: " + demo_pokemon_focus_label(_pokemon));

    var _bar_y = _y + (_compact ? 17 : 22);
    demo_draw_stat_bar("HP", demo_pokemon_stat_pct(_pokemon, "hp"), _x, _bar_y, _bar_w, make_color_rgb(104, 210, 96));
    demo_draw_stat_bar("ATK", demo_pokemon_stat_pct(_pokemon, "atk"), _x, _bar_y + _line_h, _bar_w, make_color_rgb(232, 88, 72));
    demo_draw_stat_bar("DEF", demo_pokemon_stat_pct(_pokemon, "def"), _x, _bar_y + (_line_h * 2), _bar_w, make_color_rgb(88, 146, 224));
    demo_draw_stat_bar("VEL", demo_pokemon_stat_pct(_pokemon, "spd"), _x, _bar_y + (_line_h * 3), _bar_w, make_color_rgb(242, 206, 78));
    draw_set_halign(_old_halign);
}

function demo_meta_aplicar_inicio_run(_controller) {
    if (!instance_exists(_controller)) {
        return false;
    }

    if (_controller.meta_inicio_aplicado) {
        return false;
    }

    if (!is_struct(_controller.meta_progresso)) {
        _controller.meta_progresso = demo_meta_carregar();
        demo_meta_sincronizar_globals(_controller.meta_progresso);
    }

    switch (demo_meta_upgrade_level(_controller.meta_progresso, "start_balls")) {
        case 1: demo_inventario_adicionar(_controller.inventario, "pokebola", 2); break;
        case 2: demo_inventario_adicionar(_controller.inventario, "pokebola", 5); break;
        case 3: demo_inventario_adicionar(_controller.inventario, "pokebola", 8); break;
        case 4: demo_inventario_adicionar(_controller.inventario, "great_ball", 5); break;
        case 5: demo_inventario_adicionar(_controller.inventario, "ultra_ball", 5); break;
    }

    switch (demo_meta_upgrade_level(_controller.meta_progresso, "start_potions")) {
        case 1: demo_inventario_adicionar(_controller.inventario, "potion", 1); break;
        case 2: demo_inventario_adicionar(_controller.inventario, "potion", 2); break;
        case 3: demo_inventario_adicionar(_controller.inventario, "super_potion", 3); break;
        case 4: demo_inventario_adicionar(_controller.inventario, "hyper_potion", 2); break;
        case 5:
            demo_inventario_adicionar(_controller.inventario, "full_restore", 1);
            demo_inventario_adicionar(_controller.inventario, "hyper_potion", 1);
            break;
    }

    _controller.meta_inicio_aplicado = true;
    return true;
}

function demo_meta_comprar(_controller, _id_upgrade) {
    if (!instance_exists(_controller)) {
        return false;
    }

    var _entry = demo_meta_shop_entry_get(_id_upgrade);

    if (!is_struct(_entry)) {
        return false;
    }

    if (!is_struct(_controller.meta_progresso)) {
        _controller.meta_progresso = demo_meta_carregar();
    }

    var _cost = demo_meta_upgrade_cost(_controller.meta_progresso, _entry);

    if (_cost < 0) {
        _controller.message = _entry.Nome + " ja esta no maximo.";
        return false;
    }

    if (_controller.meta_progresso.FragmentosEspaco < _cost) {
        _controller.message = "Fragmentos do Espaco insuficientes.";
        return false;
    }

    _controller.meta_progresso.FragmentosEspaco -= _cost;
    variable_struct_set(_controller.meta_progresso, _entry.ID, demo_meta_upgrade_level(_controller.meta_progresso, _entry.ID) + 1);
    demo_meta_salvar(_controller.meta_progresso);
    demo_meta_sincronizar_globals(_controller.meta_progresso);
    _controller.starter_ids = demo_meta_starter_roll(_controller.meta_progresso);
    _controller.message = "Comprou " + _entry.Nome + ".";

    return true;
}

function demo_meta_shop_view_rect() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    return {
        X: 82,
        Y: 138,
        W: _gw - 164,
        H: max(180, _gh - 286)
    };
}

function demo_meta_shop_card_height(_entry) {
    return demo_meta_entry_is_starter(_entry) ? 310 : 98;
}

function demo_meta_shop_content_height() {
    var _entries = demo_meta_shop_entries();
    var _gap_y = 12;
    var _height = 0;

    for (var _i = 0; _i < array_length(_entries); _i += 2) {
        var _row_h = demo_meta_shop_card_height(_entries[_i]);

        if (_i + 1 < array_length(_entries)) {
            _row_h = max(_row_h, demo_meta_shop_card_height(_entries[_i + 1]));
        }

        _height += _row_h;

        if (_i + 2 < array_length(_entries)) {
            _height += _gap_y;
        }
    }

    return _height + 18;
}

function demo_meta_shop_scroll_max() {
    var _view = demo_meta_shop_view_rect();
    return max(0, demo_meta_shop_content_height() - _view.H);
}

function demo_draw_meta_shop_scrollbar(_view, _scroll, _scroll_max) {
    if (_scroll_max <= 0) {
        return;
    }

    var _track_x = _view.X + _view.W - 12;
    var _track_y = _view.Y + 4;
    var _track_h = _view.H - 8;
    var _thumb_h = max(42, (_view.H / demo_meta_shop_content_height()) * _track_h);
    var _thumb_y = _track_y + ((_track_h - _thumb_h) * (_scroll / _scroll_max));

    draw_set_color(make_color_rgb(204, 198, 180));
    draw_rectangle(_track_x, _track_y, _track_x + 6, _track_y + _track_h, false);
    draw_set_color(make_color_rgb(118, 92, 70));
    draw_rectangle(_track_x, _thumb_y, _track_x + 6, _thumb_y + _thumb_h, false);
}

function demo_meta_shop_card_rect(_index) {
    var _gw = display_get_gui_width();
    var _scroll = argument_count >= 2 ? argument[1] : 0;
    var _view = demo_meta_shop_view_rect();
    var _entries = demo_meta_shop_entries();
    var _entry = _entries[_index];
    var _card_w = min(580, (_view.W - 50) * 0.5);
    var _card_h = demo_meta_shop_card_height(_entry);
    var _gap_x = 22;
    var _gap_y = 12;
    var _total_w = (_card_w * 2) + _gap_x;
    var _start_x = _view.X + ((_view.W - _total_w) * 0.5);
    var _col = _index mod 2;
    var _row = _index div 2;
    var _y = _view.Y - _scroll;

    for (var _i = 0; _i < _row * 2; _i += 2) {
        var _row_h = demo_meta_shop_card_height(_entries[_i]);

        if (_i + 1 < array_length(_entries)) {
            _row_h = max(_row_h, demo_meta_shop_card_height(_entries[_i + 1]));
        }

        _y += _row_h + _gap_y;
    }

    return {
        X: _start_x + (_col * (_card_w + _gap_x)),
        Y: _y,
        W: _card_w,
        H: _card_h
    };
}

function demo_string_fit(_text, _max_w, _scale) {
    var _out = string(_text);

    if (string_width(_out) * _scale <= _max_w) {
        return _out;
    }

    while (string_length(_out) > 4 && string_width(_out + "...") * _scale > _max_w) {
        _out = string_delete(_out, string_length(_out), 1);
    }

    return _out + "...";
}

function demo_draw_text_fit(_x, _y, _text, _max_w, _scale, _color) {
    draw_set_color(_color);
    draw_text_transformed(_x, _y, demo_string_fit(_text, _max_w, _scale), _scale, _scale, 0);
}

function demo_pokemon_focus_short(_pokemon) {
    var _focus = demo_pokemon_focus_label(_pokemon);

    switch (_focus) {
        case "VELOCIDADE": return "VEL";
        case "EQUILIBRADO": return "EQUIL";
        case "ATAQUE": return "ATK";
        case "DEFESA": return "DEF";
        case "VIDA": return "HP";
    }

    return _focus;
}

function demo_draw_pokemon_stat_mini(_pokemon, _x, _y, _w) {
    var _labels = ["HP", "ATK", "DEF", "VEL"];
    var _stats = ["hp", "atk", "def", "spd"];
    var _colors = [
        make_color_rgb(104, 210, 96),
        make_color_rgb(232, 88, 72),
        make_color_rgb(88, 146, 224),
        make_color_rgb(242, 206, 78)
    ];
    var _scale = argument_count >= 5 ? argument[4] : 0.46;
    var _line_h = argument_count >= 6 ? argument[5] : 13;
    var _bar_h = argument_count >= 7 ? argument[6] : 6;
    var _label_w = max(30, floor(58 * _scale));

    for (var _i = 0; _i < 4; _i += 1) {
        var _yy = _y + (_i * _line_h);
        draw_set_color(make_color_rgb(60, 50, 46));
        draw_text_transformed(_x, _yy - 3, _labels[_i], _scale, _scale, 0);
        draw_set_color(make_color_rgb(196, 190, 170));
        draw_rectangle(_x + _label_w, _yy, _x + _w, _yy + _bar_h, false);
        draw_set_color(make_color_rgb(82, 70, 62));
        draw_rectangle(_x + _label_w, _yy, _x + _w, _yy + _bar_h, true);
        draw_set_color(_colors[_i]);
        draw_rectangle(_x + _label_w + 2, _yy + 2, _x + _label_w + 2 + ((_w - _label_w - 4) * demo_pokemon_stat_pct(_pokemon, _stats[_i])), _yy + _bar_h - 2, false);
    }
}

function demo_draw_meta_starter_preview(_entry, _rect) {
    var _ids = demo_meta_starter_entry_ids(_entry.ID);
    var _count = array_length(_ids);

    if (_count <= 0) {
        return undefined;
    }

    var _mx = argument_count >= 3 ? argument[2] : device_mouse_x_to_gui(0);
    var _my = argument_count >= 4 ? argument[3] : device_mouse_y_to_gui(0);
    var _tooltip_x = argument_count >= 5 ? argument[4] : _mx;
    var _tooltip_y = argument_count >= 6 ? argument[5] : _my;
    var _tooltip = undefined;
    var _gap = 8;
    var _slot_w = (_rect.W - 48 - ((_count - 1) * _gap)) / _count;
    var _slot_y = _rect.Y + 86;
    var _slot_h = _rect.H - 106;

    for (var _i = 0; _i < _count; _i += 1) {
        var _id = _ids[_i];
        var _slot_x = _rect.X + 22 + (_i * (_slot_w + _gap));
        var _pokemon = demo_pokemon_preview_get(_id);
        var _skills = demo_get_initial_skills(_id);
        var _skill = array_length(_skills) > 0 ? _skills[0] : undefined;
        var _hover = demo_hover_rect(_mx, _my, _slot_x, _slot_y, _slot_w, _slot_h);

        draw_set_color(_hover ? make_color_rgb(255, 244, 196) : make_color_rgb(248, 242, 220));
        draw_rectangle(_slot_x, _slot_y, _slot_x + _slot_w, _slot_y + _slot_h, false);
        draw_set_color(_hover ? make_color_rgb(232, 184, 82) : make_color_rgb(188, 166, 122));
        draw_rectangle(_slot_x, _slot_y, _slot_x + _slot_w, _slot_y + _slot_h, true);

        if (_hover) {
            draw_set_alpha(0.20);
            draw_set_color(c_white);
            draw_rectangle(_slot_x + 4, _slot_y + 4, _slot_x + _slot_w - 4, _slot_y + _slot_h - 4, false);
            draw_set_alpha(1);
        }

        draw_set_halign(fa_center);
        draw_set_color(make_color_rgb(36, 30, 28));
        draw_text_transformed(_slot_x + (_slot_w * 0.5), _slot_y + 9, demo_string_fit(demo_pokemon_nome(_id), _slot_w - 20, 0.60), 0.60, 0.60, 0);
        draw_set_halign(fa_left);

        demo_draw_pokemon_sprite(_id, _slot_x + 44, _slot_y + 88, 0.86, 1, 0);

        if (is_struct(_skill)) {
            battle_ui_draw_type_icon(_skill.TipoElementar, _slot_x + 72, _slot_y + 40, 0.40);
            demo_draw_text_fit(_slot_x + 110, _slot_y + 39, _skill.Nome, _slot_w - 118, 0.50, make_color_rgb(60, 50, 46));
            var _skill_cd = variable_struct_exists(_skill, "TempoRecargaMax") ? _skill.TempoRecargaMax : (variable_struct_exists(_skill, "TempoRecargaBase") ? _skill.TempoRecargaBase : (variable_struct_exists(_skill, "CooldownBase") ? _skill.CooldownBase : 0));
            var _skill_info = "Dano " + string(_skill.DanoBase) + "  CD " + string_format(_skill_cd, 1, 1) + "s";
            demo_draw_text_fit(_slot_x + 72, _slot_y + 63, _skill_info, _slot_w - 82, 0.42, make_color_rgb(86, 68, 58));
        }

        if (is_struct(_pokemon)) {
            demo_draw_text_fit(_slot_x + 72, _slot_y + 86, "Foco " + demo_pokemon_focus_short(_pokemon), _slot_w - 82, 0.43, make_color_rgb(86, 68, 58));
            demo_draw_pokemon_stat_mini(_pokemon, _slot_x + 14, _slot_y + 132, _slot_w - 14, 0.55, 15, 8);
        }

        if (_hover && is_struct(_skill)) {
            _tooltip = {
                X: _tooltip_x,
                Y: _tooltip_y,
                SafeX: max(62, _rect.X + 10),
                SafeY: max(52, _rect.Y + 10),
                SafeW: min(display_get_gui_width() - 124, max(260, _rect.W - 20)),
                SafeH: display_get_gui_height() - 104,
                Pokemon: demo_pokemon_nome(_id),
                Skill: _skill
            };
        }
    }

    return _tooltip;
}

function demo_draw_meta_shop_card(_entry, _rect, _level, _cost, _maxed, _can_buy, _hover) {
    var _is_starter_entry = demo_meta_entry_is_starter(_entry);

    draw_set_color(_hover && _can_buy ? make_color_rgb(255, 244, 152) : make_color_rgb(242, 235, 208));
    if (!_can_buy && !_maxed) draw_set_color(make_color_rgb(206, 198, 178));
    if (_maxed) draw_set_color(make_color_rgb(214, 238, 210));
    draw_rectangle(_rect.X, _rect.Y, _rect.X + _rect.W, _rect.Y + _rect.H, false);

    draw_set_color(_hover ? make_color_rgb(92, 246, 238) : make_color_rgb(108, 82, 68));
    if (!_can_buy && !_maxed) draw_set_color(make_color_rgb(118, 106, 98));
    if (_maxed) draw_set_color(make_color_rgb(56, 154, 88));
    draw_rectangle(_rect.X, _rect.Y, _rect.X + 12, _rect.Y + _rect.H, false);
    draw_rectangle(_rect.X, _rect.Y, _rect.X + _rect.W, _rect.Y + _rect.H, true);

    draw_set_color(make_color_rgb(36, 30, 28));
    demo_draw_text_fit(_rect.X + 28, _rect.Y + 10, _entry.Nome, _rect.W - 190, 0.82, make_color_rgb(36, 30, 28));

    draw_set_color(make_color_rgb(86, 68, 58));
    var _desc_line_sep = _is_starter_entry ? 20 : 23;
    draw_text_ext(_rect.X + 28, _rect.Y + (_is_starter_entry ? 34 : 40), demo_meta_entry_description(_entry, _level), _desc_line_sep, _rect.W - 200);

    draw_set_color(make_color_rgb(36, 30, 28));
    var _level_text = _entry.Max == 1 ? (_level > 0 ? "Comprado" : "Unico") : "Nv. " + string(_level) + " / " + string(_entry.Max);
    draw_text(_rect.X + _rect.W - 138, _rect.Y + 8, _level_text);
    draw_set_color(_maxed ? make_color_rgb(56, 154, 88) : (_can_buy ? make_color_rgb(124, 72, 152) : make_color_rgb(132, 76, 76)));
    var _cost_text = _maxed ? "MAX" : "Custo " + string(_cost);
    draw_text(_rect.X + _rect.W - 138, _rect.Y + (_is_starter_entry ? 28 : 34), _cost_text);

    if (_is_starter_entry) {
        draw_set_color(make_color_rgb(184, 174, 154));
        draw_line(_rect.X + 24, _rect.Y + 74, _rect.X + _rect.W - 24, _rect.Y + 74);
        return demo_draw_meta_starter_preview(_entry, _rect, argument_count >= 8 ? argument[7] : device_mouse_x_to_gui(0), argument_count >= 9 ? argument[8] : device_mouse_y_to_gui(0), argument_count >= 10 ? argument[9] : device_mouse_x_to_gui(0), argument_count >= 11 ? argument[10] : device_mouse_y_to_gui(0));
    }

    return undefined;
}

function demo_draw_meta_shop_cards(_controller, _entries, _view, _scroll, _meta, _mx, _my, _offset_x, _offset_y) {
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    var _tooltip = undefined;
    var _mx_local = _mx - _offset_x;
    var _my_local = _my - _offset_y;

    for (var _i = 0; _i < array_length(_entries); _i += 1) {
        var _entry = _entries[_i];
        var _rect_global = demo_meta_shop_card_rect(_i, _scroll);

        if (_rect_global.Y > _view.Y + _view.H || _rect_global.Y + _rect_global.H < _view.Y) {
            continue;
        }

        var _level = demo_meta_upgrade_level(_meta, _entry.ID);
        var _cost = demo_meta_upgrade_cost(_meta, _entry);
        var _maxed = _cost < 0;
        var _can_buy = !_maxed && _meta.FragmentosEspaco >= _cost;
        var _hover = demo_hover_rect(_mx, _my, _view.X, _view.Y, _view.W, _view.H) && demo_hover_rect(_mx, _my, _rect_global.X, _rect_global.Y, _rect_global.W, _rect_global.H);
        var _rect = {
            X: _rect_global.X - _offset_x,
            Y: _rect_global.Y - _offset_y,
            W: _rect_global.W,
            H: _rect_global.H
        };

        var _card_tooltip = demo_draw_meta_shop_card(_entry, _rect, _level, _cost, _maxed, _can_buy, _hover, _mx_local, _my_local, _mx, _my);

        if (is_struct(_card_tooltip)) {
            _tooltip = _card_tooltip;
        }
    }

    return _tooltip;
}

function demo_draw_gold_ui_panel(_x, _y, _w, _h) {
    draw_set_alpha(0.42);
    draw_set_color(make_color_rgb(20, 17, 28));
    draw_rectangle(_x + 8, _y + 9, _x + _w + 8, _y + _h + 9, false);
    draw_set_alpha(1);

    draw_set_color(make_color_rgb(94, 70, 42));
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
    draw_set_color(make_color_rgb(236, 196, 92));
    draw_rectangle(_x + 3, _y + 3, _x + _w - 3, _y + _h - 3, false);
    draw_set_color(make_color_rgb(255, 246, 210));
    draw_rectangle(_x + 7, _y + 7, _x + _w - 7, _y + _h - 7, false);
    draw_set_color(make_color_rgb(229, 218, 178));
    draw_rectangle(_x + 12, _y + 12, _x + _w - 12, _y + _h - 12, false);
    draw_set_color(make_color_rgb(252, 246, 226));
    draw_rectangle(_x + 16, _y + 16, _x + _w - 16, _y + _h - 16, false);

    draw_set_color(make_color_rgb(128, 98, 58));
    draw_rectangle(_x + 7, _y + 7, _x + _w - 7, _y + _h - 7, true);
    draw_set_color(make_color_rgb(122, 94, 60));
    draw_line(_x + 18, _y + _h - 20, _x + _w - 18, _y + _h - 20);
}

function demo_draw_starter_skill_tooltip(_tooltip) {
    if (!is_struct(_tooltip) || !variable_struct_exists(_tooltip, "Skill") || !is_struct(_tooltip.Skill)) {
        return;
    }

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _skill = _tooltip.Skill;
    var _pokemon_name = variable_struct_exists(_tooltip, "Pokemon") ? _tooltip.Pokemon : "Pokemon";
    var _skill_cd = variable_struct_exists(_skill, "TempoRecargaMax") ? _skill.TempoRecargaMax : (variable_struct_exists(_skill, "TempoRecargaBase") ? _skill.TempoRecargaBase : 0);
    var _desc = habilidade_descricao_curta(_skill);
    var _tw = 340;
    var _inner_w = _tw - 32;
    var _body_line_sep = 24;
    var _body_y = 106;
    battle_ui_font_body();
    var _body_h = string_height_ext(_desc, _body_line_sep, _inner_w);
    var _th = clamp(_body_y + _body_h + 30, 172, 252);
    var _safe_x = variable_struct_exists(_tooltip, "SafeX") ? _tooltip.SafeX : 18;
    var _safe_y = variable_struct_exists(_tooltip, "SafeY") ? _tooltip.SafeY : 18;
    var _safe_w = variable_struct_exists(_tooltip, "SafeW") ? _tooltip.SafeW : (_gw - (_safe_x * 2));
    var _safe_h = variable_struct_exists(_tooltip, "SafeH") ? _tooltip.SafeH : (_gh - (_safe_y * 2));
    var _safe_r = min(_gw - 18, _safe_x + _safe_w);
    var _safe_b = min(_gh - 18, _safe_y + _safe_h);
    var _tx = clamp(_tooltip.X + 18, _safe_x, _safe_r - _tw);
    var _ty = clamp(_tooltip.Y - (_th * 0.5), _safe_y, _safe_b - _th);

    battle_ui_draw_nineslice_panel(_tx, _ty, _tw, _th);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(36, 30, 28));
    battle_ui_font_title();
    draw_text(_tx + 16, _ty + 20, _pokemon_name);

    battle_ui_draw_type_icon(_skill.TipoElementar, _tx + 16, _ty + 52, 0.58);
    battle_ui_font_title();
    demo_draw_text_fit(_tx + 76, _ty + 49, _skill.Nome, _inner_w - 70, 0.76, make_color_rgb(36, 30, 28));
    draw_set_color(make_color_rgb(86, 68, 58));
    battle_ui_font_body();
    draw_text_transformed(_tx + 76, _ty + 76, battle_ui_skill_damage_text(_skill) + "  CD " + string_format(_skill_cd, 1, 1) + "s", 0.62, 0.62, 0);

    draw_set_color(make_color_rgb(72, 56, 50));
    battle_ui_font_body();
    draw_text_ext(_tx + 16, _ty + _body_y, _desc, _body_line_sep, _inner_w);
    battle_ui_font_title();
}

function demo_draw_gold_inner_panel(_x, _y, _w, _h) {
    draw_set_color(make_color_rgb(118, 92, 58));
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
    draw_set_color(make_color_rgb(238, 226, 190));
    draw_rectangle(_x + 2, _y + 2, _x + _w - 2, _y + _h - 2, false);
    draw_set_color(make_color_rgb(255, 251, 236));
    draw_rectangle(_x + 6, _y + 6, _x + _w - 6, _y + _h - 6, false);
    draw_set_color(make_color_rgb(132, 108, 78));
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);
}

function demo_draw_gold_button(_rect, _label, _hover) {
    var _draw_rect = demo_hover_grow_rect(_rect.X, _rect.Y, _rect.W, _rect.H, _hover, 3);

    draw_set_alpha(0.36);
    draw_set_color(make_color_rgb(24, 19, 28));
    draw_rectangle(_draw_rect.X + 6, _draw_rect.Y + 7, _draw_rect.X + _draw_rect.W + 6, _draw_rect.Y + _draw_rect.H + 7, false);
    draw_set_alpha(1);

    draw_set_color(make_color_rgb(96, 70, 42));
    draw_rectangle(_draw_rect.X, _draw_rect.Y, _draw_rect.X + _draw_rect.W, _draw_rect.Y + _draw_rect.H, false);
    draw_set_color(_hover ? make_color_rgb(255, 228, 108) : make_color_rgb(232, 196, 92));
    draw_rectangle(_draw_rect.X + 3, _draw_rect.Y + 3, _draw_rect.X + _draw_rect.W - 3, _draw_rect.Y + _draw_rect.H - 3, false);
    draw_set_color(make_color_rgb(255, 248, 224));
    draw_rectangle(_draw_rect.X + 7, _draw_rect.Y + 7, _draw_rect.X + _draw_rect.W - 7, _draw_rect.Y + _draw_rect.H - 7, false);
    draw_set_color(make_color_rgb(124, 96, 64));
    draw_rectangle(_draw_rect.X + 3, _draw_rect.Y + 3, _draw_rect.X + _draw_rect.W - 3, _draw_rect.Y + _draw_rect.H - 3, true);

    if (_hover) {
        draw_set_alpha(0.22);
        draw_set_color(c_white);
        draw_rectangle(_draw_rect.X + 10, _draw_rect.Y + 10, _draw_rect.X + _draw_rect.W - 10, _draw_rect.Y + _draw_rect.H - 10, false);
        draw_set_alpha(1);
    }

    draw_set_color(make_color_rgb(36, 30, 28));
    draw_set_valign(fa_middle);
    draw_set_halign(fa_center);
    draw_text(_draw_rect.X + (_draw_rect.W * 0.5), _draw_rect.Y + (_draw_rect.H * 0.5), _label);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function demo_draw_space_fragment_icon(_cx, _cy, _size) {
    var _r = _size * 0.5;
    var _base = make_color_rgb(154, 78, 224);
    var _light = make_color_rgb(230, 154, 255);
    var _shine = make_color_rgb(255, 224, 255);
    var _dark = make_color_rgb(72, 44, 118);
    var _deep = make_color_rgb(36, 26, 68);
    var _edge = make_color_rgb(20, 16, 34);

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_cx, _cy, _base, 1);
    draw_vertex_color(_cx - (_r * 0.70), _cy - (_r * 0.34), _edge, 1);
    draw_vertex_color(_cx - (_r * 0.30), _cy - (_r * 0.88), _edge, 1);
    draw_vertex_color(_cx + (_r * 0.34), _cy - (_r * 0.88), _edge, 1);
    draw_vertex_color(_cx + (_r * 0.76), _cy - (_r * 0.30), _edge, 1);
    draw_vertex_color(_cx + (_r * 0.46), _cy + (_r * 0.76), _edge, 1);
    draw_vertex_color(_cx - (_r * 0.24), _cy + (_r * 0.92), _edge, 1);
    draw_vertex_color(_cx - (_r * 0.76), _cy + (_r * 0.34), _edge, 1);
    draw_vertex_color(_cx - (_r * 0.70), _cy - (_r * 0.34), _edge, 1);
    draw_primitive_end();

    var _in = max(1, _r - 2.4);
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_cx, _cy, _base, 1);
    draw_vertex_color(_cx - (_in * 0.64), _cy - (_in * 0.30), _dark, 1);
    draw_vertex_color(_cx - (_in * 0.26), _cy - (_in * 0.80), _light, 1);
    draw_vertex_color(_cx + (_in * 0.30), _cy - (_in * 0.80), _shine, 1);
    draw_vertex_color(_cx + (_in * 0.70), _cy - (_in * 0.26), _base, 1);
    draw_vertex_color(_cx + (_in * 0.42), _cy + (_in * 0.68), _dark, 1);
    draw_vertex_color(_cx - (_in * 0.20), _cy + (_in * 0.84), _deep, 1);
    draw_vertex_color(_cx - (_in * 0.70), _cy + (_in * 0.30), _base, 1);
    draw_vertex_color(_cx - (_in * 0.64), _cy - (_in * 0.30), _dark, 1);
    draw_primitive_end();

    draw_set_alpha(0.66);
    draw_set_color(_shine);
    draw_triangle(_cx - (_in * 0.18), _cy - (_in * 0.62), _cx + (_in * 0.30), _cy - (_in * 0.58), _cx + (_in * 0.04), _cy - (_in * 0.08), false);
    draw_set_color(_light);
    draw_triangle(_cx - (_in * 0.54), _cy - (_in * 0.16), _cx - (_in * 0.06), _cy + (_in * 0.02), _cx - (_in * 0.36), _cy + (_in * 0.46), false);
    draw_set_alpha(0.50);
    draw_set_color(make_color_rgb(102, 246, 238));
    draw_triangle(_cx + (_in * 0.12), _cy - (_in * 0.04), _cx + (_in * 0.54), _cy - (_in * 0.22), _cx + (_in * 0.30), _cy + (_in * 0.36), false);
    draw_set_color(_deep);
    draw_triangle(_cx + (_in * 0.10), _cy + (_in * 0.14), _cx + (_in * 0.38), _cy + (_in * 0.58), _cx - (_in * 0.12), _cy + (_in * 0.68), false);
    draw_set_alpha(1);

    draw_set_alpha(0.70);
    draw_set_color(make_color_rgb(26, 20, 42));
    draw_line_width(_cx - (_in * 0.52), _cy - (_in * 0.14), _cx + (_in * 0.48), _cy - (_in * 0.42), 1);
    draw_line_width(_cx - (_in * 0.16), _cy - (_in * 0.62), _cx + (_in * 0.02), _cy + (_in * 0.66), 1);
    draw_line_width(_cx - (_in * 0.54), _cy + (_in * 0.28), _cx + (_in * 0.40), _cy + (_in * 0.40), 1);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_rectangle(_cx - (_in * 0.02), _cy - (_in * 0.66), _cx + (_in * 0.22), _cy - (_in * 0.58), false);
    draw_line_width(_cx + (_in * 0.22), _cy - (_in * 0.48), _cx + (_in * 0.42), _cy - (_in * 0.24), 1);
}

function demo_draw_space_fragment_badge(_x, _y, _valor, _icon_sprite) {
    var _value_text = string(max(0, floor(_valor)));
    var _w = max(104, 74 + string_width(_value_text));
    var _h = 44;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _hover = demo_hover_rect(_mx, _my, _x, _y, _w, _h);

    draw_set_alpha(0.35);
    draw_set_color(make_color_rgb(20, 16, 28));
    draw_rectangle(_x + 4, _y + 5, _x + _w + 4, _y + _h + 5, false);
    draw_set_alpha(1);

    draw_set_color(_hover ? make_color_rgb(78, 54, 108) : make_color_rgb(48, 36, 76));
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
    draw_set_color(make_color_rgb(232, 196, 96));
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);
    draw_set_color(make_color_rgb(255, 238, 154));
    draw_rectangle(_x + 3, _y + 3, _x + _w - 3, _y + _h - 3, true);

    demo_draw_space_fragment_icon(_x + 25, _y + (_h * 0.5), 30);

    draw_set_color(make_color_rgb(255, 246, 214));
    draw_set_halign(fa_right);
    draw_set_valign(fa_middle);
    draw_text(_x + _w - 18, _y + (_h * 0.5), _value_text);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    if (_hover) {
        return {
            X: _x + (_w * 0.5),
            Y: _y + _h + 6,
            Titulo: "Fragmento temporal:",
            Texto: "Residuo deixado por lideres de ginasio que mantinham estilhacos do tempo presos a Cronaria."
        };
    }

    return undefined;
}

function demo_draw_space_fragment_tooltip(_tooltip) {
    if (!is_struct(_tooltip)) {
        return;
    }

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _title = variable_struct_exists(_tooltip, "Titulo") ? _tooltip.Titulo : "Fragmento temporal:";
    var _body = variable_struct_exists(_tooltip, "Texto") ? _tooltip.Texto : "";
    var _scale_body = 0.78;
    var _body_line_sep = 18;
    var _tw = min(270, _gw - 36);
    var _inner_w = _tw - 30;
    var _body_h = string_height_ext(_body, _body_line_sep, _inner_w / _scale_body) * _scale_body;
    var _th = clamp(54 + _body_h, 82, 132);
    var _tx = clamp(_tooltip.X - (_tw * 0.5), 18, _gw - _tw - 18);
    var _ty = _tooltip.Y + 8;

    if (_ty + _th > _gh - 18) {
        _ty = _tooltip.Y - _th - 14;
    }

    _ty = clamp(_ty, 18, _gh - _th - 18);

    battle_ui_draw_nineslice_panel(_tx, _ty, _tw, _th);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(30, 24, 22));
    battle_ui_font_title();
    draw_text(_tx + 16, _ty + 11, _title);
    draw_set_color(make_color_rgb(72, 56, 50));
    battle_ui_font_body();
    draw_text_ext_transformed(_tx + 16, _ty + 38, _body, _body_line_sep, _inner_w / _scale_body, _scale_body, _scale_body, 0);
    battle_ui_font_title();
}

function demo_draw_meta_loja(_controller) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _meta = instance_exists(_controller) && is_struct(_controller.meta_progresso) ? _controller.meta_progresso : demo_meta_default();

    if (instance_exists(_controller) && sprite_exists(_controller.title_city_sprite)) {
        demo_draw_sprite_cover(_controller.title_city_sprite, 0, 0, _gw, _gh, 1);
    } else {
        draw_clear(make_color_rgb(10, 18, 34));
    }

    if (instance_exists(_controller) && sprite_exists(_controller.title_scene_bg_sprite)) {
        demo_draw_sprite_stretch(_controller.title_scene_bg_sprite, 0, 0, _gw, _gh, 0.48);
    }

    draw_set_alpha(0.70);
    draw_set_color(make_color_rgb(6, 10, 20));
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    var _panel_x = 46;
    var _panel_y = 34;
    var _panel_w = _gw - 92;
    var _panel_h = _gh - 68;
    demo_draw_gold_ui_panel(_panel_x, _panel_y, _panel_w, _panel_h);

    var _view = demo_meta_shop_view_rect();
    var _scroll = instance_exists(_controller) && variable_instance_exists(_controller, "meta_shop_scroll") ? _controller.meta_shop_scroll : 0;
    var _scroll_max = demo_meta_shop_scroll_max();
    _scroll = clamp(_scroll, 0, _scroll_max);

    var _view_pad = 12;
    demo_draw_gold_inner_panel(_view.X - _view_pad, _view.Y - _view_pad, _view.W + (_view_pad * 2), _view.H + (_view_pad * 2));

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(36, 30, 28));
    draw_text(82, 58, "LOJA DO ESPACO");
    draw_set_color(make_color_rgb(86, 68, 58));
    draw_text(82, 88, "Compre melhorias permanentes para futuras runs.");
    var _fragment_icon = instance_exists(_controller) ? _controller.space_fragment_icon_sprite : -1;
    var _fragment_badge_w = max(104, 74 + string_width(string(max(0, floor(_meta.FragmentosEspaco)))));
    var _fragment_tooltip = demo_draw_space_fragment_badge(_panel_x + _panel_w - _fragment_badge_w - 18, 52, _meta.FragmentosEspaco, _fragment_icon);

    var _entries = demo_meta_shop_entries();
    var _surf_w = max(1, floor(_view.W));
    var _surf_h = max(1, floor(_view.H));
    var _shop_surface = surface_create(_surf_w, _surf_h);
    var _starter_tooltip = undefined;

    if (surface_exists(_shop_surface)) {
        surface_set_target(_shop_surface);
        draw_clear_alpha(c_white, 0);
        _starter_tooltip = demo_draw_meta_shop_cards(_controller, _entries, _view, _scroll, _meta, _mx, _my, _view.X, _view.Y);
        surface_reset_target();
        draw_surface(_shop_surface, _view.X, _view.Y);
        surface_free(_shop_surface);
    } else {
        _starter_tooltip = demo_draw_meta_shop_cards(_controller, _entries, _view, _scroll, _meta, _mx, _my, 0, 0);
    }

    draw_set_color(make_color_rgb(118, 108, 96));
    draw_rectangle(_view.X - _view_pad, _view.Y - _view_pad, _view.X + _view.W + _view_pad, _view.Y + _view.H + _view_pad, true);
    demo_draw_meta_shop_scrollbar(_view, _scroll, _scroll_max);

    var _back_rect = { X: 72, Y: _gh - 112, W: 190, H: 54 };
    demo_draw_gold_button(_back_rect, "VOLTAR", demo_hover_rect(_mx, _my, _back_rect.X, _back_rect.Y, _back_rect.W, _back_rect.H));

    demo_draw_space_fragment_tooltip(_fragment_tooltip);
    demo_draw_starter_skill_tooltip(_starter_tooltip);
}

function demo_draw_menu_titulo(_controller) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    if (instance_exists(_controller) && sprite_exists(_controller.title_city_sprite)) {
        demo_draw_sprite_cover(_controller.title_city_sprite, 0, 0, _gw, _gh, 1);
    } else {
        draw_clear(make_color_rgb(10, 18, 34));
    }

    if (instance_exists(_controller) && sprite_exists(_controller.title_scene_bg_sprite)) {
        demo_draw_sprite_stretch(_controller.title_scene_bg_sprite, 0, 0, _gw, _gh, 0.62);
    }

    for (var _i = 0; _i < 8; _i += 1) {
        var _band_y = (_i / 8) * _gh;
        draw_set_alpha(0.12);
        draw_set_color(make_color_rgb(20 + (_i * 3), 28 + (_i * 4), 44 + (_i * 6)));
        draw_rectangle(0, _band_y, _gw, _band_y + (_gh / 8) + 2, false);
    }

    draw_set_alpha(0.42);
    draw_set_color(make_color_rgb(6, 10, 20));
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    var _time_title = current_time * 0.001;
    var _stage_y = _gh * 0.65;
    var _platform_y = _stage_y + 42;
    var _pulse = sin(_time_title * 3.0);
    var _impact_wave = max(0, sin(_time_title * 2.65));
    var _surge_wave = max(0, sin((_time_title * 5.20) + 0.45));
    var _impact = max(power(_impact_wave, 5), power(_surge_wave, 10));
    var _shake_x = sin(_time_title * 54.0) * (2 + (_impact * 6)) * _impact;
    var _shake_y = cos(_time_title * 48.0) * (1 + (_impact * 4)) * _impact;
    var _crack_x = (_gw * 0.50) + _shake_x;
    var _crack_y = (_gh * 0.43) + _shake_y;
    var _mewtwo_x = (_gw * 0.245) + (sin(_time_title * 1.6) * 4);
    var _mewtwo_y = _platform_y + 6;
    var _mew_x = (_gw * 0.725) + (sin(_time_title * 1.2) * 5);
    var _mew_y = (_stage_y - 118) + (sin(_time_title * 2.25) * 28);
    var _celebi_x = (_gw * 0.795) + (sin(_time_title * 1.35 + 1.8) * 4);
    var _celebi_y = (_platform_y - 4) + (sin(_time_title * 1.9 + 1.1) * 9);
    var _fx_frame = floor(current_time * 0.018);
    var _sprite_flicker = 0.92 + (sin(_time_title * 8.2) * 0.06);
    var _mewtwo_scale = 2.52 + (_impact * 0.12);
    var _mewtwo_bob = demo_intro_pokemon_bob(demo_intro_id_chefe(), _mewtwo_scale);
    var _mewtwo_beam_x = _mewtwo_x + 60;
    var _mewtwo_beam_y = _mewtwo_y - 98 + _mewtwo_bob;
    var _mewtwo_beam2_x = _mewtwo_x + 50;
    var _mewtwo_beam2_y = _mewtwo_y - 84 + _mewtwo_bob;
    var _mew_core_x = _mew_x - 54 + (sin(current_time * 0.010 + 1.2) * 2);
    var _mew_core_y = _mew_y - 34 + (cos(current_time * 0.008 + 1.1) * 2);
    var _celebi_core_x = _celebi_x - 52 + (sin(current_time * 0.010) * 2);
    var _celebi_core_y = _celebi_y - 42 + (cos(current_time * 0.009) * 2);

    if (instance_exists(_controller)) {
        if (sprite_exists(_controller.title_cosmo_sprite)) {
            demo_draw_sheet_frame_centered(_controller.title_cosmo_sprite, 5, 3, _fx_frame, _crack_x, _crack_y, 1.9, make_color_rgb(116, 236, 244), 0.18 + (_impact * 0.08));
        }

        if (sprite_exists(_controller.title_scene_base0_sprite)) {
            demo_draw_sprite_grounded(_controller.title_scene_base0_sprite, _crack_x, _platform_y + 8, 3.35, 1, c_white, 0.70);
        }

        if (sprite_exists(_controller.title_scene_base1_sprite)) {
            demo_draw_sprite_grounded(_controller.title_scene_base1_sprite, _mewtwo_x, _mewtwo_y + 26, 2.22, 1, c_white, 0.84);
            demo_draw_sprite_grounded(_controller.title_scene_base1_sprite, _mew_x, _mew_y + 42, 1.66, 1, c_white, 0.72);
            demo_draw_sprite_grounded(_controller.title_scene_base1_sprite, _celebi_x, _celebi_y + 18, 1.70, 1, c_white, 0.76);
        }

        var _boss_sprite = sprite_exists(_controller.title_giovanni_sprite) ? _controller.title_giovanni_sprite : _controller.title_rocketboss_sprite;

        if (sprite_exists(_boss_sprite)) {
            draw_set_alpha(0.24);
            draw_set_color(c_black);
            draw_ellipse(_crack_x - 112, _platform_y + 6, _crack_x + 112, _platform_y + 34, false);
            draw_set_alpha(0.86);
            demo_draw_sprite_grounded(_boss_sprite, _crack_x + 18, _platform_y + 18 + (_pulse * 2), 2.85, -1, make_color_rgb(222, 210, 255), 1);
            draw_set_alpha(1);
        }

        var _beam_alpha = 0.82 + (_impact * 0.34);
        var _beam_jitter = 4 + (_impact * 10);
        demo_draw_title_energy_beam(_mewtwo_beam_x, _mewtwo_beam_y, _crack_x - 36, _crack_y + 22, make_color_rgb(162, 96, 255), make_color_rgb(255, 118, 222), _beam_alpha, _beam_jitter);
        demo_draw_title_energy_beam(_mewtwo_beam2_x, _mewtwo_beam2_y, _crack_x - 14, _crack_y - 2, make_color_rgb(96, 246, 238), c_white, _beam_alpha * 0.46, _beam_jitter * 0.55);
        demo_draw_title_energy_beam(_mew_core_x, _mew_core_y, _crack_x + 38, _crack_y - 30, make_color_rgb(255, 106, 218), c_white, _beam_alpha, _beam_jitter);
        demo_draw_title_energy_beam(_celebi_core_x, _celebi_core_y, _crack_x + 48, _crack_y + 44, make_color_rgb(142, 255, 128), make_color_rgb(226, 255, 170), _beam_alpha * 0.92, _beam_jitter);

        demo_draw_intro_power_core(_mewtwo_beam_x, _mewtwo_beam_y, 28, make_color_rgb(190, 112, 255), make_color_rgb(255, 130, 230), _beam_alpha, _impact);
        demo_draw_intro_power_core(_mewtwo_beam2_x, _mewtwo_beam2_y, 18, make_color_rgb(96, 246, 238), c_white, _beam_alpha * 0.55, _impact);
        demo_draw_intro_power_core(_mew_core_x, _mew_core_y, 24, make_color_rgb(255, 128, 226), make_color_rgb(255, 190, 242), _beam_alpha * 0.88, _impact);
        demo_draw_intro_power_core(_celebi_core_x, _celebi_core_y, 24, make_color_rgb(178, 255, 128), make_color_rgb(226, 255, 170), _beam_alpha * 0.84, _impact);

        if (sprite_exists(_controller.title_ultra_beam_sprite)) {
            demo_draw_sheet_frame_centered(_controller.title_ultra_beam_sprite, 4, 1, _fx_frame, (_mew_core_x + _crack_x) * 0.5, (_mew_core_y + _crack_y) * 0.5, 0.82, make_color_rgb(255, 132, 224), 0.42 + (_impact * 0.18));
            demo_draw_sheet_frame_centered(_controller.title_ultra_beam_sprite, 4, 1, _fx_frame + 2, (_mewtwo_beam2_x + _crack_x) * 0.5, (_mewtwo_beam2_y + _crack_y) * 0.5, 0.72, make_color_rgb(116, 246, 242), 0.34 + (_impact * 0.12));
        }

        if (sprite_exists(_controller.title_psycho_cut_sprite)) {
            demo_draw_sheet_frame_centered(_controller.title_psycho_cut_sprite, 4, 4, _fx_frame, _crack_x, _crack_y, 1.05 + (_impact * 0.16), make_color_rgb(255, 130, 232), 0.34 + (_impact * 0.26));
        }

        if (sprite_exists(_controller.title_burst_sprite)) {
            demo_draw_sheet_frame_centered(_controller.title_burst_sprite, 5, 2, _fx_frame, _mew_core_x, _mew_core_y, 0.58, make_color_rgb(255, 196, 244), 0.62);
            demo_draw_sheet_frame_centered(_controller.title_burst_sprite, 5, 2, _fx_frame + 4, _celebi_core_x, _celebi_core_y, 0.48, make_color_rgb(190, 255, 158), 0.50);
        }

        draw_set_alpha(0.26);
        draw_set_color(c_black);
        draw_ellipse(_mewtwo_x - 82, _mewtwo_y - 16, _mewtwo_x + 82, _mewtwo_y + 6, false);
        draw_ellipse(_mew_x - 50, _mew_y + 20, _mew_x + 50, _mew_y + 34, false);
        draw_ellipse(_celebi_x - 50, _celebi_y - 8, _celebi_x + 50, _celebi_y + 7, false);
        draw_set_alpha(1);

        draw_set_alpha(0.22 + (_impact * 0.10));
        draw_set_color(make_color_rgb(255, 116, 220));
        draw_circle(_mew_core_x, _mew_core_y, 42 + (_impact * 18), true);
        draw_set_color(make_color_rgb(178, 255, 144));
        draw_circle(_celebi_core_x, _celebi_core_y, 36 + (_impact * 14), true);
        draw_set_alpha(1);

        demo_draw_title_spark_field(_mewtwo_beam_x, _mewtwo_beam_y, 76, make_color_rgb(190, 112, 255), 0.80 + (_impact * 0.18), 16);
        demo_draw_title_spark_field(_mewtwo_beam2_x, _mewtwo_beam2_y, 48, make_color_rgb(116, 246, 242), 0.48 + (_impact * 0.12), 10);
        demo_draw_title_spark_field(_mew_core_x, _mew_core_y, 66, make_color_rgb(255, 128, 226), 0.78 + (_impact * 0.18), 14);
        demo_draw_title_spark_field(_celebi_core_x, _celebi_core_y, 58, make_color_rgb(178, 255, 128), 0.72 + (_impact * 0.16), 14);

        demo_draw_intro_pokemon(_controller.intro_mewtwo_back_sprite, demo_intro_id_chefe(), _mewtwo_x, _mewtwo_y - 2, _mewtwo_scale, -1, c_white, _sprite_flicker);
        demo_draw_intro_pokemon(_controller.intro_mew_front_sprite, demo_intro_id_guardiao(0), _mew_x, _mew_y, 1.92 + (_impact * 0.09), 1, c_white, _sprite_flicker);
        demo_draw_intro_pokemon(_controller.intro_celebi_front_sprite, demo_intro_id_guardiao(1), _celebi_x, _celebi_y, 1.84 + (_impact * 0.08), 1, c_white, _sprite_flicker);
    }

    draw_set_alpha(0.30);
    draw_set_color(make_color_rgb(72, 220, 230));
    draw_circle(_crack_x, _crack_y, 164 + (sin(current_time * 0.0025) * 8), true);
    draw_set_alpha(0.18);
    draw_circle(_crack_x, _crack_y, 210 + (sin(current_time * 0.002) * 10), true);
    draw_set_alpha(1);

    demo_draw_space_crack(_crack_x, _crack_y + 18, 360, 0.94, 0.64);

    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text_transformed(_gw * 0.5 + 3, 92 + 3, "RASGO TEMPORAL", 2.15, 2.15, 0);
    draw_set_color(make_color_rgb(255, 238, 118));
    draw_text_transformed(_gw * 0.5, 92, "RASGO TEMPORAL", 2.15, 2.15, 0);
    draw_set_color(c_white);
    draw_text_transformed(_gw * 0.5, 144, "O ESPACO ESTILHACADO", 1.28, 1.28, 0);
    draw_set_valign(fa_top);

    var _btn = demo_menu_start_button_rect();
    var _shop_btn = demo_menu_shop_button_rect();
    var _hover = demo_hover_rect(_mx, _my, _btn.X, _btn.Y, _btn.W, _btn.H);
    var _shop_hover = demo_hover_rect(_mx, _my, _shop_btn.X, _shop_btn.Y, _shop_btn.W, _shop_btn.H);

    demo_draw_title_button(_btn, "COMECAR RUN", _hover);
    demo_draw_title_button(_shop_btn, "LOJA DO ESPACO", _shop_hover);
    diario_draw_menu(_mx, _my);

    var _fragment_tooltip_title = undefined;

    if (instance_exists(_controller) && is_struct(_controller.meta_progresso)) {
        var _title_frag_w = max(104, 74 + string_width(string(max(0, floor(_controller.meta_progresso.FragmentosEspaco)))));
        _fragment_tooltip_title = demo_draw_space_fragment_badge(_gw - _title_frag_w - 46, 44, _controller.meta_progresso.FragmentosEspaco, _controller.space_fragment_icon_sprite);
    }

    demo_draw_space_fragment_tooltip(_fragment_tooltip_title);

    draw_set_halign(fa_center);
    draw_set_halign(fa_left);
}

function demo_draw_intro_lab_background(_controller, _gw, _gh, _alpha, _shake_x, _shake_y, _energy) {
    draw_set_alpha(_alpha);

    if (instance_exists(_controller) && sprite_exists(_controller.intro_lab_bg_sprite)) {
        demo_draw_sprite_stretch(_controller.intro_lab_bg_sprite, 0 + _shake_x * 0.25, 0 + _shake_y * 0.25, _gw, _gh * 0.72, _alpha);
    } else {
        draw_set_color(make_color_rgb(24, 34, 54));
        draw_rectangle(0, 0, _gw, _gh, false);
    }

    draw_set_color(make_color_rgb(14, 20, 34));
    draw_rectangle(0, _gh * 0.58 + _shake_y, _gw, _gh, false);
    draw_set_color(make_color_rgb(40, 54, 72));
    draw_rectangle(0, _gh * 0.58 + _shake_y, _gw, _gh * 0.64 + _shake_y, false);

    if (instance_exists(_controller) && sprite_exists(_controller.intro_lab_base0_sprite)) {
        demo_draw_sprite_stretch(_controller.intro_lab_base0_sprite, 0, _gh * 0.52 + _shake_y, _gw, _gh * 0.22, _alpha);
    }

    if (instance_exists(_controller) && sprite_exists(_controller.intro_lab_base1_sprite)) {
        demo_draw_sprite_stretch(_controller.intro_lab_base1_sprite, 0, _gh * 0.62 + _shake_y, _gw, _gh * 0.28, _alpha);
    }

    for (var _i = 0; _i < 7; _i += 1) {
        var _panel_x = 76 + (_i * 176) + (_shake_x * 0.18);
        var _panel_y = 78 + (sin((current_time * 0.002) + _i) * 5);

        draw_set_alpha(_alpha * (0.32 + (_energy * 0.24)));
        draw_set_color((_i mod 2) == 0 ? make_color_rgb(72, 246, 238) : make_color_rgb(255, 116, 220));
        draw_rectangle(_panel_x, _panel_y, _panel_x + 78, _panel_y + 12, false);
        draw_set_alpha(_alpha * 0.16);
        draw_rectangle(_panel_x + 8, _panel_y + 22, _panel_x + 112, _panel_y + 28, false);
    }

    draw_set_alpha(_alpha * (0.18 + (_energy * 0.16)));
    draw_set_color(make_color_rgb(86, 246, 238));
    for (var _c = 0; _c < 9; _c += 1) {
        var _cx = 88 + (_c * 148) + (sin(current_time * 0.004 + _c) * 4);
        draw_line_width(_cx, _gh * 0.64, _cx + 72, _gh * 0.90, 2);
    }

    draw_set_alpha(1);
}

function demo_draw_intro_pixel_cloud(_cx, _cy, _scale, _alpha, _color) {
    if (_alpha <= 0) {
        return;
    }

    var _highlight = argument_count >= 6 ? argument[5] : c_white;

    draw_set_alpha(_alpha);
    draw_set_color(_color);
    draw_circle(_cx - 28 * _scale, _cy + 8 * _scale, 18 * _scale, false);
    draw_circle(_cx - 10 * _scale, _cy - 6 * _scale, 24 * _scale, false);
    draw_circle(_cx + 18 * _scale, _cy, 22 * _scale, false);
    draw_circle(_cx + 42 * _scale, _cy + 10 * _scale, 16 * _scale, false);
    draw_rectangle(_cx - 42 * _scale, _cy + 5 * _scale, _cx + 54 * _scale, _cy + 22 * _scale, false);
    draw_set_alpha(_alpha * 0.40);
    draw_set_color(_highlight);
    draw_rectangle(_cx - 18 * _scale, _cy - 16 * _scale, _cx + 20 * _scale, _cy - 12 * _scale, false);
    draw_rectangle(_cx + 16 * _scale, _cy + 2 * _scale, _cx + 48 * _scale, _cy + 6 * _scale, false);
    draw_set_alpha(1);
}

function demo_intro_wrap_x(_value, _span) {
    return _value - floor(_value / _span) * _span;
}

function demo_draw_intro_cloud_bank(_gw, _gh, _alpha, _night, _chaos, _shake_x, _shake_y) {
    if (_alpha <= 0) {
        return;
    }

    var _span = _gw + 300;
    var _speed = (_night > 0.5 ? -0.030 : 0.018) + (_chaos * 0.012);
    var _drift = current_time * _speed;
    var _main = _night > 0.5 ? make_color_rgb(38, 54, 66) : make_color_rgb(196, 238, 230);
    var _alt = _night > 0.5 ? make_color_rgb(24, 36, 50) : make_color_rgb(176, 224, 218);
    var _light = _night > 0.5 ? make_color_rgb(86, 116, 132) : make_color_rgb(240, 255, 250);

    for (var _i = 0; _i < 7; _i += 1) {
        var _raw_x = (_i * 226) + _drift + (sin(current_time * 0.0009 + _i) * (12 + (_chaos * 14)));
        var _x = demo_intro_wrap_x(_raw_x, _span) - 150 + (_shake_x * 0.03);
        var _y = _gh * (0.10 + ((_i mod 3) * 0.035)) + (sin(current_time * 0.0014 + _i * 1.7) * 5) + (_shake_y * 0.03);
        var _scale = 0.58 + ((_i mod 4) * 0.12) + (_night * 0.18);
        var _cloud_alpha = _alpha * (0.54 - ((_i mod 3) * 0.07));

        demo_draw_intro_pixel_cloud(_x, _y, _scale, _cloud_alpha, (_i mod 2) == 0 ? _main : _alt, _light);
    }
}

function demo_draw_intro_lightning_bolt(_x, _y, _length, _alpha, _seed) {
    if (_alpha <= 0) {
        return;
    }

    var _time = current_time * 0.001;
    var _flash = max(0, sin((_time * (8.0 + (_seed * 0.11))) + (_seed * 2.73)));
    var _snap = max(0, sin((_time * (17.0 + (_seed * 0.07))) + (_seed * 1.31)));
    _flash = max(power(_flash, 7), power(_snap, 12) * 0.72);

    if (_flash < 0.08) {
        return;
    }

    var _pxs = [_x];
    var _pys = [_y];
    var _segments = 8;

    for (var _seg = 1; _seg <= _segments; _seg += 1) {
        var _progress = _seg / _segments;
        var _fork = sin((_seed * 4.17) + (_seg * 2.41) + (_time * 2.4)) * (13 + ((_seg mod 3) * 7));
        array_push(_pxs, _x + _fork);
        array_push(_pys, _y + (_length * _progress));
    }

    for (var _pass = 0; _pass < 3; _pass += 1) {
        draw_set_alpha(_alpha * _flash * (_pass == 0 ? 0.22 : (_pass == 1 ? 0.52 : 0.96)));
        draw_set_color(_pass == 0 ? make_color_rgb(50, 156, 220) : (_pass == 1 ? make_color_rgb(106, 232, 255) : make_color_rgb(238, 255, 255)));

        for (var _line = 0; _line < _segments; _line += 1) {
            draw_line_width(_pxs[_line], _pys[_line], _pxs[_line + 1], _pys[_line + 1], _pass == 0 ? 10 : (_pass == 1 ? 5 : 2));
        }

        if (_pass >= 1) {
            for (var _branch = 2; _branch < _segments; _branch += 2) {
                var _dir = ((_branch + _seed) mod 2) == 0 ? 1 : -1;
                var _branch_len = (24 + ((_branch mod 3) * 14)) * _dir;
                var _by = _pys[_branch] + sin(_time * 5 + _branch) * 7;
                draw_line_width(_pxs[_branch], _pys[_branch], _pxs[_branch] + _branch_len, _by + 18, _pass == 1 ? 3 : 1);
            }
        }
    }

    draw_set_alpha(_alpha * _flash * 0.26);
    draw_set_color(make_color_rgb(150, 238, 255));
    draw_circle(_x, _y + (_length * 0.52), 52 + (_flash * 36), true);
    draw_set_alpha(1);
}

function demo_draw_intro_ember_patch(_x, _y, _scale, _alpha, _seed) {
    var _pulse = 0.65 + (sin(current_time * 0.009 + _seed) * 0.25);

    draw_set_alpha(_alpha * 0.22 * _pulse);
    draw_set_color(make_color_rgb(255, 114, 38));
    draw_circle(_x, _y, 26 * _scale, false);

    for (var _e = 0; _e < 12; _e += 1) {
        var _life_raw = (current_time * 0.0012) + (_e * 0.137) + (_seed * 0.061);
        var _life = _life_raw - floor(_life_raw);
        var _side = ((_e mod 2) * 2) - 1;
        var _ex = _x + _side * (6 + ((_e * 7 + _seed) mod 22)) * _scale + sin(current_time * 0.008 + _e) * 3;
        var _ey = _y - (_life * (36 + (_e mod 4) * 8) * _scale);
        var _sz = max(2, floor((4 - (_life * 2)) * _scale));

        draw_set_alpha(_alpha * (1 - _life) * (0.65 + _pulse * 0.25));
        draw_set_color((_e mod 3) == 0 ? make_color_rgb(255, 226, 102) : make_color_rgb(255, 98, 42));
        draw_rectangle(_ex, _ey, _ex + _sz + (_e mod 2), _ey + _sz, false);
    }

    draw_set_alpha(_alpha * 0.58 * _pulse);
    draw_set_color(make_color_rgb(255, 142, 48));
    draw_line_width(_x - 22 * _scale, _y + 7 * _scale, _x + 22 * _scale, _y - 4 * _scale, max(1, 2 * _scale));
    draw_set_alpha(1);
}

function demo_draw_intro_fire_cluster(_x, _base_y, _scale, _alpha, _seed, _intensity) {
    if (_alpha <= 0) {
        return;
    }

    var _time = current_time * 0.001;
    var _pulse = 0.74 + (sin((_time * 9.0) + _seed) * 0.18) + (_intensity * 0.16);
    var _glow = _alpha * clamp(0.18 + (_intensity * 0.22), 0, 0.58) * _pulse;

    draw_set_alpha(_glow);
    draw_set_color(make_color_rgb(255, 94, 32));
    draw_circle(_x, _base_y - 10 * _scale, 30 * _scale, false);

    draw_set_alpha(_alpha * 0.58);
    draw_set_color(make_color_rgb(30, 20, 18));
    draw_rectangle(_x - 24 * _scale, _base_y - 2 * _scale, _x + 25 * _scale, _base_y + 3 * _scale, false);

    for (var _f = 0; _f < 8; _f += 1) {
        var _phase = sin((_time * (8.4 + (_f * 0.38))) + _seed + (_f * 1.7));
        var _col_x = _x + (((_f mod 4) - 1.5) * 9 * _scale) + (_phase * 2 * _scale);
        var _height = (15 + ((_f * 7 + _seed) mod 22)) * _scale * (0.82 + (_pulse * 0.22));
        var _width = (5 + (_f mod 3) * 2) * _scale;
        var _color = (_f mod 3) == 0 ? make_color_rgb(255, 232, 108) : ((_f mod 2) == 0 ? make_color_rgb(255, 130, 42) : make_color_rgb(218, 55, 36));

        draw_set_alpha(_alpha * (0.70 + (_intensity * 0.22)));
        draw_set_color(_color);
        draw_rectangle(_col_x - _width, _base_y - _height, _col_x + _width, _base_y, false);

        if ((_f mod 2) == 0) {
            draw_set_alpha(_alpha * 0.38);
            draw_set_color(make_color_rgb(255, 214, 80));
            draw_rectangle(_col_x - (_width * 0.42), _base_y - (_height * 0.78), _col_x + (_width * 0.42), _base_y - (_height * 0.22), false);
        }
    }

    for (var _s = 0; _s < 5; _s += 1) {
        var _life = frac((_time * (0.34 + _intensity * 0.20)) + (_s * 0.17) + (_seed * 0.03));
        draw_set_alpha(_alpha * (1 - _life) * 0.20);
        draw_set_color(make_color_rgb(18, 20, 22));
        draw_circle(_x - 18 * _scale + (_s * 8 * _scale) + sin(_time * 2.4 + _s) * 4, _base_y - (44 + (_life * 62)) * _scale, (10 + (_s mod 3) * 4) * _scale, false);
    }

    draw_set_alpha(1);
}

function demo_draw_intro_power_core(_x, _y, _radius, _outer_color, _inner_color, _alpha, _impact) {
    draw_set_alpha(_alpha * 0.22);
    draw_set_color(_outer_color);
    draw_circle(_x, _y, _radius + (_impact * 10), true);
    draw_set_alpha(_alpha * 0.38);
    draw_circle(_x, _y, (_radius * 0.58) + (_impact * 6), true);
    draw_set_alpha(_alpha * 0.52);
    draw_set_color(_inner_color);
    draw_circle(_x, _y, (_radius * 0.30) + (_impact * 4), false);
    draw_set_alpha(_alpha * 0.82);
    draw_set_color(c_white);
    draw_circle(_x, _y, 4 + (_impact * 4), false);
    draw_set_alpha(1);
}

function demo_draw_intro_destruction_layer(_gw, _gh, _alpha, _shake_x, _shake_y, _chaos) {
    if (_alpha <= 0 || _chaos <= 0) {
        return;
    }

    var _horizon = _gh * 0.57 + (_shake_y * 0.12);

    for (var _b = 0; _b < 10; _b += 1) {
        var _bx = 34 + (_b * 142) + (sin(_b) * 24) + (_shake_x * 0.10);
        demo_draw_intro_ember_patch(_bx + 24, _horizon + 14, 0.9 + ((_b mod 3) * 0.18), _alpha * (0.62 + (_chaos * 0.24)), _b);
        demo_draw_intro_fire_cluster(_bx + 18, _horizon + 15, 0.46 + ((_b mod 2) * 0.08), _alpha * clamp(0.34 + (_chaos * 0.68), 0, 1), _b + 31, _chaos);
        if ((_b mod 2) == 0) {
            demo_draw_intro_ember_patch(_bx + 58, _horizon + 16, 0.74, _alpha * (0.48 + (_chaos * 0.22)), _b + 12);
            demo_draw_intro_fire_cluster(_bx + 66, _horizon + 14, 0.36, _alpha * clamp(0.26 + (_chaos * 0.56), 0, 1), _b + 44, _chaos * 0.82);
        }

        draw_set_alpha(_alpha * (0.16 + (_chaos * 0.12)));
        draw_set_color(make_color_rgb(18, 20, 24));
        draw_circle(_bx + 20 + sin(current_time * 0.0015 + _b) * 10, _horizon - 118 - ((_b mod 3) * 12), 26 + ((_b mod 2) * 10), false);
        draw_set_alpha(_alpha * (0.08 + (_chaos * 0.10)));
        draw_set_color(make_color_rgb(4, 10, 14));
        draw_circle(_bx + 64 + sin(current_time * 0.001 + _b) * 12, _horizon - 164 - ((_b mod 2) * 16), 34 + ((_b mod 3) * 8), false);
    }

    draw_set_alpha(_alpha * (0.22 + (_chaos * 0.30)));
    draw_set_color(make_color_rgb(52, 70, 62));
    for (var _d = 0; _d < 54; _d += 1) {
        var _dx = ((_d * 127 + 33) mod max(1, floor(_gw)));
        var _dy = _gh * 0.56 + ((_d * 37) mod max(1, floor(_gh * 0.24)));
        draw_rectangle(_dx, _dy, _dx + 8 + (_d mod 5), _dy + 3 + (_d mod 3), false);
    }

    draw_set_alpha(_alpha * (0.18 + (_chaos * 0.38)));
    draw_set_color(make_color_rgb(255, 92, 42));
    for (var _f = 0; _f < 24; _f += 1) {
        var _fx = ((_f * 173 + 88) mod max(1, floor(_gw)));
        var _fy = _gh * 0.61 + ((_f * 31) mod max(1, floor(_gh * 0.14)));
        draw_line_width(_fx - 24, _fy + 6, _fx + 22, _fy - 8, 3);
        draw_set_color(make_color_rgb(255, 210, 76));
        draw_line_width(_fx - 12, _fy + 3, _fx + 10, _fy - 3, 2);
        draw_set_color(make_color_rgb(255, 92, 42));
    }

    for (var _fg = 0; _fg < 8; _fg += 1) {
        var _fgx = ((_fg * 181 + 74) mod max(1, floor(_gw)));
        var _fgy = _gh * (0.62 + ((_fg mod 3) * 0.035));
        demo_draw_intro_fire_cluster(_fgx, _fgy, 0.42 + ((_fg mod 3) * 0.10), _alpha * clamp(0.18 + (_chaos * 0.62), 0, 0.90), _fg + 70, _chaos);
    }

    draw_set_alpha(_alpha * (0.16 + (_chaos * 0.18)));
    draw_set_color(make_color_rgb(82, 42, 30));
    for (var _r = 0; _r < 28; _r += 1) {
        var _rx = ((_r * 211 + floor(current_time * 0.012)) mod max(1, floor(_gw + 120))) - 60;
        var _ry = _gh * 0.64 + ((_r * 43) mod max(1, floor(_gh * 0.20)));
        draw_line_width(_rx, _ry, _rx + 38 + ((_r mod 3) * 12), _ry - 10, 2);
    }

    draw_set_alpha(1);
}

function demo_draw_intro_field_background(_controller, _gw, _gh, _night, _alpha, _shake_x, _shake_y, _chaos) {
    var _day_alpha = _alpha * (1 - (_night * 0.40));
    var _skyline_alpha = _alpha * clamp(_chaos * 1.35, 0, 1);
    var _skyline_y = _gh * 0.08 + (_shake_y * 0.08);
    var _skyline_h = _gh * 0.56;
    var _skyline_drift = sin(current_time * 0.00055) * 2;

    if (instance_exists(_controller) && sprite_exists(_controller.intro_field_bg_sprite)) {
        demo_draw_sprite_stretch(_controller.intro_field_bg_sprite, 0 + _shake_x * 0.12, 0 + _shake_y * 0.12, _gw, _gh * 0.68, _day_alpha);
    } else {
        draw_set_alpha(_day_alpha);
        draw_set_color(make_color_rgb(128, 220, 210));
        draw_rectangle(0, 0, _gw, _gh * 0.56, false);
    }

    if (_day_alpha > 0) {
        draw_set_alpha(_day_alpha * (1 - (_night * 0.85)));
        draw_set_color(make_color_rgb(255, 226, 112));
        draw_circle(_gw * 0.83 + (_shake_x * 0.05), _gh * 0.14 + (_shake_y * 0.05), 42, false);
        draw_set_alpha(_day_alpha * (1 - (_night * 0.85)) * 0.22);
        draw_circle(_gw * 0.83, _gh * 0.14, 78, true);
        draw_set_alpha(1);

        var _cloud_alpha = _day_alpha * (1 - _night) * (0.34 + (_chaos * 0.14));
        demo_draw_intro_cloud_bank(_gw, _gh, _cloud_alpha, 0, _chaos, _shake_x, _shake_y);
    }

    if (instance_exists(_controller) && sprite_exists(_controller.intro_destroyed_horizon_day_sprite)) {
        demo_draw_sprite_stretch(
            _controller.intro_destroyed_horizon_day_sprite,
            _skyline_drift + (_shake_x * 0.04),
            _skyline_y,
            _gw,
            _skyline_h,
            _skyline_alpha * (1 - _night)
        );
    }

    if (instance_exists(_controller) && sprite_exists(_controller.intro_field_base0_sprite)) {
        demo_draw_sprite_stretch(_controller.intro_field_base0_sprite, 0, _gh * 0.50 + _shake_y, _gw, _gh * 0.28, _day_alpha);
    }

    if (instance_exists(_controller) && sprite_exists(_controller.intro_field_base1_sprite)) {
        demo_draw_sprite_stretch(_controller.intro_field_base1_sprite, 0, _gh * 0.60 + _shake_y, _gw, _gh * 0.34, _day_alpha);
    } else {
        draw_set_alpha(_day_alpha);
        draw_set_color(make_color_rgb(76, 170, 84));
        draw_rectangle(0, _gh * 0.56 + _shake_y, _gw, _gh, false);
        draw_set_color(make_color_rgb(42, 116, 64));
        draw_rectangle(0, _gh * 0.58 + _shake_y, _gw, _gh * 0.64 + _shake_y, false);
    }

    demo_draw_intro_destruction_layer(_gw, _gh, _alpha, _shake_x, _shake_y, _chaos);

    if (_night > 0) {
        if (instance_exists(_controller) && sprite_exists(_controller.intro_field_night_bg_sprite)) {
            demo_draw_sprite_stretch(_controller.intro_field_night_bg_sprite, 0 + _shake_x * 0.12, 0 + _shake_y * 0.12, _gw, _gh * 0.68, _alpha * _night);
        }

        if (instance_exists(_controller) && sprite_exists(_controller.intro_field_night_base0_sprite)) {
            demo_draw_sprite_stretch(_controller.intro_field_night_base0_sprite, 0, _gh * 0.50 + _shake_y, _gw, _gh * 0.28, _alpha * _night);
        }

        if (instance_exists(_controller) && sprite_exists(_controller.intro_field_night_base1_sprite)) {
            demo_draw_sprite_stretch(_controller.intro_field_night_base1_sprite, 0, _gh * 0.60 + _shake_y, _gw, _gh * 0.34, _alpha * _night);
        }

        draw_set_alpha(_alpha * _night * 0.46);
        draw_set_color(make_color_rgb(4, 10, 30));
        draw_rectangle(0, 0, _gw, _gh, false);

        if (instance_exists(_controller) && sprite_exists(_controller.intro_destroyed_horizon_night_sprite)) {
            demo_draw_sprite_stretch(
                _controller.intro_destroyed_horizon_night_sprite,
                -_skyline_drift + (_shake_x * 0.04),
                _skyline_y,
                _gw,
                _skyline_h,
                _skyline_alpha * _night
            );
        }

        var _storm_alpha = _alpha * _night * clamp((_chaos - 0.08) / 0.68, 0, 1);
        demo_draw_intro_cloud_bank(_gw, _gh, _storm_alpha * 0.82, 1, _chaos, _shake_x, _shake_y);

        var _sky_flash = max(
            power(max(0, sin(current_time * 0.012 + 1.7)), 9),
            power(max(0, sin(current_time * 0.018 + 4.3)), 13) * 0.76
        ) * _storm_alpha;

        if (_sky_flash > 0.015) {
            draw_set_alpha(_sky_flash * 0.20);
            draw_set_color(make_color_rgb(120, 220, 255));
            draw_rectangle(0, 0, _gw, _gh * 0.56, false);
        }

        draw_set_alpha(_alpha * _night);
        draw_set_color(make_color_rgb(230, 226, 184));
        draw_circle(_gw * 0.82 + (_shake_x * 0.05), _gh * 0.15 + (_shake_y * 0.05), 34, false);
        draw_set_color(make_color_rgb(13, 18, 40));
        draw_circle(_gw * 0.84 + (_shake_x * 0.04), _gh * 0.14 + (_shake_y * 0.04), 29, false);

        var _left_moon_alpha = _alpha * _night * clamp((_chaos - 0.18) / 0.62, 0, 1);
        var _left_moon_x = _gw * 0.14 + (_shake_x * 0.04);
        var _left_moon_y = _gh * 0.16 + (_shake_y * 0.04);

        if (_left_moon_alpha > 0) {
            draw_set_alpha(_left_moon_alpha * 0.18);
            draw_set_color(make_color_rgb(186, 224, 232));
            draw_circle(_left_moon_x, _left_moon_y, 76, true);
            draw_set_alpha(_left_moon_alpha * 0.34);
            draw_circle(_left_moon_x, _left_moon_y, 50, true);
            draw_set_alpha(_left_moon_alpha);
            draw_set_color(make_color_rgb(232, 230, 198));
            draw_circle(_left_moon_x, _left_moon_y, 31, false);
            draw_set_alpha(_left_moon_alpha * 0.22);
            draw_set_color(make_color_rgb(142, 150, 158));
            draw_circle(_left_moon_x - 8, _left_moon_y - 6, 5, false);
            draw_circle(_left_moon_x + 10, _left_moon_y + 8, 4, false);
            draw_circle(_left_moon_x + 2, _left_moon_y - 13, 3, false);
        }

        for (var _star = 0; _star < 20; _star += 1) {
            var _sx = 48 + ((_star * 173) mod max(1, floor(_gw - 96)));
            var _sy = 36 + ((_star * 67) mod max(1, floor(_gh * 0.34)));
            var _twinkle = 0.45 + (sin(current_time * 0.006 + _star) * 0.28);
            draw_set_alpha(_alpha * _night * _twinkle);
            draw_set_color((_star mod 3) == 0 ? make_color_rgb(160, 248, 238) : c_white);
            draw_rectangle(_sx, _sy, _sx + 2, _sy + 2, false);
        }

        demo_draw_intro_lightning_bolt(_gw * 0.18 + (_shake_x * 0.03), _gh * 0.18, _gh * 0.24, _storm_alpha * 0.78, 9);
        demo_draw_intro_lightning_bolt(_gw * 0.30 + (_shake_x * 0.03), _gh * 0.22, _gh * 0.22, _storm_alpha, 1);
        demo_draw_intro_lightning_bolt(_gw * 0.62 + (_shake_x * 0.03), _gh * 0.17, _gh * 0.27, _storm_alpha * 0.68, 13);
        demo_draw_intro_lightning_bolt(_gw * 0.79 + (_shake_x * 0.03), _gh * 0.20, _gh * 0.23, _storm_alpha, 5);

        draw_set_alpha(1);
    }

    draw_set_alpha(1);
}

function demo_draw_intro_capsule(_cx, _base_y, _scale, _alpha, _energy, _front) {
    var _w = 86 * _scale;
    var _h = 210 * _scale;
    var _x1 = _cx - (_w * 0.5);
    var _x2 = _cx + (_w * 0.5);
    var _y1 = _base_y - _h;
    var _y2 = _base_y;

    if (!_front) {
        draw_set_alpha(_alpha * 0.34);
        draw_set_color(c_black);
        draw_ellipse(_x1 - 32 * _scale, _y2 - 6 * _scale, _x2 + 32 * _scale, _y2 + 22 * _scale, false);

        draw_set_alpha(_alpha * 0.82);
        draw_set_color(make_color_rgb(32, 44, 68));
        draw_rectangle(_x1 - 18 * _scale, _y1 - 18 * _scale, _x2 + 18 * _scale, _y2 + 14 * _scale, false);
        draw_set_color(make_color_rgb(22, 30, 48));
        draw_rectangle(_x1 - 26 * _scale, _y1 - 28 * _scale, _x2 + 26 * _scale, _y1 - 10 * _scale, false);
        draw_rectangle(_x1 - 26 * _scale, _y2 - 4 * _scale, _x2 + 26 * _scale, _y2 + 18 * _scale, false);
        draw_set_color(make_color_rgb(82, 94, 112));
        draw_ellipse(_x1 - 24 * _scale, _y2 - 18 * _scale, _x2 + 24 * _scale, _y2 + 16 * _scale, false);
        draw_set_color(make_color_rgb(46, 58, 82));
        draw_ellipse(_x1 - 22 * _scale, _y1 - 24 * _scale, _x2 + 22 * _scale, _y1 + 18 * _scale, false);
        draw_set_alpha(_alpha * (0.18 + (_energy * 0.30)));
        draw_set_color(make_color_rgb(102, 246, 238));
        draw_rectangle(_x1, _y1, _x2, _y2, false);
        draw_set_alpha(_alpha * (0.14 + (_energy * 0.20)));
        draw_set_color(make_color_rgb(255, 126, 226));
        for (var _wisp = 0; _wisp < 5; _wisp += 1) {
            var _wy = _y1 + 36 * _scale + ((_wisp * 31 + floor(current_time * 0.03)) mod max(1, floor((_h - 62 * _scale))));
            draw_line_width(_cx - 30 * _scale + ((_wisp mod 2) * 18 * _scale), _wy, _cx + 26 * _scale - ((_wisp mod 2) * 14 * _scale), _wy - 18 * _scale, max(1, 2 * _scale));
        }
        draw_set_alpha(_alpha * 0.42);
        draw_set_color(make_color_rgb(190, 252, 246));
        draw_line_width(_x1 + 12 * _scale, _y1 + 10 * _scale, _x1 + 12 * _scale, _y2 - 16 * _scale, 3);
        draw_line_width(_x2 - 10 * _scale, _y1 + 20 * _scale, _x2 - 10 * _scale, _y2 - 28 * _scale, 1);
    } else {
        draw_set_alpha(_alpha * (0.22 + (_energy * 0.18)));
        draw_set_color(make_color_rgb(132, 246, 242));
        draw_rectangle(_x1, _y1, _x2, _y2, true);
        draw_ellipse(_x1, _y1 - 12 * _scale, _x2, _y1 + 20 * _scale, true);
        draw_ellipse(_x1, _y2 - 18 * _scale, _x2, _y2 + 12 * _scale, true);
        draw_set_alpha(_alpha * 0.36);
        draw_set_color(make_color_rgb(232, 252, 255));
        draw_line_width(_x1 + 20 * _scale, _y1 + 8 * _scale, _x1 + 20 * _scale, _y2 - 22 * _scale, max(1, 2 * _scale));
        draw_line_width(_x1 + 30 * _scale, _y1 + 18 * _scale, _x1 + 30 * _scale, _y2 - 44 * _scale, 1);
        draw_set_alpha(_alpha * 0.24);
        draw_set_color(make_color_rgb(112, 246, 238));
        draw_ellipse(_x1 + 6 * _scale, _y1 - 4 * _scale, _x2 - 6 * _scale, _y1 + 14 * _scale, true);
        draw_ellipse(_x1 + 6 * _scale, _y2 - 12 * _scale, _x2 - 6 * _scale, _y2 + 4 * _scale, true);
        draw_set_alpha(_alpha * (0.55 + (_energy * 0.30)));
        draw_set_color(make_color_rgb(255, 116, 224));
        draw_line_width(_cx - 64 * _scale, _base_y - 36 * _scale, _cx - 132 * _scale, _base_y + 28 * _scale, 3);
        draw_line_width(_cx + 64 * _scale, _base_y - 42 * _scale, _cx + 142 * _scale, _base_y + 24 * _scale, 3);
        draw_set_alpha(_alpha * _energy * 0.46);
        draw_set_color(make_color_rgb(255, 242, 148));
        draw_circle(_cx, _base_y - 94 * _scale, 24 * _scale, true);
    }

    draw_set_alpha(1);
}

function demo_intro_step_max() {
    return 4;
}

function demo_intro_virtual_time(_step, _timer) {
    var _local = clamp(_timer, 0, 1.15);

    switch (_step) {
        case 0: return 1.15 + (_local * 1.15);
        case 1: return 2.55 + (_local * 1.35);
        case 2: return 4.45 + (_local * 1.45);
        case 3: return 6.85 + (_local * 1.80);
        case 4: return 10.35 + (_local * 1.35);
    }

    return 12.0;
}

function demo_intro_caption(_step) {
    switch (_step) {
        case 0: return "Na Ilha Brasa, Vesper manteve Aeonox preso em uma capsula de contencao.";
        case 1: return "A energia psiquica passou do limite. O laboratorio inteiro comecou a tremer.";
        case 2: return "Lumis e Brotempo surgiram para conter Aeonox antes que Cronaria fosse engolida.";
        case 3: return "O choque abriu uma fresta no espaco-tempo. Monstros de outras eras atravessaram.";
        case 4: return "A noite caiu sobre Cronaria. Cada run comeca no rastro desse ceu estilhacado.";
    }

    return "";
}

function demo_intro_skip_button_rect() {
    var _gw = display_get_gui_width();

    return {
        X: _gw - 186,
        Y: 44,
        W: 130,
        H: 42
    };
}

function demo_draw_intro_contexto(_controller) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _step = instance_exists(_controller) && variable_instance_exists(_controller, "intro_step") ? _controller.intro_step : 0;
    var _timer = instance_exists(_controller) ? _controller.intro_timer : 0;
    var _t = demo_intro_virtual_time(_step, _timer);

    var _lab_alpha = 1 - clamp((_t - 3.55) / 0.85, 0, 1);
    var _field_alpha = clamp((_t - 3.25) / 0.95, 0, 1);
    var _escape = clamp((_t - 2.35) / 1.15, 0, 1);
    var _rupture = clamp((_t - 5.55) / 2.15, 0, 1);
    var _allies = clamp((_t - 4.45) / 1.10, 0, 1);
    var _battle = clamp((_t - 5.20) / 0.95, 0, 1) * (1 - clamp((_t - 9.60) / 0.75, 0, 1));
    var _title = clamp((_t - 10.15) / 1.35, 0, 1);
    var _night = clamp((_t - 7.15) / 2.30, 0, 1);
    var _impact = max(0, sin(_t * 10.5));
    var _lab_quake = clamp((_t - 1.45) / 1.20, 0, 1) * (1 - clamp((_t - 4.35) / 0.85, 0, 1));
    var _shake_power = (_lab_quake * (4 + (_escape * 9))) + (_rupture * (1 - _title) * 5) + (_battle * _impact * 9);
    var _shake_x = sin(current_time * 0.071) * _shake_power;
    var _shake_y = cos(current_time * 0.083) * _shake_power;
    var _sx = _shake_x;
    var _sy = _shake_y;
    var _intro_fx_frame = floor(current_time * 0.025);

    draw_clear(make_color_rgb(8, 12, 24));
    var _cinema_chaos = max(_rupture, _battle);
    demo_draw_intro_field_background(_controller, _gw, _gh, _night, max(_field_alpha, _title), _shake_x, _shake_y, _cinema_chaos);

    if (_lab_alpha > 0) {
        demo_draw_intro_lab_background(_controller, _gw, _gh, _lab_alpha, _shake_x, _shake_y, _escape);
    }

    var _capsule_x = (_gw * 0.48) + (_sx * 0.28);
    var _capsule_base_y = (_gh * 0.64) + (_sy * 0.22);
    var _mewtwo_x = lerp(_capsule_x, _gw * 0.28, clamp((_t - 3.25) / 1.05, 0, 1)) + (_sx * 0.55);
    var _mewtwo_y = lerp(_capsule_base_y + 8, _gh * 0.69, clamp((_t - 3.25) / 1.05, 0, 1)) + (_sy * 0.65);
    var _giovanni_x = lerp(_gw * 0.72, _gw * 0.62, clamp((_t - 4.40) / 1.1, 0, 1)) + (_sx * 0.35);
    var _giovanni_y = lerp(_gh * 0.66, _gh * 0.65, clamp((_t - 4.40) / 1.1, 0, 1)) + _sy;
    var _mew_x = lerp(_gw * 1.10, _gw * 0.73, _allies) - (_sx * 0.65);
    var _mew_y = (_gh * 0.40) + (sin(current_time * 0.0030) * 28) + _sy;
    var _celebi_x = lerp(_gw * 1.12, _gw * 0.82, _allies) - (_sx * 0.60);
    var _celebi_y = (_gh * 0.63) + (sin(current_time * 0.0022 + 1.7) * 12) + _sy;
    var _crack_x = _gw * 0.52 + (_sx * 0.45);
    var _crack_y = _gh * 0.43 + (_sy * 0.45);

    if (_lab_alpha > 0) {
        var _mewtwo_lab_alpha = _lab_alpha * (1 - clamp((_t - 2.92) / 0.36, 0, 1));
        demo_draw_intro_capsule(_capsule_x, _capsule_base_y, 1.18, _lab_alpha, _escape, false);

        if (instance_exists(_controller)) {
            if (_mewtwo_lab_alpha > 0.02) {
                draw_set_alpha(_mewtwo_lab_alpha);
                demo_draw_intro_pokemon(_controller.intro_mewtwo_front_sprite, demo_intro_id_chefe(), _capsule_x + (sin(current_time * 0.016) * _escape * 8), _capsule_base_y - 18 + (cos(current_time * 0.020) * _escape * 8), 1.58 + (_escape * 0.20), 1, c_white, _mewtwo_lab_alpha);
                draw_set_alpha(1);
            }

            if (sprite_exists(_controller.title_burst_sprite) && _escape > 0.2) {
                demo_draw_sheet_frame_centered(_controller.title_burst_sprite, 5, 2, _intro_fx_frame, _capsule_x, _capsule_base_y - 98, 0.72 + (_escape * 0.25), make_color_rgb(255, 132, 226), _lab_alpha * _escape * 0.66);
            }

            if (sprite_exists(_controller.title_electric1_sprite) && _escape > 0.1) {
                demo_draw_sheet_frame_centered(_controller.title_electric1_sprite, 5, 3, _intro_fx_frame, _capsule_x, _capsule_base_y - 98, 0.72 + (_escape * 0.18), make_color_rgb(126, 246, 238), _lab_alpha * _escape * 0.56);
            }

            var _boss_sprite_lab = sprite_exists(_controller.title_giovanni_sprite) ? _controller.title_giovanni_sprite : _controller.title_rocketboss_sprite;

            if (sprite_exists(_boss_sprite_lab)) {
                draw_set_alpha(_lab_alpha);
                draw_set_color(c_black);
                draw_ellipse(_giovanni_x - 50, _giovanni_y - 6, _giovanni_x + 50, _giovanni_y + 10, false);
                demo_draw_sprite_grounded(_boss_sprite_lab, _giovanni_x, _giovanni_y, 2.25, -1, make_color_rgb(226, 220, 255), _lab_alpha);
                draw_set_alpha(1);
            }
        }

        demo_draw_intro_capsule(_capsule_x, _capsule_base_y, 1.18, _lab_alpha, _escape, true);

        if (_escape > 0.15) {
            demo_draw_title_spark_field(_capsule_x, _capsule_base_y - 96, 92, make_color_rgb(112, 246, 238), _lab_alpha * _escape, 16);
            demo_draw_title_spark_field(_capsule_x, _capsule_base_y - 84, 72, make_color_rgb(255, 116, 220), _lab_alpha * _escape * 0.82, 12);
        }
    }

    if (_rupture > 0) {
        draw_set_alpha(0.22 + (_rupture * 0.30));
        draw_set_color(make_color_rgb(112, 246, 238));
        draw_circle(_crack_x, _crack_y, 90 + (_rupture * 210) + (sin(current_time * 0.010) * 12), true);
        draw_set_alpha(0.16 + (_rupture * 0.16));
        draw_circle(_crack_x, _crack_y, 150 + (_rupture * 260), true);
        draw_set_alpha(1);
        demo_draw_space_crack(_crack_x, _crack_y, 160 + (_rupture * 250), 0.55 + (_rupture * 0.40), _rupture);
    }

    var _field_actor_alpha = clamp((_t - 4.18) / 0.50, 0, 1) * (1 - clamp(_lab_alpha * 2.4, 0, 1));

    draw_set_alpha(0.32 * _field_actor_alpha);
    draw_set_color(c_black);
    draw_ellipse(_mewtwo_x - 86, _mewtwo_y - 10, _mewtwo_x + 86, _mewtwo_y + 14, false);
    if (_t < 6.2) draw_ellipse(_giovanni_x - 52, _giovanni_y - 8, _giovanni_x + 52, _giovanni_y + 8, false);
    if (_allies > 0) {
        draw_ellipse(_mew_x - 54, _mew_y + 20, _mew_x + 54, _mew_y + 34, false);
        draw_ellipse(_celebi_x - 48, _celebi_y - 8, _celebi_x + 48, _celebi_y + 8, false);
    }
    draw_set_alpha(1);

    if (instance_exists(_controller)) {
        var _boss_sprite = sprite_exists(_controller.title_giovanni_sprite) ? _controller.title_giovanni_sprite : _controller.title_rocketboss_sprite;

        if (sprite_exists(_boss_sprite) && _field_actor_alpha > 0) {
            var _giovanni_alpha = _field_actor_alpha * (1 - clamp((_t - 6.0) / 1.1, 0, 0.70));

            if (_t >= 7.0) {
                _giovanni_alpha = 0.36 * (1 - (_title * 0.42));
            }

            demo_draw_sprite_grounded(_boss_sprite, _giovanni_x, _giovanni_y, 2.35, -1, make_color_rgb(218, 204, 255), _giovanni_alpha);
        }

        if (sprite_exists(_controller.title_cosmo_sprite) && _rupture > 0.2) {
            demo_draw_sheet_frame_centered(_controller.title_cosmo_sprite, 5, 3, _intro_fx_frame, _crack_x, _crack_y, 1.45 + (_rupture * 0.80), make_color_rgb(112, 246, 238), 0.16 + (_rupture * 0.18));
        }

        if (sprite_exists(_controller.title_electric2_sprite) && _rupture > 0.28) {
            demo_draw_sheet_frame_centered(_controller.title_electric2_sprite, 5, 3, _intro_fx_frame + 3, _crack_x, _crack_y + 8, 1.00 + (_rupture * 0.40), make_color_rgb(255, 132, 226), _rupture * 0.30);
        }

        if (sprite_exists(_controller.title_burst_sprite) && _allies > 0.02) {
            demo_draw_sheet_frame_centered(_controller.title_burst_sprite, 5, 2, _intro_fx_frame, _mew_x - 34, _mew_y - 34, 0.72, make_color_rgb(255, 172, 236), 0.72 * _allies);
            demo_draw_sheet_frame_centered(_controller.title_burst_sprite, 5, 2, _intro_fx_frame + 3, _celebi_x - 28, _celebi_y - 36, 0.58, make_color_rgb(178, 255, 142), 0.62 * _allies);
        }

        draw_set_alpha(_allies);
        draw_set_color(make_color_rgb(255, 128, 226));
        draw_circle(_mew_x - 28, _mew_y - 32, 34 + (_impact * 10), true);
        draw_set_color(make_color_rgb(170, 255, 140));
        draw_circle(_celebi_x - 28, _celebi_y - 36, 30 + (_impact * 8), true);
        draw_set_alpha(1);

        if (_field_actor_alpha > 0) {
            demo_draw_intro_pokemon(_controller.intro_mewtwo_back_sprite, demo_intro_id_chefe(), _mewtwo_x, _mewtwo_y, 2.48 + (_battle * 0.16), -1, c_white, _field_actor_alpha * (1 - (_title * 0.15)));
        }

        if (_allies > 0) {
            draw_set_alpha(_allies);
            demo_draw_intro_pokemon(_controller.intro_mew_front_sprite, demo_intro_id_guardiao(0), _mew_x, _mew_y, 1.78 + (_battle * 0.10), 1, c_white, 1);
            demo_draw_intro_pokemon(_controller.intro_celebi_front_sprite, demo_intro_id_guardiao(1), _celebi_x, _celebi_y, 1.62 + (_battle * 0.09), 1, c_white, 1);
            draw_set_alpha(1);
        }

        if (_battle > 0) {
            var _beam_alpha = _battle * (0.72 + (_impact * 0.26));
            var _jitter = 2 + (_impact * 7);
            var _mewtwo_battle_scale = 2.48 + (_battle * 0.16);
            var _mewtwo_battle_bob = demo_intro_pokemon_bob(demo_intro_id_chefe(), _mewtwo_battle_scale);
            var _mewtwo_battle_beam_x = _mewtwo_x + 42;
            var _mewtwo_battle_beam_y = _mewtwo_y - 82 + _mewtwo_battle_bob;
            var _mewtwo_battle_beam2_x = _mewtwo_x + 34;
            var _mewtwo_battle_beam2_y = _mewtwo_y - 60 + _mewtwo_battle_bob;
            var _clash_push = (sin(current_time * 0.0042) * 0.62) + (sin(current_time * 0.009 + 1.7) * 0.28);
            var _clash_x = _crack_x + (_clash_push * 58) + (_impact * 8);
            var _clash_y = _crack_y + (sin(current_time * 0.006 + 0.8) * 18);
            var _mew_force = clamp((1 - _clash_push) * 0.5, 0.18, 0.86);
            var _mewtwo_force = clamp((1 + _clash_push) * 0.5, 0.18, 0.86);
            var _mew_core_x = _mew_x - 38 + (sin(current_time * 0.010 + 1.2) * 2);
            var _mew_core_y = _mew_y - 36 + (cos(current_time * 0.008 + 1.1) * 2);
            var _celebi_core_x = _celebi_x - 20 + (sin(current_time * 0.010) * 2);
            var _celebi_core_y = _celebi_y - 34 + (cos(current_time * 0.009) * 2);
            var _mewtwo_core_x = _mewtwo_battle_beam_x + (sin(current_time * 0.012 + 0.8) * 2);
            var _mewtwo_core_y = _mewtwo_battle_beam_y + (cos(current_time * 0.011 + 0.6) * 2);
            var _mewtwo_core2_x = _mewtwo_battle_beam2_x + (sin(current_time * 0.010 + 2.4) * 2);
            var _mewtwo_core2_y = _mewtwo_battle_beam2_y + (cos(current_time * 0.009 + 2.2) * 2);

            demo_draw_intro_power_core(_mewtwo_core_x, _mewtwo_core_y, 34, make_color_rgb(190, 112, 255), make_color_rgb(255, 130, 230), _beam_alpha, _impact);
            demo_draw_intro_power_core(_mewtwo_core2_x, _mewtwo_core2_y, 24, make_color_rgb(96, 246, 238), c_white, _beam_alpha * 0.62, _impact);
            demo_draw_intro_power_core(_mew_core_x, _mew_core_y, 28, make_color_rgb(255, 128, 226), make_color_rgb(255, 190, 242), _beam_alpha * 0.88, _impact);
            demo_draw_intro_power_core(_celebi_core_x, _celebi_core_y, 30, make_color_rgb(178, 255, 128), make_color_rgb(226, 255, 170), _beam_alpha, _impact);
            demo_draw_title_spark_field(_mewtwo_core_x, _mewtwo_core_y, 72, make_color_rgb(190, 112, 255), _battle * (0.76 + (_impact * 0.18)), 14);
            demo_draw_title_spark_field(_mew_core_x, _mew_core_y, 58, make_color_rgb(255, 128, 226), _battle * (0.70 + (_impact * 0.18)), 12);
            demo_draw_title_spark_field(_celebi_core_x, _celebi_core_y, 52, make_color_rgb(178, 255, 128), _battle * (0.66 + (_impact * 0.16)), 12);
            demo_draw_title_spark_field(_clash_x, _clash_y, 96 + (_impact * 28), make_color_rgb(112, 246, 238), _beam_alpha * 0.92, 20);
            demo_draw_title_energy_beam(_mewtwo_core_x, _mewtwo_core_y, _clash_x, _clash_y, make_color_rgb(182, 92, 255), make_color_rgb(255, 128, 226), _beam_alpha * (0.86 + (_mewtwo_force * 0.22)), _jitter);
            demo_draw_title_energy_beam(_mewtwo_core2_x, _mewtwo_core2_y, _clash_x - 10, _clash_y + 12, make_color_rgb(96, 246, 238), c_white, _beam_alpha * (0.38 + (_mewtwo_force * 0.18)), _jitter * 0.55);
            demo_draw_title_energy_beam(_mew_core_x, _mew_core_y, _clash_x, _clash_y, make_color_rgb(255, 108, 220), c_white, _beam_alpha * (0.72 + (_mew_force * 0.24)), _jitter);
            demo_draw_title_energy_beam(_celebi_core_x, _celebi_core_y, _clash_x + 8, _clash_y + 10, make_color_rgb(176, 255, 120), make_color_rgb(226, 255, 170), _beam_alpha * (0.68 + (_mew_force * 0.24)), _jitter);

            draw_set_alpha(_beam_alpha * 0.74);
            draw_set_color(make_color_rgb(255, 226, 120));
            draw_circle(_clash_x, _clash_y, 18 + (_impact * 13), false);
            draw_set_alpha(_beam_alpha * 0.46);
            draw_set_color(make_color_rgb(112, 246, 238));
            draw_circle(_clash_x, _clash_y, 52 + (_impact * 22), true);
            draw_set_alpha(_beam_alpha * 0.62);
            draw_set_color(c_white);
            draw_circle(_clash_x, _clash_y, 7 + (_impact * 6), false);
            draw_set_alpha(1);

            if (sprite_exists(_controller.title_psycho_cut_sprite)) {
                demo_draw_sheet_frame_centered(_controller.title_psycho_cut_sprite, 4, 4, _intro_fx_frame, _clash_x, _clash_y, 1.12 + (_impact * 0.30), make_color_rgb(255, 132, 232), _beam_alpha * 0.52);
            }

            if (sprite_exists(_controller.title_ultra_beam_sprite)) {
                demo_draw_sheet_frame_centered(_controller.title_ultra_beam_sprite, 4, 1, _intro_fx_frame, (_mewtwo_x + _clash_x) * 0.5, (_mewtwo_battle_beam_y + _clash_y) * 0.5, 0.78, make_color_rgb(190, 112, 255), _beam_alpha * 0.36);
                demo_draw_sheet_frame_centered(_controller.title_ultra_beam_sprite, 4, 1, _intro_fx_frame + 2, (_mew_x + _clash_x) * 0.5, (_mew_y + _clash_y) * 0.5, 0.66, make_color_rgb(176, 255, 120), _beam_alpha * 0.32);
            }
        }
    }

    var _flash1 = clamp(1 - abs(_t - 2.55) / 0.24, 0, 1);
    var _flash2 = clamp(1 - abs(_t - 3.70) / 0.32, 0, 1);
    var _flash3 = clamp(1 - abs(_t - 5.35) / 0.28, 0, 1);
    var _flash4 = clamp(1 - abs(_t - 10.15) / 0.44, 0, 1);
    var _white_flash = max(max(_flash1, _flash2), max(_flash3, _flash4 * 0.75));

    if (_white_flash > 0) {
        draw_set_alpha(_white_flash * 0.86);
        draw_set_color(c_white);
        draw_rectangle(0, 0, _gw, _gh, false);
        draw_set_alpha(1);
    }

    var _skip_rect = demo_intro_skip_button_rect();
    var _mx_intro = device_mouse_x_to_gui(0);
    var _my_intro = device_mouse_y_to_gui(0);
    var _skip_hover = demo_hover_rect(_mx_intro, _my_intro, _skip_rect.X, _skip_rect.Y, _skip_rect.W, _skip_rect.H);
    demo_draw_gold_button(_skip_rect, "PULAR", _skip_hover);

    if (_title < 0.95) {
        battle_ui_draw_nineslice_panel(42, _gh - 148, _gw - 84, 104);
        draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(36, 30, 28) : c_white);

        var _caption = demo_intro_caption(_step);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        battle_ui_font_body();
        draw_text_ext(96, _gh - 118, _caption, 24, _gw - 218);

        var _continue_txt = _step >= demo_intro_step_max() ? "ENTER / clique: comecar" : "ENTER / clique: continuar";
        var _blink_continue = 0.58 + (sin(current_time * 0.008) * 0.22);
        draw_set_alpha(_blink_continue);
        draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(72, 66, 58) : make_color_rgb(220, 236, 238));
        draw_set_halign(fa_right);
        battle_ui_font_body();
        draw_text(_gw - 82, _gh - 94, _continue_txt);
        draw_set_alpha(1);
        draw_set_halign(fa_left);
        battle_ui_font_title();
    }

    if (_title > 0) {
        draw_set_alpha(0.58 * _title);
        draw_set_color(make_color_rgb(8, 12, 28));
        draw_rectangle(0, 0, _gw, _gh, false);
        draw_set_alpha(_title);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text_transformed((_gw * 0.5) + 3, 96 + 3, "RASGO TEMPORAL", 2.10, 2.10, 0);
        draw_set_color(make_color_rgb(255, 238, 118));
        draw_text_transformed(_gw * 0.5, 96, "RASGO TEMPORAL", 2.10, 2.10, 0);
        draw_set_color(c_white);
        draw_text_transformed(_gw * 0.5, 146, "O ESPACO ESTILHACADO", 1.25, 1.25, 0);

        if (_step >= demo_intro_step_max()) {
            var _blink = 0.68 + (sin(current_time * 0.006) * 0.24);
            draw_set_alpha(_blink);
            draw_set_color(make_color_rgb(220, 236, 238));
            draw_text(_gw * 0.5, _gh - 86, "ENTER / clique para continuar");
        }

        draw_set_alpha(1);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}

function demo_draw_game_over_background(_controller, _gw, _gh) {
    var _shake_x = sin(current_time * 0.020) * 2;
    var _shake_y = cos(current_time * 0.017) * 1.5;

    demo_draw_intro_field_background(_controller, _gw, _gh, 1, 1, _shake_x, _shake_y, 1);

    draw_set_alpha(0.34);
    draw_set_color(make_color_rgb(4, 8, 16));
    draw_rectangle(0, 0, _gw, _gh, false);

    draw_set_alpha(0.20);
    draw_set_color(c_black);
    draw_rectangle(0, _gh * 0.62, _gw, _gh, false);

    draw_set_alpha(1);
}

function demo_draw_game_over_pokeball(_controller, _x, _y) {
    var _ball = demo_item_icon_get("pokebola");
    var _timer = instance_exists(_controller) && variable_instance_exists(_controller, "game_over_timer") ? _controller.game_over_timer : 1;
    var _entry = clamp(_timer / 0.65, 0, 1);
    var _settle = (1 - _entry) * sin(_entry * pi * 3) * 18;
    var _pulse = 0.92 + (sin(current_time * 0.006) * 0.04);
    var _bob = sin(current_time * 0.0045) * 2.2;
    var _draw_y = _y + _bob - _settle;
    var _rot = -14 + (sin(current_time * 0.004) * 2.4);
    var _scale = (2.42 + (sin(current_time * 0.006) * 0.035)) * lerp(0.86, 1, _entry);

    draw_set_alpha(0.44);
    draw_set_color(c_black);
    draw_ellipse(_x - 42, _y + 20, _x + 48, _y + 35, false);

    draw_set_alpha(0.34 * _pulse);
    draw_set_color(make_color_rgb(255, 96, 58));
    draw_circle(_x + 3, _draw_y - 4, 34 + (_pulse * 6), true);
    draw_set_alpha(1);

    for (var _back_g = 0; _back_g < 11; _back_g += 1) {
        var _back_x = _x - 50 + ((_back_g * 13) mod 100);
        var _back_y = _y + 26 + ((_back_g * 5) mod 8);
        var _back_h = 5 + ((_back_g * 3) mod 7);
        var _sway = sin(current_time * 0.004 + _back_g) * 2;
        draw_set_alpha(0.30 + ((_back_g mod 3) * 0.06));
        draw_set_color((_back_g mod 2) == 0 ? make_color_rgb(58, 132, 70) : make_color_rgb(92, 174, 84));
        draw_line_width(_back_x, _back_y, _back_x + _sway, _back_y - _back_h, 1);
    }

    draw_set_alpha(1);

    if (sprite_exists(_ball)) {
        draw_sprite_ext(_ball, 0, _x, _draw_y - 4, _scale, _scale, _rot, c_white, 1);
    } else {
        draw_set_color(c_red);
        draw_circle(_x, _draw_y - 4, 24, false);
        draw_set_color(c_white);
        draw_rectangle(_x - 24, _draw_y - 4, _x + 24, _draw_y + 20, false);
        draw_set_color(c_black);
        draw_line_width(_x - 22, _draw_y - 4, _x + 22, _draw_y - 4, 3);
        draw_circle(_x, _draw_y - 4, 6, false);
    }

    for (var _g = 0; _g < 14; _g += 1) {
        var _gx = _x - 58 + ((_g * 17) mod 116);
        var _gy = _y + 28 + ((_g * 7) mod 9);
        var _blade_h = 4 + ((_g * 3) mod 7);
        var _lean = sin(current_time * 0.0045 + _g * 0.7) * 2.5;
        draw_set_alpha(0.34 + ((_g mod 3) * 0.08));
        draw_set_color((_g mod 2) == 0 ? make_color_rgb(72, 154, 78) : make_color_rgb(106, 190, 90));
        draw_line_width(_gx, _gy, _gx + _lean, _gy - _blade_h, 1);
    }

    draw_set_alpha(1);
}

function demo_draw_game_over_stat_mini(_pokemon, _x, _y, _w) {
    var _labels = ["HP", "ATK", "DEF", "VEL"];
    var _stats = ["hp", "atk", "def", "spd"];
    var _colors = [
        make_color_rgb(104, 210, 96),
        make_color_rgb(232, 88, 72),
        make_color_rgb(88, 146, 224),
        make_color_rgb(242, 206, 78)
    ];
    var _bar_x = _x + 34;
    var _bar_w = max(42, _w - 38);

    for (var _i = 0; _i < 4; _i += 1) {
        var _yy = _y + (_i * 14);
        draw_set_color(make_color_rgb(50, 42, 38));
        draw_text_transformed(_x, _yy - 4, _labels[_i], 0.42, 0.42, 0);
        draw_set_color(make_color_rgb(190, 184, 166));
        draw_rectangle(_bar_x, _yy, _bar_x + _bar_w, _yy + 7, false);
        draw_set_color(make_color_rgb(96, 82, 74));
        draw_rectangle(_bar_x, _yy, _bar_x + _bar_w, _yy + 7, true);
        draw_set_color(_colors[_i]);
        draw_rectangle(_bar_x + 1, _yy + 1, _bar_x + 1 + ((_bar_w - 2) * demo_pokemon_stat_pct(_pokemon, _stats[_i])), _yy + 6, false);
    }
}

function demo_draw_game_over_skill_line(_skill, _x, _y, _w) {
    if (!is_struct(_skill)) {
        draw_set_color(make_color_rgb(104, 92, 82));
        draw_text_transformed(_x, _y, "Vazio", 0.42, 0.42, 0);
        return;
    }

    battle_ui_draw_type_icon(_skill.TipoElementar, _x, _y + 1, 0.34);
    draw_set_color(make_color_rgb(36, 30, 28));
    battle_ui_draw_text_fit(_x + 36, _y, _skill.Nome, _w - 38, 0.43, make_color_rgb(36, 30, 28));
}

function demo_draw_game_over_passive_line(_label, _name, _unlocked, _x, _y, _w) {
    var _nome = is_string(_name) && _name != "" ? _name : "Sem passiva";
    var _suffix = _unlocked ? "" : " (bloq.)";
    draw_set_color(_unlocked ? make_color_rgb(36, 30, 28) : make_color_rgb(116, 98, 84));
    battle_ui_draw_text_fit(_x, _y, _label + ": " + _nome + _suffix, _w, 0.39, _unlocked ? make_color_rgb(36, 30, 28) : make_color_rgb(116, 98, 84));
}

function demo_draw_game_over_party_card(_pokemon, _x, _y, _w, _h, _slot, _filled_total) {
    var _has_pokemon = is_struct(_pokemon);

    draw_set_color(_has_pokemon ? make_color_rgb(242, 235, 208) : make_color_rgb(202, 194, 178));
    draw_rectangle(_x, _y, _x + _w, _y + _h, false);
    draw_set_color(make_color_rgb(96, 78, 58));
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);
    draw_rectangle(_x + 4, _y + 4, _x + _w - 4, _y + _h - 4, true);

    draw_set_color(_has_pokemon ? make_color_rgb(132, 24, 36) : make_color_rgb(86, 80, 78));
    draw_rectangle(_x + 8, _y + 8, _x + _w - 8, _y + 36, false);
    draw_set_color(c_white);
    draw_text_transformed(_x + 16, _y + 16, string(_slot + 1) + "/4", 0.46, 0.46, 0);

    if (!_has_pokemon) {
        draw_set_color(make_color_rgb(72, 64, 58));
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_transformed(_x + (_w * 0.5), _y + (_h * 0.5), "Slot vazio", 0.62, 0.62, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        return;
    }

    draw_set_color(make_color_rgb(36, 30, 28));
    battle_ui_draw_text_fit(_x + 16, _y + 46, _pokemon.Nome, _w - 88, 0.66, make_color_rgb(36, 30, 28));
    draw_set_halign(fa_right);
    draw_text_transformed(_x + _w - 16, _y + 46, "Lv." + string(_pokemon.Level), 0.56, 0.56, 0);
    draw_set_halign(fa_left);

    var _raridade = variable_struct_exists(_pokemon, "RaridadeEfetiva") ? _pokemon.RaridadeEfetiva : (variable_struct_exists(_pokemon, "RaridadePadrao") ? _pokemon.RaridadePadrao : PokemonRaridade.COMMON);
    pokemon_raridade_draw_icon(_raridade, _x + _w - 32, _y + 14, 18);
    battle_ui_draw_type_icon(_pokemon.Tipo1, _x + 16, _y + 68, 0.43);

    if (_pokemon.Tipo2 != PokemonTipo.NONE && _pokemon.Tipo2 != _pokemon.Tipo1) {
        battle_ui_draw_type_icon(_pokemon.Tipo2, _x + 53, _y + 68, 0.43);
    }

    var _icon = demo_pokemon_icon_get(_pokemon.ID, variable_struct_exists(_pokemon, "IsShiny") && _pokemon.IsShiny);
    var _sprite_x = _x + 54;
    var _sprite_y = _y + 117;

    draw_set_color(make_color_rgb(98, 154, 112));
    draw_rectangle(_x + 14, _y + 92, _x + 100, _y + 142, false);
    draw_set_color(make_color_rgb(52, 116, 70));
    draw_line_width(_x + 22, _y + 133, _x + 92, _y + 133, 2);

    if (sprite_exists(_icon)) {
        draw_sprite_ext(_icon, 0, _sprite_x, _sprite_y, 1.48, 1.48, 0, c_white, 1);
    } else {
        demo_draw_pokemon_sprite(_pokemon.ID, _sprite_x, _sprite_y + 18, 0.78, 1, 0);
    }

    demo_draw_game_over_stat_mini(_pokemon, _x + 112, _y + 92, _w - 130);

    var _skills_y = _y + 154;
    draw_set_color(make_color_rgb(184, 166, 132));
    draw_line_width(_x + 16, _skills_y - 8, _x + _w - 16, _skills_y - 8, 1);
    draw_set_color(make_color_rgb(36, 30, 28));
    draw_text_transformed(_x + 16, _skills_y - 2, "Habilidades", 0.46, 0.46, 0);

    var _skill_col_w = ((_w - 34) * 0.5) - 4;

    for (var _s = 0; _s < 4; _s += 1) {
        var _skill = undefined;

        if (variable_struct_exists(_pokemon, "HabilidadesEquipadas") && is_array(_pokemon.HabilidadesEquipadas) && _s < array_length(_pokemon.HabilidadesEquipadas)) {
            _skill = _pokemon.HabilidadesEquipadas[_s];
        }

        var _skill_col = _s mod 2;
        var _skill_row = floor(_s / 2);
        demo_draw_game_over_skill_line(_skill, _x + 16 + (_skill_col * (_skill_col_w + 8)), _skills_y + 20 + (_skill_row * 23), _skill_col_w);
    }

    var _passive_y = _skills_y + 68;
    draw_set_color(make_color_rgb(184, 166, 132));
    draw_line_width(_x + 16, _passive_y - 8, _x + _w - 16, _passive_y - 8, 1);
    draw_set_color(make_color_rgb(36, 30, 28));
    draw_text_transformed(_x + 16, _passive_y - 2, "Passivas", 0.46, 0.46, 0);

    var _p1_unlocked = variable_struct_exists(_pokemon, "Passiva1Desbloqueada") && _pokemon.Passiva1Desbloqueada;
    var _p2_unlocked = variable_struct_exists(_pokemon, "Passiva2Desbloqueada") && _pokemon.Passiva2Desbloqueada;
    var _p1 = variable_struct_exists(_pokemon, "Passiva1Nome") ? _pokemon.Passiva1Nome : "";
    var _p2 = variable_struct_exists(_pokemon, "Passiva2Nome") ? _pokemon.Passiva2Nome : "";
    demo_draw_game_over_passive_line("P1", _p1, _p1_unlocked, _x + 16, _passive_y + 18, _w - 32);
    demo_draw_game_over_passive_line("P2", _p2, _p2_unlocked, _x + 16, _passive_y + 34, _w - 32);
}

function demo_game_over_button_rect(_gw, _gh) {
    var _panel_y = 46;
    var _panel_h = 172;
    var _cards_y = max(_panel_y + _panel_h + 150, _gh - 370);
    var _card_h = min(270, _gh - _cards_y - 84);
    _card_h = max(254, _card_h);
    var _btn_w = 320;
    var _btn_h = 54;
    var _btn_x = (_gw - _btn_w) * 0.5;
    var _btn_y = min(_gh - 68, _cards_y + _card_h + 16);

    return { X: _btn_x, Y: _btn_y, W: _btn_w, H: _btn_h };
}

function demo_draw_game_over(_controller) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    demo_draw_game_over_background(_controller, _gw, _gh);

    var _filled_total = 0;

    if (instance_exists(_controller) && is_array(_controller.player_party)) {
        for (var _count_i = 0; _count_i < min(4, array_length(_controller.player_party)); _count_i += 1) {
            if (is_struct(_controller.player_party[_count_i])) {
                _filled_total += 1;
            }
        }
    }

    var _panel_w = min(_gw - 96, 860);
    var _panel_h = 172;
    var _panel_x = (_gw - _panel_w) * 0.5;
    var _panel_y = 46;
    battle_ui_draw_nineslice_panel(_panel_x, _panel_y, _panel_w, _panel_h);

    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(196, 46, 54));
    draw_text_transformed(_gw * 0.5, _panel_y + 24, "GAME OVER", 1.95, 1.95, 0);

    draw_set_halign(fa_left);
    draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(36, 30, 28) : c_white);
    battle_ui_font_body();
    draw_text_ext(
        _panel_x + 42,
        _panel_y + 76,
        "A ultima Capsula caiu na grama enquanto a fenda continuava rasgando Cronaria. A run acabou, mas o eco dessa equipe ainda fica preso no tempo.",
        25,
        _panel_w - 84
    );
    battle_ui_font_title();
    draw_set_halign(fa_left);

    demo_draw_game_over_pokeball(_controller, _gw * 0.5, max(_panel_y + _panel_h + 112, _gh * 0.51));

    var _cards_y = max(_panel_y + _panel_h + 150, _gh - 370);
    var _card_h = min(270, _gh - _cards_y - 84);
    _card_h = max(254, _card_h);
    var _slots = 4;
    var _gap = 14;
    var _party_w = min(_gw - 80, 1220);
    var _card_w = (_party_w - (_gap * (_slots - 1))) / _slots;
    var _cards_x = (_gw - _party_w) * 0.5;

    draw_set_color(c_white);
    draw_text_transformed(_cards_x, _cards_y - 30, "Equipe final: " + string(_filled_total) + "/4", 0.74, 0.74, 0);

    for (var _i = 0; _i < _slots; _i += 1) {
        var _pokemon = undefined;

        if (instance_exists(_controller) && is_array(_controller.player_party) && _i < array_length(_controller.player_party)) {
            _pokemon = _controller.player_party[_i];
        }

        demo_draw_game_over_party_card(_pokemon, _cards_x + (_i * (_card_w + _gap)), _cards_y, _card_w, _card_h, _i, _filled_total);
    }

    var _button_rect = demo_game_over_button_rect(_gw, _gh);
    var _hover = demo_hover_rect(_mx, _my, _button_rect.X, _button_rect.Y, _button_rect.W, _button_rect.H);
    demo_draw_gold_button(_button_rect, "VOLTAR AO MENU", _hover);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}

function demo_pokemon_curar_ativo(_controller) {
    if (!instance_exists(_controller)) {
        return false;
    }

    with (_controller) {
        demo_party_garantir(id);

        for (var _p = 0; _p < array_length(player_party); _p += 1) {
            var _party_pokemon = player_party[_p];

            if (is_struct(_party_pokemon)) {
                _party_pokemon.HpAtual = _party_pokemon.HpMax;

                if (variable_struct_exists(_party_pokemon, "Status")) {
                    _party_pokemon.Status = "";
                }
            }
        }

        if (is_struct(player_pokemon_data)) {
            player_pokemon_data.HpAtual = player_pokemon_data.HpMax;

            if (variable_struct_exists(player_pokemon_data, "Status")) {
                player_pokemon_data.Status = "";
            }
        }

        if (instance_exists(player_inst)) {
            player_inst.hp_atual = player_inst.hp_max;

            if (is_struct(player_inst.status_map)) {
                player_inst.status_map = {};
            }
        }
    }

    return true;
}

function demo_party_curar_pos_batalha(_controller) {
    if (!instance_exists(_controller)) {
        return 0;
    }

    var _total_curado = 0;

    with (_controller) {
        demo_party_garantir(id);

        for (var _p = 0; _p < array_length(player_party); _p += 1) {
            var _party_pokemon = player_party[_p];

            if (!is_struct(_party_pokemon)) {
                continue;
            }

            if (!variable_struct_exists(_party_pokemon, "HpAtual")) {
                _party_pokemon.HpAtual = _party_pokemon.HpMax;
            }

            if (_party_pokemon.HpAtual <= 0 || _party_pokemon.HpAtual >= _party_pokemon.HpMax) {
                continue;
            }

            var _antes = _party_pokemon.HpAtual;
            var _cura = max(1, ceil(_party_pokemon.HpMax * 0.125));
            _party_pokemon.HpAtual = min(_party_pokemon.HpMax, _party_pokemon.HpAtual + _cura);
            _total_curado += _party_pokemon.HpAtual - _antes;
        }

        if (is_struct(player_pokemon_data) && variable_struct_exists(player_pokemon_data, "HpAtual")) {
            if (instance_exists(player_inst)) {
                player_inst.hp_atual = clamp(player_pokemon_data.HpAtual, 1, player_inst.hp_max);
            }
        }
    }

    return _total_curado;
}

function demo_asset_sprite(_path) {
    var _rel = string_replace_all(string(_path), "\\", "/");
    var _found_path = project_asset_path(_rel);

    if (_found_path != "") {
        return sprite_add(_found_path, 1, false, false, 0, 0);
    }

    if (!project_asset_permitido(_rel)) {
        return -1;
    }

    var _filename_only = filename_name(_rel) + filename_ext(_rel);
    var _without_datafiles = _rel;

    if (string_pos("datafiles/", _without_datafiles) == 1) {
        _without_datafiles = string_delete(_without_datafiles, 1, string_length("datafiles/"));
    }

    var _candidates = [
        _rel,
        _filename_only,
        _without_datafiles,
        project_asset_join(working_directory, _rel),
        project_asset_join(working_directory, _filename_only),
        project_asset_join(working_directory, _without_datafiles),
        project_asset_join(working_directory, "../" + _rel)
    ];

    for (var _i = 0; _i < array_length(_candidates); _i += 1) {
        if (file_exists(_candidates[_i])) {
            return sprite_add(_candidates[_i], 1, false, false, 0, 0);
        }
    }

    return -1;
}

function demo_pokemon_nome(_id) {
    if (variable_global_exists("pokedex") && is_struct(global.pokedex)) {
        var _pokemon = pokemon_db_get(global.pokedex, _id);

        if (is_struct(_pokemon) && is_string(_pokemon.Nome)) {
            return _pokemon.Nome;
        }
    }

    var _species = pokemon_species_info_gen5(_id);

    if (is_struct(_species) && is_string(_species.Nome)) {
        return _species.Nome;
    }

    return "Monstro #" + string(_id);
}

function demo_get_initial_skills(_pokemon_id) {
    var _result = [];

    if (!variable_global_exists("pokedex") || !is_struct(global.pokedex)) {
        return _result;
    }

    var _pokemon = pokemon_db_get(global.pokedex, _pokemon_id);

    if (!is_struct(_pokemon)) {
        return _result;
    }

    var _skills = _pokemon.ListaHabilidadesDisponiveis;

    for (var _i = 0; _i < array_length(_skills); _i += 1) {
        var _skill = _skills[_i];

        if (is_struct(_skill) && _skill.NivelAprendizado <= 1) {
            array_push(_result, _skill);
        }
    }

    return _result;
}

function demo_get_pokemon_sprite(_pokemon_id) {
    if (!variable_global_exists("demo_sprite_cache") || !is_struct(global.demo_sprite_cache)) {
        global.demo_sprite_cache = {};
    }

    var _key = string(_pokemon_id);

    if (variable_struct_exists(global.demo_sprite_cache, _key)) {
        var _cached = variable_struct_get(global.demo_sprite_cache, _key);

        if (sprite_exists(_cached)) {
            return _cached;
        }
    }

    var _sprite = pokemon_sprite_carregar_pose(_pokemon_id, "idle", -1);
    variable_struct_set(global.demo_sprite_cache, _key, _sprite);
    return _sprite;
}

function demo_liberar_sprite_cache() {
    if (!variable_global_exists("demo_sprite_cache") || !is_struct(global.demo_sprite_cache)) {
        return;
    }

    var _keys = variable_struct_get_names(global.demo_sprite_cache);

    for (var _i = 0; _i < array_length(_keys); _i += 1) {
        pokemon_sprite_liberar(variable_struct_get(global.demo_sprite_cache, _keys[_i]));
    }

    global.demo_sprite_cache = {};
}

function demo_pokemon_icon_path(_pokemon_id, _is_shiny) {
    var _nome = pokemon_sprite_nome_canonico(_pokemon_id);
    var _nomes = [string(_pokemon_id)];

    if (_nome != "") {
        array_push(_nomes, _nome);
    }

    var _pastas = _is_shiny ? ["datafiles/sprites/criaturas/icones/cromatico/", "datafiles/sprites/criaturas/icones/"] : ["datafiles/sprites/criaturas/icones/"];

    for (var _p = 0; _p < array_length(_pastas); _p += 1) {
        for (var _n = 0; _n < array_length(_nomes); _n += 1) {
            var _path = project_asset_path(_pastas[_p] + _nomes[_n] + ".png");

            if (_path != "") {
                return _path;
            }
        }
    }

    return "";
}

function demo_pokemon_icon_get(_pokemon_id, _is_shiny) {
    if (!variable_global_exists("demo_pokemon_icon_cache") || !is_struct(global.demo_pokemon_icon_cache)) {
        global.demo_pokemon_icon_cache = {};
    }

    var _key = string(_pokemon_id) + (_is_shiny ? "_shiny" : "_normal");

    if (variable_struct_exists(global.demo_pokemon_icon_cache, _key)) {
        return variable_struct_get(global.demo_pokemon_icon_cache, _key);
    }

    var _path = demo_pokemon_icon_path(_pokemon_id, _is_shiny);
    var _sprite = -1;

    if (_path != "") {
        _sprite = sprite_add(_path, 1, false, false, 0, 0);

        if (sprite_exists(_sprite)) {
            sprite_set_offset(_sprite, sprite_get_width(_sprite) * 0.5, sprite_get_height(_sprite) * 0.5);
        }
    }

    if (!sprite_exists(_sprite)) {
        _sprite = placeholder_criatura_sprite(_pokemon_id, "icon", _is_shiny);
    }

    variable_struct_set(global.demo_pokemon_icon_cache, _key, _sprite);
    return _sprite;
}

function demo_liberar_pokemon_icon_cache() {
    if (!variable_global_exists("demo_pokemon_icon_cache") || !is_struct(global.demo_pokemon_icon_cache)) {
        return;
    }

    var _keys = variable_struct_get_names(global.demo_pokemon_icon_cache);

    for (var _i = 0; _i < array_length(_keys); _i += 1) {
        pokemon_sprite_liberar(variable_struct_get(global.demo_pokemon_icon_cache, _keys[_i]));
    }

    global.demo_pokemon_icon_cache = {};
}

function demo_item_icon_get(_id_item) {
    if (!variable_global_exists("demo_item_icon_cache") || !is_struct(global.demo_item_icon_cache)) {
        global.demo_item_icon_cache = {};
    }

    if (variable_struct_exists(global.demo_item_icon_cache, _id_item)) {
        return variable_struct_get(global.demo_item_icon_cache, _id_item);
    }

    var _sprite = demo_asset_sprite("datafiles/sprites/itens/" + string(_id_item) + ".png");

    if (!sprite_exists(_sprite)) {
        _sprite = placeholder_item_sprite(_id_item);
    }

    if (sprite_exists(_sprite)) {
        sprite_set_offset(_sprite, sprite_get_width(_sprite) * 0.5, sprite_get_height(_sprite) * 0.5);
    }

    variable_struct_set(global.demo_item_icon_cache, _id_item, _sprite);
    return _sprite;
}

function demo_draw_item_icon(_id_item, _x, _y, _size) {
    var _sprite = demo_item_icon_get(_id_item);

    if (sprite_exists(_sprite)) {
        var _scale = _size / max(sprite_get_width(_sprite), sprite_get_height(_sprite));
        var _bbox_center_x = (sprite_get_bbox_left(_sprite) + sprite_get_bbox_right(_sprite)) * 0.5;
        var _bbox_center_y = (sprite_get_bbox_top(_sprite) + sprite_get_bbox_bottom(_sprite)) * 0.5;
        var _draw_x = _x - ((_bbox_center_x - sprite_get_xoffset(_sprite)) * _scale);
        var _draw_y = _y - ((_bbox_center_y - sprite_get_yoffset(_sprite)) * _scale);
        draw_sprite_ext(_sprite, 0, _draw_x, _draw_y, _scale, _scale, 0, c_white, 1);
        return;
    }

    draw_set_color(make_color_rgb(224, 210, 168));
    draw_rectangle(_x - (_size * 0.5), _y - (_size * 0.5), _x + (_size * 0.5), _y + (_size * 0.5), false);
    draw_set_color(make_color_rgb(108, 82, 68));
    draw_rectangle(_x - (_size * 0.5), _y - (_size * 0.5), _x + (_size * 0.5), _y + (_size * 0.5), true);
}

function demo_draw_trainer_frame(_sprite, _frame, _row, _x, _y, _scale) {
    if (!sprite_exists(_sprite)) {
        return;
    }

    var _frame_w = sprite_get_width(_sprite) / 4;
    var _frame_h = sprite_get_height(_sprite) / 4;
    var _trim = 1;
    var _src_x = (_frame * _frame_w) + _trim;
    var _src_y = (_row * _frame_h) + _trim;
    var _src_w = _frame_w - (_trim * 2);
    var _src_h = _frame_h - (_trim * 2);

    draw_sprite_part_ext(
        _sprite,
        0,
        _src_x,
        _src_y,
        _src_w,
        _src_h,
        _x - (_src_w * _scale * 0.5),
        _y - (_src_h * _scale),
        _scale,
        _scale,
        c_white,
        1
    );
}

function demo_liberar_item_icon_cache() {
    if (!variable_global_exists("demo_item_icon_cache") || !is_struct(global.demo_item_icon_cache)) {
        return;
    }

    var _keys = variable_struct_get_names(global.demo_item_icon_cache);

    for (var _i = 0; _i < array_length(_keys); _i += 1) {
        pokemon_sprite_liberar(variable_struct_get(global.demo_item_icon_cache, _keys[_i]));
    }

    global.demo_item_icon_cache = {};
}

function demo_effect_sprite_get(_id_effect) {
    if (!variable_global_exists("demo_effect_sprite_cache") || !is_struct(global.demo_effect_sprite_cache)) {
        global.demo_effect_sprite_cache = {};
    }

    if (variable_struct_exists(global.demo_effect_sprite_cache, _id_effect)) {
        return variable_struct_get(global.demo_effect_sprite_cache, _id_effect);
    }

    var _sprite = demo_asset_sprite("datafiles/sprites/efeitos/" + string(_id_effect) + ".png");

    if (sprite_exists(_sprite)) {
        sprite_set_offset(_sprite, sprite_get_width(_sprite) * 0.5, sprite_get_height(_sprite) * 0.5);
    }

    variable_struct_set(global.demo_effect_sprite_cache, _id_effect, _sprite);
    return _sprite;
}

function demo_liberar_effect_sprite_cache() {
    if (!variable_global_exists("demo_effect_sprite_cache") || !is_struct(global.demo_effect_sprite_cache)) {
        global.demo_effect_sprite_cache = {};
    }

    var _keys = variable_struct_get_names(global.demo_effect_sprite_cache);

    for (var _i = 0; _i < array_length(_keys); _i += 1) {
        pokemon_sprite_liberar(variable_struct_get(global.demo_effect_sprite_cache, _keys[_i]));
    }

    global.demo_effect_sprite_cache = {};

    if (!variable_global_exists("battle_status_effect_sprite_cache") || !is_struct(global.battle_status_effect_sprite_cache)) {
        global.battle_status_effect_sprite_cache = {};
        return;
    }

    var _status_keys = variable_struct_get_names(global.battle_status_effect_sprite_cache);

    for (var _s = 0; _s < array_length(_status_keys); _s += 1) {
        pokemon_sprite_liberar(variable_struct_get(global.battle_status_effect_sprite_cache, _status_keys[_s]));
    }

    global.battle_status_effect_sprite_cache = {};
}

function demo_card_sprite_offset_x(_pokemon_id) {
    return 0;
}

function demo_card_sprite_scale(_pokemon_id) {
    return 1.58;
}

function demo_status_nome_visual(_status) {
    switch (_status) {
        case "Molhado": return "MOLHADO";
        case "Enraizado": return "ENRAIZADO";
        case "Queimando":
        case "Queimado": return "QUEIMADO";
        case "Preso": return "PRESO";
        case "Paralisado": return "PARALISADO";
        case "Ofuscado": return "OFUSCADO";
        case "Envenenado": return "ENVENENADO";
        case "Corroendo": return "CORROENDO";
        case "Fotossintese": return "FOTOSSINTESE";
        case "Crescimento": return "CRESCIMENTO";
        case "ArmaduraDerretida": return "ARMADURA DERRETIDA";
        case "CalorConcentrado": return "CALOR CONCENTRADO";
        case "CalorEscaldante": return "CALOR ESCALDANTE";
        case "FenixAtiva": return "FENIX";
        case "NevoaEstagnante": return "NEVOA";
        case "FluxoAcelerado": return "FLUXO";
        case "MareAlta": return "MARE ALTA";
        case "Sobrecarregado": return "SOBRECARGA";
        case "ErroEletrico": return "ERRO ELETRICO";
        case "EstaticaAtiva": return "ESTATICA";
        case "Gelado": return "GELADO";
        case "Congelando": return "CONGELANDO";
        case "Fragil": return "FRAGIL";
        case "Granizo": return "GRANIZO";
        case "MantoGelo": return "MANTO DE GELO";
        case "PosturaQuebrada": return "POSTURA QUEBRADA";
        case "ImpetoOfensivo": return "IMPETO";
        case "EspiritoLuta": return "ESPIRITO DE LUTA";
        case "Vulneravel": return "VULNERAVEL";
        case "BarreiraLama": return "BARREIRA DE LAMA";
        case "Aterrado": return "ATERRADO";
        case "AreiaMovedica": return "AREIA MOVEDICA";
        case "Desabando": return "DESABANDO";
        case "Turbulento": return "TURBULENTO";
        case "VentoCauda": return "VENTO DE CAUDA";
        case "VentoDeCauda": return "VENTO DE CAUDA";
        case "Evasivo": return "EVASIVO";
        case "PenasLeves": return "PENAS LEVES";
        case "MarcadoRasante": return "MARCADO RASANTE";
        case "EscudoCinetico": return "ESCUDO CINETICO";
        case "FocoPsiquico": return "FOCO PSIQUICO";
        case "DistorcaoEspacial": return "DISTORCAO";
        case "ParalisiaMental": return "PARALISIA MENTAL";
        case "AmnesiaInduzida": return "AMNESIA";
        case "CasuloRigido": return "CASULO";
        case "SedaPresa": return "SEDA PRESA";
        case "Infestado": return "INFESTADO";
        case "EnxameAtivo": return "ENXAME";
        case "Metamorfose": return "METAMORFOSE";
        case "ToxinaAtiva": return "TOXINA";
        case "Fragmentado": return "FRAGMENTADO";
        case "CascaRocha": return "CASCA DE ROCHA";
        case "ImpactoGeologico": return "IMPACTO GEOLOGICO";
        case "FossilVivo": return "FOSSIL VIVO";
        case "TerrorCrescente": return "TERROR";
        case "Intangivel": return "INTANGIVEL";
        case "Maldito": return "MALDITO";
        case "EssenciaDrenada": return "ESSENCIA";
        case "Amedrontado": return "AMEDRONTADO";
        case "Assombrado": return "ASSOMBRADO";
        case "FuriaDraconica": return "FURIA DRACONICA";
        case "EscamaImperial": return "ESCAMA IMPERIAL";
        case "AscensaoDraconica": return "ASCENSAO";
        case "Predador": return "PREDADOR";
        case "EspinhosFerro": return "ESPINHOS";
        case "Fortificado": return "FORTIFICADO";
        case "BlindagemMagnetica": return "BLINDAGEM";
        case "ImpactoPesado": return "IMPACTO PESADO";
        case "LigaPesada": return "LIGA PESADA";
        case "GolpeBaixo": return "GOLPE BAIXO";
        case "JogoSujo": return "JOGO SUJO";
        case "CamuflagemSombria": return "CAMUFLAGEM";
        case "CopiaSombria": return "COPIA SOMBRIA";
        case "PerseguicaoSombria": return "PERSEGUICAO";
        case "MarcadoSombrio": return "MARCADO SOMBRIO";
        case "EncantoCarga": return "ENCANTO";
        case "LuzPurificadora": return "LUZ PURIFICADORA";
        case "AuraMistica": return "AURA MISTICA";
        case "BarreiraFada": return "BARREIRA FADA";
        case "BrilhoOfuscante": return "BRILHO";
        case "ForcaNeutra": return "FORCA NEUTRA";
        case "EstoqueDefensivo": return "ESTOQUE";
        case "LegadoAtivo": return "LEGADO";
        case "MimetismoAtivo": return "MIMETISMO";
        case "ReciclagemAtiva": return "RECICLAGEM";
        case "Cura": return "CURA";
        case "CuraMax": return "CURA MAX";
        case "ReduzCD": return "ACELERA CD";
        case "AumentaCD": return "ATRASA CD";
        case "CooldownAlvo": return "CD DO ALVO";
        case "Sacrificio": return "SACRIFICA HP";
        case "Execucao": return "EXECUCAO";
        case "HPBaixo": return "HP BAIXO";
    }

    return string_upper(_status);
}

function demo_status_cor(_status) {
    switch (_status) {
        case "Molhado": return make_color_rgb(58, 142, 238);
        case "FluxoAcelerado":
        case "MareAlta":
        case "NevoaEstagnante":
        case "ReduzCD":
        case "AumentaCD":
        case "CooldownAlvo": return make_color_rgb(64, 168, 226);
        case "Enraizado": return make_color_rgb(76, 168, 78);
        case "Fotossintese":
        case "Crescimento": return make_color_rgb(94, 184, 84);
        case "Queimando":
        case "Queimado":
        case "ArmaduraDerretida":
        case "CalorConcentrado":
        case "CalorEscaldante":
        case "FenixAtiva": return make_color_rgb(236, 94, 42);
        case "Preso": return make_color_rgb(92, 184, 96);
        case "Paralisado":
        case "Sobrecarregado":
        case "ErroEletrico":
        case "EstaticaAtiva": return make_color_rgb(226, 194, 56);
        case "Ofuscado": return make_color_rgb(250, 232, 118);
        case "Envenenado":
        case "Corroendo": return make_color_rgb(166, 88, 198);
        case "Gelado":
        case "Congelando":
        case "Fragil":
        case "Granizo":
        case "MantoGelo": return make_color_rgb(92, 196, 224);
        case "PosturaQuebrada":
        case "ImpetoOfensivo":
        case "EspiritoLuta": return make_color_rgb(198, 82, 56);
        case "Vulneravel": return make_color_rgb(220, 112, 86);
        case "BarreiraLama":
        case "Aterrado":
        case "AreiaMovedica":
        case "Desabando": return make_color_rgb(190, 146, 74);
        case "Turbulento":
        case "VentoCauda":
        case "VentoDeCauda":
        case "Evasivo":
        case "PenasLeves":
        case "MarcadoRasante": return make_color_rgb(130, 166, 226);
        case "EscudoCinetico":
        case "FocoPsiquico":
        case "DistorcaoEspacial":
        case "ParalisiaMental":
        case "AmnesiaInduzida": return make_color_rgb(224, 84, 150);
        case "CasuloRigido":
        case "SedaPresa":
        case "Infestado":
        case "EnxameAtivo":
        case "Metamorfose": return make_color_rgb(142, 184, 62);
        case "ToxinaAtiva": return make_color_rgb(150, 74, 176);
        case "Fragmentado":
        case "CascaRocha":
        case "ImpactoGeologico":
        case "FossilVivo": return make_color_rgb(166, 138, 82);
        case "TerrorCrescente":
        case "Intangivel":
        case "Maldito":
        case "EssenciaDrenada":
        case "Amedrontado":
        case "Assombrado": return make_color_rgb(122, 92, 170);
        case "FuriaDraconica":
        case "EscamaImperial":
        case "AscensaoDraconica":
        case "Predador": return make_color_rgb(116, 96, 226);
        case "EspinhosFerro":
        case "Fortificado":
        case "BlindagemMagnetica":
        case "ImpactoPesado":
        case "LigaPesada": return make_color_rgb(136, 158, 170);
        case "GolpeBaixo":
        case "JogoSujo":
        case "CamuflagemSombria":
        case "CopiaSombria":
        case "PerseguicaoSombria":
        case "MarcadoSombrio": return make_color_rgb(82, 70, 104);
        case "EncantoCarga":
        case "LuzPurificadora":
        case "AuraMistica":
        case "BarreiraFada":
        case "BrilhoOfuscante": return make_color_rgb(226, 128, 174);
        case "ForcaNeutra":
        case "EstoqueDefensivo":
        case "LegadoAtivo":
        case "MimetismoAtivo":
        case "ReciclagemAtiva": return make_color_rgb(160, 156, 118);
        case "Cura":
        case "CuraMax": return make_color_rgb(92, 184, 102);
        case "Sacrificio":
        case "HPBaixo": return make_color_rgb(198, 54, 72);
        case "Execucao": return make_color_rgb(236, 188, 70);
    }

    return make_color_rgb(94, 142, 220);
}

function demo_status_tooltip_texto(_status) {
    switch (_status) {
        case "Molhado": return "Molhado: fortalece combos de Agua e Eletrico. Alguns golpes de Terra tambem aproveitam.";
        case "Enraizado": return "Enraizado: prende o alvo e prepara combos de Grama, Inseto, Eletrico e Pedra.";
        case "Queimando":
        case "Queimado": return "Queimado: causa pressao de Fogo e conversa com golpes que reduzem Defesa ou Ataque.";
        case "Preso": return "Preso: o alvo fica vulneravel a combos de controle e impactos pesados.";
        case "Paralisado": return "Paralisado: atrasa a rotacao do alvo e ajuda golpes Eletricos a finalizarem.";
        case "Ofuscado": return "Ofuscado: pode fazer o alvo errar e ativa punicoes eletricas ou sombrias.";
        case "Envenenado": return "Envenenado: causa dano por tempo e alimenta combos de Veneno e Grama.";
        case "Corroendo": return "Corroendo: reduz a resistencia do alvo e melhora dano de atrito.";
        case "Fotossintese": return "Fotossintese: recupera e prepara golpes solares mais fortes.";
        case "Crescimento": return "Crescimento: aumenta pressao de critico e fortalece golpes de Grama.";
        case "ArmaduraDerretida": return "Armadura Derretida: reduz a defesa efetiva do alvo e abre finalizadores de Fogo.";
        case "CalorConcentrado": return "Calor Concentrado: prepara ataques explosivos de Fogo.";
        case "CalorEscaldante": return "Calor Escaldante: enfraquece o ataque do alvo e sustenta controle de Fogo.";
        case "FenixAtiva": return "Fenix: aumenta o dano de atacantes rapidos quando entram em risco.";
        case "NevoaEstagnante": return "Nevoa: atrasa cooldowns inimigos e fortalece controle de Agua.";
        case "FluxoAcelerado": return "Fluxo Acelerado: reduz seus cooldowns e melhora rotacoes rapidas de Agua.";
        case "MareAlta": return "Mare Alta: indica vantagem de ritmo para golpes de Agua.";
        case "Sobrecarregado": return "Sobrecarregado: acumula carga eletrica para explosoes e combos.";
        case "ErroEletrico": return "Erro Eletrico: marca falhas do alvo e ativa punicoes eletricas.";
        case "EstaticaAtiva": return "Estatica: acelera a rotacao do usuario e melhora golpes rapidos.";
        case "Gelado": return "Gelado: reduz ritmo e prepara efeitos de Gelo.";
        case "Congelando": return "Congelando: o alvo esta perto de travar e sofre mais finalizadores de Gelo.";
        case "Fragil": return "Fragil: alvo quebradico, recebe melhor dano de estilhacar.";
        case "Granizo": return "Granizo: pressao de arena que melhora controle de Gelo.";
        case "MantoGelo": return "Manto de Gelo: aumenta resistencia e transforma defesa em vantagem.";
        case "PosturaQuebrada": return "Postura Quebrada: reduz defesa efetiva e abre combos de Lutador.";
        case "ImpetoOfensivo": return "Impeto: aumenta pressao em sequencias de golpes de Lutador.";
        case "EspiritoLuta": return "Espirito de Luta: melhora sustentacao quando o usuario esta sob risco.";
        case "Vulneravel": return "Vulneravel: o alvo fica mais facil de punir por finalizadores.";
        case "BarreiraLama": return "Barreira de Lama: aumenta resistencia e sustenta rotas longas.";
        case "Aterrado": return "Aterrado: estabiliza o usuario e melhora golpes de Terra.";
        case "AreiaMovedica": return "Areia Movedica: atrasa a rotacao do alvo e conversa com controle.";
        case "Desabando": return "Desabando: marca impacto pesado e abre dano de Terra.";
        case "Turbulento": return "Turbulento: atrapalha ritmo inimigo e melhora golpes de Voador.";
        case "VentoCauda":
        case "VentoDeCauda": return "Vento de Cauda: acelera rotacoes e ajuda equipes rapidas.";
        case "Evasivo": return "Evasivo: aumenta a chance de evitar golpes e conversa com builds de Voador e Sombrio.";
        case "PenasLeves": return "Penas Leves: transforma mobilidade em velocidade e pressao rapida.";
        case "MarcadoRasante": return "Marcado Rasante: abre janela curta para dano explosivo Voador.";
        case "EscudoCinetico": return "Escudo Cinetico: converte controle mental em protecao.";
        case "FocoPsiquico": return "Foco Psiquico: melhora controle mental e dano de habilidades Psiquicas.";
        case "DistorcaoEspacial": return "Distorcao: enfraquece defesa/tempo do alvo para combos Psiquicos.";
        case "ParalisiaMental": return "Paralisia Mental: atrasa comandos sem desligar totalmente o inimigo.";
        case "AmnesiaInduzida": return "Amnesia: reduz a eficiencia da melhor acao inimiga por um tempo.";
        case "CasuloRigido": return "Casulo: aumenta resistencia e prepara contra-ataque de Inseto.";
        case "SedaPresa": return "Seda Presa: atrasa cooldowns e prende o alvo para combos.";
        case "Infestado": return "Infestado: pressao de Inseto que conversa com Veneno e Grama.";
        case "EnxameAtivo": return "Enxame: melhora golpes pequenos e rapidos.";
        case "Metamorfose": return "Metamorfose: converte tempo de luta em crescimento defensivo/ofensivo.";
        case "ToxinaAtiva": return "Toxina: sacrifica seguranca para aumentar dano e drenos de Veneno.";
        case "Fragmentado": return "Fragmentado: rachaduras de Pedra aumentam punicoes e impactos.";
        case "CascaRocha": return "Casca de Rocha: aumenta resistencia, mas favorece lutas lentas.";
        case "ImpactoGeologico": return "Impacto Geologico: sacrifica seguranca para dano verdadeiro.";
        case "FossilVivo": return "Fossil Vivo: ajuda a sobreviver a golpes fatais.";
        case "TerrorCrescente": return "Terror: cresce quanto mais a luta dura.";
        case "Intangivel": return "Intangivel: cria janelas curtas de evasao total.";
        case "Maldito": return "Maldito: vincula o alvo e melhora drenos/retornos de dano.";
        case "EssenciaDrenada": return "Essencia: rouba energia do alvo para sustentar o usuario.";
        case "Amedrontado": return "Amedrontado: alvo fora de ritmo, vulneravel a Fantasma e Dragao.";
        case "Assombrado": return "Assombrado: dano fantasma cresce conforme a luta se prolonga.";
        case "FuriaDraconica": return "Furia Draconica: dano aumenta quando o usuario esta ferido.";
        case "EscamaImperial": return "Escama Imperial: protege contra debuffs e reforca dano draconico.";
        case "AscensaoDraconica": return "Ascensao: melhora ciclos longos e golpes ancestrais.";
        case "Predador": return "Predador: pune alvos quando o usuario esta em vantagem.";
        case "EspinhosFerro": return "Espinhos: devolve parte do dano recebido.";
        case "Fortificado": return "Fortificado: empilha defesa e estabiliza lutas longas.";
        case "BlindagemMagnetica": return "Blindagem: campo metalico que protege e prepara golpes de Aco.";
        case "ImpactoPesado": return "Impacto Pesado: transforma Defesa/Peso em dano.";
        case "LigaPesada": return "Liga Pesada: reduz picos de dano e favorece tanques.";
        case "GolpeBaixo": return "Golpe Baixo: pune inimigos carregando habilidades.";
        case "JogoSujo": return "Jogo Sujo: transforma debuffs do alvo em dano sombrio.";
        case "CamuflagemSombria": return "Camuflagem: aumenta evasao contra alvos debilitados.";
        case "CopiaSombria": return "Copia Sombria: ilusao que pode absorver impacto.";
        case "PerseguicaoSombria": return "Perseguicao: pune alvos evasivos ou deslocados.";
        case "MarcadoSombrio": return "Marcado Sombrio: alvo preparado para punicoes sombrias.";
        case "EncantoCarga": return "Encanto: carrega energia para o proximo golpe de Fada.";
        case "LuzPurificadora": return "Luz Purificadora: limpa debuffs leves e sustenta o usuario.";
        case "AuraMistica": return "Aura Mistica: melhora dano/protecao elemental da equipe.";
        case "BarreiraFada": return "Barreira Fada: reduz dano continuo e segura atrito.";
        case "BrilhoOfuscante": return "Brilho: reduz dano inimigo e prepara combos de Fada.";
        case "ForcaNeutra": return "Forca Neutra: dano estavel e pouco dependente de setup.";
        case "EstoqueDefensivo": return "Estoque: acumula defesa para liberar em dano depois.";
        case "LegadoAtivo": return "Legado: prepara vantagem para continuidade da equipe.";
        case "MimetismoAtivo": return "Mimetismo: adapta resistencia ao que sofreu recentemente.";
        case "ReciclagemAtiva": return "Reciclagem: chance de reaproveitar recursos ou ritmo.";
        case "Cura": return "Cura: recupera parte do HP com base no dano causado.";
        case "CuraMax": return "Cura Max: recupera uma fracao do HP maximo.";
        case "ReduzCD": return "Acelera CD: reduz cooldowns do usuario para girar habilidades mais rapido.";
        case "AumentaCD": return "Atrasa CD: aumenta cooldowns do alvo e quebra o ritmo dele.";
        case "CooldownAlvo": return "CD do Alvo: causa mais dano se o inimigo estiver carregando golpes.";
        case "Sacrificio": return "Sacrificio: consome HP do usuario para ganhar impacto.";
        case "Execucao": return "Execucao: finaliza melhor alvos com HP baixo.";
        case "HPBaixo": return "HP Baixo: fica mais forte quando o usuario esta ferido.";
    }

    return _status + ": efeito de combo usado por habilidades especificas.";
}

function demo_draw_status_term(_status, _x, _y, _mx, _my) {
    var _label = demo_status_nome_visual(_status);
    battle_ui_font_title();
    var _w = string_width(_label);
    var _h = 18;
    var _hover = demo_hover_rect(_mx, _my, _x - 2, _y - 2, _w + 4, _h + 4);

    draw_set_color(demo_status_cor(_status));
    draw_text(_x, _y, _label);
    draw_line_width(_x, _y + 18, _x + _w, _y + 18, 1);

    if (_hover) {
        return {
            Texto: demo_status_tooltip_texto(_status),
            X: _x + (_w * 0.5),
            Y: _y - 12
        };
    }

    return undefined;
}

function demo_effect_token_from_prefix(_efeito, _prefix) {
    if (!is_string(_efeito) || string_pos(_prefix, _efeito) != 1) {
        return "";
    }

    var _resto = string_delete(_efeito, 1, string_length(_prefix));
    var _sep = string_pos(":", _resto);
    return _sep > 0 ? string_copy(_resto, 1, _sep - 1) : _resto;
}

function demo_effect_add_unique(_effects, _status, _role) {
    if (!is_array(_effects) || _status == "") {
        return _effects;
    }

    for (var _i = 0; _i < array_length(_effects); _i += 1) {
        var _effect = _effects[_i];

        if (is_struct(_effect) && _effect.Status == _status && _effect.Role == _role) {
            return _effects;
        }
    }

    array_push(_effects, { Status: _status, Role: _role });
    return _effects;
}

function demo_habilidade_efeitos_visuais(_skill) {
    var _effects = [];

    if (!is_struct(_skill)) {
        return _effects;
    }

    var _status = demo_effect_token_from_prefix(_skill.EfeitoEspecial, "aplicar_status:");

    if (_status != "") {
        _effects = demo_effect_add_unique(_effects, _status, "aplica");
    }

    if (is_string(_skill.ComboID) && _skill.ComboID != "") {
        _effects = demo_effect_add_unique(_effects, _skill.ComboID, "combo");
    }

    if (is_array(_skill.Efeitos)) {
        for (var _i = 0; _i < array_length(_skill.Efeitos); _i += 1) {
            var _efeito = _skill.Efeitos[_i];

            if (!is_string(_efeito)) {
                continue;
            }

            _status = demo_effect_token_from_prefix(_efeito, "aplicar_status_usuario:");
            if (_status != "") {
                _effects = demo_effect_add_unique(_effects, _status, "usuario");
                continue;
            }

            _status = demo_effect_token_from_prefix(_efeito, "aplicar_status:");
            if (_status != "") {
                _effects = demo_effect_add_unique(_effects, _status, "aplica");
                continue;
            }

            _status = demo_effect_token_from_prefix(_efeito, "bonus_dano_alvo_status:");
            if (_status != "") {
                _effects = demo_effect_add_unique(_effects, _status, "combo");
                continue;
            }

            _status = demo_effect_token_from_prefix(_efeito, "bonus_dano_usuario_status:");
            if (_status != "") {
                _effects = demo_effect_add_unique(_effects, _status, "escala");
                continue;
            }

            _status = demo_effect_token_from_prefix(_efeito, "curar_dano_status:");
            if (_status != "") {
                _effects = demo_effect_add_unique(_effects, _status, "drena");
                continue;
            }

            if (string_pos("curar_dano:", _efeito) == 1) {
                _effects = demo_effect_add_unique(_effects, "Cura", "cura");
                continue;
            }

            if (string_pos("curar_maxhp:", _efeito) == 1) {
                _effects = demo_effect_add_unique(_effects, "CuraMax", "cura");
                continue;
            }

            if (string_pos("reduzir_cooldowns_usuario:", _efeito) == 1) {
                _effects = demo_effect_add_unique(_effects, "ReduzCD", "tempo");
                continue;
            }

            if (string_pos("aumentar_cooldowns_alvo:", _efeito) == 1) {
                _effects = demo_effect_add_unique(_effects, "AumentaCD", "tempo");
                continue;
            }

            if (string_pos("bonus_dano_alvo_cd:", _efeito) == 1) {
                _effects = demo_effect_add_unique(_effects, "CooldownAlvo", "combo");
                continue;
            }

            if (string_pos("sacrificar_hp_pct:", _efeito) == 1 || string_pos("bonus_dano_sacrificio:", _efeito) == 1) {
                _effects = demo_effect_add_unique(_effects, "Sacrificio", "risco");
                continue;
            }

            if (string_pos("bonus_dano_alvo_hp_baixo:", _efeito) == 1) {
                _effects = demo_effect_add_unique(_effects, "Execucao", "combo");
                continue;
            }

            if (string_pos("bonus_dano_usuario_hp_baixo:", _efeito) == 1) {
                _effects = demo_effect_add_unique(_effects, "HPBaixo", "escala");
                continue;
            }
        }
    }

    return _effects;
}

function demo_habilidade_status_principal(_skill) {
    var _effects = demo_habilidade_efeitos_visuais(_skill);
    return array_length(_effects) > 0 ? _effects[0].Status : "";
}

function demo_effect_role_prefix(_role) {
    switch (_role) {
        case "aplica": return "Aplica ";
        case "usuario": return "Ganha ";
        case "combo": return "Combo ";
        case "escala": return "Escala ";
        case "drena": return "Drena com ";
        case "cura": return "";
        case "tempo": return "";
        case "risco": return "";
    }

    return "";
}

function demo_effect_role_suffix(_role) {
    switch (_role) {
        case "combo": return " no alvo";
        case "escala": return " ativo";
    }

    return "";
}

function demo_effect_phrase_parts(_effect) {
    if (!is_struct(_effect)) {
        return { Prefix: "", Suffix: "" };
    }

    var _role = _effect.Role;
    var _status = _effect.Status;

    if (_role == "cura") {
        if (_status == "CuraMax") {
            return { Prefix: "Recupera ", Suffix: " pelo HP max." };
        }

        return { Prefix: "Absorve vida e ", Suffix: " HP." };
    }

    if (_role == "aplica") {
        if (_status == "Molhado") return { Prefix: "Deixa o alvo ", Suffix: " para combos." };
        if (_status == "Queimando" || _status == "Queimado") return { Prefix: "Marca o alvo com ", Suffix: "." };
        if (_status == "Envenenado") return { Prefix: "Aplica ", Suffix: " e dano por tempo." };
        if (_status == "Enraizado" || _status == "Preso" || _status == "SedaPresa") return { Prefix: "Prende o alvo com ", Suffix: "." };
        return { Prefix: "Aplica ", Suffix: " no alvo." };
    }

    if (_role == "usuario") {
        return { Prefix: "Ativa ", Suffix: " no usuario." };
    }

    if (_role == "combo") {
        if (_status == "CooldownAlvo") return { Prefix: "Pune ", Suffix: " alto." };
        return { Prefix: "Ganha bonus contra ", Suffix: "." };
    }

    if (_role == "escala") {
        return { Prefix: "Ganha dano com ", Suffix: " ativo." };
    }

    if (_role == "drena") {
        return { Prefix: "Drena melhor de alvo com ", Suffix: "." };
    }

    if (_role == "tempo") {
        if (_status == "ReduzCD") return { Prefix: "Acelera o proprio ", Suffix: "." };
        if (_status == "AumentaCD") return { Prefix: "Atrasa o ", Suffix: " do alvo." };
    }

    if (_role == "risco") {
        return { Prefix: "Troca seguranca por ", Suffix: "." };
    }

    return { Prefix: demo_effect_role_prefix(_role), Suffix: demo_effect_role_suffix(_role) };
}

function demo_draw_effect_line(_effect, _x, _y, _mx, _my) {
    if (!is_struct(_effect)) {
        return undefined;
    }

    var _max_w = argument_count >= 6 ? argument[5] : 9999;
    var _parts = demo_effect_phrase_parts(_effect);
    var _prefix = _parts.Prefix;
    battle_ui_font_body();
    draw_set_color(make_color_rgb(50, 36, 34));
    draw_text(_x, _y, _prefix);

    var _term_label = demo_status_nome_visual(_effect.Status);
    var _term_x = _x + string_width(_prefix);
    var _term_y = _y;

    if (_prefix != "" && (string_width(_prefix) + string_width(_term_label)) > _max_w) {
        _term_x = _x;
        _term_y = _y + 22;
    }

    var _tooltip = demo_draw_status_term(_effect.Status, _term_x, _term_y, _mx, _my);
    var _suffix = _parts.Suffix;
    var _suffix_x = _term_x + string_width(_term_label) + 8;
    battle_ui_font_body();

    if (_suffix != "" && (_suffix_x + string_width(_suffix) - _x) <= _max_w) {
        draw_set_color(make_color_rgb(50, 36, 34));
        draw_text(_suffix_x, _term_y, _suffix);
    } else if (_suffix != "") {
        draw_set_color(make_color_rgb(50, 36, 34));
        draw_text_ext(_x, _term_y + 22, _suffix, 22, _max_w);
    }

    battle_ui_font_title();
    return _tooltip;
}

function demo_draw_habilidade_descricao_rica(_skill, _x, _y, _w, _mx, _my) {
    if (!is_struct(_skill)) {
        return undefined;
    }

    var _tooltip = undefined;
    var _max_lines = argument_count >= 7 ? argument[6] : 2;
    var _effects = demo_habilidade_efeitos_visuais(_skill);
    battle_ui_font_body();
    draw_set_color(make_color_rgb(50, 36, 34));

    if (array_length(_effects) > 0) {
        var _line_count = min(_max_lines, array_length(_effects));
        var _effect_gap = 52;

        for (var _i = 0; _i < _line_count; _i += 1) {
            var _line_tooltip = demo_draw_effect_line(_effects[_i], _x, _y + (_i * _effect_gap), _mx, _my, _w);

            if (is_struct(_line_tooltip)) {
                _tooltip = _line_tooltip;
            }
        }

        if (array_length(_effects) > _max_lines && _max_lines > 1) {
            battle_ui_font_body();
            draw_set_color(make_color_rgb(90, 72, 64));
            draw_text(_x, _y + (_line_count * _effect_gap), "+" + string(array_length(_effects) - _max_lines) + " efeito");
        }

        battle_ui_font_title();
        return _tooltip;
    }

    var _desc = habilidade_descricao_curta(_skill);
    battle_ui_font_body();
    draw_text_ext(_x, _y, _desc, 22, _w);
    battle_ui_font_title();
    return undefined;
}

function demo_draw_status_tooltip(_tooltip) {
    if (!is_struct(_tooltip)) {
        return;
    }

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _max_w = min(300, _gw - 36);
    var _texto = _tooltip.Texto;
    var _split = string_pos(": ", _texto);
    var _title = _split > 0 ? string_copy(_texto, 1, _split) : "";
    var _body = _split > 0 ? string_delete(_texto, 1, _split + 1) : _texto;
    battle_ui_font_title();
    var _title_w = _title != "" ? string_width(_title) : 0;
    battle_ui_font_body();
    var _body_w = string_width(_body);
    var _tw = min(_max_w, max(210, max(_title_w, _body_w) + 34));
    var _inner_w = _tw - 32;
    var _title_h = _title != "" ? 22 : 0;
    var _body_h = string_height_ext(_body, 22, _inner_w);
    var _th = clamp(_title_h + _body_h + 28, 56, 148);
    var _tx = clamp(_tooltip.X - (_tw * 0.5), 18, _gw - _tw - 18);
    var _ty = _tooltip.Y - _th - 8;

    if (_ty < 18) {
        _ty = _tooltip.Y + 22;
    }

    _ty = clamp(_ty, 18, _gh - _th - 18);

    battle_ui_draw_nineslice_panel(_tx, _ty, _tw, _th);
    draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(36, 30, 28) : c_white);
    if (_title != "") {
        battle_ui_font_title();
        draw_text(_tx + 16, _ty + 12, _title);
    }
    battle_ui_font_body();
    draw_text_ext(_tx + 16, _ty + 12 + _title_h, _body, 22, _inner_w);
    battle_ui_font_title();
}

function demo_hover_rect(_mx, _my, _x, _y, _w, _h) {
    return _mx >= _x && _mx <= _x + _w && _my >= _y && _my <= _y + _h;
}

function demo_hover_grow_rect(_x, _y, _w, _h, _hover, _amount) {
    var _grow = _hover ? _amount : 0;
    return {
        X: _x - _grow,
        Y: _y - _grow,
        W: _w + (_grow * 2),
        H: _h + (_grow * 2)
    };
}

function demo_pallet_map_rect(_view_w, _view_h) {
    var _src_w = 768;
    var _src_h = 413;
    var _scale = max(_view_w / _src_w, _view_h / _src_h);
    var _w = _src_w * _scale;
    var _h = _src_h * _scale;

    return {
        X: (_view_w - _w) * 0.5,
        Y: (_view_h - _h) * 0.5,
        W: _w,
        H: _h,
        Scale: _scale
    };
}

function demo_city_map_rect(_sprite, _view_w, _view_h) {
    var _city_index = argument_count >= 4 ? argument[3] : -1;
    var _src_w = sprite_exists(_sprite) ? sprite_get_width(_sprite) : 768;
    var _src_h = sprite_exists(_sprite) ? sprite_get_height(_sprite) : 413;
    var _cover = (_city_index == 1 || _city_index == 6);
    var _scale = _cover ? max(_view_w / _src_w, _view_h / _src_h) : min(_view_w / _src_w, _view_h / _src_h);

    if (_cover) {
        _scale *= 1.06;
    }

    var _w = _src_w * _scale;
    var _h = _src_h * _scale;
    var _x = (_view_w - _w) * 0.5;
    var _y = (_view_h - _h) * 0.5;

    if (_city_index == 1 || _city_index == 6) {
        _x -= _w * 0.018;
        _y -= _h * 0.014;
    }

    return {
        X: _x,
        Y: _y,
        W: _w,
        H: _h,
        Scale: _scale
    };
}

function demo_city_sprite_get(_controller, _city_index) {
    if (!instance_exists(_controller)) {
        return -1;
    }

    if (!variable_instance_exists(_controller, "city_sprites") || !is_array(_controller.city_sprites)) {
        return -1;
    }

    if (_city_index < 0 || _city_index >= array_length(_controller.city_sprites)) {
        return -1;
    }

    var _sprite = _controller.city_sprites[_city_index];

    if (sprite_exists(_sprite)) {
        return _sprite;
    }

    var _cidade = _city_index < array_length(_controller.kanto_cidades) ? _controller.kanto_cidades[_city_index] : undefined;

    if (is_struct(_cidade) && _cidade.SpriteCidade != "") {
        _sprite = demo_asset_sprite("datafiles/sprites/cidades/" + _cidade.SpriteCidade);
    }

    if (!sprite_exists(_sprite)) {
        _sprite = placeholder_cidade_sprite(_city_index, is_struct(_cidade) ? _cidade.Nome : "");
    }

    _controller.city_sprites[_city_index] = _sprite;
    return _sprite;
}

function demo_pallet_marker_pos(_nx, _ny, _view_w, _view_h) {
    var _rect = demo_pallet_map_rect(_view_w, _view_h);

    return {
        X: _rect.X + (_nx * _rect.W),
        Y: _rect.Y + (_ny * _rect.H)
    };
}

function DemoCityMarker(_symbol, _label, _action, _nx, _ny) constructor {
    Symbol = _symbol;
    Label = _label;
    Action = _action;
    NX = _nx;
    NY = _ny;
    TargetIndex = argument_count >= 6 ? argument[5] : -1;
}

function demo_city_marker_pos(_controller, _marker, _view_w, _view_h) {
    var _city_idx = 0;

    if (instance_exists(_controller) && variable_instance_exists(_controller, "cidade_index")) {
        _city_idx = variable_instance_get(_controller, "cidade_index");
    }

    var _sprite = demo_city_sprite_get(_controller, _city_idx);
    var _rect = demo_city_map_rect(_sprite, _view_w, _view_h, _city_idx);

    return {
        X: _rect.X + (_marker.NX * _rect.W),
        Y: _rect.Y + (_marker.NY * _rect.H)
    };
}

function demo_city_event_seen(_controller, _city_index) {
    if (!instance_exists(_controller) || !variable_instance_exists(_controller, "cidade_eventos_vistos")) {
        return false;
    }

    var _seen = variable_instance_get(_controller, "cidade_eventos_vistos");

    if (!is_array(_seen) || _city_index < 0 || _city_index >= array_length(_seen)) {
        return false;
    }

    return _seen[_city_index];
}

function demo_city_markers(_controller) {
    if (!instance_exists(_controller)) {
        return [];
    }

    var _city = variable_instance_exists(_controller, "cidade_index") ? variable_instance_get(_controller, "cidade_index") : 0;
    var _markers = [];
    var _next_label = "Sair da cidade";
    var _back_label = "Voltar";
    var _max_city = _city;

    if (variable_instance_exists(_controller, "kanto_cidades")) {
        var _cities = variable_instance_get(_controller, "kanto_cidades");

        if (is_array(_cities)) {
            _max_city = max(0, array_length(_cities) - 1);

            if (_city < array_length(_cities) - 1) {
                _next_label = "Ir para " + _cities[_city + 1].Nome;
            }

            if (_city > 0) {
                _back_label = "Voltar para " + _cities[_city - 1].Nome;
            }
        }
    }

    var _next_target = min(_city + 1, _max_city);
    var _back_target = max(_city - 1, 0);

    switch (_city) {
        case 0:
            array_push(_markers, new DemoCityMarker(variable_instance_get(_controller, "mae_presente_entregue") ? "!" : "?", "Casa da Mae", "mom", 0.265, 0.205));
            array_push(_markers, new DemoCityMarker("$", "PokeMart", "mart", 0.480, 0.205));
            array_push(_markers, new DemoCityMarker(variable_instance_get(_controller, "professor_carvalho_visto") ? "!" : "?", "Prof. Sabia", "lab", 0.715, 0.195));
            array_push(_markers, new DemoCityMarker("^", _next_label, "leave", 0.405, 0.075, _next_target));
            break;

        case 1:
            array_push(_markers, new DemoCityMarker("+", "Centro de Cura", "center", 0.385, 0.590));
            array_push(_markers, new DemoCityMarker("$", "PokeMart", "mart", 0.599, 0.395));
            array_push(_markers, new DemoCityMarker("G", "Ginasio trancado", "gym", 0.519, 0.205));
            array_push(_markers, new DemoCityMarker(demo_city_event_seen(_controller, _city) ? "!" : "?", "Cidadao", "event", 0.395, 0.447));
            array_push(_markers, new DemoCityMarker("<", _back_label, "leave", 0.121, 0.503, _back_target));
            array_push(_markers, new DemoCityMarker("v", _next_label, "leave", 0.400, 0.882, _next_target));
            break;

        case 2:
            array_push(_markers, new DemoCityMarker("+", "Centro de Cura", "center", 0.305, 0.585));
            array_push(_markers, new DemoCityMarker("$", "PokeMart", "mart", 0.632, 0.490));
            array_push(_markers, new DemoCityMarker("G", "Ginasio Tito Basalto", "gym", 0.375, 0.360));
            array_push(_markers, new DemoCityMarker(demo_city_event_seen(_controller, _city) ? "!" : "?", "Museu de Pedralia", "event", 0.390, 0.125));
            array_push(_markers, new DemoCityMarker(demo_city_event_seen(_controller, _city) ? "!" : "?", "Morador", "event", 0.840, 0.670));
            array_push(_markers, new DemoCityMarker(">", _next_label, "leave", 0.970, 0.635, _next_target));
            array_push(_markers, new DemoCityMarker("<", _back_label, "leave", 0.505, 0.970, _back_target));
            break;

        case 3:
            array_push(_markers, new DemoCityMarker("+", "Centro de Cura", "center", 0.405, 0.090));
            array_push(_markers, new DemoCityMarker("$", "PokeMart", "mart", 0.548, 0.478));
            array_push(_markers, new DemoCityMarker("G", "Ginasio Ondina", "gym", 0.148, 0.615));
            array_push(_markers, new DemoCityMarker(demo_city_event_seen(_controller, _city) ? "!" : "?", "Ponte das Gaivotas", "event", 0.855, 0.325));
            array_push(_markers, new DemoCityMarker(demo_city_event_seen(_controller, _city) ? "!" : "?", "Casa suspeita", "event", 0.805, 0.530));
            array_push(_markers, new DemoCityMarker(">", _next_label, "leave", 0.500, 0.965, _next_target));
            array_push(_markers, new DemoCityMarker("^", _back_label, "leave", 0.486, 0.055, _back_target));
            break;

        case 4:
            array_push(_markers, new DemoCityMarker("+", "Centro de Cura", "center", 0.372, 0.315));
            array_push(_markers, new DemoCityMarker("$", "PokeMart", "mart", 0.287, 0.285));
            array_push(_markers, new DemoCityMarker("G", "Ginasio Capita Raia", "gym", 0.303, 0.570));
            array_push(_markers, new DemoCityMarker(demo_city_event_seen(_controller, _city) ? "!" : "?", "Porto Cargueiro Aurora", "event", 0.150, 0.075));
            array_push(_markers, new DemoCityMarker(">", _next_label, "leave", 0.363, 0.970, _next_target));
            array_push(_markers, new DemoCityMarker("<", _back_label, "leave", 0.050, 0.470, _back_target));
            break;

        case 5:
            array_push(_markers, new DemoCityMarker("+", "Centro de Cura", "center", 0.338, 0.580));
            array_push(_markers, new DemoCityMarker("$", "PokeMart", "mart", 0.618, 0.460));
            array_push(_markers, new DemoCityMarker("G", "Ginasio Dr. Calidus", "gym", 0.496, 0.115));
            array_push(_markers, new DemoCityMarker(demo_city_event_seen(_controller, _city) ? "!" : "?", "Laboratorio", "event", 0.254, 0.164));
            array_push(_markers, new DemoCityMarker(demo_city_event_seen(_controller, _city) ? "!" : "?", "Pesquisador", "event", 0.674, 0.648));
            array_push(_markers, new DemoCityMarker(">", _next_label, "leave", 0.398, 0.985, _next_target));
            array_push(_markers, new DemoCityMarker("<", _back_label, "leave", 0.030, 0.486, _back_target));
            break;

        default:
            array_push(_markers, new DemoCityMarker("+", "Centro de Cura", "center", 0.388, 0.568));
            array_push(_markers, new DemoCityMarker("$", "PokeMart", "mart", 0.597, 0.392));
            array_push(_markers, new DemoCityMarker("G", "Ginasio Vesper", "gym", 0.519, 0.205));
            array_push(_markers, new DemoCityMarker(demo_city_event_seen(_controller, _city) ? "!" : "?", "Base Eclipse", "event", 0.395, 0.447));
            array_push(_markers, new DemoCityMarker("<", _back_label, "leave", 0.121, 0.503, _back_target));
            break;
    }

    return _markers;
}

function demo_city_marker_ativar(_controller, _marker) {
    if (!instance_exists(_controller) || !is_struct(_marker)) {
        return;
    }

    with (_controller) {
        switch (_marker.Action) {
            case "mom":
                estado_demo = DemoEstado.CASA_MAE;

                if (!mae_presente_entregue) {
                    dinheiro += 100 + demo_meta_dinheiro_inicial_bonus(meta_progresso);
                    mae_presente_entregue = true;
                    message = demo_dialogo_mae_inicial();
                } else {
                    message = demo_dialogo_mae_retorno();
                }
                break;

            case "mart":
                estado_demo = DemoEstado.POKESTORE;
                message = "Bem-vindo ao Mercado de " + demo_cidade_nome(cidade_index) + ".";
                break;

            case "lab":
                estado_demo = DemoEstado.LAB_CARVALHO;
                professor_carvalho_visto = true;
                message = demo_dialogo_professor_carvalho();
                break;

            case "center":
                demo_pokemon_curar_ativo(id);
                message = "Equipe curada.";
                break;

            case "gym":
                if (!demo_cidade_tem_ginasio(cidade_index)) {
                    estado_demo = DemoEstado.GINASIO;
                    message = demo_cidade_nome(cidade_index) + " ainda nao tem lider ativo. A primeira trava esta em Pedralia.";
                } else if (demo_cidade_ginasio_vencido(cidade_index)) {
                    estado_demo = DemoEstado.GINASIO;
                    message = demo_cidade_atual().Lider + " ja foi derrotado. A proxima rota esta liberada.";
                } else {
                    var _gym_enemy_id = demo_gym_enemy_id(cidade_index);
                    var _escopo_lider = diario_escopo("lider:" + string(cidade_index));
                    enemy_pokemon_data = demo_criar_pokemon_data(_gym_enemy_id, demo_gym_enemy_level(cidade_index), true, false, true, "ginasio");
                    diario_escopo_fim(_escopo_lider);
                    battle_context = "ginasio";
                    gym_battle_city_index = cidade_index;
                    demo_start_battle(id);
                }
                break;

            case "event":
                estado_demo = DemoEstado.CASA_MAE;

                if (variable_instance_exists(id, "cidade_eventos_vistos") && is_array(cidade_eventos_vistos) && cidade_index >= 0 && cidade_index < array_length(cidade_eventos_vistos)) {
                    cidade_eventos_vistos[cidade_index] = true;
                }

                message = demo_cidade_atual().Evento + ": moradores relatam que as rotas mudaram durante a noite. Algumas ficaram curtas, outras parecem nunca acabar.";
                break;

            case "leave":
                var _target_index = variable_struct_exists(_marker, "TargetIndex") ? _marker.TargetIndex : -1;

                if (_target_index < 0) {
                    _target_index = (_marker.Symbol == "<" || _marker.Symbol == "^") ? max(0, cidade_index - 1) : min(array_length(kanto_cidades) - 1, cidade_index + 1);
                }

                saida_destino_index = clamp(_target_index, 0, array_length(kanto_cidades) - 1);
                estado_demo = DemoEstado.SAIR_CIDADE;
                message = saida_destino_index < cidade_index ? "Escolha a rota para voltar a " + demo_cidade_nome(saida_destino_index) + "." : "Escolha a rota para " + demo_cidade_nome(saida_destino_index) + ".";
                break;
        }
    }
}

function demo_city_marker_hit(_mx, _my, _x, _y) {
    return point_distance(_mx, _my, _x, _y) <= 30;
}

function demo_draw_city_marker(_symbol, _label, _x, _y, _hover) {
    var _text = _hover ? _label : _symbol;
    var _pad_x = _hover ? 14 : 0;
    var _w = max(34, string_width(_text) + (_pad_x * 2));
    var _h = 34;

    draw_set_alpha(_hover ? 0.34 : 0.22);
    draw_set_color(c_black);
    draw_ellipse(_x - (_w * 0.5), _y - 10, _x + (_w * 0.5), _y + 18, false);
    draw_set_alpha(1);

    draw_set_color(_hover ? make_color_rgb(255, 232, 88) : make_color_rgb(242, 235, 208));
    draw_rectangle(_x - (_w * 0.5), _y - _h, _x + (_w * 0.5), _y, false);
    draw_set_color(make_color_rgb(88, 64, 48));
    draw_rectangle(_x - (_w * 0.5), _y - _h, _x + (_w * 0.5), _y, true);
    draw_rectangle(_x - (_w * 0.5) + 3, _y - _h + 3, _x + (_w * 0.5) - 3, _y - 3, true);
    draw_set_color(make_color_rgb(36, 30, 28));
    draw_text(_x - (string_width(_text) * 0.5), _y - 25, _text);
}

function demo_draw_choice_button(_label, _subtitle, _x, _y, _w, _h, _hover) {
    var _draw_rect = demo_hover_grow_rect(_x, _y, _w, _h, _hover, 3);
    var _dx = _draw_rect.X;
    var _dy = _draw_rect.Y;
    var _dw = _draw_rect.W;
    var _dh = _draw_rect.H;

    if (_hover) {
        draw_set_alpha(0.24);
        draw_set_color(make_color_rgb(255, 232, 88));
        draw_rectangle(_dx - 6, _dy - 6, _dx + _dw + 6, _dy + _dh + 6, false);
        draw_set_alpha(1);
    }

    draw_set_color(make_color_rgb(242, 235, 208));
    draw_rectangle(_dx, _dy, _dx + _dw, _dy + _dh, false);
    draw_set_color(_hover ? make_color_rgb(255, 232, 88) : make_color_rgb(108, 82, 68));
    draw_rectangle(_dx, _dy, _dx + _dw, _dy + _dh, true);
    draw_rectangle(_dx + 3, _dy + 3, _dx + _dw - 3, _dy + _dh - 3, true);
    draw_set_color(make_color_rgb(196, 46, 54));
    draw_rectangle(_dx, _dy, _dx + 12, _dy + _dh, false);
    draw_set_color(make_color_rgb(36, 30, 28));

    if (_subtitle == "") {
        draw_set_valign(fa_middle);
        draw_text(_dx + 28, _dy + (_dh * 0.5), _label);
        draw_set_valign(fa_top);
    } else {
        draw_text(_dx + 28, _dy + 12, _label);
        draw_set_color(make_color_rgb(86, 68, 58));
        draw_text_ext(_dx + 28, _dy + 38, _subtitle, 16, _dw - 56);
    }
}

function demo_draw_route_choice_button(_rota, _label_prefix, _x, _y, _w, _h, _hover, _enabled) {
    var _alpha = _enabled ? 1 : 0.48;
    var _draw_rect = demo_hover_grow_rect(_x, _y, _w, _h, _hover && _enabled, 3);
    var _dx = _draw_rect.X;
    var _dy = _draw_rect.Y;
    var _dw = _draw_rect.W;
    var _dh = _draw_rect.H;

    if (_hover && _enabled) {
        draw_set_alpha(0.24);
        draw_set_color(make_color_rgb(255, 232, 88));
        draw_rectangle(_dx - 6, _dy - 6, _dx + _dw + 6, _dy + _dh + 6, false);
        draw_set_alpha(1);
    }

    draw_set_alpha(_alpha);
    draw_set_color(_enabled ? make_color_rgb(196, 46, 54) : make_color_rgb(76, 72, 72));
    draw_rectangle(_dx, _dy, _dx + 12, _dy + _dh, false);
    draw_set_color((_hover && _enabled) ? make_color_rgb(255, 244, 152) : make_color_rgb(242, 235, 208));
    draw_rectangle(_dx + 12, _dy, _dx + _dw, _dy + _dh, false);
    draw_set_color((_hover && _enabled) ? make_color_rgb(220, 184, 42) : make_color_rgb(108, 82, 68));
    draw_rectangle(_dx + 12, _dy, _dx + _dw, _dy + _dh, true);
    draw_rectangle(_dx + 15, _dy + 3, _dx + _dw - 3, _dy + _dh - 3, true);

    draw_set_color(make_color_rgb(36, 30, 28));
    draw_text(_dx + 28, _dy + 14, _label_prefix + _rota.Nome);
    draw_set_color(make_color_rgb(72, 60, 54));
    draw_text(_dx + 28, _dy + 40, demo_rota_descricao_visual(_rota));
    draw_text_ext(_dx + 28, _dy + 64, "Biomas: " + demo_rota_biomas_texto(_rota), 14, _dw - 52);
    draw_text(_dx + 28, _dy + _dh - 28, demo_rota_encontros_range_texto(_rota));
    draw_set_alpha(1);
}

function demo_draw_money_badge(_x, _y, _valor) {
    draw_set_color(make_color_rgb(242, 235, 208));
    draw_rectangle(_x, _y, _x + 156, _y + 42, false);
    draw_set_color(make_color_rgb(108, 82, 68));
    draw_rectangle(_x, _y, _x + 156, _y + 42, true);
    draw_set_color(make_color_rgb(248, 228, 104));
    draw_circle(_x + 24, _y + 21, 12, false);
    draw_set_color(make_color_rgb(88, 64, 34));
    draw_text(_x + 15, _y + 13, "M$");
    draw_set_color(make_color_rgb(36, 30, 28));
    draw_text(_x + 48, _y + 13, string(_valor));
}

function ItemData(_id, _nome, _tipo, _valor_efeito, _preco, _descricao) constructor {
    ID = _id;
    Nome = _nome;
    Tipo = _tipo;
    ValorEfeito = _valor_efeito;
    Preco = _preco;
    Descricao = _descricao;
}

function demo_item_db_criar() {
    return {
        pokebola: new ItemData("pokebola", "Capsula Simples", "captura", 0.25, 20, "25% de chance base de captura."),
        great_ball: new ItemData("great_ball", "Capsula Reforcada", "captura", 0.50, 60, "50% de chance base de captura."),
        ultra_ball: new ItemData("ultra_ball", "Capsula Avancada", "captura", 0.75, 150, "75% de chance base de captura."),
        master_ball: new ItemData("master_ball", "Capsula Mestra", "captura", 1.00, 0, "Captura garantida. Recompensa rarissima."),
        potion: new ItemData("potion", "Pocao", "cura", 0.25, 30, "Cura 25% do HP maximo."),
        super_potion: new ItemData("super_potion", "Pocao Forte", "cura", 0.50, 80, "Cura 50% do HP maximo."),
        hyper_potion: new ItemData("hyper_potion", "Pocao Maxima", "cura", 0.75, 200, "Cura 75% do HP maximo."),
        full_restore: new ItemData("full_restore", "Elixir Total", "cura_status", 1.00, 400, "Cura todo HP e remove status."),
        antidote: new ItemData("antidote", "Antidoto", "status", 0, 15, "Remove Veneno."),
        burn_heal: new ItemData("burn_heal", "Pomada Fria", "status", 0, 20, "Remove Queimadura."),
        awakening: new ItemData("awakening", "Sal de Despertar", "status", 0, 20, "Remove Sono."),
        full_heal: new ItemData("full_heal", "Tonico Puro", "status", 0, 40, "Remove qualquer status."),
        oran_berry: new ItemData("oran_berry", "Fruta Anil", "berry", 0.25, 50, "Auto: cura 25% abaixo de 30% HP."),
        cheri_berry: new ItemData("cheri_berry", "Fruta Rubra", "berry", 0, 60, "Auto: cura Paralisia."),
        leppa_berry: new ItemData("leppa_berry", "Fruta Ambar", "cooldown", 0.50, 120, "Reduz cooldowns em 50% uma vez."),
        rare_candy: new ItemData("rare_candy", "Cristal de Nivel", "level", 1, 900, "Sobe 1 nivel do monstro ativo.")
    };
}

function demo_item_get(_id_item) {
    if (!variable_global_exists("item_db") || !is_struct(global.item_db)) {
        global.item_db = demo_item_db_criar();
    }

    if (variable_struct_exists(global.item_db, _id_item)) {
        return variable_struct_get(global.item_db, _id_item);
    }

    return undefined;
}

function demo_inventario_criar() {
    return {
        pokebola: 0,
        potion: 0,
        antidote: 0,
        great_ball: 0,
        ultra_ball: 0,
        master_ball: 0,
        super_potion: 0,
        hyper_potion: 0,
        full_restore: 0,
        burn_heal: 0,
        awakening: 0,
        full_heal: 0,
        oran_berry: 0,
        cheri_berry: 0,
        leppa_berry: 0,
        rare_candy: 0
    };
}

function demo_inventario_quantidade(_inventario, _id_item) {
    if (!is_struct(_inventario) || !variable_struct_exists(_inventario, _id_item)) {
        return 0;
    }

    return variable_struct_get(_inventario, _id_item);
}

function demo_inventario_adicionar(_inventario, _id_item, _qtd) {
    if (!is_struct(_inventario)) {
        return false;
    }

    var _atual = demo_inventario_quantidade(_inventario, _id_item);
    variable_struct_set(_inventario, _id_item, max(0, _atual + _qtd));
    return true;
}

function demo_shop_items_cidade(_cidade_index) {
    switch (_cidade_index) {
        case 0:
        case 1:
            return ["pokebola", "potion", "antidote"];
        case 2:
            return ["pokebola", "great_ball", "potion", "antidote", "burn_heal", "awakening"];
        case 3:
            return ["great_ball", "super_potion", "oran_berry", "full_heal"];
        case 4:
            return ["ultra_ball", "hyper_potion", "leppa_berry", "full_heal"];
        case 5:
        case 6:
            return ["ultra_ball", "hyper_potion", "full_restore", "leppa_berry", "rare_candy"];
    }

    return ["pokebola", "potion"];
}

function demo_item_ids_mochila() {
    return [
        "potion", "super_potion", "hyper_potion", "full_restore",
        "antidote", "burn_heal", "awakening", "full_heal",
        "rare_candy",
        "oran_berry", "cheri_berry", "leppa_berry",
        "pokebola", "great_ball", "ultra_ball", "master_ball"
    ];
}

function demo_item_ids_possuidos(_inventario) {
    var _todos = demo_item_ids_mochila();
    var _possuidos = [];

    for (var _i = 0; _i < array_length(_todos); _i += 1) {
        if (demo_inventario_quantidade(_inventario, _todos[_i]) > 0) {
            array_push(_possuidos, _todos[_i]);
        }
    }

    return _possuidos;
}

function demo_item_pode_usar(_item, _em_batalha) {
    if (!is_struct(_item)) {
        return false;
    }

    switch (_item.Tipo) {
        case "cura":
        case "cura_status":
        case "status":
            return true;
        case "cooldown":
            return _em_batalha;
        case "level":
            return !_em_batalha;
        case "berry":
            return false;
        case "captura":
            return _em_batalha;
    }

    return false;
}

function demo_party_garantir(_controller) {
    if (!instance_exists(_controller)) {
        return;
    }

    with (_controller) {
        if (!variable_instance_exists(id, "player_party") || !is_array(player_party)) {
            player_party = [];
        }

        if (array_length(player_party) <= 0 && is_struct(player_pokemon_data)) {
            player_party = [player_pokemon_data];
            player_party_active_index = 0;
        }
    }
}

function demo_party_adicionar(_controller, _pokemon) {
    if (!instance_exists(_controller) || !is_struct(_pokemon)) {
        return false;
    }

    demo_party_garantir(_controller);

    if (array_length(_controller.player_party) >= 4) {
        _controller.message = "Equipe cheia. Voce so pode carregar 4 monstros nesta run.";
        return false;
    }

    var _party = _controller.player_party;
    _pokemon.FoiCapturado = true;
    _pokemon.Capturado = true;
    array_push(_party, _pokemon);
    _controller.player_party = _party;
    pokedex_capturar(_pokemon.ID);
    _controller.message = _pokemon.Nome + " entrou para sua equipe!";
    return true;
}

function demo_capture_replace_abrir(_controller, _pokemon) {
    if (!instance_exists(_controller) || !is_struct(_pokemon)) {
        return false;
    }

    demo_party_garantir(_controller);
    _pokemon.FoiCapturado = true;
    _pokemon.Capturado = true;
    _controller.capture_replace_open = true;
    _controller.capture_replace_pokemon = _pokemon;
    _controller.message = "Equipe cheia. Escolha quem sera substituido por " + _pokemon.Nome + ".";
    pokedex_capturar(_pokemon.ID);
    return true;
}

function demo_capture_replace_confirmar(_controller, _party_index) {
    if (!instance_exists(_controller)) {
        return false;
    }

    demo_party_garantir(_controller);

    if (!variable_instance_exists(_controller, "capture_replace_open") || !_controller.capture_replace_open || !is_struct(_controller.capture_replace_pokemon)) {
        return false;
    }

    if (_party_index < 0 || _party_index >= array_length(_controller.player_party)) {
        return false;
    }

    var _novo = _controller.capture_replace_pokemon;
    var _antigo = _controller.player_party[_party_index];
    var _party = _controller.player_party;
    _party[_party_index] = _novo;
    _controller.player_party = _party;

    if (_controller.player_party_active_index == _party_index) {
        _controller.player_pokemon_data = _novo;

        if (instance_exists(_controller.player_inst)) {
            pokemon_batalha_injetar(_controller.player_inst, _novo);
            pokemon_batalha_definir_lado(_controller.player_inst, LadoBatalha.ALIADO);
        }
    }

    _controller.capture_replace_open = false;
    _controller.capture_replace_pokemon = undefined;
    _controller.message = _novo.Nome + " entrou no lugar de " + (is_struct(_antigo) ? _antigo.Nome : "um monstro") + ".";

    if (is_struct(_controller.battle_result_info)) {
        _controller.battle_result_info.Capturado = _novo;
        _controller.battle_result_info.Mensagem = _controller.message;
    }

    return true;
}

function demo_capture_replace_card_rect(_controller, _index) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _panel_w = min(_gw - 64, 1260);
    var _panel_h = min(_gh - 64, 640);
    var _panel_x = (_gw - _panel_w) * 0.5;
    var _panel_y = (_gh - _panel_h) * 0.5;
    var _gap = 14;
    var _card_count = 5;
    var _card_w = (_panel_w - 48 - (_gap * (_card_count - 1))) / _card_count;
    var _card_h = _panel_h - 158;
    var _card_y = _panel_y + 118;
    var _card_x = _panel_x + 24 + (_index * (_card_w + _gap));

    return {
        X: _card_x,
        Y: _card_y,
        W: _card_w,
        H: _card_h
    };
}

function demo_capture_replace_handle_click(_controller) {
    if (!instance_exists(_controller) || !variable_instance_exists(_controller, "capture_replace_open") || !_controller.capture_replace_open) {
        return false;
    }

    if (!mouse_check_button_pressed(mb_left)) {
        return true;
    }

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    demo_party_garantir(_controller);

    for (var _i = 0; _i < min(4, array_length(_controller.player_party)); _i += 1) {
        var _rect = demo_capture_replace_card_rect(_controller, _i);

        if (demo_hover_rect(_mx, _my, _rect.X, _rect.Y, _rect.W, _rect.H)) {
            demo_capture_replace_confirmar(_controller, _i);
            demo_party_curar_pos_batalha(_controller);
            battle_log_push("A equipe recuperou um pouco de HP.");
            return true;
        }
    }

    return true;
}

function demo_capture_replace_draw_skill(_skill, _x, _y, _w, _mx, _my) {
    if (!is_struct(_skill)) {
        draw_set_color(make_color_rgb(96, 82, 74));
        draw_text_transformed(_x, _y, "Vazio", 0.48, 0.48, 0);
        return undefined;
    }

    var _hover = demo_hover_rect(_mx, _my, _x - 4, _y - 3, _w + 8, 25);

    if (_hover) {
        draw_set_alpha(0.18);
        draw_set_color(make_color_rgb(255, 232, 88));
        draw_rectangle(_x - 6, _y - 4, _x + _w + 6, _y + 23, false);
        draw_set_alpha(1);
    }

    battle_ui_draw_type_icon(_skill.TipoElementar, _x, _y + 1, 0.46);
    draw_set_color(make_color_rgb(36, 30, 28));
    battle_ui_draw_text_fit(_x + 46, _y, _skill.Nome, _w - 48, 0.48, make_color_rgb(36, 30, 28));
    draw_set_color(make_color_rgb(74, 58, 52));
    draw_text_transformed(_x + 46, _y + 13, battle_ui_skill_damage_text(_skill) + "  CD " + string_format(_skill.TempoRecargaMax, 1, 1) + "s", 0.36, 0.36, 0);

    if (_hover) {
        return {
            X: _mx,
            Y: _my,
            Texto: habilidade_descricao_curta(_skill)
        };
    }

    return undefined;
}

function demo_draw_capture_replace_card(_pokemon, _rect, _label, _clickable, _mx, _my) {
    if (!is_struct(_pokemon)) {
        return undefined;
    }

    var _hover = _clickable && demo_hover_rect(_mx, _my, _rect.X, _rect.Y, _rect.W, _rect.H);
    var _tooltip = undefined;

    if (_hover) {
        draw_set_alpha(0.26);
        draw_set_color(make_color_rgb(255, 232, 88));
        draw_rectangle(_rect.X - 6, _rect.Y - 6, _rect.X + _rect.W + 6, _rect.Y + _rect.H + 6, false);
        draw_set_alpha(1);
    }

    draw_set_color(_label == "NOVO" ? make_color_rgb(216, 244, 216) : make_color_rgb(242, 235, 208));
    draw_rectangle(_rect.X, _rect.Y, _rect.X + _rect.W, _rect.Y + _rect.H, false);
    draw_set_color(_hover ? make_color_rgb(255, 232, 88) : make_color_rgb(188, 164, 92));
    draw_rectangle(_rect.X, _rect.Y, _rect.X + _rect.W, _rect.Y + _rect.H, true);
    draw_rectangle(_rect.X + 4, _rect.Y + 4, _rect.X + _rect.W - 4, _rect.Y + _rect.H - 4, true);

    draw_set_color(_label == "NOVO" ? make_color_rgb(56, 154, 88) : make_color_rgb(196, 46, 54));
    draw_rectangle(_rect.X + 8, _rect.Y + 8, _rect.X + _rect.W - 8, _rect.Y + 42, false);
    draw_set_color(c_white);
    draw_text_transformed(_rect.X + 18, _rect.Y + 18, _label, 0.52, 0.52, 0);

    draw_set_color(make_color_rgb(36, 30, 28));
    battle_ui_draw_text_fit(_rect.X + 16, _rect.Y + 54, _pokemon.Nome, _rect.W - 80, 0.62, make_color_rgb(36, 30, 28));
    draw_set_halign(fa_right);
    draw_text_transformed(_rect.X + _rect.W - 18, _rect.Y + 54, "Lv." + string(_pokemon.Level), 0.52, 0.52, 0);
    draw_set_halign(fa_left);

    var _raridade = variable_struct_exists(_pokemon, "RaridadeEfetiva") ? _pokemon.RaridadeEfetiva : (variable_struct_exists(_pokemon, "RaridadePadrao") ? _pokemon.RaridadePadrao : PokemonRaridade.COMMON);
    pokemon_raridade_draw_icon(_raridade, _rect.X + _rect.W - 34, _rect.Y + 16, 18);
    battle_ui_draw_type_icon(_pokemon.Tipo1, _rect.X + 16, _rect.Y + 78, 0.48);

    if (_pokemon.Tipo2 != PokemonTipo.NONE && _pokemon.Tipo2 != _pokemon.Tipo1) {
        battle_ui_draw_type_icon(_pokemon.Tipo2, _rect.X + 54, _rect.Y + 78, 0.48);
    }

    var _is_shiny = variable_struct_exists(_pokemon, "IsShiny") && _pokemon.IsShiny;
    var _icon = demo_pokemon_icon_get(_pokemon.ID, _is_shiny);
    var _sprite_y = _rect.Y + 134;

    draw_set_color(make_color_rgb(168, 220, 188));
    draw_rectangle(_rect.X + 16, _rect.Y + 104, _rect.X + _rect.W - 16, _rect.Y + 164, false);
    draw_set_color(make_color_rgb(104, 172, 128));
    draw_line_width(_rect.X + 28, _rect.Y + 154, _rect.X + _rect.W - 28, _rect.Y + 154, 2);

    if (sprite_exists(_icon)) {
        draw_sprite_ext(_icon, 0, _rect.X + (_rect.W * 0.5), _sprite_y, 1.65, 1.65, 0, c_white, 1);
    } else {
        demo_draw_pokemon_sprite(_pokemon.ID, _rect.X + (_rect.W * 0.5), _sprite_y + 22, 0.9, 1, 0);
    }

    demo_draw_pokemon_stat_bars(_pokemon, _rect.X + 16, _rect.Y + 176, _rect.W - 32, true);

    var _skills_y = _rect.Y + 274;
    draw_set_color(make_color_rgb(204, 188, 158));
    draw_line_width(_rect.X + 16, _skills_y - 10, _rect.X + _rect.W - 16, _skills_y - 10, 1);
    draw_set_color(make_color_rgb(36, 30, 28));
    draw_text_transformed(_rect.X + 16, _skills_y - 2, "Habilidades", 0.48, 0.48, 0);

    for (var _s = 0; _s < 4; _s += 1) {
        var _skill = _pokemon.HabilidadesEquipadas[_s];
        var _skill_tooltip = demo_capture_replace_draw_skill(_skill, _rect.X + 16, _skills_y + 24 + (_s * 31), _rect.W - 32, _mx, _my);

        if (is_struct(_skill_tooltip)) {
            _tooltip = _skill_tooltip;
        }
    }

    if (_clickable) {
        draw_set_color(_hover ? make_color_rgb(36, 30, 28) : make_color_rgb(92, 72, 58));
        draw_set_halign(fa_center);
        draw_text_transformed(_rect.X + (_rect.W * 0.5), _rect.Y + _rect.H - 30, "SUBSTITUIR", 0.58, 0.58, 0);
        draw_set_halign(fa_left);
    }

    return _tooltip;
}

function demo_draw_capture_replace_overlay(_controller) {
    if (!instance_exists(_controller) || !variable_instance_exists(_controller, "capture_replace_open") || !_controller.capture_replace_open || !is_struct(_controller.capture_replace_pokemon)) {
        return;
    }

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _panel_w = min(_gw - 64, 1260);
    var _panel_h = min(_gh - 64, 640);
    var _panel_x = (_gw - _panel_w) * 0.5;
    var _panel_y = (_gh - _panel_h) * 0.5;

    draw_set_alpha(0.72);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    battle_ui_draw_nineslice_panel(_panel_x, _panel_y, _panel_w, _panel_h);
    draw_set_color(make_color_rgb(36, 30, 28));
    draw_text(_panel_x + 28, _panel_y + 20, "EQUIPE CHEIA");
    battle_ui_font_body();
    draw_text_ext(_panel_x + 28, _panel_y + 52, "Escolha um monstro da equipe para dar lugar a " + _controller.capture_replace_pokemon.Nome + ".", 24, _panel_w - 56);
    battle_ui_font_title();

    var _tooltip = undefined;
    demo_party_garantir(_controller);

    for (var _i = 0; _i < 4; _i += 1) {
        var _party_pokemon = _i < array_length(_controller.player_party) ? _controller.player_party[_i] : undefined;
        var _rect = demo_capture_replace_card_rect(_controller, _i);
        var _card_tooltip = demo_draw_capture_replace_card(_party_pokemon, _rect, _i == _controller.player_party_active_index ? "ATIVO" : "TIME", true, _mx, _my);

        if (is_struct(_card_tooltip)) {
            _tooltip = _card_tooltip;
        }
    }

    var _new_rect = demo_capture_replace_card_rect(_controller, 4);
    var _new_tooltip = demo_draw_capture_replace_card(_controller.capture_replace_pokemon, _new_rect, "NOVO", false, _mx, _my);

    if (is_struct(_new_tooltip)) {
        _tooltip = _new_tooltip;
    }

    draw_set_color(make_color_rgb(92, 72, 58));
    battle_ui_font_body();
    draw_text(_panel_x + 28, _panel_y + _panel_h - 34, "Passe o mouse nas habilidades para ver a descricao. Clique em um monstro do time para substituir.");
    battle_ui_font_title();
    demo_draw_status_tooltip(_tooltip);
}

function demo_party_trocar_ativo(_controller, _party_index) {
    if (!instance_exists(_controller)) {
        return false;
    }

    demo_party_garantir(_controller);

    if (_party_index < 0 || _party_index >= array_length(_controller.player_party)) {
        return false;
    }

    var _novo = _controller.player_party[_party_index];

    if (!is_struct(_novo) || (variable_struct_exists(_novo, "HpAtual") && _novo.HpAtual <= 0)) {
        _controller.message = "Esse monstro nao consegue lutar agora.";
        return false;
    }

    if (instance_exists(_controller.player_inst) && is_struct(_controller.player_pokemon_data)) {
        _controller.player_pokemon_data.HpAtual = max(0, _controller.player_inst.hp_atual);
    }

    _controller.player_party_active_index = _party_index;
    _controller.player_pokemon_data = _novo;
    demo_battle_marcar_participante(_controller, _controller.player_pokemon_data);

    if (instance_exists(_controller.player_inst)) {
        _controller.player_inst.vivo = true;
        _controller.player_inst.batalha_ativo = true;
        pokemon_batalha_injetar(_controller.player_inst, _controller.player_pokemon_data);
        pokemon_batalha_definir_lado(_controller.player_inst, LadoBatalha.ALIADO);
    }

    battle_log_force("Vai, " + string_upper(_controller.player_pokemon_data.Nome) + "!");
    return true;
}

function demo_battle_marcar_participante(_controller, _pokemon) {
    if (!instance_exists(_controller) || !is_struct(_pokemon)) {
        return;
    }

    if (!variable_instance_exists(_controller, "battle_participants") || !is_array(_controller.battle_participants)) {
        _controller.battle_participants = [];
    }

    for (var _i = 0; _i < array_length(_controller.battle_participants); _i += 1) {
        if (_controller.battle_participants[_i] == _pokemon) {
            return;
        }
    }

    var _participants = _controller.battle_participants;
    array_push(_participants, _pokemon);
    _controller.battle_participants = _participants;
}

function demo_exp_compartilhar(_controller, _base_xp) {
    if (!instance_exists(_controller) || _base_xp <= 0) {
        return [];
    }

    demo_party_garantir(_controller);
    var _ganhos = [];

    for (var _i = 0; _i < array_length(_controller.player_party); _i += 1) {
        var _pokemon = _controller.player_party[_i];

        if (!is_struct(_pokemon)) {
            continue;
        }

        var _participou = false;

        for (var _p = 0; _p < array_length(_controller.battle_participants); _p += 1) {
            if (_controller.battle_participants[_p] == _pokemon) {
                _participou = true;
                break;
            }
        }

        var _xp = _participou ? _base_xp : floor(_base_xp * 0.5);

        if (_xp <= 0) {
            continue;
        }

        var _level_antes = _pokemon.Level;
        var _resultado = pokemon_ganhar_exp(_pokemon, _xp);

        array_push(_ganhos, {
            Pokemon: _pokemon,
            XP: _xp,
            Participou: _participou,
            LevelAntes: _level_antes,
            LevelDepois: is_struct(_resultado) ? _resultado.LevelFinal : _pokemon.Level,
            Evolucoes: (is_struct(_resultado) && variable_struct_exists(_resultado, "Evolucoes") && is_array(_resultado.Evolucoes)) ? _resultado.Evolucoes : []
        });
    }

    return _ganhos;
}

function demo_exp_ganhos_mesclar(_base, _novos) {
    if (!is_array(_base)) {
        _base = [];
    }

    if (!is_array(_novos)) {
        return _base;
    }

    for (var _i = 0; _i < array_length(_novos); _i += 1) {
        var _novo = _novos[_i];

        if (!is_struct(_novo) || !is_struct(_novo.Pokemon)) {
            continue;
        }

        var _achou = false;

        for (var _b = 0; _b < array_length(_base); _b += 1) {
            var _existente = _base[_b];

            if (is_struct(_existente) && _existente.Pokemon == _novo.Pokemon) {
                _existente.XP += _novo.XP;
                _existente.Participou = _existente.Participou || _novo.Participou;
                _existente.LevelDepois = _novo.LevelDepois;

                if (!variable_struct_exists(_existente, "Evolucoes") || !is_array(_existente.Evolucoes)) {
                    _existente.Evolucoes = [];
                }

                if (variable_struct_exists(_novo, "Evolucoes") && is_array(_novo.Evolucoes)) {
                    for (var _ev = 0; _ev < array_length(_novo.Evolucoes); _ev += 1) {
                        array_push(_existente.Evolucoes, _novo.Evolucoes[_ev]);
                    }
                }

                _base[_b] = _existente;
                _achou = true;
                break;
            }
        }

        if (!_achou) {
            array_push(_base, _novo);
        }
    }

    return _base;
}

function demo_battle_rewards_resetar(_controller) {
    if (!instance_exists(_controller)) {
        return;
    }

    _controller.battle_reward_xp_base_total = 0;
    _controller.battle_reward_money_total = 0;
    _controller.battle_reward_ganhos = [];
    _controller.battle_reward_items = [];
}

function demo_battle_reward_adicionar(_controller, _xp_base, _xp_ganhos, _dinheiro) {
    if (!instance_exists(_controller)) {
        return;
    }

    _controller.battle_reward_xp_base_total += max(0, _xp_base);
    _controller.battle_reward_money_total += max(0, _dinheiro);
    _controller.battle_reward_ganhos = demo_exp_ganhos_mesclar(_controller.battle_reward_ganhos, _xp_ganhos);
}

function demo_resultado_criar(_tipo, _titulo, _mensagem, _xp_base, _xp_ganhos, _capturado) {
    return {
        Tipo: _tipo,
        Titulo: _titulo,
        Mensagem: _mensagem,
        XPBase: _xp_base,
        Ganhos: is_array(_xp_ganhos) ? _xp_ganhos : [],
        Capturado: _capturado,
        Dinheiro: argument_count >= 7 ? argument[6] : 0,
        Itens: argument_count >= 8 && is_array(argument[7]) ? argument[7] : [],
        FragmentosEspaco: argument_count >= 9 ? max(0, argument[8]) : 0
    };
}

function demo_run_resetar(_controller, _estado_destino) {
    if (!instance_exists(_controller)) {
        return;
    }

    diario_encerrar();

    with (_controller) {
        demo_cleanup_battle(id);

        starter_id = -1;
        player_pokemon_data = undefined;
        enemy_pokemon_data = undefined;
        player_party = [];
        player_party_active_index = 0;
        player_inst = noone;
        enemy_inst = noone;
        battle_manager = noone;
        battle_trainer_active = false;
        battle_trainer_name = "";
        battle_context = "";
        gym_battle_city_index = -1;
        route_trainer_data = undefined;
        trainer_party = [];
        trainer_party_index = 0;
        route_trainer_encountered = false;
        route_trainer_step = -1;
        battle_reward_xp_base_total = 0;
        battle_reward_money_total = 0;
        battle_reward_ganhos = [];
        battle_reward_items = [];
        route_steps = 0;
        route_steps_needed = irandom_range(3, 6);
        rota_origem_index = 0;
        rota_destino_index = 0;
        saida_destino_index = -1;
        rota_atual = undefined;
        cidade_index = 0;
        cidade_nome = "Vila Alvorada";
        dinheiro = 0;
        inventario = demo_inventario_criar();
        meta_progresso = demo_meta_carregar();
        demo_meta_sincronizar_globals(meta_progresso);
        meta_inicio_aplicado = false;
        starter_ids = demo_meta_starter_roll(meta_progresso);
        mochila_contexto_anterior = DemoEstado.CIDADE;
        mae_presente_entregue = false;
        professor_carvalho_visto = false;
        ginasios_vencidos = array_create(array_length(kanto_cidades), false);
        cidade_eventos_vistos = array_create(array_length(kanto_cidades), false);
        rota_drafts = array_create(array_length(rota_blocos_db), undefined);
        rota_escolhas = array_create(array_length(rota_blocos_db), "");
        result_timer = 0;
        capture_anim = undefined;
        capture_pending_item = "";
        capture_pending_success = false;
        capture_replace_open = false;
        capture_replace_pokemon = undefined;
        battle_participants = [];
        battle_result_info = undefined;
        battle_reward_xp_base_total = 0;
        battle_reward_money_total = 0;
        battle_reward_ganhos = [];
        battle_reward_items = [];
        intro_timer = 0;
        intro_step = 0;
        game_over_timer = 0;
        estado_demo = _estado_destino;
        message = _estado_destino == DemoEstado.MENU ? "Menu inicial" : "Escolha seu monstro inicial";

        if (variable_global_exists("mochila_overlay_aberta")) global.mochila_overlay_aberta = false;
        if (variable_global_exists("troca_overlay_aberta")) global.troca_overlay_aberta = false;
        if (variable_global_exists("pokedex_overlay_aberto")) global.pokedex_overlay_aberto = false;
        if (variable_global_exists("time_scale")) global.time_scale = 1.0;
        if (variable_global_exists("velocidade_jogo")) global.velocidade_jogo = 1.0;
        if (variable_global_exists("draft_habilidade_atual")) global.draft_habilidade_atual = undefined;
        if (variable_global_exists("draft_habilidade_fila")) global.draft_habilidade_fila = [];
        if (variable_global_exists("estado_jogo")) global.estado_jogo = EstadoJogo.EXPLORACAO;
    }
}

function demo_capture_chance(_controller, _item, _enemy) {
    if (!instance_exists(_controller) || !is_struct(_item) || !is_struct(_enemy)) {
        return 0;
    }

    var _hp_pct = 1;

    if (instance_exists(_controller.enemy_inst)) {
        _hp_pct = clamp(_controller.enemy_inst.hp_atual / max(1, _controller.enemy_inst.hp_max), 0, 1);
    } else if (variable_struct_exists(_enemy, "HpAtual")) {
        _hp_pct = clamp(_enemy.HpAtual / max(1, _enemy.HpMax), 0, 1);
    }

    var _low_hp_bonus = (1 - _hp_pct) * 0.22;
    var _shiny_bonus = variable_struct_exists(_enemy, "CaptureChanceBonus") ? _enemy.CaptureChanceBonus : 0;
    var _meta_bonus = variable_global_exists("demo_meta_capture_bonus") ? global.demo_meta_capture_bonus : 0;
    return clamp(_item.ValorEfeito + _low_hp_bonus + _shiny_bonus + _meta_bonus, 0.03, 1);
}

function demo_capture_anim_criar(_item_id, _success) {
    return {
        ItemID: _item_id,
        Timer: 0,
        Duracao: _success ? 3.7 : 3.0,
        Success: _success,
        Phase: "throw",
        ShakeCount: 0,
        Done: false
    };
}

function demo_capture_iniciar(_controller, _id_item) {
    if (!instance_exists(_controller)) {
        return false;
    }

    var _item = demo_item_get(_id_item);

    if (!is_struct(_item) || _item.Tipo != "captura") {
        return false;
    }

    if (_controller.battle_context != "rota") {
        _controller.message = "Voce so pode capturar monstros selvagens.";
        battle_log_push(_controller.message);
        return false;
    }

    if (!is_struct(_controller.enemy_pokemon_data) || !instance_exists(_controller.enemy_inst) || !_controller.enemy_inst.vivo) {
        return false;
    }

    demo_party_garantir(_controller);

    if (demo_inventario_quantidade(_controller.inventario, _id_item) <= 0) {
        _controller.message = "Voce nao possui " + _item.Nome + ".";
        battle_log_push(_controller.message);
        return false;
    }

    demo_inventario_adicionar(_controller.inventario, _id_item, -1);
    var _chance = demo_capture_chance(_controller, _item, _controller.enemy_pokemon_data);
    var _success = random(1) < _chance;
    _controller.capture_anim = demo_capture_anim_criar(_id_item, _success);
    _controller.capture_pending_item = _id_item;
    _controller.capture_pending_success = _success;
    _controller.estado_demo = DemoEstado.CAPTURA;
    global.mochila_overlay_aberta = false;
    global.pokedex_overlay_aberto = false;
    global.troca_overlay_aberta = false;
    global.time_scale = 0;
    global.velocidade_jogo = 0;
    battle_log_force("Voce arremessou " + string_upper(_item.Nome) + "!");
    return true;
}

function demo_item_usar(_controller, _id_item, _em_batalha) {
    if (!instance_exists(_controller)) {
        return false;
    }

    var _item = demo_item_get(_id_item);

    if (!demo_item_pode_usar(_item, _em_batalha)) {
        return false;
    }

    with (_controller) {
        if (demo_inventario_quantidade(inventario, _id_item) <= 0) {
            message = "Voce nao possui " + _item.Nome + ".";
            exit;
        }

        if (_item.Tipo == "captura") {
            demo_capture_iniciar(id, _id_item);
            exit;
        }

        if (_item.Tipo == "level") {
            if (!is_struct(player_pokemon_data)) {
                message = "Nenhum monstro ativo para receber o Cristal de Nivel.";
                exit;
            }

            if (player_pokemon_data.Level >= 30) {
                message = player_pokemon_data.Nome + " ja esta no nivel maximo.";
                exit;
            }

            var _level_antes_candy = player_pokemon_data.Level;
            var _xp_para_subir = max(1, player_pokemon_data.ExpNecessaria - player_pokemon_data.ExpAtual);
            var _resultado_candy = pokemon_ganhar_exp(player_pokemon_data, _xp_para_subir);

            if (is_struct(_resultado_candy) && _resultado_candy.LevelFinal > _level_antes_candy) {
                demo_inventario_adicionar(inventario, _id_item, -1);
                message = player_pokemon_data.Nome + " subiu para o Lv." + string(player_pokemon_data.Level) + "!";
            } else {
                message = "O Cristal de Nivel nao teve efeito.";
            }

            exit;
        }

        var _ally = instance_exists(player_inst) ? player_inst : noone;
        var _curou = false;

        if (instance_exists(_ally) && (_item.Tipo == "cura" || _item.Tipo == "cura_status")) {
            var _antes = _ally.hp_atual;
            _ally.hp_atual = min(_ally.hp_max, _ally.hp_atual + ceil(_ally.hp_max * _item.ValorEfeito));
            _curou = _ally.hp_atual > _antes;

            if (is_struct(player_pokemon_data)) {
                player_pokemon_data.HpAtual = _ally.hp_atual;
            }
        } else if (!_em_batalha && is_struct(player_pokemon_data) && (_item.Tipo == "cura" || _item.Tipo == "cura_status")) {
            if (!variable_struct_exists(player_pokemon_data, "HpAtual")) {
                player_pokemon_data.HpAtual = player_pokemon_data.HpMax;
            }

            var _antes_data = player_pokemon_data.HpAtual;
            player_pokemon_data.HpAtual = min(player_pokemon_data.HpMax, player_pokemon_data.HpAtual + ceil(player_pokemon_data.HpMax * _item.ValorEfeito));
            _curou = player_pokemon_data.HpAtual > _antes_data;
        }

        if (_item.Tipo == "cooldown" && instance_exists(_ally)) {
            for (var _i_cd = 0; _i_cd < 4; _i_cd += 1) {
                var _skill_cd = _ally.habilidades_equipadas[_i_cd];

                if (is_struct(_skill_cd)) {
                    _skill_cd.TempoRecargaAtual *= (1 - _item.ValorEfeito);
                }
            }

            _curou = true;
        }

        if (_item.Tipo == "status" || _item.Tipo == "cura_status") {
            if (instance_exists(_ally) && is_struct(_ally.status_map)) {
                _ally.status_map = {};
            }

            _curou = true;
        }

        if (!_curou && (_item.Tipo == "cura" || _item.Tipo == "cura_status")) {
            message = player_pokemon_data.Nome + " ja esta com HP cheio.";
            exit;
        }

        demo_inventario_adicionar(inventario, _id_item, -1);
        message = "Voce usou " + _item.Nome + ".";

        if (_em_batalha) {
            battle_log_push("Voce usou " + string_upper(_item.Nome) + "!");
        }
    }

    return true;
}

function demo_item_comprar(_controller, _id_item) {
    if (!instance_exists(_controller)) {
        return false;
    }

    var _item = demo_item_get(_id_item);

    if (!is_struct(_item) || _item.Preco <= 0) {
        return false;
    }

    with (_controller) {
        if (dinheiro < _item.Preco) {
            message = "Dinheiro insuficiente para comprar " + _item.Nome + ".";
            exit;
        }

        dinheiro -= _item.Preco;
        demo_inventario_adicionar(inventario, _id_item, 1);
        message = "Comprou " + _item.Nome + ".";
    }

    return true;
}

function demo_kanto_cidades_criar() {
    // Cidades, lideres e eventos vem de datafiles/data/mundo.json.
    var _fonte = conteudo_cidades();
    var _cidades = [];

    for (var _i = 0; _i < array_length(_fonte); _i += 1) {
        var _c = _fonte[_i];
        array_push(_cidades, {
            Nome: string(conteudo_struct_get(_c, "nome", "Cidade " + string(_i + 1))),
            Lider: string(conteudo_struct_get(_c, "lider", "")),
            Especialidade: string(conteudo_struct_get(_c, "especialidade", "")),
            Tipo: conteudo_tipo_de_texto(conteudo_struct_get(_c, "tipo", "")),
            Evento: string(conteudo_struct_get(_c, "evento", "")),
            LiderCriaturaID: floor(conteudo_struct_get(_c, "lider_criatura_id", 0)),
            LiderNivel: floor(conteudo_struct_get(_c, "lider_nivel", 0)),
            SpriteLider: string(conteudo_struct_get(_c, "sprite_lider", "")),
            SpriteCidade: string(conteudo_struct_get(_c, "sprite_cidade", ""))
        });
    }

    if (array_length(_cidades) <= 0) {
        array_push(_cidades, { Nome: "Vila Alvorada", Lider: "", Especialidade: "", Tipo: PokemonTipo.NONE, Evento: "Casa da Mae", LiderCriaturaID: 0, LiderNivel: 0, SpriteLider: "", SpriteCidade: "" });
    }

    return _cidades;
}

function demo_cidade_atual() {
    if (!variable_instance_exists(id, "kanto_cidades") || !is_array(kanto_cidades)) {
        return { Nome: "Vila Alvorada", Lider: "", Especialidade: "", Tipo: PokemonTipo.NONE, Evento: "Casa da Mae" };
    }

    return kanto_cidades[clamp(cidade_index, 0, array_length(kanto_cidades) - 1)];
}

function demo_cidade_nome(_index) {
    if (!variable_instance_exists(id, "kanto_cidades") || !is_array(kanto_cidades)) {
        return "Vila Alvorada";
    }

    return kanto_cidades[clamp(_index, 0, array_length(kanto_cidades) - 1)].Nome;
}

function demo_cidade_tem_ginasio(_index) {
    return _index >= 2;
}

function demo_cidade_ginasio_vencido(_index) {
    if (!demo_cidade_tem_ginasio(_index)) {
        return true;
    }

    if (!variable_instance_exists(id, "ginasios_vencidos") || !is_array(ginasios_vencidos)) {
        return false;
    }

    return ginasios_vencidos[_index];
}

function DemoRotaData(_id, _nome, _descricao, _biomas, _min_encontros, _max_encontros, _min_selvagem, _max_selvagem, _min_treinador, _max_treinador) constructor {
    ID = _id;
    Nome = _nome;
    Descricao = _descricao;
    Biomas = _biomas;
    MinEncontros = _min_encontros;
    MaxEncontros = _max_encontros;
    MinSelvagem = _min_selvagem;
    MaxSelvagem = _max_selvagem;
    MinTreinador = _min_treinador;
    MaxTreinador = _max_treinador;
}

function demo_rota_pool_geral_criar() {
    return [
        new DemoRotaData("rota_2", "Bosque Verdejante", "Mata fechada com insetos e flores toxicas", ["inseto", "grama", "veneno"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("rota_22", "Caminho dos Desafiantes", "Trilha de treino entre lutadores e fadas", ["luta", "fada", "normal"], 3, 5, 0, 0, 0, 0),
        new DemoRotaData("rota_23", "Pantano das Fendas", "Lama, agua parada e insetos", ["veneno", "agua", "inseto"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("rota_3_4", "Gruta do Eco", "Entrada rochosa cheia de ecos", ["caverna", "pedra", "terra"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("rota_42", "Pico Congelado", "Vento gelado e asas no alto", ["gelo", "dragao", "voador"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("rota_4_ferro", "Fenda de Ferro", "Rochas metalicas e trilhos velhos", ["aco", "pedra", "normal"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("rota_5_6", "Via Central", "Estrada movimentada e campos eletricos", ["terra", "eletrico", "normal"], 3, 5, 0, 0, 0, 0),
        new DemoRotaData("rota_115", "Vale Mistico", "Nevoa feerica e ecos psiquicos", ["fada", "psiquico", "fantasma"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("rota_9", "Desfiladeiro Ardente", "Pedra quente e chao rachado", ["fogo", "terra", "pedra"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("rota_19_20", "Mar Aberto", "Ondas, aves e sombras no fundo", ["agua", "sombrio", "voador"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("rota_10", "Usinas Destruidas", "Maquinas faiscando entre chamas", ["aco", "eletrico", "fogo"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("rota_12", "Abismo das Fendas", "Agua escura e vultos", ["sombrio", "fantasma", "agua"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("rota_21", "Canal Vulcanico", "Magma, dragoes e fumaca", ["dragao", "fogo", "sombrio"], 3, 5, 0, 0, 0, 0),
        new DemoRotaData("bosque_venenoso", "Bosque Venenoso", "Flores toxicas e insetos de fenda", ["grama", "veneno", "inseto"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("trilha_cinzas", "Trilha de Cinzas", "Terra quente e rochas instaveis", ["fogo", "terra", "pedra"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("canion_magnetico", "Canion Magnetico", "Sucata antiga e campos eletricos", ["eletrico", "aco", "terra"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("praia_ventos", "Praia dos Ventos", "Agua rasa, aves e trilha costeira", ["agua", "voador", "normal"], 3, 5, 0, 0, 0, 0),
        new DemoRotaData("ruinas_psiquicas", "Ruinas Psiquicas", "Ecos mentais entre casas quebradas", ["psiquico", "fantasma", "fada"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("glaciar_errante", "Glaciar Errante", "Nevoa fria cortando a estrada", ["gelo", "agua", "dragao"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("caverna_cristal", "Caverna Cristal", "Pedras vivas e metal brilhante", ["caverna", "pedra", "aco"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("campo_floral", "Campo Floral", "Flores estranhas perto da fazenda", ["fada", "grama", "normal"], 3, 5, 0, 0, 0, 0),
        new DemoRotaData("dojo_abandonado", "Dojo Abandonado", "Faixas rasgadas e passos no escuro", ["luta", "sombrio", "normal"], 3, 5, 0, 0, 0, 0),
        new DemoRotaData("ponte_sombria", "Ponte Sombria", "Fenda noturna sobre agua parada", ["sombrio", "fantasma", "veneno"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("ninho_correntes", "Ninho das Correntes", "Vento forte e descargas no ar", ["voador", "eletrico", "dragao"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("lamacal_antigo", "Lamacal Antigo", "Agua barrenta e toxinas no solo", ["agua", "terra", "veneno"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("bosque_seda", "Bosque de Seda", "Teias, folhas e luzes feericas", ["inseto", "grama", "fada"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("deserto_partido", "Deserto Partido", "Areia quente e pedra rachada", ["terra", "pedra", "fogo"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("usina_submersa", "Usina Submersa", "Maquinas afogadas ainda ligadas", ["eletrico", "agua", "aco"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("cratera_draconica", "Cratera Draconica", "Calor, pedra e presenca ancestral", ["dragao", "fogo", "pedra"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("jardim_lunar", "Jardim Lunar", "Clareira fria sob luz estranha", ["fada", "gelo", "grama"], 3, 5, 0, 0, 0, 0),
        new DemoRotaData("trilho_sucata", "Trilho de Sucata", "Linha ferrea tomada por metal vivo", ["aco", "eletrico", "sombrio"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("corrego_oculto", "Corrego Oculto", "Agua limpa cortando mato fechado", ["agua", "grama", "psiquico"], 3, 5, 0, 0, 0, 0),
        new DemoRotaData("torre_ruida", "Torre Ruida", "Pedra antiga e sombras no alto", ["fantasma", "voador", "pedra"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("planicie_raios", "Planicie dos Raios", "Campo aberto carregado de eletricidade", ["eletrico", "normal", "voador"], 3, 5, 0, 0, 0, 0),
        new DemoRotaData("mina_salgada", "Mina Salgada", "Tuneis umidos perto do mar", ["caverna", "agua", "pedra"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("mata_crepusculo", "Mata do Crepusculo", "Arvores densas e passos distantes", ["sombrio", "grama", "inseto"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("floresta_eclipse", "Floresta do Eclipse", "Noite fechada, lua baixa e teias nas trilhas", ["sombrio", "fantasma", "inseto"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("sepulcro_raizes", "Sepulcro de Raizes", "Tumulos tomados por musgo e veneno", ["fantasma", "grama", "veneno"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("fornalha_ferro", "Fornalha de Ferro", "Metal rubro, fuligem e vapor eletrico", ["fogo", "aco", "eletrico"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("tunel_obsidiana", "Tunel de Obsidiana", "Caverna quente com rochas negras", ["caverna", "fogo", "pedra"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("serra_gelida", "Serra Gelida", "Vento cortante entre pedra e metal", ["gelo", "pedra", "aco"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("lago_neblina", "Lago da Neblina", "Agua fria sob ecos psiquicos", ["agua", "gelo", "psiquico"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("altar_lunar", "Altar Lunar", "Pedras antigas brilhando com energia feerica", ["fada", "fantasma", "psiquico"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("penhasco_dragao", "Penhasco do Dragao", "Correntes de ar sobre rochas escaldadas", ["dragao", "voador", "fogo"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("pedreira_bruta", "Pedreira Bruta", "Quebra-pedra, poeira e treino pesado", ["pedra", "luta", "terra"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("pantanoso_noturno", "Pantano Noturno", "Agua escura com toxinas e insetos", ["agua", "sombrio", "veneno"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("jardim_estilhacado", "Jardim Estilhacado", "Flores feericas crescendo entre cristais", ["fada", "grama", "pedra"], 3, 5, 0, 0, 0, 0),
        new DemoRotaData("trilha_carvao", "Trilha do Carvao", "Cinzas no mato e calor vindo do subsolo", ["fogo", "grama", "terra"], 4, 5, 0, 0, 0, 0),
        new DemoRotaData("observatorio_eco", "Observatorio Eco", "Antenas quebradas lendo sinais mentais", ["psiquico", "eletrico", "normal"], 3, 5, 0, 0, 0, 0),
        new DemoRotaData("ninho_farpas", "Ninho de Farpas", "Casulos, espinhos e sombra entre folhas", ["inseto", "sombrio", "grama"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("dique_enferrujado", "Dique Enferrujado", "Agua batendo em comportas antigas", ["agua", "aco", "eletrico"], 4, 6, 0, 0, 0, 0),
        new DemoRotaData("arena_poeira", "Arena de Poeira", "Solo seco marcado por batalhas", ["luta", "terra", "normal"], 3, 5, 0, 0, 0, 0)
    ];
}

function demo_rota_blocos_criar() {
    var _pool = demo_rota_pool_geral_criar();

    return [
        [
            new DemoRotaData("rota_1", "Trilha da Alvorada", "Estrada de grama classica", ["grama", "normal", "voador"], 3, 5, 0, 0, 0, 0)
        ],
        _pool,
        _pool,
        _pool,
        _pool,
        _pool
    ];
}

function demo_rota_block_index(_origem_index, _destino_index) {
    return clamp(min(_origem_index, _destino_index), 0, 5);
}

function demo_rota_level_range(_block_index, _treinador) {
    var _block = clamp(_block_index, 0, 5);

    if (_treinador) {
        switch (_block) {
            case 0: return [2, 3];
            case 1: return [6, 8];
            case 2: return [10, 12];
            case 3: return [14, 16];
            case 4: return [19, 22];
            case 5: return [24, 27];
        }
    }

    switch (_block) {
        case 0: return [1, 3];
        case 1: return [4, 7];
        case 2: return [8, 11];
        case 3: return [12, 15];
        case 4: return [16, 21];
        case 5: return [22, 26];
    }

    return [1, 3];
}

function demo_rota_level_range_texto(_block_index, _treinador) {
    var _range = demo_rota_level_range(_block_index, _treinador);
    return "Lv. " + string(_range[0]) + "-" + string(_range[1]);
}

function demo_rota_biomas_texto(_rota) {
    if (!is_struct(_rota) || !is_array(_rota.Biomas)) {
        return "";
    }

    var _texto = "";

    for (var _i = 0; _i < array_length(_rota.Biomas); _i += 1) {
        if (_i > 0) {
            _texto += ", ";
        }

        _texto += _rota.Biomas[_i];
    }

    return _texto;
}

function demo_rota_descricao_visual(_rota) {
    if (!is_struct(_rota)) {
        return "Caminho instavel entre fendas.";
    }

    switch (_rota.ID) {
        case "rota_1": return "Estrada clara, grama alta e muitas arvores.";
        case "rota_2": return "Bosque fechado, folhas altas e veneno no ar.";
        case "rota_22": return "Estrada de treino rumo a Liga do Vale.";
        case "rota_23": return "Pantano baixo, agua parada e zumbidos constantes.";
        case "rota_3_4": return "Entrada rochosa da Gruta do Eco, cheia de ecos.";
        case "rota_42": return "Subida congelada sob ventos cortantes.";
        case "rota_4_ferro": return "Fenda metalica entre rochas antigas.";
        case "rota_5_6": return "Via central com fios soltos e terra batida.";
        case "rota_115": return "Vale mistico onde ecos respondem aos passos.";
        case "rota_9": return "Desfiladeiro quente, rachado e instavel.";
        case "rota_19_20": return "Mar aberto com sombras cruzando as ondas.";
        case "rota_10": return "Usina quebrada ainda faiscando no escuro.";
        case "rota_12": return "Abismo sobre agua escura e fendas frias.";
        case "rota_21": return "Canal vulcanico aquecido por presenca antiga.";
        case "glaciar_errante": return "Nevoa fria, gelo fino e agua quase parada.";
        case "floresta_eclipse": return "Mata noturna com lua baixa e teias densas.";
        case "caverna_cristal": return "Tuneis de pedra com cristais vivos nas paredes.";
        case "bosque_venenoso": return "Bosque toxico com troncos ocos e pocas venenosas.";
        case "trilha_cinzas": return "Trilha queimada, brasa viva e vento quente.";
        case "canion_magnetico": return "Canion de ferro, rochas partidas e descargas no ar.";
        case "praia_ventos": return "Costa aberta, nuvens correndo e ondas agitadas.";
        case "ruinas_psiquicas": return "Pilares antigos, nevoa roxa e ecos mentais.";
        case "campo_floral": return "Flores altas, polen no vento e insetos rondando.";
        case "dojo_abandonado": return "Tatames quebrados e poeira girando no silencio.";
        case "ponte_sombria": return "Ponte fria sobre agua escura e sombras na margem.";
        case "ninho_correntes": return "Rocha molhada, correnteza e ninhos entre as fendas.";
        case "lamacal_antigo": return "Lama funda, pocas verdes e cheiro de pantano antigo.";
        case "bosque_seda": return "Bosque de teias, galhos baixos e folhas vibrando.";
        case "deserto_partido": return "Areia rachada, pedras quentes e vento seco.";
        case "usina_submersa": return "Maquinas afogadas, chuva fina e cabos faiscando.";
        case "cratera_draconica": return "Cratera escura com marcas antigas de dragao.";
        case "jardim_lunar": return "Jardim noturno, flores claras e brilho de lua.";
        case "trilho_sucata": return "Trilho abandonado, placas tortas e metal vivo.";
        case "corrego_oculto": return "Corrego estreito, mato fechado e agua fria.";
        case "torre_ruida": return "Torre partida, lapides caidas e nevoa densa.";
        case "planicie_raios": return "Ferro-velho vivo, carros largados e faiscas soltas.";
        case "mina_salgada": return "Mina umida, sal nas paredes e pedra escorregadia.";
        case "mata_crepusculo": return "Mata em crepusculo, folhas roxas e olhos distantes.";
        case "sepulcro_raizes": return "Lapides presas por raizes e ar parado.";
        case "fornalha_ferro": return "Ferro rubro, fuligem e vapor eletrico.";
        case "tunel_obsidiana": return "Tunel negro, pedra quente e luz de lava distante.";
        case "serra_gelida": return "Pedra gelada e metal rangendo no vento.";
        case "lago_neblina": return "Lago quieto, neblina baixa e reflexos estranhos.";
        case "altar_lunar": return "Altar sob a lua, runas frias e silencio pesado.";
        case "penhasco_dragao": return "Penhasco alto, vento forte e marcas de garras.";
        case "pedreira_bruta": return "Pedreira aberta, blocos partidos e poeira grossa.";
        case "pantanoso_noturno": return "Pantano escuro, toxinas e reflexos nas aguas.";
        case "jardim_estilhacado": return "Jardim quebrado, cristais soltos e brilho irregular.";
        case "trilha_carvao": return "Carvao no chao, fumaca baixa e brasas teimosas.";
        case "observatorio_eco": return "Observatorio quebrado, metal frio e ecos no ceu.";
        case "ninho_farpas": return "Arbustos de farpas, insetos rapidos e folhas cortadas.";
        case "dique_enferrujado": return "Comportas antigas tremendo sobre agua eletrica.";
        case "arena_poeira": return "Arena seca, poeira girando e pedras gastas.";
    }

    var _cave = demo_rota_tem_bioma(_rota, "caverna") || demo_rota_tem_bioma(_rota, "pedra");
    var _night = demo_rota_tem_bioma(_rota, "sombrio") || demo_rota_tem_bioma(_rota, "fantasma");
    var _ice = demo_rota_tem_bioma(_rota, "gelo");
    var _fire = demo_rota_tem_bioma(_rota, "fogo");
    var _water = demo_rota_tem_bioma(_rota, "agua");
    var _metal = demo_rota_tem_bioma(_rota, "aco") || demo_rota_tem_bioma(_rota, "eletrico");
    var _forest = demo_rota_tem_bioma(_rota, "grama") || demo_rota_tem_bioma(_rota, "inseto");

    if (_ice) return "Frio intenso, neblina baixa e passos abafados.";
    if (_fire) return "Calor subindo do chao e pedras incandescentes.";
    if (_night) return "Sombras longas, silencio pesado e olhos na mata.";
    if (_cave) return "Pedras soltas, paredes estreitas e eco distante.";
    if (_metal) return "Sucata viva, faiscas e maquinas fora de ritmo.";
    if (_water) return "Agua cortando a trilha e vento umido no rosto.";
    if (_forest) return "Mato alto, flores estranhas e movimento nas folhas.";

    return _rota.Descricao;
}

function demo_rota_inicio_mensagem(_destino_index, _rota_info, _encontros, _faixa) {
    if (!is_struct(_rota_info)) {
        return "Destino: " + demo_cidade_nome(_destino_index) + "\nTrecho: rota instavel\nSelvagens: " + _faixa + "\nENTER ou clique para avancar.";
    }

    return "Destino: " + demo_cidade_nome(_destino_index) + "\n"
        + "Trecho: " + _rota_info.Nome + " - " + demo_rota_descricao_visual(_rota_info) + "\n"
        + "Selvagens: " + _faixa + " | Biomas: " + demo_rota_biomas_texto(_rota_info) + "\n"
        + "ENTER ou clique para avancar.";
}

function demo_rota_encontros_range_texto(_rota) {
    if (!is_struct(_rota)) {
        return "Gera encontros.";
    }

    if (_rota.MinEncontros == _rota.MaxEncontros) {
        return "Gera " + string(_rota.MinEncontros) + " encontros.";
    }

    return "Gera " + string(_rota.MinEncontros) + " a " + string(_rota.MaxEncontros) + " encontros.";
}

function demo_rota_id_ja_escolhido(_controller, _route_id, _except_block) {
    if (!instance_exists(_controller) || !is_array(_controller.rota_escolhas)) {
        return false;
    }

    for (var _i = 0; _i < array_length(_controller.rota_escolhas); _i += 1) {
        if (_i == _except_block) {
            continue;
        }

        if (_controller.rota_escolhas[_i] == _route_id) {
            return true;
        }
    }

    return false;
}

function demo_rota_bioma_overlap(_a, _b) {
    if (!is_struct(_a) || !is_struct(_b) || !is_array(_a.Biomas) || !is_array(_b.Biomas)) {
        return 0;
    }

    var _overlap = 0;

    for (var _i = 0; _i < array_length(_a.Biomas); _i += 1) {
        for (var _j = 0; _j < array_length(_b.Biomas); _j += 1) {
            if (_a.Biomas[_i] == _b.Biomas[_j]) {
                _overlap += 1;
                break;
            }
        }
    }

    return _overlap;
}

function demo_rota_array_push_unica(_array, _rota) {
    if (!is_struct(_rota)) {
        return _array;
    }

    for (var _i = 0; _i < array_length(_array); _i += 1) {
        if (is_struct(_array[_i]) && _array[_i].ID == _rota.ID) {
            return _array;
        }
    }

    array_push(_array, _rota);
    return _array;
}

// Sorteios desta funcao sao deterministicos no Desafio Diario.
function demo_rota_draft_criar(_controller, _block_index, _rotas) {
    var _escopo = diario_escopo("draft_rota:" + string(_block_index));
    var _resultado = demo_rota_draft_criar_base(_controller, _block_index, _rotas);
    diario_escopo_fim(_escopo);
    return _resultado;
}

function demo_rota_draft_criar_base(_controller, _block_index, _rotas) {
    var _candidatas = [];
    var _fallback = [];
    var _escolhida_atual = _controller.rota_escolhas[_block_index];

    for (var _i = 0; _i < array_length(_rotas); _i += 1) {
        var _rota = _rotas[_i];

        if (!is_struct(_rota)) {
            continue;
        }

        if (_rota.ID == _escolhida_atual) {
            _fallback = demo_rota_array_push_unica(_fallback, _rota);
        } else if (!demo_rota_id_ja_escolhido(_controller, _rota.ID, _block_index)) {
            _candidatas = demo_rota_array_push_unica(_candidatas, _rota);
        } else {
            _fallback = demo_rota_array_push_unica(_fallback, _rota);
        }
    }

    array_shuffle(_candidatas);
    array_shuffle(_fallback);

    var _draft = [];

    if (_escolhida_atual != "") {
        for (var _chosen_i = 0; _chosen_i < array_length(_rotas); _chosen_i += 1) {
            if (is_struct(_rotas[_chosen_i]) && _rotas[_chosen_i].ID == _escolhida_atual) {
                _draft = demo_rota_array_push_unica(_draft, _rotas[_chosen_i]);
                break;
            }
        }
    }

    if (array_length(_candidatas) > 0 && array_length(_draft) < 2) {
        _draft = demo_rota_array_push_unica(_draft, _candidatas[0]);
    }

    var _best_index = -1;
    var _best_score = -100000;

    for (var _cand_i = 0; _cand_i < array_length(_candidatas); _cand_i += 1) {
        var _cand = _candidatas[_cand_i];

        if (array_length(_draft) > 0 && _cand.ID == _draft[0].ID) {
            continue;
        }

        var _score = irandom(30);

        if (array_length(_draft) > 0) {
            _score += (3 - demo_rota_bioma_overlap(_draft[0], _cand)) * 20;
        }

        if (_score > _best_score) {
            _best_score = _score;
            _best_index = _cand_i;
        }
    }

    if (_best_index >= 0 && array_length(_draft) < 2) {
        _draft = demo_rota_array_push_unica(_draft, _candidatas[_best_index]);
    }

    for (var _fb_i = 0; _fb_i < array_length(_fallback) && array_length(_draft) < 2; _fb_i += 1) {
        _draft = demo_rota_array_push_unica(_draft, _fallback[_fb_i]);
    }

    return _draft;
}

function demo_rota_draft_get(_controller, _block_index) {
    if (!instance_exists(_controller)) {
        return [];
    }

    if (_block_index < 0 || _block_index >= array_length(_controller.rota_blocos_db)) {
        return [];
    }

    var _rotas = _controller.rota_blocos_db[_block_index];
    var _draft_salvo = _controller.rota_drafts[_block_index];

    if (array_length(_rotas) <= 2) {
        _controller.rota_drafts[_block_index] = _rotas;
        return _rotas;
    }

    if (is_array(_draft_salvo) && _controller.rota_escolhas[_block_index] == "") {
        for (var _saved_i = 0; _saved_i < array_length(_draft_salvo); _saved_i += 1) {
            if (is_struct(_draft_salvo[_saved_i]) && demo_rota_id_ja_escolhido(_controller, _draft_salvo[_saved_i].ID, _block_index)) {
                _controller.rota_drafts[_block_index] = undefined;
                break;
            }
        }
    }

    if (!is_array(_controller.rota_drafts[_block_index])) {
        _controller.rota_drafts[_block_index] = demo_rota_draft_criar(_controller, _block_index, _rotas);
    }

    return _controller.rota_drafts[_block_index];
}

function demo_rota_draft_visivel_get(_controller, _block_index, _exclude_route_id) {
    if (!instance_exists(_controller)) {
        return [];
    }

    var _base = demo_rota_draft_get(_controller, _block_index);
    var _result = [];

    for (var _i = 0; _i < array_length(_base); _i += 1) {
        var _rota = _base[_i];

        if (!is_struct(_rota) || (_exclude_route_id != "" && _rota.ID == _exclude_route_id)) {
            continue;
        }

        _result = demo_rota_array_push_unica(_result, _rota);
    }

    if (_block_index < 0 || _block_index >= array_length(_controller.rota_blocos_db)) {
        return _result;
    }

    var _pool = _controller.rota_blocos_db[_block_index];
    var _candidatas = [];

    for (var _pool_i = 0; _pool_i < array_length(_pool); _pool_i += 1) {
        var _cand = _pool[_pool_i];

        if (!is_struct(_cand) || (_exclude_route_id != "" && _cand.ID == _exclude_route_id)) {
            continue;
        }

        if (demo_rota_id_ja_escolhido(_controller, _cand.ID, _block_index)) {
            continue;
        }

        _candidatas = demo_rota_array_push_unica(_candidatas, _cand);
    }

    array_shuffle(_candidatas);

    while (array_length(_result) < 2 && array_length(_candidatas) > 0) {
        var _best_i = 0;
        var _best_score = -100000;

        for (var _cand_i = 0; _cand_i < array_length(_candidatas); _cand_i += 1) {
            var _score = irandom(40);

            for (var _res_i = 0; _res_i < array_length(_result); _res_i += 1) {
                _score += (3 - demo_rota_bioma_overlap(_result[_res_i], _candidatas[_cand_i])) * 18;
            }

            if (_score > _best_score) {
                _best_score = _score;
                _best_i = _cand_i;
            }
        }

        _result = demo_rota_array_push_unica(_result, _candidatas[_best_i]);
        array_delete(_candidatas, _best_i, 1);
    }

    return _result;
}

function demo_rota_saida_destino_get(_controller) {
    if (!instance_exists(_controller)) {
        return 0;
    }

    var _last_city = array_length(_controller.kanto_cidades) - 1;
    var _destino = variable_instance_exists(_controller, "saida_destino_index") ? _controller.saida_destino_index : -1;

    if (_destino < 0) {
        _destino = min(_controller.cidade_index + 1, _last_city);
    }

    return clamp(_destino, 0, _last_city);
}

function demo_rota_saida_opcoes_get(_controller, _destino_index) {
    if (!instance_exists(_controller)) {
        return [];
    }

    var _block = demo_rota_block_index(_controller.cidade_index, _destino_index);

    if (_destino_index < _controller.cidade_index) {
        var _rota_back = demo_rota_escolhida_get(_controller, _block);

        if (!is_struct(_rota_back)) {
            var _back_draft = demo_rota_draft_get(_controller, _block);

            if (array_length(_back_draft) > 0) {
                _rota_back = _back_draft[0];
                demo_rota_escolher(_controller, _block, _rota_back);
            }
        }

        return is_struct(_rota_back) ? [_rota_back] : [];
    }

    if (_destino_index > _controller.cidade_index) {
        return demo_rota_draft_visivel_get(_controller, _block, "");
    }

    return [];
}

function demo_rota_escolhida_get(_controller, _block_index) {
    if (!instance_exists(_controller)) {
        return undefined;
    }

    if (_block_index < 0 || _block_index >= array_length(_controller.rota_escolhas)) {
        return undefined;
    }

    var _chosen_id = _controller.rota_escolhas[_block_index];

    if (_chosen_id == "") {
        return undefined;
    }

    var _draft = demo_rota_draft_get(_controller, _block_index);

    for (var _i = 0; _i < array_length(_draft); _i += 1) {
        if (_draft[_i].ID == _chosen_id) {
            return _draft[_i];
        }
    }

    return undefined;
}

function demo_rota_escolher(_controller, _block_index, _rota) {
    if (!instance_exists(_controller) || !is_struct(_rota)) {
        return;
    }

    _controller.rota_escolhas[_block_index] = _rota.ID;
}

function demo_rota_opcao_ativa(_controller, _block_index, _rota, _destino_index) {
    if (!instance_exists(_controller) || !is_struct(_rota)) {
        return false;
    }

    if (_destino_index < _controller.cidade_index) {
        return _controller.rota_escolhas[_block_index] == _rota.ID;
    }

    if (_controller.rota_escolhas[_block_index] == "") {
        return true;
    }

    return _controller.rota_escolhas[_block_index] == _rota.ID;
}

// Sorteios desta funcao sao deterministicos no Desafio Diario.
function demo_rota_iniciar(_destino_index, _rota_info) {
    var _escopo = diario_escopo("rota:" + string(cidade_index) + ">" + string(_destino_index) + ":" + (is_struct(_rota_info) ? _rota_info.ID : ""));
    var _resultado = demo_rota_iniciar_base(_destino_index, _rota_info);
    diario_escopo_fim(_escopo);
    return _resultado;
}

function demo_rota_iniciar_base(_destino_index, _rota_info) {
    rota_origem_index = cidade_index;
    rota_destino_index = clamp(_destino_index, 0, array_length(kanto_cidades) - 1);
    rota_atual = _rota_info;
    route_steps = 0;
    route_steps_needed = is_struct(_rota_info) ? irandom_range(_rota_info.MinEncontros, _rota_info.MaxEncontros) : demo_rota_encontros(cidade_index, rota_destino_index);
    route_trainer_encountered = false;
    route_trainer_step = -1;

    if (random(1) < demo_rota_trainer_route_chance(rota_origem_index, rota_destino_index)) {
        var _trainer_max_step = max(1, route_steps_needed);

        if (demo_cidade_tem_ginasio(rota_destino_index) && !demo_cidade_ginasio_vencido(rota_destino_index)) {
            _trainer_max_step = max(1, route_steps_needed - 1);
        }

        route_trainer_step = irandom_range(1, _trainer_max_step);
    }

    estado_demo = DemoEstado.ROTA;
    var _faixa = demo_rota_level_range_texto(demo_rota_block_index(rota_origem_index, rota_destino_index), false);
    message = demo_rota_inicio_mensagem(rota_destino_index, _rota_info, route_steps_needed, _faixa);
}

function demo_rota_encontros(_origem_index, _destino_index) {
    var _a = min(_origem_index, _destino_index);
    var _b = max(_origem_index, _destino_index);

    if (_a == 0 && _b == 1) return irandom_range(3, 5); // Cidade 0 -> 1.
    if (_a == 1 && _b == 2) return 4; // Cidade 1 -> 2.
    if (_a == 2 && _b == 3) return 4; // Cidade 2 -> 3.
    if (_a == 3 && _b == 4) return 4; // Cidade 3 -> 4.
    if (_a == 4 && _b == 5) return 4; // Cidade 4 -> 5.
    if (_a == 5 && _b == 6) return 3; // Cidade 5 -> 6 (final).

    return irandom_range(3, 4);
}

function demo_rota_encontros_texto(_origem_index, _destino_index) {
    var _a = min(_origem_index, _destino_index);
    var _b = max(_origem_index, _destino_index);

    if (_a == 0 && _b == 1) return "Gera 3 a 5 encontros.";

    var _qtd = demo_rota_encontros(_origem_index, _destino_index);
    return "Gera " + string(_qtd) + " encontros.";
}

function demo_rota_enemy_level(_origem_index, _destino_index) {
    var _block = demo_rota_block_index(_origem_index, _destino_index);
    var _range = demo_rota_level_range(_block, false);
    return irandom_range(_range[0], _range[1]);
}

function demo_pokemon_tags_contem(_pokemon, _tags) {
    if (!is_struct(_pokemon) || !variable_struct_exists(_pokemon, "BirthTags") || !is_array(_pokemon.BirthTags) || !is_array(_tags)) {
        return false;
    }

    for (var _i = 0; _i < array_length(_pokemon.BirthTags); _i += 1) {
        for (var _t = 0; _t < array_length(_tags); _t += 1) {
            if (_pokemon.BirthTags[_i] == _tags[_t]) {
                return true;
            }
        }
    }

    return false;
}

function demo_rota_enemy_fallback_ids(_block_index) {
    // Sem lista fixa: usa criaturas em estagio inicial, das mais comuns as mais raras.
    var _limite = _block_index <= 0 ? PokemonRaridade.COMMON : (_block_index == 1 ? PokemonRaridade.UNCOMMON : PokemonRaridade.RARE);
    var _ids = criatura_ids();
    var _resultado = [];

    for (var _i = 0; _i < array_length(_ids); _i += 1) {
        var _info = criatura_info(_ids[_i]);

        if (is_struct(_info) && _info.EvoluiDe <= 0 && _info.Raridade <= _limite) {
            array_push(_resultado, _ids[_i]);
        }
    }

    if (array_length(_resultado) <= 0) {
        _resultado = conteudo_pacote_iniciais("base");
    }

    return _resultado;
}

function demo_rota_enemy_permitido(_pokemon, _rota_info, _level, _contexto) {
    if (!demo_pokemon_tags_contem(_pokemon, _rota_info.Biomas)) {
        return false;
    }

    var _block = 0;

    if (variable_instance_exists(id, "rota_origem_index") && variable_instance_exists(id, "rota_destino_index")) {
        _block = demo_rota_block_index(rota_origem_index, rota_destino_index);
    }

    var _raridade = variable_struct_exists(_pokemon, "RaridadePadrao") ? _pokemon.RaridadePadrao : PokemonRaridade.COMMON;
    var _wild_min = variable_struct_exists(_pokemon, "WildMinLevel") ? _pokemon.WildMinLevel : pokemon_wild_min_level_atualizar(_pokemon);
    var _nivel_tolerado = _contexto == "treinador" ? _level + 1 : _level;

    if (_nivel_tolerado < _wild_min) {
        return false;
    }

    if (_contexto == "selvagem") {
        if (_block <= 0) {
            if (_raridade != PokemonRaridade.COMMON) {
                return false;
            }

            if (_pokemon.Tipo2 != PokemonTipo.NONE && _pokemon.Tipo1 != PokemonTipo.NORMAL) {
                return false;
            }
        }

        if (_level <= 3 && _raridade > PokemonRaridade.RARE) {
            return false;
        }
    }

    return true;
}

function demo_rota_enemy_weight(_pokemon, _level, _contexto) {
    if (!is_struct(_pokemon)) {
        return 0;
    }

    var _min_level = variable_struct_exists(_pokemon, "WildMinLevel") ? _pokemon.WildMinLevel : pokemon_wild_min_level_atualizar(_pokemon);

    if (_level < _min_level && _contexto != "treinador") {
        return 0;
    }

    var _raridade = variable_struct_exists(_pokemon, "RaridadePadrao") ? _pokemon.RaridadePadrao : PokemonRaridade.COMMON;
    var _diff = max(0, _level - _min_level);
    var _peso = 100 + min(40, _diff * 8);

    if (_min_level >= 23) {
        _peso = 7 + min(16, _diff * 3);
    } else if (_min_level >= 18) {
        _peso = 14 + min(22, _diff * 4);
    } else if (_min_level >= 10) {
        _peso = 32 + min(28, _diff * 5);
    } else if (_min_level >= 6) {
        _peso = 58 + min(28, _diff * 6);
    }

    switch (_raridade) {
        case PokemonRaridade.UNCOMMON:
            _peso *= 0.78;
            break;
        case PokemonRaridade.RARE:
            _peso *= 0.52;
            break;
        case PokemonRaridade.EPIC:
            _peso *= 0.24;
            break;
        case PokemonRaridade.LEGENDARY:
        case PokemonRaridade.ULTRA_RARE:
            _peso *= 0.05;
            break;
    }

    if (_contexto == "treinador") {
        _peso *= 1.20;
    }

    return max(1, floor(_peso));
}

function demo_rota_enemy_id(_rota_info) {
    var _level = argument_count >= 2 ? argument[1] : 1;
    var _contexto = argument_count >= 3 ? argument[2] : "selvagem";
    var _block = 0;

    if (variable_instance_exists(id, "rota_origem_index") && variable_instance_exists(id, "rota_destino_index")) {
        _block = demo_rota_block_index(rota_origem_index, rota_destino_index);
    }

    if (!is_struct(_rota_info) || !is_array(_rota_info.Biomas) || !variable_global_exists("pokedex")) {
        var _fallback_ids = demo_rota_enemy_fallback_ids(_block);
        return _fallback_ids[irandom(array_length(_fallback_ids) - 1)];
    }

    var _candidatos = [];
    var _peso_total = 0;

    var _ids_criaturas = criatura_ids();

    for (var _idx = 0; _idx < array_length(_ids_criaturas); _idx += 1) {
        var _id = _ids_criaturas[_idx];
        var _base = pokemon_db_get(global.pokedex, _id);

        if (demo_rota_enemy_permitido(_base, _rota_info, _level, _contexto)) {
            var _peso = demo_rota_enemy_weight(_base, _level, _contexto);

            if (_peso > 0) {
                array_push(_candidatos, { ID: _id, Peso: _peso });
                _peso_total += _peso;
            }
        }
    }

    if (_peso_total > 0 && array_length(_candidatos) > 0) {
        var _roll = irandom(max(0, _peso_total - 1)) + 1;

        for (var _i = 0; _i < array_length(_candidatos); _i += 1) {
            _roll -= _candidatos[_i].Peso;

            if (_roll <= 0) {
                return _candidatos[_i].ID;
            }
        }

        return _candidatos[array_length(_candidatos) - 1].ID;
    }

    var _fallback_ids = demo_rota_enemy_fallback_ids(_block);
    var _fallback_validos = [];

    for (var _fb = 0; _fb < array_length(_fallback_ids); _fb += 1) {
        var _fallback_id = _fallback_ids[_fb];
        var _fallback_base = pokemon_db_get(global.pokedex, _fallback_id);

        if (demo_rota_enemy_permitido(_fallback_base, _rota_info, _level, _contexto)) {
            array_push(_fallback_validos, _fallback_id);
        }
    }

    if (array_length(_fallback_validos) > 0) {
        return _fallback_validos[irandom(array_length(_fallback_validos) - 1)];
    }

    return _fallback_ids[irandom(array_length(_fallback_ids) - 1)];
}

// Gera e inicia o proximo encontro selvagem da rota atual.
function demo_rota_encontro_selvagem_iniciar(_controller) {
    with (_controller) {
        var _escopo = diario_escopo("selvagem:" + string(rota_origem_index) + ">" + string(rota_destino_index) + ":" + string(route_steps));
        var _enemy_level = demo_rota_enemy_level(rota_origem_index, rota_destino_index);
        var _enemy_id = demo_rota_enemy_id(rota_atual, _enemy_level, "selvagem");
        enemy_pokemon_data = demo_criar_pokemon_data(_enemy_id, _enemy_level, true, true, true, "selvagem");
        diario_escopo_fim(_escopo);
        battle_context = "rota";
        demo_start_battle(id);
    }
}

function demo_rota_trainer_chance(_controller) {
    if (!instance_exists(_controller)) {
        return 0.25;
    }

    return demo_rota_trainer_route_chance(_controller.rota_origem_index, _controller.rota_destino_index);
}

function demo_rota_trainer_route_chance(_origem_index, _destino_index) {
    var _block = demo_rota_block_index(_origem_index, _destino_index);
    var _meta_bonus = variable_global_exists("demo_meta_trainer_chance_bonus") ? global.demo_meta_trainer_chance_bonus : 0;

    if (_block <= 0) {
        return clamp(0.18 + _meta_bonus, 0.18, 0.55);
    }

    return clamp(0.26 + (_block * 0.035) + _meta_bonus, 0.26, 0.65);
}

function demo_rota_trainer_classe(_rota_info, _block_index) {
    var _candidatos = [];

    if (_block_index <= 0) {
        return choose(
            { Nome: "Jovem Treinador", Sprite: "jovem.png" },
            { Nome: "Estudante", Sprite: "estudante.png" },
            { Nome: "Excursionista", Sprite: "excursionista.png" },
            { Nome: "Jardineira", Sprite: "jardineira.png" }
        );
    }

    if (is_struct(_rota_info) && is_array(_rota_info.Biomas)) {
        for (var _i = 0; _i < array_length(_rota_info.Biomas); _i += 1) {
            var _tag = _rota_info.Biomas[_i];

            switch (_tag) {
                case "inseto":
                    array_push(_candidatos, { Nome: "Colecionador de Insetos", Sprite: "colecionador.png" });
                    break;
                case "grama":
                case "fazenda":
                    array_push(_candidatos, { Nome: "Jardineira", Sprite: "jardineira.png" });
                    break;
                case "veneno":
                    array_push(_candidatos, { Nome: "Motoqueiro", Sprite: "motoqueiro.png" });
                    break;
                case "agua":
                    array_push(_candidatos, { Nome: choose("Nadador", "Marinheira"), Sprite: "nadador.png" });
                    break;
                case "fogo":
                    array_push(_candidatos, { Nome: "Campista", Sprite: "campista.png" });
                    break;
                case "eletrico":
                case "aco":
                    array_push(_candidatos, { Nome: choose("Engenheiro", "Cientista"), Sprite: "engenheiro.png" });
                    break;
                case "caverna":
                case "pedra":
                case "terra":
                    array_push(_candidatos, { Nome: choose("Montanhista", "Arqueologo"), Sprite: "montanhista.png" });
                    break;
                case "fada":
                case "psiquico":
                    array_push(_candidatos, { Nome: "Vidente", Sprite: "vidente.png" });
                    break;
                case "fantasma":
                    array_push(_candidatos, { Nome: "Medium", Sprite: "medium.png" });
                    break;
                case "gelo":
                case "dragao":
                    array_push(_candidatos, { Nome: "Veterano", Sprite: "veterano.png" });
                    break;
                case "voador":
                    array_push(_candidatos, { Nome: "Falcoeira", Sprite: "falcoeira.png" });
                    break;
                case "luta":
                    array_push(_candidatos, { Nome: "Lutadora de Rua", Sprite: "lutadora.png" });
                    break;
                case "sombrio":
                    array_push(_candidatos, { Nome: "Agente do Eclipse", Sprite: "agente_eclipse.png" });
                    break;
                case "normal":
                    array_push(_candidatos, { Nome: choose("Jovem Treinador", "Estudante", "Excursionista"), Sprite: "jovem.png" });
                    break;
            }
        }
    }

    if (array_length(_candidatos) <= 0) {
        if (_block_index >= 4) {
            array_push(_candidatos, { Nome: "Veterano", Sprite: "veterano.png" });
        } else {
            array_push(_candidatos, { Nome: choose("Jovem Treinador", "Estudante"), Sprite: "jovem.png" });
        }
    }

    return _candidatos[irandom(array_length(_candidatos) - 1)];
}

function demo_rota_trainer_level(_controller) {
    if (!instance_exists(_controller) || !is_struct(_controller.rota_atual)) {
        return 5;
    }

    var _block = demo_rota_block_index(_controller.rota_origem_index, _controller.rota_destino_index);
    var _range = demo_rota_level_range(_block, true);
    return irandom_range(_range[0], _range[1]);
}

function demo_rota_trainer_party_size(_controller) {
    if (!instance_exists(_controller)) {
        return 2;
    }

    var _block = demo_rota_block_index(_controller.rota_origem_index, _controller.rota_destino_index);

    if (_block <= 0) {
        return 2;
    }

    if (_block <= 2) {
        return irandom_range(2, 3);
    }

    return irandom_range(3, 4);
}

function demo_rota_trainer_party_criar(_controller) {
    var _party = [];

    if (!instance_exists(_controller)) {
        return _party;
    }

    var _count = demo_rota_trainer_party_size(_controller);

    for (var _i = 0; _i < _count; _i += 1) {
        var _level = demo_rota_trainer_level(_controller);
        var _enemy_id = demo_rota_enemy_id(_controller.rota_atual, _level, "treinador");
        var _pokemon = demo_criar_pokemon_data(_enemy_id, _level, true, false, true, "treinador");

        if (is_struct(_pokemon)) {
            array_push(_party, _pokemon);
        }
    }

    return _party;
}

// Sorteios desta funcao sao deterministicos no Desafio Diario.
function demo_rota_trainer_iniciar(_controller) {
    var _escopo = diario_escopo("treinador:" + string(_controller.rota_origem_index) + ">" + string(_controller.rota_destino_index));
    var _resultado = demo_rota_trainer_iniciar_base(_controller);
    diario_escopo_fim(_escopo);
    return _resultado;
}

function demo_rota_trainer_iniciar_base(_controller) {
    if (!instance_exists(_controller)) {
        return false;
    }

    var _block = demo_rota_block_index(_controller.rota_origem_index, _controller.rota_destino_index);
    var _party = demo_rota_trainer_party_criar(_controller);

    if (array_length(_party) <= 0) {
        return false;
    }

    _controller.route_trainer_data = demo_rota_trainer_classe(_controller.rota_atual, _block);
    _controller.trainer_party = _party;
    _controller.trainer_party_index = 0;
    _controller.enemy_pokemon_data = _party[0];
    _controller.battle_context = "treinador";
    demo_start_battle(_controller);
    return true;
}

function demo_trainer_tem_proximo(_controller) {
    if (!instance_exists(_controller) || _controller.battle_context != "treinador" || !is_array(_controller.trainer_party)) {
        return false;
    }

    return _controller.trainer_party_index + 1 < array_length(_controller.trainer_party);
}

function demo_trainer_enviar_proximo(_controller) {
    if (!demo_trainer_tem_proximo(_controller)) {
        return false;
    }

    if (instance_exists(_controller.enemy_inst)) {
        _controller.enemy_inst.vivo = false;
        _controller.enemy_inst.batalha_ativo = false;
        instance_destroy(_controller.enemy_inst);
    }

    _controller.trainer_party_index += 1;
    _controller.enemy_pokemon_data = _controller.trainer_party[_controller.trainer_party_index];
    _controller.enemy_inst = pokemon_batalha_criar(room_width * 0.75, room_height * 0.69, _controller.enemy_pokemon_data, "Instances", LadoBatalha.INIMIGO);
    _controller.enemy_inst.visible = false;

    if (instance_exists(_controller.battle_manager)) {
        _controller.battle_manager.inimigos_campo = [_controller.enemy_inst];
    }

    _controller.message = _controller.battle_trainer_name + " enviou " + _controller.enemy_pokemon_data.Nome + "!";
    battle_log_force(_controller.message);
    return true;
}

function demo_item_drop_append(_drops, _id_item, _qtd) {
    if (!is_array(_drops) || _qtd <= 0 || _id_item == "") {
        return _drops;
    }

    for (var _i = 0; _i < array_length(_drops); _i += 1) {
        if (is_struct(_drops[_i]) && _drops[_i].ID == _id_item) {
            var _drop = _drops[_i];
            _drop.Qtd += _qtd;
            _drops[_i] = _drop;
            return _drops;
        }
    }

    array_push(_drops, { ID: _id_item, Qtd: _qtd });
    return _drops;
}

function demo_trainer_drop_ball_id(_block_index) {
    if (_block_index >= 4) {
        return random(1) < 0.58 ? "ultra_ball" : "great_ball";
    }

    if (_block_index >= 2) {
        return random(1) < 0.55 ? "great_ball" : "pokebola";
    }

    return random(1) < 0.18 ? "great_ball" : "pokebola";
}

function demo_trainer_drop_heal_id(_block_index) {
    if (_block_index >= 5) {
        return choose("hyper_potion", "full_restore", "full_heal");
    }

    if (_block_index >= 3) {
        return choose("super_potion", "hyper_potion", "full_heal");
    }

    if (_block_index >= 1) {
        return choose("potion", "super_potion", "antidote", "burn_heal");
    }

    return choose("potion", "antidote");
}

// Sorteios desta funcao sao deterministicos no Desafio Diario.
function demo_trainer_drops_gerar(_controller) {
    var _escopo = diario_escopo("drops:" + string(_controller.rota_origem_index) + ">" + string(_controller.rota_destino_index) + ":" + string(_controller.route_steps));
    var _resultado = demo_trainer_drops_gerar_base(_controller);
    diario_escopo_fim(_escopo);
    return _resultado;
}

function demo_trainer_drops_gerar_base(_controller) {
    var _drops = [];

    if (!instance_exists(_controller)) {
        return _drops;
    }

    var _block = demo_rota_block_index(_controller.rota_origem_index, _controller.rota_destino_index);

    if (random(1) < clamp(0.46 + (_block * 0.04), 0.46, 0.66)) {
        _drops = demo_item_drop_append(_drops, demo_trainer_drop_ball_id(_block), irandom_range(1, _block >= 3 ? 2 : 1));
    }

    if (random(1) < clamp(0.34 + (_block * 0.035), 0.34, 0.52)) {
        _drops = demo_item_drop_append(_drops, demo_trainer_drop_heal_id(_block), 1);
    }

    if (_block >= 2 && random(1) < 0.12) {
        _drops = demo_item_drop_append(_drops, choose("oran_berry", "cheri_berry", "leppa_berry"), 1);
    }

    if (random(1) < clamp(0.02 + (_block * 0.006), 0.02, 0.06)) {
        _drops = demo_item_drop_append(_drops, "rare_candy", 1);
    }

    if (random(1) < 0.0015) {
        _drops = demo_item_drop_append(_drops, "master_ball", 1);
    }

    for (var _i = 0; _i < array_length(_drops); _i += 1) {
        if (is_struct(_drops[_i])) {
            demo_inventario_adicionar(_controller.inventario, _drops[_i].ID, _drops[_i].Qtd);
        }
    }

    return _drops;
}

function demo_exp_base_por_level(_level) {
    return 36 + (_level * 14);
}

function demo_exp_recompensa(_pokemon_vencedor, _enemy_level, _tipo_encontro, _capturado) {
    var _mult = 1.0;

    switch (_tipo_encontro) {
        case "captura": _mult = 1.5; break;
        case "treinador": _mult = 2.0; break;
        case "rocket": _mult = 3.0; break;
        default: _mult = 1.0; break;
    }

    if (_capturado) {
        _mult = max(_mult, 1.5);
    }

    var _catchup = 1.0;

    if (is_struct(_pokemon_vencedor) && _pokemon_vencedor.Level < _enemy_level - 4) {
        _catchup = 4.0;
    }

    return floor(demo_exp_base_por_level(_enemy_level) * _mult * _catchup);
}

function demo_cidade_chegar(_index) {
    cidade_index = clamp(_index, 0, array_length(kanto_cidades) - 1);
    cidade_nome = demo_cidade_nome(cidade_index);
    route_steps = 0;
    rota_destino_index = cidade_index;
    estado_demo = DemoEstado.CIDADE;
    message = "Voce chegou a " + cidade_nome + ".";
}

function demo_gym_enemy_id(_cidade_index) {
    var _cidades = variable_instance_exists(id, "kanto_cidades") ? kanto_cidades : demo_kanto_cidades_criar();

    if (_cidade_index >= 0 && _cidade_index < array_length(_cidades) && _cidades[_cidade_index].LiderCriaturaID > 0) {
        return _cidades[_cidade_index].LiderCriaturaID;
    }

    var _fallback_ids = conteudo_pacote_iniciais("base");
    return _fallback_ids[irandom(array_length(_fallback_ids) - 1)];
}

function demo_gym_enemy_level(_cidade_index) {
    var _cidades = variable_instance_exists(id, "kanto_cidades") ? kanto_cidades : demo_kanto_cidades_criar();

    if (_cidade_index >= 0 && _cidade_index < array_length(_cidades) && _cidades[_cidade_index].LiderNivel > 0) {
        return _cidades[_cidade_index].LiderNivel;
    }

    return clamp(5 + (_cidade_index * 4), 5, 30);
}

function demo_dialogo_mae_inicial() {
    var _meta = variable_global_exists("demo_meta_progresso") && is_struct(global.demo_meta_progresso) ? global.demo_meta_progresso : demo_meta_default();
    var _valor = 100 + demo_meta_dinheiro_inicial_bonus(_meta);
    return "Mae: Eu preparei uma pequena ajuda para sua jornada. Leve estes " + string(_valor) + " M$ e compre suprimentos antes de sair pela Trilha da Alvorada.";
}

function demo_dialogo_mae_retorno() {
    return "Mae: Cuide bem do seu monstro. Se precisar de suprimentos, passe no Mercado antes de seguir viagem.";
}

function demo_dialogo_professor_carvalho() {
    var _prof = conteudo_mundo_texto("professor", "Prof. Sabia");
    var _vilao = conteudo_mundo_texto("equipe_vila", "Sindicato Eclipse");
    var _chefe = conteudo_mundo_texto("chefe_final", "Aeonox");
    var _regiao = conteudo_mundo_texto("regiao", "Vale de Cronaria");
    return _prof + ": O " + _vilao + " libertou " + _chefe + ", e o tempo se rasgou sobre o " + _regiao + ". Monstros de outras eras estao atravessando as fendas. Leve este parceiro, venca os lideres e feche o rasgo antes que ele engula tudo.";
}

function demo_trainer_filename(_leader_name) {
    var _cidades = variable_instance_exists(id, "kanto_cidades") ? kanto_cidades : demo_kanto_cidades_criar();

    for (var _i = 0; _i < array_length(_cidades); _i += 1) {
        if (_cidades[_i].Lider == _leader_name) {
            return _cidades[_i].SpriteLider;
        }
    }

    return "";
}

function demo_trainer_sprite_carregar(_leader_name) {
    var _filename = demo_trainer_filename(_leader_name);
    var _sprite = -1;

    if (_filename != "") {
        _sprite = demo_asset_sprite("datafiles/sprites/treinadores/" + _filename);
    }

    if (!sprite_exists(_sprite)) {
        _sprite = placeholder_treinador_sprite(_leader_name);
    }

    return _sprite;
}

function demo_trainer_sprite_carregar_generico(_filename) {
    var _sprite = -1;

    if (is_string(_filename) && _filename != "") {
        _sprite = demo_asset_sprite("datafiles/sprites/treinadores/" + _filename);
    }

    if (!sprite_exists(_sprite)) {
        _sprite = placeholder_treinador_sprite(_filename);
    }

    return _sprite;
}

function demo_rota_tem_bioma(_rota, _bioma) {
    if (!is_struct(_rota) || !is_array(_rota.Biomas)) {
        return false;
    }

    for (var _i = 0; _i < array_length(_rota.Biomas); _i += 1) {
        if (_rota.Biomas[_i] == _bioma) {
            return true;
        }
    }

    return false;
}

function demo_rota_visual_tema(_rota) {
    if (is_struct(_rota) && variable_struct_exists(_rota, "ID") && _rota.ID == "rota_1") {
        return "grama";
    }

    var _agua = demo_rota_tem_bioma(_rota, "agua");
    var _voador = demo_rota_tem_bioma(_rota, "voador");
    var _veneno = demo_rota_tem_bioma(_rota, "veneno");
    var _grama = demo_rota_tem_bioma(_rota, "grama");
    var _inseto = demo_rota_tem_bioma(_rota, "inseto");
    var _sombrio = demo_rota_tem_bioma(_rota, "sombrio");
    var _fantasma = demo_rota_tem_bioma(_rota, "fantasma");
    var _gelo = demo_rota_tem_bioma(_rota, "gelo");
    var _fogo = demo_rota_tem_bioma(_rota, "fogo");
    var _eletrico = demo_rota_tem_bioma(_rota, "eletrico");
    var _aco = demo_rota_tem_bioma(_rota, "aco");
    var _caverna = demo_rota_tem_bioma(_rota, "caverna");
    var _pedra = demo_rota_tem_bioma(_rota, "pedra");
    var _terra = demo_rota_tem_bioma(_rota, "terra");
    var _dragao = demo_rota_tem_bioma(_rota, "dragao");
    var _psiquico = demo_rota_tem_bioma(_rota, "psiquico");

    if (_agua && (_voador || _veneno || _grama)) {
        return "floral";
    }

    if (_veneno && (_agua || _inseto || _sombrio)) {
        return "pantano";
    }

    if (_sombrio && (_fantasma || _inseto || _grama)) {
        return "floresta_noite";
    }

    if (_fantasma) {
        return "cemiterio";
    }

    if (_gelo) {
        return "gelo";
    }

    if (_fogo) {
        return "vulcao";
    }

    if (_eletrico || _aco) {
        return "sucata";
    }

    if (_caverna || _pedra || _terra || _dragao) {
        return "montanha";
    }

    if (_agua) {
        return "agua";
    }

    if (_grama || _inseto) {
        return "grama";
    }

    if (_psiquico) {
        return "ruinas";
    }

    return "grama";
}

function demo_draw_route_tree(_x, _y, _scale, _dark) {
    var _outline = _dark ? make_color_rgb(8, 16, 24) : make_color_rgb(22, 32, 24);
    var _trunk_dark = _dark ? make_color_rgb(42, 26, 38) : make_color_rgb(78, 42, 28);
    var _trunk = _dark ? make_color_rgb(82, 48, 52) : make_color_rgb(126, 70, 38);
    var _trunk_light = _dark ? make_color_rgb(118, 74, 66) : make_color_rgb(178, 104, 52);
    var _leaf_dark = _dark ? make_color_rgb(12, 44, 46) : make_color_rgb(22, 78, 42);
    var _leaf = _dark ? make_color_rgb(26, 82, 62) : make_color_rgb(50, 132, 54);
    var _leaf_mid = _dark ? make_color_rgb(48, 112, 72) : make_color_rgb(78, 158, 62);
    var _leaf_light = _dark ? make_color_rgb(74, 138, 82) : make_color_rgb(116, 190, 76);
    var _px = max(1, floor(4 * _scale));

    draw_set_alpha(0.30);
    draw_set_color(c_black);
    draw_ellipse(_x - 40 * _scale, _y - 8 * _scale, _x + 42 * _scale, _y + 10 * _scale, false);
    draw_set_alpha(1);

    draw_set_color(_outline);
    draw_rectangle(_x - 13 * _scale, _y - 70 * _scale, _x + 15 * _scale, _y + 4 * _scale, false);
    draw_rectangle(_x - 28 * _scale, _y - 66 * _scale, _x - 6 * _scale, _y - 54 * _scale, false);
    draw_rectangle(_x + 4 * _scale, _y - 70 * _scale, _x + 36 * _scale, _y - 58 * _scale, false);
    draw_set_color(_trunk_dark);
    draw_rectangle(_x - 9 * _scale, _y - 66 * _scale, _x + 11 * _scale, _y, false);
    draw_set_color(_trunk);
    draw_rectangle(_x - 5 * _scale, _y - 62 * _scale, _x + 7 * _scale, _y - 2 * _scale, false);
    draw_rectangle(_x - 23 * _scale, _y - 63 * _scale, _x - 5 * _scale, _y - 58 * _scale, false);
    draw_rectangle(_x + 7 * _scale, _y - 66 * _scale, _x + 31 * _scale, _y - 61 * _scale, false);
    draw_set_color(_trunk_light);
    draw_rectangle(_x - 2 * _scale, _y - 57 * _scale, _x + 2 * _scale, _y - 8 * _scale, false);
    draw_rectangle(_x + 7 * _scale, _y - 42 * _scale, _x + 10 * _scale, _y - 28 * _scale, false);
    draw_set_color(_trunk_dark);
    draw_line_width(_x - 8 * _scale, _y - 46 * _scale, _x - 12 * _scale, _y - 30 * _scale, max(1, 2 * _scale));
    draw_line_width(_x + 8 * _scale, _y - 58 * _scale, _x + 14 * _scale, _y - 48 * _scale, max(1, 2 * _scale));

    draw_set_color(_outline);
    draw_rectangle(_x - 62 * _scale, _y - 148 * _scale, _x + 58 * _scale, _y - 62 * _scale, false);
    draw_rectangle(_x - 78 * _scale, _y - 124 * _scale, _x + 72 * _scale, _y - 78 * _scale, false);
    draw_rectangle(_x - 44 * _scale, _y - 170 * _scale, _x + 38 * _scale, _y - 118 * _scale, false);
    draw_set_color(_leaf_dark);
    draw_rectangle(_x - 58 * _scale, _y - 144 * _scale, _x + 54 * _scale, _y - 66 * _scale, false);
    draw_rectangle(_x - 74 * _scale, _y - 120 * _scale, _x + 68 * _scale, _y - 82 * _scale, false);
    draw_rectangle(_x - 40 * _scale, _y - 166 * _scale, _x + 34 * _scale, _y - 122 * _scale, false);
    draw_set_color(_leaf);
    draw_rectangle(_x - 54 * _scale, _y - 140 * _scale, _x + 42 * _scale, _y - 86 * _scale, false);
    draw_rectangle(_x - 66 * _scale, _y - 116 * _scale, _x + 62 * _scale, _y - 90 * _scale, false);
    draw_rectangle(_x - 28 * _scale, _y - 162 * _scale, _x + 28 * _scale, _y - 126 * _scale, false);
    draw_set_color(_leaf_mid);
    draw_rectangle(_x - 40 * _scale, _y - 132 * _scale, _x + 14 * _scale, _y - 104 * _scale, false);
    draw_rectangle(_x + 16 * _scale, _y - 124 * _scale, _x + 52 * _scale, _y - 96 * _scale, false);
    draw_rectangle(_x - 54 * _scale, _y - 108 * _scale, _x - 18 * _scale, _y - 88 * _scale, false);
    draw_rectangle(_x - 18 * _scale, _y - 156 * _scale, _x + 18 * _scale, _y - 138 * _scale, false);
    draw_set_color(_leaf_light);
    draw_rectangle(_x - 34 * _scale, _y - 136 * _scale, _x - 12 * _scale, _y - 128 * _scale, false);
    draw_rectangle(_x + 22 * _scale, _y - 118 * _scale, _x + 42 * _scale, _y - 110 * _scale, false);
    draw_rectangle(_x - 8 * _scale, _y - 154 * _scale, _x + 12 * _scale, _y - 146 * _scale, false);

    draw_set_color(_outline);
    for (var _n = 0; _n < 10; _n += 1) {
        var _nx = _x + (((_n * 29) mod 122) - 61) * _scale;
        var _ny = _y - (78 + ((_n * 23) mod 78)) * _scale;
        draw_rectangle(_nx, _ny, _nx + _px, _ny + _px, false);
    }
}

function demo_draw_route_rock(_x, _y, _scale, _ice) {
    var _edge = make_color_rgb(36, 36, 42);
    var _base = _ice ? make_color_rgb(112, 164, 184) : make_color_rgb(88, 86, 78);
    var _light = _ice ? make_color_rgb(194, 232, 238) : make_color_rgb(146, 140, 116);
    var _dark = _ice ? make_color_rgb(74, 118, 150) : make_color_rgb(58, 56, 54);

    draw_set_alpha(0.24);
    draw_set_color(c_black);
    draw_ellipse(_x - 16 * _scale, _y + 2 * _scale, _x + 17 * _scale, _y + 12 * _scale, false);
    draw_set_alpha(1);
    draw_set_color(_edge);
    draw_triangle(_x - 16 * _scale, _y + 7 * _scale, _x - 6 * _scale, _y - 16 * _scale, _x + 15 * _scale, _y + 8 * _scale, false);
    draw_set_color(_base);
    draw_triangle(_x - 13 * _scale, _y + 5 * _scale, _x - 5 * _scale, _y - 13 * _scale, _x + 12 * _scale, _y + 6 * _scale, false);
    draw_set_color(_light);
    draw_triangle(_x - 10 * _scale, _y + 2 * _scale, _x - 5 * _scale, _y - 13 * _scale, _x + 2 * _scale, _y + 4 * _scale, false);
    draw_set_color(_dark);
    draw_triangle(_x + 2 * _scale, _y + 4 * _scale, _x + 12 * _scale, _y + 6 * _scale, _x - 1 * _scale, _y - 3 * _scale, false);
    draw_set_alpha(0.55);
    draw_set_color(c_white);
    draw_line_width(_x - 5 * _scale, _y - 10 * _scale, _x + 4 * _scale, _y - 2 * _scale, 1);
    draw_set_alpha(1);
}

function demo_draw_route_grass_clump(_x, _y, _scale, _dark) {
    var _base = _dark ? make_color_rgb(18, 78, 56) : make_color_rgb(46, 148, 70);
    var _light = _dark ? make_color_rgb(54, 128, 78) : make_color_rgb(104, 206, 88);

    draw_set_color(_base);
    for (var _i = -2; _i <= 2; _i += 1) {
        draw_triangle(_x + (_i * 5 * _scale), _y, _x + ((_i * 5) - 3) * _scale, _y - (14 + abs(_i) * 3) * _scale, _x + ((_i * 5) + 4) * _scale, _y, false);
    }

    draw_set_color(_light);
    draw_triangle(_x - 5 * _scale, _y, _x - 2 * _scale, _y - 18 * _scale, _x + 2 * _scale, _y, false);
}

function demo_draw_route_ice_crystal(_x, _y, _scale) {
    draw_set_color(make_color_rgb(56, 96, 136));
    draw_triangle(_x, _y - 34 * _scale, _x - 14 * _scale, _y, _x + 14 * _scale, _y, false);
    draw_set_color(make_color_rgb(142, 224, 240));
    draw_triangle(_x, _y - 30 * _scale, _x - 10 * _scale, _y - 1 * _scale, _x + 10 * _scale, _y - 1 * _scale, false);
    draw_set_color(make_color_rgb(226, 252, 255));
    draw_triangle(_x - 2 * _scale, _y - 28 * _scale, _x - 8 * _scale, _y - 3 * _scale, _x + 1 * _scale, _y - 4 * _scale, false);
    draw_set_alpha(0.60);
    draw_set_color(c_white);
    draw_line_width(_x + 1 * _scale, _y - 24 * _scale, _x + 7 * _scale, _y - 6 * _scale, 1);
    draw_set_alpha(1);
}

function demo_draw_route_scrap(_x, _y, _scale) {
    draw_set_alpha(0.26);
    draw_set_color(c_black);
    draw_rectangle(_x - 14 * _scale, _y + 6 * _scale, _x + 19 * _scale, _y + 12 * _scale, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(38, 44, 48));
    draw_rectangle(_x - 14 * _scale, _y - 8 * _scale, _x + 18 * _scale, _y + 8 * _scale, false);
    draw_set_color(make_color_rgb(90, 104, 108));
    draw_rectangle(_x - 10 * _scale, _y - 6 * _scale, _x + 12 * _scale, _y + 2 * _scale, false);
    draw_set_color(make_color_rgb(238, 208, 62));
    draw_line_width(_x - 8 * _scale, _y + 5 * _scale, _x + 16 * _scale, _y - 7 * _scale, max(1, 2 * _scale));
}

function demo_draw_route_lava_crack(_x, _y, _scale) {
    draw_set_color(make_color_rgb(52, 38, 34));
    draw_rectangle(_x - 20 * _scale, _y - 3 * _scale, _x + 22 * _scale, _y + 5 * _scale, false);
    draw_set_color(make_color_rgb(232, 82, 34));
    draw_rectangle(_x - 17 * _scale, _y - 1 * _scale, _x + 19 * _scale, _y + 2 * _scale, false);
    draw_set_alpha(0.55);
    draw_set_color(make_color_rgb(255, 188, 66));
    draw_rectangle(_x - 12 * _scale, _y, _x + 9 * _scale, _y + 1 * _scale, false);
    draw_set_alpha(1);
}

function demo_draw_route_broken_pillar(_x, _y, _scale) {
    draw_set_color(make_color_rgb(62, 58, 68));
    draw_rectangle(_x - 13 * _scale, _y - 48 * _scale, _x + 13 * _scale, _y + 6 * _scale, false);
    draw_set_color(make_color_rgb(132, 126, 116));
    draw_rectangle(_x - 10 * _scale, _y - 44 * _scale, _x + 10 * _scale, _y + 4 * _scale, false);
    draw_set_color(make_color_rgb(170, 164, 144));
    draw_rectangle(_x - 8 * _scale, _y - 42 * _scale, _x - 2 * _scale, _y + 2 * _scale, false);
    draw_set_color(make_color_rgb(78, 70, 82));
    draw_rectangle(_x - 18 * _scale, _y, _x + 18 * _scale, _y + 10 * _scale, false);
}

function demo_draw_route_path_stones(_w, _road_top, _road_bottom, _color, _count) {
    draw_set_alpha(0.28);
    draw_set_color(_color);

    for (var _i = 0; _i < _count; _i += 1) {
        var _x = ((_i * 97 + 31) mod max(1, floor(_w)));
        var _y = _road_top + 8 + ((_i * 43) mod max(1, floor(_road_bottom - _road_top - 16)));
        var _s = 3 + (_i mod 4);
        draw_rectangle(_x, _y, _x + _s * 2, _y + _s, false);
    }

    draw_set_alpha(1);
}

function demo_draw_route_stars(_w, _h, _count, _purple) {
    for (var _i = 0; _i < _count; _i += 1) {
        var _x = ((_i * 151 + 37) mod max(1, floor(_w)));
        var _y = 20 + ((_i * 79 + 11) mod max(1, floor(_h * 0.34)));
        var _blink = 0.35 + (sin(current_time * 0.004 + _i * 1.7) * 0.28);
        draw_set_alpha(_blink);
        draw_set_color(_purple ? make_color_rgb(210, 178, 255) : make_color_rgb(235, 240, 218));
        draw_rectangle(_x, _y, _x + 2, _y + 2, false);

        if ((_i mod 5) == 0) {
            draw_line(_x - 3, _y + 1, _x + 5, _y + 1);
            draw_line(_x + 1, _y - 3, _x + 1, _y + 5);
        }
    }

    draw_set_alpha(1);
}

function demo_draw_route_rain(_w, _h, _count) {
    draw_set_color(make_color_rgb(176, 218, 232));

    for (var _i = 0; _i < _count; _i += 1) {
        var _x = ((_i * 83 + floor(current_time * 0.12)) mod max(1, floor(_w + 80))) - 40;
        var _y = ((_i * 47 + floor(current_time * 0.36)) mod max(1, floor(_h + 80))) - 40;
        var _alpha = 0.28 + ((_i mod 4) * 0.06);
        draw_set_alpha(_alpha);
        draw_line_width(_x, _y, _x - 10, _y + 20, 2);
    }

    draw_set_alpha(1);
}

function demo_draw_route_fireflies(_w, _h, _road_top, _road_bottom) {
    for (var _i = 0; _i < 16; _i += 1) {
        var _base_x = ((_i * 173 + 29) mod max(1, floor(_w)));
        var _base_y = _road_top - 70 + ((_i * 41) mod max(1, floor((_road_bottom - _road_top) + 140)));
        var _x = _base_x + sin(current_time * 0.002 + _i) * 12;
        var _y = _base_y + cos(current_time * 0.0025 + _i * 0.6) * 8;
        var _a = 0.30 + sin(current_time * 0.006 + _i) * 0.22;
        draw_set_alpha(_a);
        draw_set_color(make_color_rgb(196, 238, 104));
        draw_circle(_x, _y, 3, false);
    }

    draw_set_alpha(1);
}

function demo_draw_route_petals_or_leaves(_w, _h, _count, _is_snow) {
    for (var _i = 0; _i < _count; _i += 1) {
        var _x = ((_i * 127 + floor(current_time * (_is_snow ? 0.02 : 0.06))) mod max(1, floor(_w + 40))) - 20;
        var _y = ((_i * 71 + floor(current_time * (_is_snow ? 0.035 : 0.045))) mod max(1, floor(_h + 40))) - 20;
        draw_set_alpha(_is_snow ? 0.58 : 0.36);
        draw_set_color(_is_snow ? make_color_rgb(238, 252, 255) : make_color_rgb(112, 190, 72));
        draw_rectangle(_x, _y, _x + (_is_snow ? 3 : 5), _y + (_is_snow ? 3 : 2), false);
    }

    draw_set_alpha(1);
}

function demo_draw_route_flower_patch(_x, _y, _scale, _dark) {
    var _stem = _dark ? make_color_rgb(40, 104, 66) : make_color_rgb(58, 150, 70);
    draw_set_color(_stem);

    for (var _i = 0; _i < 6; _i += 1) {
        var _fx = _x + ((_i * 11) - 28) * _scale;
        var _fy = _y - ((_i mod 3) * 5) * _scale;
        draw_line_width(_fx, _fy, _fx, _fy - 10 * _scale, max(1, 1 * _scale));
        draw_set_color((_i mod 2) == 0 ? make_color_rgb(238, 122, 188) : make_color_rgb(238, 222, 92));
        draw_rectangle(_fx - 3 * _scale, _fy - 14 * _scale, _fx + 3 * _scale, _fy - 8 * _scale, false);
        draw_set_color(_stem);
    }
}

function demo_route_sprite_from_bank(_controller, _bank_name, _sprite_name) {
    if (!instance_exists(_controller) || !variable_instance_exists(_controller, _bank_name)) {
        return -1;
    }

    var _bank = variable_instance_get(_controller, _bank_name);

    if (!is_struct(_bank) || !variable_struct_exists(_bank, _sprite_name)) {
        return -1;
    }

    return variable_struct_get(_bank, _sprite_name);
}

function demo_draw_route_cover_sprite(_spr, _w, _h, _alpha) {
    if (!sprite_exists(_spr)) {
        return false;
    }

    var _sw = max(1, sprite_get_width(_spr));
    var _sh = max(1, sprite_get_height(_spr));
    var _scale = max(_w / _sw, _h / _sh);
    var _x = (_w - (_sw * _scale)) * 0.5;
    var _y = (_h - (_sh * _scale)) * 0.5;
    draw_sprite_ext(_spr, 0, _x, _y, _scale, _scale, 0, c_white, _alpha);
    return true;
}

function demo_draw_route_scrolling_sprite(_spr, _w, _y, _scale, _speed, _alpha, _blend) {
    if (!sprite_exists(_spr)) {
        return;
    }

    var _sw = max(1, sprite_get_width(_spr) * _scale);
    var _offset = -((current_time * _speed) mod _sw);

    for (var _x = _offset; _x < _w + _sw; _x += _sw) {
        draw_sprite_ext(_spr, 0, _x, _y, _scale, _scale, 0, _blend, _alpha);
    }
}

function demo_draw_route_tiled_overlay(_spr, _w, _h, _speed_x, _speed_y, _alpha, _blend) {
    if (!sprite_exists(_spr)) {
        return;
    }

    var _sw = max(1, sprite_get_width(_spr));
    var _sh = max(1, sprite_get_height(_spr));
    var _offset_x = -((current_time * _speed_x) mod _sw);
    var _offset_y = -((current_time * _speed_y) mod _sh);

    for (var _x = _offset_x; _x < _w + _sw; _x += _sw) {
        for (var _y = _offset_y; _y < _h + _sh; _y += _sh) {
            draw_sprite_ext(_spr, 0, _x, _y, 1, 1, 0, _blend, _alpha);
        }
    }
}

function demo_draw_route_sheet_effect(_spr, _frames, _x, _y, _scale, _alpha, _blend, _frame_offset) {
    if (!sprite_exists(_spr) || _frames <= 0) {
        return;
    }

    var _fw = sprite_get_width(_spr) / _frames;
    var _fh = sprite_get_height(_spr);
    var _frame = (floor(current_time * 0.010) + _frame_offset) mod _frames;
    draw_sprite_part_ext(_spr, 0, _frame * _fw, 0, _fw, _fh, _x, _y, _scale, _scale, _blend, _alpha);
}

function demo_draw_route_sprite_scene(_controller, _tema, _w, _h) {
    if (_tema == "chuva") _tema = "pantano";
    if (_tema == "usina") _tema = "sucata";
    
    // Mapeamento para as novas artes geradas
    var _tema_sprite_nome = _tema;
    if (_tema == "gelo") _tema_sprite_nome = "gelo2";
    if (_tema == "montanha") _tema_sprite_nome = "montanha2";

    var _theme_sprite = demo_route_sprite_from_bank(_controller, "route_theme_sprites", _tema_sprite_nome);

    if (!demo_draw_route_cover_sprite(_theme_sprite, _w, _h, 1)) {
        var _fallback_sprite = instance_exists(_controller) && variable_instance_exists(_controller, "route_background_sprite") ? _controller.route_background_sprite : -1;
        demo_draw_route_cover_sprite(_fallback_sprite, _w, _h, 1);
    }

    var _clouds = demo_route_sprite_from_bank(_controller, "route_fx_sprites", "clouds");
    var _dark_clouds = demo_route_sprite_from_bank(_controller, "route_fx_sprites", "dark_clouds");
    var _rain = demo_route_sprite_from_bank(_controller, "route_fx_sprites", "rain");
    var _snow = demo_route_sprite_from_bank(_controller, "route_fx_sprites", "snow");
    var _fog = demo_route_sprite_from_bank(_controller, "route_fx_sprites", "fog");
    var _fire = demo_route_sprite_from_bank(_controller, "route_fx_sprites", "fire");
    var _sparks = demo_route_sprite_from_bank(_controller, "route_fx_sprites", "sparks");
    var _lightning = demo_route_sprite_from_bank(_controller, "route_fx_sprites", "lightning");

    switch (_tema) {

        case "pantano":
            demo_draw_route_scrolling_sprite(_dark_clouds, _w, 20, 1.36, 0.020, 0.66, c_white);
            demo_draw_route_scrolling_sprite(_fog, _w, _h * 0.42, 1.58, -0.016, 0.46, make_color_rgb(184, 214, 194));
            demo_draw_route_tiled_overlay(_rain, _w, _h, -0.030, 0.155, 0.48, c_white);
            if ((floor(current_time / 780) mod 5) == 0) {
                demo_draw_route_sheet_effect(_lightning, 3, _w * 0.55, 36, 1.45, 0.58, c_white, 0);
            }
            demo_draw_route_procedural_grid(_controller, _w, _h, "sprites/overworld/routes/elements/bg_chao_lama.jpg", [
                "sprites/overworld/routes/elements/spr_arvore_morta.jpg",
                "sprites/overworld/routes/elements/spr_tronco_caido.jpg",
                "sprites/overworld/routes/elements/spr_poca_toxica.jpg",
                "sprites/overworld/routes/elements/spr_cogumelo_venenoso.jpg"
            ]);
            break;

        case "grama":
            demo_draw_route_scrolling_sprite(_clouds, _w, 32, 1.45, 0.018, 0.80, c_white);
            demo_draw_route_procedural_grid(_controller, _w, _h, "sprites/overworld/routes/elements/bg_chao_grama.jpg", [
                "sprites/overworld/routes/elements/spr_arvore_frondosa.jpg",
                "sprites/overworld/routes/elements/spr_arbusto_pequeno.jpg",
                "sprites/overworld/routes/elements/spr_pedregulho_comum.jpg",
                "sprites/overworld/routes/elements/spr_cerca_madeira.jpg",
                "sprites/overworld/routes/elements/spr_flores_coloridas.jpg"
            ]);
            break;

        case "floresta_noite":
        case "bosque":
            demo_draw_route_scrolling_sprite(_dark_clouds, _w, 28, 1.24, 0.014, 0.64, c_white);
            demo_draw_route_scrolling_sprite(_fog, _w, _h * 0.46, 1.50, -0.012, 0.42, make_color_rgb(196, 170, 232));
            demo_draw_route_procedural_grid(_controller, _w, _h, "sprites/overworld/routes/elements/bg_chao_escuro_folhas.jpg", [
                "sprites/overworld/routes/elements/spr_arvore_morta.jpg",
                "sprites/overworld/routes/elements/spr_tronco_caido.jpg"
            ]);
            break;
            
        case "caverna":
        case "montanha":
            demo_draw_route_scrolling_sprite(_dark_clouds, _w, 28, 1.12, 0.010, 0.34, c_white);
            demo_draw_route_scrolling_sprite(_fog, _w, _h * 0.42, 1.50, -0.008, 0.30, make_color_rgb(190, 204, 210));
            demo_draw_route_procedural_grid(_controller, _w, _h, "sprites/overworld/routes/elements/bg_chao_pedra.jpg", [
                "sprites/overworld/routes/elements/spr_pedra_pontiaguda.jpg",
                "sprites/overworld/routes/elements/spr_estalagmite_cristal.jpg",
                "sprites/overworld/routes/elements/spr_carrinho_mina.jpg"
            ]);
            break;

        case "floral":
            demo_draw_route_scrolling_sprite(_clouds, _w, 20, 1.35, 0.012, 0.85, c_white);
            var _swing_f = dsin(current_time * 0.15) * 4;
            draw_set_color(make_color_rgb(255, 215, 0));
            draw_circle(_w * 0.4 + _swing_f, _h * 0.7, 8, false);
            draw_circle(_w * 0.75 - _swing_f, _h * 0.72, 8, false);
            draw_set_color(c_white);
            break;

        case "fantasma":
        case "cemiterio":
            demo_draw_route_scrolling_sprite(_dark_clouds, _w, 34, 1.24, 0.012, 0.62, c_white);
            demo_draw_route_scrolling_sprite(_fog, _w, _h * 0.45, 1.72, -0.014, 0.52, make_color_rgb(210, 190, 244));
            break;

        case "gelo":
            demo_draw_route_scrolling_sprite(_fog, _w, _h * 0.36, 1.45, -0.008, 0.34, make_color_rgb(225, 250, 255));
            demo_draw_route_tiled_overlay(_snow, _w, _h, 0.020, 0.056, 0.62, c_white);
            break;

        case "vulcao":
            demo_draw_route_scrolling_sprite(_dark_clouds, _w, 18, 1.18, 0.018, 0.46, make_color_rgb(210, 132, 100));
            for (var _fire_i = 0; _fire_i < 7; _fire_i += 1) {
                var _fx = ((_fire_i * 167 + 82) mod max(1, floor(_w)));
                var _fy = 210 + ((_fire_i * 83) mod max(1, floor(_h * 0.38)));
                demo_draw_route_sheet_effect(_fire, 4, _fx, _fy, 1.45 + ((_fire_i mod 3) * 0.22), 0.88, c_white, _fire_i);
            }
            break;

        case "agua":
            demo_draw_route_scrolling_sprite(_clouds, _w, 28, 1.28, 0.020, 0.72, c_white);
            demo_draw_route_scrolling_sprite(_fog, _w, _h * 0.42, 1.26, -0.012, 0.18, make_color_rgb(205, 244, 250));
            break;

        case "sucata":
            demo_draw_route_scrolling_sprite(_dark_clouds, _w, 18, 1.28, 0.018, 0.50, c_white);
            demo_draw_route_tiled_overlay(_rain, _w, _h, -0.016, 0.104, 0.24, make_color_rgb(210, 230, 228));
            for (var _spark_i = 0; _spark_i < 12; _spark_i += 1) {
                var _sx = ((_spark_i * 127 + 37) mod max(1, floor(_w)));
                var _sy = 58 + ((_spark_i * 79) mod max(1, floor(_h * 0.62)));
                demo_draw_route_sheet_effect(_sparks, 4, _sx, _sy, 0.72 + ((_spark_i mod 2) * 0.18), 0.84, c_white, _spark_i);
            }
            if ((floor(current_time / 700) mod 4) == 0) {
                demo_draw_route_sheet_effect(_lightning, 3, _w * 0.62, 28, 1.55, 0.50, c_white, 1);
            }
            break;

        case "ruinas":
            demo_draw_route_scrolling_sprite(_clouds, _w, 34, 1.16, 0.010, 0.34, make_color_rgb(222, 210, 244));
            demo_draw_route_scrolling_sprite(_fog, _w, _h * 0.43, 1.42, -0.010, 0.34, make_color_rgb(212, 194, 236));
            break;
    }
}

function demo_load_external_sprite(_path) {
    // Cache de sprites carregados por caminho relativo (passa pelo filtro de arte permitida).
    static _cache = ds_map_create();

    if (!ds_map_exists(_cache, _path)) {
        var _found = project_asset_path(_path);
        var _spr = _found != "" ? sprite_add(_found, 1, false, false, 0, 0) : -1;
        ds_map_add(_cache, _path, _spr);
    }

    return ds_map_find_value(_cache, _path);
}

function demo_draw_route_procedural_grid(_controller, _w, _h, _bg_path, _elements_array) {
    var _bg = demo_load_external_sprite("datafiles/" + _bg_path);
    if (sprite_exists(_bg)) {
        demo_draw_route_cover_sprite(_bg, _w, _h, 1);
    }
}

function demo_draw_route_travel_background(_controller, _w, _h) {
    var _rota = instance_exists(_controller) ? _controller.rota_atual : undefined;
    var _tema = demo_rota_visual_tema(_rota);
    demo_draw_route_sprite_scene(_controller, _tema, _w, _h);

    // Logica do Jogador no Grid Top-Down
    var _progress = 0;
    if (instance_exists(_controller) && variable_instance_exists(_controller, "run") && is_struct(_controller.run) && variable_struct_exists(_controller.run, "NoAtual")) {
        _progress = clamp(_controller.run.NoAtual / 15, 0, 1);
    }
    
    // Fallback: se nao achou o nó, anima com o tempo para demonstrar
    if (_progress == 0) _progress = clamp(((current_time / 1000) mod 15) / 15, 0, 1);

    var _start_x = _w * 0.20;
    var _start_y = _h * 0.20;
    var _end_x = _w * 0.80;
    var _end_y = _h * 0.80;
    
    // Sentido da Viagem
    var _is_returning = false;

    var _walk_x = _is_returning ? lerp(_end_x, _start_x, _progress) : lerp(_start_x, _end_x, _progress);
    var _walk_y = _is_returning ? lerp(_end_y, _start_y, _progress) : lerp(_start_y, _end_y, _progress);

    // Carregar Sprite do Jogador
    var _spr_player = instance_exists(_controller) && variable_instance_exists(_controller, "route_trainer_sprite") ? _controller.route_trainer_sprite : -1;
    if (sprite_exists(_spr_player)) {
        var _fw = sprite_get_width(_spr_player) / 4;
        var _fh = sprite_get_height(_spr_player) / 4;
        
        // Animacao: 4 frames
        var _anim_speed = 0.008;
        var _frame = floor(current_time * _anim_speed) mod 4;
        
        // Direção: 0 = Baixo, 1 = Cima, 2 = Esquerda, 3 = Direita
        var _dir_row = 2; // Right
        if (_is_returning) {
            _dir_row = 1; // Left
        }
        
        // Sombra simples
        draw_set_color(c_black);
        draw_set_alpha(0.3);
        draw_ellipse(_walk_x - 12, _walk_y - 6, _walk_x + 12, _walk_y + 6, false);
        draw_set_alpha(1);
        draw_set_color(c_white);

        draw_sprite_part_ext(_spr_player, 0, _frame * _fw, _dir_row * _fh, _fw, _fh, _walk_x - (_fw/2), _walk_y - _fh + 4, 1.2, 1.2, c_white, 1);
    }
}

function demo_draw_gym_trainer(_spr, _base_x, _base_y) {
    var _trainer_ground_y = _base_y + 10;

    if (!sprite_exists(_spr)) {
        var _bob_fallback = sin(current_time * 0.005) * 3;
        var _y = _trainer_ground_y + _bob_fallback;
        draw_set_alpha(0.24);
        draw_set_color(c_black);
        draw_ellipse(_base_x - 30, _y - 8, _base_x + 30, _y + 7, false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(102, 82, 56));
        draw_rectangle(_base_x - 22, _y - 100, _base_x + 22, _y - 48, false);
        draw_set_color(make_color_rgb(230, 172, 122));
        draw_circle(_base_x, _y - 124, 20, false);
        draw_set_color(make_color_rgb(62, 44, 32));
        draw_triangle(_base_x - 24, _y - 136, _base_x, _y - 162, _base_x + 24, _y - 136, false);
        draw_set_color(make_color_rgb(72, 112, 70));
        draw_rectangle(_base_x - 18, _y - 48, _base_x - 4, _y - 4, false);
        draw_rectangle(_base_x + 4, _y - 48, _base_x + 18, _y - 4, false);
        draw_set_color(make_color_rgb(230, 172, 122));
        draw_rectangle(_base_x - 38, _y - 94, _base_x - 22, _y - 56, false);
        draw_rectangle(_base_x + 22, _y - 94, _base_x + 38, _y - 56, false);
        return;
    }

    var _target_h = 210;
    var _scale = min(1.65, _target_h / max(1, sprite_get_height(_spr)));
    var _bob = sin(current_time * 0.005) * 3;
    var _sx = _scale;
    var _sy = _scale * (1 + sin(current_time * 0.006) * 0.025);
    var _bbox_center_x = (sprite_get_bbox_left(_spr) + sprite_get_bbox_right(_spr)) * 0.5;
    var _bbox_bottom = sprite_get_bbox_bottom(_spr);
    var _draw_x = _base_x - ((_bbox_center_x - sprite_get_xoffset(_spr)) * _sx);
    var _draw_y = (_trainer_ground_y + _bob) - ((_bbox_bottom - sprite_get_yoffset(_spr)) * _sy);

    draw_set_alpha(0.24);
    draw_set_color(c_black);
    draw_ellipse(_base_x - 30, _trainer_ground_y - 7, _base_x + 30, _trainer_ground_y + 6, false);
    draw_set_alpha(1);
    draw_sprite_ext(_spr, 0, _draw_x, _draw_y, _sx, _sy, 0, c_white, 1);
}

function demo_draw_dialog_character(_spr, _x1, _y1, _x2, _y2) {
    if (!sprite_exists(_spr)) {
        return;
    }

    var _panel_w = _x2 - _x1;
    var _panel_h = _y2 - _y1;
    var _target_h = _panel_h * 0.88;
    var _scale = _target_h / max(1, sprite_get_height(_spr));
    var _x = _x2 - (_panel_w * 0.17);
    var _y = _y2 - 12;
    var _bbox_center_x = (sprite_get_bbox_left(_spr) + sprite_get_bbox_right(_spr)) * 0.5;
    var _bbox_bottom = sprite_get_bbox_bottom(_spr);
    var _draw_x = _x - ((_bbox_center_x - sprite_get_xoffset(_spr)) * _scale);
    var _draw_y = _y - ((_bbox_bottom - sprite_get_yoffset(_spr)) * _scale);

    draw_set_alpha(0.34);
    draw_sprite_ext(_spr, 0, _draw_x, _draw_y, _scale, _scale, 0, c_white, 1);
    draw_set_alpha(1);
}

function demo_dialog_sprite_cidade(_controller, _fallback_sprite) {
    if (!instance_exists(_controller)) {
        return _fallback_sprite;
    }

    if (variable_instance_exists(_controller, "dialog_sprites_cidade")) {
        var _sprites = variable_instance_get(_controller, "dialog_sprites_cidade");

        if (is_array(_sprites)) {
            var _cidade_idx = variable_instance_exists(_controller, "cidade_index") ? variable_instance_get(_controller, "cidade_index") : 0;
            var _idx = clamp(_cidade_idx, 0, array_length(_sprites) - 1);
            var _spr = _sprites[_idx];

            if (sprite_exists(_spr)) return _spr;
        }
    }

    return _fallback_sprite;
}

function demo_draw_pokemon_sprite(_pokemon_id, _x, _y, _scale, _face_dir, _flash) {
    var _bob = sin(current_time * 0.006 + _pokemon_id) * 3 * _scale;
    var _sx = _scale * _face_dir;
    var _sy = _scale * (1 + sin(current_time * 0.006 + _pokemon_id) * 0.035);
    var _yy = _y + _bob;
    var _blend = _flash > 0 ? c_red : c_white;
    var _sprite = demo_get_pokemon_sprite(_pokemon_id);

    draw_set_color(c_black);
    draw_ellipse(_x - 30 * _scale, _y - 7 * _scale, _x + 30 * _scale, _y + 6 * _scale, false);

    if (sprite_exists(_sprite)) {
        var _bbox_center_x = (sprite_get_bbox_left(_sprite) + sprite_get_bbox_right(_sprite)) * 0.5;
        var _bbox_bottom = sprite_get_bbox_bottom(_sprite);
        var _draw_x = _x - ((_bbox_center_x - sprite_get_xoffset(_sprite)) * _sx);
        var _draw_y = _yy - ((_bbox_bottom - sprite_get_yoffset(_sprite)) * _sy);

        draw_sprite_ext(_sprite, 0, _draw_x, _draw_y, _sx, _sy, 0, _blend, 1);
        draw_set_color(c_white);
        return;
    }

    draw_set_color(_blend);
    draw_rectangle(_x - 22 * _scale, _yy - 44 * _scale, _x + 22 * _scale, _yy, false);

    draw_set_color(c_white);
}

function demo_draw_battle_pokemon_instance(_inst) {
    if (!instance_exists(_inst) || !_inst.vivo) {
        return;
    }

    var _spr = _inst.sprite_idle;

    switch (_inst.estado_visual) {
        case ESTADO.ATACANDO:
            _spr = sprite_exists(_inst.sprite_ataque) ? _inst.sprite_ataque : _inst.sprite_idle;
            break;

        case ESTADO.DANO:
            _spr = sprite_exists(_inst.sprite_dano) ? _inst.sprite_dano : _inst.sprite_idle;
            break;
    }

    var _shake_x = variable_global_exists("screen_shake_x") ? global.screen_shake_x : 0;
    var _shake_y = variable_global_exists("screen_shake_y") ? global.screen_shake_y : 0;
    var _draw_x = _inst.x + _inst.visual_offset_x + _shake_x;
    var _draw_y = _inst.y + _shake_y;
    var _xscale = _inst.lado_batalha == LadoBatalha.ALIADO ? -1 : 1;
    var _base_scale = 2.05;
    var _scale = _base_scale;
    var _alpha = 1;
    var _capture_enemy = false;

    var _demo = instance_number(obj_demo_game) > 0 ? instance_find(obj_demo_game, 0) : noone;

    if (instance_exists(_demo) && _demo.estado_demo == DemoEstado.CAPTURA && _inst.lado_batalha == LadoBatalha.INIMIGO && is_struct(_demo.capture_anim)) {
        _capture_enemy = true;
        var _capture_t = _demo.capture_anim.Timer;

        if (_capture_t >= 0.72) {
            var _shrink = clamp((_capture_t - 0.72) / 0.72, 0, 1);
            _scale *= lerp(1, 0.08, _shrink);
            _draw_y = lerp(_draw_y, _inst.y + 12, _shrink);
            _alpha = 1 - (_shrink * 0.85);
        }

        if (_capture_t >= 1.45 && _demo.capture_anim.Success) {
            _alpha = 0;
        } else if (_capture_t >= 2.25 && !_demo.capture_anim.Success) {
            var _return_t = clamp((_capture_t - 2.25) / 0.55, 0, 1);
            _scale = _base_scale * _return_t;
            _alpha = _return_t;
        }
    }

    var _shadow_x = _draw_x;
    var _shadow_y = _draw_y + 8;

    if (sprite_exists(_spr)) {
        var _bbox_center_x = (sprite_get_bbox_left(_spr) + sprite_get_bbox_right(_spr)) * 0.5;
        var _bbox_bottom = sprite_get_bbox_bottom(_spr);
        _draw_x -= ((_bbox_center_x - sprite_get_xoffset(_spr)) * _xscale * _scale);
        _draw_y -= ((_bbox_bottom - sprite_get_yoffset(_spr)) * _scale);
    }

    draw_set_color(c_black);
    draw_set_alpha(_alpha);
    draw_ellipse(_shadow_x - 52, _shadow_y - 11, _shadow_x + 52, _shadow_y + 9, false);
    draw_set_alpha(1);

    if (_alpha > 0.05 && variable_instance_exists(_inst, "is_shiny") && _inst.is_shiny) {
        var _star = demo_effect_sprite_get("shiny_star");
        var _pulse = 0.72 + (sin(current_time * 0.010) * 0.22);

        draw_set_alpha(0.28 + (_pulse * 0.16));
        draw_set_color(make_color_rgb(255, 232, 88));
        draw_circle(_shadow_x, _shadow_y - 68, 54 + (_pulse * 8), false);
        draw_set_alpha(1);

        if (sprite_exists(_star)) {
            for (var _spark = 0; _spark < 4; _spark += 1) {
                var _ang = current_time * 0.004 + (_spark * 1.5708);
                var _sx = _shadow_x + (cos(_ang) * (46 + (_pulse * 7)));
                var _sy = _shadow_y - 72 + (sin(_ang) * (30 + (_pulse * 5)));
                draw_sprite_ext(_star, 0, _sx, _sy, 1.25 + (_pulse * 0.35), 1.25 + (_pulse * 0.35), current_time * 0.08, c_white, 0.9);
            }
        }
    }

    if (sprite_exists(_spr)) {
        var _blend = _capture_enemy ? c_white : (_inst.visual_flash > 0 ? c_red : c_white);
        draw_set_alpha(_alpha);
        draw_sprite_ext(_spr, 0, _draw_x, _draw_y, _xscale * _scale, _scale, 0, _blend, 1);
        draw_set_alpha(1);
    } else {
        demo_draw_pokemon_sprite(_inst.pokemon_id, _draw_x, _draw_y, _scale, _xscale, _inst.visual_flash);
    }

    battle_status_draw_world_effects(_inst, _shadow_x, _shadow_y, _scale, _alpha);

}

function demo_draw_capture_animation(_controller) {
    if (!instance_exists(_controller) || !is_struct(_controller.capture_anim) || !instance_exists(_controller.enemy_inst)) {
        return;
    }

    var _anim = _controller.capture_anim;
    var _t = _anim.Timer;
    var _enemy = _controller.enemy_inst;
    var _start_x = room_width * 0.14;
    var _start_y = room_height * 0.60;
    var _hit_x = _enemy.x - 14;
    var _hit_y = _enemy.y - 68;
    var _land_x = _enemy.x;
    var _land_y = _enemy.y + 6;
    var _ball_x = _start_x;
    var _ball_y = _start_y;
    var _rot = current_time * 0.5;
    var _scale = 1.7;

    if (_t < 0.72) {
        var _p = clamp(_t / 0.72, 0, 1);
        _ball_x = lerp(_start_x, _hit_x, _p);
        _ball_y = lerp(_start_y, _hit_y, _p) - sin(_p * pi) * 170;
        _rot = _p * 720;
    } else {
        _ball_x = _land_x;
        _ball_y = _land_y;

        if (_t < 1.25) {
            var _drop = clamp((_t - 0.72) / 0.53, 0, 1);
            _ball_y = lerp(_hit_y, _land_y, _drop);
            _rot = 360 + (_drop * 180);
        } else {
            var _shake_t = _t - 1.25;
            var _shake_phase = floor(_shake_t / 0.42);
            var _shake_local = (_shake_t mod 0.42) / 0.42;

            if (_shake_phase < (_anim.Success ? 3 : 2)) {
                _rot = sin(_shake_local * pi * 2) * 18;
                _ball_x += sin(_shake_local * pi * 2) * 8;
            } else {
                _rot = 0;
            }

            if (!_anim.Success && _t > 2.15) {
                _scale = 1.7 + (sin((_t - 2.15) * 18) * 0.18);
            }
        }
    }

    var _spr = demo_item_icon_get(_anim.ItemID);

    if (sprite_exists(_spr)) {
        draw_sprite_ext(_spr, 0, _ball_x, _ball_y, _scale, _scale, _rot, c_white, 1);
    } else if (sprite_exists(global.ui_ball_sprite)) {
        draw_sprite_ext(global.ui_ball_sprite, 0, _ball_x, _ball_y, _scale, _scale, _rot, c_white, 1);
    } else {
        draw_set_color(c_red);
        draw_circle(_ball_x, _ball_y, 12 * _scale, false);
        draw_set_color(c_white);
        draw_rectangle(_ball_x - 12 * _scale, _ball_y, _ball_x + 12 * _scale, _ball_y + 12 * _scale, false);
        draw_set_color(c_black);
        draw_circle(_ball_x, _ball_y, 4 * _scale, false);
    }

    if (_t > 0.68 && _t < 1.05) {
        var _flash = 1 - clamp((_t - 0.68) / 0.37, 0, 1);
        draw_set_alpha(_flash * 0.42);
        draw_set_color(c_white);
        draw_circle(_hit_x, _hit_y, 86 * (1 - _flash + 0.2), false);
        draw_set_alpha(1);
    }
}

function demo_draw_result_panel(_controller) {
    if (!instance_exists(_controller) || !is_struct(_controller.battle_result_info)) {
        return;
    }

    battle_ui_init();

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _info = _controller.battle_result_info;
    var _w = 620;
    var _drop_count = variable_struct_exists(_info, "Itens") && is_array(_info.Itens) ? array_length(_info.Itens) : 0;
    var _frag_count = variable_struct_exists(_info, "FragmentosEspaco") ? _info.FragmentosEspaco : 0;
    var _h = _info.Tipo == "derrota" ? 240 : (is_struct(_info.Capturado) ? 438 : 388);

    if (_drop_count > 0) {
        _h += 52 + (min(4, _drop_count) * 30);
    }

    if (_frag_count > 0) {
        _h += 62;
    }

    var _x = (_gw - _w) * 0.5;
    var _y = (_gh - _h) * 0.5 - 22;

    draw_set_alpha(0.48);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    battle_ui_draw_nineslice_panel(_x, _y, _w, _h);
    var _inner_x = _x + 38;
    var _inner_w = _w - 76;
    var _top_y = _y + 44;
    var _continue_y = _y + _h - 56;
    var _accent = _info.Tipo == "derrota" ? make_color_rgb(196, 46, 54) : make_color_rgb(56, 154, 88);
    var _title = "Vitoria";
    var _summary = "A equipe venceu o confronto e pode seguir pela rota.";

    if (_info.Tipo == "derrota") {
        _title = "Run encerrada";
        _summary = "Todos os monstros ativos foram derrotados. Reorganize a estrategia e tente outra travessia.";
    } else if (_info.Tipo == "captura") {
        _title = "Captura realizada";
        _summary = "O novo monstro entrou na equipe com a propria build rolada nesta run.";
    }

    draw_set_color(_accent);
    draw_text(_inner_x, _top_y, string_upper(_title));
    draw_line_width(_inner_x, _top_y + 30, _inner_x + _inner_w, _top_y + 30, 3);

    draw_set_color(sprite_exists(global.ui_panel_sprite) ? c_black : c_white);
    draw_text_ext(_inner_x, _top_y + 46, _summary, 24, _inner_w);

    var _content_y = _top_y + 106;

    if (is_struct(_info.Capturado)) {
        var _capturado = _info.Capturado;
        var _is_shiny = variable_struct_exists(_capturado, "IsShiny") && _capturado.IsShiny;
        var _icon = demo_pokemon_icon_get(_capturado.ID, _is_shiny);

        battle_ui_draw_nineslice_panel(_inner_x, _content_y, _inner_w, 82);

        if (sprite_exists(_icon)) {
            draw_sprite_ext(_icon, 0, _inner_x + 42, _content_y + 42, 2.2, 2.2, 0, c_white, 1);
        }

        draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(36, 30, 28) : c_white);
        draw_text(_inner_x + 88, _content_y + 16, (_is_shiny ? "CROMATICO " : "") + _capturado.Nome + " entrou na equipe");
        draw_text(_inner_x + 88, _content_y + 44, "Lv." + string(_capturado.Level) + "   Time: " + string(array_length(_controller.player_party)) + " / 4");
        _content_y += 96;
    }

    if ((variable_struct_exists(_info, "Dinheiro") && _info.Dinheiro > 0) || _info.XPBase > 0) {
        var _reward_lines = min(4, array_length(_info.Ganhos));

        for (var _rl = 0; _rl < min(4, array_length(_info.Ganhos)); _rl += 1) {
            var _line_gain = _info.Ganhos[_rl];

            if (is_struct(_line_gain) && variable_struct_exists(_line_gain, "Evolucoes") && is_array(_line_gain.Evolucoes)) {
                _reward_lines += min(2, array_length(_line_gain.Evolucoes));
            }
        }

        var _reward_h = 56 + (_reward_lines * 24);
        battle_ui_draw_nineslice_panel(_inner_x, _content_y, _inner_w, _reward_h);
        draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(36, 30, 28) : c_white);
        var _reward_text = variable_struct_exists(_info, "Dinheiro") && _info.Dinheiro > 0 ? "M$ " + string(_info.Dinheiro) + " recebidos" : "Sem dinheiro nesta luta";
        draw_text(_inner_x + 24, _content_y + 16, _reward_text);

        if (_info.XPBase > 0) {
            draw_text(_inner_x + 260, _content_y + 16, "EXP base " + string(_info.XPBase));
        }

        _content_y += 48;

        for (var _i = 0; _i < min(4, array_length(_info.Ganhos)); _i += 1) {
            var _gain = _info.Ganhos[_i];

            if (!is_struct(_gain) || !is_struct(_gain.Pokemon)) {
                continue;
            }

            var _pokemon = _gain.Pokemon;
            var _label = _gain.Participou ? "100%" : "50%";
            var _level_txt = _gain.LevelDepois > _gain.LevelAntes ? "  Lv." + string(_gain.LevelAntes) + " > " + string(_gain.LevelDepois) : "";
            draw_text(_inner_x + 24, _content_y, _pokemon.Nome + ": +" + string(_gain.XP) + " EXP (" + _label + ")" + _level_txt);
            _content_y += 24;

            if (variable_struct_exists(_gain, "Evolucoes") && is_array(_gain.Evolucoes)) {
                for (var _ev = 0; _ev < min(2, array_length(_gain.Evolucoes)); _ev += 1) {
                    var _evo = _gain.Evolucoes[_ev];

                    if (is_struct(_evo)) {
                        draw_text(_inner_x + 44, _content_y, "Evoluiu: " + _evo.DeNome + " -> " + _evo.ParaNome);
                        _content_y += 24;
                    }
                }
            }
        }
    }

    if (_drop_count > 0) {
        var _drops_h = 48 + (min(4, _drop_count) * 30);
        battle_ui_draw_nineslice_panel(_inner_x, _content_y + 12, _inner_w, _drops_h);
        draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(36, 30, 28) : c_white);
        draw_text(_inner_x + 24, _content_y + 28, "Itens recebidos");
        _content_y += 58;

        for (var _drop_i = 0; _drop_i < min(4, _drop_count); _drop_i += 1) {
            var _drop = _info.Itens[_drop_i];

            if (!is_struct(_drop)) {
                continue;
            }

            var _item = demo_item_get(_drop.ID);
            var _nome_item = is_struct(_item) ? _item.Nome : string(_drop.ID);
            demo_draw_item_icon(_drop.ID, _inner_x + 38, _content_y + 12, 24);
            draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(36, 30, 28) : c_white);
            draw_text(_inner_x + 68, _content_y + 4, _nome_item + " x" + string(_drop.Qtd));
            _content_y += 30;
        }
    }

    if (_frag_count > 0) {
        battle_ui_draw_nineslice_panel(_inner_x, _content_y + 12, _inner_w, 50);
        demo_draw_space_fragment_icon(_inner_x + 40, _content_y + 38, 32);
        draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(36, 30, 28) : c_white);
        draw_text(_inner_x + 72, _content_y + 28, "Fragmento temporal +" + string(_frag_count));
        _content_y += 66;
    }

    draw_set_color(sprite_exists(global.ui_panel_sprite) ? c_black : c_white);
    var _continue = "Clique ou pressione ENTER para continuar";
    draw_text(_x + (_w - string_width(_continue)) * 0.5, _continue_y, _continue);
}

function demo_inicializar_globals() {
    if (!variable_global_exists("pokedex")) {
        global.pokedex = pokemon_db_criar();
    }

    if (!variable_global_exists("item_db")) {
        global.item_db = demo_item_db_criar();
    }

    if (!variable_global_exists("time_scale")) {
        global.time_scale = 1.0;
    }

    if (!variable_global_exists("velocidade_jogo")) {
        global.velocidade_jogo = global.time_scale;
    }

    if (!variable_global_exists("pokedex_overlay_aberto")) {
        global.pokedex_overlay_aberto = false;
    }

    battle_ui_init();
    pokedex_inicializar(global.pokedex);
}

function demo_pokemon_shiny_chance() {
    var _bonus = variable_global_exists("demo_meta_shiny_bonus") ? global.demo_meta_shiny_bonus : 0;
    return clamp(0.01 + _bonus, 0.01, 0.035);
}

function demo_pokemon_roll_female(_pokemon_id) {
    return random(1) < 0.5 && pokemon_sprite_path(_pokemon_id, "", false, true) != "";
}

function demo_pokemon_aplicar_shiny(_pokemon) {
    return pokemon_data_aplicar_shiny(_pokemon);
}

function demo_aplicar_balanceamento_selvagem(_pokemon, _level) {
    if (!is_struct(_pokemon)) {
        return;
    }

    var _ratio = 1.0;

    if (_level <= 1) {
        _ratio = 0.66;
    } else if (_level <= 2) {
        _ratio = 0.74;
    } else if (_level <= 3) {
        _ratio = 0.82;
    } else if (_level <= 5) {
        _ratio = 0.90;
    }

    if (_ratio < 1) {
        pokemon_data_aplicar_multiplicador_atributos(_pokemon, _ratio);
    }

    var _raridade = variable_struct_exists(_pokemon, "RaridadeEfetiva") ? _pokemon.RaridadeEfetiva : PokemonRaridade.COMMON;

    if (_level <= 3 && _raridade == PokemonRaridade.RARE) {
        pokemon_data_aplicar_multiplicador_atributos(_pokemon, 0.88);
    } else if (_level <= 6 && _raridade >= PokemonRaridade.EPIC) {
        pokemon_data_aplicar_multiplicador_atributos(_pokemon, 0.82);
    }

    _pokemon.HpAtual = _pokemon.HpMax;
}

function demo_criar_pokemon_data(_id, _level, _auto_resolver_progressao) {
    if (argument_count < 3) {
        _auto_resolver_progressao = false;
    }

    var _permitir_shiny = argument_count >= 4 ? argument[3] : false;
    var _permitir_female = argument_count >= 5 ? argument[4] : false;
    var _build_context = argument_count >= 6 ? argument[5] : "";
    var _base = pokemon_db_get(global.pokedex, _id);
    var _pokemon = pokemon_data_clonar(_base, _level);

    if (is_struct(_pokemon)) {
        _pokemon.HpAtual = _pokemon.HpMax;
        _pokemon.IsFemale = _permitir_female ? demo_pokemon_roll_female(_id) : false;

        if (_auto_resolver_progressao && _build_context != "") {
            pokemon_progressao_inimigo_randomizar_build(_pokemon, _build_context);
        } else if (_auto_resolver_progressao) {
            pokemon_progressao_auto_resolver_ate_level(_pokemon);
        }

        if (_build_context == "selvagem") {
            demo_aplicar_balanceamento_selvagem(_pokemon, _level);
        }

        if (_permitir_shiny && random(1) < demo_pokemon_shiny_chance()) {
            demo_pokemon_aplicar_shiny(_pokemon);
        }
    }

    return _pokemon;
}

function demo_start_battle(_controller) {
    if (!instance_exists(_controller)) {
        return;
    }

    with (_controller) {
        demo_cleanup_battle(id);
        demo_party_garantir(id);

        if (!instance_exists(obj_battle_ui)) {
            instance_create_layer(0, 0, "Instances", obj_battle_ui);
        }

        battle_manager = instance_create_layer(0, 0, "Instances", obj_gerenciador_batalha);
        player_inst = pokemon_batalha_criar(room_width * 0.25, room_height * 0.69, player_pokemon_data, "Instances", LadoBatalha.ALIADO);
        enemy_inst = pokemon_batalha_criar(room_width * 0.75, room_height * 0.69, enemy_pokemon_data, "Instances", LadoBatalha.INIMIGO);
        player_inst.visible = false;
        enemy_inst.visible = false;
        battle_manager.aliados_campo = [player_inst];
        battle_manager.inimigos_campo = [enemy_inst];
        battle_participants = [];
        demo_battle_marcar_participante(id, player_pokemon_data);
        demo_battle_rewards_resetar(id);
        battle_result_info = undefined;
        battle_time_scale_restore_preferido();
        estado_demo = DemoEstado.BATALHA;

        if (battle_context == "ginasio") {
            if (sprite_exists(gym_trainer_sprite)) {
                pokemon_sprite_liberar(gym_trainer_sprite);
            }

            battle_trainer_active = true;
            battle_trainer_name = kanto_cidades[gym_battle_city_index].Lider;
            gym_trainer_sprite = demo_trainer_sprite_carregar(battle_trainer_name);
            message = battle_trainer_name + " esta mantendo uma fenda aberta no ginasio!";
        } else if (battle_context == "treinador") {
            if (sprite_exists(gym_trainer_sprite)) {
                pokemon_sprite_liberar(gym_trainer_sprite);
            }

            battle_trainer_active = true;
            battle_trainer_name = is_struct(route_trainer_data) ? route_trainer_data.Nome : "Treinador";
            var _trainer_sprite_file = is_struct(route_trainer_data) ? route_trainer_data.Sprite : "YOUNGSTER.png";
            gym_trainer_sprite = demo_trainer_sprite_carregar_generico(_trainer_sprite_file);
            var _party_total = is_array(trainer_party) ? array_length(trainer_party) : 1;
            message = battle_trainer_name + " te desafiou com " + string(_party_total) + " monstros!";
        } else {
            battle_trainer_active = false;
            battle_trainer_name = "";
            var _shiny_prefix = is_struct(enemy_pokemon_data) && variable_struct_exists(enemy_pokemon_data, "IsShiny") && enemy_pokemon_data.IsShiny ? " CROMATICO" : "";
            message = "Um" + _shiny_prefix + " " + enemy_pokemon_data.Nome + " selvagem apareceu!";
        }

        battle_log_force(message);
    }
}

function demo_cleanup_battle(_controller) {
    if (!instance_exists(_controller)) {
        return;
    }

    with (_controller) {
        if (instance_exists(player_inst)) {
            instance_destroy(player_inst);
        }

        if (instance_exists(enemy_inst)) {
            instance_destroy(enemy_inst);
        }

        if (instance_exists(battle_manager)) {
            instance_destroy(battle_manager);
        }

        if (sprite_exists(gym_trainer_sprite)) {
            pokemon_sprite_liberar(gym_trainer_sprite);
            gym_trainer_sprite = -1;
        }

        with (obj_battle_ui) {
            instance_destroy();
        }

        with (obj_vfx_ataque) {
            instance_destroy();
        }

        battle_time_scale_restore_preferido();
        global.pokedex_overlay_aberto = false;
        global.mochila_overlay_aberta = false;
        global.troca_overlay_aberta = false;
        global.battle_fugir_solicitado = false;
        capture_anim = undefined;
        capture_pending_item = "";
        capture_pending_success = false;
        capture_replace_open = false;
        capture_replace_pokemon = undefined;
        battle_trainer_active = false;
        battle_trainer_name = "";

        if (variable_global_exists("estado_jogo")) {
            global.estado_jogo = EstadoJogo.EXPLORACAO;
        }
    }
}
