var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

battle_ui_init();

if (font_exists(global.ui_font)) {
    draw_set_font(global.ui_font);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);

if (estado_demo == DemoEstado.MENU) {
    demo_draw_menu_titulo(id);
} else if (estado_demo == DemoEstado.META_LOJA) {
    demo_draw_meta_loja(id);
} else if (estado_demo == DemoEstado.INTRO) {
    demo_draw_intro_contexto(id);
} else if (estado_demo == DemoEstado.GAME_OVER) {
    demo_draw_game_over(id);
    diario_draw_resultado_game_over(id);
} else if (estado_demo == DemoEstado.VITORIA_FINAL) {
    demo_draw_vitoria_final(id);
    diario_draw_resultado_game_over(id);
} else if (estado_demo == DemoEstado.ESCOLHA_INICIAL) {
    draw_set_color(c_black);
    draw_set_alpha(0.55);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(_gw * 0.5, 76, "ESCOLHA SEU MONSTRO INICIAL");
    draw_text(_gw * 0.5, 110, "Clique em um card ou pressione 1, 2 ou 3");
    draw_set_halign(fa_left);

    var _card_w = 350;
    var _gap = 30;
    var _start_x = (_gw - ((_card_w * 3) + (_gap * 2))) * 0.5;
    var _card_y = 140;
    var _card_h = min(580, _gh - _card_y - 34);
    var _mx_hover = device_mouse_x_to_gui(0);
    var _my_hover = device_mouse_y_to_gui(0);
    var _status_tooltip = undefined;

    for (var _i = 0; _i < 3; _i += 1) {
        var _x = _start_x + (_i * (_card_w + _gap));
        var _id = starter_ids[_i];
        var _hover = _mx_hover >= _x && _mx_hover <= _x + _card_w && _my_hover >= _card_y && _my_hover <= _card_y + _card_h;
        var _pokemon_preview = demo_pokemon_preview_get(_id);

        if (_hover) {
            draw_set_alpha(0.28);
            draw_set_color(make_color_rgb(255, 232, 88));
            draw_rectangle(_x - 7, _card_y - 7, _x + _card_w + 7, _card_y + _card_h + 7, false);
            draw_set_alpha(1);
        }

        draw_set_color(make_color_rgb(108, 18, 28));
        draw_rectangle(_x, _card_y, _x + _card_w, _card_y + _card_h, false);
        draw_set_color(_hover ? make_color_rgb(255, 232, 88) : make_color_rgb(246, 238, 206));
        draw_rectangle(_x, _card_y, _x + _card_w, _card_y + _card_h, true);
        draw_rectangle(_x + 4, _card_y + 4, _x + _card_w - 4, _card_y + _card_h - 4, true);

        draw_set_color(make_color_rgb(196, 46, 54));
        draw_rectangle(_x + 8, _card_y + 8, _x + _card_w - 8, _card_y + 70, false);
        draw_set_color(make_color_rgb(148, 26, 38));
        draw_rectangle(_x + 8, _card_y + 50, _x + _card_w - 8, _card_y + 70, false);
        draw_set_color(make_color_rgb(248, 228, 104));
        draw_rectangle(_x + 18, _card_y + 18, _x + 32, _card_y + 32, false);

        draw_set_color(c_white);
        draw_text(_x + 42, _card_y + 20, string(_i + 1) + ". " + demo_pokemon_nome(_id));
        draw_set_halign(fa_right);
        draw_text(_x + _card_w - 78, _card_y + 20, "Lv. 5");
        draw_set_halign(fa_left);
        var _raridade_card = is_struct(_pokemon_preview) && variable_struct_exists(_pokemon_preview, "RaridadePadrao") ? _pokemon_preview.RaridadePadrao : PokemonRaridade.COMMON;
        var _raridade_icon_x = _x + _card_w - 44;
        var _raridade_icon_y = _card_y + 15;
        var _raridade_icon_size = 28;
        var _raridade_hover = demo_hover_rect(_mx_hover, _my_hover, _raridade_icon_x - 5, _raridade_icon_y - 5, _raridade_icon_size + 10, _raridade_icon_size + 10);

        if (_raridade_hover) {
            draw_set_alpha(0.30);
            draw_set_color(c_white);
            draw_circle(_raridade_icon_x + (_raridade_icon_size * 0.5), _raridade_icon_y + (_raridade_icon_size * 0.5), 22, true);
            draw_set_alpha(1);
        }

        pokemon_raridade_draw_icon(_raridade_card, _raridade_icon_x, _raridade_icon_y, _raridade_icon_size);

        if (_raridade_hover) {
            _status_tooltip = {
                Texto: "Raridade: " + pokemon_raridade_nome(_raridade_card),
                X: _raridade_icon_x + (_raridade_icon_size * 0.5),
                Y: _raridade_icon_y - 6,
                W: _raridade_icon_size
            };
        }

        draw_set_color(make_color_rgb(228, 226, 202));
        draw_rectangle(_x + 18, _card_y + 86, _x + _card_w - 18, _card_y + 278, false);
        draw_set_color(make_color_rgb(88, 92, 88));
        draw_rectangle(_x + 18, _card_y + 86, _x + _card_w - 18, _card_y + 278, true);
        draw_set_color(make_color_rgb(168, 220, 188));
        draw_rectangle(_x + 30, _card_y + 100, _x + _card_w - 30, _card_y + 258, false);
        draw_set_color(make_color_rgb(104, 172, 128));
        draw_line_width(_x + 42, _card_y + 246, _x + _card_w - 42, _card_y + 246, 2);

        demo_draw_pokemon_sprite(
            _id,
            _x + (_card_w * 0.5) + demo_card_sprite_offset_x(_id),
            _card_y + 238,
            demo_card_sprite_scale(_id),
            1,
            0
        );

        var _stat_panel_y = _card_y + 292;
        var _stat_panel_h = 96;
        draw_set_color(make_color_rgb(242, 235, 208));
        draw_rectangle(_x + 18, _stat_panel_y, _x + _card_w - 18, _stat_panel_y + _stat_panel_h, false);
        draw_set_color(make_color_rgb(108, 82, 68));
        draw_rectangle(_x + 18, _stat_panel_y, _x + _card_w - 18, _stat_panel_y + _stat_panel_h, true);
        demo_draw_pokemon_stat_bars(_pokemon_preview, _x + 30, _stat_panel_y + 10, _card_w - 66, true);

        draw_set_color(make_color_rgb(246, 238, 206));
        var _divider_y = _stat_panel_y + _stat_panel_h + 12;
        draw_line_width(_x + 18, _divider_y, _x + _card_w - 18, _divider_y, 2);

        var _skills = demo_get_initial_skills(_id);
        var _skill_panel_y = _divider_y + 12;
        var _skill_panel_h = max(124, (_card_y + _card_h) - _skill_panel_y - 18);

        draw_set_color(make_color_rgb(242, 235, 208));
        draw_rectangle(_x + 18, _skill_panel_y, _x + _card_w - 18, _skill_panel_y + _skill_panel_h, false);
        draw_set_color(make_color_rgb(108, 82, 68));
        draw_rectangle(_x + 18, _skill_panel_y, _x + _card_w - 18, _skill_panel_y + _skill_panel_h, true);
        draw_set_color(make_color_rgb(204, 188, 158));
        draw_line_width(_x + 28, _skill_panel_y + 36, _x + _card_w - 28, _skill_panel_y + 36, 1);

        draw_set_color(make_color_rgb(50, 36, 34));
        draw_text(_x + 30, _skill_panel_y + 12, "Ataque inicial");

        for (var _s = 0; _s < min(1, array_length(_skills)); _s += 1) {
            var _skill = _skills[_s];

            if (is_struct(_skill)) {
                battle_ui_draw_type_icon(_skill.TipoElementar, _x + 30, _skill_panel_y + 50, 0.66);
                draw_set_color(make_color_rgb(36, 30, 28));
                draw_text(_x + 96, _skill_panel_y + 48, _skill.Nome);
                draw_text(_x + 96, _skill_panel_y + 72, battle_ui_skill_damage_text(_skill) + "   CD " + string_format(_skill.TempoRecargaMax, 1, 1) + "s");
                var _tooltip_atual = demo_draw_habilidade_descricao_rica(_skill, _x + 30, _skill_panel_y + 98, _card_w - 60, _mx_hover, _my_hover, 1);

                if (is_struct(_tooltip_atual)) {
                    _status_tooltip = _tooltip_atual;
                }
            }
        }

        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_text_transformed(_x + _card_w - 106, _card_y + 48, battle_ui_string_fit(pokemon_raridade_nome(_raridade_card), 76, 0.48), 0.48, 0.48, 0);
        draw_set_halign(fa_left);
    }

    demo_draw_status_tooltip(_status_tooltip);
} else if (estado_demo == DemoEstado.CIDADE || estado_demo == DemoEstado.POKESTORE || estado_demo == DemoEstado.LAB_CARVALHO || estado_demo == DemoEstado.MOCHILA || estado_demo == DemoEstado.GINASIO || estado_demo == DemoEstado.CASA_MAE || estado_demo == DemoEstado.SAIR_CIDADE) {
    var _mx_city_ui = device_mouse_x_to_gui(0);
    var _my_city_ui = device_mouse_y_to_gui(0);

    draw_set_color(make_color_rgb(242, 235, 208));
    draw_rectangle(36, 34, 420, 106, false);
    draw_set_color(make_color_rgb(108, 82, 68));
    draw_rectangle(36, 34, 420, 106, true);
    draw_rectangle(40, 38, 416, 102, true);
    draw_set_color(make_color_rgb(196, 46, 54));
    draw_rectangle(36, 34, 420, 58, false);
    var _cidade_titulo = demo_cidade_nome(cidade_index);

    if (cidade_index == 0) {
        _cidade_titulo = "Vila Alvorada";
    }

    draw_set_color(c_white);
    battle_ui_font_title();
    draw_set_valign(fa_middle);
    draw_text(58, 46, string_upper(_cidade_titulo));
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(36, 30, 28));
    var _cidade_subtitulo = "Escolha um ponto no mapa";

    if (estado_demo == DemoEstado.CIDADE && message != "" && message != demo_cidade_nome(cidade_index)) {
        _cidade_subtitulo = message;
    }

    if (estado_demo == DemoEstado.CASA_MAE) {
        _cidade_subtitulo = cidade_index == 0 ? "Casa da Mae" : demo_cidade_atual().Evento;
    } else if (estado_demo == DemoEstado.POKESTORE) {
        _cidade_subtitulo = "Compras e suprimentos";
    } else if (estado_demo == DemoEstado.LAB_CARVALHO) {
        _cidade_subtitulo = "Lab. do Prof. Sabia";
    } else if (estado_demo == DemoEstado.MOCHILA) {
        _cidade_subtitulo = "Mochila";
    } else if (estado_demo == DemoEstado.GINASIO) {
        _cidade_subtitulo = demo_cidade_tem_ginasio(cidade_index) ? "Ginasio - " + demo_cidade_atual().Lider : "Sem ginasio";
    } else if (estado_demo == DemoEstado.SAIR_CIDADE) {
        _cidade_subtitulo = "Saida da cidade";
    }

    battle_ui_draw_text_fit(58, 72, _cidade_subtitulo, 350, 1, make_color_rgb(36, 30, 28));

    if (estado_demo == DemoEstado.CIDADE) {
        missoes_draw_lista(id);
    }

    demo_draw_money_badge(_gw - 208, 38, dinheiro);

    if (estado_demo == DemoEstado.CIDADE) {
        var _markers_city_ui = demo_city_markers(id);

        for (var _city_marker_i = 0; _city_marker_i < array_length(_markers_city_ui); _city_marker_i += 1) {
            var _marker_ui = _markers_city_ui[_city_marker_i];
            var _marker_ui_pos = demo_city_marker_pos(id, _marker_ui, _gw, _gh);

            demo_draw_city_marker(
                _marker_ui.Symbol,
                _marker_ui.Label,
                _marker_ui_pos.X,
                _marker_ui_pos.Y,
                demo_city_marker_hit(_mx_city_ui, _my_city_ui, _marker_ui_pos.X, _marker_ui_pos.Y)
            );
        }

        demo_draw_choice_button("Mochila", "", 36, _gh - 96, 210, 58, demo_hover_rect(_mx_city_ui, _my_city_ui, 36, _gh - 96, 210, 58));
    } else if (estado_demo == DemoEstado.POKESTORE) {
        draw_set_color(make_color_rgb(242, 235, 208));
        draw_rectangle(70, 152, 650, 612, false);
        draw_set_color(make_color_rgb(108, 82, 68));
        draw_rectangle(70, 152, 650, 612, true);
        draw_set_color(make_color_rgb(36, 30, 28));
        draw_text(98, 176, "Clique em um item para comprar.");

        var _shop_items = demo_shop_items_cidade(cidade_index);
        var _shop_x = 88;
        var _shop_y = 214;
        var _shop_w = 520;
        var _shop_row_h = 58;
        draw_set_color(make_color_rgb(86, 68, 58));
        draw_text(_shop_x + 418, _shop_y - 20, "Estoque");

        for (var _shop_i = 0; _shop_i < array_length(_shop_items); _shop_i += 1) {
            var _shop_id = _shop_items[_shop_i];
            var _shop_item = demo_item_get(_shop_id);

            if (!is_struct(_shop_item)) {
                continue;
            }

            var _row_y = _shop_y + (_shop_i * (_shop_row_h + 8));
            var _hover_shop = demo_hover_rect(_mx_city_ui, _my_city_ui, _shop_x, _row_y, _shop_w, _shop_row_h);
            draw_set_color(_hover_shop ? make_color_rgb(255, 244, 152) : make_color_rgb(250, 244, 224));
            draw_rectangle(_shop_x, _row_y, _shop_x + _shop_w, _row_y + _shop_row_h, false);
            draw_set_color(_hover_shop ? make_color_rgb(220, 184, 42) : make_color_rgb(164, 138, 92));
            draw_rectangle(_shop_x, _row_y, _shop_x + _shop_w, _row_y + _shop_row_h, true);
            demo_draw_item_icon(_shop_id, _shop_x + 28, _row_y + 29, 32);
            draw_set_color(make_color_rgb(36, 30, 28));
            battle_ui_font_title();
            draw_text(_shop_x + 58, _row_y + 9, _shop_item.Nome);
            draw_text(_shop_x + 302, _row_y + 9, "M$ " + string(_shop_item.Preco));
            draw_text(_shop_x + 432, _row_y + 9, "x" + string(demo_inventario_quantidade(inventario, _shop_id)));
            draw_set_color(make_color_rgb(86, 68, 58));
            battle_ui_font_body();
            draw_text_ext(_shop_x + 58, _row_y + 31, _shop_item.Descricao, 14, _shop_w - 76);
            battle_ui_font_title();
        }

        demo_draw_choice_button("Voltar", "", 54, _gh - 96, 180, 58, demo_hover_rect(_mx_city_ui, _my_city_ui, 54, _gh - 96, 180, 58));
        demo_draw_choice_button("Mochila", "", 264, _gh - 96, 210, 58, demo_hover_rect(_mx_city_ui, _my_city_ui, 264, _gh - 96, 210, 58));
    } else if (estado_demo == DemoEstado.LAB_CARVALHO) {
        draw_set_color(make_color_rgb(242, 235, 208));
        draw_rectangle(70, 150, 820, 430, false);
        draw_set_color(make_color_rgb(108, 82, 68));
        draw_rectangle(70, 150, 820, 430, true);
        demo_draw_dialog_character(professor_sprite, 70, 150, 820, 430);
        draw_set_color(make_color_rgb(36, 30, 28));
        battle_ui_font_title();
        draw_text(98, 176, "Lab. do Prof. Sabia");
        battle_ui_font_body();
        draw_text_ext(98, 212, message, 24, 520);
        battle_ui_font_title();
        demo_draw_choice_button("Voltar", "", 54, _gh - 96, 180, 58, demo_hover_rect(_mx_city_ui, _my_city_ui, 54, _gh - 96, 180, 58));
    } else if (estado_demo == DemoEstado.MOCHILA) {
        draw_set_color(make_color_rgb(242, 235, 208));
        draw_rectangle(70, 136, 742, 620, false);
        draw_set_color(make_color_rgb(108, 82, 68));
        draw_rectangle(70, 136, 742, 620, true);
        draw_set_color(make_color_rgb(36, 30, 28));
        battle_ui_font_body();
        draw_text_ext(98, 166, "Armazenamento de todos os seus itens. Para usar ou equipar nos seus monstros entre as rotas, basta clicar no item.", 24, 560);
        battle_ui_font_title();

        var _bag_ids = demo_item_ids_possuidos(inventario);
        var _bag_x = 88;
        var _bag_y = 236;
        var _bag_col_w = 306;
        var _bag_row_h = 52;

        if (array_length(_bag_ids) <= 0) {
            var _empty_text = "Mochila vazia";
            draw_set_color(make_color_rgb(86, 68, 58));
            draw_text(406 - (string_width(_empty_text) * 0.5), 368, _empty_text);
        }

        for (var _bag_i = 0; _bag_i < array_length(_bag_ids); _bag_i += 1) {
            var _bag_id = _bag_ids[_bag_i];
            var _bag_item = demo_item_get(_bag_id);

            if (!is_struct(_bag_item)) {
                continue;
            }

            var _bag_qty = demo_inventario_quantidade(inventario, _bag_id);
            var _can_use_bag = demo_item_pode_usar(_bag_item, false);
            var _bag_col = _bag_i div 8;
            var _bag_row = _bag_i mod 8;
            var _bag_item_x = _bag_x + (_bag_col * (_bag_col_w + 18));
            var _row_bag_y = _bag_y + (_bag_row * (_bag_row_h + 8));
            var _hover_bag = _can_use_bag && demo_hover_rect(_mx_city_ui, _my_city_ui, _bag_item_x, _row_bag_y, _bag_col_w, _bag_row_h);
            draw_set_color(_hover_bag ? make_color_rgb(255, 244, 152) : make_color_rgb(250, 244, 224));
            draw_rectangle(_bag_item_x, _row_bag_y, _bag_item_x + _bag_col_w, _row_bag_y + _bag_row_h, false);
            draw_set_color(_hover_bag ? make_color_rgb(220, 184, 42) : make_color_rgb(164, 138, 92));
            draw_rectangle(_bag_item_x, _row_bag_y, _bag_item_x + _bag_col_w, _row_bag_y + _bag_row_h, true);
            demo_draw_item_icon(_bag_id, _bag_item_x + 28, _row_bag_y + (_bag_row_h * 0.5), 30);
            draw_set_color(make_color_rgb(36, 30, 28));
            draw_text(_bag_item_x + 58, _row_bag_y + 8, _bag_item.Nome);
            draw_text(_bag_item_x + 244, _row_bag_y + 8, "x" + string(_bag_qty));
            draw_set_color(make_color_rgb(86, 68, 58));
            draw_text(_bag_item_x + 58, _row_bag_y + 30, _bag_item.Tipo);
        }

        demo_draw_choice_button("Voltar", "", 54, _gh - 96, 180, 58, demo_hover_rect(_mx_city_ui, _my_city_ui, 54, _gh - 96, 180, 58));
    } else if (estado_demo == DemoEstado.GINASIO) {
        draw_set_color(make_color_rgb(242, 235, 208));
        draw_rectangle(70, 170, 680, 386, false);
        draw_set_color(make_color_rgb(108, 82, 68));
        draw_rectangle(70, 170, 680, 386, true);
        var _ginasio_speaker = demo_cidade_tem_ginasio(cidade_index) ? demo_dialog_sprite_cidade(id, professor_sprite) : professor_sprite;
        demo_draw_dialog_character(_ginasio_speaker, 70, 170, 680, 386);
        draw_set_color(make_color_rgb(36, 30, 28));
        battle_ui_font_title();
        draw_text(98, 196, demo_cidade_tem_ginasio(cidade_index) ? "Ginasio de " + demo_cidade_nome(cidade_index) : "Sem ginasio");
        battle_ui_font_body();
        draw_text_ext(98, 232, message, 24, 410);
        battle_ui_font_title();
        demo_draw_choice_button("Voltar", "", 54, _gh - 96, 180, 58, demo_hover_rect(_mx_city_ui, _my_city_ui, 54, _gh - 96, 180, 58));
    } else if (estado_demo == DemoEstado.CASA_MAE) {
        draw_set_color(make_color_rgb(242, 235, 208));
        draw_rectangle(70, 170, 680, 386, false);
        draw_set_color(make_color_rgb(108, 82, 68));
        draw_rectangle(70, 170, 680, 386, true);
        var _evento_speaker = cidade_index == 0 ? mae_sprite : demo_dialog_sprite_cidade(id, professor_sprite);
        demo_draw_dialog_character(_evento_speaker, 70, 170, 680, 386);
        draw_set_color(make_color_rgb(36, 30, 28));
        battle_ui_font_title();
        draw_text(98, 196, cidade_index == 0 ? "Casa da Mae" : (evento_titulo != "" ? evento_titulo : demo_cidade_atual().Evento));
        battle_ui_font_body();
        draw_text_ext(98, 232, message, 24, 410);
        battle_ui_font_title();
        demo_draw_choice_button("Voltar", "", 54, _gh - 96, 180, 58, demo_hover_rect(_mx_city_ui, _my_city_ui, 54, _gh - 96, 180, 58));
    } else if (estado_demo == DemoEstado.SAIR_CIDADE) {
        draw_set_color(make_color_rgb(242, 235, 208));
        draw_rectangle((_gw - 640) * 0.5, 210, (_gw + 640) * 0.5, 292, false);
        draw_set_color(make_color_rgb(108, 82, 68));
        draw_rectangle((_gw - 640) * 0.5, 210, (_gw + 640) * 0.5, 292, true);
        draw_set_color(make_color_rgb(36, 30, 28));
        var _destino_rota_ui = demo_rota_saida_destino_get(id);
        var _prompt_rota = "O caminho final esta selado.";

        if (_destino_rota_ui < cidade_index) {
            _prompt_rota = "Escolha a rota para voltar a " + demo_cidade_nome(_destino_rota_ui);
        } else if (_destino_rota_ui > cidade_index) {
            _prompt_rota = "Escolha a rota para " + demo_cidade_nome(_destino_rota_ui);
        }

        draw_text((_gw * 0.5) - (string_width(_prompt_rota) * 0.5), 238, _prompt_rota);

        var _route_w_ui = 360;
        var _route_h_ui = 132;
        var _route_gap_ui = 22;
        var _route_y_ui = 318;
        var _block_rota_ui = demo_rota_block_index(cidade_index, _destino_rota_ui);
        var _rotas_saida_ui = demo_rota_saida_opcoes_get(id, _destino_rota_ui);
        var _total_options_ui = array_length(_rotas_saida_ui);
        var _total_w_ui = (_route_w_ui * _total_options_ui) + (_route_gap_ui * max(0, _total_options_ui - 1));
        var _x_leave_ui = (_gw - _total_w_ui) * 0.5;
        var _prefix_rota_ui = _destino_rota_ui < cidade_index ? "Retornar: " : "Avancar: ";

        for (var _route_ui_i = 0; _route_ui_i < _total_options_ui; _route_ui_i += 1) {
            var _rota_ui = _rotas_saida_ui[_route_ui_i];
            var _card_x_ui = _x_leave_ui + (_route_ui_i * (_route_w_ui + _route_gap_ui));
            var _enabled_ui = _destino_rota_ui != cidade_index;

            if (_destino_rota_ui > cidade_index) {
                _enabled_ui = _enabled_ui && demo_cidade_ginasio_vencido(cidade_index);
                _enabled_ui = _enabled_ui && demo_rota_opcao_ativa(id, _block_rota_ui, _rota_ui, _destino_rota_ui);
            }

            demo_draw_route_choice_button(
                _rota_ui,
                _prefix_rota_ui,
                _card_x_ui,
                _route_y_ui,
                _route_w_ui,
                _route_h_ui,
                demo_hover_rect(_mx_city_ui, _my_city_ui, _card_x_ui, _route_y_ui, _route_w_ui, _route_h_ui),
                _enabled_ui
            );
        }

        demo_draw_choice_button("Voltar", "", 54, _gh - 96, 180, 58, demo_hover_rect(_mx_city_ui, _my_city_ui, 54, _gh - 96, 180, 58));
    }
} else if (estado_demo == DemoEstado.ROTA || estado_demo == DemoEstado.VITORIA || estado_demo == DemoEstado.DERROTA) {
    var _route_panel_x = 28;
    var _route_panel_y = _gh - 206;
    var _route_panel_w = _gw - 56;
    var _route_panel_h = 178;
    var _route_title = "Rota em andamento";

    if (estado_demo == DemoEstado.VITORIA) {
        _route_title = "Trecho concluido";
    } else if (estado_demo == DemoEstado.DERROTA) {
        _route_title = "Equipe abatida";
    }

    battle_ui_draw_nineslice_panel(_route_panel_x, _route_panel_y, _route_panel_w, _route_panel_h);
    draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(36, 30, 28) : c_white);
    battle_ui_font_title();
    var _route_inner_x = _route_panel_x + 42;
    var _route_inner_w = _route_panel_w - 84;
    draw_text(_route_inner_x, _route_panel_y + 20, string_upper(_route_title));
    draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(74, 62, 54) : c_white);
    battle_ui_font_body();
    var _route_from = demo_cidade_nome(rota_origem_index);
    var _route_to = demo_cidade_nome(rota_destino_index);
    var _route_name = is_struct(rota_atual) ? rota_atual.Nome : "Rota instavel";
    var _route_desc = is_struct(rota_atual) ? demo_rota_descricao_visual(rota_atual) : "caminho instavel";
    var _route_summary = "Estagio da rota: " + string(route_steps) + " / " + string(route_steps_needed) + "\n"
        + _route_from + " -> " + _route_to + "\n"
        + _route_name + " - " + _route_desc;
    draw_text_ext(_route_inner_x, _route_panel_y + 56, _route_summary, 25, _route_inner_w);
    battle_ui_font_title();

    var _route_progress = clamp(route_steps / max(1, route_steps_needed), 0, 1);
    var _bar_x = _route_inner_x;
    var _bar_y = _route_panel_y + _route_panel_h - 24;
    var _bar_w = _route_inner_w;
    var _bar_h = 9;
    var _encounter_text = "Encontros do caminho: " + string(route_steps) + " / " + string(route_steps_needed);
    draw_set_color(sprite_exists(global.ui_panel_sprite) ? make_color_rgb(36, 30, 28) : c_white);
    draw_text(_bar_x, _bar_y - 25, _encounter_text);
    draw_set_color(make_color_rgb(184, 172, 138));
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
    draw_set_color(make_color_rgb(84, 78, 70));
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, true);
    draw_set_color(make_color_rgb(72, 168, 248));
    draw_rectangle(_bar_x + 2, _bar_y + 2, _bar_x + 2 + max(0, (_bar_w - 4) * _route_progress), _bar_y + _bar_h - 2, false);

    if (estado_demo == DemoEstado.VITORIA || estado_demo == DemoEstado.DERROTA) {
        demo_draw_result_panel(id);
    }
}

