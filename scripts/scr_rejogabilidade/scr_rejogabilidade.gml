// Rejogabilidade (Sprint 7): dificuldade, conquistas, visuais do jogador e modo Buraco Negro.
// O progresso permanente fica em progresso.json (dificuldade escolhida, conquistas, contadores,
// visual atual e recorde do Buraco Negro).

enum Dificuldade {
    FACIL,
    NORMAL,
    DIFICIL,
    HARDCORE
}

// ------------------------------------------------------------------ progresso permanente

function progresso_path() {
    return (autoteste_ativo() ? "autoteste_" : "") + "progresso.json";
}

function progresso_padrao() {
    return {
        Dificuldade: Dificuldade.NORMAL,
        Conquistas: {},
        Contadores: { sinergias: 0, combos: 0 },
        Skin: "padrao",
        BuracoNegroLiberado: false,
        BuracoNegroRecorde: 0,
        SomModo: 0,
        Idioma: "pt"
    };
}

function progresso() {
    if (variable_global_exists("progresso_dados") && is_struct(global.progresso_dados)) {
        return global.progresso_dados;
    }

    var _dados = progresso_padrao();

    if (file_exists(progresso_path())) {
        var _file = file_text_open_read(progresso_path());
        var _texto = "";

        while (!file_text_eof(_file)) {
            _texto += file_text_readln(_file);
        }

        file_text_close(_file);

        try {
            var _lido = json_parse(_texto);
            var _chaves = variable_struct_get_names(_dados);

            for (var _i = 0; _i < array_length(_chaves); _i += 1) {
                if (is_struct(_lido) && variable_struct_exists(_lido, _chaves[_i])) {
                    variable_struct_set(_dados, _chaves[_i], variable_struct_get(_lido, _chaves[_i]));
                }
            }
        } catch (_erro) {
            show_debug_message("[progresso] arquivo invalido: " + string(_erro));
        }
    }

    if (!is_struct(_dados.Conquistas)) _dados.Conquistas = {};
    if (!is_struct(_dados.Contadores)) _dados.Contadores = { sinergias: 0, combos: 0 };
    global.progresso_dados = _dados;
    return _dados;
}

function progresso_salvar() {
    var _file = file_text_open_write(progresso_path());
    file_text_write_string(_file, json_stringify(progresso()));
    file_text_close(_file);
}

// ------------------------------------------------------------------ dificuldade

function dificuldade_nome(_d) {
    static _nomes = ["FACIL", "NORMAL", "DIFICIL", "HARDCORE"];
    return _nomes[clamp(_d, 0, 3)];
}

// O Desafio Diario sempre roda no Normal, para todo mundo jogar igual.
function dificuldade_atual() {
    if (diario_ativo()) {
        return Dificuldade.NORMAL;
    }

    return clamp(progresso().Dificuldade, 0, 3);
}

function dificuldade_params(_d) {
    switch (_d) {
        case Dificuldade.FACIL:
            return { Nivel: -2, Dano: 0.85, Dinheiro: 1.0, Captura: 1.15, Fragmentos: 1.0, RotasCegas: false, IaItens: false,
                     Descricao: "Inimigos 2 niveis abaixo, dano inimigo -15%, captura +15%." };
        case Dificuldade.DIFICIL:
            return { Nivel: 2, Dano: 1.15, Dinheiro: 1.2, Captura: 0.9, Fragmentos: 1.5, RotasCegas: false, IaItens: false,
                     Descricao: "Inimigos 2 niveis acima, dano inimigo +15%, +20% dinheiro, +50% fragmentos." };
        case Dificuldade.HARDCORE:
            return { Nivel: 3, Dano: 1.35, Dinheiro: 1.4, Captura: 0.6, Fragmentos: 2.0, RotasCegas: true, IaItens: true,
                     Descricao: "Rotas sem tipos visiveis, captura -40%, dano inimigo +35%, treinadores usam itens, fragmentos x2." };
    }

    return { Nivel: 0, Dano: 1.0, Dinheiro: 1.0, Captura: 1.0, Fragmentos: 1.0, RotasCegas: false, IaItens: false,
             Descricao: "A experiencia padrao." };
}

function dificuldade_param(_chave) {
    return variable_struct_get(dificuldade_params(dificuldade_atual()), _chave);
}

