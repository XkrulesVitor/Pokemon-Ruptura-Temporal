// Placeholders procedurais.
// Aparecem enquanto a arte original nao existe. Para trocar por arte de verdade, basta
// colocar o PNG na pasta indicada (veja docs/como_adicionar_artes.txt): o jogo
// sempre procura o arquivo primeiro e so desenha o placeholder quando ele nao existe.
// Cada chamada devolve um sprite novo; quem chama e dono dele (pode dar sprite_delete).

function placeholder_hash(_n) {
    // Hash inteiro simples, deterministico, sem tocar no RNG global do jogo.
    var _h = (floor(abs(_n)) * 2654435761) mod 4294967296;
    _h = ((_h div 65536) + (_h * 31)) mod 4294967296;
    return _h;
}

function placeholder_hash_texto(_texto) {
    var _h = 7;
    var _s = string(_texto);

    for (var _i = 1; _i <= string_length(_s); _i += 1) {
        _h = (_h * 31 + ord(string_char_at(_s, _i))) mod 1000003;
    }

    return _h;
}

function placeholder_estado_salvar() {
    return { Cor: draw_get_color(), Alpha: draw_get_alpha() };
}

function placeholder_estado_restaurar(_estado) {
    draw_set_color(_estado.Cor);
    draw_set_alpha(_estado.Alpha);
}

function placeholder_finalizar(_surf, _w, _h, _xorig, _yorig, _estado) {
    surface_reset_target();
    var _spr = sprite_create_from_surface(_surf, 0, 0, _w, _h, false, false, _xorig, _yorig);
    surface_free(_surf);
    placeholder_estado_restaurar(_estado);
    return _spr;
}

function placeholder_cor_cromatica(_cor) {
    var _hue = (color_get_hue(_cor) + 70) mod 256;
    return make_color_hsv(_hue, min(255, color_get_saturation(_cor) + 30), min(255, color_get_value(_cor) + 25));
}

