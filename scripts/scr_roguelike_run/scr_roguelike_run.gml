enum TipoNoRun {
    INICIO,
    POKEMON_SELVAGEM,
    TREINADOR_COMUM,
    EQUIPE_VILA,
    CIDADE_GINASIO,
    LIDER_GINASIO,
    TESOURO
}

function RunInventario() constructor {
    Dinheiro = 0;
    Pokebolas = 5;
    Pocoes = 2;
    Insignias = 0;
}

function RunNode(_id, _coluna, _linha, _tipo, _nivel_sugerido) constructor {
    ID = _id;
    Coluna = _coluna;
    Linha = _linha;
    Tipo = _tipo;
    NivelSugerido = _nivel_sugerido;
    Conexoes = [];
    Visitado = false;
    Disponivel = false;
    Encontro = undefined;
    Recompensas = {};
}

function RunState(_pokedex, _equipe_inicial) constructor {
    Pokedex = _pokedex;
    Equipe = is_array(_equipe_inicial) ? _equipe_inicial : [];
    Inventario = new RunInventario();
    Mapa = [];
    Colunas = 0;
    Linhas = 0;
    NoAtual = undefined;
    DistanciaPercorrida = 0;
    LimiteNivelCaptura = 10;
    GameOver = false;
    UltimoNoResolvido = undefined;
}

function run_criar(_pokedex, _equipe_inicial, _colunas, _linhas) {
    if (argument_count < 3) {
        _colunas = 8;
    }

    if (argument_count < 4) {
        _linhas = 4;
    }

    var _run = new RunState(_pokedex, _equipe_inicial);
    run_gerar_mapa(_run, _colunas, _linhas);
    return _run;
}

function run_gerar_mapa(_run, _colunas, _linhas) {
    _run.Colunas = max(3, _colunas);
    _run.Linhas = max(2, _linhas);
    _run.Mapa = array_create(_run.Colunas);

    for (var _col = 0; _col < _run.Colunas; _col += 1) {
        _run.Mapa[_col] = array_create(_run.Linhas);

        for (var _row = 0; _row < _run.Linhas; _row += 1) {
            var _tipo = run_sortear_tipo_no(_col, _run.Colunas);
            var _nivel = run_nivel_sugerido(_run, _col);
            var _node = new RunNode(run_node_id(_col, _row), _col, _row, _tipo, _nivel);
            _run.Mapa[_col][_row] = _node;
        }
    }

    var _start_row = floor(_run.Linhas / 2);
    var _start = _run.Mapa[0][_start_row];
    _start.Tipo = TipoNoRun.INICIO;
    _start.Visitado = true;
    _start.Disponivel = true;
    _run.NoAtual = _start;

    for (var _row_start = 0; _row_start < _run.Linhas; _row_start += 1) {
        if (_row_start != _start_row) {
            _run.Mapa[0][_row_start].Tipo = TipoNoRun.CIDADE_GINASIO;
        }
    }

    for (var _row_final = 0; _row_final < _run.Linhas; _row_final += 1) {
        _run.Mapa[_run.Colunas - 1][_row_final].Tipo = TipoNoRun.LIDER_GINASIO;
    }

    run_conectar_mapa(_run);
    run_atualizar_nos_disponiveis(_run);
}

function run_conectar_mapa(_run) {
    for (var _col = 0; _col < _run.Colunas - 1; _col += 1) {
        for (var _row = 0; _row < _run.Linhas; _row += 1) {
            var _node = _run.Mapa[_col][_row];
            var _min_row = max(0, _row - 1);
            var _max_row = min(_run.Linhas - 1, _row + 1);
            var _conexoes_desejadas = irandom_range(1, 2);

            repeat (_conexoes_desejadas) {
                var _target_row = irandom_range(_min_row, _max_row);
                run_node_conectar(_node, _run.Mapa[_col + 1][_target_row]);
            }
        }
    }
}

function run_node_conectar(_origem, _destino) {
    for (var _i = 0; _i < array_length(_origem.Conexoes); _i += 1) {
        if (_origem.Conexoes[_i] == _destino.ID) {
            return;
        }
    }

    array_push(_origem.Conexoes, _destino.ID);
}

function run_node_id(_coluna, _linha) {
    return "n_" + string(_coluna) + "_" + string(_linha);
}

