function BestiarioEntrada(_id, _nome, _tipo1, _tipo2, _hp, _atk, _def, _spd) constructor {
    ID = _id;
    Nome = _nome;
    Tipo1 = _tipo1;
    Tipo2 = _tipo2;
    HpMax = _hp;
    Attack = _atk;
    Defense = _def;
    Speed = _spd;
    RaridadePadrao = argument_count >= 9 ? argument[8] : CriaturaRaridade.COMMON;
    HabilidadeInicialNome = argument_count >= 10 ? argument[9] : "-";
    HabilidadeInicialTipo = argument_count >= 11 ? argument[10] : CriaturaTipo.NONE;
    Descoberto = false;
    Capturado = false;
    Capturas = 0;
}

function bestiario_save_path() {
    return (autoteste_ativo() ? "autoteste_" : "") + "bestiario_save.json";
}

function bestiario_inicializar() {
    var _bestiario_db = argument_count > 0 ? argument[0] : undefined;

    if (argument_count < 1 || !is_struct(_bestiario_db)) {
        if (variable_global_exists("bestiario")) {
            _bestiario_db = global.bestiario;
        } else {
            _bestiario_db = criatura_db_criar();
            global.bestiario = _bestiario_db;
        }
    }

    global.bestiario_estado = {};

    var _ids = variable_struct_get_names(_bestiario_db);

    for (var _i = 0; _i < array_length(_ids); _i += 1) {
        var _key = _ids[_i];
        var _criatura = variable_struct_get(_bestiario_db, _key);
        var _habilidade_inicial = criatura_habilidade_inicial_get(_criatura);

        variable_struct_set(
            global.bestiario_estado,
            _key,
            new BestiarioEntrada(
                _criatura.ID,
                _criatura.Nome,
                _criatura.Tipo1,
                _criatura.Tipo2,
                _criatura.HpMax,
                _criatura.Attack,
                _criatura.Defense,
                _criatura.Speed,
                variable_struct_exists(_criatura, "RaridadePadrao") ? _criatura.RaridadePadrao : CriaturaRaridade.COMMON,
                is_struct(_habilidade_inicial) ? _habilidade_inicial.Nome : "-",
                is_struct(_habilidade_inicial) ? _habilidade_inicial.TipoElementar : CriaturaTipo.NONE
            )
        );
    }

    bestiario_carregar();
}

function bestiario_garantir() {
    if (!variable_global_exists("bestiario_estado") || !is_struct(global.bestiario_estado)) {
        bestiario_inicializar();
    }
}

function bestiario_get(_id) {
    bestiario_garantir();

    var _key = string(_id);

    if (!variable_struct_exists(global.bestiario_estado, _key)) {
        return undefined;
    }

    return variable_struct_get(global.bestiario_estado, _key);
}

function bestiario_descobrir(_id) {
    var _entry = bestiario_get(_id);

    if (!is_struct(_entry)) {
        return false;
    }

    return _entry.Capturado;
}

function bestiario_capturar(_id) {
    var _entry = bestiario_get(_id);

    if (!is_struct(_entry)) {
        return false;
    }

    _entry.Descoberto = true;
    _entry.Capturado = true;
    _entry.Capturas = variable_struct_exists(_entry, "Capturas") ? (_entry.Capturas + 1) : 1;
    bestiario_salvar();
    return true;
}

function bestiario_exportar_save_struct() {
    bestiario_garantir();

    var _save = {};
    var _ids = variable_struct_get_names(global.bestiario_estado);

    for (var _i = 0; _i < array_length(_ids); _i += 1) {
        var _key = _ids[_i];
        var _entry = variable_struct_get(global.bestiario_estado, _key);

        variable_struct_set(_save, _key, {
            descoberto: _entry.Descoberto,
            capturado: _entry.Capturado,
            capturas: variable_struct_exists(_entry, "Capturas") ? _entry.Capturas : 0
        });
    }

    return _save;
}

function bestiario_salvar() {
    bestiario_garantir();

    var _json = json_stringify(bestiario_exportar_save_struct());
    var _file = file_text_open_write(bestiario_save_path());
    file_text_write_string(_file, _json);
    file_text_close(_file);
}

