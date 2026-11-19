// Desafio Diario
// Todo dia (data em UTC) existe uma run com a mesma semente para todo mundo:
// - inicial do dia: criatura em estagio inicial, de raridade comum, incomum ou rara;
// - a semente fixa drafts de rota, encontros, treinadores, drops, lideres e drafts de habilidade;
// - o combate em tempo real e as capturas continuam aleatorios (dependem do jogador);
// - sem bonus da loja permanente;
// - uma tentativa oficial por dia (vale pontos e fragmentos); depois disso, so treino.
// Para testar outra data: variavel de ambiente RASGO_DIARIO_DATA=AAAAMMDD.

function diario_save_path() {
    return (autoteste_ativo() ? "autoteste_" : "") + "desafio_diario.json";
}

function diario_ativo() {
    return variable_global_exists("diario") && is_struct(global.diario) && global.diario.Ativo;
}

function diario_pad2(_n) {
    return (_n < 10 ? "0" : "") + string(_n);
}

function diario_chave_data(_ano, _mes, _dia) {
    return string(_ano) + diario_pad2(_mes) + diario_pad2(_dia);
}

function diario_chave_hoje() {
    var _forcada = environment_get_variable("RASGO_DIARIO_DATA");

    if (string_length(_forcada) == 8 && string_digits(_forcada) == _forcada) {
        return _forcada;
    }

    var _tz = date_get_timezone();
    date_set_timezone(timezone_utc);
    var _agora = date_current_datetime();
    var _chave = diario_chave_data(date_get_year(_agora), date_get_month(_agora), date_get_day(_agora));
    date_set_timezone(_tz);
    return _chave;
}

function diario_chave_deslocar(_chave, _dias) {
    var _ano = real(string_copy(_chave, 1, 4));
    var _mes = real(string_copy(_chave, 5, 2));
    var _dia = real(string_copy(_chave, 7, 2));
    var _data = date_inc_day(date_create_datetime(_ano, _mes, _dia, 12, 0, 0), _dias);
    return diario_chave_data(date_get_year(_data), date_get_month(_data), date_get_day(_data));
}

function diario_chave_legivel(_chave) {
    return string_copy(_chave, 7, 2) + "/" + string_copy(_chave, 5, 2) + "/" + string_copy(_chave, 1, 4);
}

// FNV-1a de 32 bits em int64 (deterministico, nao usa o RNG do jogo).
function diario_hash(_texto) {
    var _h = int64(2166136261);
    var _s = string(_texto);

    for (var _i = 1; _i <= string_length(_s); _i += 1) {
        _h = _h ^ int64(ord(string_char_at(_s, _i)));
        _h = (_h * int64(16777619)) & int64(4294967295);
    }

    return _h;
}

// Escopo deterministico: tudo que for sorteado entre diario_escopo() e diario_escopo_fim()
// sai igual para a mesma data e a mesma chave. Fora do modo diario nao faz nada.
function diario_escopo(_chave) {
    if (!diario_ativo()) {
        return false;
    }

    global.diario.Profundidade += 1;

    if (global.diario.Profundidade == 1) {
        random_set_seed(real(diario_hash(global.diario.Chave + "|" + string(_chave))));
    }

    return true;
}

function diario_escopo_fim(_iniciado) {
    if (!_iniciado || !diario_ativo()) {
        return;
    }

    global.diario.Profundidade = max(0, global.diario.Profundidade - 1);

    if (global.diario.Profundidade == 0) {
        randomize();
    }
}

function diario_pool_iniciais() {
    var _ids = criatura_ids();
    var _pool = [];

    for (var _i = 0; _i < array_length(_ids); _i += 1) {
        var _info = criatura_info(_ids[_i]);

        if (is_struct(_info) && _info.EvoluiDe <= 0 && _info.Raridade <= PokemonRaridade.RARE) {
            array_push(_pool, _ids[_i]);
        }
    }

    return _pool;
}

function diario_inicial_do_dia(_chave) {
    var _pool = diario_pool_iniciais();

    if (array_length(_pool) <= 0) {
        return conteudo_pacote_iniciais("base")[0];
    }

    return _pool[real(diario_hash(_chave + "|inicial")) mod array_length(_pool)];
}

// ------------------------------------------------------------------ save

function diario_save_padrao() {
    return { Historico: {}, Sequencia: 0, UltimoDia: "", MelhorPontos: 0, MelhorDia: "" };
}

function diario_save_carregar() {
    var _save = diario_save_padrao();

    if (!file_exists(diario_save_path())) {
        return _save;
    }

    var _file = file_text_open_read(diario_save_path());
    var _texto = "";

    while (!file_text_eof(_file)) {
        _texto += file_text_readln(_file);
    }

    file_text_close(_file);

    try {
        var _lido = json_parse(_texto);

        if (is_struct(_lido)) {
            var _chaves = variable_struct_get_names(_save);

            for (var _i = 0; _i < array_length(_chaves); _i += 1) {
                if (variable_struct_exists(_lido, _chaves[_i])) {
                    variable_struct_set(_save, _chaves[_i], variable_struct_get(_lido, _chaves[_i]));
                }
            }
        }
    } catch (_erro) {
        show_debug_message("[diario] save invalido, recomecando: " + string(_erro));
    }

    if (!is_struct(_save.Historico)) {
        _save.Historico = {};
    }

    return _save;
}

