// Kit de interface (Sprint 9): paineis, cartoes, borda de selecao, etiquetas e selo de moedas.
// Tudo desenhado por codigo, com a mesma paleta, para a interface ficar consistente.

function ui_cor(_nome) {
    switch (_nome) {
        case "papel": return make_color_rgb(244, 236, 214);
        case "papel_claro": return make_color_rgb(252, 248, 236);
        case "papel_escuro": return make_color_rgb(226, 214, 186);
        case "borda": return make_color_rgb(92, 66, 50);
        case "borda_suave": return make_color_rgb(170, 142, 100);
        case "tinta": return make_color_rgb(40, 32, 30);
        case "tinta_suave": return make_color_rgb(98, 80, 68);
        case "ouro": return make_color_rgb(255, 210, 90);
        case "ouro_escuro": return make_color_rgb(196, 146, 46);
        case "vermelho": return make_color_rgb(178, 52, 58);
        case "verde": return make_color_rgb(62, 150, 92);
        case "noite": return make_color_rgb(24, 28, 46);
        case "ciano": return make_color_rgb(120, 230, 255);
    }

    return c_white;
}

function ui_fundo_escurecido(_alpha) {
    draw_set_alpha(_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}

function ui_sombra(_x, _y, _w, _h, _raio, _desloc) {
    draw_set_alpha(0.28);
    draw_set_color(c_black);
    draw_roundrect_ext(_x + _desloc, _y + _desloc + 2, _x + _w + _desloc, _y + _h + _desloc + 2, _raio, _raio, false);
    draw_set_alpha(1);
}

// Painel de "papel" (lojas, dialogos, menus da cidade).
function ui_painel_papel(_x, _y, _w, _h) {
    ui_sombra(_x, _y, _w, _h, 16, 6);
    draw_set_color(ui_cor("borda"));
    draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 16, 16, false);
    draw_set_color(ui_cor("papel"));
    draw_roundrect_ext(_x + 3, _y + 3, _x + _w - 3, _y + _h - 3, 14, 14, false);
    draw_set_color(ui_cor("papel_claro"));
    draw_line_width(_x + 16, _y + 5, _x + _w - 16, _y + 5, 2);
    draw_set_color(ui_cor("borda_suave"));
    draw_roundrect_ext(_x + 7, _y + 7, _x + _w - 7, _y + _h - 7, 12, 12, true);
}

// Faixa de titulo no topo de um painel (devolve a altura usada).
function ui_painel_titulo(_x, _y, _w, _texto) {
    var _h = 40;
    draw_set_color(ui_cor("vermelho"));
    draw_roundrect_ext(_x + 3, _y + 3, _x + _w - 3, _y + _h, 14, 14, false);
    draw_rectangle(_x + 3, _y + 20, _x + _w - 3, _y + _h, false);
    draw_set_color(ui_cor("ouro_escuro"));
    draw_rectangle(_x + 3, _y + _h, _x + _w - 3, _y + _h + 2, false);
    battle_ui_font_title();
    ui_texto_sombra(_x + 22, _y + 11, _texto, c_white, 1);
    return _h + 2;
}

function ui_texto_sombra(_x, _y, _texto, _cor, _escala) {
    var _cor_antiga = draw_get_color();
    draw_set_color(c_black);
    draw_set_alpha(draw_get_alpha() * 0.55);
    i18n_draw_text_transformed(_x + 1, _y + 2, _texto, _escala, _escala, 0);
    draw_set_alpha(1);
    draw_set_color(_cor);
    i18n_draw_text_transformed(_x, _y, _texto, _escala, _escala, 0);
    draw_set_color(_cor_antiga);
}

