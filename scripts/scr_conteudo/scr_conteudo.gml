// Conteudo original do jogo, carregado de datafiles/data/*.json.
// criaturas.json -> roster (gerado por tools/gerar_conteudo.py)
// mundo.json     -> regiao, cidades, lideres, viloes e personagens

function conteudo_tipo_de_texto(_texto) {
    switch (string_lower(string(_texto))) {
        case "normal": return CriaturaTipo.NORMAL;
        case "fogo": return CriaturaTipo.FIRE;
        case "agua": return CriaturaTipo.WATER;
        case "grama": return CriaturaTipo.GRASS;
        case "eletrico": return CriaturaTipo.ELECTRIC;
        case "gelo": return CriaturaTipo.ICE;
        case "lutador": return CriaturaTipo.FIGHTING;
        case "veneno": return CriaturaTipo.POISON;
        case "terra": return CriaturaTipo.GROUND;
        case "voador": return CriaturaTipo.FLYING;
        case "psiquico": return CriaturaTipo.PSYCHIC;
        case "inseto": return CriaturaTipo.BUG;
        case "pedra": return CriaturaTipo.ROCK;
        case "fantasma": return CriaturaTipo.GHOST;
        case "dragao": return CriaturaTipo.DRAGON;
        case "sombrio": return CriaturaTipo.DARK;
        case "aco": return CriaturaTipo.STEEL;
        case "fada": return CriaturaTipo.FAIRY;
    }

    return CriaturaTipo.NONE;
}

function conteudo_raridade_de_texto(_texto) {
    switch (string_lower(string(_texto))) {
        case "incomum": return CriaturaRaridade.UNCOMMON;
        case "raro": return CriaturaRaridade.RARE;
        case "epico": return CriaturaRaridade.EPIC;
        case "lendario": return CriaturaRaridade.LEGENDARY;
        case "ultra_raro": return CriaturaRaridade.ULTRA_RARE;
    }

    return CriaturaRaridade.COMMON;
}

function conteudo_ler_json(_relativo) {
    var _path = project_asset_path(_relativo);

    if (_path == "") {
        show_debug_message("[conteudo] arquivo nao encontrado: " + _relativo);
        return undefined;
    }

    var _buffer = buffer_load(_path);

    if (_buffer < 0) {
        show_debug_message("[conteudo] falha ao ler: " + _path);
        return undefined;
    }

    var _texto = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer);

    try {
        return json_parse(_texto);
    } catch (_erro) {
        show_debug_message("[conteudo] JSON invalido em " + _path + ": " + string(_erro));
    }

    return undefined;
}

function conteudo_struct_get(_struct, _chave, _padrao) {
    if (is_struct(_struct) && variable_struct_exists(_struct, _chave)) {
        var _valor = variable_struct_get(_struct, _chave);

        if (!is_undefined(_valor)) {
            return _valor;
        }
    }

    return _padrao;
}