function dificuldade_nivel(_nivel) {
    return clamp(_nivel + dificuldade_param("Nivel"), 1, 30);
}

function dificuldade_alternar() {
    var _p = progresso();
    _p.Dificuldade = (_p.Dificuldade + 1) mod 4;
    progresso_salvar();
}

// Hardcore: inimigos de treinador/lider/chefe usam uma cura forte uma vez por batalha.
function dificuldade_ia_itens(_inst) {
    if (!dificuldade_param("IaItens") || _inst.lado_batalha != LadoBatalha.INIMIGO) {
        return;
    }

    if (variable_instance_exists(_inst, "ia_item_usado") && _inst.ia_item_usado) {
        return;
    }

    if (_inst.hp_atual > _inst.hp_max * 0.3) {
        return;
    }

    var _jogo = instance_number(obj_demo_game) > 0 ? instance_find(obj_demo_game, 0) : noone;

    if (!instance_exists(_jogo) || _jogo.battle_context == "rota") {
        return;
    }

    _inst.ia_item_usado = true;
    _inst.hp_atual = min(_inst.hp_max, _inst.hp_atual + (_inst.hp_max * 0.4));
    _inst.status_map = {};
    battle_log_push(string_upper(_inst.criatura_nome) + " recebeu uma POCAO MAXIMA e limpou os status!");
    battle_float_text_push(_inst.x - 24, _inst.y - 84, "+CURA", make_color_rgb(120, 255, 140));
}

// ------------------------------------------------------------------ conquistas

function conquistas_lista() {
    static _lista = [
        { Id: "primeira_captura", Nome: "Primeiro Laco", Descricao: "Capture seu primeiro monstro.", Skin: "" },
        { Id: "colecionador", Nome: "Colecionador", Descricao: "Tenha 25 monstros capturados no Bestiario.", Skin: "" },
        { Id: "bestiario_completo", Nome: "Enciclopedia Viva", Descricao: "Capture todos os monstros do Bestiario.", Skin: "" },
        { Id: "primeiro_lider", Nome: "Primeira Insignia", Descricao: "Venca um lider de ginasio.", Skin: "rubi" },
        { Id: "rasgo_fechado", Nome: "Rasgo Fechado", Descricao: "Venca Aeonox.", Skin: "esmeralda" },
        { Id: "solitario", Nome: "Lobo Solitario", Descricao: "Venca Aeonox com apenas 1 monstro na equipe.", Skin: "" },
        { Id: "dificil", Nome: "Caminho Dificil", Descricao: "Venca Aeonox no Dificil ou no Hardcore.", Skin: "" },
        { Id: "hardcore", Nome: "Sem Misericordia", Descricao: "Venca Aeonox no Hardcore.", Skin: "obsidiana" },
        { Id: "sinergista", Nome: "Sinergista", Descricao: "Ative 25 sinergias cruzadas.", Skin: "" },
        { Id: "combo_mestre", Nome: "Mestre dos Combos", Descricao: "Faca 50 COMBOS ou DANOS SINERGICOS.", Skin: "" },
        { Id: "lendario", Nome: "Lenda Capturada", Descricao: "Capture um monstro lendario.", Skin: "" },
        { Id: "cromatico", Nome: "Brilho Raro", Descricao: "Capture uma variante cromatica.", Skin: "" },
        { Id: "diario_7", Nome: "Semana no Rasgo", Descricao: "Complete 7 Desafios Diarios seguidos.", Skin: "safira" },
        { Id: "buraco_10", Nome: "Horizonte de Eventos", Descricao: "Chegue a onda 10 do Buraco Negro.", Skin: "cometa" }
    ];
    return _lista;
}

function conquista_tem(_id) {
    return variable_struct_exists(progresso().Conquistas, _id);
}

function conquistas_total_desbloqueadas() {
    return array_length(variable_struct_get_names(progresso().Conquistas));
}

function conquista_desbloquear(_id) {
    if (conquista_tem(_id)) {
        return false;
    }

    var _lista = conquistas_lista();

    for (var _i = 0; _i < array_length(_lista); _i += 1) {
        if (_lista[_i].Id == _id) {
            variable_struct_set(progresso().Conquistas, _id, date_datetime_string(date_current_datetime()));
            progresso_salvar();

            if (!variable_global_exists("conquista_avisos") || !is_array(global.conquista_avisos)) {
                global.conquista_avisos = [];
            }

            array_push(global.conquista_avisos, { Texto: _lista[_i].Nome, Skin: _lista[_i].Skin, Timer: 4.0 });
            audio_sfx("conquista");
            return true;
        }
    }

    return false;
}