// Borda animada de selecao: brilho pulsante + cantoneiras que respiram.
function ui_borda_selecao(_x, _y, _w, _h) {
    var _t = current_time * 0.006;
    var _pulso = 0.5 + (0.5 * sin(_t));
    var _cor = merge_color(ui_cor("ouro"), c_white, 0.25 * _pulso);

    draw_set_alpha(0.18 + (0.18 * _pulso));
    draw_set_color(_cor);
    draw_roundrect_ext(_x - 6, _y - 6, _x + _w + 6, _y + _h + 6, 14, 14, false);
    draw_set_alpha(1);
    draw_set_color(_cor);
    draw_roundrect_ext(_x - 2, _y - 2, _x + _w + 2, _y + _h + 2, 12, 12, true);
    draw_roundrect_ext(_x - 3, _y - 3, _x + _w + 3, _y + _h + 3, 12, 12, true);

    var _o = 5 + (2 * _pulso);
    var _l = 14;
    var _e = 3;
    draw_set_color(ui_cor("ouro"));
    // canto superior esquerdo
    draw_rectangle(_x - _o, _y - _o, _x - _o + _l, _y - _o + _e, false);
    draw_rectangle(_x - _o, _y - _o, _x - _o + _e, _y - _o + _l, false);
    // superior direito
    draw_rectangle(_x + _w + _o - _l, _y - _o, _x + _w + _o, _y - _o + _e, false);
    draw_rectangle(_x + _w + _o - _e, _y - _o, _x + _w + _o, _y - _o + _l, false);
    // inferior esquerdo
    draw_rectangle(_x - _o, _y + _h + _o - _e, _x - _o + _l, _y + _h + _o, false);
    draw_rectangle(_x - _o, _y + _h + _o - _l, _x - _o + _e, _y + _h + _o, false);
    // inferior direito
    draw_rectangle(_x + _w + _o - _l, _y + _h + _o - _e, _x + _w + _o, _y + _h + _o, false);
    draw_rectangle(_x + _w + _o - _e, _y + _h + _o - _l, _x + _w + _o, _y + _h + _o, false);
}

// Cartao clicavel (itens, rotas, opcoes). Devolve o retangulo efetivo (sobe 2px no hover).
function ui_cartao(_x, _y, _w, _h, _hover, _desabilitado) {
    var _dy = _hover && !_desabilitado ? -2 : 0;
    ui_sombra(_x, _y + _dy, _w, _h, 10, _hover ? 5 : 3);
    draw_set_color(_hover && !_desabilitado ? ui_cor("ouro_escuro") : ui_cor("borda_suave"));
    draw_roundrect_ext(_x, _y + _dy, _x + _w, _y + _h + _dy, 10, 10, false);
    draw_set_color(_desabilitado ? ui_cor("papel_escuro") : (_hover ? make_color_rgb(255, 248, 222) : ui_cor("papel_claro")));
    draw_roundrect_ext(_x + 2, _y + 2 + _dy, _x + _w - 2, _y + _h - 2 + _dy, 9, 9, false);

    if (_hover && !_desabilitado) {
        ui_borda_selecao(_x, _y + _dy, _w, _h);
    }

    return { X: _x, Y: _y + _dy, W: _w, H: _h };
}

// Etiqueta pequena arredondada (ex.: "So em batalha", categoria do item).
function ui_tag(_x, _y, _texto, _cor_fundo, _cor_texto) {
    var _escala = 0.55;
    var _w = (i18n_string_width(_texto) * _escala) + 14;
    var _h = 18;
    draw_set_color(_cor_fundo);
    draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 8, 8, false);
    draw_set_color(_cor_texto);
    i18n_draw_text_transformed(_x + 7, _y + 2, _texto, _escala, _escala, 0);
    return _w;
}

