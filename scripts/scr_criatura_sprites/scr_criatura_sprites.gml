function project_asset_join(_base, _relative) {
    if (_base == "") {
        return _relative;
    }

    var _last = string_char_at(_base, string_length(_base));

    if (_last == "/" || _last == "\\") {
        return _base + _relative;
    }

    return _base + "/" + _relative;
}

// Somente arte original/autoral e dados do jogo sao carregados.
// Arte de terceiros (pastas antigas e asset_library) fica de fora de proposito.
function project_asset_permitido(_relative) {
    var _r = string_lower(string_replace_all(string(_relative), "\\", "/"));

    if (string_pos("datafiles/", _r) == 1) {
        _r = string_delete(_r, 1, string_length("datafiles/"));
    }

    static _permitidos = [
        "data/",
        "fonts_jogo/",
        "sprites/criaturas/",
        "sprites/treinadores/",
        "sprites/itens/",
        "sprites/cidades/",
        "sprites/interface/",
        "sprites/efeitos/",
        "sprites/cutscene/",
        "sprites/overworld/routes/"
    ];

    for (var _i = 0; _i < array_length(_permitidos); _i += 1) {
        if (string_pos(_permitidos[_i], _r) == 1) {
            return true;
        }
    }

    return false;
}

function project_asset_path(_relative) {
    var _rel = string_replace_all(string(_relative), "\\", "/");

    if (!project_asset_permitido(_rel)) {
        return "";
    }

    var _runtime_rel = _rel;

    if (string_pos("datafiles/", _runtime_rel) == 1) {
        _runtime_rel = string_delete(_runtime_rel, 1, string_length("datafiles/"));
    }

    // Included Files ficam na raiz do working_directory em tempo de execucao.
    if (file_exists(_runtime_rel)) {
        return _runtime_rel;
    }

    var _candidates = [
        _rel,
        project_asset_join(working_directory, _runtime_rel),
        project_asset_join(working_directory, _rel),
        project_asset_join(program_directory, _runtime_rel),
        project_asset_join(program_directory, "datafiles/" + _runtime_rel)
    ];

    for (var _i = 0; _i < array_length(_candidates); _i += 1) {
        if (file_exists(_candidates[_i])) {
            return _candidates[_i];
        }
    }

    return "";
}

function criatura_sprite_nome_canonico(_criatura_id) {
    var _info = criatura_info(_criatura_id);

    if (is_struct(_info)) {
        return string_lower(string_replace_all(_info.Nome, " ", "_"));
    }

    return "";
}

function criatura_sprite_essentials_folder(_pose) {
    // Mantida por compatibilidade: as poses agora usam sufixo no nome do arquivo.
    return _pose == "back" ? "costas" : "frente";
}

// Procura a arte original da criatura em datafiles/sprites/criaturas/.
// Nomes aceitos (o primeiro que existir vence):
//   <id>_<pose>.png, <nome>_<pose>.png, <id>.png, <nome>.png
//   variantes: cromatico/<...>, costas/<...> (pose back)
// Tambem aceita o campo "sprite" do criaturas.json.
function criatura_sprite_path(_criatura_id, _sufixo) {
    if (argument_count < 2 || is_undefined(_sufixo)) {
        _sufixo = "";
    }

    _sufixo = string(_sufixo);
    var _is_shiny = argument_count >= 3 ? argument[2] : false;
    var _pose = _sufixo == "" ? "" : string_delete(_sufixo, 1, 1);
    var _info = criatura_info(_criatura_id);
    var _nomes = [string(_criatura_id)];
    var _nome = criatura_sprite_nome_canonico(_criatura_id);

    if (_nome != "") {
        array_push(_nomes, _nome);
    }

    var _pastas = [];

    if (_is_shiny) {
        array_push(_pastas, _pose == "back" ? "datafiles/sprites/criaturas/cromatico/costas/" : "datafiles/sprites/criaturas/cromatico/");
    }

    array_push(_pastas, _pose == "back" ? "datafiles/sprites/criaturas/costas/" : "datafiles/sprites/criaturas/");
    var _candidates = [];

    if (is_struct(_info) && _info.Sprite != "" && _pose != "back") {
        array_push(_candidates, "datafiles/sprites/criaturas/" + _info.Sprite);
    }

    for (var _p = 0; _p < array_length(_pastas); _p += 1) {
        for (var _n = 0; _n < array_length(_nomes); _n += 1) {
            if (_pose != "" && _pose != "back") {
                array_push(_candidates, _pastas[_p] + _nomes[_n] + "_" + _pose + ".png");
            }

            array_push(_candidates, _pastas[_p] + _nomes[_n] + ".png");
        }
    }

    for (var _i = 0; _i < array_length(_candidates); _i += 1) {
        var _path = project_asset_path(_candidates[_i]);

        if (_path != "") {
            return _path;
        }
    }

    return "";
}

function criatura_sprite_carregar(_criatura_id, _sprite_antigo) {
    if (argument_count < 2) {
        _sprite_antigo = -1;
    }

    var _is_shiny = argument_count >= 3 ? argument[2] : false;
    return criatura_sprite_carregar_pose(_criatura_id, "front", _sprite_antigo, _is_shiny);
}

function criatura_sprite_carregar_pose(_criatura_id, _pose, _sprite_antigo) {
    if (argument_count < 3) {
        _sprite_antigo = -1;
    }

    var _is_shiny = argument_count >= 4 ? argument[3] : false;
    var _path = criatura_sprite_path(_criatura_id, "_" + _pose, _is_shiny);

    if (_path == "" && _pose != "back") {
        _path = criatura_sprite_path(_criatura_id, "", _is_shiny);
    }

    if (sprite_exists(_sprite_antigo)) {
        sprite_delete(_sprite_antigo);
    }

    var _sprite = -1;

    if (_path != "") {
        _sprite = sprite_add(_path, 1, false, false, 0, 0);
    }

    if (!sprite_exists(_sprite)) {
        // Sem arte ainda: desenha um placeholder pelo tipo/estagio da criatura.
        return placeholder_criatura_sprite(_criatura_id, _pose == "back" ? "back" : "front", _is_shiny);
    }

    sprite_set_offset(_sprite, sprite_get_width(_sprite) * 0.5, sprite_get_height(_sprite));
    return _sprite;
}

function criatura_sprite_liberar_array(_sprites) {
    for (var _i = 0; _i < array_length(_sprites); _i += 1) {
        criatura_sprite_liberar(_sprites[_i]);
    }
}

function criatura_sprite_liberar(_sprite_dynamic) {
    if (sprite_exists(_sprite_dynamic)) {
        sprite_delete(_sprite_dynamic);
    }
}
