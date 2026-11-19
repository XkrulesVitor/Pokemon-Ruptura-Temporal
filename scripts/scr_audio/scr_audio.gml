// Audio sintetizado (Sprint 8): efeitos chiptune e musicas em loop geradas no proprio jogo.
// Nada e baixado: as ondas sao calculadas em buffers PCM. Para trocar por arquivos de verdade,
// coloque datafiles/audio/<nome>.ogg (ex.: musica_batalha.ogg, sfx_golpe.ogg).
// As musicas sao geradas aos poucos (alguns milhares de amostras por frame) para nao travar a tela.

#macro AUDIO_TAXA 16000

function audio_garantir() {
    if (variable_global_exists("audio_estado") && is_struct(global.audio_estado)) {
        return global.audio_estado;
    }

    global.audio_estado = {
        Sons: {},
        Buffers: [],
        MusicaAtual: "",
        MusicaInst: -1,
        MusicaPedida: "",
        Job: undefined,
        Ruido: 22695477
    };

    return global.audio_estado;
}

// Modo de som salvo no progresso: 0 = tudo ligado, 1 = so efeitos, 2 = mudo.
function audio_modo() {
    return conteudo_struct_get(progresso(), "SomModo", 0);
}

function audio_modo_alternar() {
    var _p = progresso();
    _p.SomModo = (conteudo_struct_get(_p, "SomModo", 0) + 1) mod 3;
    progresso_salvar();

    var _a = audio_garantir();

    if (_p.SomModo != 0 && audio_exists(_a.MusicaInst)) {
        audio_stop_sound(_a.MusicaInst);
        _a.MusicaInst = -1;
        _a.MusicaAtual = "";
    }
}

function audio_modo_nome() {
    static _nomes = ["LIGADO", "SO EFEITOS", "MUDO"];
    return _nomes[clamp(audio_modo(), 0, 2)];
}

function audio_ruido(_a) {
    // LCG proprio em int64: nao mexe no RNG do jogo (importante para o Desafio Diario).
    _a.Ruido = (int64(_a.Ruido) * int64(1103515245) + int64(12345)) & int64(2147483647);
    return (real(_a.Ruido) / 1073741824) - 1;
}

function audio_onda(_tipo, _fase) {
    var _f = _fase - floor(_fase);

    switch (_tipo) {
        case 0: return _f < 0.5 ? 1 : -1;                  // quadrada
        case 1: return _f < 0.25 ? 1 : -1;                 // pulso fino
        case 2: return 1 - (4 * abs(_f - 0.5));            // triangulo
        case 3: return sin(_fase * 2 * pi);                // senoide
    }

    return 0;
}

function audio_nota_freq(_semitom) {
    // 0 = La 440 Hz.
    return 440 * power(2, _semitom / 12);
}

// Soma uma nota no acumulador (array de reais).
// Soma uma nota no acumulador (array de reais). Onda calculada direto no laco por desempenho.
function audio_render_nota(_acum, _ini, _dur, _freq, _tipo, _vol, _freq_fim) {
    var _a = audio_garantir();
    var _n = array_length(_acum);
    var _comeco = max(0, _ini);
    var _fim = min(_n, _ini + _dur);
    var _fase = 0;
    var _passo = _freq / AUDIO_TAXA;
    var _delta_passo = ((_freq_fim - _freq) / AUDIO_TAXA) / max(1, _dur);
    var _inv_dur = 1 / max(1, _dur);
    var _ataque = max(1, floor(AUDIO_TAXA * 0.004));

    for (var _i = _comeco; _i < _fim; _i += 1) {
        var _k = _i - _ini;
        var _t = _k * _inv_dur;
        _fase += _passo + (_delta_passo * _k);
        var _f = _fase - floor(_fase);
        var _v = 0;

        switch (_tipo) {
            case 0: _v = _f < 0.5 ? 1 : -1; break;
            case 1: _v = _f < 0.25 ? 1 : -1; break;
            case 2: _v = 1 - (4 * abs(_f - 0.5)); break;
            case 3: _v = sin(_fase * 6.283185); break;
            case 4: _v = audio_ruido(_a); break;
        }

        var _env = (1 - _t) * (1 - (_t * 0.3));
        if (_k < _ataque) _env *= _k / _ataque;
        _acum[@ _i] += _v * _vol * _env;
    }
}