function run_get_node(_run, _node_id) {
    for (var _col = 0; _col < _run.Colunas; _col += 1) {
        for (var _row = 0; _row < _run.Linhas; _row += 1) {
            var _node = _run.Mapa[_col][_row];

            if (_node.ID == _node_id) {
                return _node;
            }
        }
    }

    return undefined;
}

function run_sortear_tipo_no(_coluna, _colunas_total) {
    if (_coluna <= 0) {
        return TipoNoRun.INICIO;
    }

    if (_coluna >= _colunas_total - 1) {
        return TipoNoRun.LIDER_GINASIO;
    }

    if (_coluna % 3 == 0 && irandom(100) < 45) {
        return TipoNoRun.CIDADE_GINASIO;
    }

    var _roll = irandom(99);

    if (_roll < 42) {
        return TipoNoRun.POKEMON_SELVAGEM;
    }

    if (_roll < 72) {
        return TipoNoRun.TREINADOR_COMUM;
    }

    if (_roll < 90) {
        return TipoNoRun.EQUIPE_VILA;
    }

    return TipoNoRun.TESOURO;
}

function run_nivel_sugerido(_run, _distancia) {
    var _badges_bonus = is_struct(_run) ? _run.Inventario.Insignias * 4 : 0;
    return clamp(3 + floor(_distancia * 2.35) + _badges_bonus + irandom_range(0, 2), 1, 30);
}

function run_atualizar_nos_disponiveis(_run) {
    for (var _col = 0; _col < _run.Colunas; _col += 1) {
        for (var _row = 0; _row < _run.Linhas; _row += 1) {
            _run.Mapa[_col][_row].Disponivel = false;
        }
    }

    if (!is_struct(_run.NoAtual)) {
        return;
    }

    _run.NoAtual.Disponivel = true;

    for (var _i = 0; _i < array_length(_run.NoAtual.Conexoes); _i += 1) {
        var _next = run_get_node(_run, _run.NoAtual.Conexoes[_i]);

        if (is_struct(_next) && !_next.Visitado) {
            _next.Disponivel = true;
        }
    }

    // Missões de entrega podem abrir uma rota curta de retorno, sem liberar teleporte.
    if (run_missao_exige_retorno(_run)) {
        for (var _row_back = max(0, _run.NoAtual.Linha - 1); _row_back <= min(_run.Linhas - 1, _run.NoAtual.Linha + 1); _row_back += 1) {
            var _back = _run.Mapa[_run.NoAtual.Coluna - 1][_row_back];
            _back.Disponivel = true;
        }
    }
}

function run_no_pode_mover(_run, _node) {
    if (!is_struct(_run) || !is_struct(_node) || _run.GameOver) {
        return false;
    }

    if (!is_struct(_run.NoAtual)) {
        return _node.Tipo == TipoNoRun.INICIO;
    }

    for (var _i = 0; _i < array_length(_run.NoAtual.Conexoes); _i += 1) {
        if (_run.NoAtual.Conexoes[_i] == _node.ID) {
            return true;
        }
    }

    return run_missao_exige_retorno(_run) && run_node_e_retorno_adjacente(_run, _node);
}

function run_missao_exige_retorno(_run) {
    if (!is_struct(_run) || !is_struct(_run.NoAtual) || !variable_global_exists("missoes_ativas")) {
        return false;
    }

    for (var _i = 0; _i < array_length(global.missoes_ativas); _i += 1) {
        var _destino = run_get_node(_run, global.missoes_ativas[_i].DestinoID);

        if (is_struct(_destino) && _destino.Coluna < _run.NoAtual.Coluna) {
            return true;
        }
    }

    return false;
}

function run_node_e_retorno_adjacente(_run, _node) {
    if (!is_struct(_run.NoAtual) || !is_struct(_node)) {
        return false;
    }

    return _node.Coluna == _run.NoAtual.Coluna - 1
        && abs(_node.Linha - _run.NoAtual.Linha) <= 1;
}

function run_mover_para_no(_run, _node) {
    if (!run_no_pode_mover(_run, _node)) {
        return false;
    }

    _run.NoAtual = _node;
    _run.NoAtual.Visitado = true;
    _run.DistanciaPercorrida = max(_run.DistanciaPercorrida, _node.Coluna);
    _run.NoAtual.NivelSugerido = run_nivel_sugerido(_run, _run.DistanciaPercorrida);
    _run.NoAtual.Encontro = run_gerar_encontro(_run, _run.NoAtual);
    event_validar_entrega_no(_run, _run.NoAtual);

    if (_run.NoAtual.Tipo == TipoNoRun.CIDADE_GINASIO) {
        event_tentar_disparar_cidade(_run, _run.NoAtual);
    }

    run_atualizar_nos_disponiveis(_run);
    return true;
}