function bestiario_carregar() {
    if (!file_exists(bestiario_save_path())) {
        return false;
    }

    var _file = file_text_open_read(bestiario_save_path());
    var _json = "";

    while (!file_text_eof(_file)) {
        _json += file_text_read_string(_file);
        file_text_readln(_file);
    }

    file_text_close(_file);

    if (_json == "") {
        return false;
    }

    var _save = json_parse(_json);

    if (!is_struct(_save)) {
        return false;
    }

    var _ids = variable_struct_get_names(_save);

    for (var _i = 0; _i < array_length(_ids); _i += 1) {
        var _key = _ids[_i];

        if (!variable_struct_exists(global.bestiario_estado, _key)) {
            continue;
        }

        var _entry = variable_struct_get(global.bestiario_estado, _key);
        var _saved = variable_struct_get(_save, _key);
        _entry.Descoberto = variable_struct_exists(_saved, "descoberto") && _saved.descoberto;
        _entry.Capturado = variable_struct_exists(_saved, "capturado") && _saved.capturado;
        _entry.Capturas = variable_struct_exists(_saved, "capturas") ? _saved.capturas : (_entry.Capturado ? 1 : 0);
    }

    return true;
}

function bestiario_ui_get_sprite(_id) {
    if (!instance_exists(obj_game_manager)) {
        return -1;
    }

    var _key = string(_id);
    var _gm = instance_find(obj_game_manager, 0);

    if (variable_struct_exists(_gm.bestiario_ui_sprites, _key)) {
        return variable_struct_get(_gm.bestiario_ui_sprites, _key);
    }

    var _sprite = criatura_sprite_carregar_pose(_id, "idle", -1);
    variable_struct_set(_gm.bestiario_ui_sprites, _key, _sprite);
    return _sprite;
}

function bestiario_ui_liberar_sprites() {
    if (!instance_exists(obj_game_manager)) {
        return;
    }

    var _gm = instance_find(obj_game_manager, 0);
    var _keys = variable_struct_get_names(_gm.bestiario_ui_sprites);

    for (var _i = 0; _i < array_length(_keys); _i += 1) {
        var _sprite = variable_struct_get(_gm.bestiario_ui_sprites, _keys[_i]);
        criatura_sprite_liberar(_sprite);
    }

    _gm.bestiario_ui_sprites = {};
}

function bestiario_tipo_nome(_tipo) {
    if (_tipo == CriaturaTipo.NONE) {
        return "-";
    }

    return criatura_nome_tipo(_tipo);
}

function bestiario_geracao_por_id(_id) {
    // O filtro antigo de "geracao" agora filtra por estagio evolutivo (1, 2 ou 3).
    var _info = criatura_info(_id);
    return is_struct(_info) ? _info.Estagio : 0;
}

function bestiario_ui_filtros_init() {
    if (!variable_global_exists("bestiario_filtro_geracao")) {
        global.bestiario_filtro_geracao = 0;
    }

    if (!variable_global_exists("bestiario_filtro_raridade")) {
        global.bestiario_filtro_raridade = -1;
    }
}

function bestiario_ui_raridade_filtros() {
    return [
        -1,
        CriaturaRaridade.COMMON,
        CriaturaRaridade.UNCOMMON,
        CriaturaRaridade.RARE,
        CriaturaRaridade.EPIC,
        CriaturaRaridade.LEGENDARY
    ];
}

function bestiario_ui_raridade_filtro_nome(_raridade) {
    if (_raridade < 0) {
        return "Todas";
    }

    return criatura_raridade_nome(_raridade);
}

function bestiario_ui_button_hit(_mx, _my, _x, _y, _w, _h) {
    return _mx >= _x && _mx <= _x + _w && _my >= _y && _my <= _y + _h;
}