demo_draw_capture_replace_overlay(id);

if (variable_global_exists("estado_jogo") && global.estado_jogo == EstadoJogo.DRAFT_HABILIDADE && is_struct(global.draft_habilidade_atual)) {
    draw_set_alpha(0.72);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    var _draft = global.draft_habilidade_atual;
    var _count = array_length(_draft.Opcoes);
    var _card_w_draft = 360;
    var _card_h_draft = 232;
    var _gap_draft = 34;
    var _total_w_draft = (_card_w_draft * _count) + (_gap_draft * max(0, _count - 1));
    var _start_x_draft = (_gw - _total_w_draft) * 0.5;
    var _card_y_draft = 292;

    var _draft_pokemon_name = (variable_struct_exists(_draft, "Pokemon") && is_struct(_draft.Pokemon) && variable_struct_exists(_draft.Pokemon, "Nome")) ? string_upper(_draft.Pokemon.Nome) : "MONSTRO";
    var _draft_title = _draft_pokemon_name + " - NIVEL " + string(_draft.Level);
    var _draft_subtitle = "Escolha uma nova habilidade";

    if (variable_struct_exists(_draft, "TipoDraft")) {
        if (_draft.TipoDraft == "upgrade") {
            _draft_title = _draft_pokemon_name + " - NIVEL " + string(_draft.Level);
            _draft_subtitle = "Escolha uma habilidade para evoluir";
        } else if (_draft.TipoDraft == "slot_ou_upgrade") {
            _draft_title = _draft_pokemon_name + " - NIVEL 20";
            _draft_subtitle = "Escolha uma habilidade ou uma evolucao";
        }
    }

    draw_set_color(c_white);
    draw_text(_gw * 0.5 - (string_width(_draft_title) * 0.5), 184, _draft_title);
    battle_ui_font_body();
    draw_text(_gw * 0.5 - (string_width(_draft_subtitle) * 0.5), 222, _draft_subtitle);
    battle_ui_font_title();

    var _draft_tooltip = undefined;
    var _mx_draft = device_mouse_x_to_gui(0);
    var _my_draft = device_mouse_y_to_gui(0);

    for (var _d = 0; _d < _count; _d += 1) {
        var _x_draft = _start_x_draft + (_d * (_card_w_draft + _gap_draft));
        var _hover_draft = demo_hover_rect(_mx_draft, _my_draft, _x_draft, _card_y_draft, _card_w_draft, _card_h_draft);

        if (_hover_draft) {
            draw_set_alpha(0.22);
            draw_set_color(make_color_rgb(255, 232, 88));
            draw_rectangle(_x_draft - 6, _card_y_draft - 6, _x_draft + _card_w_draft + 6, _card_y_draft + _card_h_draft + 6, false);
            draw_set_alpha(1);
        }

        battle_ui_draw_nineslice_panel(_x_draft, _card_y_draft, _card_w_draft, _card_h_draft);
        var _tooltip_draft = battle_ui_draw_skill_summary(_draft.Opcoes[_d], _x_draft + 28, _card_y_draft + 28, _card_w_draft - 56, true);

        if (is_struct(_tooltip_draft)) {
            _draft_tooltip = _tooltip_draft;
        }
    }

    demo_draw_status_tooltip(_draft_tooltip);
}

if (estado_demo != DemoEstado.GAME_OVER && estado_demo != DemoEstado.MENU && estado_demo != DemoEstado.VITORIA_FINAL) {
    diario_draw_hud();
}

missao_toast_draw();