function run_gerar_encontro(_run, _node) {
    var _tipo = _node.Tipo;
    var _encontro = {
        TipoNo: _tipo,
        Inimigos: [],
        ExpBase: 0,
        PodeCapturar: false,
        RoubaPokemonNaDerrota: false,
        RoubaPokemonDesmaiado: false,
        PossuiGinasio: false,
        Ginasio: undefined,
        Recompensas: {}
    };

    switch (_tipo) {
        case TipoNoRun.POKEMON_SELVAGEM:
            _encontro.Inimigos = run_sortear_pokemon_inimigos(_run, _tipo, _run.DistanciaPercorrida);
            _encontro.ExpBase = 35 + _node.NivelSugerido * 8;
            _encontro.PodeCapturar = true;
            _encontro.Recompensas = { Dinheiro: run_dinheiro_recompensa_inimigos(_encontro.Inimigos, "selvagem") };
            break;

        case TipoNoRun.TREINADOR_COMUM:
            _encontro.Inimigos = run_sortear_pokemon_inimigos(_run, _tipo, _run.DistanciaPercorrida);
            _encontro.ExpBase = 60 + _node.NivelSugerido * 12;
            _encontro.Recompensas = { Pokebolas: irandom_range(1, 2), Pocoes: irandom_range(0, 1), Dinheiro: run_dinheiro_recompensa_inimigos(_encontro.Inimigos, "treinador") };
            break;

        case TipoNoRun.EQUIPE_VILA:
            _encontro.Inimigos = run_sortear_pokemon_inimigos(_run, _tipo, _run.DistanciaPercorrida);
            _encontro.ExpBase = 90 + _node.NivelSugerido * 16;
            _encontro.RoubaPokemonNaDerrota = true;
            _encontro.RoubaPokemonDesmaiado = true;
            _encontro.Recompensas = { Dinheiro: run_dinheiro_recompensa_inimigos(_encontro.Inimigos, "rocket") };
            break;

        case TipoNoRun.CIDADE_GINASIO:
            _encontro.Recompensas = { DescansoSeguro: true };
            _encontro.PossuiGinasio = true;
            _encontro.Ginasio = run_gerar_encontro_lider(_run, _node);
            break;

        case TipoNoRun.LIDER_GINASIO:
            _encontro = run_gerar_encontro_lider(_run, _node);
            break;

        case TipoNoRun.TESOURO:
            _encontro.Recompensas = { Pokebolas: irandom_range(1, 3), Pocoes: irandom_range(1, 2), Dinheiro: 40 + _node.NivelSugerido * 4 };
            break;
    }

    return _encontro;
}

function run_gerar_encontro_lider(_run, _node) {
    var _inimigos = run_sortear_pokemon_inimigos(_run, TipoNoRun.LIDER_GINASIO, _run.DistanciaPercorrida);

    return {
        TipoNo: TipoNoRun.LIDER_GINASIO,
        Inimigos: _inimigos,
        ExpBase: 140 + _node.NivelSugerido * 20,
        PodeCapturar: false,
        RoubaPokemonNaDerrota: false,
        RoubaPokemonDesmaiado: false,
        PossuiGinasio: false,
        Ginasio: undefined,
        Recompensas: { Insignia: 1, Dinheiro: run_dinheiro_recompensa_inimigos(_inimigos, "ginasio") }
    };
}

function run_sortear_pokemon_inimigos(_run, _tipo_no, _distancia) {
    var _ids = run_loot_table_ids(_tipo_no, _distancia);
    var _quantidade = run_quantidade_inimigos(_tipo_no, _distancia);
    var _inimigos = [];

    repeat (_quantidade) {
        var _id = _ids[irandom(array_length(_ids) - 1)];
        var _base = pokemon_db_get(_run.Pokedex, _id);
        var _level = run_nivel_inimigo(_run, _tipo_no, _distancia);
        var _enemy = pokemon_data_clonar(_base, _level);

        if (is_struct(_enemy)) {
            var _contexto = "selvagem";

            switch (_tipo_no) {
                case TipoNoRun.TREINADOR_COMUM:
                    _contexto = "treinador";
                    break;

                case TipoNoRun.EQUIPE_VILA:
                    _contexto = "rocket";
                    break;

                case TipoNoRun.LIDER_GINASIO:
                    _contexto = "ginasio";
                    break;
            }

            pokemon_progressao_inimigo_randomizar_build(_enemy, _contexto);
            array_push(_inimigos, _enemy);
        }
    }

    return _inimigos;
}