// Selo de dinheiro: pilula escura com moeda dourada.
function ui_selo_moedas(_x, _y, _valor) {
    var _texto = string(_valor);
    var _w = max(120, i18n_string_width(_texto) + 74);
    var _h = 40;
    ui_sombra(_x, _y, _w, _h, 20, 3);
    draw_set_color(ui_cor("ouro_escuro"));
    draw_roundrect_ext(_x, _y, _x + _w, _y + _h, 20, 20, false);
    draw_set_color(ui_cor("noite"));
    draw_roundrect_ext(_x + 2, _y + 2, _x + _w - 2, _y + _h - 2, 18, 18, false);
    var _cx = _x + 22;
    var _cy = _y + (_h * 0.5);
    draw_set_color(ui_cor("ouro_escuro"));
    draw_circle(_cx, _cy, 12, false);
    draw_set_color(ui_cor("ouro"));
    draw_circle(_cx, _cy, 10, false);
    draw_set_color(ui_cor("ouro_escuro"));
    draw_circle(_cx, _cy, 6, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(ui_cor("borda"));
    i18n_draw_text_transformed(_cx, _cy, "M", 0.62, 0.62, 0);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    i18n_draw_text(_x + 44, _cy, _texto);
    draw_set_valign(fa_top);
    return _w;
}

// Texto com quebra de linha limitado a N linhas (corta com "...").
function ui_texto_bloco(_x, _y, _texto, _sep, _w, _max_linhas, _escala) {
    var _base = i18n_t(string(_texto));
    var _t = _base;
    var _n = string_length(_base);
    var _limite = (_sep * _max_linhas) + 2;
    var _largura = _w / _escala;

    while (_n > 4 && (string_height_ext(_t, _sep, _largura) * _escala) > _limite) {
        _n -= 3;
        _t = string_copy(_base, 1, _n) + "...";
    }

    var _fonte = ui_fonte_escalada(_escala);

    if (_fonte >= 0) {
        var _antiga = draw_get_font();
        draw_set_font(_fonte);
        draw_text_ext(_x, _y, _t, _sep * _escala, _w);
        draw_set_font(_antiga);
        return;
    }

    var _filtro = gpu_get_texfilter();
    gpu_set_texfilter(true);
    draw_text_ext_transformed(_x, _y, _t, _sep, _largura, _escala, _escala, 0);
    gpu_set_texfilter(_filtro);
}

// Fonte da interface rasterizada no tamanho final (base x escala), criada uma vez e guardada.
// Devolve -1 quando a fonte atual nao e uma das fontes da interface ou a escala e ~1.
function ui_fonte_escalada(_escala) {
    if (!variable_global_exists("ui_font_tamanho") || abs(_escala - 1) < 0.04 || _escala <= 0.3 || _escala > 4) {
        return -1;
    }

    var _atual = draw_get_font();
    var _caminho = "";

    if (font_exists(global.ui_font) && _atual == global.ui_font) {
        _caminho = global.ui_font_path;
    } else if (font_exists(global.ui_font_body) && _atual == global.ui_font_body) {
        _caminho = global.ui_font_body_path;
    }

    if (_caminho == "") {
        return -1;
    }

    var _px = max(6, round(global.ui_font_tamanho * _escala));

    if (_px == global.ui_font_tamanho) {
        return -1;
    }

    if (!variable_global_exists("ui_fontes_cache") || !is_struct(global.ui_fontes_cache)) {
        global.ui_fontes_cache = {};
    }

    var _chave = _caminho + "|" + string(_px);

    if (!variable_struct_exists(global.ui_fontes_cache, _chave)) {
        global.ui_fontes_cache[$ _chave] = font_add(_caminho, _px, false, false, 32, 127);
    }

    var _fonte = global.ui_fontes_cache[$ _chave];
    return font_exists(_fonte) ? _fonte : -1;
}

// ------------------------------------------------------------------ mercado, mochila e dialogos da cidade
// Os retangulos saem destas funcoes e sao usados tanto no desenho quanto no clique.

// A altura acompanha a quantidade de itens a venda (2 colunas).
function demo_loja_painel(_n = 6) {
    var _gw = display_get_gui_width();
    var _linhas = max(1, ceil(_n / 2));
    return { X: (_gw - 820) * 0.5, Y: 124, W: 820, H: max(330, 92 + (_linhas * 106) + 52) };
}

function demo_loja_rect(_i) {
    var _p = demo_loja_painel();
    var _cw = (_p.W - 64) / 2;
    return { X: _p.X + 24 + ((_i mod 2) * (_cw + 16)), Y: _p.Y + 92 + ((_i div 2) * 106), W: _cw, H: 94 };
}

function demo_mochila_painel(_n = 12) {
    var _gw = display_get_gui_width();
    var _linhas = max(1, ceil(_n / 4));
    return { X: (_gw - 1160) * 0.5, Y: 112, W: 1160, H: clamp(92 + (_linhas * 92) + 50, 300, 552) };
}

// 4 colunas; com muitos itens as linhas encolhem para caber no painel.
function demo_mochila_rect(_i, _n = 12) {
    var _p = demo_mochila_painel(_n);
    var _colunas = 4;
    var _cw = (_p.W - 48 - ((_colunas - 1) * 16)) / _colunas;
    var _linhas = max(1, ceil(_n / _colunas));
    var _passo = min(92, floor((_p.H - 92 - 50) / _linhas));
    return { X: _p.X + 24 + ((_i mod _colunas) * (_cw + 16)), Y: _p.Y + 92 + ((_i div _colunas) * _passo), W: _cw, H: _passo - 10 };
}

function demo_item_categoria(_item) {
    switch (_item.Tipo) {
        case "captura": return { Nome: "Captura", Cor: make_color_rgb(64, 132, 196) };
        case "cura": return { Nome: "Cura", Cor: make_color_rgb(62, 150, 92) };
        case "cura_status": return { Nome: "Cura total", Cor: make_color_rgb(40, 130, 80) };
        case "status": return { Nome: "Status", Cor: make_color_rgb(48, 140, 140) };
        case "berry": return { Nome: "Fruta automatica", Cor: make_color_rgb(200, 120, 40) };
        case "cooldown": return { Nome: "Batalha", Cor: make_color_rgb(132, 84, 180) };
        case "buff": return { Nome: "Batalha", Cor: make_color_rgb(132, 84, 180) };
        case "level": return { Nome: "Nivel", Cor: make_color_rgb(190, 140, 30) };
    }

    return { Nome: "Item", Cor: ui_cor("tinta_suave") };
}

function demo_item_slot_icone(_id_item, _cx, _cy, _raio) {
    draw_set_color(ui_cor("borda_suave"));
    draw_circle(_cx, _cy, _raio + 2, false);
    draw_set_color(ui_cor("papel_escuro"));
    draw_circle(_cx, _cy, _raio, false);
    demo_draw_item_icon(_id_item, _cx, _cy, _raio * 1.45);
}

function demo_draw_loja(_c) {
    var _itens = demo_shop_items_cidade(_c.cidade_index);
    var _p = demo_loja_painel(array_length(_itens));
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    ui_fundo_escurecido(0.35);
    ui_painel_papel(_p.X, _p.Y, _p.W, _p.H);
    ui_painel_titulo(_p.X, _p.Y, _p.W, "MERCADO - " + string_upper(demo_cidade_nome(_c.cidade_index)));
    ui_selo_moedas(_p.X + _p.W - 176, _p.Y + 1, _c.dinheiro);
    battle_ui_font_body();
    draw_set_color(ui_cor("tinta_suave"));
    i18n_draw_text(_p.X + 26, _p.Y + 56, "Clique em um item para comprar.");

    for (var _i = 0; _i < array_length(_itens); _i += 1) {
        var _item = demo_item_get(_itens[_i]);

        if (!is_struct(_item)) {
            continue;
        }

        var _r = demo_loja_rect(_i);
        var _pode = _c.dinheiro >= _item.Preco;
        var _hover = demo_hover_rect(_mx, _my, _r.X, _r.Y, _r.W, _r.H);
        var _k = ui_cartao(_r.X, _r.Y, _r.W, _r.H, _hover, !_pode);

        demo_item_slot_icone(_itens[_i], _k.X + 42, _k.Y + (_k.H * 0.5), 26);
        battle_ui_font_title();
        battle_ui_draw_text_fit(_k.X + 82, _k.Y + 10, _item.Nome, _k.W - 200, 0.82, ui_cor("tinta"));
        draw_set_halign(fa_right);
        draw_set_color(_pode ? ui_cor("verde") : ui_cor("vermelho"));
        i18n_draw_text_transformed(_k.X + _k.W - 16, _k.Y + 10, "M$ " + string(_item.Preco), 0.82, 0.82, 0);
        draw_set_color(ui_cor("tinta_suave"));
        i18n_draw_text_transformed(_k.X + _k.W - 16, _k.Y + _k.H - 24, "Voce tem: " + string(demo_inventario_quantidade(_c.inventario, _itens[_i])), 0.6, 0.6, 0);
        draw_set_halign(fa_left);
        var _cat = demo_item_categoria(_item);
        ui_tag(_k.X + 82, _k.Y + _k.H - 26, _cat.Nome, _cat.Cor, c_white);
        battle_ui_font_body();
        draw_set_color(ui_cor("tinta_suave"));
        ui_texto_bloco(_k.X + 82, _k.Y + 34, _item.Descricao, 17, _k.W - 108, 2, 0.74);
        battle_ui_font_title();
    }

    // Linha de status (compra feita, dinheiro insuficiente...).
    battle_ui_font_body();
    draw_set_color(string_pos("insuficiente", _c.message) > 0 ? ui_cor("vermelho") : ui_cor("tinta"));
    battle_ui_draw_text_fit(_p.X + 26, _p.Y + _p.H - 36, demo_rodape_mensagem(_c), _p.W - 52, 0.8, draw_get_color());
    battle_ui_font_title();
}

function demo_draw_mochila(_c) {
    var _ids = demo_item_ids_possuidos(_c.inventario);
    var _p = demo_mochila_painel(array_length(_ids));
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    ui_fundo_escurecido(0.35);
    ui_painel_papel(_p.X, _p.Y, _p.W, _p.H);
    ui_painel_titulo(_p.X, _p.Y, _p.W, "MOCHILA");
    ui_selo_moedas(_p.X + _p.W - 176, _p.Y + 1, _c.dinheiro);
    battle_ui_font_body();
    draw_set_color(ui_cor("tinta_suave"));
    i18n_draw_text(_p.X + 26, _p.Y + 56, "Clique em um item para usar. Alguns so funcionam em batalha.");

    if (array_length(_ids) <= 0) {
        draw_set_halign(fa_center);
        i18n_draw_text(_p.X + (_p.W * 0.5), _p.Y + (_p.H * 0.5), "Mochila vazia");
        draw_set_halign(fa_left);
    }

    for (var _i = 0; _i < array_length(_ids); _i += 1) {
        var _item = demo_item_get(_ids[_i]);

        if (!is_struct(_item)) {
            continue;
        }

        var _r = demo_mochila_rect(_i, array_length(_ids));
        var _usavel = demo_item_pode_usar(_item, false);
        var _hover = _usavel && demo_hover_rect(_mx, _my, _r.X, _r.Y, _r.W, _r.H);
        var _k = ui_cartao(_r.X, _r.Y, _r.W, _r.H, _hover, false);
        var _qtd = demo_inventario_quantidade(_c.inventario, _ids[_i]);

        demo_item_slot_icone(_ids[_i], _k.X + 36, _k.Y + (_k.H * 0.5), 22);
        battle_ui_font_title();
        battle_ui_draw_text_fit(_k.X + 70, _k.Y + 9, _item.Nome, _k.W - 120, 0.78, ui_cor("tinta"));

        // Quantidade em selo redondo.
        draw_set_color(ui_cor("borda"));
        draw_circle(_k.X + _k.W - 22, _k.Y + 20, 14, false);
        draw_set_color(ui_cor("ouro"));
        draw_circle(_k.X + _k.W - 22, _k.Y + 20, 12, false);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(ui_cor("borda"));
        i18n_draw_text_transformed(_k.X + _k.W - 22, _k.Y + 20, string(_qtd), 0.62, 0.62, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        var _cat = demo_item_categoria(_item);
        var _tx = _k.X + 70 + ui_tag(_k.X + 70, _k.Y + 34, _cat.Nome, _cat.Cor, c_white) + 6;

        if (!_usavel) {
            ui_tag(_tx, _k.Y + 34, _item.Tipo == "berry" ? "Usa sozinha" : "So em batalha", ui_cor("papel_escuro"), ui_cor("tinta_suave"));
        }

        battle_ui_font_body();
        draw_set_color(ui_cor("tinta_suave"));
        ui_texto_bloco(_k.X + 70, min(_k.Y + 56, _k.Y + _k.H - 17), _item.Descricao, 16, _k.W - 84, 1, 0.66);
        battle_ui_font_title();
    }

    battle_ui_font_body();
    draw_set_color(ui_cor("tinta"));
    battle_ui_draw_text_fit(_p.X + 26, _p.Y + _p.H - 36, demo_rodape_mensagem(_c), _p.W - 52, 0.8, ui_cor("tinta"));
    battle_ui_font_title();
}

function demo_draw_dialogo_cidade(_titulo, _texto, _speaker) {
    var _x = 70;
    var _y = 150;
    var _w = 800;
    var _h = 300;
    ui_fundo_escurecido(0.25);
    ui_painel_papel(_x, _y, _w, _h);
    var _hh = ui_painel_titulo(_x, _y, _w, _titulo);
    demo_draw_dialog_character(_speaker, _x, _y + _hh, _x + _w, _y + _h - 6);
    battle_ui_font_body();
    draw_set_color(ui_cor("tinta"));
    ui_texto_bloco(_x + 28, _y + _hh + 20, _texto, 26, _w - 290, 8, 1);
    battle_ui_font_title();
}

// Rodape das janelas da cidade: esconde a mensagem que so repete o nome da cidade.
function demo_rodape_mensagem(_c) {
    var _m = string(_c.message);

    if (_m == demo_cidade_nome(_c.cidade_index) || _m == "Vila Alvorada") {
        return "";
    }

    return _m;
}

// Cor de texto das descricoes ricas: escura no papel, clara quando um painel escuro pede.
function ui_tinta_contexto(_suave = false) {
    if (variable_global_exists("ui_tinta_override") && !is_undefined(global.ui_tinta_override)) {
        return _suave ? make_color_rgb(190, 196, 220) : global.ui_tinta_override;
    }

    return _suave ? make_color_rgb(90, 72, 64) : make_color_rgb(50, 36, 34);
}

// Cartao no tema escuro da batalha (mesma logica do ui_cartao).
function ui_cartao_escuro(_x, _y, _w, _h, _hover, _desabilitado) {
    var _dy = _hover && !_desabilitado ? -2 : 0;
    ui_sombra(_x, _y + _dy, _w, _h, 10, _hover ? 5 : 3);
    draw_set_color(_hover && !_desabilitado ? ui_cor("ouro") : make_color_rgb(96, 108, 150));
    draw_roundrect_ext(_x, _y + _dy, _x + _w, _y + _h + _dy, 10, 10, false);
    var _c1 = _desabilitado ? make_color_rgb(30, 32, 46) : (_hover ? make_color_rgb(48, 58, 96) : make_color_rgb(36, 44, 74));
    draw_set_color(_c1);
    draw_roundrect_ext(_x + 2, _y + 2 + _dy, _x + _w - 2, _y + _h - 2 + _dy, 9, 9, false);

    if (_hover && !_desabilitado) {
        ui_borda_selecao(_x, _y + _dy, _w, _h);
    }

    return { X: _x, Y: _y + _dy, W: _w, H: _h };
}

// Caixa de confirmacao (Sim / Cancelar). Enter confirma, Esc cancela.
function ui_confirmacao_abrir(_acao, _titulo, _texto, _rotulo_sim) {
    global.ui_confirmacao = { Acao: _acao, Titulo: _titulo, Texto: _texto, Sim: _rotulo_sim };
}

function ui_confirmacao_ativa() {
    return variable_global_exists("ui_confirmacao") && is_struct(global.ui_confirmacao);
}

function ui_confirmacao_fechar() {
    global.ui_confirmacao = undefined;
}

function ui_confirmacao_rects() {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _w = 620;
    var _h = 236;
    var _x = (_gw - _w) * 0.5;
    var _y = (_gh - _h) * 0.5;
    return {
        Painel: { X: _x, Y: _y, W: _w, H: _h },
        Sim: { X: _x + 36, Y: _y + _h - 82, W: 290, H: 54 },
        Nao: { X: _x + _w - 36 - 220, Y: _y + _h - 82, W: 220, H: 54 }
    };
}

// Devolve "sim", "nao" ou "" (sem resposta neste quadro).
function ui_confirmacao_step() {
    if (!ui_confirmacao_ativa()) {
        return "";
    }

    if (keyboard_check_pressed(vk_escape)) {
        return "nao";
    }

    if (keyboard_check_pressed(vk_enter)) {
        return "sim";
    }

    if (mouse_check_button_pressed(mb_left)) {
        var _r = ui_confirmacao_rects();
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);

        if (demo_hover_rect(_mx, _my, _r.Sim.X, _r.Sim.Y, _r.Sim.W, _r.Sim.H)) {
            return "sim";
        }

        if (demo_hover_rect(_mx, _my, _r.Nao.X, _r.Nao.Y, _r.Nao.W, _r.Nao.H)) {
            return "nao";
        }
    }

    return "";
}

function ui_confirmacao_draw() {
    if (!ui_confirmacao_ativa()) {
        return;
    }

    var _c = global.ui_confirmacao;
    var _r = ui_confirmacao_rects();
    var _p = _r.Painel;
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);

    ui_fundo_escurecido(0.55);
    ui_painel_papel(_p.X, _p.Y, _p.W, _p.H);
    ui_painel_titulo(_p.X, _p.Y, _p.W, _c.Titulo);
    battle_ui_font_body();
    draw_set_color(ui_cor("tinta"));
    ui_texto_bloco(_p.X + 30, _p.Y + 62, _c.Texto, 24, _p.W - 60, 3, 1);
    battle_ui_font_title();
    demo_draw_choice_button(_c.Sim, "", _r.Sim.X, _r.Sim.Y, _r.Sim.W, _r.Sim.H, demo_hover_rect(_mx, _my, _r.Sim.X, _r.Sim.Y, _r.Sim.W, _r.Sim.H));
    demo_draw_choice_button("Cancelar", "", _r.Nao.X, _r.Nao.Y, _r.Nao.W, _r.Nao.H, demo_hover_rect(_mx, _my, _r.Nao.X, _r.Nao.Y, _r.Nao.W, _r.Nao.H));
}

// Botoes fixos da cidade.
function demo_cidade_botao_mochila_rect() {
    return { X: 36, Y: display_get_gui_height() - 96, W: 210, H: 58 };
}

function demo_cidade_botao_menu_rect() {
    return { X: 262, Y: display_get_gui_height() - 96, W: 150, H: 58 };
}

function demo_cidade_abrir_pausa() {
    ui_confirmacao_abrir("sair", "PAUSA", "A run fica salva nesta cidade e volta pelo botao CONTINUAR. Voltar ao menu inicial?", "Sair para o menu");
}