function conquista_contador(_chave, _qtd) {
    var _c = progresso().Contadores;
    variable_struct_set(_c, _chave, conteudo_struct_get(_c, _chave, 0) + _qtd);

    if (_chave == "sinergias" && _c.sinergias >= 25) conquista_desbloquear("sinergista");
    if (_chave == "combos" && _c.combos >= 50) conquista_desbloquear("combo_mestre");
}

function conquistas_bestiario_capturados() {
    if (!variable_global_exists("bestiario_estado") || !is_struct(global.bestiario_estado)) {
        return 0;
    }

    var _total = 0;
    var _ids = variable_struct_get_names(global.bestiario_estado);

    for (var _i = 0; _i < array_length(_ids); _i += 1) {
        if (variable_struct_get(global.bestiario_estado, _ids[_i]).Capturado) {
            _total += 1;
        }
    }

    return _total;
}

// Eventos: "captura" (_dado = criatura), "lider", "chefe" (_dado = controller), "diario" (_dado = sequencia), "onda" (_dado = numero).
function conquista_evento(_evento, _dado) {
    switch (_evento) {
        case "captura":
            conquista_desbloquear("primeira_captura");

            if (is_struct(_dado)) {
                if (variable_struct_exists(_dado, "RaridadePadrao") && _dado.RaridadePadrao >= CriaturaRaridade.LEGENDARY) conquista_desbloquear("lendario");
                if (variable_struct_exists(_dado, "IsShiny") && _dado.IsShiny) conquista_desbloquear("cromatico");
            }

            var _capturados = conquistas_bestiario_capturados();
            if (_capturados >= 25) conquista_desbloquear("colecionador");
            if (_capturados >= array_length(criatura_ids())) conquista_desbloquear("bestiario_completo");
            break;

        case "lider":
            conquista_desbloquear("primeiro_lider");
            break;

        case "chefe":
            conquista_desbloquear("rasgo_fechado");

            if (instance_exists(_dado) && array_length(_dado.player_party) == 1) conquista_desbloquear("solitario");
            if (dificuldade_atual() >= Dificuldade.DIFICIL) conquista_desbloquear("dificil");
            if (dificuldade_atual() == Dificuldade.HARDCORE) conquista_desbloquear("hardcore");

            var _p = progresso();
            if (!_p.BuracoNegroLiberado) {
                _p.BuracoNegroLiberado = true;
                progresso_salvar();
            }
            break;

        case "diario":
            if (_dado >= 7) conquista_desbloquear("diario_7");
            break;

        case "onda":
            if (_dado >= 10) conquista_desbloquear("buraco_10");
            break;
    }
}

function conquista_avisos_draw() {
    if (!variable_global_exists("conquista_avisos") || !is_array(global.conquista_avisos) || array_length(global.conquista_avisos) <= 0) {
        return;
    }

    var _aviso = global.conquista_avisos[0];
    _aviso.Timer -= delta_time / 1000000;

    if (_aviso.Timer <= 0) {
        array_delete(global.conquista_avisos, 0, 1);
        return;
    }

    var _gw = display_get_gui_width();
    var _w = 340;
    var _h = _aviso.Skin != "" ? 68 : 52;
    var _entrada = clamp((4.0 - _aviso.Timer) / 0.25, 0, 1);
    var _x = _gw - ((_w + 20) * _entrada);
    var _y = 110;

    draw_set_alpha(clamp(_aviso.Timer, 0, 1));
    draw_set_color(make_color_rgb(40, 30, 10));
    draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 10, 10, false);
    draw_set_color(make_color_rgb(255, 210, 90));
    draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 10, 10, true);
    i18n_draw_text_transformed(_x + 16, _y + 8, "CONQUISTA DESBLOQUEADA", 0.6, 0.6, 0);
    draw_set_color(c_white);
    i18n_draw_text_transformed(_x + 16, _y + 26, _aviso.Texto, 0.85, 0.85, 0);

    if (_aviso.Skin != "") {
        draw_set_color(make_color_rgb(170, 230, 255));
        i18n_draw_text_transformed(_x + 16, _y + 48, "Novo visual: " + skin_nome(_aviso.Skin), 0.58, 0.58, 0);
    }

    draw_set_alpha(1);
}

