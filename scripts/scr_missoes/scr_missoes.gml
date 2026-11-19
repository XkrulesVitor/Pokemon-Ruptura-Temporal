// Missoes de NPC nas cidades (dados em datafiles/data/mundo.json -> "missoes").
// - Cada run sorteia uma missao por cidade (no Desafio Diario o sorteio segue a semente do dia).
// - O marcador de evento da cidade mostra "!" quando a missao esta disponivel.
// - Falar com o NPC aceita a missao; o progresso conta sozinho; a recompensa sai na hora.
// - Estado fica em obj_demo_game.missoes ({ "<cidade>": { Id, Estado, Progresso, Destino } })
//   e vai junto no save da run.

#macro MISSOES_ATIVAS_MAX 3

function missoes_db() {
    return conteudo_struct_get(conteudo_garantir().Mundo, "missoes", []);
}

function missao_def(_id) {
    var _db = missoes_db();

    for (var _i = 0; _i < array_length(_db); _i += 1) {
        if (_db[_i].id == _id) {
            return _db[_i];
        }
    }

    return undefined;
}

function missoes_garantir(_controller) {
    if (!variable_instance_exists(_controller, "missoes") || !is_struct(_controller.missoes)) {
        _controller.missoes = {};
    }

    return _controller.missoes;
}

// Estado da missao desta cidade (sorteia na primeira consulta).
function missao_da_cidade(_controller, _cidade) {
    var _missoes = missoes_garantir(_controller);
    var _chave = string(_cidade);

    if (variable_struct_exists(_missoes, _chave)) {
        return variable_struct_get(_missoes, _chave);
    }

    var _candidatas = [];
    var _db = missoes_db();

    for (var _i = 0; _i < array_length(_db); _i += 1) {
        if (_db[_i].cidade == _cidade) {
            array_push(_candidatas, _db[_i]);
        }
    }

    var _estado = undefined;

    if (array_length(_candidatas) > 0) {
        var _escopo = diario_escopo("missao:" + _chave);
        var _def = _candidatas[irandom(array_length(_candidatas) - 1)];
        diario_escopo_fim(_escopo);
        _estado = { Id: _def.id, Estado: "disponivel", Progresso: 0, Destino: -1 };
    } else {
        _estado = { Id: "", Estado: "nenhuma", Progresso: 0, Destino: -1 };
    }

    variable_struct_set(_missoes, _chave, _estado);
    return _estado;
}

function missao_tem_novidade(_controller, _cidade) {
    if (!instance_exists(_controller)) {
        return false;
    }

    return missao_da_cidade(_controller, _cidade).Estado == "disponivel";
}

function missoes_ativas(_controller) {
    var _missoes = missoes_garantir(_controller);
    var _chaves = variable_struct_get_names(_missoes);
    var _ativas = [];

    for (var _i = 0; _i < array_length(_chaves); _i += 1) {
        var _m = variable_struct_get(_missoes, _chaves[_i]);

        if (_m.Estado == "ativa") {
            array_push(_ativas, _m);
        }
    }

    return _ativas;
}

function missao_objetivo_texto(_estado) {
    var _def = missao_def(_estado.Id);

    if (!is_struct(_def)) {
        return "";
    }

    var _qtd = conteudo_struct_get(_def, "quantidade", 1);
    var _alvo = string(conteudo_struct_get(_def, "alvo", ""));

    switch (_def.tipo) {
        case "capturar_tipo": return "Capture " + string(_qtd) + " monstro(s) do tipo " + _alvo + " (" + string(_estado.Progresso) + "/" + string(_qtd) + ")";
        case "capturar_qualquer": return "Capture " + string(_qtd) + " monstros (" + string(_estado.Progresso) + "/" + string(_qtd) + ")";
        case "vencer_tipo": return "Venca " + string(_qtd) + " monstros do tipo " + _alvo + " (" + string(_estado.Progresso) + "/" + string(_qtd) + ")";
        case "vencer_treinadores": return "Venca " + string(_qtd) + " treinadores (" + string(_estado.Progresso) + "/" + string(_qtd) + ")";
        case "entregar": return "Leve a encomenda ate " + demo_cidade_nome(_estado.Destino);
        case "nivel": return "Tenha um monstro no nivel " + string(_qtd);
    }

    return "";
}