// Criatura: corpo pela cor do tipo 1, detalhes pela cor do tipo 2, tamanho pelo estagio
// e silhueta pelo papel (tanque, veloz, muralha...). Pose "back" desenha sem rosto.
function placeholder_criatura_sprite(_id, _pose, _cromatico) {
    var _info = criatura_info(_id);
    var _t1 = is_struct(_info) ? _info.Tipo1 : PokemonTipo.NORMAL;
    var _t2 = is_struct(_info) ? _info.Tipo2 : PokemonTipo.NONE;
    var _estagio = is_struct(_info) ? clamp(_info.Estagio, 1, 3) : 1;
    var _papel = is_struct(_info) ? _info.Papel : "equilibrado";
    var _lendario = is_struct(_info) && _info.Raridade >= PokemonRaridade.LEGENDARY;
    var _icone = (_pose == "icon");
    var _costas = (_pose == "back");
    var _tam = _icone ? 40 : 96;
    var _s = _tam / 96;
    var _estado = placeholder_estado_salvar();
    var _surf = surface_create(_tam, _tam);

    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);
    draw_set_alpha(1);

    var _cor = battle_ui_type_color(_t1);
    var _cor2 = _t2 != PokemonTipo.NONE ? battle_ui_type_color(_t2) : merge_color(_cor, c_white, 0.45);

    if (_cromatico) {
        _cor = placeholder_cor_cromatica(_cor);
        _cor2 = placeholder_cor_cromatica(_cor2);
    }

    var _contorno = merge_color(_cor, c_black, 0.55);
    var _h = placeholder_hash(_id);
    var _rx = (18 + (_estagio * 6)) * _s;
    var _ry = (15 + (_estagio * 6)) * _s;

    switch (_papel) {
        case "tanque": _rx *= 1.18; _ry *= 0.94; break;
        case "veloz": _rx *= 0.84; _ry *= 1.10; break;
        case "muralha": _rx *= 1.10; _ry *= 1.02; break;
        case "vidro": _rx *= 0.80; _ry *= 1.14; break;
        case "bruto": _rx *= 1.10; _ry *= 1.08; break;
    }

    if (_lendario) {
        _rx *= 1.08;
        _ry *= 1.08;
    }

    var _cx = _tam * 0.5;
    var _cy = _tam - _ry - (5 * _s);

    // Aura dos lendarios.
    if (_lendario) {
        draw_set_alpha(0.35);
        draw_set_color(_cor2);
        draw_circle(_cx, _cy, max(_rx, _ry) + (6 * _s), false);
        draw_set_alpha(1);
    }

    // Apendices (orelhas, chifres ou cristas) variam pelo hash da especie.
    var _apendice = _h mod 4;
    var _topo = _cy - _ry;
    draw_set_color(_contorno);

    for (var _lado = -1; _lado <= 1; _lado += 2) {
        var _bx = _cx + (_lado * _rx * 0.55);

        switch (_apendice) {
            case 0: // orelhas pontudas
                draw_triangle(_bx - (7 * _s), _topo + (8 * _s), _bx + (7 * _s), _topo + (8 * _s), _bx + (_lado * 4 * _s), _topo - (14 * _s), false);
                draw_set_color(_cor2);
                draw_triangle(_bx - (4 * _s), _topo + (7 * _s), _bx + (4 * _s), _topo + (7 * _s), _bx + (_lado * 3 * _s), _topo - (8 * _s), false);
                draw_set_color(_contorno);
                break;
            case 1: // chifres
                draw_set_color(_cor2);
                draw_triangle(_bx - (3 * _s), _topo + (6 * _s), _bx + (3 * _s), _topo + (6 * _s), _bx + (_lado * 9 * _s), _topo - (12 * _s), false);
                draw_set_color(_contorno);
                break;
            case 2: // orelhas redondas
                draw_circle(_bx, _topo + (2 * _s), 8 * _s, false);
                draw_set_color(_cor2);
                draw_circle(_bx, _topo + (2 * _s), 5 * _s, false);
                draw_set_color(_contorno);
                break;
            case 3: // antenas
                draw_line_width(_bx, _topo + (6 * _s), _bx + (_lado * 6 * _s), _topo - (12 * _s), max(1, 2 * _s));
                draw_set_color(_cor2);
                draw_circle(_bx + (_lado * 6 * _s), _topo - (12 * _s), 3.5 * _s, false);
                draw_set_color(_contorno);
                break;
        }
    }

    // Cauda para estagios evoluidos.
    if (_estagio >= 2 && !_icone) {
        draw_set_color(_cor2);
        var _cauda_dir = (_h mod 2 == 0) ? 1 : -1;
        draw_triangle(_cx + (_cauda_dir * _rx * 0.6), _cy + (_ry * 0.2), _cx + (_cauda_dir * _rx * 0.6), _cy - (_ry * 0.25), _cx + (_cauda_dir * (_rx + (16 * _s))), _cy - (_ry * 0.75), false);
    }

    // Corpo com contorno.
    draw_set_color(_contorno);
    if (_papel == "muralha") {
        draw_roundrect_ext(_cx - _rx - (2 * _s), _cy - _ry - (2 * _s), _cx + _rx + (2 * _s), _cy + _ry + (2 * _s), 18 * _s, 18 * _s, false);
        draw_set_color(_cor);
        draw_roundrect_ext(_cx - _rx, _cy - _ry, _cx + _rx, _cy + _ry, 16 * _s, 16 * _s, false);
    } else {
        draw_ellipse(_cx - _rx - (2 * _s), _cy - _ry - (2 * _s), _cx + _rx + (2 * _s), _cy + _ry + (2 * _s), false);
        draw_set_color(_cor);
        draw_ellipse(_cx - _rx, _cy - _ry, _cx + _rx, _cy + _ry, false);
    }

    // Brilho e barriga.
    draw_set_alpha(0.35);
    draw_set_color(c_white);
    draw_ellipse(_cx - (_rx * 0.65), _cy - (_ry * 0.85), _cx - (_rx * 0.05), _cy - (_ry * 0.35), false);
    draw_set_alpha(1);

    if (!_costas) {
        draw_set_color(_cor2);
        draw_ellipse(_cx - (_rx * 0.5), _cy - (_ry * 0.05), _cx + (_rx * 0.5), _cy + (_ry * 0.85), false);

        // Olhos.
        var _olho_y = _cy - (_ry * 0.32);
        var _olho_dx = _rx * 0.36;
        var _olho_r = max(1.5, 5.2 * _s);

        for (var _o = -1; _o <= 1; _o += 2) {
            draw_set_color(c_white);
            draw_circle(_cx + (_o * _olho_dx), _olho_y, _olho_r, false);
            draw_set_color(make_color_rgb(24, 22, 34));
            draw_circle(_cx + (_o * _olho_dx) + (1.2 * _s), _olho_y + (0.6 * _s), _olho_r * 0.55, false);
        }
    } else {
        // Costas: listra no dorso com a cor secundaria.
        draw_set_color(_cor2);
        draw_ellipse(_cx - (_rx * 0.22), _cy - (_ry * 0.8), _cx + (_rx * 0.22), _cy + (_ry * 0.5), false);
    }

    // Pezinhos.
    draw_set_color(_contorno);
    draw_ellipse(_cx - (_rx * 0.75), _cy + (_ry * 0.72), _cx - (_rx * 0.25), _cy + _ry + (3 * _s), false);
    draw_ellipse(_cx + (_rx * 0.25), _cy + (_ry * 0.72), _cx + (_rx * 0.75), _cy + _ry + (3 * _s), false);

    return placeholder_finalizar(_surf, _tam, _tam, _tam * 0.5, _icone ? _tam * 0.5 : _tam, _estado);
}