// ------------------------------------------------------------------ visuais do jogador

function skins_lista() {
    static _skins = [
        { Id: "padrao", Nome: "Padrao", Camisa: make_color_rgb(64, 156, 136), Chapeu: make_color_rgb(232, 168, 56), Conquista: "" },
        { Id: "rubi", Nome: "Rubi", Camisa: make_color_rgb(196, 52, 64), Chapeu: make_color_rgb(40, 40, 52), Conquista: "primeiro_lider" },
        { Id: "esmeralda", Nome: "Esmeralda", Camisa: make_color_rgb(40, 150, 80), Chapeu: make_color_rgb(230, 220, 120), Conquista: "rasgo_fechado" },
        { Id: "safira", Nome: "Safira", Camisa: make_color_rgb(52, 92, 200), Chapeu: make_color_rgb(230, 240, 255), Conquista: "diario_7" },
        { Id: "cometa", Nome: "Cometa", Camisa: make_color_rgb(110, 60, 170), Chapeu: make_color_rgb(120, 230, 255), Conquista: "buraco_10" },
        { Id: "obsidiana", Nome: "Obsidiana", Camisa: make_color_rgb(30, 28, 36), Chapeu: make_color_rgb(200, 40, 60), Conquista: "hardcore" }
    ];
    return _skins;
}

function skin_dados(_id) {
    var _skins = skins_lista();

    for (var _i = 0; _i < array_length(_skins); _i += 1) {
        if (_skins[_i].Id == _id) {
            return _skins[_i];
        }
    }

    return _skins[0];
}

function skin_nome(_id) {
    return skin_dados(_id).Nome;
}

function skin_liberada(_skin) {
    return _skin.Conquista == "" || conquista_tem(_skin.Conquista);
}

function skin_alternar() {
    var _skins = skins_lista();
    var _atual = 0;

    for (var _i = 0; _i < array_length(_skins); _i += 1) {
        if (_skins[_i].Id == progresso().Skin) _atual = _i;
    }

    for (var _n = 1; _n <= array_length(_skins); _n += 1) {
        var _cand = _skins[(_atual + _n) mod array_length(_skins)];

        if (skin_liberada(_cand)) {
            progresso().Skin = _cand.Id;
            progresso_salvar();
            return _cand;
        }
    }

    return _skins[_atual];
}

// Recria o sprite do personagem do mapa com o visual atual (so quando ele e placeholder).
function skin_aplicar(_controller) {
    if (!instance_exists(_controller) || !_controller.route_trainer_placeholder) {
        return;
    }

    criatura_sprite_liberar(_controller.route_trainer_sprite);
    _controller.route_trainer_sprite = placeholder_andarilho_folha(progresso().Skin);
}

// ------------------------------------------------------------------ modo Buraco Negro

function buraco_negro_ativo() {
    return variable_global_exists("buraco_negro") && is_struct(global.buraco_negro) && global.buraco_negro.Ativo;
}

function buraco_negro_disponivel() {
    return progresso().BuracoNegroLiberado && !diario_ativo();
}

function buraco_negro_iniciar(_controller) {
    global.buraco_negro = { Ativo: true, Onda: 0, Resultado: undefined };

    with (_controller) {
        for (var _i = 0; _i < array_length(player_party); _i += 1) {
            if (is_struct(player_party[_i])) {
                player_party[_i].HpAtual = player_party[_i].HpMax;
                player_party[_i].Desmaiado = false;
            }
        }
    }

    buraco_negro_proxima_onda(_controller);
}

function buraco_negro_encerrar() {
    global.buraco_negro = undefined;
}

