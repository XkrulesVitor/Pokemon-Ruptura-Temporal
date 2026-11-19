// Autoteste: percorre as telas principais sozinho, salva screenshots e registra erros.
// Ative com a variavel de ambiente RASGO_AUTOTESTE=1. A pasta de saida vem de
// RASGO_AUTOTESTE_DIR (ou fica em game_save_id/autoteste/). No fim o jogo fecha sozinho.
// Rode pelo script tools/autoteste.ps1.

function autoteste_ativo() {
    return variable_global_exists("autoteste") && is_struct(global.autoteste);
}

function autoteste_log(_texto) {
    if (!autoteste_ativo()) {
        return;
    }

    var _linha = "[" + string_format(current_time / 1000, 4, 2) + "s] " + string(_texto);
    array_push(global.autoteste.Log, _linha);
    show_debug_message("[autoteste] " + _linha);
}

function autoteste_log_salvar() {
    if (!autoteste_ativo()) {
        return;
    }

    var _file = file_text_open_write(global.autoteste.Dir + "log.txt");

    for (var _i = 0; _i < array_length(global.autoteste.Log); _i += 1) {
        file_text_write_string(_file, global.autoteste.Log[_i]);
        file_text_writeln(_file);
    }

    file_text_close(_file);
}

function autoteste_iniciar() {
    if (environment_get_variable("RASGO_AUTOTESTE") != "1") {
        return;
    }

    var _dir = environment_get_variable("RASGO_AUTOTESTE_DIR");

    if (_dir == "") {
        _dir = game_save_id + "autoteste/";
    }

    _dir = string_replace_all(_dir, "\\", "/");

    if (string_char_at(_dir, string_length(_dir)) != "/") {
        _dir += "/";
    }

    if (!directory_exists(_dir)) {
        directory_create(_dir);
    }

    global.autoteste = {
        Dir: _dir,
        Passo: -1,
        Timer: 0,
        Espera: 0,
        Capturar: "",
        AguardandoFoto: false,
        Log: [],
        DraftsVistos: 0,
        Executado: false,
        Esperado: "",
        Fim: false
    };

    exception_unhandled_handler(function(_erro) {
        autoteste_log("ERRO NAO TRATADO: " + string(_erro.longMessage));
        autoteste_log("pilha: " + string(_erro.stacktrace));
        autoteste_log_salvar();
        game_end();
        return 0;
    });

    autoteste_log("autoteste iniciado. saida: " + _dir);
}

function autoteste_jogo() {
    return instance_number(obj_demo_game) > 0 ? instance_find(obj_demo_game, 0) : noone;
}

function autoteste_foto(_nome) {
    global.autoteste.Capturar = _nome;
    global.autoteste.AguardandoFoto = true;
}