function diario_save_gravar(_save) {
    var _file = file_text_open_write(diario_save_path());
    file_text_write_string(_file, json_stringify(_save));
    file_text_close(_file);
}

function diario_registro_do_dia(_save, _chave) {
    if (is_struct(_save) && variable_struct_exists(_save.Historico, _chave)) {
        return variable_struct_get(_save.Historico, _chave);
    }

    return undefined;
}

// Resumo de hoje para o menu (cacheado por data).
function diario_info_hoje() {
    var _chave = diario_chave_hoje();

    if (!variable_global_exists("diario_info_cache") || !is_struct(global.diario_info_cache) || global.diario_info_cache.Chave != _chave || global.diario_info_cache.Sujo) {
        var _save = diario_save_carregar();
        var _registro = diario_registro_do_dia(_save, _chave);
        var _inicial = diario_inicial_do_dia(_chave);
        global.diario_info_cache = {
            Chave: _chave,
            Sujo: false,
            InicialID: _inicial,
            InicialNome: demo_pokemon_nome(_inicial),
            OficialUsada: is_struct(_registro),
            Pontos: is_struct(_registro) ? _registro.Pontos : 0,
            Sequencia: _save.Sequencia,
            UltimoDia: _save.UltimoDia,
            MelhorPontos: _save.MelhorPontos
        };
    }

    return global.diario_info_cache;
}

// ------------------------------------------------------------------ fluxo da run

function diario_iniciar(_controller) {
    if (!instance_exists(_controller)) {
        return;
    }

    var _chave = diario_chave_hoje();
    var _save = diario_save_carregar();
    var _oficial = !is_struct(diario_registro_do_dia(_save, _chave));
    var _inicial = diario_inicial_do_dia(_chave);

    // Reseta a run normal primeiro (isso tambem encerra qualquer diario anterior).
    demo_run_resetar(_controller, DemoEstado.ESCOLHA_INICIAL);

    global.diario = {
        Ativo: true,
        Chave: _chave,
        Oficial: _oficial,
        InicialID: _inicial,
        Vitorias: 0,
        Capturas: 0,
        ChefeDerrotado: false,
        Profundidade: 0,
        Resultado: undefined
    };

    if (_oficial) {
        // A tentativa oficial conta a partir de agora: fechar o jogo no meio nao devolve a tentativa.
        variable_struct_set(_save.Historico, _chave, { Oficial: true, Finalizado: false, Pontos: 0, Insignias: 0, Inicial: _inicial });
        diario_save_gravar(_save);
    }

    if (variable_global_exists("diario_info_cache") && is_struct(global.diario_info_cache)) {
        global.diario_info_cache.Sujo = true;
    }

    // Todo mundo joga nas mesmas condicoes: sem bonus da loja permanente.
    demo_meta_sincronizar_globals(demo_meta_default());

    with (_controller) {
        meta_inicio_aplicado = true;
        starter_ids = [_inicial, _inicial, _inicial];
        starter_id = _inicial;
        message = "Desafio Diario " + diario_chave_legivel(_chave) + (_oficial ? " (tentativa oficial)" : " (treino)");
    }
}

function diario_encerrar() {
    if (variable_global_exists("diario") && is_struct(global.diario)) {
        global.diario.Ativo = false;
    }

    global.diario = undefined;
}

function diario_registrar_vitoria() {
    if (diario_ativo()) {
        global.diario.Vitorias += 1;
    }
}

function diario_registrar_captura() {
    if (diario_ativo()) {
        global.diario.Capturas += 1;
    }
}

function diario_insignias(_controller) {
    var _total = 0;

    if (instance_exists(_controller) && is_array(_controller.ginasios_vencidos)) {
        for (var _i = 0; _i < array_length(_controller.ginasios_vencidos); _i += 1) {
            if (_controller.ginasios_vencidos[_i]) {
                _total += 1;
            }
        }
    }

    return _total;
}

function diario_pontuacao(_controller) {
    var _niveis = 0;

    if (instance_exists(_controller) && is_array(_controller.player_party)) {
        for (var _i = 0; _i < array_length(_controller.player_party); _i += 1) {
            var _membro = _controller.player_party[_i];

            if (is_struct(_membro) && variable_struct_exists(_membro, "Level")) {
                _niveis += _membro.Level;
            }
        }
    }

    var _bonus_chefe = global.diario.ChefeDerrotado ? 5000 : 0;
    return (diario_insignias(_controller) * 1000) + (global.diario.Vitorias * 40) + (global.diario.Capturas * 60) + (_niveis * 10) + _bonus_chefe;
}