function buraco_negro_proxima_onda(_controller) {
    var _bn = global.buraco_negro;
    _bn.Onda += 1;
    conquista_evento("onda", _bn.Onda - 1);

    var _ids = criatura_ids();
    var _qtd = min(4, 1 + (_bn.Onda div 3));
    var _mult = 1 + (0.10 * (_bn.Onda - 1));
    var _party = [];

    for (var _i = 0; _i < _qtd; _i += 1) {
        var _p = demo_criar_criatura_data(_ids[irandom(array_length(_ids) - 1)], 30, true, true, true, "ginasio");

        if (!is_struct(_p)) {
            continue;
        }

        _p.HpMax = max(1, round(_p.HpMax * _mult));
        _p.HpAtual = _p.HpMax;
        _p.Attack = max(1, round(_p.Attack * _mult));
        _p.Defense = max(1, round(_p.Defense * (1 + ((_mult - 1) * 0.6))));
        array_push(_party, _p);
    }

    with (_controller) {
        // A equipe respira entre ondas: 35% de HP para quem ainda esta de pe.
        for (var _m = 0; _m < array_length(player_party); _m += 1) {
            var _membro = player_party[_m];

            if (is_struct(_membro) && _membro.HpAtual > 0) {
                _membro.HpAtual = min(_membro.HpMax, _membro.HpAtual + ceil(_membro.HpMax * 0.35));
            }
        }

        trainer_party = _party;
        trainer_party_index = 0;
        enemy_criatura_data = _party[0];
        battle_context = "buraco_negro";
        demo_start_battle(id);
    }
}

// Chamado quando a equipe cai no Buraco Negro.
function buraco_negro_finalizar() {
    if (!buraco_negro_ativo() || is_struct(global.buraco_negro.Resultado)) {
        return;
    }

    var _ondas = max(0, global.buraco_negro.Onda - 1);
    var _p = progresso();
    var _recorde = _ondas > _p.BuracoNegroRecorde;

    if (_recorde) {
        _p.BuracoNegroRecorde = _ondas;
        progresso_salvar();
    }

    conquista_evento("onda", _ondas);
    global.buraco_negro.Resultado = { Ondas: _ondas, Recorde: _p.BuracoNegroRecorde, NovoRecorde: _recorde };
}

function buraco_negro_draw_resultado() {
    if (!buraco_negro_ativo()) {
        return;
    }

    buraco_negro_finalizar();
    var _r = global.buraco_negro.Resultado;
    var _gw = display_get_gui_width();
    var _w = 560;
    var _x = (_gw - _w) * 0.5;
    var _y = 226;

    battle_ui_draw_nineslice_panel(_x, _y, _w, 70);
    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(190, 150, 255));
    i18n_draw_text_transformed(_gw * 0.5, _y + 12, "BURACO NEGRO" + (_r.NovoRecorde ? " - NOVO RECORDE!" : ""), 0.82, 0.82, 0);
    draw_set_color(c_white);
    i18n_draw_text_transformed(_gw * 0.5, _y + 40, string(_r.Ondas) + " ondas vencidas  |  recorde: " + string(_r.Recorde), 0.72, 0.72, 0);
    draw_set_halign(fa_left);
}

// ------------------------------------------------------------------ menu e tela de conquistas

function menu_opcoes_rects() {
    return [
        { X: 28, Y: 24, W: 270, H: 36 },
        { X: 28, Y: 66, W: 270, H: 36 },
        { X: 28, Y: 108, W: 270, H: 36 },
        { X: 28, Y: 150, W: 270, H: 36 },
        { X: 28, Y: 192, W: 270, H: 36 }
    ];
}

function menu_opcoes_draw(_mx, _my) {
    var _r = menu_opcoes_rects();
    var _rotulos = [
        "DIFICULDADE: " + dificuldade_nome(progresso().Dificuldade),
        "CONQUISTAS " + string(conquistas_total_desbloqueadas()) + "/" + string(array_length(conquistas_lista())),
        "VISUAL: " + string_upper(skin_nome(progresso().Skin)),
        "SOM: " + audio_modo_nome(),
        "IDIOMA: " + idioma_nome()
    ];

    for (var _i = 0; _i < array_length(_r); _i += 1) {
        var _hover = demo_hover_rect(_mx, _my, _r[_i].X, _r[_i].Y, _r[_i].W, _r[_i].H);
        draw_set_alpha(_hover ? 0.95 : 0.78);
        draw_set_color(make_color_rgb(24, 28, 46));
        draw_roundrect_ext(_r[_i].X, _r[_i].Y, _r[_i].X + _r[_i].W, _r[_i].Y + _r[_i].H, 8, 8, false);
        draw_set_alpha(1);
        draw_set_color(_hover ? make_color_rgb(255, 222, 120) : make_color_rgb(150, 160, 200));
        draw_roundrect_ext(_r[_i].X, _r[_i].Y, _r[_i].X + _r[_i].W, _r[_i].Y + _r[_i].H, 8, 8, true);
        battle_ui_draw_text_fit(_r[_i].X + 14, _r[_i].Y + 9, _rotulos[_i], _r[_i].W - 28, 0.7, _hover ? make_color_rgb(255, 238, 170) : c_white);

        if (_hover) {
            ui_borda_selecao(_r[_i].X, _r[_i].Y, _r[_i].W, _r[_i].H);
        }
    }

    if (demo_hover_rect(_mx, _my, _r[0].X, _r[0].Y, _r[0].W, _r[0].H)) {
        battle_ui_draw_text_fit(_r[0].X, _r[4].Y + 46, dificuldade_params(progresso().Dificuldade).Descricao, 440, 0.6, make_color_rgb(255, 238, 170));
    }
}