function bestiario_ui_draw_filter_button(_label, _x, _y, _w, _h, _active) {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _hover = bestiario_ui_button_hit(_mx, _my, _x, _y, _w, _h);
    var _grow = _hover ? 2 : 0;
    var _dx = _x - _grow;
    var _dy = _y - _grow;
    var _dw = _w + (_grow * 2);
    var _dh = _h + (_grow * 2);

    battle_ui_draw_nineslice_panel(_dx, _dy, _dw, _dh);

    if (_active) {
        draw_set_alpha(0.32);
        draw_set_color(make_color_rgb(245, 220, 86));
        draw_rectangle(_dx + 5, _dy + 5, _dx + _dw - 5, _dy + _dh - 5, false);
        draw_set_alpha(1);
    } else if (_hover) {
        draw_set_alpha(0.16);
        draw_set_color(c_white);
        draw_rectangle(_dx + 6, _dy + 6, _dx + _dw - 6, _dy + _dh - 6, false);
        draw_set_alpha(1);
    }

    battle_ui_draw_text_center_fit(_dx + (_dw * 0.5), _dy + (_dh * 0.5), _label, _dw - 12, _dh - 8, 0.62, sprite_exists(global.ui_panel_sprite) ? c_black : c_white);
}

function bestiario_ui_entry_passes_filters(_entry) {
    if (!is_struct(_entry) || !_entry.Capturado) {
        return false;
    }

    if (global.bestiario_filtro_geracao > 0 && bestiario_geracao_por_id(_entry.ID) != global.bestiario_filtro_geracao) {
        return false;
    }

    if (global.bestiario_filtro_raridade >= 0 && _entry.RaridadePadrao != global.bestiario_filtro_raridade) {
        return false;
    }

    return true;
}

function bestiario_ui_step() {
    if (!variable_global_exists("bestiario_overlay_aberto") || !global.bestiario_overlay_aberto) {
        return false;
    }

    bestiario_ui_filtros_init();

    if (!mouse_check_button_pressed(mb_left)) {
        return false;
    }

    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _x = 56;
    var _gen_y = 92;
    var _rar_y = 130;

    for (var _g = 0; _g <= 3; _g += 1) {
        var _btn_x = _x + 88 + (_g * 72);

        if (bestiario_ui_button_hit(_mx, _my, _btn_x, _gen_y, 66, 28)) {
            global.bestiario_filtro_geracao = _g;
            return true;
        }
    }

    var _rarities = bestiario_ui_raridade_filtros();
    var _rar_x = _x + 88;

    for (var _r = 0; _r < array_length(_rarities); _r += 1) {
        var _rar_w = _r == 0 ? 76 : 94;

        if (bestiario_ui_button_hit(_mx, _my, _rar_x, _rar_y, _rar_w, 28)) {
            global.bestiario_filtro_raridade = _rarities[_r];
            return true;
        }

        _rar_x += _rar_w + 8;
    }

    return false;
}

