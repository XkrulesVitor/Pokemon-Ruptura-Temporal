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
            pokedex_garantir();
            var _ids = criatura_ids();

            // So marca em memoria (nao salva) para a foto mostrar entradas.
            for (var _i = 0; _i < min(24, array_length(_ids)); _i += 1) {
                var _entrada = variable_struct_get(global.pokedex_estado, string(_ids[_i]));

                if (is_struct(_entrada)) {
                    _entrada.Capturado = true;
                    _entrada.Descoberto = true;
                }
            }

            global.pokedex_overlay_aberto = true;
        } },
        { Nome: "mochila", Espera: 1.2, Foto: "10_mochila", Acao: function() {
            global.pokedex_overlay_aberto = false;
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
            enemy_pokemon_data = demo_criar_pokemon_data(_inimigo, _nivel, true, true, true, "selvagem");
            battle_context = "rota";
            route_steps += 1;
            demo_start_battle(id);
            autoteste_log("selvagem: " + enemy_pokemon_data.Nome + " nv " + string(_nivel));
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
            autoteste_log("lider: " + (is_struct(enemy_pokemon_data) ? enemy_pokemon_data.Nome : "?"));
        } },
        { Nome: "fim do lider", Espera: 1.0, Foto: "19_lider_resultado", AguardarBatalha: true, Acao: function() {} },
        { Nome: "game over", Espera: 1.5, Foto: "20_game_over", Acao: function() {
            demo_cleanup_battle(id);
            estado_demo = DemoEstado.GAME_OVER;
            game_over_timer = 0;
        } },
        { Nome: "menu com diario", Espera: 1.2, Foto: "21_menu_diario", Acao: function() {
            demo_run_resetar(id, DemoEstado.MENU);
        } },
        { Nome: "diario: inicio", Espera: 1.5, Foto: "22_diario_laboratorio", Acao: function() {
            diario_iniciar(id);
            autoteste_log("diario " + global.diario.Chave + " oficial=" + string(global.diario.Oficial) + " inicial=" + demo_pokemon_nome(global.diario.InicialID));
        } },
        { Nome: "diario: cidade", Espera: 1.2, Foto: "23_diario_cidade", Acao: function() {
            autoteste_log("diario equipe: " + player_party[0].Nome + " nv " + string(player_party[0].Level) + " hp " + string(player_party[0].HpMax) + " atk " + string(player_party[0].Attack));
            estado_demo = DemoEstado.CIDADE;
            cidade_index = 0;
            message = demo_cidade_nome(cidade_index);
        } },
        { Nome: "diario: escolha de rota", Espera: 1.2, Foto: "24_diario_rotas", Acao: function() {
            saida_destino_index = 1;
            estado_demo = DemoEstado.SAIR_CIDADE;
            var _opcoes = demo_rota_saida_opcoes_get(id, 1);
            var _nomes = "";
            for (var _i = 0; _i < array_length(_opcoes); _i += 1) _nomes += _opcoes[_i].Nome + "; ";
            autoteste_log("diario rotas: " + _nomes);
        } },
        { Nome: "diario: encontro", Espera: 2.0, Foto: "25_diario_batalha", Acao: function() {
            var _opcoes = demo_rota_saida_opcoes_get(id, 1);
            demo_rota_escolher(id, demo_rota_block_index(0, 1), _opcoes[0]);
            demo_rota_iniciar(1, _opcoes[0]);
            autoteste_log("diario passos da rota: " + string(route_steps_needed) + " treinador no passo " + string(route_trainer_step));
            route_steps += 1;
            demo_rota_encontro_selvagem_iniciar(id);
            autoteste_log("diario selvagem: " + enemy_pokemon_data.Nome + " nv " + string(enemy_pokemon_data.Level) + " hp " + string(enemy_pokemon_data.HpMax));
        } },
        { Nome: "diario: game over", Espera: 1.5, Foto: "26_diario_game_over", Acao: function() {
            demo_cleanup_battle(id);
            estado_demo = DemoEstado.GAME_OVER;
            game_over_timer = 0;
            diario_finalizar(id);
            autoteste_log("diario pontos: " + string(global.diario.Resultado.Pontos));
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

            pokemon_draft_escolher(global.draft_habilidade_atual, 0, -1);

            if (instance_exists(_jogo.player_inst)) {
                pokemon_batalha_sincronizar_habilidades(_jogo.player_inst);
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

    autoteste_log("foto " + _passo.Foto + " | estado " + string(_jogo.estado_demo) + " | " + string(_jogo.message));
    autoteste_foto(_passo.Foto);
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
