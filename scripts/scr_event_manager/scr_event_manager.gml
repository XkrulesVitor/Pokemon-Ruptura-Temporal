enum EstadoEventoNarrativo {
    INATIVO,
    OFERECIDO,
    ACEITO,
    RECUSADO,
    CONCLUIDO
}

// Banco interno de eventos narrativos. Pode ser trocado por JSON depois,
// mantendo os mesmos campos de EventoNarrativoData.
function OpcaoEventoNarrativo(_id, _texto, _acao) constructor {
    ID = _id;
    Texto = _texto;
    Acao = _acao;
}

function EventoNarrativoData(
    _id,
    _nome,
    _chance,
    _condicao,
    _dialogo,
    _opcoes,
    _consequencias
) constructor {
    ID = _id;
    Nome = _nome;
    Chance = _chance;
    CondicaoAtivacao = _condicao;
    TextoDialogo = _dialogo;
    OpcoesJogador = is_array(_opcoes) ? _opcoes : [];
    Consequencias = is_struct(_consequencias) ? _consequencias : {};
}

function MissaoAtivaData(
    _id,
    _nome,
    _origem_id,
    _destino_id,
    _texto_objetivo,
    _recompensa
) constructor {
    ID = _id;
    Nome = _nome;
    OrigemID = _origem_id;
    DestinoID = _destino_id;
    TextoObjetivo = _texto_objetivo;
    Recompensa = is_struct(_recompensa) ? _recompensa : {};
    Status = EstadoEventoNarrativo.ACEITO;
}

function event_manager_init() {
    if (!variable_global_exists("event_flags")) {
        global.event_flags = {};
    }

    if (!variable_global_exists("evento_narrativo_atual")) {
        global.evento_narrativo_atual = undefined;
    }

    if (!variable_global_exists("missoes_ativas")) {
        global.missoes_ativas = [];
    }

    if (!variable_global_exists("missoes_concluidas")) {
        global.missoes_concluidas = [];
    }

    global.missao_ativa = array_length(global.missoes_ativas) > 0;
    global.missao_destino = global.missao_ativa ? global.missoes_ativas[0].DestinoID : "";

    if (!variable_global_exists("event_db")) {
        global.event_db = event_db_criar();
    }
}

function event_db_criar() {
    return [
        new EventoNarrativoData(
            "carta_cerulean_pallet",
            "Carta da Velhinha",
            30,
            function(_run, _node) {
                return is_struct(_run)
                    && is_struct(_node)
                    && _node.Tipo == TipoNoRun.CIDADE_GINASIO
                    && !event_flag_get("quest_carta_cerulean_pallet_concluida")
                    && !event_missao_ativa("carta_cerulean_pallet");
            },
            [
                "Uma senhora encontra voce perto do Centro de Cura.",
                "\"Meu neto esta em Pallet. Pode entregar esta carta antes que a rota feche?\""
            ],
            [
                new OpcaoEventoNarrativo("aceitar", "Aceitar entrega", "aceitar_missao"),
                new OpcaoEventoNarrativo("recusar", "Recusar", "recusar_evento")
            ],
            {
                MissaoID: "carta_cerulean_pallet",
                DestinoID: "n_0_1",
                Objetivo: "Entregue a carta em Vila Alvorada.",
                Recompensa: { PokemonRaroID: 7, PokemonRaroNivel: 8, Dinheiro: 100 }
            }
        ),
        new EventoNarrativoData(
            "pesquisador_fossil",
            "Fossil Instavel",
            25,
            function(_run, _node) {
                return is_struct(_run)
                    && is_struct(_node)
                    && _node.Tipo == TipoNoRun.CIDADE_GINASIO
                    && _run.DistanciaPercorrida >= 2
                    && !event_flag_get("quest_pesquisador_fossil_concluida")
                    && !event_missao_ativa("pesquisador_fossil");
            },
            [
                "Um pesquisador segura uma caixa termica que vibra sem parar.",
                "\"Leve este fossil ate a cidade mais proxima antes que ele quebre.\""
            ],
            [
                new OpcaoEventoNarrativo("aceitar", "Levar fossil", "aceitar_missao"),
                new OpcaoEventoNarrativo("recusar", "Deixar para la", "recusar_evento")
            ],
            {
                MissaoID: "pesquisador_fossil",
                DestinoID: "proxima_cidade",
                Objetivo: "Entregue o fossil em uma cidade futura.",
                Recompensa: { PokemonRaroID: 1, PokemonRaroNivel: 10, Pokebolas: 2 }
            }
        )
    ];
}

function event_flag_get(_flag) {
    event_manager_init();

    if (!variable_struct_exists(global.event_flags, _flag)) {
        return false;
    }

    return variable_struct_get(global.event_flags, _flag);
}

function event_flag_set(_flag, _valor) {
    event_manager_init();
    variable_struct_set(global.event_flags, _flag, _valor);
}

function event_missao_ativa(_missao_id) {
    event_manager_init();

    for (var _i = 0; _i < array_length(global.missoes_ativas); _i += 1) {
        if (global.missoes_ativas[_i].ID == _missao_id) {
            return true;
        }
    }

    return false;
}