// Retrato de treinador/NPC: silhueta com cor derivada do nome.
function placeholder_treinador_sprite(_nome) {
    var _w = 96;
    var _h = 160;
    var _hash = placeholder_hash_texto(_nome);
    var _cor_roupa = make_color_hsv(_hash mod 256, 150, 190);
    var _cor_detalhe = make_color_hsv((_hash div 7) mod 256, 120, 230);
    var _pele = merge_color(make_color_rgb(236, 196, 160), make_color_rgb(140, 96, 70), ((_hash div 13) mod 100) / 100);
    var _estado = placeholder_estado_salvar();
    var _surf = surface_create(_w, _h);

    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);
    draw_set_alpha(1);

    var _cx = _w * 0.5;
    var _contorno = make_color_rgb(30, 28, 40);

    // Pernas.
    draw_set_color(merge_color(_cor_roupa, c_black, 0.45));
    draw_rectangle(_cx - 18, 118, _cx - 4, 156, false);
    draw_rectangle(_cx + 4, 118, _cx + 18, 156, false);

    // Tronco.
    draw_set_color(_contorno);
    draw_roundrect_ext(_cx - 30, 58, _cx + 30, 124, 16, 16, false);
    draw_set_color(_cor_roupa);
    draw_roundrect_ext(_cx - 27, 61, _cx + 27, 121, 14, 14, false);
    draw_set_color(_cor_detalhe);
    draw_rectangle(_cx - 27, 88, _cx + 27, 96, false);

    // Cabeca e cabelo/chapeu.
    draw_set_color(_contorno);
    draw_circle(_cx, 38, 24, false);
    draw_set_color(_pele);
    draw_circle(_cx, 39, 21, false);
    draw_set_color(merge_color(_cor_detalhe, c_black, 0.35));

    if ((_hash mod 2) == 0) {
        draw_roundrect_ext(_cx - 24, 12, _cx + 24, 30, 10, 10, false);
        draw_rectangle(_cx - 30, 26, _cx + 30, 31, false);
    } else {
        draw_ellipse(_cx - 23, 14, _cx + 23, 36, false);
    }

    draw_set_color(_contorno);
    draw_circle(_cx - 8, 41, 2.5, false);
    draw_circle(_cx + 8, 41, 2.5, false);

    return placeholder_finalizar(_surf, _w, _h, _w * 0.5, _h, _estado);
}

// Folha 4x4 do personagem andando pelo mapa (linhas: baixo, esquerda, direita, cima).
function placeholder_andarilho_folha() {
    var _fw = 32;
    var _fh = 48;
    var _w = _fw * 4;
    var _h = _fh * 4;
    var _estado = placeholder_estado_salvar();
    var _surf = surface_create(_w, _h);

    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);
    draw_set_alpha(1);

    for (var _row = 0; _row < 4; _row += 1) {
        for (var _frame = 0; _frame < 4; _frame += 1) {
            var _ox = _frame * _fw;
            var _oy = _row * _fh;
            var _cx = _ox + (_fw * 0.5);
            var _passo = (_frame mod 2 == 1) ? ((_frame == 1) ? -3 : 3) : 0;

            draw_set_color(make_color_rgb(40, 52, 92));
            draw_rectangle(_cx - 7 + _passo, _oy + 34, _cx - 2 + _passo, _oy + 45, false);
            draw_rectangle(_cx + 2 - _passo, _oy + 34, _cx + 7 - _passo, _oy + 45, false);
            draw_set_color(make_color_rgb(32, 30, 44));
            draw_roundrect_ext(_cx - 10, _oy + 18, _cx + 10, _oy + 38, 6, 6, false);
            draw_set_color(make_color_rgb(64, 156, 136));
            draw_roundrect_ext(_cx - 8, _oy + 20, _cx + 8, _oy + 36, 5, 5, false);
            draw_set_color(make_color_rgb(32, 30, 44));
            draw_circle(_cx, _oy + 12, 9, false);
            draw_set_color(make_color_rgb(236, 200, 166));
            draw_circle(_cx, _oy + 12, 7.5, false);
            draw_set_color(make_color_rgb(232, 168, 56));
            draw_roundrect_ext(_cx - 9, _oy + 2, _cx + 9, _oy + 9, 4, 4, false);

            if (_row != 3) {
                var _olho_dx = (_row == 1) ? -3 : ((_row == 2) ? 3 : 0);
                draw_set_color(make_color_rgb(32, 30, 44));
                draw_rectangle(_cx - 3 + _olho_dx, _oy + 12, _cx - 2 + _olho_dx, _oy + 14, false);
                draw_rectangle(_cx + 2 + _olho_dx, _oy + 12, _cx + 3 + _olho_dx, _oy + 14, false);
            }
        }
    }

    return placeholder_finalizar(_surf, _w, _h, 0, 0, _estado);
}