function run_loot_table_ids(_tipo_no, _distancia) {
    var _early = [1, 4, 7];
    var _mid = [1, 4, 7, 1, 4, 7];
    var _late = [1, 4, 7, 4, 7, 1];

    if (_tipo_no == TipoNoRun.EQUIPE_VILA) {
        return _distancia < 4 ? [4, 7, 4] : [4, 7, 1, 4];
    }

    if (_tipo_no == TipoNoRun.LIDER_GINASIO) {
        return [1, 4, 7, 7, 4];
    }

    if (_distancia < 3) {
        return _early;
    }

    if (_distancia < 6) {
        return _mid;
    }

    return _late;
}

function run_quantidade_inimigos(_tipo_no, _distancia) {
    switch (_tipo_no) {
        case TipoNoRun.POKEMON_SELVAGEM:
            return _distancia >= 5 ? irandom_range(1, 2) : 1;

        case TipoNoRun.TREINADOR_COMUM:
            return _distancia >= 4 ? 2 : 1;

        case TipoNoRun.EQUIPE_VILA:
            return _distancia >= 5 ? 2 : 1;

        case TipoNoRun.LIDER_GINASIO:
            return _distancia >= 6 ? 2 : 1;
    }

    return 0;
}

function run_nivel_inimigo(_run, _tipo_no, _distancia) {
    var _nivel = run_nivel_sugerido(_run, _distancia);

    switch (_tipo_no) {
        case TipoNoRun.POKEMON_SELVAGEM:
            _nivel -= 1;
            break;

        case TipoNoRun.EQUIPE_VILA:
            _nivel += 3;
            break;

        case TipoNoRun.LIDER_GINASIO:
            _nivel += 5;
            break;
    }

    return clamp(_nivel, 1, 30);
}

function run_dinheiro_limite_total(_tipo_encontro) {
    switch (_tipo_encontro) {
        case "treinador": return 480;
        case "rocket": return 650;
        case "ginasio": return 900;
        case "selvagem": return 240;
    }

    return 240;
}

function run_dinheiro_recompensa_inimigos(_inimigos, _tipo_encontro) {
    if (!is_array(_inimigos)) {
        return 0;
    }

    var _total = 0;

    for (var _i = 0; _i < array_length(_inimigos); _i += 1) {
        _total += pokemon_recompensa_dinheiro(_inimigos[_i], _tipo_encontro);
    }

    return min(_total, run_dinheiro_limite_total(_tipo_encontro));
}

function run_resolver_vitoria_no(_run, _node) {
    if (!is_struct(_run) || !is_struct(_node) || !is_struct(_node.Encontro)) {
        return false;
    }

    var _enc = _node.Encontro;

    if (_enc.RoubaPokemonDesmaiado) {
        run_remover_pokemons_desmaiados_permanente(_run);

        if (run_time_derrotado(_run)) {
            _run.GameOver = true;
            global.estado_jogo = EstadoJogo.GAME_OVER;
            return true;
        }
    }

    run_aplicar_recompensas(_run, _enc.Recompensas);

    if (_enc.ExpBase > 0) {
        run_distribuir_exp(_run, _enc.ExpBase);
    }

    if (variable_struct_exists(_enc.Recompensas, "Insignia")) {
        run_expandir_limite_captura(_run);
    }

    _run.UltimoNoResolvido = _node;
    return true;
}

function run_resolver_derrota_no(_run, _node) {
    if (!is_struct(_run) || !is_struct(_node) || !is_struct(_node.Encontro)) {
        return false;
    }

    if (_node.Encontro.RoubaPokemonNaDerrota) {
        run_remover_pokemons_desmaiados_permanente(_run);
    }

    if (run_time_derrotado(_run)) {
        _run.GameOver = true;
        global.estado_jogo = EstadoJogo.GAME_OVER;
    }

    return true;
}