function missao_recompensa_texto(_def) {
    var _r = conteudo_struct_get(_def, "recompensa", {});
    var _partes = [];
    var _dinheiro = conteudo_struct_get(_r, "dinheiro", 0);

    if (_dinheiro > 0) {
        array_push(_partes, "M$ " + string(_dinheiro));
    }

    var _itens = conteudo_struct_get(_r, "itens", {});
    var _ids = variable_struct_get_names(_itens);

    for (var _i = 0; _i < array_length(_ids); _i += 1) {
        var _item = demo_item_get(_ids[_i]);
        array_push(_partes, string(variable_struct_get(_itens, _ids[_i])) + "x " + (is_struct(_item) ? _item.Nome : _ids[_i]));
    }

    return string_join_ext(", ", _partes);
}

function missao_conceder(_controller, _estado) {
    var _def = missao_def(_estado.Id);

    if (!is_struct(_def)) {
        return;
    }

    _estado.Estado = "concluida";
    var _r = conteudo_struct_get(_def, "recompensa", {});

    with (_controller) {
        dinheiro += conteudo_struct_get(_r, "dinheiro", 0);
        var _itens = conteudo_struct_get(_r, "itens", {});
        var _ids = variable_struct_get_names(_itens);

        for (var _i = 0; _i < array_length(_ids); _i += 1) {
            demo_inventario_adicionar(inventario, _ids[_i], variable_struct_get(_itens, _ids[_i]));
        }
    }

    var _texto = "Missao concluida (" + _def.npc + ")! Recompensa: " + missao_recompensa_texto(_def);
    missao_toast(_texto);
    battle_log_push(_texto);
    audio_sfx("missao");
}

function missao_toast(_texto) {
    global.missao_toast_atual = { Texto: _texto, Timer: 4.5 };
}

function missao_tipo_bate(_criatura, _alvo) {
    if (!is_struct(_criatura)) {
        return false;
    }

    var _tipo = conteudo_tipo_de_texto(_alvo);
    return _tipo != CriaturaTipo.NONE && (_criatura.Tipo1 == _tipo || _criatura.Tipo2 == _tipo);
}

// Avisa as missoes ativas de algo que aconteceu.
// _evento: "captura" (_dado = criatura), "vitoria" (_dado = criatura derrotada),
//          "treinador" (venceu o treinador inteiro), "chegada" (_dado = indice da cidade), "checar".
function missao_evento(_controller, _evento, _dado) {
    if (!instance_exists(_controller)) {
        return;
    }

    var _ativas = missoes_ativas(_controller);

    for (var _i = 0; _i < array_length(_ativas); _i += 1) {
        var _m = _ativas[_i];
        var _def = missao_def(_m.Id);

        if (!is_struct(_def)) {
            continue;
        }

        var _qtd = conteudo_struct_get(_def, "quantidade", 1);
        var _alvo = conteudo_struct_get(_def, "alvo", "");

        switch (_def.tipo) {
            case "capturar_tipo":
                if (_evento == "captura" && missao_tipo_bate(_dado, _alvo)) _m.Progresso += 1;
                break;
            case "capturar_qualquer":
                if (_evento == "captura") _m.Progresso += 1;
                break;
            case "vencer_tipo":
                if (_evento == "vitoria" && missao_tipo_bate(_dado, _alvo)) _m.Progresso += 1;
                break;
            case "vencer_treinadores":
                if (_evento == "treinador") _m.Progresso += 1;
                break;
            case "entregar":
                if (_evento == "chegada" && _dado == _m.Destino) _m.Progresso = _qtd;
                break;
            case "nivel":
                var _maior = 0;

                for (var _p = 0; _p < array_length(_controller.player_party); _p += 1) {
                    if (is_struct(_controller.player_party[_p])) _maior = max(_maior, _controller.player_party[_p].Level);
                }

                if (_maior >= _qtd) _m.Progresso = _qtd;
                break;
        }

        if (_m.Progresso >= _qtd) {
            missao_conceder(_controller, _m);
        }
    }
}

