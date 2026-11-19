function battle_ui_init() {
    if (!variable_global_exists("fila_texto_combate")) {
        global.fila_texto_combate = [];
    }

    if (!variable_global_exists("texto_combate_atual")) {
        global.texto_combate_atual = "";
    }

    if (!variable_global_exists("texto_combate_timer")) {
        global.texto_combate_timer = 0;
    }

    if (!variable_global_exists("historico_texto_combate")) {
        global.historico_texto_combate = [];
    }

    if (!variable_global_exists("battle_float_texts")) {
        global.battle_float_texts = [];
    }

    if (!variable_global_exists("battle_status_effect_sprite_cache")) {
        global.battle_status_effect_sprite_cache = {};
    }

    if (!variable_global_exists("screen_shake_timer")) {
        global.screen_shake_timer = 0;
        global.screen_shake_intensity = 0;
        global.screen_shake_x = 0;
        global.screen_shake_y = 0;
    }

    if (!variable_global_exists("battle_fugir_solicitado")) {
        global.battle_fugir_solicitado = false;
    }

    if (!variable_global_exists("time_scale")) {
        global.time_scale = 1.0;
    }

    if (!variable_global_exists("time_scale_preferido")) {
        global.time_scale_preferido = battle_time_scale_normalizar(global.time_scale);
    }

    if (!variable_global_exists("velocidade_jogo")) {
        global.velocidade_jogo = global.time_scale;
    }

    if (!variable_global_exists("bestiario_overlay_aberto")) {
        global.bestiario_overlay_aberto = false;
    }

    if (!variable_global_exists("mochila_overlay_aberta")) {
        global.mochila_overlay_aberta = false;
    }

    if (!variable_global_exists("troca_overlay_aberta")) {
        global.troca_overlay_aberta = false;
    }

    if (!variable_global_exists("ui_panel_sprite")) {
        global.ui_panel_sprite = -1;
    }

    if (!variable_global_exists("ui_databox_ally_sprite")) {
        global.ui_databox_ally_sprite = -1;
    }

    if (!variable_global_exists("ui_databox_foe_sprite")) {
        global.ui_databox_foe_sprite = -1;
    }

    if (!variable_global_exists("ui_ball_sprite")) {
        global.ui_ball_sprite = -1;
    }

    if (!variable_global_exists("ui_types_sprite")) {
        global.ui_types_sprite = -1;
    }

    if (!variable_global_exists("ui_font")) {
        global.ui_font = -1;
    }

    if (!variable_global_exists("ui_font_body")) {
        global.ui_font_body = -1;
    }

    if (!variable_global_exists("ui_assets_carregados")) {
        global.ui_assets_carregados = false;
    }

    if (!global.ui_assets_carregados) {
        global.ui_assets_carregados = true;
        global.ui_panel_sprite = demo_asset_sprite("datafiles/sprites/interface/painel.png");
        global.ui_databox_ally_sprite = demo_asset_sprite("datafiles/sprites/interface/caixa_aliado.png");
        global.ui_databox_foe_sprite = demo_asset_sprite("datafiles/sprites/interface/caixa_inimigo.png");
        global.ui_ball_sprite = demo_asset_sprite("datafiles/sprites/interface/icone_capsula.png");
        global.ui_types_sprite = demo_asset_sprite("datafiles/sprites/interface/tipos.png");

        // Fontes do jogo: coloque titulo.ttf e corpo.ttf em datafiles/fonts_jogo/.
        // Sem elas, usa uma fonte do proprio Windows so para desenvolvimento.
        var _font_path = project_asset_path("datafiles/fonts_jogo/titulo.ttf");
        var _font_body_path = project_asset_path("datafiles/fonts_jogo/corpo.ttf");
        var _font_size = 18;

        if (_font_path == "") {
            _font_path = battle_ui_fonte_sistema(["segoeuib.ttf", "verdanab.ttf", "arialbd.ttf"]);
            _font_size = 14;
        }

        if (_font_body_path == "") {
            _font_body_path = battle_ui_fonte_sistema(["segoeui.ttf", "verdana.ttf", "arial.ttf"]);
        }

        global.ui_font_path = _font_path;
        global.ui_font_body_path = _font_body_path;
        global.ui_font_tamanho = _font_size;

        if (_font_path != "") {
            global.ui_font = font_add(_font_path, _font_size, false, false, 32, 127);
        }

        if (_font_body_path != "") {
            global.ui_font_body = font_add(_font_body_path, _font_size, false, false, 32, 127);
        }
    }
}

function battle_ui_fonte_sistema(_arquivos) {
    for (var _i = 0; _i < array_length(_arquivos); _i += 1) {
        var _path = "C:/Windows/Fonts/" + _arquivos[_i];

        if (file_exists(_path)) {
            return _path;
        }
    }

    return "";
}

function battle_ui_font_title() {
    if (variable_global_exists("ui_font") && font_exists(global.ui_font)) {
        draw_set_font(global.ui_font);
    }
}

function battle_ui_font_body() {
    if (variable_global_exists("ui_font_body") && font_exists(global.ui_font_body)) {
        draw_set_font(global.ui_font_body);
    } else {
        battle_ui_font_title();
    }
}

function battle_time_scale_normalizar(_scale) {
    if (_scale <= 0) {
        return 1.0;
    }

    if (_scale < 1.25) {
        return 1.0;
    }

    if (_scale < 1.75) {
        return 1.5;
    }

    if (_scale < 2.5) {
        return 2.0;
    }

    return 3.0;
}

function battle_time_scale_garantir() {
    if (!variable_global_exists("time_scale_preferido")) {
        var _base = variable_global_exists("time_scale") ? global.time_scale : 1.0;
        global.time_scale_preferido = battle_time_scale_normalizar(_base);
    }

    if (!variable_global_exists("time_scale")) {
        global.time_scale = global.time_scale_preferido;
    }

    if (!variable_global_exists("velocidade_jogo")) {
        global.velocidade_jogo = global.time_scale;
    }
}

function battle_time_scale_set(_scale, _persistir) {
    battle_time_scale_garantir();

    var _novo = battle_time_scale_normalizar(_scale);

    if (_persistir) {
        global.time_scale_preferido = _novo;
    }

    global.time_scale = _novo;
    global.velocidade_jogo = _novo;
    return _novo;
}

function battle_time_scale_restore_preferido() {
    battle_time_scale_garantir();
    return battle_time_scale_set(global.time_scale_preferido, false);
}

function battle_time_scale_toggle_pause() {
    battle_time_scale_garantir();

    if (global.time_scale == 0) {
        return battle_time_scale_restore_preferido();
    }

    global.time_scale_preferido = battle_time_scale_normalizar(global.time_scale);
    global.time_scale = 0;
    global.velocidade_jogo = 0;
    return 0;
}

function battle_time_scale_cycle() {
    battle_time_scale_garantir();

    var _atual = global.time_scale == 0 ? global.time_scale_preferido : global.time_scale;
    var _normal = battle_time_scale_normalizar(_atual);
    var _novo = 1.0;

    if (_normal == 1.0) {
        _novo = 1.5;
    } else if (_normal == 1.5) {
        _novo = 2.0;
    } else if (_normal == 2.0) {
        _novo = 3.0;
    }

    return battle_time_scale_set(_novo, true);
}

function battle_ui_string_fit(_text, _max_w, _scale) {
    _text = i18n_t(_text);
    var _out = string(_text);

    if (_max_w <= 0) {
        return "";
    }

    if (i18n_string_width(_out) * _scale <= _max_w) {
        return _out;
    }

    while (string_length(_out) > 3 && i18n_string_width(_out + "...") * _scale > _max_w) {
        _out = string_delete(_out, string_length(_out), 1);
    }

    return _out + "...";
}

function battle_ui_draw_text_fit(_x, _y, _text, _max_w, _scale, _color) {
    draw_set_color(_color);
    i18n_draw_text_transformed(_x, _y, battle_ui_string_fit(_text, _max_w, _scale), _scale, _scale, 0);
}