function run_time_derrotado(_run) {
    for (var _i = 0; _i < array_length(_run.Equipe); _i += 1) {
        var _pokemon = _run.Equipe[_i];

        if (is_struct(_pokemon) && (!variable_struct_exists(_pokemon, "Desmaiado") || !_pokemon.Desmaiado)) {
            return false;
        }
    }

    return true;
}

function run_remover_pokemons_desmaiados_permanente(_run) {
    var _removeu = false;

    for (var _i = array_length(_run.Equipe) - 1; _i >= 0; _i -= 1) {
        var _pokemon = _run.Equipe[_i];

        if (is_struct(_pokemon) && variable_struct_exists(_pokemon, "Desmaiado") && _pokemon.Desmaiado) {
            array_delete(_run.Equipe, _i, 1);
            _removeu = true;
        }
    }

    return _removeu;
}

function run_remover_pokemon_permanente(_run) {
    if (run_remover_pokemons_desmaiados_permanente(_run)) {
        return true;
    }

    if (array_length(_run.Equipe) > 0) {
        array_delete(_run.Equipe, array_length(_run.Equipe) - 1, 1);
        return true;
    }

    return false;
}

function run_aplicar_recompensas(_run, _recompensas) {
    if (!is_struct(_recompensas)) {
        return;
    }

    if (variable_struct_exists(_recompensas, "Dinheiro")) {
        _run.Inventario.Dinheiro += _recompensas.Dinheiro;
    }

    if (variable_struct_exists(_recompensas, "Pokebolas")) {
        _run.Inventario.Pokebolas += _recompensas.Pokebolas;
    }

    if (variable_struct_exists(_recompensas, "Pocoes")) {
        _run.Inventario.Pocoes += _recompensas.Pocoes;
    }

    if (variable_struct_exists(_recompensas, "Insignia")) {
        _run.Inventario.Insignias += _recompensas.Insignia;
    }

    if (variable_struct_exists(_recompensas, "DescansoSeguro") && _recompensas.DescansoSeguro) {
        run_descansar_equipe(_run);
    }
}

function run_distribuir_exp(_run, _exp_total) {
    var _vivos = 0;

    for (var _i = 0; _i < array_length(_run.Equipe); _i += 1) {
        var _pokemon = _run.Equipe[_i];

        if (is_struct(_pokemon) && (!variable_struct_exists(_pokemon, "Desmaiado") || !_pokemon.Desmaiado)) {
            _vivos += 1;
        }
    }

    if (_vivos <= 0) {
        return;
    }

    var _por_pokemon = ceil(_exp_total / _vivos);

    for (var _j = 0; _j < array_length(_run.Equipe); _j += 1) {
        var _ally = _run.Equipe[_j];

        if (is_struct(_ally) && (!variable_struct_exists(_ally, "Desmaiado") || !_ally.Desmaiado)) {
            pokemon_ganhar_exp(_ally, _por_pokemon);
        }
    }
}

function run_descansar_equipe(_run) {
    for (var _i = 0; _i < array_length(_run.Equipe); _i += 1) {
        if (is_struct(_run.Equipe[_i])) {
            _run.Equipe[_i].Desmaiado = false;
        }
    }
}

function run_expandir_limite_captura(_run) {
    _run.LimiteNivelCaptura = clamp(10 + (_run.Inventario.Insignias * 5), 10, 30);
}

function run_tentar_captura(_run, _pokemon_selvagem) {
    if (!is_struct(_run) || !is_struct(_pokemon_selvagem) || _run.Inventario.Pokebolas <= 0) {
        return false;
    }

    _run.Inventario.Pokebolas -= 1;

    if (_pokemon_selvagem.Level > _run.LimiteNivelCaptura) {
        return false;
    }

    var _bonus_shiny = variable_struct_exists(_pokemon_selvagem, "CaptureChanceBonus") ? (_pokemon_selvagem.CaptureChanceBonus * 100) : 0;
    var _chance = clamp(75 - (_pokemon_selvagem.Level * 0.65) + (_run.Inventario.Insignias * 5) + _bonus_shiny, 15, 95);

    if (irandom(99) < _chance) {
        _pokemon_selvagem.FoiCapturado = true;
        _pokemon_selvagem.Capturado = true;
        array_push(_run.Equipe, _pokemon_selvagem);
        pokedex_capturar(_pokemon_selvagem.ID);
        return true;
    }

    return false;
}