// Chamado quando a run termina. Pode ser chamado mais de uma vez: so calcula na primeira.
function diario_finalizar(_controller) {
    if (!diario_ativo() || is_struct(global.diario.Resultado)) {
        return;
    }

    var _pontos = diario_pontuacao(_controller);
    var _save = diario_save_carregar();
    var _chave = global.diario.Chave;

    if (global.diario.Oficial) {
        variable_struct_set(_save.Historico, _chave, {
            Oficial: true,
            Finalizado: true,
            Pontos: _pontos,
            Insignias: diario_insignias(_controller),
            Inicial: global.diario.InicialID
        });

        if (_save.UltimoDia == diario_chave_deslocar(_chave, -1)) {
            _save.Sequencia += 1;
        } else if (_save.UltimoDia != _chave) {
            _save.Sequencia = 1;
        }

        _save.UltimoDia = _chave;
        conquista_evento("diario", _save.Sequencia);

        if (_pontos > _save.MelhorPontos) {
            _save.MelhorPontos = _pontos;
            _save.MelhorDia = _chave;
        }

        diario_save_gravar(_save);
    }

    global.diario.Resultado = {
        Pontos: _pontos,
        Insignias: diario_insignias(_controller),
        Vitorias: global.diario.Vitorias,
        Capturas: global.diario.Capturas,
        Oficial: global.diario.Oficial,
        Sequencia: _save.Sequencia,
        Melhor: _save.MelhorPontos
    };

    if (variable_global_exists("diario_info_cache") && is_struct(global.diario_info_cache)) {
        global.diario_info_cache.Sujo = true;
    }
}

// ------------------------------------------------------------------ interface

function demo_menu_daily_button_rect() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    return { X: (_gw * 0.5) + 10, Y: _gh - 166, W: 300, H: 58 };
}

function diario_draw_menu(_mx, _my) {
    var _rect = demo_menu_daily_button_rect();
    var _hover = demo_hover_rect(_mx, _my, _rect.X, _rect.Y, _rect.W, _rect.H);
    var _info = diario_info_hoje();

    demo_draw_title_button(_rect, _info.OficialUsada ? "DIARIO (TREINO)" : "DESAFIO DIARIO", _hover);

    var _linha = "Hoje " + diario_chave_legivel(_info.Chave) + ": " + _info.InicialNome;

    if (_info.OficialUsada) {
        _linha += " | sua marca: " + string(_info.Pontos) + " pts";
    }

    if (_info.Sequencia > 0) {
        _linha += " | sequencia: " + string(_info.Sequencia);
    }

    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_text_transformed(_rect.X + (_rect.W * 0.5) + 1, _rect.Y - 21, _linha, 0.72, 0.72, 0);
    draw_set_color(make_color_rgb(255, 238, 150));
    draw_text_transformed(_rect.X + (_rect.W * 0.5), _rect.Y - 22, _linha, 0.72, 0.72, 0);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}

function diario_draw_hud() {
    if (!diario_ativo()) {
        return;
    }

    var _texto = "DESAFIO DIARIO " + diario_chave_legivel(global.diario.Chave) + (global.diario.Oficial ? "" : " - TREINO");
    var _gw = display_get_gui_width();
    var _w = string_width(_texto) * 0.62 + 24;

    draw_set_alpha(0.78);
    draw_set_color(make_color_rgb(24, 28, 46));
    draw_roundrect_ext((_gw - _w) * 0.5, -6, (_gw + _w) * 0.5, 15, 6, 6, false);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(255, 222, 120));
    draw_text_transformed(_gw * 0.5, 0, _texto, 0.62, 0.62, 0);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}

function diario_draw_resultado_game_over(_controller) {
    if (!diario_ativo()) {
        return;
    }

    diario_finalizar(_controller);
    var _r = global.diario.Resultado;

    if (!is_struct(_r)) {
        return;
    }

    var _gw = display_get_gui_width();
    var _w = 560;
    var _h = 92;
    var _x = (_gw - _w) * 0.5;
    var _y = 226;

    battle_ui_draw_nineslice_panel(_x, _y, _w, _h);
    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(255, 222, 120));
    draw_text_transformed(_gw * 0.5, _y + 14, "DESAFIO DIARIO " + diario_chave_legivel(global.diario.Chave) + (global.diario.ChefeDerrotado ? " - RASGO FECHADO!" : "") + (_r.Oficial ? "" : " (treino, nao conta)"), 0.82, 0.82, 0);
    draw_set_color(c_white);
    draw_text_transformed(_gw * 0.5, _y + 42, string(_r.Pontos) + " pontos  |  " + string(_r.Insignias) + " insignias  |  " + string(_r.Vitorias) + " vitorias  |  " + string(_r.Capturas) + " capturas", 0.72, 0.72, 0);
    draw_text_transformed(_gw * 0.5, _y + 64, "Melhor marca: " + string(_r.Melhor) + "   Sequencia de dias: " + string(_r.Sequencia), 0.68, 0.68, 0);
    draw_set_halign(fa_left);
}