function audio_acum_para_som(_acum, _loop) {
    var _a = audio_garantir();
    var _n = array_length(_acum);
    var _buf = buffer_create(_n * 2, buffer_fixed, 2);

    for (var _i = 0; _i < _n; _i += 1) {
        buffer_write(_buf, buffer_s16, round(clamp(_acum[_i], -1, 1) * 30000));
    }

    var _snd = audio_create_buffer_sound(_buf, buffer_s16, AUDIO_TAXA, 0, _n * 2, audio_mono);
    array_push(_a.Buffers, _buf);
    return _snd;
}

function audio_arquivo(_nome) {
    var _path = project_asset_path("datafiles/audio/" + _nome + ".ogg");
    return _path != "" ? audio_create_stream(_path) : -1;
}

// ------------------------------------------------------------------ efeitos

function audio_sfx_receita(_nome) {
    // [semitom, duracao_s, tipo_onda, volume, semitom_final, atraso_s]
    switch (_nome) {
        case "clique": return [[12, 0.035, 1, 0.35, 12, 0]];
        case "golpe": return [[-24, 0.09, 4, 0.55, -24, 0], [-33, 0.10, 3, 0.7, -40, 0]];
        case "combo": return [[3, 0.07, 0, 0.35, 3, 0], [7, 0.07, 0, 0.35, 7, 0.06], [12, 0.12, 0, 0.4, 12, 0.12], [-24, 0.12, 4, 0.4, -24, 0]];
        case "cura": return [[-5, 0.30, 3, 0.5, 14, 0], [2, 0.25, 2, 0.25, 19, 0.05]];
        case "captura_lancar": return [[14, 0.22, 2, 0.45, -6, 0]];
        case "captura_sucesso": return [[3, 0.1, 0, 0.35, 3, 0], [7, 0.1, 0, 0.35, 7, 0.1], [10, 0.1, 0, 0.35, 10, 0.2], [15, 0.28, 0, 0.4, 15, 0.3]];
        case "captura_falha": return [[3, 0.14, 0, 0.35, 3, 0], [-2, 0.26, 0, 0.35, -4, 0.14]];
        case "nivel": return [[0, 0.07, 1, 0.3, 0, 0], [4, 0.07, 1, 0.3, 4, 0.07], [7, 0.07, 1, 0.3, 7, 0.14], [12, 0.07, 1, 0.3, 12, 0.21], [16, 0.25, 1, 0.35, 16, 0.28]];
        case "vitoria": return [[3, 0.12, 0, 0.3, 3, 0], [7, 0.12, 0, 0.3, 7, 0.13], [10, 0.12, 0, 0.3, 10, 0.26], [15, 0.5, 0, 0.35, 15, 0.39], [-9, 0.8, 2, 0.4, -9, 0.39]];
        case "derrota": return [[3, 0.25, 2, 0.4, 3, 0], [-1, 0.25, 2, 0.4, -1, 0.25], [-4, 0.6, 2, 0.45, -6, 0.5]];
        case "conquista": return [[15, 0.08, 2, 0.3, 15, 0], [19, 0.08, 2, 0.3, 19, 0.08], [22, 0.08, 2, 0.3, 22, 0.16], [27, 0.3, 2, 0.35, 27, 0.24]];
        case "missao": return [[10, 0.12, 2, 0.35, 10, 0], [15, 0.3, 2, 0.35, 15, 0.12]];
    }

    return [[0, 0.05, 1, 0.3, 0, 0]];
}