// Mapa de cidade visto de cima: chao, ruas, casas e arvores. Cada cidade tem sua paleta.
function placeholder_cidade_sprite(_indice, _nome) {
    var _w = 768;
    var _h = 413;
    var _paletas = [
        [make_color_rgb(110, 178, 96), make_color_rgb(214, 196, 140)],
        [make_color_rgb(98, 164, 150), make_color_rgb(208, 200, 170)],
        [make_color_rgb(150, 148, 132), make_color_rgb(196, 182, 150)],
        [make_color_rgb(96, 160, 186), make_color_rgb(224, 214, 176)],
        [make_color_rgb(128, 150, 110), make_color_rgb(188, 186, 176)],
        [make_color_rgb(170, 120, 86), make_color_rgb(214, 170, 120)],
        [make_color_rgb(96, 84, 112), make_color_rgb(150, 140, 150)]
    ];
    var _pal = _paletas[clamp(_indice, 0, array_length(_paletas) - 1)];
    var _estado = placeholder_estado_salvar();
    var _surf = surface_create(_w, _h);

    surface_set_target(_surf);
    draw_clear_alpha(_pal[0], 1);
    draw_set_alpha(1);

    // Textura leve do chao.
    for (var _t = 0; _t < 260; _t += 1) {
        var _hx = placeholder_hash(_t * 3 + _indice * 1000);
        draw_set_color(merge_color(_pal[0], (_t mod 2 == 0) ? c_white : c_black, 0.08));
        draw_rectangle(_hx mod _w, (_hx div _w) mod _h, (_hx mod _w) + 3, ((_hx div _w) mod _h) + 2, false);
    }

    // Ruas em cruz.
    draw_set_color(_pal[1]);
    draw_rectangle(0, _h * 0.52, _w, (_h * 0.52) + 34, false);
    draw_rectangle(_w * 0.46, 0, (_w * 0.46) + 34, _h, false);
    draw_set_color(merge_color(_pal[1], c_black, 0.15));
    draw_rectangle(0, (_h * 0.52) + 30, _w, (_h * 0.52) + 34, false);

    // Casas.
    var _telhados = [make_color_rgb(196, 78, 66), make_color_rgb(70, 116, 196), make_color_rgb(84, 150, 90), make_color_rgb(214, 160, 60), make_color_rgb(140, 90, 170)];
    var _casas = [[0.10, 0.16], [0.26, 0.20], [0.62, 0.14], [0.80, 0.22], [0.12, 0.70], [0.30, 0.74], [0.64, 0.70], [0.82, 0.74]];

    for (var _c = 0; _c < array_length(_casas); _c += 1) {
        var _bx = _casas[_c][0] * _w;
        var _by = _casas[_c][1] * _h;
        var _cw = 72 + ((placeholder_hash(_c + _indice * 17) mod 3) * 12);
        var _ch = 54;
        draw_set_color(make_color_rgb(40, 36, 44));
        draw_rectangle(_bx - 2, _by - 2, _bx + _cw + 2, _by + _ch + 2, false);
        draw_set_color(make_color_rgb(226, 220, 206));
        draw_rectangle(_bx, _by + 18, _bx + _cw, _by + _ch, false);
        draw_set_color(_telhados[(_c + _indice) mod array_length(_telhados)]);
        draw_rectangle(_bx, _by, _bx + _cw, _by + 20, false);
        draw_set_color(make_color_rgb(110, 78, 56));
        draw_rectangle(_bx + (_cw * 0.5) - 6, _by + 36, _bx + (_cw * 0.5) + 6, _by + _ch, false);
        draw_set_color(make_color_rgb(140, 190, 230));
        draw_rectangle(_bx + 8, _by + 26, _bx + 20, _by + 36, false);
        draw_rectangle(_bx + _cw - 20, _by + 26, _bx + _cw - 8, _by + 36, false);
    }

    // Arvores nas bordas.
    for (var _a = 0; _a < 22; _a += 1) {
        var _ha = placeholder_hash(_a * 11 + _indice * 101);
        var _ax = (_a mod 2 == 0) ? (_ha mod 60) + 10 : _w - 70 + (_ha mod 60);
        var _ay = 20 + ((_ha div 7) mod (_h - 40));
        draw_set_color(make_color_rgb(34, 70, 40));
        draw_circle(_ax, _ay, 15, false);
        draw_set_color(merge_color(_pal[0], make_color_rgb(30, 110, 50), 0.6));
        draw_circle(_ax - 2, _ay - 2, 12, false);
    }

    return placeholder_finalizar(_surf, _w, _h, 0, 0, _estado);
}