// Cada passo: { Nome, Acao (funcao executada com o obj_demo_game), Espera (s), Foto, AguardarBatalha }
function autoteste_passos() {
    return [
        { Nome: "menu", Espera: 2.0, Foto: "01_menu", Acao: function() {} },
        { Nome: "loja permanente", Espera: 1.2, Foto: "02_loja_permanente", Acao: function() { estado_demo = DemoEstado.META_LOJA; } },
        { Nome: "intro 1", Espera: 2.5, Foto: "03_intro_1", Acao: function() {
            estado_demo = DemoEstado.INTRO;
            intro_step = 0;
            intro_timer = 0;
        } },
        { Nome: "intro 2", Espera: 2.5, Foto: "04_intro_2", Acao: function() {
            intro_step = floor(demo_intro_step_max() * 0.5);
            intro_timer = 0;
        } },
        { Nome: "intro 3", Espera: 2.5, Foto: "05_intro_3", Acao: function() {
            intro_step = demo_intro_step_max();
            intro_timer = 0;
        } },
        { Nome: "escolha inicial", Espera: 1.5, Foto: "06_escolha_inicial", Acao: function() {
            estado_demo = DemoEstado.ESCOLHA_INICIAL;
        } },
        { Nome: "laboratorio", Espera: 1.5, Foto: "07_laboratorio", Acao: function() {
            starter_id = starter_ids[0];
        } },
        { Nome: "cidade inicial", Espera: 1.5, Foto: "08_cidade_inicial", Acao: function() {
            estado_demo = DemoEstado.CIDADE;
            cidade_index = 0;
            message = demo_cidade_nome(cidade_index);
        } },
        { Nome: "bestiario", Espera: 1.5, Foto: "09_bestiario", Acao: function() {
            bestiario_garantir();
            var _ids = criatura_ids();

            // So marca em memoria (nao salva) para a foto mostrar entradas.
            for (var _i = 0; _i < min(24, array_length(_ids)); _i += 1) {
                var _entrada = variable_struct_get(global.bestiario_estado, string(_ids[_i]));

                if (is_struct(_entrada)) {
                    _entrada.Capturado = true;
                    _entrada.Descoberto = true;
                }
            }

            global.bestiario_overlay_aberto = true;
        } },
        { Nome: "mochila", Espera: 1.2, Foto: "10_mochila", Acao: function() {
            global.bestiario_overlay_aberto = false;
            global.time_scale = 1;
            demo_inventario_adicionar(inventario, "pokebola", 5);
            demo_inventario_adicionar(inventario, "potion", 2);
            demo_inventario_adicionar(inventario, "oran_berry", 1);
            demo_inventario_adicionar(inventario, "rare_candy", 1);
            mochila_contexto_anterior = DemoEstado.CIDADE;
            estado_demo = DemoEstado.MOCHILA;
        } },
        { Nome: "mercado", Espera: 1.2, Foto: "11_mercado", Acao: function() {
            cidade_index = 1;
            estado_demo = DemoEstado.POKESTORE;
        } },
        { Nome: "escolha de rota", Espera: 1.5, Foto: "12_escolha_rota", Acao: function() {
            cidade_index = 0;
            saida_destino_index = 1;
            estado_demo = DemoEstado.SAIR_CIDADE;
        } },
        { Nome: "rota", Espera: 1.5, Foto: "13_rota", Acao: function() {
            var _opcoes = demo_rota_saida_opcoes_get(id, 1);
            var _rota = _opcoes[0];
            demo_rota_escolher(id, demo_rota_block_index(0, 1), _rota);
            demo_rota_iniciar(1, _rota);
        } },
        { Nome: "batalha selvagem", Espera: 2.5, Foto: "14_batalha_inicio", Acao: function() {
            var _nivel = demo_rota_enemy_level(rota_origem_index, rota_destino_index);
            var _inimigo = demo_rota_enemy_id(rota_atual, _nivel, "selvagem");
            enemy_criatura_data = demo_criar_criatura_data(_inimigo, _nivel, true, true, true, "selvagem");
            battle_context = "rota";
            route_steps += 1;
            demo_start_battle(id);
            autoteste_log("selvagem: " + enemy_criatura_data.Nome + " nv " + string(_nivel));
        } },
        { Nome: "batalha acelerada", Espera: 4.0, Foto: "15_batalha_meio", Acao: function() {
            battle_time_scale_set(3.0, false);
        } },
        { Nome: "fim da batalha", Espera: 1.0, Foto: "16_batalha_resultado", AguardarBatalha: true, Acao: function() {} },
        { Nome: "cidade com lider", Espera: 1.5, Foto: "17_cidade_lider", Acao: function() {
            demo_cleanup_battle(id);
            demo_cidade_chegar(2);
        } },
        { Nome: "batalha de lider", Espera: 2.5, Foto: "18_lider_inicio", Acao: function() {
            var _markers = demo_city_markers(id);

            for (var _i = 0; _i < array_length(_markers); _i += 1) {
                if (_markers[_i].Action == "gym") {
                    demo_city_marker_ativar(id, _markers[_i]);
                    break;
                }
            }

            battle_time_scale_set(3.0, false);
            autoteste_log("lider: " + (is_struct(enemy_criatura_data) ? enemy_criatura_data.Nome : "?"));
        } },
        { Nome: "fim do lider", Espera: 1.0, Foto: "19_lider_resultado", AguardarBatalha: true, Acao: function() {} },
        { Nome: "game over", Espera: 1.5, Foto: "20_game_over", Acao: function() {
            demo_cleanup_battle(id);
            estado_demo = DemoEstado.GAME_OVER;
            game_over_timer = 0;
        } },
        { Nome: "chefe: cidade final", Espera: 1.5, Foto: "21_cidade_final_rasgo", Acao: function() {
            demo_run_resetar(id, DemoEstado.CIDADE);
            var _p = demo_criar_criatura_data(conteudo_pacote_iniciais("base")[1], 28, true);
            _p.FoiCapturado = true;
            _p.Capturado = true;
            player_party = [_p];
            player_criatura_data = _p;
            player_party_active_index = 0;
            cidade_index = array_length(kanto_cidades) - 1;
            ginasios_vencidos[cidade_index] = true;
            message = demo_cidade_nome(cidade_index);
        } },
        { Nome: "chefe: fase 1", Espera: 2.5, Foto: "22_chefe_fase1", Acao: function() {
            var _markers = demo_city_markers(id);
            var _achou = false;

            for (var _i = 0; _i < array_length(_markers); _i += 1) {
                if (_markers[_i].Action == "boss") {
                    demo_city_marker_ativar(id, _markers[_i]);
                    _achou = true;
                    break;
                }
            }

            autoteste_log("marcador do rasgo encontrado: " + string(_achou) + " | fases: " + string(array_length(trainer_party)));
        } },
        { Nome: "chefe: fase 2", Espera: 2.5, Foto: "23_chefe_fase2", Acao: function() {
            if (instance_exists(enemy_inst)) enemy_inst.vivo = false;
        } },
        { Nome: "chefe: fase 3", Espera: 2.5, Foto: "24_chefe_fase3", Acao: function() {
            autoteste_log("fase atual: " + enemy_criatura_data.Nome);
            if (instance_exists(enemy_inst)) enemy_inst.vivo = false;
        } },
        { Nome: "chefe: derrotado", Espera: 1.5, Foto: "25_chefe_derrotado", Acao: function() {
            autoteste_log("fase atual: " + enemy_criatura_data.Nome);
            if (instance_exists(enemy_inst)) enemy_inst.vivo = false;
        } },
        { Nome: "vitoria final", Espera: 3.0, Foto: "26_vitoria_final", Acao: function() {
            autoteste_log("estado antes da vitoria final: " + string(estado_demo) + " | " + message);
            demo_cleanup_battle(id);
            demo_vitoria_final_iniciar(id);
        } },
        { Nome: "save: preparar run", Espera: 1.5, Foto: "27_save_cidade", Acao: function() {
            autoteste_log("save apagado apos a vitoria final: " + string(!run_save_existe()));
            demo_run_resetar(id, DemoEstado.ROTA);
            var _a = demo_criar_criatura_data(conteudo_pacote_iniciais("base")[2], 14, true);
            var _b = demo_criar_criatura_data(criatura_id_por_nome("Gaviolento"), 12, true);
            _a.Capturado = true;
            _b.Capturado = true;
            player_party = [_a, _b];
            player_party_active_index = 1;
            player_criatura_data = _b;
            dinheiro = 777;
            demo_inventario_adicionar(inventario, "great_ball", 3);
            ginasios_vencidos[2] = true;
            cidade_index = 3;
            message = demo_cidade_nome(3);
            estado_demo = DemoEstado.CIDADE; // a transicao ROTA -> CIDADE dispara o autosave
            var _equipadas = 0;
            for (var _i = 0; _i < 4; _i += 1) if (is_struct(_a.HabilidadesEquipadas[_i])) _equipadas += 1;
            global.autoteste.Esperado = _a.Nome + " nv" + string(_a.Level) + " xp" + string(_a.ExpAtual) + " hab" + string(_equipadas) + " | " + _b.Nome + " nv" + string(_b.Level) + " | ativa 1 | $777 | cidade 3 | ginasio2 1 | great_ball 3";
            autoteste_log("esperado: " + global.autoteste.Esperado);
        } },
        { Nome: "save: voltar ao menu", Espera: 1.2, Foto: "28_menu_continuar", Acao: function() {
            autoteste_log("save existe: " + string(run_save_existe()));
            demo_run_resetar(id, DemoEstado.MENU);
        } },
        { Nome: "save: continuar", Espera: 1.5, Foto: "29_run_retomada", Acao: function() {
            var _ok = run_save_carregar(id);
            var _a = player_party[0];
            var _b = player_party[1];
            var _equipadas = 0;
            for (var _i = 0; _i < 4; _i += 1) if (is_struct(_a.HabilidadesEquipadas[_i])) _equipadas += 1;
            var _obtido = _a.Nome + " nv" + string(_a.Level) + " xp" + string(_a.ExpAtual) + " hab" + string(_equipadas) + " | " + _b.Nome + " nv" + string(_b.Level) + " | ativa " + string(player_party_active_index) + " | $" + string(dinheiro) + " | cidade " + string(cidade_index) + " | ginasio2 " + string(ginasios_vencidos[2]) + " | great_ball " + string(demo_inventario_quantidade(inventario, "great_ball"));
            autoteste_log("carregou: " + string(_ok) + " | obtido: " + _obtido);
            autoteste_log(_obtido == global.autoteste.Esperado ? "SAVE OK: ida e volta identica" : "SAVE DIVERGENTE");
            autoteste_log("instanceof da criatura restaurada: " + instanceof(_a));
        } },
        { Nome: "save: batalha com a equipe restaurada", Espera: 3.0, Foto: "30_batalha_pos_save", Acao: function() {
            enemy_criatura_data = demo_criar_criatura_data(criatura_id_por_nome("Peixote"), 10, true, true, true, "selvagem");
            battle_context = "rota";
            demo_start_battle(id);
        } },
        { Nome: "menu com diario", Espera: 1.2, Foto: "31_menu_diario", Acao: function() {
            demo_run_resetar(id, DemoEstado.MENU);
        } },
        { Nome: "diario: inicio", Espera: 1.5, Foto: "32_diario_laboratorio", Acao: function() {
            diario_iniciar(id);
            autoteste_log("diario " + global.diario.Chave + " oficial=" + string(global.diario.Oficial) + " inicial=" + demo_criatura_nome(global.diario.InicialID));
        } },
        { Nome: "diario: cidade", Espera: 1.2, Foto: "33_diario_cidade", Acao: function() {
            autoteste_log("diario equipe: " + player_party[0].Nome + " nv " + string(player_party[0].Level) + " hp " + string(player_party[0].HpMax) + " atk " + string(player_party[0].Attack));
            estado_demo = DemoEstado.CIDADE;
            cidade_index = 0;
            message = demo_cidade_nome(cidade_index);
        } },
        { Nome: "diario: escolha de rota", Espera: 1.2, Foto: "34_diario_rotas", Acao: function() {
            saida_destino_index = 1;
            estado_demo = DemoEstado.SAIR_CIDADE;
            var _opcoes = demo_rota_saida_opcoes_get(id, 1);
            var _nomes = "";
            for (var _i = 0; _i < array_length(_opcoes); _i += 1) _nomes += _opcoes[_i].Nome + "; ";
            autoteste_log("diario rotas: " + _nomes);
        } },
        { Nome: "diario: encontro", Espera: 2.0, Foto: "35_diario_batalha", Acao: function() {
            var _opcoes = demo_rota_saida_opcoes_get(id, 1);
            demo_rota_escolher(id, demo_rota_block_index(0, 1), _opcoes[0]);
            demo_rota_iniciar(1, _opcoes[0]);
            autoteste_log("diario passos da rota: " + string(route_steps_needed) + " treinador no passo " + string(route_trainer_step));
            route_steps += 1;
            demo_rota_encontro_selvagem_iniciar(id);
            autoteste_log("diario selvagem: " + enemy_criatura_data.Nome + " nv " + string(enemy_criatura_data.Level) + " hp " + string(enemy_criatura_data.HpMax));
        } },
        { Nome: "diario: game over", Espera: 1.5, Foto: "36_diario_game_over", Acao: function() {
            demo_cleanup_battle(id);
            estado_demo = DemoEstado.GAME_OVER;
            game_over_timer = 0;
            diario_finalizar(id);
            autoteste_log("diario pontos: " + string(global.diario.Resultado.Pontos));
        } },
        { Nome: "missao: cidade", Espera: 1.5, Foto: "37_missao_cidade", Acao: function() {
            demo_run_resetar(id, DemoEstado.ROTA);
            var _p = demo_criar_criatura_data(conteudo_pacote_iniciais("base")[0], 12, true);
            _p.Capturado = true;
            player_party = [_p];
            player_criatura_data = _p;
            dinheiro = 100;
            cidade_index = 1;
            message = demo_cidade_nome(1);
            estado_demo = DemoEstado.CIDADE;
            autoteste_log("missao sorteada em " + demo_cidade_nome(1) + ": " + missao_da_cidade(id, 1).Id + " | marcador com novidade: " + string(missao_tem_novidade(id, 1)));
        } },
        { Nome: "missao: aceitar", Espera: 1.5, Foto: "38_missao_dialogo", Acao: function() {
            var _markers = demo_city_markers(id);

            for (var _i = 0; _i < array_length(_markers); _i += 1) {
                if (_markers[_i].Action == "event") {
                    demo_city_marker_ativar(id, _markers[_i]);
                    break;
                }
            }

            autoteste_log("estado da missao: " + missao_da_cidade(id, 1).Estado + " | " + message);
        } },
        { Nome: "missao: lista na cidade", Espera: 1.2, Foto: "39_missao_lista", Acao: function() {
            estado_demo = DemoEstado.CIDADE;
            message = demo_cidade_nome(cidade_index);
        } },
        { Nome: "missao: concluir", Espera: 1.5, Foto: "40_missao_concluida", Acao: function() {
            var _m = missao_da_cidade(id, 1);
            var _def = missao_def(_m.Id);
            var _antes = dinheiro;
            var _qtd = conteudo_struct_get(_def, "quantidade", 1);
            var _alvo = conteudo_tipo_de_texto(conteudo_struct_get(_def, "alvo", ""));
            var _modelo = undefined;
            var _ids = criatura_ids();

            for (var _i = 0; _i < array_length(_ids); _i += 1) {
                var _info = criatura_info(_ids[_i]);
                if (_alvo == CriaturaTipo.NONE || _info.Tipo1 == _alvo || _info.Tipo2 == _alvo) { _modelo = demo_criar_criatura_data(_ids[_i], 5, false); break; }
            }

            for (var _n = 0; _n < _qtd + 1; _n += 1) {
                switch (_def.tipo) {
                    case "capturar_tipo": case "capturar_qualquer": missao_evento(id, "captura", _modelo); break;
                    case "vencer_tipo": missao_evento(id, "vitoria", _modelo); break;
                    case "vencer_treinadores": missao_evento(id, "treinador", undefined); break;
                    case "entregar": demo_cidade_chegar(_m.Destino); break;
                }
            }

            autoteste_log("missao " + _m.Id + " -> " + _m.Estado + " | dinheiro " + string(_antes) + " -> " + string(dinheiro));
            autoteste_log(_m.Estado == "concluida" ? "MISSAO OK" : "MISSAO NAO CONCLUIU");
            estado_demo = DemoEstado.CIDADE;
        } },
        { Nome: "combate: sinergia", Espera: 0.45, Foto: "41_combate_sinergia", Acao: function() {
            demo_run_resetar(id, DemoEstado.ROTA);
            var _p = demo_criar_criatura_data(criatura_id_por_nome("Larvinha"), 14, true);
            _p.Capturado = true;
            player_party = [_p];
            player_criatura_data = _p;
            enemy_criatura_data = demo_criar_criatura_data(criatura_id_por_nome("Folhoca"), 10, true, false, false, "selvagem");
            battle_context = "rota";
            demo_start_battle(id);
            battle_time_scale_set(0, false);
            var _hab = player_inst.habilidades_equipadas;
            if (!is_struct(_hab[1])) { _hab[1] = variable_clone(_hab[0]); _hab[1].ID = "teste_veneno"; }
            _hab[0].TipoElementar = CriaturaTipo.BUG;
            _hab[1].TipoElementar = CriaturaTipo.POISON;
            var _n = sinergia_aplicar(player_inst, enemy_inst, _hab[0]);
            battle_combo_push(enemy_inst.x, enemy_inst.y - 132, "SINERGIA!", make_color_rgb(120, 230, 255));
            autoteste_log("sinergias aplicadas: " + string(_n) + " | alvo envenenado: " + string(criatura_status_tem(enemy_inst, "Envenenado")) + " | texto: " + sinergia_texto(_hab, _hab[0]));
        } },
        { Nome: "combate: captura", Espera: 2.5, Foto: "42_combate_vfx", Acao: function() {
            var _bola = demo_item_get("pokebola");
            var _ultra = demo_item_get("ultra_ball");
            enemy_inst.hp_atual = enemy_inst.hp_max;
            var _cheio = demo_capture_chance(id, _bola, enemy_criatura_data);
            enemy_inst.hp_atual = max(1, enemy_inst.hp_max * 0.1);
            var _baixo = demo_capture_chance(id, _bola, enemy_criatura_data);
            var _ultra_baixo = demo_capture_chance(id, _ultra, enemy_criatura_data);
            autoteste_log("captura comum: capsula HP cheio " + string_format(_cheio * 100, 1, 1) + "% | capsula 10% HP " + string_format(_baixo * 100, 1, 1) + "% | avancada 10% HP " + string_format(_ultra_baixo * 100, 1, 1) + "% | mestra " + string(demo_capture_chance(id, demo_item_get("master_ball"), enemy_criatura_data) * 100) + "%");
            enemy_inst.hp_atual = enemy_inst.hp_max;
            battle_time_scale_set(2.0, false);
        } },
        { Nome: "rejog: menu hardcore", Espera: 1.2, Foto: "43_menu_hardcore", Acao: function() {
            demo_run_resetar(id, DemoEstado.MENU);
            progresso().Dificuldade = Dificuldade.HARDCORE;
            autoteste_log("hardcore: nivel +" + string(dificuldade_param("Nivel")) + " dano x" + string(dificuldade_param("Dano")) + " captura x" + string(dificuldade_param("Captura")) + " | nivel 10 vira " + string(dificuldade_nivel(10)));
        } },
        { Nome: "rejog: rota cega", Espera: 1.2, Foto: "44_rota_cega", Acao: function() {
            demo_run_resetar(id, DemoEstado.ROTA);
            var _p = demo_criar_criatura_data(conteudo_pacote_iniciais("base")[0], 8, true);
            player_party = [_p];
            player_criatura_data = _p;
            cidade_index = 0;
            saida_destino_index = 1;
            estado_demo = DemoEstado.SAIR_CIDADE;
            var _rotas = demo_rota_saida_opcoes_get(id, 1);
            autoteste_log("biomas no hardcore: " + demo_rota_biomas_texto(_rotas[0]));
        } },
        { Nome: "rejog: conquistas", Espera: 1.2, Foto: "45_conquistas", Acao: function() {
            progresso().Dificuldade = Dificuldade.NORMAL;
            conquista_evento("captura", player_party[0]);
            autoteste_log("conquistas: " + string(conquistas_total_desbloqueadas()) + "/" + string(array_length(conquistas_lista())) + " | buraco negro liberado: " + string(progresso().BuracoNegroLiberado));
            estado_demo = DemoEstado.CONQUISTAS;
        } },
        { Nome: "rejog: buraco negro onda 1", Espera: 2.0, Foto: "46_buraco_onda1", Acao: function() {
            demo_run_resetar(id, DemoEstado.ROTA);
            var _a = demo_criar_criatura_data(criatura_id_por_nome("Infernhal"), 30, true);
            var _b = demo_criar_criatura_data(criatura_id_por_nome("Abissauro"), 30, true);
            player_party = [_a, _b];
            player_criatura_data = _a;
            player_party_active_index = 0;
            buraco_negro_iniciar(id);
            autoteste_log("onda " + string(global.buraco_negro.Onda) + " | inimigos " + string(array_length(trainer_party)));
        } },
        { Nome: "rejog: buraco negro vencer onda", Espera: 1.2, Foto: "", Acao: function() {
            if (instance_exists(enemy_inst)) enemy_inst.vivo = false;
        } },
        { Nome: "rejog: buraco negro onda 2", Espera: 2.0, Foto: "47_buraco_onda2", Acao: function() {
            autoteste_log("estado apos vencer onda 1: " + string(estado_demo) + " | " + message);
            demo_cleanup_battle(id);
            buraco_negro_proxima_onda(id);
            autoteste_log("onda " + string(global.buraco_negro.Onda) + " | inimigos " + string(array_length(trainer_party)) + " | hp do 1o inimigo " + string(trainer_party[0].HpMax));
        } },
        { Nome: "rejog: buraco negro derrota", Espera: 1.5, Foto: "48_buraco_game_over", Acao: function() {
            demo_cleanup_battle(id);
            buraco_negro_finalizar();
            estado_demo = DemoEstado.GAME_OVER;
            game_over_timer = 0;
            autoteste_log("buraco negro: " + string(global.buraco_negro.Resultado.Ondas) + " ondas | recorde " + string(progresso().BuracoNegroRecorde));
        } },
        { Nome: "rejog: item de batalha", Espera: 1.5, Foto: "49_item_buff", Acao: function() {
            demo_run_resetar(id, DemoEstado.ROTA);
            var _p = demo_criar_criatura_data(conteudo_pacote_iniciais("base")[1], 12, true);
            player_party = [_p];
            player_criatura_data = _p;
            enemy_criatura_data = demo_criar_criatura_data(criatura_id_por_nome("Rataco"), 8, true, false, false, "selvagem");
            battle_context = "rota";
            demo_start_battle(id);
            demo_inventario_adicionar(inventario, "po_ataque", 1);
            demo_item_usar(id, "po_ataque", true);
            autoteste_log("po de furia: impeto ofensivo = " + string(criatura_status_tem(player_inst, "ImpetoOfensivo")) + " | restam " + string(demo_inventario_quantidade(inventario, "po_ataque")));
        } },
        { Nome: "audio: menu", Espera: 6.0, Foto: "50_menu_som", Acao: function() {
            demo_run_resetar(id, DemoEstado.MENU);
            autoteste_log("audio antes: " + string(variable_struct_get_names(audio_garantir().Sons)) + " | fps " + string(fps_real));
        } },
        { Nome: "audio: resultado", Espera: 0.2, Foto: "", Acao: function() {
            var _a = audio_garantir();
            autoteste_log("audio depois: " + string(variable_struct_get_names(_a.Sons)) + " | tocando: " + _a.MusicaAtual + " | job pendente: " + string(is_struct(_a.Job)) + " | fps " + string(fps_real));
        } },
        { Nome: "idioma: menu em ingles", Espera: 1.2, Foto: "51_menu_en", Acao: function() {
            if (idioma_atual() == "pt") idioma_alternar();
            demo_run_resetar(id, DemoEstado.MENU);
            autoteste_log("idioma: " + idioma_atual() + " | exemplo: " + i18n_t("Voce chegou a Pedralia.") + " | " + i18n_t("COMECAR RUN"));
        } },
        { Nome: "idioma: escolha em ingles", Espera: 1.2, Foto: "52_escolha_en", Acao: function() {
            estado_demo = DemoEstado.ESCOLHA_INICIAL;
        } },
        { Nome: "idioma: cidade em ingles", Espera: 1.2, Foto: "53_cidade_en", Acao: function() {
            starter_id = starter_ids[0];
            estado_demo = DemoEstado.CIDADE;
            cidade_index = 2;
            message = "Voce chegou a " + demo_cidade_nome(2) + ".";
        } },
        { Nome: "idioma: batalha em ingles", Espera: 2.5, Foto: "54_batalha_en", Acao: function() {
            enemy_criatura_data = demo_criar_criatura_data(criatura_id_por_nome("Rataco"), 6, true, false, false, "selvagem");
            battle_context = "rota";
            demo_start_battle(id);
        } },
        { Nome: "idioma: volta ao portugues", Espera: 0.2, Foto: "", Acao: function() {
            if (idioma_atual() == "en") idioma_alternar();
            autoteste_log("idioma restaurado: " + idioma_atual());
        } }
    ];
}