function audio_sfx_som(_nome) {
    var _a = audio_garantir();

    if (variable_struct_exists(_a.Sons, "sfx_" + _nome)) {
        return variable_struct_get(_a.Sons, "sfx_" + _nome);
    }

    var _snd = audio_arquivo("sfx_" + _nome);

    if (_snd < 0) {
        var _receita = audio_sfx_receita(_nome);
        var _dur_total = 0;

        for (var _i = 0; _i < array_length(_receita); _i += 1) {
            _dur_total = max(_dur_total, _receita[_i][1] + _receita[_i][5]);
        }

        var _acum = array_create(ceil((_dur_total + 0.02) * AUDIO_TAXA), 0);

        for (var _j = 0; _j < array_length(_receita); _j += 1) {
            var _r = _receita[_j];
            audio_render_nota(_acum, floor(_r[5] * AUDIO_TAXA), floor(_r[1] * AUDIO_TAXA), audio_nota_freq(_r[0]), _r[2], _r[3], audio_nota_freq(_r[4]));
        }

        _snd = audio_acum_para_som(_acum, false);
    }

    variable_struct_set(_a.Sons, "sfx_" + _nome, _snd);
    return _snd;
}

function audio_sfx(_nome) {
    if (audio_modo() >= 2) {
        return;
    }

    // Evita metralhadora de sons iguais (ex.: varios golpes no mesmo instante a 3x).
    var _a = audio_garantir();
    var _chave_tempo = "t_" + _nome;
    var _ultimo = variable_struct_exists(_a, _chave_tempo) ? variable_struct_get(_a, _chave_tempo) : -1000;

    if (current_time - _ultimo < 70) {
        return;
    }

    variable_struct_set(_a, _chave_tempo, current_time);

    var _snd = audio_sfx_som(_nome);

    if (audio_exists(_snd)) {
        audio_play_sound(_snd, 5, false, _nome == "clique" ? 0.35 : 0.7);
    }
}

// ------------------------------------------------------------------ musica

// Cada musica: tom, escala, progressao de acordes, andamento e estilo.
function audio_musica_receita(_nome) {
    switch (_nome) {
        case "menu": return { Bpm: 84, Tom: -9, Menor: true, Acordes: [0, 5, 3, 4], Bateria: false, Semente: 11 };
        case "cidade": return { Bpm: 100, Tom: -7, Menor: false, Acordes: [0, 5, 3, 4], Bateria: false, Semente: 23 };
        case "rota": return { Bpm: 120, Tom: -5, Menor: false, Acordes: [0, 3, 4, 0], Bateria: true, Semente: 37 };
        case "batalha": return { Bpm: 144, Tom: -8, Menor: true, Acordes: [0, 5, 6, 4], Bateria: true, Semente: 41 };
        case "chefe": return { Bpm: 156, Tom: -10, Menor: true, Acordes: [0, 1, 5, 4], Bateria: true, Semente: 53 };
        case "buraco": return { Bpm: 132, Tom: -11, Menor: true, Acordes: [0, 6, 5, 1], Bateria: true, Semente: 67 };
        case "vitoria_final": return { Bpm: 112, Tom: -4, Menor: false, Acordes: [0, 4, 5, 3], Bateria: false, Semente: 79 };
    }

    return { Bpm: 100, Tom: -9, Menor: true, Acordes: [0, 3, 4, 0], Bateria: false, Semente: 5 };
}

function audio_escala(_menor) {
    return _menor ? [0, 2, 3, 5, 7, 8, 10] : [0, 2, 4, 5, 7, 9, 11];
}

