var _dt = delta_time / 1000000;

if (variable_global_exists("estado_jogo") && global.estado_jogo == EstadoJogo.DRAFT_HABILIDADE) {
    if (mouse_check_button_pressed(mb_left) && is_struct(global.draft_habilidade_atual)) {
        var _mx_draft = device_mouse_x_to_gui(0);
        var _my_draft = device_mouse_y_to_gui(0);
        var _gw_draft = display_get_gui_width();
        var _card_w_draft = 360;
        var _card_h_draft = 232;
        var _gap_draft = 34;
        var _count_draft = array_length(global.draft_habilidade_atual.Opcoes);
        var _total_w_draft = (_card_w_draft * _count_draft) + (_gap_draft * max(0, _count_draft - 1));
        var _start_x_draft = (_gw_draft - _total_w_draft) * 0.5;
        var _card_y_draft = 292;

        for (var _d = 0; _d < _count_draft; _d += 1) {
            var _x_draft = _start_x_draft + (_d * (_card_w_draft + _gap_draft));

            if (_mx_draft >= _x_draft && _mx_draft <= _x_draft + _card_w_draft && _my_draft >= _card_y_draft && _my_draft <= _card_y_draft + _card_h_draft) {
                pokemon_draft_escolher(global.draft_habilidade_atual, _d, -1);
                pokemon_batalha_sincronizar_habilidades(player_inst);
                break;
            }
        }
    }

    exit;
}

if (variable_instance_exists(id, "capture_replace_open") && capture_replace_open) {
    demo_capture_replace_handle_click(id);
    exit;
}

// Autosave: grava a run sempre que o jogador volta para a cidade.
run_save_step(id);