function autoteste_step() {
    if (!autoteste_ativo() || global.autoteste.Fim) {
        return;
    }

    var _t = global.autoteste;
    var _dt = delta_time / 1000000;
    var _jogo = autoteste_jogo();

    if (!instance_exists(_jogo)) {
        return;
    }

    if (_t.AguardandoFoto) {
        return;
    }

    // Draft de habilidade aparece ao subir de nivel: fotografa o primeiro e escolhe a opcao 1.
    if (variable_global_exists("estado_jogo") && global.estado_jogo == EstadoJogo.DRAFT_HABILIDADE && is_struct(global.draft_habilidade_atual)) {
        _t.Timer += _dt;

        if (_t.Timer > 1.0) {
            if (_t.DraftsVistos == 0) {
                _t.DraftsVistos += 1;
                autoteste_log("draft de habilidade aberto");
                autoteste_foto("draft_habilidade");
                _t.Timer = 0.5;
                return;
            }

            criatura_draft_escolher(global.draft_habilidade_atual, 0, -1);

            if (instance_exists(_jogo.player_inst)) {
                criatura_batalha_sincronizar_habilidades(_jogo.player_inst);
            }

            _t.Timer = 0;
        }

        return;
    }

    var _passos = autoteste_passos();

    if (_t.Passo < 0) {
        _t.Passo = 0;
        _t.Executado = false;
    }

    if (_t.Passo >= array_length(_passos)) {
        autoteste_log("fim: todos os passos concluidos sem erro");
        autoteste_log_salvar();
        _t.Fim = true;
        game_end();
        return;
    }

    var _passo = _passos[_t.Passo];

    if (!_t.Executado) {
        autoteste_log("passo: " + _passo.Nome);
        var _acao = method(_jogo, _passo.Acao);
        _acao();
        _t.Executado = true;
        _t.Timer = 0;
        return;
    }

    _t.Timer += _dt;
    var _aguardar = variable_struct_exists(_passo, "AguardarBatalha") && _passo.AguardarBatalha;

    if (_aguardar && _jogo.estado_demo == DemoEstado.BATALHA && _t.Timer < 60) {
        return;
    }

    if (_t.Timer < _passo.Espera) {
        return;
    }

    if (_passo.Foto != "") {
        autoteste_log("foto " + _passo.Foto + " | fps_real " + string(round(fps_real)) + " | estado " + string(_jogo.estado_demo) + " | " + string_copy(string(_jogo.message), 1, 60));
        autoteste_foto(_passo.Foto);
    }
    _t.Passo += 1;
    _t.Executado = false;
}

function autoteste_draw_gui_end() {
    if (!autoteste_ativo() || global.autoteste.Capturar == "") {
        return;
    }

    screen_save(global.autoteste.Dir + global.autoteste.Capturar + ".png");
    global.autoteste.Capturar = "";
    global.autoteste.AguardandoFoto = false;
}