// Monta a lista de notas da musica (4 acordes x 2 voltas, compasso 4/4).
function audio_musica_eventos(_nome) {
    var _r = audio_musica_receita(_nome);
    var _escala = audio_escala(_r.Menor);
    var _amostras_tempo = floor((60 / _r.Bpm) * AUDIO_TAXA);
    var _eventos = [];
    var _semente = _r.Semente;
    var _compassos = array_length(_r.Acordes) * 2;

    for (var _c = 0; _c < _compassos; _c += 1) {
        var _grau = _r.Acordes[_c mod array_length(_r.Acordes)];
        var _raiz = _r.Tom + _escala[_grau mod 7];
        var _terca = _r.Tom + _escala[(_grau + 2) mod 7] + (((_grau + 2) >= 7) ? 12 : 0);
        var _quinta = _r.Tom + _escala[(_grau + 4) mod 7] + (((_grau + 4) >= 7) ? 12 : 0);
        var _base = _c * 4 * _amostras_tempo;

        // Baixo em colcheias.
        for (var _b = 0; _b < 8; _b += 1) {
            var _nota_baixo = (_b mod 4 == 2) ? _quinta - 24 : _raiz - 24;
            array_push(_eventos, [_base + (_b * (_amostras_tempo div 2)), floor(_amostras_tempo * 0.45), _nota_baixo, 1, 0.16]);
        }

        // Acorde arpejado suave.
        var _arpejo = [_raiz, _terca, _quinta, _terca];
        for (var _p = 0; _p < 4; _p += 1) {
            array_push(_eventos, [_base + (_p * _amostras_tempo), floor(_amostras_tempo * 0.9), _arpejo[_p] - 12, 2, 0.08]);
        }

        // Melodia: notas do acorde e da escala, ritmo pseudoaleatorio fixo por musica.
        var _passo = 0;
        while (_passo < 8) {
            _semente = real((int64(_semente) * int64(1103515245) + int64(12345)) & int64(2147483647));
            var _dur = ((_semente div 65536) mod 3 == 0) ? 2 : 1;
            var _salta = ((_semente div 1024) mod 5 == 0);
            if (!_salta) {
                var _escolha = [_raiz, _terca, _quinta, _r.Tom + _escala[(_grau + 1) mod 7], _quinta][(_semente div 4096) mod 5];
                array_push(_eventos, [_base + (_passo * (_amostras_tempo div 2)), floor((_amostras_tempo div 2) * _dur * 0.9), _escolha + 12, 0, 0.075]);
            }
            _passo += _dur;
        }

        if (_r.Bateria) {
            for (var _k = 0; _k < 4; _k += 1) {
                if (_k mod 2 == 0) array_push(_eventos, [_base + (_k * _amostras_tempo), floor(AUDIO_TAXA * 0.09), -36, 3, 0.35, -48]);
                array_push(_eventos, [_base + (_k * _amostras_tempo) + (_amostras_tempo div 2), floor(AUDIO_TAXA * 0.03), 0, 4, 0.07]);
                if (_k mod 2 == 1) array_push(_eventos, [_base + (_k * _amostras_tempo), floor(AUDIO_TAXA * 0.08), 0, 4, 0.16]);
            }
        }
    }

    return { Eventos: _eventos, Amostras: _compassos * 4 * _amostras_tempo };
}

function audio_musica(_nome) {
    var _a = audio_garantir();
    _a.MusicaPedida = _nome;
}