function bestiario_ui_draw_overlay() {
    bestiario_garantir();
    bestiario_ui_filtros_init();

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    draw_set_alpha(0.82);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    battle_ui_draw_nineslice_panel(28, 24, _gw - 56, _gh - 48);

    var _text_color = sprite_exists(global.ui_panel_sprite) ? c_black : c_white;
    draw_set_color(_text_color);
    i18n_draw_text(56, 44, "BESTIARIO");

    var _ids = variable_struct_get_names(global.bestiario_estado);
    var _capturados_total = 0;
    var _filtered = [];

    for (var _count_i = 0; _count_i < array_length(_ids); _count_i += 1) {
        var _count_entry = variable_struct_get(global.bestiario_estado, _ids[_count_i]);

        if (_count_entry.Capturado) {
            _capturados_total += 1;
        }

        if (bestiario_ui_entry_passes_filters(_count_entry)) {
            array_push(_filtered, _ids[_count_i]);
        }
    }

    i18n_draw_text(56, 66, "Capturados: " + string(_capturados_total) + " / " + string(array_length(_ids)) + "   P: fechar");

    i18n_draw_text(56, 98, "Estagio");

    for (var _g = 0; _g <= 3; _g += 1) {
        var _gen_label = _g == 0 ? "Todos" : "Est. " + string(_g);
        bestiario_ui_draw_filter_button(_gen_label, 144 + (_g * 72), 92, 66, 28, global.bestiario_filtro_geracao == _g);
    }

    i18n_draw_text(56, 136, "Raridade");
    var _rarities = bestiario_ui_raridade_filtros();
    var _rar_x = 144;

    for (var _r = 0; _r < array_length(_rarities); _r += 1) {
        var _raridade = _rarities[_r];
        var _rar_w = _r == 0 ? 76 : 94;
        bestiario_ui_draw_filter_button(bestiario_ui_raridade_filtro_nome(_raridade), _rar_x, 130, _rar_w, 28, global.bestiario_filtro_raridade == _raridade);
        _rar_x += _rar_w + 8;
    }

    var _cols = 3;
    var _gap = 12;
    var _cell_w = ((_gw - 112) - (_gap * (_cols - 1))) / _cols;
    var _cell_h = 136;
    var _start_x = 56;
    var _start_y = 178;
    var _max_rows = floor((_gh - _start_y - 54) / _cell_h);
    var _max_cards = max(1, _cols * max(1, _max_rows));
    var _shown = min(array_length(_filtered), _max_cards);

    if (_shown <= 0) {
        draw_set_color(_text_color);
        i18n_draw_text(_start_x, _start_y + 24, "Nenhum monstro capturado neste filtro.");
        draw_text(_start_x, _start_y + 52, "Capture monstros nas rotas para liberar dados completos aqui.");
        draw_set_color(c_white);
        return;
    }

    for (var _i = 0; _i < _shown; _i += 1) {
        var _entry = variable_struct_get(global.bestiario_estado, _filtered[_i]);
        var _col = _i mod _cols;
        var _row = floor(_i / _cols);
        var _x = _start_x + (_col * (_cell_w + _gap));
        var _y = _start_y + (_row * _cell_h);

        draw_set_color(make_color_rgb(242, 235, 208));
        draw_rectangle(_x, _y, _x + _cell_w, _y + _cell_h - 10, false);
        draw_set_color(make_color_rgb(108, 82, 68));
        draw_rectangle(_x, _y, _x + _cell_w, _y + _cell_h - 10, true);
        draw_rectangle(_x + 3, _y + 3, _x + _cell_w - 3, _y + _cell_h - 13, true);

        draw_set_color(make_color_rgb(196, 46, 54));
        draw_rectangle(_x + 4, _y + 4, _x + _cell_w - 4, _y + 32, false);
        criatura_raridade_draw_icon(_entry.RaridadePadrao, _x + 12, _y + 8, 20);

        var _sprite = bestiario_ui_get_sprite(_entry.ID);

        if (sprite_exists(_sprite)) {
            var _spr_scale = min(1.15, 62 / max(1, max(sprite_get_width(_sprite), sprite_get_height(_sprite))));
            draw_sprite_ext(_sprite, 0, _x + 64, _y + 86, _spr_scale, _spr_scale, 0, c_white, 1);
        }

        draw_set_color(c_white);
        battle_ui_draw_text_fit(_x + 40, _y + 9, "#" + string(_entry.ID) + " " + _entry.Nome, _cell_w - 116, 0.72, c_white);
        draw_set_halign(fa_right);
        i18n_draw_text_transformed(_x + _cell_w - 14, _y + 10, "x" + string(max(1, _entry.Capturas)), 0.64, 0.64, 0);
        draw_set_halign(fa_left);

        var _card_text = make_color_rgb(58, 42, 36); // corpo do card e claro
        draw_set_color(_card_text);
        battle_ui_draw_text_fit(_x + 106, _y + 44, bestiario_tipo_nome(_entry.Tipo1) + " / " + bestiario_tipo_nome(_entry.Tipo2), _cell_w - 122, 0.62, _card_text);
        battle_ui_draw_text_fit(_x + 106, _y + 66, "Inicial: " + _entry.HabilidadeInicialNome, _cell_w - 122, 0.58, _card_text);
        battle_ui_draw_text_fit(_x + 106, _y + 88, "Raridade: " + criatura_raridade_nome(_entry.RaridadePadrao), _cell_w - 122, 0.58, _card_text);
        battle_ui_draw_text_fit(_x + 106, _y + 106, "HP " + string(_entry.HpMax) + "  ATK " + string(_entry.Attack) + "  DEF " + string(_entry.Defense) + "  VEL " + string(_entry.Speed), _cell_w - 122, 0.52, _card_text);
    }

    if (array_length(_filtered) > _shown) {
        draw_set_color(_text_color);
        i18n_draw_text(56, _gh - 42, "Mostrando " + string(_shown) + " de " + string(array_length(_filtered)) + ". Use os filtros para afinar a lista.");
    }

    draw_set_color(c_white);
}