function event_missao_concluida(_missao_id) {
    event_manager_init();

    for (var _i = 0; _i < array_length(global.missoes_concluidas); _i += 1) {
        if (global.missoes_concluidas[_i] == _missao_id) {
            return true;
        }
    }

    return false;
}

function event_tentar_disparar_cidade(_run, _node) {
    event_manager_init();

    if (!is_struct(_node) || _node.Tipo != TipoNoRun.CIDADE_GINASIO) {
        return undefined;
    }

    if (is_struct(global.evento_narrativo_atual)) {
        return global.evento_narrativo_atual;
    }

    var _candidatos = [];

    for (var _i = 0; _i < array_length(global.event_db); _i += 1) {
        var _evento = global.event_db[_i];

        if (is_method(_evento.CondicaoAtivacao) && _evento.CondicaoAtivacao(_run, _node)) {
            if (irandom(99) < _evento.Chance) {
                array_push(_candidatos, _evento);
            }
        }
    }

    if (array_length(_candidatos) <= 0) {
        return undefined;
    }

    var _selecionado = _candidatos[irandom(array_length(_candidatos) - 1)];
    global.evento_narrativo_atual = _selecionado;
    global.estado_jogo = EstadoJogo.EVENTO_NARRATIVO;
    return _selecionado;
}

// Chamado pela UI narrativa quando o jogador escolhe Aceitar ou Recusar.
function event_responder_opcao(_run, _opcao_id) {
    event_manager_init();

    var _evento = global.evento_narrativo_atual;

    if (!is_struct(_evento)) {
        return false;
    }

    for (var _i = 0; _i < array_length(_evento.OpcoesJogador); _i += 1) {
        var _opcao = _evento.OpcoesJogador[_i];

        if (_opcao.ID != _opcao_id) {
            continue;
        }

        switch (_opcao.Acao) {
            case "aceitar_missao":
                event_aceitar_missao(_run, _evento);
                break;

            case "recusar_evento":
                event_flag_set("evento_" + _evento.ID + "_recusado", true);
                break;
        }

        global.evento_narrativo_atual = undefined;
        global.estado_jogo = EstadoJogo.EXPLORACAO;
        return true;
    }

    return false;
}

function event_aceitar_missao(_run, _evento) {
    var _destino = _evento.Consequencias.DestinoID;

    if (_destino == "proxima_cidade") {
        _destino = event_encontrar_proxima_cidade(_run);
    }

    var _missao = new MissaoAtivaData(
        _evento.Consequencias.MissaoID,
        _evento.Nome,
        is_struct(_run.NoAtual) ? _run.NoAtual.ID : "",
        _destino,
        _evento.Consequencias.Objetivo,
        _evento.Consequencias.Recompensa
    );

    array_push(global.missoes_ativas, _missao);
    global.missao_ativa = true;
    global.missao_destino = _missao.DestinoID;
    event_flag_set("quest_" + _missao.ID + "_aceita", true);
}

function event_encontrar_proxima_cidade(_run) {
    if (!is_struct(_run) || !is_struct(_run.NoAtual)) {
        return "";
    }

    for (var _col = _run.NoAtual.Coluna + 1; _col < _run.Colunas; _col += 1) {
        for (var _row = 0; _row < _run.Linhas; _row += 1) {
            var _node = _run.Mapa[_col][_row];

            if (_node.Tipo == TipoNoRun.CIDADE_GINASIO) {
                return _node.ID;
            }
        }
    }

    return _run.NoAtual.ID;
}

// Valida entregas ao entrar em qualquer no. Isso permite missões de rota inversa.
function event_validar_entrega_no(_run, _node) {
    event_manager_init();

    if (!is_struct(_run) || !is_struct(_node)) {
        return [];
    }

    var _concluidas_agora = [];

    for (var _i = array_length(global.missoes_ativas) - 1; _i >= 0; _i -= 1) {
        var _missao = global.missoes_ativas[_i];

        if (_missao.DestinoID == _node.ID) {
            event_concluir_missao(_run, _missao);
            array_push(_concluidas_agora, _missao);
            array_delete(global.missoes_ativas, _i, 1);
        }
    }

    global.missao_ativa = array_length(global.missoes_ativas) > 0;
    global.missao_destino = global.missao_ativa ? global.missoes_ativas[0].DestinoID : "";
    return _concluidas_agora;
}

function event_concluir_missao(_run, _missao) {
    _missao.Status = EstadoEventoNarrativo.CONCLUIDO;
    array_push(global.missoes_concluidas, _missao.ID);
    event_flag_set("quest_" + _missao.ID + "_concluida", true);
    event_aplicar_recompensa_missao(_run, _missao.Recompensa);
}

function event_aplicar_recompensa_missao(_run, _recompensa) {
    if (!is_struct(_run) || !is_struct(_recompensa)) {
        return;
    }

    run_aplicar_recompensas(_run, _recompensa);

    if (variable_struct_exists(_recompensa, "PokemonRaroID")) {
        var _id = _recompensa.PokemonRaroID;
        var _level = variable_struct_exists(_recompensa, "PokemonRaroNivel") ? _recompensa.PokemonRaroNivel : 5;
        var _base = pokemon_db_get(_run.Pokedex, _id);
        var _pokemon = pokemon_data_clonar(_base, _level);

        if (is_struct(_pokemon)) {
            array_push(_run.Equipe, _pokemon);
        }
    }
}