// Icone de item 32x32 conforme a categoria.
function placeholder_item_sprite(_id_item) {
    var _item = demo_item_get(_id_item);
    var _tipo = is_struct(_item) ? _item.Tipo : "";
    var _tam = 32;
    var _estado = placeholder_estado_salvar();
    var _surf = surface_create(_tam, _tam);
    var _contorno = make_color_rgb(32, 30, 44);

    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);
    draw_set_alpha(1);

    switch (_tipo) {
        case "captura":
            var _cor_cap = make_color_rgb(70, 190, 200);
            switch (_id_item) {
                case "great_ball": _cor_cap = make_color_rgb(90, 120, 230); break;
                case "ultra_ball": _cor_cap = make_color_rgb(230, 190, 60); break;
                case "master_ball": _cor_cap = make_color_rgb(170, 80, 210); break;
            }
            draw_set_color(_contorno);
            draw_roundrect_ext(5, 9, 27, 25, 8, 8, false);
            draw_set_color(_cor_cap);
            draw_roundrect_ext(7, 11, 16, 23, 6, 6, false);
            draw_set_color(make_color_rgb(236, 236, 228));
            draw_roundrect_ext(16, 11, 25, 23, 6, 6, false);
            draw_set_color(_contorno);
            draw_rectangle(15, 10, 17, 24, false);
            break;

        case "cura":
        case "cura_status":
        case "status":
            var _cor_liq = make_color_rgb(220, 80, 90);
            if (_tipo == "status") _cor_liq = make_color_rgb(90, 200, 120);
            if (_tipo == "cura_status") _cor_liq = make_color_rgb(240, 200, 80);
            draw_set_color(_contorno);
            draw_roundrect_ext(8, 10, 24, 29, 6, 6, false);
            draw_rectangle(12, 4, 20, 11, false);
            draw_set_color(_cor_liq);
            draw_roundrect_ext(10, 14, 22, 27, 5, 5, false);
            draw_set_color(make_color_rgb(180, 140, 100));
            draw_rectangle(13, 5, 19, 9, false);
            break;

        case "berry":
        case "cooldown":
            var _cor_fruta = make_color_rgb(80, 120, 220);
            if (_id_item == "cheri_berry") _cor_fruta = make_color_rgb(220, 70, 70);
            if (_id_item == "leppa_berry") _cor_fruta = make_color_rgb(230, 150, 50);
            draw_set_color(_contorno);
            draw_circle(16, 18, 10, false);
            draw_set_color(_cor_fruta);
            draw_circle(16, 18, 8, false);
            draw_set_color(make_color_rgb(70, 150, 70));
            draw_triangle(16, 9, 22, 4, 24, 9, false);
            break;

        default:
            draw_set_color(_contorno);
            draw_triangle(16, 3, 27, 16, 16, 29, false);
            draw_triangle(16, 3, 5, 16, 16, 29, false);
            draw_set_color(make_color_rgb(140, 220, 240));
            draw_triangle(16, 6, 24, 16, 16, 26, false);
            draw_triangle(16, 6, 8, 16, 16, 26, false);
            break;
    }

    return placeholder_finalizar(_surf, _tam, _tam, _tam * 0.5, _tam * 0.5, _estado);
}
