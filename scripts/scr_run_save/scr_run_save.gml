// Save no meio da run.
// - Grava um snapshot sempre que o jogador volta para a tela da cidade (chegada de rota,
//   vitoria de lider, saida da loja/mochila...). So existe um slot.
// - "CONTINUAR" no menu restaura a run nessa cidade.
// - O save e apagado quando a run termina (game over ou vitoria final).
// - Runs do Desafio Diario tambem sao salvas, com o estado do diario junto.

#macro RUN_SAVE_VERSAO 1

function run_save_path() {
    return (autoteste_ativo() ? "autoteste_" : "") + "run_salva.json";
}

function run_save_existe() {
    if (!variable_global_exists("run_save_existe_cache")) {
        global.run_save_existe_cache = file_exists(run_save_path());
    }

    return global.run_save_existe_cache;
}

function run_save_apagar() {
    if (file_exists(run_save_path())) {
        file_delete(run_save_path());
    }

    global.run_save_existe_cache = false;
    global.run_save_resumo_cache = undefined;
}

function run_save_soma_niveis(_party) {
    var _total = 0;

    for (var _i = 0; _i < array_length(_party); _i += 1) {
        if (is_struct(_party[_i]) && variable_struct_exists(_party[_i], "Level")) {
            _total += _party[_i].Level;
        }
    }

    return _total;
}

function run_save_gravar(_controller) {
    if (!instance_exists(_controller)) {
        return false;
    }

    var _dados = undefined;

    with (_controller) {
        demo_party_garantir(id);

        if (array_length(player_party) <= 0) {
            return false;
        }

        // A criatura ativa e a mesma struct que esta na equipe; guardamos so o indice.
        _dados = {
            Versao: RUN_SAVE_VERSAO,
            Data: date_datetime_string(date_current_datetime()),
            Party: player_party,
            PartyAtiva: player_party_active_index,
            StarterID: starter_id,
            Dinheiro: dinheiro,
            Inventario: inventario,
            CidadeIndex: cidade_index,
            GinasiosVencidos: ginasios_vencidos,
            CidadeEventosVistos: cidade_eventos_vistos,
            RotaDrafts: rota_drafts,
            RotaEscolhas: rota_escolhas,
            MaePresenteEntregue: mae_presente_entregue,
            ProfessorVisto: professor_carvalho_visto,
            Missoes: missoes,
            Diario: diario_ativo() ? global.diario : undefined,
            Resumo: {
                Cidade: demo_cidade_nome(cidade_index),
                Insignias: diario_insignias(id),
                Equipe: array_length(player_party),
                Niveis: run_save_soma_niveis(player_party),
                Lider: player_party[clamp(player_party_active_index, 0, array_length(player_party) - 1)].Nome,
                Diario: diario_ativo()
            }
        };
    }

    var _texto = json_stringify(_dados);
    var _file = file_text_open_write(run_save_path());
    file_text_write_string(_file, _texto);
    file_text_close(_file);

    global.run_save_existe_cache = true;
    global.run_save_resumo_cache = _dados.Resumo;
    return true;
}

function run_save_ler() {
    if (!file_exists(run_save_path())) {
        return undefined;
    }

    var _file = file_text_open_read(run_save_path());
    var _texto = "";

    while (!file_text_eof(_file)) {
        _texto += file_text_readln(_file);
    }

    file_text_close(_file);

    try {
        var _dados = json_parse(_texto);

        if (is_struct(_dados) && variable_struct_exists(_dados, "Versao") && _dados.Versao == RUN_SAVE_VERSAO) {
            return _dados;
        }
    } catch (_erro) {
        show_debug_message("[run_save] save invalido: " + string(_erro));
    }

    return undefined;
}

function run_save_resumo() {
    if (!run_save_existe()) {
        return undefined;
    }

    if (!variable_global_exists("run_save_resumo_cache") || !is_struct(global.run_save_resumo_cache)) {
        var _dados = run_save_ler();
        global.run_save_resumo_cache = is_struct(_dados) ? _dados.Resumo : undefined;

        if (!is_struct(_dados)) {
            global.run_save_existe_cache = false;
        }
    }

    return global.run_save_resumo_cache;
}

