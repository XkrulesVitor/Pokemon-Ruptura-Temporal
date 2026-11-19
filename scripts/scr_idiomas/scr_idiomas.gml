// Idiomas (Sprint 8). O texto do jogo e escrito em portugues; ao desenhar, i18n_t() troca pela
// traducao do idioma escolhido (datafiles/data/idiomas/<idioma>.json):
//   "exatos": a frase inteira; "trechos": pedacos dentro de frases montadas com nomes e numeros.
// Todas as chamadas de desenho/medicao de texto do jogo passam pelas funcoes i18n_* abaixo.

function idioma_atual() {
    return string(conteudo_struct_get(progresso(), "Idioma", "pt"));
}

function idioma_alternar() {
    var _p = progresso();
    _p.Idioma = idioma_atual() == "pt" ? "en" : "pt";
    progresso_salvar();
    global.i18n_dados = undefined;

    if (variable_global_exists("i18n_cache") && ds_exists(global.i18n_cache, ds_type_map)) {
        ds_map_clear(global.i18n_cache);
    }
}

function idioma_nome() {
    return idioma_atual() == "pt" ? "PORTUGUES" : "ENGLISH";
}

function idioma_dados() {
    if (!variable_global_exists("i18n_dados") || is_undefined(global.i18n_dados)) {
        var _json = conteudo_ler_json("datafiles/data/idiomas/" + idioma_atual() + ".json");
        global.i18n_dados = is_struct(_json) ? _json : {};
    }

    return global.i18n_dados;
}

function i18n_t(_texto) {
    if (!is_string(_texto) || _texto == "" || idioma_atual() == "pt") {
        return _texto;
    }

    if (!variable_global_exists("i18n_cache") || !ds_exists(global.i18n_cache, ds_type_map)) {
        global.i18n_cache = ds_map_create();
    }

    var _cache = global.i18n_cache;

    if (ds_map_exists(_cache, _texto)) {
        return _cache[? _texto];
    }

    var _dados = idioma_dados();
    var _exatos = conteudo_struct_get(_dados, "exatos", {});
    var _resultado = _texto;

    if (variable_struct_exists(_exatos, _texto)) {
        _resultado = variable_struct_get(_exatos, _texto);
    } else {
        var _trechos = conteudo_struct_get(_dados, "trechos", []);

        for (var _i = 0; _i < array_length(_trechos); _i += 1) {
            if (string_pos(_trechos[_i][0], _resultado) > 0) {
                _resultado = string_replace_all(_resultado, _trechos[_i][0], _trechos[_i][1]);
            }
        }
    }

    if (ds_map_size(_cache) > 6000) {
        ds_map_clear(_cache);
    }

    _cache[? _texto] = _resultado;
    return _resultado;
}

function i18n_draw_text(_x, _y, _texto) {
    draw_text(_x, _y, i18n_t(_texto));
}

function i18n_draw_text_ext(_x, _y, _texto, _sep, _w) {
    draw_text_ext(_x, _y, i18n_t(_texto), _sep, _w);
}

function i18n_draw_text_transformed(_x, _y, _texto, _xs, _ys, _ang) {
    draw_text_transformed(_x, _y, i18n_t(_texto), _xs, _ys, _ang);
}

function i18n_draw_text_ext_transformed(_x, _y, _texto, _sep, _w, _xs, _ys, _ang) {
    draw_text_ext_transformed(_x, _y, i18n_t(_texto), _sep, _w, _xs, _ys, _ang);
}

function i18n_string_width(_texto) {
    return string_width(i18n_t(_texto));
}

function i18n_string_height(_texto) {
    return string_height(i18n_t(_texto));
}

function i18n_string_height_ext(_texto, _sep, _w) {
    return string_height_ext(i18n_t(_texto), _sep, _w);
}