// Devolve true se tratou o clique.
function menu_opcoes_clique(_controller, _mx, _my) {
    var _r = menu_opcoes_rects();

    if (demo_hover_rect(_mx, _my, _r[0].X, _r[0].Y, _r[0].W, _r[0].H)) {
        dificuldade_alternar();
        return true;
    }

    if (demo_hover_rect(_mx, _my, _r[1].X, _r[1].Y, _r[1].W, _r[1].H)) {
        _controller.estado_demo = DemoEstado.CONQUISTAS;
        return true;
    }

    if (demo_hover_rect(_mx, _my, _r[2].X, _r[2].Y, _r[2].W, _r[2].H)) {
        skin_alternar();
        skin_aplicar(_controller);
        return true;
    }

    if (demo_hover_rect(_mx, _my, _r[3].X, _r[3].Y, _r[3].W, _r[3].H)) {
        audio_modo_alternar();
        return true;
    }

    if (demo_hover_rect(_mx, _my, _r[4].X, _r[4].Y, _r[4].W, _r[4].H)) {
        idioma_alternar();
        return true;
    }

    return false;
}

function conquistas_draw_tela() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _lista = conquistas_lista();

    draw_rectangle_colour(0, 0, _gw, _gh, make_color_rgb(18, 20, 40), make_color_rgb(18, 20, 40), make_color_rgb(40, 30, 60), make_color_rgb(40, 30, 60), false);
    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(255, 222, 120));
    i18n_draw_text_transformed(_gw * 0.5, 34, "CONQUISTAS  " + string(conquistas_total_desbloqueadas()) + "/" + string(array_length(_lista)), 1.3, 1.3, 0);
    draw_set_halign(fa_left);

    var _cols = 2;
    var _w = 560;
    var _h = 64;
    var _x0 = (_gw - ((_w * _cols) + 20)) * 0.5;

    for (var _i = 0; _i < array_length(_lista); _i += 1) {
        var _c = _lista[_i];
        var _x = _x0 + ((_i mod _cols) * (_w + 20));
        var _y = 90 + (floor(_i / _cols) * (_h + 10));
        var _ok = conquista_tem(_c.Id);

        draw_set_alpha(_ok ? 0.95 : 0.6);
        draw_set_color(_ok ? make_color_rgb(52, 44, 20) : make_color_rgb(30, 32, 48));
        draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 8, 8, false);
        draw_set_alpha(1);
        draw_set_color(_ok ? make_color_rgb(255, 210, 90) : make_color_rgb(90, 96, 120));
        draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 8, 8, true);
        battle_ui_draw_text_fit(_x + 16, _y + 9, (_ok ? "[OK] " : "[  ] ") + _c.Nome, _w - 32, 0.78, _ok ? c_white : make_color_rgb(170, 176, 200));
        battle_ui_draw_text_fit(_x + 16, _y + 36, _c.Descricao + (_c.Skin != "" ? "  (libera o visual " + skin_nome(_c.Skin) + ")" : ""), _w - 32, 0.6, make_color_rgb(200, 206, 230));
    }

    var _p = progresso();
    draw_set_color(make_color_rgb(190, 200, 230));
    i18n_draw_text_transformed(_x0, _gh - 104, "Sinergias: " + string(_p.Contadores.sinergias) + "   Combos: " + string(_p.Contadores.combos) + "   Recorde do Buraco Negro: " + string(_p.BuracoNegroRecorde) + " ondas", 0.7, 0.7, 0);
    demo_draw_choice_button("Voltar", "", 54, _gh - 76, 180, 58, demo_hover_rect(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 54, _gh - 76, 180, 58));
}