function run_save_carregar(_controller) {
    var _dados = run_save_ler();

    if (!is_struct(_dados) || !instance_exists(_controller)) {
        run_save_apagar();
        return false;
    }

    // Comeca de uma run limpa (isso tambem encerra qualquer diario) e aplica o snapshot.
    demo_run_resetar(_controller, DemoEstado.CIDADE);

    var _party = is_array(_dados.Party) ? _dados.Party : [];

    for (var _i = 0; _i < array_length(_party); _i += 1) {
        if (is_struct(_party[_i])) {
            static_set(_party[_i], static_get(PokemonData));
        }
    }

    with (_controller) {
        player_party = _party;
        player_party_active_index = clamp(_dados.PartyAtiva, 0, max(0, array_length(_party) - 1));
        player_pokemon_data = array_length(_party) > 0 ? _party[player_party_active_index] : undefined;
        starter_id = _dados.StarterID;
        dinheiro = _dados.Dinheiro;
        inventario = is_struct(_dados.Inventario) ? _dados.Inventario : demo_inventario_criar();
        cidade_index = clamp(_dados.CidadeIndex, 0, array_length(kanto_cidades) - 1);
        cidade_nome = demo_cidade_nome(cidade_index);
        rota_origem_index = cidade_index;
        rota_destino_index = cidade_index;
        ginasios_vencidos = is_array(_dados.GinasiosVencidos) ? _dados.GinasiosVencidos : ginasios_vencidos;
        cidade_eventos_vistos = is_array(_dados.CidadeEventosVistos) ? _dados.CidadeEventosVistos : cidade_eventos_vistos;
        rota_drafts = is_array(_dados.RotaDrafts) ? _dados.RotaDrafts : rota_drafts;
        rota_escolhas = is_array(_dados.RotaEscolhas) ? _dados.RotaEscolhas : rota_escolhas;
        mae_presente_entregue = _dados.MaePresenteEntregue;
        professor_carvalho_visto = _dados.ProfessorVisto;
        missoes = variable_struct_exists(_dados, "Missoes") && is_struct(_dados.Missoes) ? _dados.Missoes : {};
        meta_inicio_aplicado = true;
        estado_demo = DemoEstado.CIDADE;
        estado_anterior_save = DemoEstado.CIDADE;
        message = "Run retomada em " + cidade_nome + ".";
    }

    if (is_struct(_dados.Diario)) {
        global.diario = _dados.Diario;
        global.diario.Ativo = true;
        global.diario.Profundidade = 0;
        global.diario.Resultado = undefined;
        demo_meta_sincronizar_globals(demo_meta_default());
    }

    return true;
}

// Chamado a cada Step do obj_demo_game (depois dos retornos de draft/overlay):
// salva quando o estado acabou de virar CIDADE.
function run_save_step(_controller) {
    with (_controller) {
        if (!variable_instance_exists(id, "estado_anterior_save")) {
            estado_anterior_save = estado_demo;
        }

        if (estado_demo == DemoEstado.CIDADE && estado_anterior_save != DemoEstado.CIDADE) {
            run_save_gravar(id);
        }

        estado_anterior_save = estado_demo;
    }
}

// ------------------------------------------------------------------ menu

function demo_menu_continue_button_rect() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    return { X: (_gw * 0.5) - 310, Y: _gh - 96, W: 300, H: 58 };
}

function run_save_draw_menu(_mx, _my) {
    var _resumo = run_save_resumo();

    if (!is_struct(_resumo)) {
        return;
    }

    var _rect = demo_menu_continue_button_rect();
    demo_draw_title_button(_rect, "CONTINUAR", demo_hover_rect(_mx, _my, _rect.X, _rect.Y, _rect.W, _rect.H));

    var _linha = (_resumo.Diario ? "Diario | " : "") + _resumo.Cidade + " | " + string(_resumo.Insignias) + " insignias | " + _resumo.Lider + " e mais " + string(max(0, _resumo.Equipe - 1));
    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_text_transformed(_rect.X + (_rect.W * 0.5) + 1, _rect.Y + _rect.H + 9, _linha, 0.62, 0.62, 0);
    draw_set_color(make_color_rgb(200, 230, 255));
    draw_text_transformed(_rect.X + (_rect.W * 0.5), _rect.Y + _rect.H + 8, _linha, 0.62, 0.62, 0);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}