function conteudo_garantir() {
    if (variable_global_exists("conteudo") && is_struct(global.conteudo)) {
        return global.conteudo;
    }

    var _conteudo = {
        Criaturas: {},
        PorNome: {},
        Ids: [],
        Evolucoes: [],
        Pacotes: {},
        Mundo: undefined
    };

    var _json = conteudo_ler_json("datafiles/data/criaturas.json");
    var _lista = conteudo_struct_get(_json, "criaturas", []);

    for (var _i = 0; _i < array_length(_lista); _i += 1) {
        var _c = _lista[_i];
        var _id = floor(conteudo_struct_get(_c, "id", 0));

        if (_id <= 0) {
            continue;
        }

        var _info = {
            ID: _id,
            Nome: string(conteudo_struct_get(_c, "nome", "Criatura " + string(_id))),
            Tipo1: conteudo_tipo_de_texto(conteudo_struct_get(_c, "tipo1", "normal")),
            Tipo2: conteudo_tipo_de_texto(conteudo_struct_get(_c, "tipo2", "")),
            Raridade: conteudo_raridade_de_texto(conteudo_struct_get(_c, "raridade", "comum")),
            Papel: string(conteudo_struct_get(_c, "papel", "equilibrado")),
            Hp: conteudo_struct_get(_c, "hp", 45),
            Attack: conteudo_struct_get(_c, "ataque", 45),
            Defense: conteudo_struct_get(_c, "defesa", 45),
            Speed: conteudo_struct_get(_c, "velocidade", 45),
            Estagio: floor(conteudo_struct_get(_c, "estagio", 1)),
            EvoluiDe: floor(conteudo_struct_get(_c, "evolui_de", 0)),
            NivelEvolucao: floor(conteudo_struct_get(_c, "nivel_evolucao", 0)),
            Sprite: string(conteudo_struct_get(_c, "sprite", ""))
        };

        if (_info.Tipo1 == CriaturaTipo.NONE) {
            _info.Tipo1 = CriaturaTipo.NORMAL;
        }

        variable_struct_set(_conteudo.Criaturas, string(_id), _info);
        variable_struct_set(_conteudo.PorNome, string_lower(_info.Nome), _id);
        array_push(_conteudo.Ids, _id);

        if (_info.EvoluiDe > 0) {
            array_push(_conteudo.Evolucoes, { From: _info.EvoluiDe, To: _id, Level: max(2, _info.NivelEvolucao) });
        }
    }

    array_sort(_conteudo.Ids, true);

    var _pacotes = conteudo_struct_get(_json, "pacotes_iniciais", {});

    if (is_struct(_pacotes)) {
        var _chaves = variable_struct_get_names(_pacotes);

        for (var _p = 0; _p < array_length(_chaves); _p += 1) {
            var _pacote = variable_struct_get(_pacotes, _chaves[_p]);
            variable_struct_set(_conteudo.Pacotes, _chaves[_p], {
                Nome: string(conteudo_struct_get(_pacote, "nome", _chaves[_p])),
                Ids: conteudo_struct_get(_pacote, "ids", [])
            });
        }
    }

    _conteudo.Mundo = conteudo_ler_json("datafiles/data/mundo.json");

    if (array_length(_conteudo.Ids) <= 0) {
        show_error("Nao foi possivel carregar datafiles/data/criaturas.json. Rode tools/gerar_conteudo.py e confira os Included Files.", true);
    }

    global.conteudo = _conteudo;
    return _conteudo;
}

function criatura_ids() {
    return conteudo_garantir().Ids;
}

function criatura_info(_id) {
    var _criaturas = conteudo_garantir().Criaturas;
    var _chave = string(_id);

    if (variable_struct_exists(_criaturas, _chave)) {
        return variable_struct_get(_criaturas, _chave);
    }

    return undefined;
}

function criatura_id_por_nome(_nome) {
    var _por_nome = conteudo_garantir().PorNome;
    var _chave = string_lower(string(_nome));

    if (variable_struct_exists(_por_nome, _chave)) {
        return variable_struct_get(_por_nome, _chave);
    }

    return 0;
}

function criatura_e_estagio_inicial(_id) {
    var _info = criatura_info(_id);
    return is_struct(_info) && _info.EvoluiDe <= 0;
}

function conteudo_pacote_iniciais(_chave) {
    var _pacotes = conteudo_garantir().Pacotes;

    if (variable_struct_exists(_pacotes, _chave)) {
        var _ids = variable_struct_get(_pacotes, _chave).Ids;
        var _copia = [];

        for (var _i = 0; _i < array_length(_ids); _i += 1) {
            array_push(_copia, floor(_ids[_i]));
        }

        return _copia;
    }

    return [];
}

function conteudo_pacote_nome(_chave) {
    var _pacotes = conteudo_garantir().Pacotes;

    if (variable_struct_exists(_pacotes, _chave)) {
        return variable_struct_get(_pacotes, _chave).Nome;
    }

    return _chave;
}

function conteudo_mundo_texto(_chave, _padrao) {
    return string(conteudo_struct_get(conteudo_garantir().Mundo, _chave, _padrao));
}

function conteudo_cidades() {
    var _mundo = conteudo_garantir().Mundo;
    return conteudo_struct_get(_mundo, "cidades", []);
}

// Arquivos de dados auxiliares (itens, rotas, treinadores), lidos uma vez e guardados.
function conteudo_dados(_nome) {
    if (!variable_global_exists("conteudo_dados_cache") || !is_struct(global.conteudo_dados_cache)) {
        global.conteudo_dados_cache = {};
    }

    if (!variable_struct_exists(global.conteudo_dados_cache, _nome)) {
        var _json = conteudo_ler_json("datafiles/data/" + _nome + ".json");

        if (!is_struct(_json)) {
            show_error("Nao foi possivel carregar datafiles/data/" + _nome + ".json.", true);
        }

        variable_struct_set(global.conteudo_dados_cache, _nome, _json);
    }

    return variable_struct_get(global.conteudo_dados_cache, _nome);
}