function battle_ui_draw_text_center_fit(_x, _y, _text, _max_w, _max_h, _scale, _color) {
    var _fit_scale = _scale;
    var _tw = max(1, i18n_string_width(string(_text)));
    var _th = max(1, i18n_string_height(string(_text)));

    _fit_scale = min(_fit_scale, _max_w / _tw);
    _fit_scale = min(_fit_scale, _max_h / _th);
    _fit_scale = clamp(_fit_scale, 0.46, _scale);

    draw_set_color(_color);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    i18n_draw_text_transformed(_x, _y, string(_text), _fit_scale, _fit_scale, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

function battle_ui_type_row(_tipo) {
    switch (_tipo) {
        case CriaturaTipo.NORMAL: return 0;
        case CriaturaTipo.FIGHTING: return 1;
        case CriaturaTipo.FLYING: return 2;
        case CriaturaTipo.POISON: return 3;
        case CriaturaTipo.GROUND: return 4;
        case CriaturaTipo.ROCK: return 5;
        case CriaturaTipo.BUG: return 6;
        case CriaturaTipo.GHOST: return 7;
        case CriaturaTipo.STEEL: return 8;
        case CriaturaTipo.FIRE: return 10;
        case CriaturaTipo.WATER: return 11;
        case CriaturaTipo.GRASS: return 12;
        case CriaturaTipo.ELECTRIC: return 13;
        case CriaturaTipo.PSYCHIC: return 14;
        case CriaturaTipo.ICE: return 15;
        case CriaturaTipo.DRAGON: return 16;
        case CriaturaTipo.DARK: return 17;
        case CriaturaTipo.FAIRY: return 18;
    }

    return 9;
}

function battle_ui_type_color(_tipo) {
    switch (_tipo) {
        case CriaturaTipo.FIRE: return make_color_rgb(238, 116, 48);
        case CriaturaTipo.WATER: return make_color_rgb(80, 136, 232);
        case CriaturaTipo.GRASS: return make_color_rgb(104, 184, 72);
        case CriaturaTipo.ELECTRIC: return make_color_rgb(248, 208, 48);
        case CriaturaTipo.POISON: return make_color_rgb(160, 64, 160);
        case CriaturaTipo.FIGHTING: return make_color_rgb(194, 76, 48);
        case CriaturaTipo.GROUND: return make_color_rgb(210, 172, 96);
        case CriaturaTipo.ROCK: return make_color_rgb(176, 144, 80);
        case CriaturaTipo.FLYING: return make_color_rgb(144, 168, 232);
        case CriaturaTipo.PSYCHIC: return make_color_rgb(236, 88, 136);
        case CriaturaTipo.BUG: return make_color_rgb(146, 188, 58);
        case CriaturaTipo.GHOST: return make_color_rgb(112, 88, 152);
        case CriaturaTipo.DRAGON: return make_color_rgb(112, 88, 216);
        case CriaturaTipo.STEEL: return make_color_rgb(168, 184, 196);
        case CriaturaTipo.DARK: return make_color_rgb(88, 72, 104);
        case CriaturaTipo.FAIRY: return make_color_rgb(238, 153, 172);
        case CriaturaTipo.NORMAL: return make_color_rgb(168, 168, 120);
    }

    return make_color_rgb(120, 120, 120);
}

function battle_ui_type_label(_tipo) {
    switch (_tipo) {
        case CriaturaTipo.FIRE: return "FOGO";
        case CriaturaTipo.WATER: return "AGUA";
        case CriaturaTipo.GRASS: return "GRAMA";
        case CriaturaTipo.ELECTRIC: return "ELETRICO";
        case CriaturaTipo.POISON: return "VENENO";
        case CriaturaTipo.NORMAL: return "NORMAL";
        case CriaturaTipo.FIGHTING: return "LUTADOR";
        case CriaturaTipo.FLYING: return "VOADOR";
        case CriaturaTipo.GROUND: return "TERRA";
        case CriaturaTipo.ROCK: return "PEDRA";
        case CriaturaTipo.BUG: return "INSETO";
        case CriaturaTipo.GHOST: return "FANTASMA";
        case CriaturaTipo.STEEL: return "ACO";
        case CriaturaTipo.PSYCHIC: return "PSIQUICO";
        case CriaturaTipo.ICE: return "GELO";
        case CriaturaTipo.DRAGON: return "DRAGAO";
        case CriaturaTipo.DARK: return "SOMBRIO";
        case CriaturaTipo.FAIRY: return "FADA";
    }

    return "TIPO";
}

function battle_ui_draw_type_icon(_tipo, _x, _y, _scale) {
    battle_ui_init();

    if (sprite_exists(global.ui_types_sprite)) {
        var _rows = 19;
        var _sw = sprite_get_width(global.ui_types_sprite);
        var _row_h = sprite_get_height(global.ui_types_sprite) / _rows;
        var _row = battle_ui_type_row(_tipo);
        draw_sprite_part_ext(global.ui_types_sprite, 0, 0, _row * _row_h, _sw, _row_h, _x, _y, _scale, _scale, c_white, 1);
        return;
    }

    var _badge_w = 58 * _scale;
    var _badge_h = 20 * _scale;
    var _label = battle_ui_type_label(_tipo);

    draw_set_color(merge_color(battle_ui_type_color(_tipo), c_black, 0.45));
    draw_roundrect_ext(_x, _y, _x + _badge_w, _y + _badge_h, 6, 6, false);
    draw_set_color(battle_ui_type_color(_tipo));
    draw_roundrect_ext(_x + 1, _y + 1, _x + _badge_w - 1, _y + _badge_h - 1, 5, 5, false);
    battle_ui_draw_text_center_fit(_x + (_badge_w * 0.5), _y + (_badge_h * 0.5), _label, _badge_w - 6, _badge_h - 2, 0.55, c_white);
}

function battle_ui_skill_damage_text(_skill) {
    if (!is_struct(_skill)) {
        return "";
    }

    if (variable_struct_exists(_skill, "TipoOpcao") && _skill.TipoOpcao == "upgrade") {
        return criatura_habilidade_tier_nome(_skill.TierAtual) + " > " + criatura_habilidade_tier_nome(_skill.ProximoTier);
    }

    return _skill.DanoBase > 0 ? "Dano " + string(_skill.DanoBase) : "Suporte";
}

function battle_ui_draw_skill_summary(_skill, _x, _y, _w, _show_description) {
    if (!is_struct(_skill)) {
        return undefined;
    }

    var _text_color = sprite_exists(global.ui_panel_sprite) ? c_black : c_white;
    var _tooltip = undefined;

    battle_ui_draw_type_icon(_skill.TipoElementar, _x, _y + 2, 0.82);
    draw_set_color(_text_color);
    battle_ui_font_title();
    battle_ui_draw_text_fit(_x + 62, _y - 2, _skill.Nome, _w - 66, 0.95, _text_color);
    battle_ui_font_body();
    var _escuro = !sprite_exists(global.ui_panel_sprite);
    var _cor_info = _escuro ? make_color_rgb(190, 200, 230) : make_color_rgb(80, 72, 66);

    if (variable_struct_exists(_skill, "TipoOpcao") && _skill.TipoOpcao == "upgrade") {
        draw_set_color(ui_cor("ouro"));
        i18n_draw_text_transformed(_x + 62, _y + 30, battle_ui_skill_damage_text(_skill), 0.85, 0.85, 0);
        draw_set_color(_text_color);
        i18n_draw_text_ext(_x, _y + 72, "Evolui esta habilidade, aumentando dano, efeito ou reduzindo recarga.", 24, _w);
        battle_ui_font_title();
        return undefined;
    }

    draw_set_color(_cor_info);
    i18n_draw_text_transformed(_x + 62, _y + 30, battle_ui_skill_damage_text(_skill) + "   |   CD " + string_format(_skill.TempoRecargaMax, 1, 1) + "s", 0.85, 0.85, 0);
    draw_set_color(_text_color);

    if (_show_description) {
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        global.ui_tinta_override = _text_color;
        _tooltip = demo_draw_habilidade_descricao_rica(_skill, _x, _y + 72, _w, _mx, _my, 2);
        global.ui_tinta_override = undefined;
    }

    battle_ui_font_title();
    return _tooltip;
}

function battle_ui_draw_skill_slot(_skill, _x, _y, _w, _h, _is_next) {
    battle_ui_draw_nineslice_panel(_x, _y, _w, _h);
    var _text_color = sprite_exists(global.ui_panel_sprite) ? c_black : c_white;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _hover = battle_ui_button_hit(_mx, _my, _x, _y, _w, _h);

    if (_hover) {
        draw_set_alpha(0.22);
        draw_set_color(make_color_rgb(245, 220, 86));
        draw_rectangle(_x + 6, _y + 6, _x + _w - 6, _y + _h - 6, false);
        draw_set_alpha(1);
    }

    if (!is_struct(_skill)) {
        var _trancado = variable_global_exists("ui_slot_trancado") ? global.ui_slot_trancado : "";

        if (_trancado != "") {
            draw_set_alpha(0.55);
            battle_ui_draw_text_fit(_x + 28, _y + 20, "Trancado", _w - 56, 0.74, _text_color);
            battle_ui_font_body();
            battle_ui_draw_text_fit(_x + 28, _y + 50, _trancado, _w - 56, 0.66, _text_color);
            battle_ui_font_title();
            draw_set_alpha(1);
            return undefined;
        }

        battle_ui_draw_text_fit(_x + 28, _y + 20, "Vazio", _w - 56, 0.74, _text_color);
        return undefined;
    }

    // Proxima habilidade a disparar: contorno ciano; hover: borda de selecao.
    if (_is_next) {
        draw_set_alpha(0.55 + (0.3 * sin(current_time * 0.008)));
        draw_set_color(make_color_rgb(120, 230, 255));
        draw_roundrect_ext(_x + 2, _y + 2, _x + _w - 2, _y + _h - 2, 8, 8, true);
        draw_set_alpha(1);
    }

    if (_hover) {
        ui_borda_selecao(_x, _y, _w, _h);
    }

    battle_ui_draw_type_icon(_skill.TipoElementar, _x + 26, _y + 22, 0.66);

    battle_ui_font_title();
    battle_ui_draw_text_fit(_x + 92, _y + 17, _skill.Nome, _w - 126, 0.72, _text_color);
    battle_ui_font_body();
    battle_ui_draw_text_fit(_x + 92, _y + 46, battle_ui_skill_damage_text(_skill) + "  CD " + string_format(_skill.TempoRecargaMax, 1, 1) + "s", _w - 126, 0.62, _text_color);
    battle_ui_font_title();

    var _cooldown = max(0, _skill.TempoRecargaAtual);
    var _pct = 1 - clamp(_cooldown / max(0.01, _skill.TempoRecargaMax), 0, 1);
    draw_set_color(c_dkgray);
    draw_rectangle(_x + 26, _y + _h - 22, _x + _w - 26, _y + _h - 14, false);
    draw_set_color(_is_next ? make_color_rgb(245, 220, 86) : make_color_rgb(48, 216, 216));
    draw_rectangle(_x + 26, _y + _h - 22, _x + 26 + ((_w - 52) * _pct), _y + _h - 14, false);

    draw_set_color(_text_color);
    var _ready_text = _cooldown <= 0.05 ? "PRONTO" : string_format(_cooldown, 1, 1) + "s";
    draw_set_halign(fa_right);
    i18n_draw_text_transformed(_x + _w - 32, _y + _h - 42, _ready_text, 0.66, 0.66, 0);
    draw_set_halign(fa_left);

    // Selo de sinergia cruzada ativa (scr_combate_extras).
    var _dono = battle_ui_get_primary_ally();
    var _sinergia = instance_exists(_dono) ? sinergia_texto(_dono.habilidades_equipadas, _skill) : "";

    if (_sinergia != "") {
        draw_set_color(make_color_rgb(120, 230, 255));
        draw_set_halign(fa_right);
        i18n_draw_text_transformed(_x + _w - 14, _y + 6, "SINERGIA", 0.5, 0.5, 0);
        draw_set_halign(fa_left);
    }

    if (_hover) {
        return {
            X: _mx,
            Y: _my,
            Texto: habilidade_descricao_curta(_skill) + (_sinergia != "" ? "\n" + _sinergia : "")
        };
    }

    return undefined;
}

function battle_log_push(_texto) {
    battle_ui_init();
    array_push(global.fila_texto_combate, _texto);
    battle_log_step(0);
}

function battle_log_add_line(_texto) {
    battle_ui_init();
    array_push(global.historico_texto_combate, _texto);

    while (array_length(global.historico_texto_combate) > 3) {
        array_delete(global.historico_texto_combate, 0, 1);
    }

    global.texto_combate_atual = _texto;
}

function battle_log_force(_texto) {
    battle_ui_init();
    global.fila_texto_combate = [];
    global.historico_texto_combate = [];
    battle_log_add_line(_texto);
    global.texto_combate_timer = 0.35;
}

function battle_log_step(_dt) {
    battle_ui_init();

    if (global.texto_combate_timer > 0) {
        global.texto_combate_timer -= _dt;

        if (global.texto_combate_timer > 0) {
            return;
        }
    }

    if (array_length(global.fila_texto_combate) <= 0) {
        return;
    }

    battle_log_add_line(global.fila_texto_combate[0]);
    array_delete(global.fila_texto_combate, 0, 1);
    global.texto_combate_timer = 0.35;
}

function battle_screen_shake(_intensity, _duration) {
    battle_ui_init();
    global.screen_shake_intensity = max(global.screen_shake_intensity, _intensity);
    global.screen_shake_timer = max(global.screen_shake_timer, _duration);
}

function battle_screen_shake_step(_dt) {
    battle_ui_init();

    if (global.screen_shake_timer <= 0) {
        global.screen_shake_x = 0;
        global.screen_shake_y = 0;
        return;
    }

    global.screen_shake_timer -= _dt;
    global.screen_shake_x = random_range(-global.screen_shake_intensity, global.screen_shake_intensity);
    global.screen_shake_y = random_range(-global.screen_shake_intensity, global.screen_shake_intensity);

    if (global.screen_shake_timer <= 0) {
        global.screen_shake_intensity = 0;
    }
}

function battle_float_text_push(_x, _y, _texto, _cor) {
    battle_ui_init();
    array_push(global.battle_float_texts, {
        X: _x,
        Y: _y,
        Texto: _texto,
        Cor: _cor,
        Timer: 0.85,
        Duracao: 0.85
    });
}

function battle_float_text_step(_dt) {
    battle_ui_init();

    for (var _i = array_length(global.battle_float_texts) - 1; _i >= 0; _i -= 1) {
        var _item = global.battle_float_texts[_i];
        _item.Timer -= _dt;
        _item.Y -= 22 * _dt;

        if (_item.Timer <= 0) {
            array_delete(global.battle_float_texts, _i, 1);
        }
    }

    battle_combo_step(_dt);
}

function battle_float_text_draw_gui() {
    battle_ui_init();

    for (var _i = 0; _i < array_length(global.battle_float_texts); _i += 1) {
        var _item = global.battle_float_texts[_i];
        var _alpha = clamp(_item.Timer / _item.Duracao, 0, 1);
        draw_set_alpha(_alpha);
        draw_set_color(c_black);
        i18n_draw_text(_item.X + 2, _item.Y + 2, _item.Texto);
        draw_set_color(_item.Cor);
        i18n_draw_text(_item.X, _item.Y, _item.Texto);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    battle_combo_draw_gui();
}

function battle_ui_draw_nineslice_panel(_x, _y, _w, _h) {
    if (!variable_global_exists("ui_panel_sprite")) {
        battle_ui_init();
    }

    var _spr = global.ui_panel_sprite;

    if (sprite_exists(_spr)) {
        var _b = 8;
        var _sw = sprite_get_width(_spr);
        var _sh = sprite_get_height(_spr);
        draw_sprite_part_ext(_spr, 0, 0, 0, _b, _b, _x, _y, 1, 1, c_white, 1);
        draw_sprite_part_ext(_spr, 0, _b, 0, _sw - (_b * 2), _b, _x + _b, _y, (_w - (_b * 2)) / max(1, _sw - (_b * 2)), 1, c_white, 1);
        draw_sprite_part_ext(_spr, 0, _sw - _b, 0, _b, _b, _x + _w - _b, _y, 1, 1, c_white, 1);
        draw_sprite_part_ext(_spr, 0, 0, _b, _b, _sh - (_b * 2), _x, _y + _b, 1, (_h - (_b * 2)) / max(1, _sh - (_b * 2)), c_white, 1);
        draw_sprite_part_ext(_spr, 0, _b, _b, _sw - (_b * 2), _sh - (_b * 2), _x + _b, _y + _b, (_w - (_b * 2)) / max(1, _sw - (_b * 2)), (_h - (_b * 2)) / max(1, _sh - (_b * 2)), c_white, 1);
        draw_sprite_part_ext(_spr, 0, _sw - _b, _b, _b, _sh - (_b * 2), _x + _w - _b, _y + _b, 1, (_h - (_b * 2)) / max(1, _sh - (_b * 2)), c_white, 1);
        draw_sprite_part_ext(_spr, 0, 0, _sh - _b, _b, _b, _x, _y + _h - _b, 1, 1, c_white, 1);
        draw_sprite_part_ext(_spr, 0, _b, _sh - _b, _sw - (_b * 2), _b, _x + _b, _y + _h - _b, (_w - (_b * 2)) / max(1, _sw - (_b * 2)), 1, c_white, 1);
        draw_sprite_part_ext(_spr, 0, _sw - _b, _sh - _b, _b, _b, _x + _w - _b, _y + _h - _b, 1, 1, c_white, 1);
        return;
    }

    // Painel escuro de reserva: sem a arte do painel, a interface escreve em branco por cima.
    var _alpha_painel = draw_get_alpha();
    draw_set_color(make_color_rgb(196, 204, 230));
    draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 10, 10, false);
    draw_rectangle_colour(_x + 3, _y + 3, _x + _w - 3, _y + _h - 3, make_color_rgb(34, 40, 66), make_color_rgb(34, 40, 66), make_color_rgb(20, 22, 38), make_color_rgb(20, 22, 38), false);
    draw_set_alpha(_alpha_painel * 0.35);
    draw_set_color(c_white);
    draw_line(_x + 8, _y + 4, _x + _w - 8, _y + 4);
    draw_set_alpha(_alpha_painel);
    draw_set_color(make_color_rgb(70, 80, 120));
    draw_roundrect_ext(_x + 5, _y + 5, _x + _w - 5, _y + _h - 5, 6, 6, true);
    draw_set_color(make_color_rgb(255, 222, 120));
    draw_rectangle(_x + 3, _y + 3, _x + 5, _y + 5, false);
    draw_rectangle(_x + _w - 5, _y + 3, _x + _w - 3, _y + 5, false);
    draw_rectangle(_x + 3, _y + _h - 5, _x + 5, _y + _h - 3, false);
    draw_rectangle(_x + _w - 5, _y + _h - 5, _x + _w - 3, _y + _h - 3, false);
}

function battle_ui_hp_color(_percent) {
    if (_percent <= 0.25) {
        return c_red;
    }

    if (_percent <= 0.5) {
        return c_yellow;
    }

    return c_lime;
}

function battle_status_visual_make(_kind, _asset, _color, _label) {
    return {
        Kind: _kind,
        Asset: _asset,
        Color: _color,
        Label: _label
    };
}

function battle_status_visual_infer_kind(_status_id) {
    var _id = string_lower(string(_status_id));

    if (string_pos("enven", _id) > 0 || string_pos("queim", _id) > 0 || string_pos("granizo", _id) > 0) {
        return "icon";
    }

    if (string_pos("paralis", _id) > 0 || string_pos("gel", _id) > 0 || string_pos("congel", _id) > 0) {
        return "icon";
    }

    if (string_pos("fragil", _id) > 0 || string_pos("vulner", _id) > 0 || string_pos("corro", _id) > 0) {
        return "icon";
    }

    if (string_pos("postura", _id) > 0 || string_pos("areia", _id) > 0 || string_pos("desab", _id) > 0) {
        return "icon";
    }

    if (string_pos("turbul", _id) > 0 || string_pos("rasante", _id) > 0 || string_pos("amnesia", _id) > 0 || string_pos("distorcao", _id) > 0) {
        return "icon";
    }

    if (string_pos("seda", _id) > 0 || string_pos("infestad", _id) > 0) {
        return "icon";
    }

    if (string_pos("fragment", _id) > 0 || string_pos("assombr", _id) > 0 || string_pos("maldito", _id) > 0 || string_pos("amedront", _id) > 0) {
        return "icon";
    }

    return "aura";
}

function battle_status_visual_data(_status_id) {
    // Icones ficam na caixa de status; auras ficam animadas sobre a criatura.
    switch (string(_status_id)) {
        case "Envenenado": return battle_status_visual_make("icon", "poison", make_color_rgb(168, 72, 184), "VEN");
        case "Queimando": return battle_status_visual_make("icon", "fire4", make_color_rgb(240, 92, 38), "QMD");
        case "Granizo": return battle_status_visual_make("icon", "016-Ice01", make_color_rgb(130, 220, 245), "HZD");
        case "Paralisado": return battle_status_visual_make("icon", "electric1", make_color_rgb(248, 214, 58), "PAR");
        case "Gelado": return battle_status_visual_make("icon", "Ice1", make_color_rgb(132, 220, 248), "GEL");
        case "Congelando": return battle_status_visual_make("icon", "Ice1", make_color_rgb(168, 238, 255), "CGL");
        case "Fragil": return battle_status_visual_make("icon", "016-Ice01", make_color_rgb(182, 236, 255), "FRG");
        case "Corroendo": return battle_status_visual_make("icon", "poison3", make_color_rgb(126, 214, 92), "CRR");
        case "Vulneravel": return battle_status_visual_make("icon", "mixed status", make_color_rgb(246, 198, 74), "VUL");
        case "ArmaduraDerretida": return battle_status_visual_make("icon", "Fire3", make_color_rgb(232, 94, 34), "MEL");
        case "CalorEscaldante": return battle_status_visual_make("icon", "015-Fire01", make_color_rgb(244, 150, 52), "HOT");
        case "NevoaEstagnante": return battle_status_visual_make("icon", "Water pulse", make_color_rgb(146, 198, 230), "SLO");
        case "ErroEletrico": return battle_status_visual_make("icon", "electric2", make_color_rgb(255, 226, 66), "ERR");
        case "PosturaQuebrada": return battle_status_visual_make("icon", "mixed status", make_color_rgb(226, 118, 58), "BRK");
        case "AreiaMovedica": return battle_status_visual_make("icon", "Overworld dust and grass", make_color_rgb(198, 156, 88), "SND");
        case "Desabando": return battle_status_visual_make("icon", "Rock4", make_color_rgb(174, 132, 82), "CRS");
        case "MarcadoRasante": return battle_status_visual_make("icon", "Wind1", make_color_rgb(150, 188, 238), "MRK");
        case "Turbulento": return battle_status_visual_make("icon", "Wind4", make_color_rgb(126, 178, 226), "TRB");
        case "ParalisiaMental": return battle_status_visual_make("icon", "confused", make_color_rgb(236, 92, 150), "MND");
        case "AmnesiaInduzida": return battle_status_visual_make("icon", "confused", make_color_rgb(202, 116, 226), "AMN");
        case "DistorcaoEspacial": return battle_status_visual_make("icon", "mixed status", make_color_rgb(180, 112, 236), "DST");
        case "SedaPresa": return battle_status_visual_make("icon", "mixed status", make_color_rgb(204, 220, 164), "WEB");
        case "Infestado": return battle_status_visual_make("icon", "poison2", make_color_rgb(132, 176, 54), "INF");
        case "Fragmentado": return battle_status_visual_make("icon", "Rock4", make_color_rgb(188, 146, 84), "FRG");
        case "Assombrado": return battle_status_visual_make("icon", "confused", make_color_rgb(134, 102, 190), "HAU");
        case "Maldito": return battle_status_visual_make("icon", "mixed status", make_color_rgb(124, 78, 164), "CRS");
        case "Amedrontado": return battle_status_visual_make("icon", "confused", make_color_rgb(92, 74, 142), "FRR");
        case "MarcadoSombrio": return battle_status_visual_make("icon", "mixed status", make_color_rgb(82, 62, 112), "MRK");
        case "BrilhoOfuscante": return battle_status_visual_make("icon", "confused", make_color_rgb(244, 164, 204), "GLR");

        case "Enraizado": return battle_status_visual_make("aura", "leech-seed", make_color_rgb(72, 190, 80), "ROOT");
        case "Crescimento": return battle_status_visual_make("aura", "grass2", make_color_rgb(124, 220, 80), "GRO");
        case "Fotossintese": return battle_status_visual_make("aura", "Heal5", make_color_rgb(244, 232, 112), "SUN");
        case "ToxinaAtiva": return battle_status_visual_make("aura", "poison2", make_color_rgb(184, 78, 192), "TOX");
        case "CalorConcentrado": return battle_status_visual_make("aura", "Fire3", make_color_rgb(250, 132, 42), "HEAT");
        case "FenixAtiva": return battle_status_visual_make("aura", "Firebird", make_color_rgb(255, 116, 56), "PHX");
        case "Molhado": return battle_status_visual_make("aura", "018-Water01", make_color_rgb(82, 170, 246), "WET");
        case "FluxoAcelerado": return battle_status_visual_make("aura", "water3", make_color_rgb(86, 216, 240), "FLOW");
        case "MareAlta": return battle_status_visual_make("aura", "Water pulse", make_color_rgb(88, 166, 232), "TIDE");
        case "Ofuscado": return battle_status_visual_make("aura", "confused", make_color_rgb(255, 228, 88), "BLD");
        case "Sobrecarregado": return battle_status_visual_make("aura", "Thunder2", make_color_rgb(255, 225, 62), "CHG");
        case "EstaticaAtiva": return battle_status_visual_make("aura", "017-Thunder01", make_color_rgb(252, 222, 58), "STC");
        case "MantoGelo": return battle_status_visual_make("aura", "016-Ice01", make_color_rgb(172, 236, 255), "GEL");
        case "ImpetoOfensivo": return battle_status_visual_make("aura", "attack", make_color_rgb(238, 88, 54), "IMP");
        case "EspiritoLuta": return battle_status_visual_make("aura", "Heal3", make_color_rgb(236, 126, 76), "SPI");
        case "BarreiraLama": return battle_status_visual_make("aura", "rockice", make_color_rgb(162, 124, 76), "MUD");
        case "Aterrado": return battle_status_visual_make("aura", "Overworld dust and grass", make_color_rgb(198, 164, 92), "GRD");
        case "VentoDeCauda": return battle_status_visual_make("aura", "Wind3", make_color_rgb(150, 204, 238), "WND");
        case "PenasLeves": return battle_status_visual_make("aura", "Wind2", make_color_rgb(196, 224, 248), "FTH");
        case "Evasivo": return battle_status_visual_make("aura", "Wind1", make_color_rgb(174, 214, 246), "EVA");
        case "EscudoCinetico": return battle_status_visual_make("aura", "Barrier", make_color_rgb(214, 144, 246), "KIN");
        case "FocoPsiquico": return battle_status_visual_make("aura", "Magic2", make_color_rgb(238, 116, 178), "PSY");
        case "EnxameAtivo": return battle_status_visual_make("aura", "attack", make_color_rgb(176, 210, 68), "SWM");
        case "CasuloRigido": return battle_status_visual_make("aura", "mixed status", make_color_rgb(188, 206, 128), "COC");
        case "Metamorfose": return battle_status_visual_make("aura", "Heal3", make_color_rgb(158, 216, 96), "MOR");
        case "ImpactoGeologico": return battle_status_visual_make("aura", "Rock4", make_color_rgb(190, 144, 82), "GEO");
        case "CascaRocha": return battle_status_visual_make("aura", "rockice", make_color_rgb(178, 148, 98), "RCK");
        case "FossilVivo": return battle_status_visual_make("aura", "rockice", make_color_rgb(174, 142, 96), "FSL");
        case "TerrorCrescente": return battle_status_visual_make("aura", "Magic2", make_color_rgb(136, 92, 190), "TRR");
        case "Intangivel": return battle_status_visual_make("aura", "Magic2", make_color_rgb(156, 132, 214), "INT");
        case "EssenciaDrenada": return battle_status_visual_make("aura", "Heal3", make_color_rgb(124, 88, 172), "ESS");
        case "FuriaDraconica": return battle_status_visual_make("aura", "attack", make_color_rgb(128, 84, 232), "DRG");
        case "EscamaImperial": return battle_status_visual_make("aura", "Barrier", make_color_rgb(118, 104, 226), "SCL");
        case "AscensaoDraconica": return battle_status_visual_make("aura", "Magic2", make_color_rgb(154, 116, 250), "ASC");
        case "Predador": return battle_status_visual_make("aura", "attack", make_color_rgb(96, 78, 190), "PRD");
        case "EspinhosFerro": return battle_status_visual_make("aura", "mixed status", make_color_rgb(180, 198, 204), "THR");
        case "Fortificado": return battle_status_visual_make("aura", "Barrier", make_color_rgb(174, 188, 198), "FOR");
        case "BlindagemMagnetica": return battle_status_visual_make("aura", "Barrier", make_color_rgb(136, 204, 220), "MAG");
        case "ImpactoPesado": return battle_status_visual_make("aura", "attack", make_color_rgb(168, 176, 184), "HVY");
        case "LigaPesada": return battle_status_visual_make("aura", "rockice", make_color_rgb(154, 166, 174), "ALY");
        case "GolpeBaixo": return battle_status_visual_make("aura", "attack", make_color_rgb(78, 62, 108), "LOW");
        case "JogoSujo": return battle_status_visual_make("aura", "mixed status", make_color_rgb(96, 74, 116), "FOU");
        case "CamuflagemSombria": return battle_status_visual_make("aura", "confused", make_color_rgb(70, 58, 96), "CAM");
        case "CopiaSombria": return battle_status_visual_make("aura", "Magic2", make_color_rgb(92, 76, 130), "CPY");
        case "PerseguicaoSombria": return battle_status_visual_make("aura", "attack", make_color_rgb(82, 60, 114), "PRS");
        case "EncantoCarga": return battle_status_visual_make("aura", "Magic2", make_color_rgb(244, 146, 204), "CHG");
        case "LuzPurificadora": return battle_status_visual_make("aura", "Heal5", make_color_rgb(252, 214, 228), "CLR");
        case "AuraMistica": return battle_status_visual_make("aura", "Magic2", make_color_rgb(224, 158, 238), "AUR");
        case "BarreiraFada": return battle_status_visual_make("aura", "Barrier", make_color_rgb(246, 176, 214), "BAR");
        case "ForcaNeutra": return battle_status_visual_make("aura", "attack", make_color_rgb(188, 178, 132), "FOR");
        case "EstoqueDefensivo": return battle_status_visual_make("aura", "Barrier", make_color_rgb(184, 170, 128), "STK");
        case "LegadoAtivo": return battle_status_visual_make("aura", "Heal3", make_color_rgb(198, 190, 144), "LEG");
        case "MimetismoAtivo": return battle_status_visual_make("aura", "mixed status", make_color_rgb(174, 170, 132), "MIM");
        case "ReciclagemAtiva": return battle_status_visual_make("aura", "Heal3", make_color_rgb(202, 194, 128), "REC");
    }

    return battle_status_visual_make(
        battle_status_visual_infer_kind(_status_id),
        "mixed status",
        make_color_rgb(196, 196, 196),
        string_copy(string_upper(string(_status_id)), 1, 3)
    );
}

function battle_status_effect_sprite_get(_asset) {
    if (!is_string(_asset) || _asset == "") {
        return -1;
    }

    if (!variable_global_exists("battle_status_effect_sprite_cache") || !is_struct(global.battle_status_effect_sprite_cache)) {
        global.battle_status_effect_sprite_cache = {};
    }

    var _key = string_replace_all(_asset, " ", "_");

    if (variable_struct_exists(global.battle_status_effect_sprite_cache, _key)) {
        return variable_struct_get(global.battle_status_effect_sprite_cache, _key);
    }

    var _sprite = demo_asset_sprite("datafiles/sprites/efeitos/" + _asset + ".png");


    if (sprite_exists(_sprite)) {
        sprite_set_offset(_sprite, sprite_get_width(_sprite) * 0.5, sprite_get_height(_sprite) * 0.5);
    }

    variable_struct_set(global.battle_status_effect_sprite_cache, _key, _sprite);
    return _sprite;
}

function battle_status_draw_icon(_status_id, _x, _y, _size) {
    var _data = battle_status_visual_data(_status_id);
    var _spr = battle_status_effect_sprite_get(_data.Asset);
    var _label = string(_data.Label);
    var _w = max(_size + 12, i18n_string_width(_label) * 0.50 + 12);
    var _h = max(18, _size + 4);
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _hover = battle_ui_button_hit(_mx, _my, _x - 2, _y - 2, _w + 4, _h + 4);
    var _grow = _hover ? 1 : 0;
    var _dx = _x - _grow;
    var _dy = _y - _grow;
    var _dw = _w + (_grow * 2);
    var _dh = _h + (_grow * 2);

    draw_set_alpha(0.82);
    draw_set_color(c_black);
    draw_rectangle(_dx - 1, _dy - 1, _dx + _dw + 1, _dy + _dh + 1, false);
    draw_set_alpha(1);

    if (sprite_exists(_spr)) {
        draw_set_color(merge_color(_data.Color, c_black, 0.16));
        draw_rectangle(_dx, _dy, _dx + _dw, _dy + _dh, false);
        var _icon_size = min(_size, _dh - 4);
        var _scale = min(_icon_size / max(1, sprite_get_width(_spr)), _icon_size / max(1, sprite_get_height(_spr)));
        draw_sprite_ext(_spr, 0, _dx + (_dh * 0.5), _dy + (_dh * 0.5), _scale, _scale, 0, c_white, 1);
        draw_set_color(c_white);
        battle_ui_draw_text_center_fit(_dx + (_dh + ((_dw - _dh) * 0.5)), _dy + (_dh * 0.5) + 1, _label, max(8, _dw - _dh - 4), _dh - 4, 0.46, c_white);
    } else {
        draw_set_color(_data.Color);
        draw_rectangle(_dx, _dy, _dx + _dw, _dy + _dh, false);
        battle_ui_draw_text_center_fit(_dx + (_dw * 0.5), _dy + (_dh * 0.5) + 1, _label, _dw - 6, _dh - 4, 0.50, c_black);
    }

    draw_set_color(_data.Color);
    draw_rectangle(_dx, _dy, _dx + _dw, _dy + _dh, true);
    draw_set_color(c_white);
    draw_rectangle(_dx + 2, _dy + 2, _dx + _dw - 2, _dy + 4, false);
    draw_set_color(c_white);
    draw_set_alpha(1);

    if (_hover) {
        return {
            Texto: demo_status_tooltip_texto(_status_id),
            X: _dx + (_dw * 0.5),
            Y: _dy - 8,
            W: _dw
        };
    }

    return { W: _w, H: _h };
}

function battle_ui_draw_status_icons(_inst, _x, _y, _size) {
    if (!instance_exists(_inst) || !is_struct(_inst.status_map)) {
        return undefined;
    }

    var _keys = variable_struct_get_names(_inst.status_map);
    var _drawn = 0;
    var _cursor_x = _x;
    var _tooltip = undefined;

    for (var _i = 0; _i < array_length(_keys); _i += 1) {
        var _status_id = _keys[_i];
        var _data = battle_status_visual_data(_status_id);

        if (_data.Kind != "icon") {
            continue;
        }

        var _draw_info = battle_status_draw_icon(_status_id, _cursor_x, _y, _size);

        if (is_struct(_draw_info)) {
            if (variable_struct_exists(_draw_info, "Texto")) {
                _tooltip = _draw_info;
            }

            if (variable_struct_exists(_draw_info, "W")) {
                _cursor_x += _draw_info.W + 4;
            } else {
                _cursor_x += _size + 4;
            }
        } else {
            _cursor_x += _size + 4;
        }

        _drawn += 1;

        if (_drawn >= 8) {
            break;
        }
    }

    return _tooltip;
}

function battle_status_draw_world_fallback(_status_id, _x, _foot_y, _scale, _color, _pulse) {
    var _id = string(_status_id);
    var _body_y = _foot_y - (52 * _scale);

    draw_set_alpha(0.36);
    draw_set_color(_color);

    if (_id == "Enraizado") {
        for (var _i = -2; _i <= 2; _i += 1) {
            var _root_x = _x + (_i * 14 * _scale);
            var _top_x = _root_x + (sin((current_time * 0.006) + _i) * 8 * _scale);
            draw_line_width(_root_x, _foot_y - 4, _top_x, _foot_y - (42 * _scale), max(1, 2 * _scale));
            draw_circle(_top_x, _foot_y - (42 * _scale), 3 * _scale, false);
        }
    } else if (_id == "Fotossintese" || _id == "Crescimento") {
        draw_circle(_x, _body_y, (34 + (_pulse * 8)) * _scale, true);
        for (var _sun = 0; _sun < 6; _sun += 1) {
            var _ang = (current_time * 0.003) + (_sun * 1.0472);
            draw_circle(_x + cos(_ang) * 42 * _scale, _body_y + sin(_ang) * 24 * _scale, 4 * _scale, false);
        }
    } else if (_id == "Ofuscado") {
        for (var _spark = 0; _spark < 5; _spark += 1) {
            var _a = (current_time * 0.006) + (_spark * 1.256);
            draw_circle(_x + cos(_a) * 42 * _scale, _body_y + sin(_a) * 22 * _scale, 5 * _scale, false);
        }
    } else if (_id == "Sobrecarregado" || _id == "EstaticaAtiva") {
        for (var _bolt = 0; _bolt < 4; _bolt += 1) {
            var _bx = _x - 34 * _scale + (_bolt * 22 * _scale);
            draw_line_width(_bx, _body_y - 26 * _scale, _bx + 10 * _scale, _body_y - 4 * _scale, max(1, 2 * _scale));
            draw_line_width(_bx + 10 * _scale, _body_y - 4 * _scale, _bx - 2 * _scale, _body_y + 20 * _scale, max(1, 2 * _scale));
        }
    } else if (_id == "Molhado" || _id == "FluxoAcelerado" || _id == "MareAlta") {
        for (var _drop = 0; _drop < 5; _drop += 1) {
            var _dx = _x - 38 * _scale + (_drop * 19 * _scale);
            var _dy = _body_y - 18 * _scale + (sin(current_time * 0.006 + _drop) * 12 * _scale);
            draw_circle(_dx, _dy, 4 * _scale, false);
            draw_ellipse(_dx - 3 * _scale, _dy + 4 * _scale, _dx + 3 * _scale, _dy + 12 * _scale, false);
        }
    } else if (_id == "MantoGelo") {
        draw_ellipse(_x - 44 * _scale, _body_y - 24 * _scale, _x + 44 * _scale, _body_y + 28 * _scale, true);
        for (var _ice = 0; _ice < 6; _ice += 1) {
            draw_rectangle(_x - 40 * _scale + (_ice * 16 * _scale), _body_y - 34 * _scale, _x - 34 * _scale + (_ice * 16 * _scale), _body_y - 24 * _scale, false);
        }
    } else if (_id == "ToxinaAtiva") {
        for (var _cloud = 0; _cloud < 5; _cloud += 1) {
            var _cx = _x - 34 * _scale + (_cloud * 17 * _scale);
            var _cy = _body_y + sin(current_time * 0.004 + _cloud) * 10 * _scale;
            draw_circle(_cx, _cy, (8 + (_pulse * 3)) * _scale, false);
        }
    } else if (_id == "ImpetoOfensivo" || _id == "EspiritoLuta") {
        draw_ellipse(_x - 46 * _scale, _body_y - 24 * _scale, _x + 46 * _scale, _body_y + 30 * _scale, true);
        for (var _slash = 0; _slash < 4; _slash += 1) {
            var _sx = _x - 38 * _scale + (_slash * 25 * _scale);
            draw_line_width(_sx, _body_y + 26 * _scale, _sx + 16 * _scale, _body_y - 16 * _scale, max(1, 2 * _scale));
        }
    } else if (_id == "BarreiraLama" || _id == "Aterrado") {
        for (var _mud = 0; _mud < 5; _mud += 1) {
            var _mx = _x - 42 * _scale + (_mud * 21 * _scale);
            draw_ellipse(_mx - 8 * _scale, _foot_y - 16 * _scale, _mx + 10 * _scale, _foot_y - 4 * _scale, false);
            draw_line_width(_mx, _foot_y - 8 * _scale, _mx + sin(current_time * 0.004 + _mud) * 10 * _scale, _body_y + 18 * _scale, max(1, 2 * _scale));
        }
    } else if (_id == "VentoDeCauda" || _id == "PenasLeves" || _id == "Evasivo") {
        for (var _wind = 0; _wind < 4; _wind += 1) {
            var _wy = _body_y - 28 * _scale + (_wind * 18 * _scale);
            var _offset = sin(current_time * 0.006 + _wind) * 12 * _scale;
            draw_line_width(_x - 48 * _scale + _offset, _wy, _x + 48 * _scale + _offset, _wy - 10 * _scale, max(1, 2 * _scale));
        }
    } else if (_id == "EscudoCinetico" || _id == "FocoPsiquico") {
        draw_ellipse(_x - 48 * _scale, _body_y - 30 * _scale, _x + 48 * _scale, _body_y + 30 * _scale, true);
        for (var _orb = 0; _orb < 5; _orb += 1) {
            var _pa = (current_time * 0.004) + (_orb * 1.256);
            draw_circle(_x + cos(_pa) * 46 * _scale, _body_y + sin(_pa) * 28 * _scale, 4 * _scale, false);
        }
    } else if (_id == "EnxameAtivo" || _id == "Metamorfose") {
        for (var _swarm = 0; _swarm < 7; _swarm += 1) {
            var _sa = (current_time * 0.006) + (_swarm * 0.897);
            var _rx = 34 + ((_swarm mod 2) * 14);
            draw_circle(_x + cos(_sa) * _rx * _scale, _body_y + sin(_sa * 1.3) * 24 * _scale, (3 + _pulse * 2) * _scale, false);
        }
    } else if (_id == "CasuloRigido") {
        draw_ellipse(_x - 42 * _scale, _body_y - 34 * _scale, _x + 42 * _scale, _body_y + 34 * _scale, true);
        for (var _web = -2; _web <= 2; _web += 1) {
            draw_line_width(_x + (_web * 16 * _scale), _body_y - 34 * _scale, _x - (_web * 10 * _scale), _body_y + 34 * _scale, max(1, 1.4 * _scale));
        }
    } else if (_id == "ImpactoGeologico" || _id == "CascaRocha" || _id == "FossilVivo") {
        draw_ellipse(_x - 48 * _scale, _foot_y - 22 * _scale, _x + 48 * _scale, _foot_y - 2 * _scale, true);
        for (var _rock = 0; _rock < 6; _rock += 1) {
            var _ra = (current_time * 0.003) + (_rock * 1.0472);
            var _rx = _x + cos(_ra) * 42 * _scale;
            var _ry = _body_y + sin(_ra * 1.4) * 22 * _scale;
            draw_rectangle(_rx - 4 * _scale, _ry - 4 * _scale, _rx + 5 * _scale, _ry + 4 * _scale, false);
        }
    } else if (_id == "TerrorCrescente" || _id == "Intangivel" || _id == "EssenciaDrenada") {
        draw_ellipse(_x - 46 * _scale, _body_y - 26 * _scale, _x + 46 * _scale, _body_y + 30 * _scale, true);
        for (var _shade = 0; _shade < 6; _shade += 1) {
            var _ga = (current_time * 0.004) + (_shade * 1.0472);
            var _gx = _x + cos(_ga) * (30 + _shade * 3) * _scale;
            var _gy = _body_y + sin(_ga * 1.2) * 26 * _scale;
            draw_circle(_gx, _gy, (4 + _pulse * 2) * _scale, false);
        }
    } else if (_id == "GolpeBaixo" || _id == "JogoSujo" || _id == "CamuflagemSombria" || _id == "CopiaSombria" || _id == "PerseguicaoSombria") {
        draw_ellipse(_x - 48 * _scale, _body_y - 28 * _scale, _x + 48 * _scale, _body_y + 30 * _scale, true);
        for (var _dark = 0; _dark < 6; _dark += 1) {
            var _da2 = (current_time * 0.005) + (_dark * 1.0472);
            var _rx2 = _x + cos(_da2) * (34 + (_dark mod 2) * 8) * _scale;
            var _ry2 = _body_y + sin(_da2 * 1.35) * 24 * _scale;
            draw_circle(_rx2, _ry2, (4 + _pulse * 2) * _scale, false);
            draw_line_width(_rx2 - 8 * _scale, _ry2 + 8 * _scale, _rx2 + 8 * _scale, _ry2 - 8 * _scale, max(1, 1.6 * _scale));
        }
    } else if (_id == "FuriaDraconica" || _id == "AscensaoDraconica" || _id == "Predador") {
        draw_ellipse(_x - 50 * _scale, _body_y - 30 * _scale, _x + 50 * _scale, _body_y + 32 * _scale, true);
        for (var _drg = 0; _drg < 6; _drg += 1) {
            var _da = (current_time * 0.0045) + (_drg * 1.0472);
            var _dx = _x + cos(_da) * 44 * _scale;
            var _dy = _body_y + sin(_da * 1.25) * 28 * _scale;
            draw_line_width(_dx - 6 * _scale, _dy + 6 * _scale, _dx + 8 * _scale, _dy - 8 * _scale, max(1, 2 * _scale));
        }
    } else if (_id == "EscamaImperial") {
        draw_ellipse(_x - 50 * _scale, _body_y - 34 * _scale, _x + 50 * _scale, _body_y + 34 * _scale, true);
        for (var _scale_i = 0; _scale_i < 7; _scale_i += 1) {
            var _sx = _x - 42 * _scale + (_scale_i * 14 * _scale);
            draw_triangle(_sx, _body_y - 22 * _scale, _sx + 8 * _scale, _body_y - 10 * _scale, _sx - 8 * _scale, _body_y - 10 * _scale, false);
            draw_triangle(_sx, _body_y + 18 * _scale, _sx + 8 * _scale, _body_y + 6 * _scale, _sx - 8 * _scale, _body_y + 6 * _scale, false);
        }
    } else if (_id == "EspinhosFerro") {
        draw_ellipse(_x - 48 * _scale, _foot_y - 20 * _scale, _x + 48 * _scale, _foot_y - 2 * _scale, true);
        for (var _spike = 0; _spike < 8; _spike += 1) {
            var _px = _x - 42 * _scale + (_spike * 12 * _scale);
            draw_triangle(_px, _foot_y - 8 * _scale, _px + 5 * _scale, _foot_y - 30 * _scale, _px + 10 * _scale, _foot_y - 8 * _scale, false);
        }
    } else if (_id == "Fortificado" || _id == "BlindagemMagnetica" || _id == "ImpactoPesado" || _id == "LigaPesada") {
        draw_ellipse(_x - 50 * _scale, _body_y - 32 * _scale, _x + 50 * _scale, _body_y + 32 * _scale, true);
        for (var _plate = 0; _plate < 6; _plate += 1) {
            var _pa2 = (current_time * 0.003) + (_plate * 1.0472);
            var _mx = _x + cos(_pa2) * 48 * _scale;
            var _my = _body_y + sin(_pa2) * 30 * _scale;
            draw_rectangle(_mx - 6 * _scale, _my - 4 * _scale, _mx + 6 * _scale, _my + 4 * _scale, false);
        }
    } else {
        draw_circle(_x, _body_y, (30 + (_pulse * 8)) * _scale, true);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

function battle_status_draw_world_effects(_inst, _x, _foot_y, _scale, _alpha) {
    if (!instance_exists(_inst) || !is_struct(_inst.status_map) || _alpha <= 0.05) {
        return;
    }

    var _keys = variable_struct_get_names(_inst.status_map);
    var _drawn = 0;

    for (var _i = 0; _i < array_length(_keys); _i += 1) {
        var _status_id = _keys[_i];
        var _data = battle_status_visual_data(_status_id);

        if (_data.Kind != "aura") {
            continue;
        }

        var _pulse = 0.5 + (sin(current_time * 0.006 + (_drawn * 0.9)) * 0.5);
        var _spr = battle_status_effect_sprite_get(_data.Asset);
        var _effect_y = _foot_y - (54 * _scale) + (_drawn * 4);

        if (sprite_exists(_spr)) {
            var _target = 72 * _scale;
            var _spr_scale = min(_target / max(1, sprite_get_width(_spr)), _target / max(1, sprite_get_height(_spr)));
            draw_set_alpha(min(0.42, _alpha * (0.24 + (_pulse * 0.18))));
            draw_sprite_ext(_spr, 0, _x, _effect_y, _spr_scale, _spr_scale, sin(current_time * 0.003 + _drawn) * 8, _data.Color, 1);
            draw_set_alpha(1);
        }

        battle_status_draw_world_fallback(_status_id, _x, _foot_y, _scale, _data.Color, _pulse);
        _drawn += 1;

        if (_drawn >= 3) {
            break;
        }
    }
}

function battle_ui_get_next_skill(_inst) {
    if (!instance_exists(_inst)) {
        return undefined;
    }

    var _best = undefined;
    var _best_time = 1000000;

    for (var _i = 0; _i < 4; _i += 1) {
        var _skill = _inst.habilidades_equipadas[_i];

        if (is_struct(_skill) && _skill.TempoRecargaAtual < _best_time) {
            _best = _skill;
            _best_time = _skill.TempoRecargaAtual;
        }
    }

    return _best;
}

function battle_ui_get_primary_ally() {
    for (var _i = 0; _i < instance_number(obj_criatura_batalha); _i += 1) {
        var _inst = instance_find(obj_criatura_batalha, _i);

        if (instance_exists(_inst) && _inst.vivo && _inst.lado_batalha == LadoBatalha.ALIADO) {
            return _inst;
        }
    }

    return noone;
}

function battle_ui_draw_status_box(_inst) {
    if (!instance_exists(_inst)) {
        return;
    }

    var _gw = display_get_gui_width();
    var _is_ally = _inst.lado_batalha == LadoBatalha.ALIADO;
    var _box_sprite = _is_ally ? global.ui_databox_ally_sprite : global.ui_databox_foe_sprite;
    var _spr_w = sprite_exists(_box_sprite) ? sprite_get_width(_box_sprite) : 260;
    var _spr_h = sprite_exists(_box_sprite) ? sprite_get_height(_box_sprite) : (_is_ally ? 84 : 62);
    var _box_scale = 1;
    var _w = _spr_w;
    var _h = _spr_h;
    var _x = _inst.lado_batalha == LadoBatalha.ALIADO ? 36 : _gw - _w - 36;
    var _y = 76 + (_inst.ui_slot * (_h + 14));
    var _text_color = (sprite_exists(_box_sprite) || sprite_exists(global.ui_panel_sprite)) ? c_black : c_white;
    var _tooltip = undefined;

    if (sprite_exists(_box_sprite)) {
        draw_sprite_ext(_box_sprite, 0, _x, _y, _box_scale, _box_scale, 0, c_white, 1);
    } else {
        battle_ui_draw_nineslice_panel(_x, _y, _w, _h);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(_text_color);
    var _genero = _inst.genero == "" ? "" : " " + _inst.genero;
    var _nome = string_upper(_inst.criatura_nome) + _genero;
    var _name_x = _x + (_is_ally ? 34 : 24);
    battle_ui_draw_text_fit(_name_x, _y + 9, _nome, _w - 150, 0.80, _text_color);

    if (is_struct(_inst.criatura_data)) {
        var _raridade_box = variable_struct_exists(_inst.criatura_data, "RaridadeEfetiva") ? _inst.criatura_data.RaridadeEfetiva : (variable_struct_exists(_inst.criatura_data, "RaridadePadrao") ? _inst.criatura_data.RaridadePadrao : CriaturaRaridade.COMMON);
        var _raridade_x = _x + _w - (_is_ally ? 94 : 104);
        var _raridade_y = _y + 12;
        var _raridade_size = 14;
        var _mx_rarity = device_mouse_x_to_gui(0);
        var _my_rarity = device_mouse_y_to_gui(0);
        var _raridade_hover = demo_hover_rect(_mx_rarity, _my_rarity, _raridade_x - 4, _raridade_y - 4, _raridade_size + 8, _raridade_size + 8);

        if (_raridade_hover) {
            draw_set_alpha(0.32);
            draw_set_color(c_white);
            draw_circle(_raridade_x + (_raridade_size * 0.5), _raridade_y + (_raridade_size * 0.5), 12, true);
            draw_set_alpha(1);
        }

        criatura_raridade_draw_icon(_raridade_box, _raridade_x, _raridade_y, _raridade_size);

        if (_raridade_hover) {
            _tooltip = {
                Texto: "Raridade: " + criatura_raridade_nome(_raridade_box),
                X: _raridade_x + (_raridade_size * 0.5),
                Y: _raridade_y - 8,
                W: _raridade_size
            };
        }
    }

    draw_set_color(_text_color);
    draw_set_halign(fa_right);
    i18n_draw_text_transformed(_x + _w - (_is_ally ? 26 : 36), _y + 11, "Lv." + string(_inst.level), 0.76, 0.76, 0);
    draw_set_halign(fa_left);

    var _hp_pct = clamp(_inst.hp_atual / max(1, _inst.hp_max), 0, 1);
    var _hp_bar_x = _x + (_is_ally ? 136 : 118);
    var _hp_bar_y = _y + 42;
    var _hp_bar_w = 96;
    var _hp_bar_h = 5;
    draw_set_color(battle_ui_hp_color(_hp_pct));
    draw_rectangle(
        _hp_bar_x,
        _hp_bar_y,
        _hp_bar_x + (_hp_bar_w * _hp_pct),
        _hp_bar_y + _hp_bar_h,
        false
    );

    var _xp_pct = 0;

    if (is_struct(_inst.criatura_data)) {
        if (_inst.criatura_data.ExpNecessaria > 0) {
            _xp_pct = clamp(_inst.criatura_data.ExpAtual / max(1, _inst.criatura_data.ExpNecessaria), 0, 1);
        } else {
            _xp_pct = 1;
        }
    }

    var _xp_bar_x = _x + (_is_ally ? 45 : 112);
    var _xp_bar_y = _y + (_is_ally ? 74 : 53);
    var _xp_bar_w = _is_ally ? 192 : 118;
    var _xp_bar_h = 5;
    draw_set_color(make_color_rgb(70, 70, 70));
    draw_rectangle(_xp_bar_x, _xp_bar_y, _xp_bar_x + _xp_bar_w, _xp_bar_y + _xp_bar_h, false);
    draw_set_color(make_color_rgb(72, 168, 248));
    draw_rectangle(_xp_bar_x, _xp_bar_y, _xp_bar_x + (_xp_bar_w * _xp_pct), _xp_bar_y + _xp_bar_h, false);

    if (is_struct(_inst.criatura_data)) {
        var _type_y = _y + (_is_ally ? 33 : 28);
        var _type_scale = _is_ally ? 0.56 : 0.56;
        var _type_w = 58 * _type_scale;

        if (variable_global_exists("ui_types_sprite") && sprite_exists(global.ui_types_sprite)) {
            _type_w = sprite_get_width(global.ui_types_sprite) * _type_scale;
        }

        var _type_gap = _type_w + 3;
        var _type_count = 0;

        if (_inst.criatura_data.Tipo1 != CriaturaTipo.NONE) {
            _type_count += 1;
        }

        if (_inst.criatura_data.Tipo2 != CriaturaTipo.NONE && _inst.criatura_data.Tipo2 != _inst.criatura_data.Tipo1) {
            _type_count += 1;
        }

        var _type_group_w = _type_count <= 0 ? 0 : _type_w + ((_type_count - 1) * _type_gap);
        var _type_left_limit = _x + (_is_ally ? 18 : 10);
        var _type_right_limit = _hp_bar_x - (_is_ally ? 18 : 28) - _type_group_w;
        var _type_start = _x + (_is_ally ? 42 : 22);

        if (_type_count >= 2) {
            _type_start -= _is_ally ? 14 : 14;
        }

        var _status_x = clamp(_type_start, _type_left_limit, max(_type_left_limit, _type_right_limit));

        if (_inst.criatura_data.Tipo1 != CriaturaTipo.NONE) {
            battle_ui_draw_type_icon(_inst.criatura_data.Tipo1, _status_x, _type_y, _type_scale);
            _status_x += _type_gap;
        }

        if (_inst.criatura_data.Tipo2 != CriaturaTipo.NONE && _inst.criatura_data.Tipo2 != _inst.criatura_data.Tipo1) {
            battle_ui_draw_type_icon(_inst.criatura_data.Tipo2, _status_x, _type_y, _type_scale);
            _status_x += _type_gap;
        }
    }

    var _status_tooltip = battle_ui_draw_status_icons(_inst, _x + (_is_ally ? 58 : 72), _y + _h + 3, 18);
    return is_struct(_status_tooltip) ? _status_tooltip : _tooltip;
}

function battle_ui_draw_log_panel() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _x = 32;
    var _y = _gh - 218;
    var _w = _gw - 64;
    var _h = 84;

    battle_ui_draw_nineslice_panel(_x, _y, _w, _h);

    var _linhas = variable_global_exists("historico_texto_combate") ? global.historico_texto_combate : [];
    var _line_scale = 0.70;
    var _line_h = 22;
    var _line_y = _y + 14;

    for (var _i = 0; _i < array_length(_linhas); _i += 1) {
        battle_ui_font_body();
        battle_ui_draw_text_fit(_x + 38, _line_y + (_i * _line_h), _linhas[_i], _w - 82, _line_scale, sprite_exists(global.ui_panel_sprite) ? c_black : c_white);
    }

    battle_ui_font_title();
}

function battle_ui_draw_skill_bar() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _x = 32;
    var _y = _gh - 124;
    var _w = _gw - 64;
    var _h = 96;
    var _ally = battle_ui_get_primary_ally();
    var _next = battle_ui_get_next_skill(_ally);
    var _slot_gap = 14;
    var _slot_w = (_w - (_slot_gap * 3)) / 4;

    var _tooltip = undefined;

    for (var _i = 0; _i < 4; _i += 1) {
        var _skill = noone;

        if (instance_exists(_ally)) {
            _skill = _ally.habilidades_equipadas[_i];
        }

        var _is_next = is_struct(_skill) && is_struct(_next) && _skill.ID == _next.ID;
        global.ui_slot_trancado = "";

        if (!is_struct(_skill) && instance_exists(_ally) && is_struct(_ally.criatura_data) && !criatura_slot_desbloqueado(_ally.criatura_data, _i)) {
            var _nivel_slot = [1, 10, 15, 20][_i];
            global.ui_slot_trancado = _ally.criatura_data.Level >= _nivel_slot ? "Slot trancado" : "Abre no nivel " + string(_nivel_slot);
        }

        var _slot_tooltip = battle_ui_draw_skill_slot(_skill, _x + (_i * (_slot_w + _slot_gap)), _y, _slot_w, _h, _is_next);
        global.ui_slot_trancado = "";

        if (is_struct(_slot_tooltip)) {
            _tooltip = _slot_tooltip;
        }
    }

    return _tooltip;
}

function battle_ui_draw_button(_label, _x, _y, _w, _h, _active) {
    battle_ui_draw_nineslice_panel(_x, _y, _w, _h);

    if (_active) {
        draw_set_alpha(0.38);
        draw_set_color(make_color_rgb(245, 220, 86));
        draw_rectangle(_x + 5, _y + 5, _x + _w - 5, _y + _h - 5, false);
        draw_set_alpha(1);
    }

    var _text_color = sprite_exists(global.ui_panel_sprite) ? c_black : c_white;

    if (_label == "||") {
        var _cx = round(_x + (_w * 0.5));
        var _cy = round(_y + (_h * 0.5));
        var _bar_w = 3;
        var _bar_h = 16;
        var _gap = 4;
        var _left_x = _cx - _gap - _bar_w;
        var _right_x = _cx + _gap;
        var _top = _cy - floor(_bar_h * 0.5);
        var _bottom = _top + _bar_h;
        draw_set_color(_text_color);
        draw_rectangle(_left_x, _top, _left_x + _bar_w, _bottom, false);
        draw_rectangle(_right_x, _top, _right_x + _bar_w, _bottom, false);
        return;
    }

    battle_ui_draw_text_center_fit(_x + (_w * 0.5), _y + (_h * 0.5) + 1, _label, _w - 16, _h - 12, 1.02, _text_color);
}

function battle_ui_control_layout() {
    var _gw = display_get_gui_width();
    var _labels = ["||", "1x", "1.5x", "2x", "3x", "BESTIARIO", "MOCHILA", "TROCAR", "FUGIR"];
    var _widths = [64, 64, 78, 64, 64, 136, 142, 128, 104];
    var _gap = 8;
    var _h = 44;
    var _y = 18;
    var _total = -_gap;

    for (var _i = 0; _i < array_length(_widths); _i += 1) {
        _total += _widths[_i] + _gap;
    }

    var _x = (_gw - _total) * 0.5;
    var _buttons = [];

    for (var _j = 0; _j < array_length(_labels); _j += 1) {
        array_push(_buttons, {
            Label: _labels[_j],
            X: _x,
            Y: _y,
            W: _widths[_j],
            H: _h
        });
        _x += _widths[_j] + _gap;
    }

    return _buttons;
}

function battle_ui_draw_control_panel() {
    var _buttons = battle_ui_control_layout();

    for (var _i = 0; _i < array_length(_buttons); _i += 1) {
        var _button = _buttons[_i];
        var _active = false;

        switch (_button.Label) {
            case "||": _active = global.time_scale == 0; break;
            case "1x": _active = global.time_scale == 1.0; break;
            case "1.5x": _active = global.time_scale == 1.5; break;
            case "2x": _active = global.time_scale == 2.0; break;
            case "3x": _active = global.time_scale == 3.0; break;
            case "BESTIARIO": _active = global.bestiario_overlay_aberto; break;
            case "MOCHILA": _active = global.mochila_overlay_aberta; break;
            case "TROCAR": _active = global.troca_overlay_aberta; break;
        }

        battle_ui_draw_button(_button.Label, _button.X, _button.Y, _button.W, _button.H, _active);
    }
}

function battle_ui_draw_bag_overlay() {
    if (!variable_global_exists("mochila_overlay_aberta") || !global.mochila_overlay_aberta) {
        return;
    }

    var _demo = instance_number(obj_demo_game) > 0 ? instance_find(obj_demo_game, 0) : noone;

    if (!instance_exists(_demo)) {
        return;
    }

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    draw_set_alpha(0.72);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    battle_ui_draw_nineslice_panel(56, 84, _gw - 112, _gh - 140);
    battle_ui_font_title();
    ui_texto_sombra(84, 108, "MOCHILA", sprite_exists(global.ui_panel_sprite) ? c_black : c_white, 1.1);
    battle_ui_font_body();
    draw_set_color(sprite_exists(global.ui_panel_sprite) ? c_black : make_color_rgb(200, 206, 230));
    i18n_draw_text(84, 140, "Combate pausado. Clique em um item para usar.");
    battle_ui_font_title();

    battle_ui_draw_button("FECHAR", _gw - 224, 112, 160, 42, battle_ui_button_hit(_mx, _my, _gw - 224, 112, 160, 42));

    var _bag_ids = demo_item_ids_possuidos(_demo.inventario);
    var _n_bag = array_length(_bag_ids);

    if (_n_bag <= 0) {
        var _empty_text = "Mochila vazia";
        draw_set_color(c_white);
        i18n_draw_text((_gw * 0.5) - (i18n_string_width(_empty_text) * 0.5), _gh * 0.5, _empty_text);
    }

    for (var _bag_i = 0; _bag_i < _n_bag; _bag_i += 1) {
        var _bag_id = _bag_ids[_bag_i];
        var _bag_item = demo_item_get(_bag_id);

        if (!is_struct(_bag_item)) {
            continue;
        }

        var _r = battle_ui_bag_rect(_bag_i, _n_bag);
        var _bag_qty = demo_inventario_quantidade(_demo.inventario, _bag_id);
        var _can_use = demo_item_pode_usar(_bag_item, true);
        var _hover = _can_use && battle_ui_button_hit(_mx, _my, _r.X, _r.Y, _r.W, _r.H);
        var _k = ui_cartao_escuro(_r.X, _r.Y, _r.W, _r.H, _hover, !_can_use);

        draw_set_alpha(_can_use ? 1 : 0.55);
        draw_set_color(make_color_rgb(52, 60, 96));
        draw_circle(_k.X + 34, _k.Y + (_k.H * 0.5), 22, false);
        demo_draw_item_icon(_bag_id, _k.X + 34, _k.Y + (_k.H * 0.5), 32);
        battle_ui_font_title();
        battle_ui_draw_text_fit(_k.X + 68, _k.Y + 9, _bag_item.Nome, _k.W - 118, 0.74, c_white);

        draw_set_color(ui_cor("ouro"));
        draw_circle(_k.X + _k.W - 22, _k.Y + 20, 13, false);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(ui_cor("noite"));
        i18n_draw_text_transformed(_k.X + _k.W - 22, _k.Y + 20, string(_bag_qty), 0.6, 0.6, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        var _cat = demo_item_categoria(_bag_item);
        var _tx = _k.X + 68 + ui_tag(_k.X + 68, _k.Y + 33, _cat.Nome, _cat.Cor, c_white) + 6;

        if (!_can_use) {
            ui_tag(_tx, _k.Y + 33, "Fora de batalha", make_color_rgb(70, 74, 100), make_color_rgb(200, 206, 230));
        }

        battle_ui_font_body();
        draw_set_color(make_color_rgb(200, 206, 230));
        ui_texto_bloco(_k.X + 68, min(_k.Y + 56, _k.Y + _k.H - 17), _bag_item.Descricao, 16, _k.W - 82, 1, 0.66);
        battle_ui_font_title();
        draw_set_alpha(1);
    }
}

// Cartoes da mochila na batalha: 3 colunas; com muitos itens as linhas encolhem.
function battle_ui_bag_rect(_i, _n) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _x0 = 84;
    var _y0 = 176;
    var _colunas = 3;
    var _cw = ((_gw - 168) - ((_colunas - 1) * 16)) / _colunas;
    var _linhas = max(1, ceil(_n / _colunas));
    var _passo = min(92, floor(((_gh - 84) - _y0 - 12) / _linhas));
    return { X: _x0 + ((_i mod _colunas) * (_cw + 16)), Y: _y0 + ((_i div _colunas) * _passo), W: _cw, H: _passo - 10 };
}

function battle_ui_draw_switch_overlay() {
    if (!variable_global_exists("troca_overlay_aberta") || !global.troca_overlay_aberta) {
        return;
    }

    var _demo = instance_number(obj_demo_game) > 0 ? instance_find(obj_demo_game, 0) : noone;

    if (!instance_exists(_demo)) {
        return;
    }

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    draw_set_alpha(0.72);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    battle_ui_draw_nineslice_panel(96, 96, _gw - 192, _gh - 192);
    draw_set_color(sprite_exists(global.ui_panel_sprite) ? c_black : c_white);
    i18n_draw_text(128, 126, "TROCAR MONSTRO");
    i18n_draw_text(128, 150, "Escolha um monstro capturado para entrar em campo.");
    battle_ui_draw_button("FECHAR", _gw - 256, 124, 160, 42, battle_ui_button_hit(_mx, _my, _gw - 256, 124, 160, 42));

    demo_party_garantir(_demo);
    var _party = _demo.player_party;
    var _card_w = (_gw - 290) * 0.5;
    var _card_h = 112;
    var _start_x = 128;
    var _start_y = 204;
    var _gap_x = 26;
    var _gap_y = 18;

    for (var _i = 0; _i < 4; _i += 1) {
        var _col = _i mod 2;
        var _row = _i div 2;
        var _x = _start_x + (_col * (_card_w + _gap_x));
        var _y = _start_y + (_row * (_card_h + _gap_y));
        var _criatura = _i < array_length(_party) ? _party[_i] : undefined;
        var _active = _i == _demo.player_party_active_index;
        var _can_switch = is_struct(_criatura) && !_active && (!variable_struct_exists(_criatura, "HpAtual") || _criatura.HpAtual > 0);
        var _hover = _can_switch && battle_ui_button_hit(_mx, _my, _x, _y, _card_w, _card_h);

        battle_ui_draw_nineslice_panel(_x, _y, _card_w, _card_h);

        if (_active) {
            draw_set_color(ui_cor("ciano"));
            draw_roundrect_ext(_x + 2, _y + 2, _x + _card_w - 2, _y + _card_h - 2, 10, 10, true);
            draw_roundrect_ext(_x + 3, _y + 3, _x + _card_w - 3, _y + _card_h - 3, 10, 10, true);
        }

        if (_hover) {
            ui_borda_selecao(_x, _y, _card_w, _card_h);
        }

        if (!is_struct(_criatura)) {
            draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(80, 72, 66) : c_white);
            i18n_draw_text(_x + 24, _y + 42, "Slot vazio");
            continue;
        }

        var _spr = demo_get_criatura_sprite(_criatura.ID);

        if (sprite_exists(_spr)) {
            var _scale = 1.25;
            draw_sprite_ext(_spr, 0, _x + 58, _y + 84, _scale, _scale, 0, c_white, 1);
        }

        draw_set_color(sprite_exists(global.ui_panel_sprite) ? c_black : c_white);
        var _name = (variable_struct_exists(_criatura, "IsShiny") && _criatura.IsShiny ? "CROMATICO " : "") + _criatura.Nome;
        i18n_draw_text(_x + 112, _y + 18, _name + "  Lv." + string(_criatura.Level));
        var _hp = variable_struct_exists(_criatura, "HpAtual") ? _criatura.HpAtual : _criatura.HpMax;
        var _hp_pct = clamp(_hp / max(1, _criatura.HpMax), 0, 1);
        i18n_draw_text(_x + 112, _y + 44, "HP");
        draw_set_color(c_dkgray);
        draw_rectangle(_x + 148, _y + 48, _x + _card_w - 28, _y + 58, false);
        draw_set_color(battle_ui_hp_color(_hp_pct));
        draw_rectangle(_x + 148, _y + 48, _x + 148 + ((_card_w - 176) * _hp_pct), _y + 58, false);
        draw_set_color(sprite_exists(global.ui_panel_sprite) ? c_black : c_white);
        i18n_draw_text(_x + 112, _y + 72, _active ? "Em campo" : (_can_switch ? "Clique para trocar" : "Desmaiado"));
    }
}

function battle_ui_button_hit(_mx, _my, _x, _y, _w, _h) {
    return _mx >= _x && _mx <= _x + _w && _my >= _y && _my <= _y + _h;
}

function battle_ui_step(_dt) {
    battle_log_step(_dt);
    battle_float_text_step(_dt);
    battle_screen_shake_step(_dt);

    if (!mouse_check_button_pressed(mb_left)) {
        return;
    }

    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _demo = instance_number(obj_demo_game) > 0 ? instance_find(obj_demo_game, 0) : noone;

    if (instance_exists(_demo) && _demo.estado_demo == DemoEstado.CAPTURA) {
        return;
    }

    if (global.mochila_overlay_aberta) {
        if (battle_ui_button_hit(_mx, _my, _gw - 224, 112, 160, 42)) {
            global.mochila_overlay_aberta = false;
            global.troca_overlay_aberta = false;
            battle_time_scale_restore_preferido();
            return;
        }

        if (instance_exists(_demo)) {
            var _bag_ids = demo_item_ids_possuidos(_demo.inventario);

            for (var _bag_i = 0; _bag_i < array_length(_bag_ids); _bag_i += 1) {
                var _bag_id = _bag_ids[_bag_i];
                var _bag_item = demo_item_get(_bag_id);

                if (!is_struct(_bag_item) || !demo_item_pode_usar(_bag_item, true)) {
                    continue;
                }

                var _bag_qty = demo_inventario_quantidade(_demo.inventario, _bag_id);
                var _bag_r = battle_ui_bag_rect(_bag_i, array_length(_bag_ids));

                if (_bag_qty > 0 && battle_ui_button_hit(_mx, _my, _bag_r.X, _bag_r.Y, _bag_r.W, _bag_r.H)) {
                    demo_item_usar(_demo, _bag_id, true);
                    return;
                }
            }
        }

        return;
    }

    if (global.troca_overlay_aberta) {
        if (battle_ui_button_hit(_mx, _my, _gw - 256, 124, 160, 42)) {
            global.troca_overlay_aberta = false;
            battle_time_scale_restore_preferido();
            return;
        }

        if (instance_exists(_demo)) {
            demo_party_garantir(_demo);
            var _party = _demo.player_party;
            var _card_w = (_gw - 290) * 0.5;
            var _card_h = 112;
            var _start_x = 128;
            var _start_y = 204;
            var _gap_x = 26;
            var _gap_y = 18;

            for (var _switch_i = 0; _switch_i < min(4, array_length(_party)); _switch_i += 1) {
                var _col = _switch_i mod 2;
                var _row = _switch_i div 2;
                var _card_x = _start_x + (_col * (_card_w + _gap_x));
                var _card_y = _start_y + (_row * (_card_h + _gap_y));

                if (battle_ui_button_hit(_mx, _my, _card_x, _card_y, _card_w, _card_h)) {
                    if (demo_party_trocar_ativo(_demo, _switch_i)) {
                        global.troca_overlay_aberta = false;
                        battle_time_scale_restore_preferido();
                    }

                    return;
                }
            }
        }

        return;
    }

    var _buttons = battle_ui_control_layout();

    for (var _btn_i = 0; _btn_i < array_length(_buttons); _btn_i += 1) {
        var _button = _buttons[_btn_i];

        if (!battle_ui_button_hit(_mx, _my, _button.X, _button.Y, _button.W, _button.H)) {
            continue;
        }

        switch (_button.Label) {
            case "||":
                battle_time_scale_toggle_pause();
                break;

            case "1x":
                battle_time_scale_set(1.0, true);
                break;

            case "1.5x":
                battle_time_scale_set(1.5, true);
                break;

            case "2x":
                battle_time_scale_set(2.0, true);
                break;

            case "3x":
                battle_time_scale_set(3.0, true);
                break;

            case "BESTIARIO":
                if (!global.bestiario_overlay_aberto) {
                    global.bestiario_overlay_time_scale_anterior = global.time_scale;
                }

                global.bestiario_overlay_aberto = !global.bestiario_overlay_aberto;
                global.mochila_overlay_aberta = false;
                global.troca_overlay_aberta = false;
                global.time_scale = global.bestiario_overlay_aberto ? 0 : (variable_global_exists("bestiario_overlay_time_scale_anterior") ? global.bestiario_overlay_time_scale_anterior : global.time_scale_preferido);
                break;

            case "MOCHILA":
                global.mochila_overlay_aberta = !global.mochila_overlay_aberta;
                global.bestiario_overlay_aberto = false;
                global.troca_overlay_aberta = false;

                if (global.mochila_overlay_aberta) {
                    global.time_scale = 0;
                    global.velocidade_jogo = 0;
                } else {
                    battle_time_scale_restore_preferido();
                }
                break;

            case "TROCAR":
                global.troca_overlay_aberta = !global.troca_overlay_aberta;
                global.bestiario_overlay_aberto = false;
                global.mochila_overlay_aberta = false;

                if (global.troca_overlay_aberta) {
                    global.time_scale = 0;
                    global.velocidade_jogo = 0;
                } else {
                    battle_time_scale_restore_preferido();
                }
                break;

            case "FUGIR":
                global.battle_fugir_solicitado = true;
                battle_log_push("Voce tentou fugir deste no!");
                break;
        }

        global.velocidade_jogo = global.time_scale;
        return;
    }

    global.velocidade_jogo = global.time_scale;
}

function battle_ui_draw_gui() {
    battle_ui_init();

    if (font_exists(global.ui_font)) {
        draw_set_font(global.ui_font);
    }

    var _status_tooltip = undefined;

    for (var _status_i = 0; _status_i < instance_number(obj_criatura_batalha); _status_i += 1) {
        var _status_inst = instance_find(obj_criatura_batalha, _status_i);

        if (instance_exists(_status_inst) && _status_inst.vivo) {
            var _box_tooltip = battle_ui_draw_status_box(_status_inst);

            if (is_struct(_box_tooltip)) {
                _status_tooltip = _box_tooltip;
            }
        }
    }

    battle_ui_draw_log_panel();
    var _skill_tooltip = battle_ui_draw_skill_bar();
    battle_ui_draw_control_panel();
    battle_float_text_draw_gui();
    battle_ui_draw_bag_overlay();
    battle_ui_draw_switch_overlay();
    demo_draw_status_tooltip(_status_tooltip);
    demo_draw_status_tooltip(_skill_tooltip);
}

function battle_layout_posicionar_campo(_aliados, _inimigos) {
    var _pos_aliado_x = room_width * 0.30;
    var _pos_inimigo_x = room_width * 0.70;
    var _pos_chao_y = room_height * 0.57;
    var _spacing = 78;

    for (var _i = 0; _i < array_length(_aliados); _i += 1) {
        if (instance_exists(_aliados[_i])) {
            _aliados[_i].x = _pos_aliado_x - (_i * 28);
            _aliados[_i].y = _pos_chao_y + ((_i - ((array_length(_aliados) - 1) * 0.5)) * _spacing);
            _aliados[_i].ui_slot = _i;
            _aliados[_i].lado_batalha = LadoBatalha.ALIADO;
        }
    }

    for (var _j = 0; _j < array_length(_inimigos); _j += 1) {
        if (instance_exists(_inimigos[_j])) {
            _inimigos[_j].x = _pos_inimigo_x + (_j * 28);
            _inimigos[_j].y = _pos_chao_y + ((_j - ((array_length(_inimigos) - 1) * 0.5)) * _spacing);
            _inimigos[_j].ui_slot = _j;
            _inimigos[_j].lado_batalha = LadoBatalha.INIMIGO;
        }
    }
}

function battle_vfx_criar(_atacante, _alvo, _texto_impacto) {
    if (!instance_exists(_atacante) || !instance_exists(_alvo)) {
        return noone;
    }

    var _tipo = argument_count >= 4 ? argument[3] : CriaturaTipo.NONE;
    var _vfx = instance_create_layer(_atacante.x, _atacante.y - 28, "Instances", obj_vfx_ataque);
    _vfx.alvo = _alvo;
    _vfx.texto_impacto = _texto_impacto;
    _vfx.direcao = sign(_alvo.x - _atacante.x);
    _vfx.speed_px = _tipo == CriaturaTipo.ELECTRIC ? 760 : 520;
    _vfx.tipo = _tipo;
    _vfx.depth = -100;
    return _vfx;
}