// Chamado todo Step (obj_game_manager): gera musicas aos poucos e troca a faixa tocando.
function audio_step() {
    var _a = audio_garantir();

    if (audio_modo() != 0) {
        if (audio_exists(_a.MusicaInst)) {
            audio_stop_sound(_a.MusicaInst);
            _a.MusicaInst = -1;
            _a.MusicaAtual = "";
        }
        return;
    }

    var _pedida = _a.MusicaPedida;

    if (_pedida != _a.MusicaAtual && _pedida != "") {
        var _chave = "bgm_" + _pedida;

        if (variable_struct_exists(_a.Sons, _chave)) {
            if (audio_exists(_a.MusicaInst)) {
                audio_sound_gain(_a.MusicaInst, 0, 400);
                var _velha = _a.MusicaInst;
                call_later(0.45, time_source_units_seconds, method({ v: _velha }, function() { audio_stop_sound(v); }));
            }

            _a.MusicaInst = audio_play_sound(variable_struct_get(_a.Sons, _chave), 1, true, 0);
            audio_sound_gain(_a.MusicaInst, 0.42, 600);
            _a.MusicaAtual = _pedida;
        } else if (!is_struct(_a.Job) || _a.Job.Nome != _pedida) {
            var _arquivo = audio_arquivo("musica_" + _pedida);

            if (_arquivo >= 0) {
                variable_struct_set(_a.Sons, _chave, _arquivo);
            } else {
                var _musica = audio_musica_eventos(_pedida);
                _a.Job = { Nome: _pedida, Eventos: _musica.Eventos, Acum: array_create(_musica.Amostras, 0), Indice: 0, Buffer: -1, Convertidas: 0 };
            }
        }
    }

    // Sem nada pedido pendente, adianta as outras faixas em segundo plano.
    if (!is_struct(_a.Job)) {
        static _todas = ["menu", "cidade", "rota", "batalha", "chefe", "buraco", "vitoria_final"];

        for (var _q = 0; _q < array_length(_todas); _q += 1) {
            if (!variable_struct_exists(_a.Sons, "bgm_" + _todas[_q])) {
                var _arquivo_bg = audio_arquivo("musica_" + _todas[_q]);

                if (_arquivo_bg >= 0) {
                    variable_struct_set(_a.Sons, "bgm_" + _todas[_q], _arquivo_bg);
                    continue;
                }

                var _musica_bg = audio_musica_eventos(_todas[_q]);
                _a.Job = { Nome: _todas[_q], Eventos: _musica_bg.Eventos, Acum: array_create(_musica_bg.Amostras, 0), Indice: 0, Buffer: -1, Convertidas: 0 };
                break;
            }
        }
    }

    // Gera um pedaco da musica pendente por frame (mais rapido se for a faixa pedida agora).
    if (is_struct(_a.Job)) {
        var _orcamento = _a.Job.Nome == _a.MusicaPedida ? 9000 : 5000;
        var _job = _a.Job;

        while (_orcamento > 0 && _job.Indice < array_length(_job.Eventos)) {
            var _e = _job.Eventos[_job.Indice];
            var _freq_fim = array_length(_e) >= 6 ? audio_nota_freq(_e[5]) : audio_nota_freq(_e[2]);
            audio_render_nota(_job.Acum, _e[0], _e[1], audio_nota_freq(_e[2]), _e[3], _e[4], _freq_fim);
            _orcamento -= _e[1];
            _job.Indice += 1;
        }

        // Depois das notas, converte para PCM 16 bits tambem em pedacos.
        if (_job.Indice >= array_length(_job.Eventos)) {
            var _n = array_length(_job.Acum);

            if (_job.Buffer < 0) {
                _job.Buffer = buffer_create(_n * 2, buffer_fixed, 2);
            }

            var _ate = min(_n, _job.Convertidas + 20000);

            for (var _c = _job.Convertidas; _c < _ate; _c += 1) {
                buffer_write(_job.Buffer, buffer_s16, round(clamp(_job.Acum[_c], -1, 1) * 30000));
            }

            _job.Convertidas = _ate;

            if (_job.Convertidas >= _n) {
                array_push(_a.Buffers, _job.Buffer);
                variable_struct_set(_a.Sons, "bgm_" + _job.Nome, audio_create_buffer_sound(_job.Buffer, buffer_s16, AUDIO_TAXA, 0, _n * 2, audio_mono));
                _a.Job = undefined;
            }
        }
    }
}

// Escolhe a musica conforme a tela atual do jogo.
function audio_musica_para_jogo(_jogo) {
    if (!instance_exists(_jogo)) {
        return "menu";
    }

    switch (_jogo.estado_demo) {
        case DemoEstado.MENU:
        case DemoEstado.META_LOJA:
        case DemoEstado.CONQUISTAS:
        case DemoEstado.INTRO:
        case DemoEstado.GAME_OVER:
            return "menu";
        case DemoEstado.ROTA:
        case DemoEstado.SAIR_CIDADE:
            return "rota";
        case DemoEstado.BATALHA:
        case DemoEstado.CAPTURA:
        case DemoEstado.VITORIA:
        case DemoEstado.DERROTA:
            if (_jogo.battle_context == "chefe") return "chefe";
            if (_jogo.battle_context == "buraco_negro") return "buraco";
            return "batalha";
        case DemoEstado.VITORIA_FINAL:
            return "vitoria_final";
    }

    return "cidade";
}