// Conversa com o NPC do marcador de evento. Devolve o texto do dialogo.
function missao_interagir(_controller, _cidade, _rotulo) {
    var _estado = missao_da_cidade(_controller, _cidade);
    var _def = missao_def(_estado.Id);
    _controller.evento_titulo = _rotulo;

    if (!is_struct(_def)) {
        return _rotulo + ": moradores relatam que as rotas mudaram durante a noite. Algumas ficaram curtas, outras parecem nunca acabar.";
    }

    _controller.evento_titulo = _def.npc;

    switch (_estado.Estado) {
        case "disponivel":
            if (array_length(missoes_ativas(_controller)) >= MISSOES_ATIVAS_MAX) {
                return _def.fala + " (Voce ja tem " + string(MISSOES_ATIVAS_MAX) + " missoes ativas. Termine uma e volte aqui.)";
            }

            _estado.Estado = "ativa";
            _estado.Progresso = 0;

            if (_def.tipo == "entregar") {
                _estado.Destino = min(_cidade + conteudo_struct_get(_def, "destino_relativo", 1), array_length(_controller.kanto_cidades) - 1);
            }

            var _texto = _def.npc + ": " + _def.fala + "\nMissao aceita: " + missao_objetivo_texto(_estado) + ".\nRecompensa: " + missao_recompensa_texto(_def) + ".";
            missao_evento(_controller, "checar", undefined);
            return _texto;

        case "ativa":
            return "Ainda conto com voce. " + missao_objetivo_texto(_estado) + ".";

        case "concluida":
            return "Obrigado pela ajuda! A cidade fica te devendo essa.";
    }

    return "...";
}

// ------------------------------------------------------------------ desenho

function missoes_draw_lista(_controller) {
    var _ativas = missoes_ativas(_controller);

    if (array_length(_ativas) <= 0) {
        return;
    }

    var _x = 36;
    var _y = 114;
    var _w = 384;
    var _h = 30 + (array_length(_ativas) * 22);

    draw_set_alpha(0.82);
    draw_set_color(make_color_rgb(24, 28, 46));
    draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 8, 8, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(255, 222, 120));
    i18n_draw_text_transformed(_x + 12, _y + 6, "MISSOES", 0.7, 0.7, 0);

    for (var _i = 0; _i < array_length(_ativas); _i += 1) {
        battle_ui_draw_text_fit(_x + 12, _y + 26 + (_i * 22), "- " + missao_objetivo_texto(_ativas[_i]), _w - 24, 0.62, c_white);
    }

    draw_set_color(c_white);
}

function missao_toast_draw() {
    if (!variable_global_exists("missao_toast_atual") || !is_struct(global.missao_toast_atual)) {
        return;
    }

    global.missao_toast_atual.Timer -= delta_time / 1000000;

    if (global.missao_toast_atual.Timer <= 0) {
        global.missao_toast_atual = undefined;
        return;
    }

    var _gw = display_get_gui_width();
    var _alpha = clamp(global.missao_toast_atual.Timer, 0, 1);
    var _w = min(_gw - 80, i18n_string_width(global.missao_toast_atual.Texto) * 0.72 + 40);
    var _x = (_gw - _w) * 0.5;
    var _y = 70;

    draw_set_alpha(0.9 * _alpha);
    draw_set_color(make_color_rgb(30, 70, 50));
    draw_roundrect_ext(_x, _y, _x + _w, _y + 34, 10, 10, false);
    draw_set_color(make_color_rgb(150, 230, 170));
    draw_roundrect_ext(_x, _y, _x + _w, _y + 34, 10, 10, true);
    draw_set_alpha(_alpha);
    battle_ui_draw_text_center_fit(_gw * 0.5, _y + 17, global.missao_toast_atual.Texto, _w - 20, 30, 0.72, c_white);
    draw_set_alpha(1);
}