switch (estado_demo) {
    case DemoEstado.MENU:
        var _start_menu = keyboard_check_pressed(vk_enter);
        var _open_meta_shop = false;
        var _open_daily = keyboard_check_pressed(ord("D"));
        var _continuar = run_save_existe() && keyboard_check_pressed(ord("C"));

        if (mouse_check_button_pressed(mb_left)) {
            var _mx_menu = device_mouse_x_to_gui(0);
            var _my_menu = device_mouse_y_to_gui(0);
            var _btn_menu = demo_menu_start_button_rect();
            var _shop_btn_menu = demo_menu_shop_button_rect();
            _start_menu = demo_hover_rect(_mx_menu, _my_menu, _btn_menu.X, _btn_menu.Y, _btn_menu.W, _btn_menu.H);
            _open_meta_shop = demo_hover_rect(_mx_menu, _my_menu, _shop_btn_menu.X, _shop_btn_menu.Y, _shop_btn_menu.W, _shop_btn_menu.H);
            var _daily_btn_menu = demo_menu_daily_button_rect();
            _open_daily = demo_hover_rect(_mx_menu, _my_menu, _daily_btn_menu.X, _daily_btn_menu.Y, _daily_btn_menu.W, _daily_btn_menu.H);

            if (run_save_existe()) {
                var _continue_btn_menu = demo_menu_continue_button_rect();
                _continuar = demo_hover_rect(_mx_menu, _my_menu, _continue_btn_menu.X, _continue_btn_menu.Y, _continue_btn_menu.W, _continue_btn_menu.H);
            }
        }

        if (_continuar) {
            run_save_carregar(id);
            break;
        }

        if (_open_daily) {
            diario_iniciar(id);
            break;
        }

        if (_open_meta_shop) {
            estado_demo = DemoEstado.META_LOJA;
            meta_shop_scroll = 0;
            message = "Escolha uma melhoria permanente.";
            break;
        }

        if (_start_menu) {
            diario_encerrar();
            meta_progresso = demo_meta_carregar();
            demo_meta_sincronizar_globals(meta_progresso);
            starter_ids = demo_meta_starter_roll(meta_progresso);
            meta_inicio_aplicado = false;
            intro_timer = 0;
            intro_step = 0;
            estado_demo = DemoEstado.INTRO;
            message = "Prologo";
        }
        break;

    case DemoEstado.META_LOJA:
        if (keyboard_check_pressed(vk_escape)) {
            estado_demo = DemoEstado.MENU;
            message = "Menu inicial";
            break;
        }

        if (mouse_wheel_down()) {
            meta_shop_scroll += 118;
        } else if (mouse_wheel_up()) {
            meta_shop_scroll -= 118;
        }

        meta_shop_scroll = clamp(meta_shop_scroll, 0, demo_meta_shop_scroll_max());

        if (mouse_check_button_pressed(mb_left)) {
            var _mx_meta = device_mouse_x_to_gui(0);
            var _my_meta = device_mouse_y_to_gui(0);
            var _gh_meta = display_get_gui_height();
            var _meta_view = demo_meta_shop_view_rect();

            if (demo_hover_rect(_mx_meta, _my_meta, 72, _gh_meta - 112, 190, 54)) {
                estado_demo = DemoEstado.MENU;
                message = "Menu inicial";
                break;
            }

            var _meta_entries = demo_meta_shop_entries();

            if (demo_hover_rect(_mx_meta, _my_meta, _meta_view.X, _meta_view.Y, _meta_view.W, _meta_view.H)) {
                for (var _meta_i = 0; _meta_i < array_length(_meta_entries); _meta_i += 1) {
                    var _meta_rect = demo_meta_shop_card_rect(_meta_i, meta_shop_scroll);

                    if (demo_hover_rect(_mx_meta, _my_meta, _meta_rect.X, _meta_rect.Y, _meta_rect.W, _meta_rect.H)) {
                        demo_meta_comprar(id, _meta_entries[_meta_i].ID);
                        break;
                    }
                }
            }
        }
        break;

    case DemoEstado.INTRO:
        intro_timer += _dt;

        var _intro_skip = false;

        if (mouse_check_button_pressed(mb_left)) {
            var _mx_intro = device_mouse_x_to_gui(0);
            var _my_intro = device_mouse_y_to_gui(0);
            var _skip_rect_intro = demo_intro_skip_button_rect();
            _intro_skip = demo_hover_rect(_mx_intro, _my_intro, _skip_rect_intro.X, _skip_rect_intro.Y, _skip_rect_intro.W, _skip_rect_intro.H);
        }

        if (_intro_skip || keyboard_check_pressed(vk_escape)) {
            estado_demo = DemoEstado.ESCOLHA_INICIAL;
            message = "Escolha seu monstro inicial";
            break;
        }

        if (keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
            if (intro_step >= demo_intro_step_max()) {
                estado_demo = DemoEstado.ESCOLHA_INICIAL;
                message = "Escolha seu monstro inicial";
            } else {
                intro_step += 1;
                intro_timer = 0;
            }
        }
        break;

    case DemoEstado.ESCOLHA_INICIAL:
        if (keyboard_check_pressed(ord("1"))) {
            starter_id = starter_ids[0];
        } else if (keyboard_check_pressed(ord("2"))) {
            starter_id = starter_ids[1];
        } else if (keyboard_check_pressed(ord("3"))) {
            starter_id = starter_ids[2];
        }

        if (mouse_check_button_pressed(mb_left)) {
            var _mx = device_mouse_x_to_gui(0);
            var _my = device_mouse_y_to_gui(0);
            var _gw = display_get_gui_width();
            var _gh = display_get_gui_height();
            var _card_w = 350;
            var _gap = 30;
            var _start_x = (_gw - ((_card_w * 3) + (_gap * 2))) * 0.5;
            var _card_y = 140;
            var _card_h = min(580, _gh - _card_y - 34);

            for (var _i = 0; _i < 3; _i += 1) {
                var _x = _start_x + (_i * (_card_w + _gap));

                if (_mx >= _x && _mx <= _x + _card_w && _my >= _card_y && _my <= _card_y + _card_h) {
                    starter_id = starter_ids[_i];
                }
            }
        }

        if (starter_id > 0) {
            var _escopo_inicial = diario_escopo("inicial");
            player_pokemon_data = demo_criar_pokemon_data(starter_id, 5, false);
            diario_escopo_fim(_escopo_inicial);
            player_pokemon_data.FoiCapturado = true;
            player_pokemon_data.Capturado = true;
            player_party = [player_pokemon_data];
            player_party_active_index = 0;
            demo_meta_aplicar_inicio_run(id);
            pokedex_capturar(starter_id);
            estado_demo = DemoEstado.LAB_CARVALHO;
            professor_carvalho_visto = true;
            message = demo_dialogo_professor_carvalho();
        }
        break;

    case DemoEstado.CIDADE:
        if (mouse_check_button_pressed(mb_left)) {
            var _mx_city = device_mouse_x_to_gui(0);
            var _my_city = device_mouse_y_to_gui(0);
            var _gh_city = display_get_gui_height();
            var _gw_city = display_get_gui_width();

            if (demo_hover_rect(_mx_city, _my_city, 54, _gh_city - 96, 210, 58)) {
                mochila_contexto_anterior = estado_demo;
                estado_demo = DemoEstado.MOCHILA;
                message = "Mochila aberta.";
            } else {
                var _markers_city = demo_city_markers(id);

                for (var _marker_i = 0; _marker_i < array_length(_markers_city); _marker_i += 1) {
                    var _marker = _markers_city[_marker_i];
                    var _marker_pos = demo_city_marker_pos(id, _marker, _gw_city, _gh_city);

                    if (demo_city_marker_hit(_mx_city, _my_city, _marker_pos.X, _marker_pos.Y)) {
                        demo_city_marker_ativar(id, _marker);
                        break;
                    }
                }
            }
        }
        break;

    case DemoEstado.POKESTORE:
        if (mouse_check_button_pressed(mb_left)) {
            var _mx_shop = device_mouse_x_to_gui(0);
            var _my_shop = device_mouse_y_to_gui(0);
            var _shop_items = demo_shop_items_cidade(cidade_index);
            var _shop_x = 88;
            var _shop_y = 214;
            var _shop_w = 520;
            var _row_h = 58;

            for (var _shop_i = 0; _shop_i < array_length(_shop_items); _shop_i += 1) {
                if (demo_hover_rect(_mx_shop, _my_shop, _shop_x, _shop_y + (_shop_i * (_row_h + 8)), _shop_w, _row_h)) {
                    demo_item_comprar(id, _shop_items[_shop_i]);
                }
            }

            if (demo_hover_rect(_mx_shop, _my_shop, 264, display_get_gui_height() - 96, 210, 58)) {
                mochila_contexto_anterior = estado_demo;
                estado_demo = DemoEstado.MOCHILA;
                message = "Mochila aberta.";
            }
        }
        // falls through to the common back button below
    case DemoEstado.LAB_CARVALHO:
    case DemoEstado.GINASIO:
    case DemoEstado.CASA_MAE:
        if (mouse_check_button_pressed(mb_left)) {
            var _mx_sub = device_mouse_x_to_gui(0);
            var _my_sub = device_mouse_y_to_gui(0);

            if (demo_hover_rect(_mx_sub, _my_sub, 54, display_get_gui_height() - 96, 180, 58)) {
                estado_demo = DemoEstado.CIDADE;
                message = demo_cidade_nome(cidade_index);
            }
        }
        break;

    case DemoEstado.MOCHILA:
        if (mouse_check_button_pressed(mb_left)) {
            var _mx_bag = device_mouse_x_to_gui(0);
            var _my_bag = device_mouse_y_to_gui(0);
            var _bag_ids = demo_item_ids_possuidos(inventario);
            var _bag_x = 88;
            var _bag_y = 236;
            var _bag_col_w = 306;
            var _bag_row_h = 52;

            for (var _bag_i = 0; _bag_i < array_length(_bag_ids); _bag_i += 1) {
                var _bag_id = _bag_ids[_bag_i];
                var _bag_item = demo_item_get(_bag_id);
                var _bag_qty = demo_inventario_quantidade(inventario, _bag_id);
                var _bag_col = _bag_i div 8;
                var _bag_row = _bag_i mod 8;
                var _bag_item_x = _bag_x + (_bag_col * (_bag_col_w + 18));
                var _bag_item_y = _bag_y + (_bag_row * (_bag_row_h + 8));

                if (_bag_qty > 0 && demo_item_pode_usar(_bag_item, false) && demo_hover_rect(_mx_bag, _my_bag, _bag_item_x, _bag_item_y, _bag_col_w, _bag_row_h)) {
                    demo_item_usar(id, _bag_id, false);
                    break;
                }
            }

            if (demo_hover_rect(_mx_bag, _my_bag, 54, display_get_gui_height() - 96, 180, 58)) {
                estado_demo = mochila_contexto_anterior;
                message = demo_cidade_nome(cidade_index);
            }
        }
        break;

    case DemoEstado.SAIR_CIDADE:
        if (mouse_check_button_pressed(mb_left)) {
            var _mx_leave = device_mouse_x_to_gui(0);
            var _my_leave = device_mouse_y_to_gui(0);
            var _gw_leave = display_get_gui_width();
            var _gh_leave = display_get_gui_height();
            var _route_w_leave = 360;
            var _route_h_leave = 132;
            var _route_gap_leave = 22;
            var _route_y_leave = 318;

            if (demo_hover_rect(_mx_leave, _my_leave, 54, _gh_leave - 96, 180, 58)) {
                estado_demo = DemoEstado.CIDADE;
                message = demo_cidade_nome(cidade_index);
                saida_destino_index = -1;
                break;
            }

            var _destino_leave = demo_rota_saida_destino_get(id);
            var _block_leave = demo_rota_block_index(cidade_index, _destino_leave);
            var _rotas_leave = demo_rota_saida_opcoes_get(id, _destino_leave);
            var _total_options = array_length(_rotas_leave);
            var _total_w_leave = (_route_w_leave * _total_options) + (_route_gap_leave * max(0, _total_options - 1));
            var _x_leave = (_gw_leave - _total_w_leave) * 0.5;

            for (var _route_i = 0; _route_i < _total_options; _route_i += 1) {
                var _rota_leave = _rotas_leave[_route_i];
                var _card_x_leave = _x_leave + (_route_i * (_route_w_leave + _route_gap_leave));

                if (demo_hover_rect(_mx_leave, _my_leave, _card_x_leave, _route_y_leave, _route_w_leave, _route_h_leave)) {
                    if (_destino_leave <= cidade_index) {
                        saida_destino_index = -1;
                        demo_rota_iniciar(_destino_leave, _rota_leave);
                    } else if (cidade_index >= array_length(kanto_cidades) - 1) {
                        message = demo_cidade_ginasio_vencido(cidade_index)
                            ? "O Rasgo Temporal aguarda no centro da cidade. Feche-o para terminar a run."
                            : demo_cidade_atual().Lider + " aguarda no ginasio.";
                    } else if (!demo_cidade_ginasio_vencido(cidade_index)) {
                        message = "Voce precisa vencer o lider desta cidade antes de prosseguir.";
                    } else if (!demo_rota_opcao_ativa(id, _block_leave, _rota_leave, _destino_leave)) {
                        message = "Essa rota ficou para tras nesta run.";
                    } else {
                        demo_rota_escolher(id, _block_leave, _rota_leave);
                        saida_destino_index = -1;
                        demo_rota_iniciar(_destino_leave, _rota_leave);
                    }

                    break;
                }
            }
        }
        break;

    case DemoEstado.ROTA:
        if (keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
            route_steps += 1;

            if (!route_trainer_encountered && route_trainer_step == route_steps && demo_rota_trainer_iniciar(id)) {
                route_trainer_encountered = true;
                break;
            }

            demo_rota_encontro_selvagem_iniciar(id);
        }
        break;

    case DemoEstado.BATALHA:
        if (instance_exists(enemy_inst) && !enemy_inst.vivo) {
            if (instance_exists(player_inst) && is_struct(player_pokemon_data)) {
                player_pokemon_data.HpAtual = max(1, player_inst.hp_atual);
            }

            var _xp_tipo = "selvagem";

            if (battle_context == "ginasio" || battle_context == "treinador" || battle_context == "chefe") {
                _xp_tipo = "treinador";
            } else if (battle_context == "rocket") {
                _xp_tipo = "rocket";
            }

            var _xp_enemy_level = is_struct(enemy_pokemon_data) ? enemy_pokemon_data.Level : 1;
            var _xp_reward = demo_exp_recompensa(player_pokemon_data, _xp_enemy_level, _xp_tipo, false);
            var _xp_ganhos = demo_exp_compartilhar(id, _xp_reward);
            var _money_tipo = "selvagem";

            if (battle_context == "ginasio" || battle_context == "chefe") {
                _money_tipo = "ginasio";
            } else if (battle_context == "treinador") {
                _money_tipo = "treinador";
            } else if (battle_context == "rocket") {
                _money_tipo = "rocket";
            }

            var _money_reward = demo_meta_dinheiro_aplicar(id, pokemon_recompensa_dinheiro(enemy_pokemon_data, _money_tipo));
            demo_battle_reward_adicionar(id, _xp_reward, _xp_ganhos, _money_reward);
            missao_evento(id, "vitoria", enemy_pokemon_data);
            missao_evento(id, "checar", undefined);

            if ((battle_context == "treinador" || battle_context == "chefe") && demo_trainer_tem_proximo(id)) {
                demo_trainer_enviar_proximo(id);
                break;
            }

            var _reward_items = [];

            if (battle_context == "treinador") {
                _reward_items = demo_trainer_drops_gerar(id);
                battle_reward_items = _reward_items;
            }

            var _total_xp_reward = battle_reward_xp_base_total;
            var _total_xp_ganhos = battle_reward_ganhos;
            var _total_money_reward = battle_reward_money_total;
            var _fragmentos_reward = 0;
            dinheiro += _total_money_reward;
            var _pos_battle_heal = demo_party_curar_pos_batalha(id);
            estado_demo = DemoEstado.VITORIA;
            diario_registrar_vitoria();

            if (battle_context == "treinador" || battle_context == "ginasio") {
                missao_evento(id, "treinador", undefined);
            }
            result_timer = 1.5;
            if (battle_context == "chefe") {
                message = conteudo_mundo_texto("chefe_final", "Aeonox") + " caiu! O Rasgo Temporal esta se fechando. Pressione ENTER ou clique.";
            } else if (battle_context == "ginasio") {
                _fragmentos_reward = demo_meta_fragmentos_ginasio(gym_battle_city_index);
                demo_meta_fragmentos_adicionar(id, _fragmentos_reward);
                ginasios_vencidos[gym_battle_city_index] = true;
                message = "Vitoria contra " + kanto_cidades[gym_battle_city_index].Lider + "! +" + string(_fragmentos_reward) + " Fragmentos do Espaco.";
            } else if (battle_context == "treinador") {
                message = "Vitoria contra " + battle_trainer_name + "! Pressione ENTER ou clique para continuar pela rota.";
            } else if (route_steps >= route_steps_needed) {
                message = "Rota concluida! Pressione ENTER ou clique para chegar a " + demo_cidade_nome(rota_destino_index) + ".";
            } else {
                message = "Encontro vencido. Pressione ENTER ou clique para continuar pela rota.";
            }
            battle_result_info = demo_resultado_criar("vitoria", "Vitoria!", message, _total_xp_reward, _total_xp_ganhos, undefined, _total_money_reward, _reward_items, _fragmentos_reward);
            battle_log_force("Vitoria! +" + string(_total_xp_reward) + " EXP e M$ " + string(_total_money_reward) + ".");
            if (_pos_battle_heal > 0) {
                battle_log_push("A equipe recuperou um pouco de HP.");
            }
        } else if (instance_exists(player_inst) && !player_inst.vivo) {
            if (is_struct(player_pokemon_data)) {
                player_pokemon_data.HpAtual = 0;
            }

            var _tem_reserva = false;
            demo_party_garantir(id);

            for (var _party_check = 0; _party_check < array_length(player_party); _party_check += 1) {
                var _party_member = player_party[_party_check];

                if (_party_check != player_party_active_index && is_struct(_party_member) && (!variable_struct_exists(_party_member, "HpAtual") || _party_member.HpAtual > 0)) {
                    _tem_reserva = true;
                    break;
                }
            }

            if (_tem_reserva) {
                if (!variable_global_exists("troca_overlay_aberta") || !global.troca_overlay_aberta) {
                    global.troca_overlay_aberta = true;
                    global.mochila_overlay_aberta = false;
                    global.pokedex_overlay_aberto = false;
                    global.time_scale = 0;
                    global.velocidade_jogo = 0;
                    battle_log_force(player_pokemon_data.Nome + " desmaiou! Escolha outro monstro.");
                }

                break;
            }

            estado_demo = DemoEstado.DERROTA;
            result_timer = 1.5;
            message = "Todos os monstros da equipe foram derrotados.";
            battle_result_info = demo_resultado_criar("derrota", "Game Over", message, 0, [], undefined);
            battle_log_force("Seu monstro desmaiou...");
        }
        break;

    case DemoEstado.CAPTURA:
        if (is_struct(capture_anim)) {
            capture_anim.Timer += delta_time / 1000000;

            if (capture_anim.Timer >= capture_anim.Duracao) {
                if (capture_anim.Success) {
                    if (instance_exists(enemy_inst)) {
                        if (is_struct(enemy_pokemon_data)) {
                            enemy_pokemon_data.HpAtual = max(1, enemy_inst.hp_atual);
                        }

                        enemy_inst.vivo = false;
                        enemy_inst.batalha_ativo = false;
                    }

                    var _xp_capture_level = is_struct(enemy_pokemon_data) ? enemy_pokemon_data.Level : 1;
                    var _xp_capture_reward = demo_exp_recompensa(player_pokemon_data, _xp_capture_level, "captura", true);
                    var _xp_capture_ganhos = demo_exp_compartilhar(id, _xp_capture_reward);
                    var _money_capture_reward = demo_meta_dinheiro_aplicar(id, pokemon_recompensa_dinheiro(enemy_pokemon_data, "captura"));
                    dinheiro += _money_capture_reward;
                    estado_demo = DemoEstado.VITORIA;
                    diario_registrar_captura();
                    missao_evento(id, "captura", enemy_pokemon_data);
                    result_timer = 1.0;
                    battle_result_info = demo_resultado_criar("captura", "Monstro capturado!", message, _xp_capture_reward, _xp_capture_ganhos, enemy_pokemon_data, _money_capture_reward);

                    demo_party_garantir(id);

                    if (array_length(player_party) >= 4) {
                        demo_capture_replace_abrir(id, enemy_pokemon_data);
                        message = "Capturou " + enemy_pokemon_data.Nome + "! Escolha quem sai da equipe.";
                        battle_result_info.Mensagem = message;
                        battle_log_force(enemy_pokemon_data.Nome + " foi capturado! Escolha quem sera substituido.");
                    } else {
                        demo_party_adicionar(id, enemy_pokemon_data);
                        var _pos_capture_heal = demo_party_curar_pos_batalha(id);
                        message = "Capturou " + enemy_pokemon_data.Nome + "! Pressione ENTER ou clique para continuar.";
                        battle_result_info.Mensagem = message;
                        battle_log_force(enemy_pokemon_data.Nome + " foi capturado! +" + string(_xp_capture_reward) + " EXP e M$ " + string(_money_capture_reward) + ".");
                        if (_pos_capture_heal > 0) {
                            battle_log_push("A equipe recuperou um pouco de HP.");
                        }
                    }
                } else {
                    estado_demo = DemoEstado.BATALHA;
                    battle_time_scale_restore_preferido();
                    message = enemy_pokemon_data.Nome + " escapou da Capsula!";
                    battle_log_force(message);
                }

                capture_anim = undefined;
            }
        }
        break;

    case DemoEstado.VITORIA:
    case DemoEstado.DERROTA:
        result_timer = max(0, result_timer - _dt);

        if (result_timer <= 0 && (keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left))) {
            demo_cleanup_battle(id);

            if (estado_demo == DemoEstado.DERROTA) {
                diario_finalizar(id);
                run_save_apagar();
                estado_demo = DemoEstado.GAME_OVER;
                game_over_timer = 0;
                message = "A run terminou.";
                break;
            }

            if (battle_context == "chefe") {
                demo_vitoria_final_iniciar(id);
                break;
            }

            if (battle_context == "rota" || battle_context == "treinador" || battle_context == "rocket") {
                if (route_steps >= route_steps_needed) {
                    demo_cidade_chegar(rota_destino_index);
                } else {
                    estado_demo = DemoEstado.ROTA;
                    message = "A trilha ate " + demo_cidade_nome(rota_destino_index) + " continua. Clique ou pressione ENTER para avancar.";
                }
            } else {
                estado_demo = DemoEstado.CIDADE;
                message = demo_cidade_eh_final(cidade_index)
                    ? kanto_cidades[cidade_index].Lider + " caiu! O Rasgo Temporal se abriu no centro da cidade."
                    : kanto_cidades[cidade_index].Lider + " foi derrotado. A proxima rota esta liberada.";
            }
        }
        break;

    case DemoEstado.VITORIA_FINAL:
        vitoria_final_timer += _dt;

        if (vitoria_final_timer > 0.8) {
            var _vf_click = false;

            if (mouse_check_button_pressed(mb_left)) {
                var _vf_btn = demo_game_over_button_rect(display_get_gui_width(), display_get_gui_height());
                _vf_click = demo_hover_rect(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _vf_btn.X, _vf_btn.Y, _vf_btn.W, _vf_btn.H);
            }

            if (keyboard_check_pressed(vk_enter) || _vf_click) {
                demo_run_resetar(id, DemoEstado.MENU);
            }
        }
        break;

    case DemoEstado.GAME_OVER:
        game_over_timer += _dt;

        if (game_over_timer > 0.4) {
            var _go_enter = keyboard_check_pressed(vk_enter);
            var _go_click = false;

            if (mouse_check_button_pressed(mb_left)) {
                var _go_mx = device_mouse_x_to_gui(0);
                var _go_my = device_mouse_y_to_gui(0);
                var _go_btn = demo_game_over_button_rect(display_get_gui_width(), display_get_gui_height());
                _go_click = demo_hover_rect(_go_mx, _go_my, _go_btn.X, _go_btn.Y, _go_btn.W, _go_btn.H);
            }

            if (_go_enter || _go_click) {
                demo_run_resetar(id, DemoEstado.MENU);
            }
        }
        break;
}
