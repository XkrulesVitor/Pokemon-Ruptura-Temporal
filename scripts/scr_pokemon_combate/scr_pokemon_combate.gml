enum LadoBatalha {
    ALIADO,
    INIMIGO
}

enum ESTADO {
    IDLE,
    ATACANDO,
    DANO
}

function StatusCombate(_id, _duracao) constructor {
    ID = _id;
    TempoAtual = _duracao;
    Duracao = _duracao;
    Stacks = 1;
    TickTimer = 1.0;
}

function pokemon_status_aplicar(_alvo, _status_id, _duracao) {
    if (!instance_exists(_alvo) || _status_id == "") {
        return false;
    }

    if (!is_struct(_alvo.status_map)) {
        _alvo.status_map = {};
    }

    var _key = string(_status_id);

    if (variable_struct_exists(_alvo.status_map, _key)) {
        var _status = variable_struct_get(_alvo.status_map, _key);
        _status.TempoAtual = max(_status.TempoAtual, _duracao);
        _status.Stacks += 1;
    } else {
        variable_struct_set(_alvo.status_map, _key, new StatusCombate(_key, _duracao));
    }

    return true;
}

function pokemon_status_tem(_alvo, _status_id) {
    if (!instance_exists(_alvo) || !is_struct(_alvo.status_map)) {
        return false;
    }

    return variable_struct_exists(_alvo.status_map, string(_status_id));
}

function pokemon_status_consumir(_alvo, _status_id) {
    if (!pokemon_status_tem(_alvo, _status_id)) {
        return false;
    }

    variable_struct_remove(_alvo.status_map, string(_status_id));
    return true;
}

function pokemon_status_tick(_inst, _dt) {
    if (!instance_exists(_inst) || !is_struct(_inst.status_map)) {
        return;
    }

    var _nomes = variable_struct_get_names(_inst.status_map);

    for (var _i = array_length(_nomes) - 1; _i >= 0; _i -= 1) {
        var _key = _nomes[_i];
        var _status = variable_struct_get(_inst.status_map, _key);
        _status.TempoAtual -= _dt;

        if (_status.ID == "Envenenado") {
            _status.TickTimer -= _dt;

            if (_status.TickTimer <= 0) {
                _status.TickTimer += 1.0;
                var _stacks = clamp(_status.Stacks, 1, 4);
                var _dano_tick = max(1, floor(_inst.hp_max * (0.012 + (_stacks * 0.006))));
                _inst.hp_atual = max(0, _inst.hp_atual - _dano_tick);

                if (is_struct(_inst.pokemon_data)) {
                    _inst.pokemon_data.HpAtual = _inst.hp_atual;
                }

                battle_log_push(string_upper(_inst.pokemon_nome) + " sofreu " + string(_dano_tick) + " de VENENO!");

                if (_inst.hp_atual <= 0) {
                    _inst.vivo = false;
                    _inst.batalha_ativo = false;

                    if (is_struct(_inst.pokemon_data)) {
                        _inst.pokemon_data.Desmaiado = true;
                    }
                }
            }
        }

        if (_status.ID == "Queimando") {
            _status.TickTimer -= _dt;

            if (_status.TickTimer <= 0) {
                _status.TickTimer += 1.0;
                var _burn_stacks = clamp(_status.Stacks, 1, 3);
                var _dano_burn = max(1, floor(_inst.hp_max * (0.007 + (_burn_stacks * 0.003))));
                _inst.hp_atual = max(0, _inst.hp_atual - _dano_burn);

                if (is_struct(_inst.pokemon_data)) {
                    _inst.pokemon_data.HpAtual = _inst.hp_atual;
                }

                battle_log_push(string_upper(_inst.pokemon_nome) + " sofreu " + string(_dano_burn) + " de QUEIMADURA!");

                if (_inst.hp_atual <= 0) {
                    _inst.vivo = false;
                    _inst.batalha_ativo = false;

                    if (is_struct(_inst.pokemon_data)) {
                        _inst.pokemon_data.Desmaiado = true;
                    }
                }
            }
        }

        if (_status.ID == "Granizo") {
            _status.TickTimer -= _dt;

            if (_status.TickTimer <= 0) {
                _status.TickTimer += 1.0;
                var _hail_stacks = clamp(_status.Stacks, 1, 3);
                var _dano_hail = max(1, floor(_inst.hp_max * (0.004 + (_hail_stacks * 0.002))));
                _inst.hp_atual = max(0, _inst.hp_atual - _dano_hail);

                if (is_struct(_inst.pokemon_data)) {
                    _inst.pokemon_data.HpAtual = _inst.hp_atual;
                }

                battle_log_push(string_upper(_inst.pokemon_nome) + " sofreu " + string(_dano_hail) + " de GRANIZO!");

                if (_inst.hp_atual <= 0) {
                    _inst.vivo = false;
                    _inst.batalha_ativo = false;

                    if (is_struct(_inst.pokemon_data)) {
                        _inst.pokemon_data.Desmaiado = true;
                    }
                }
            }
        }

        if (_status.TempoAtual <= 0) {
            variable_struct_remove(_inst.status_map, _key);
        }
    }
}

function pokemon_combate_encontrar_alvo(_atacante) {
    if (!instance_exists(_atacante)) {
        return noone;
    }

    var _melhor = noone;
    var _melhor_distancia = 100000000;

    with (obj_pokemon_batalha) {
        if (id != _atacante && batalha_ativo && vivo && lado_batalha != _atacante.lado_batalha) {
            var _distancia = abs(x - _atacante.x);

            if (_distancia < _melhor_distancia) {
                _melhor_distancia = _distancia;
                _melhor = id;
            }
        }
    }

    return _melhor;
}

function pokemon_combate_calcular_dano(_atacante, _alvo, _habilidade, _multiplicador) {
    var _ataque_mult = 1 + clamp((_atacante.attack - 35) / 150, -0.12, 0.55);

    if (pokemon_status_tem(_atacante, "CalorEscaldante")) {
        _ataque_mult *= 0.90;
    }

    if (pokemon_status_tem(_atacante, "ImpetoOfensivo")) {
        var _impeto = variable_struct_get(_atacante.status_map, "ImpetoOfensivo");
        _ataque_mult *= 1 + min(0.18, clamp(_impeto.Stacks, 1, 4) * 0.04);
    }

    if (pokemon_status_tem(_atacante, "EspiritoLuta")) {
        var _hp_ratio_atacante = _atacante.hp_atual / max(1, _atacante.hp_max);
        _ataque_mult *= _hp_ratio_atacante <= 0.45 ? 1.12 : 1.04;
    }

    if (pokemon_status_tem(_atacante, "Aterrado")) {
        _ataque_mult *= 1.04;
    }

    if (pokemon_status_tem(_atacante, "VentoDeCauda")) {
        _ataque_mult *= 1.05;
    }

    if (pokemon_status_tem(_atacante, "PenasLeves")) {
        _ataque_mult *= 1.03;
    }

    if (pokemon_status_tem(_atacante, "FocoPsiquico")) {
        _ataque_mult *= 1.08;
    }

    if (pokemon_status_tem(_atacante, "ParalisiaMental")) {
        _ataque_mult *= 0.92;
    }

    if (pokemon_status_tem(_atacante, "AmnesiaInduzida")) {
        _ataque_mult *= 0.94;
    }

    if (pokemon_status_tem(_atacante, "EnxameAtivo")) {
        _ataque_mult *= 1.05;
    }

    if (pokemon_status_tem(_atacante, "Metamorfose")) {
        _ataque_mult *= 1.06;
    }

    if (pokemon_status_tem(_atacante, "SedaPresa")) {
        _ataque_mult *= 0.96;
    }

    if (pokemon_status_tem(_atacante, "Infestado")) {
        _ataque_mult *= 0.97;
    }

    if (pokemon_status_tem(_atacante, "ImpactoGeologico")) {
        _ataque_mult *= 1.08;
    }

    if (pokemon_status_tem(_atacante, "TerrorCrescente")) {
        var _terror = variable_struct_get(_atacante.status_map, "TerrorCrescente");
        _ataque_mult *= 1 + min(0.16, clamp(_terror.Stacks, 1, 4) * 0.04);
    }

    if (pokemon_status_tem(_atacante, "EssenciaDrenada")) {
        _ataque_mult *= 1.05;
    }

    if (pokemon_status_tem(_atacante, "Fragmentado")) {
        _ataque_mult *= 0.97;
    }

    if (pokemon_status_tem(_atacante, "Amedrontado")) {
        _ataque_mult *= 0.94;
    }

    if (pokemon_status_tem(_atacante, "FuriaDraconica")) {
        var _hp_ratio_furia = _atacante.hp_atual / max(1, _atacante.hp_max);
        _ataque_mult *= _hp_ratio_furia <= 0.45 ? 1.14 : 1.06;
    }

    if (pokemon_status_tem(_atacante, "AscensaoDraconica")) {
        var _ascensao = variable_struct_get(_atacante.status_map, "AscensaoDraconica");
        _ataque_mult *= 1 + min(0.15, clamp(_ascensao.Stacks, 1, 4) * 0.035);
    }

    if (pokemon_status_tem(_atacante, "Predador")) {
        var _hp_ratio_predador_a = _atacante.hp_atual / max(1, _atacante.hp_max);
        var _hp_ratio_predador_b = _alvo.hp_atual / max(1, _alvo.hp_max);
        _ataque_mult *= _hp_ratio_predador_a >= _hp_ratio_predador_b ? 1.10 : 1.03;
    }

    if (pokemon_status_tem(_atacante, "ImpactoPesado")) {
        _ataque_mult *= 1 + clamp(_atacante.defense / 800, 0.04, 0.16);
    }

    if (pokemon_status_tem(_atacante, "Fortificado")) {
        var _fort_atk = variable_struct_get(_atacante.status_map, "Fortificado");
        _ataque_mult *= 1 + min(0.10, clamp(_fort_atk.Stacks, 1, 4) * 0.025);
    }

    if (pokemon_status_tem(_atacante, "BlindagemMagnetica")) {
        _ataque_mult *= 1.04;
    }

    if (pokemon_status_tem(_atacante, "LigaPesada")) {
        _ataque_mult *= 1.03;
    }

    if (pokemon_status_tem(_atacante, "GolpeBaixo")) {
        var _golpe_baixo = variable_struct_get(_atacante.status_map, "GolpeBaixo");
        _ataque_mult *= 1 + min(0.14, clamp(_golpe_baixo.Stacks, 1, 4) * 0.035);

        if (pokemon_status_tem(_alvo, "MarcadoSombrio")) {
            _ataque_mult *= 1.06;
        }
    }

    if (pokemon_status_tem(_atacante, "JogoSujo")) {
        _ataque_mult *= 1.06;

        var _alvo_debilitado_sombrio = false;
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "Envenenado");
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "Corroendo");
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "Vulneravel");
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "Queimando");
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "ArmaduraDerretida");
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "PosturaQuebrada");
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "Ofuscado");
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "Amedrontado");
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "ParalisiaMental");
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "SedaPresa");
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "Infestado");
        _alvo_debilitado_sombrio = _alvo_debilitado_sombrio || pokemon_status_tem(_alvo, "MarcadoSombrio");

        if (_alvo_debilitado_sombrio) {
            _ataque_mult *= 1.08;
        }
    }

    if (pokemon_status_tem(_atacante, "CamuflagemSombria")) {
        _ataque_mult *= 1.04;
    }

    if (pokemon_status_tem(_atacante, "CopiaSombria")) {
        _ataque_mult *= 1.03;
    }

    if (pokemon_status_tem(_atacante, "PerseguicaoSombria")) {
        _ataque_mult *= 1.06;

        var _alvo_em_fuga_sombria = false;
        _alvo_em_fuga_sombria = _alvo_em_fuga_sombria || pokemon_status_tem(_alvo, "Evasivo");
        _alvo_em_fuga_sombria = _alvo_em_fuga_sombria || pokemon_status_tem(_alvo, "Intangivel");
        _alvo_em_fuga_sombria = _alvo_em_fuga_sombria || pokemon_status_tem(_alvo, "VentoDeCauda");
        _alvo_em_fuga_sombria = _alvo_em_fuga_sombria || pokemon_status_tem(_alvo, "PenasLeves");
        _alvo_em_fuga_sombria = _alvo_em_fuga_sombria || pokemon_status_tem(_alvo, "FluxoAcelerado");

        if (_alvo_em_fuga_sombria) {
            _ataque_mult *= 1.08;
        }
    }

    if (pokemon_status_tem(_atacante, "EncantoCarga")) {
        var _encanto_carga = variable_struct_get(_atacante.status_map, "EncantoCarga");
        _ataque_mult *= 1 + min(0.18, clamp(_encanto_carga.Stacks, 1, 4) * 0.045);
    }

    if (pokemon_status_tem(_atacante, "LuzPurificadora")) {
        _ataque_mult *= 1.03;
    }

    if (pokemon_status_tem(_atacante, "AuraMistica")) {
        _ataque_mult *= 1.05;
    }

    if (pokemon_status_tem(_atacante, "ForcaNeutra")) {
        _ataque_mult *= 1.04;
    }

    if (pokemon_status_tem(_atacante, "EstoqueDefensivo")) {
        var _estoque_atk = variable_struct_get(_atacante.status_map, "EstoqueDefensivo");
        _ataque_mult *= 1 + min(0.08, clamp(_estoque_atk.Stacks, 1, 4) * 0.02);
    }

    if (pokemon_status_tem(_atacante, "LegadoAtivo")) {
        _ataque_mult *= 1.04;
    }

    if (pokemon_status_tem(_atacante, "MimetismoAtivo")) {
        _ataque_mult *= 1.03;
    }

    if (pokemon_status_tem(_atacante, "ReciclagemAtiva")) {
        _ataque_mult *= 1.03;
    }

    if (pokemon_status_tem(_atacante, "BrilhoOfuscante")) {
        _ataque_mult *= 0.94;
    }

    if (_atacante.lado_batalha == LadoBatalha.ALIADO && variable_global_exists("demo_meta_team_damage_mult")) {
        _ataque_mult *= global.demo_meta_team_damage_mult;
    }

    var _poder = _habilidade.DanoBase * 0.64 * _ataque_mult;
    var _defesa_efetiva = _alvo.defense;

    if (pokemon_status_tem(_alvo, "Corroendo")) {
        _defesa_efetiva *= 0.78;
    }

    if (pokemon_status_tem(_alvo, "Vulneravel")) {
        _defesa_efetiva *= 0.88;
    }

    if (pokemon_status_tem(_alvo, "ArmaduraDerretida")) {
        _defesa_efetiva *= 0.84;
    }

    if (pokemon_status_tem(_alvo, "Fragil")) {
        _defesa_efetiva *= 0.90;
    }

    if (pokemon_status_tem(_alvo, "MantoGelo")) {
        _defesa_efetiva *= 1.14;
    }

    if (pokemon_status_tem(_alvo, "PosturaQuebrada")) {
        _defesa_efetiva *= 0.84;
    }

    if (pokemon_status_tem(_alvo, "Desabando")) {
        _defesa_efetiva *= 0.90;
    }

    if (pokemon_status_tem(_alvo, "AreiaMovedica")) {
        _defesa_efetiva *= 0.96;
    }

    if (pokemon_status_tem(_alvo, "BarreiraLama")) {
        _defesa_efetiva *= 1.14;
    }

    if (pokemon_status_tem(_alvo, "Aterrado")) {
        _defesa_efetiva *= 1.06;
    }

    if (pokemon_status_tem(_alvo, "MarcadoRasante")) {
        _defesa_efetiva *= 0.90;
    }

    if (pokemon_status_tem(_alvo, "Turbulento")) {
        _defesa_efetiva *= 0.94;
    }

    if (pokemon_status_tem(_alvo, "Evasivo")) {
        _defesa_efetiva *= 1.08;
    }

    if (pokemon_status_tem(_alvo, "PenasLeves")) {
        _defesa_efetiva *= 1.06;
    }

    if (pokemon_status_tem(_alvo, "EscudoCinetico")) {
        _defesa_efetiva *= 1.14;
    }

    if (pokemon_status_tem(_alvo, "DistorcaoEspacial")) {
        _defesa_efetiva *= 0.88;
    }

    if (pokemon_status_tem(_alvo, "AmnesiaInduzida")) {
        _defesa_efetiva *= 0.92;
    }

    if (pokemon_status_tem(_alvo, "CasuloRigido")) {
        _defesa_efetiva *= 1.16;
    }

    if (pokemon_status_tem(_alvo, "Metamorfose")) {
        _defesa_efetiva *= 1.04;
    }

    if (pokemon_status_tem(_alvo, "SedaPresa")) {
        _defesa_efetiva *= 0.94;
    }

    if (pokemon_status_tem(_alvo, "Infestado")) {
        _defesa_efetiva *= 0.96;
    }

    if (pokemon_status_tem(_alvo, "CascaRocha")) {
        _defesa_efetiva *= 1.18;
    }

    if (pokemon_status_tem(_alvo, "FossilVivo")) {
        _defesa_efetiva *= 1.08;
    }

    if (pokemon_status_tem(_alvo, "Fragmentado")) {
        _defesa_efetiva *= 0.90;
    }

    if (pokemon_status_tem(_alvo, "Assombrado")) {
        _defesa_efetiva *= 0.94;
    }

    if (pokemon_status_tem(_alvo, "Maldito")) {
        _defesa_efetiva *= 0.92;
    }

    if (pokemon_status_tem(_alvo, "Intangivel")) {
        _defesa_efetiva *= 1.10;
    }

    if (pokemon_status_tem(_alvo, "Amedrontado")) {
        _defesa_efetiva *= 0.96;
    }

    if (pokemon_status_tem(_alvo, "MarcadoSombrio")) {
        _defesa_efetiva *= 0.94;
    }

    if (pokemon_status_tem(_alvo, "CamuflagemSombria")) {
        _defesa_efetiva *= 1.08;
    }

    if (pokemon_status_tem(_alvo, "CopiaSombria")) {
        _defesa_efetiva *= 1.12;
    }

    if (pokemon_status_tem(_alvo, "EscamaImperial")) {
        _defesa_efetiva *= 1.14;
    }

    if (pokemon_status_tem(_alvo, "FuriaDraconica")) {
        _defesa_efetiva *= 0.97;
    }

    if (pokemon_status_tem(_alvo, "EspinhosFerro")) {
        _defesa_efetiva *= 1.06;
    }

    if (pokemon_status_tem(_alvo, "Fortificado")) {
        var _fort_def = variable_struct_get(_alvo.status_map, "Fortificado");
        _defesa_efetiva *= 1 + min(0.18, clamp(_fort_def.Stacks, 1, 5) * 0.04);
    }

    if (pokemon_status_tem(_alvo, "BlindagemMagnetica")) {
        _defesa_efetiva *= 1.10;
    }

    if (pokemon_status_tem(_alvo, "ImpactoPesado")) {
        _defesa_efetiva *= 1.05;
    }

    if (pokemon_status_tem(_alvo, "LigaPesada")) {
        _defesa_efetiva *= 1.12;
    }

    if (pokemon_status_tem(_alvo, "BrilhoOfuscante")) {
        _defesa_efetiva *= 0.96;
    }

    if (pokemon_status_tem(_alvo, "LuzPurificadora")) {
        _defesa_efetiva *= 1.08;
    }

    if (pokemon_status_tem(_alvo, "AuraMistica")) {
        _defesa_efetiva *= 1.04;
    }

    if (pokemon_status_tem(_alvo, "BarreiraFada")) {
        _defesa_efetiva *= 1.14;
    }

    if (pokemon_status_tem(_alvo, "ForcaNeutra")) {
        _defesa_efetiva *= 1.02;
    }

    if (pokemon_status_tem(_alvo, "EstoqueDefensivo")) {
        var _estoque_def = variable_struct_get(_alvo.status_map, "EstoqueDefensivo");
        _defesa_efetiva *= 1 + min(0.18, clamp(_estoque_def.Stacks, 1, 5) * 0.04);
    }

    if (pokemon_status_tem(_alvo, "LegadoAtivo")) {
        _defesa_efetiva *= 1.05;
    }

    if (pokemon_status_tem(_alvo, "MimetismoAtivo")) {
        _defesa_efetiva *= 1.08;
    }

    var _mitigacao = _defesa_efetiva * 0.13;
    var _variacao = random_range(0.92, 1.08);
    var _dano_bruto = max(1, ((_poder - _mitigacao) * _multiplicador) * _variacao);
    var _limite_golpe = max(8, floor(_alvo.hp_max * 0.42));
    return clamp(floor(_dano_bruto), 4, _limite_golpe);
}

function pokemon_combate_efetividade_log(_multiplicador_elemental) {
    if (_multiplicador_elemental >= 1.30) {
        return " Foi super efetivo!";
    }

    if (_multiplicador_elemental > 1.0) {
        return " Foi efetivo!";
    }

    if (_multiplicador_elemental <= 0.70) {
        return " Quase nao surtiu efeito.";
    }

    if (_multiplicador_elemental < 1.0) {
        return " Nao foi muito efetivo.";
    }

    return "";
}

function pokemon_combate_status_duracao_padrao(_status_id) {
    switch (_status_id) {
        case "Enraizado": return 4.0;
        case "Crescimento": return 8.0;
        case "Fotossintese": return 4.0;
        case "Envenenado": return 6.0;
        case "Corroendo": return 6.0;
        case "Vulneravel": return 6.0;
        case "ToxinaAtiva": return 5.0;
        case "Queimando": return 5.0;
        case "ArmaduraDerretida": return 6.0;
        case "CalorEscaldante": return 5.0;
        case "CalorConcentrado": return 5.0;
        case "FenixAtiva": return 5.0;
        case "Molhado": return 5.0;
        case "FluxoAcelerado": return 4.0;
        case "NevoaEstagnante": return 5.0;
        case "MareAlta": return 5.0;
        case "Paralisado": return 4.0;
        case "Ofuscado": return 4.0;
        case "Sobrecarregado": return 5.0;
        case "EstaticaAtiva": return 5.0;
        case "ErroEletrico": return 3.0;
        case "Gelado": return 5.0;
        case "Congelando": return 4.0;
        case "Fragil": return 5.0;
        case "MantoGelo": return 5.0;
        case "Granizo": return 6.0;
        case "ImpetoOfensivo": return 5.0;
        case "EspiritoLuta": return 5.0;
        case "PosturaQuebrada": return 5.5;
        case "AreiaMovedica": return 5.5;
        case "BarreiraLama": return 5.0;
        case "Desabando": return 5.0;
        case "Aterrado": return 5.0;
        case "MarcadoRasante": return 4.5;
        case "Turbulento": return 5.0;
        case "VentoDeCauda": return 4.5;
        case "PenasLeves": return 5.0;
        case "Evasivo": return 4.0;
        case "ParalisiaMental": return 4.5;
        case "AmnesiaInduzida": return 5.0;
        case "EscudoCinetico": return 5.0;
        case "FocoPsiquico": return 5.0;
        case "DistorcaoEspacial": return 5.5;
        case "EnxameAtivo": return 5.0;
        case "CasuloRigido": return 5.5;
        case "SedaPresa": return 5.5;
        case "Infestado": return 6.0;
        case "Metamorfose": return 6.0;
        case "ImpactoGeologico": return 4.5;
        case "CascaRocha": return 5.5;
        case "Fragmentado": return 6.0;
        case "FossilVivo": return 5.0;
        case "Assombrado": return 6.0;
        case "TerrorCrescente": return 6.0;
        case "Intangivel": return 4.0;
        case "Maldito": return 6.0;
        case "EssenciaDrenada": return 5.5;
        case "Amedrontado": return 4.5;
        case "MarcadoSombrio": return 5.0;
        case "GolpeBaixo": return 4.5;
        case "JogoSujo": return 5.5;
        case "CamuflagemSombria": return 5.0;
        case "CopiaSombria": return 4.5;
        case "PerseguicaoSombria": return 5.0;
        case "FuriaDraconica": return 5.5;
        case "EscamaImperial": return 5.5;
        case "AscensaoDraconica": return 6.0;
        case "Predador": return 5.0;
        case "EspinhosFerro": return 6.0;
        case "Fortificado": return 6.0;
        case "BlindagemMagnetica": return 5.5;
        case "ImpactoPesado": return 5.0;
        case "LigaPesada": return 5.5;
        case "BrilhoOfuscante": return 4.5;
        case "EncantoCarga": return 4.5;
        case "LuzPurificadora": return 4.5;
        case "AuraMistica": return 5.0;
        case "BarreiraFada": return 5.0;
        case "ForcaNeutra": return 4.5;
        case "EstoqueDefensivo": return 6.0;
        case "LegadoAtivo": return 6.0;
        case "MimetismoAtivo": return 5.0;
        case "ReciclagemAtiva": return 5.0;
    }

    return 6.0;
}

function pokemon_combate_efeito_args(_efeito, _prefixo) {
    var _args = [];

    if (!is_string(_efeito) || string_pos(_prefixo, _efeito) != 1) {
        return _args;
    }

    var _resto = string_copy(_efeito, string_length(_prefixo) + 1, string_length(_efeito));
    var _token = "";

    for (var _i = 1; _i <= string_length(_resto); _i += 1) {
        var _char = string_char_at(_resto, _i);

        if (_char == ":") {
            array_push(_args, _token);
            _token = "";
        } else {
            _token += _char;
        }
    }

    array_push(_args, _token);
    return _args;
}

function pokemon_combate_efeitos_coletar(_habilidade) {
    var _efeitos = [];

    if (!is_struct(_habilidade)) {
        return _efeitos;
    }

    if (is_string(_habilidade.EfeitoEspecial) && _habilidade.EfeitoEspecial != "") {
        array_push(_efeitos, _habilidade.EfeitoEspecial);
    }

    if (is_array(_habilidade.Efeitos)) {
        for (var _i = 0; _i < array_length(_habilidade.Efeitos); _i += 1) {
            if (is_string(_habilidade.Efeitos[_i]) && _habilidade.Efeitos[_i] != "") {
                array_push(_efeitos, _habilidade.Efeitos[_i]);
            }
        }
    }

    return _efeitos;
}

function pokemon_combate_alvo_cooldown_score(_alvo) {
    if (!instance_exists(_alvo) || !is_array(_alvo.habilidades_equipadas)) {
        return 0;
    }

    var _maior_ratio = 0;

    for (var _i = 0; _i < array_length(_alvo.habilidades_equipadas); _i += 1) {
        var _habilidade = _alvo.habilidades_equipadas[_i];

        if (!is_struct(_habilidade)) {
            continue;
        }

        var _ratio = clamp(_habilidade.TempoRecargaAtual / max(0.01, _habilidade.TempoRecargaMax), 0, 1);
        _maior_ratio = max(_maior_ratio, _ratio);
    }

    return _maior_ratio;
}

function pokemon_combate_status_algum(_inst, _status_list) {
    if (!instance_exists(_inst) || !is_array(_status_list)) {
        return false;
    }

    for (var _i = 0; _i < array_length(_status_list); _i += 1) {
        if (pokemon_status_tem(_inst, _status_list[_i])) {
            return true;
        }
    }

    return false;
}

function pokemon_combate_sinergia_tipo_status(_atacante, _alvo, _tipo) {
    var _bonus = 0;
    var _alvo_debilitado = pokemon_combate_status_algum(
        _alvo,
        ["Envenenado", "Corroendo", "Vulneravel", "Queimando", "ArmaduraDerretida", "PosturaQuebrada", "Ofuscado", "Amedrontado", "ParalisiaMental", "SedaPresa", "Infestado", "MarcadoSombrio", "Fragil", "Fragmentado", "Maldito"]
    );

    switch (_tipo) {
        case PokemonTipo.NORMAL:
            if (_alvo_debilitado) _bonus += 0.04;
            if (pokemon_combate_status_algum(_atacante, ["ForcaNeutra", "MimetismoAtivo", "LegadoAtivo"])) _bonus += 0.04;
            break;

        case PokemonTipo.FIRE:
            if (pokemon_status_tem(_alvo, "ArmaduraDerretida")) _bonus += 0.08;
            if (pokemon_combate_status_algum(_alvo, ["Envenenado", "Corroendo"])) _bonus += 0.05;
            if (pokemon_status_tem(_alvo, "Enraizado")) _bonus += 0.04;
            break;

        case PokemonTipo.WATER:
            if (pokemon_combate_status_algum(_alvo, ["Queimando", "ArmaduraDerretida"])) _bonus += 0.07;
            if (pokemon_status_tem(_alvo, "Molhado")) _bonus += 0.05;
            if (pokemon_status_tem(_alvo, "AreiaMovedica")) _bonus += 0.04;
            break;

        case PokemonTipo.GRASS:
            if (pokemon_status_tem(_alvo, "Molhado")) _bonus += 0.06;
            if (pokemon_combate_status_algum(_alvo, ["Envenenado", "Corroendo"])) _bonus += 0.06;
            if (pokemon_status_tem(_alvo, "Enraizado")) _bonus += 0.08;
            break;

        case PokemonTipo.ELECTRIC:
            if (pokemon_status_tem(_alvo, "Molhado")) _bonus += 0.10;
            if (pokemon_combate_status_algum(_alvo, ["Ofuscado", "ErroEletrico", "Paralisado"])) _bonus += 0.05;
            break;

        case PokemonTipo.ICE:
            if (pokemon_status_tem(_alvo, "Molhado")) _bonus += 0.07;
            if (pokemon_combate_status_algum(_alvo, ["Gelado", "Congelando", "Fragil"])) _bonus += 0.08;
            break;

        case PokemonTipo.FIGHTING:
            if (pokemon_combate_status_algum(_alvo, ["PosturaQuebrada", "Vulneravel", "Desabando"])) _bonus += 0.08;
            if (pokemon_combate_status_algum(_alvo, ["CascaRocha", "BarreiraLama"])) _bonus += 0.05;
            break;

        case PokemonTipo.POISON:
            if (pokemon_status_tem(_alvo, "Enraizado")) _bonus += 0.08;
            if (pokemon_status_tem(_alvo, "Queimando")) _bonus += 0.04;
            if (pokemon_combate_status_algum(_alvo, ["Envenenado", "Corroendo"])) _bonus += 0.06;
            break;

        case PokemonTipo.GROUND:
            if (pokemon_status_tem(_alvo, "Molhado")) _bonus += 0.05;
            if (pokemon_combate_status_algum(_alvo, ["Paralisado", "SedaPresa"])) _bonus += 0.05;
            if (pokemon_combate_status_algum(_alvo, ["AreiaMovedica", "Desabando"])) _bonus += 0.08;
            break;

        case PokemonTipo.FLYING:
            if (pokemon_combate_status_algum(_atacante, ["Evasivo", "VentoDeCauda", "PenasLeves"])) _bonus += 0.06;
            if (pokemon_combate_status_algum(_alvo, ["MarcadoRasante", "Turbulento"])) _bonus += 0.08;
            break;

        case PokemonTipo.PSYCHIC:
            if (pokemon_combate_status_algum(_alvo, ["ParalisiaMental", "AmnesiaInduzida"])) _bonus += 0.08;
            if (pokemon_combate_status_algum(_alvo, ["Ofuscado", "Amedrontado"])) _bonus += 0.06;
            break;

        case PokemonTipo.BUG:
            if (pokemon_combate_status_algum(_alvo, ["Enraizado", "SedaPresa", "Infestado"])) _bonus += 0.08;
            if (pokemon_status_tem(_alvo, "Envenenado")) _bonus += 0.04;
            break;

        case PokemonTipo.ROCK:
            if (pokemon_combate_status_algum(_alvo, ["Fragmentado", "Desabando", "PosturaQuebrada"])) _bonus += 0.07;
            if (pokemon_combate_status_algum(_atacante, ["CascaRocha", "ImpactoGeologico"])) _bonus += 0.05;
            break;

        case PokemonTipo.GHOST:
            if (pokemon_combate_status_algum(_alvo, ["Assombrado", "Maldito", "TerrorCrescente", "Amedrontado"])) _bonus += 0.08;
            if (pokemon_status_tem(_atacante, "EssenciaDrenada")) _bonus += 0.05;
            break;

        case PokemonTipo.DRAGON:
            if (pokemon_combate_status_algum(_atacante, ["FuriaDraconica", "EscamaImperial", "AscensaoDraconica", "Predador"])) _bonus += 0.08;
            if (pokemon_combate_status_algum(_alvo, ["Fragil", "Queimando", "Molhado"])) _bonus += 0.04;
            break;

        case PokemonTipo.DARK:
            if (_alvo_debilitado) _bonus += 0.06;
            if (pokemon_combate_status_algum(_alvo, ["MarcadoSombrio", "Amedrontado"])) _bonus += 0.08;
            break;

        case PokemonTipo.STEEL:
            if (pokemon_combate_status_algum(_atacante, ["Fortificado", "ImpactoPesado", "BlindagemMagnetica"])) _bonus += 0.06;
            if (pokemon_combate_status_algum(_alvo, ["Fragmentado", "PosturaQuebrada"])) _bonus += 0.06;
            break;

        case PokemonTipo.FAIRY:
            if (pokemon_combate_status_algum(_atacante, ["BrilhoOfuscante", "EncantoCarga", "AuraMistica"])) _bonus += 0.06;
            if (pokemon_combate_status_algum(_alvo, ["MarcadoSombrio", "ParalisiaMental", "Amedrontado"])) _bonus += 0.07;
            break;
    }

    return min(_bonus, 0.22);
}

function pokemon_combate_multiplicador_efeitos(_atacante, _alvo, _habilidade) {
    var _multiplicador = 1.0;
    var _efeitos = pokemon_combate_efeitos_coletar(_habilidade);

    for (var _i = 0; _i < array_length(_efeitos); _i += 1) {
        var _efeito = _efeitos[_i];
        var _args_alvo = pokemon_combate_efeito_args(_efeito, "bonus_dano_alvo_status:");

        if (array_length(_args_alvo) >= 2 && pokemon_status_tem(_alvo, _args_alvo[0])) {
            _multiplicador += real(_args_alvo[1]);
            continue;
        }

        var _args_usuario = pokemon_combate_efeito_args(_efeito, "bonus_dano_usuario_status:");

        if (array_length(_args_usuario) >= 2 && pokemon_status_tem(_atacante, _args_usuario[0])) {
            _multiplicador += real(_args_usuario[1]);
            continue;
        }

        var _args_sacrificio = pokemon_combate_efeito_args(_efeito, "bonus_dano_sacrificio:");

        if (array_length(_args_sacrificio) >= 1) {
            _multiplicador += real(_args_sacrificio[0]);
            continue;
        }

        var _args_cd = pokemon_combate_efeito_args(_efeito, "bonus_dano_alvo_cd:");

        if (array_length(_args_cd) >= 1) {
            _multiplicador += real(_args_cd[0]) * pokemon_combate_alvo_cooldown_score(_alvo);
        }

        var _args_hp_baixo = pokemon_combate_efeito_args(_efeito, "bonus_dano_alvo_hp_baixo:");

        if (array_length(_args_hp_baixo) >= 2 && instance_exists(_alvo) && _alvo.hp_max > 0) {
            var _hp_ratio = _alvo.hp_atual / max(1, _alvo.hp_max);

            if (_hp_ratio <= real(_args_hp_baixo[0])) {
                _multiplicador += real(_args_hp_baixo[1]);
            }
        }

        var _args_usuario_hp_baixo = pokemon_combate_efeito_args(_efeito, "bonus_dano_usuario_hp_baixo:");

        if (array_length(_args_usuario_hp_baixo) >= 2 && instance_exists(_atacante) && _atacante.hp_max > 0) {
            var _hp_ratio_usuario = _atacante.hp_atual / max(1, _atacante.hp_max);

            if (_hp_ratio_usuario <= real(_args_usuario_hp_baixo[0])) {
                _multiplicador += real(_args_usuario_hp_baixo[1]);
            }
        }
    }

    var _tipo_ataque = variable_struct_exists(_habilidade, "TipoElementar") ? _habilidade.TipoElementar : _habilidade.Tipo;
    _multiplicador += pokemon_combate_sinergia_tipo_status(_atacante, _alvo, _tipo_ataque);
    return clamp(_multiplicador, 0.55, 1.65);
}

function pokemon_combate_curar(_inst, _quantidade) {
    if (!instance_exists(_inst) || _quantidade <= 0) {
        return 0;
    }

    var _antes = _inst.hp_atual;
    _inst.hp_atual = min(_inst.hp_max, _inst.hp_atual + _quantidade);

    if (is_struct(_inst.pokemon_data)) {
        _inst.pokemon_data.HpAtual = _inst.hp_atual;
    }

    return _inst.hp_atual - _antes;
}

function pokemon_combate_aplicar_efeitos(_atacante, _alvo, _habilidade, _dano) {
    var _efeito_especial = _habilidade.EfeitoEspecial;

    if (is_method(_efeito_especial)) {
        _efeito_especial(_atacante, _alvo, _habilidade);
    }

    var _efeitos = pokemon_combate_efeitos_coletar(_habilidade);

    for (var _i = 0; _i < array_length(_efeitos); _i += 1) {
        var _efeito = _efeitos[_i];
        var _status_alvo = pokemon_combate_efeito_args(_efeito, "aplicar_status:");

        if (array_length(_status_alvo) >= 1) {
            var _status_id = _status_alvo[0];
            pokemon_status_aplicar(_alvo, _status_id, pokemon_combate_status_duracao_padrao(_status_id));
            battle_log_push(string_upper(_alvo.pokemon_nome) + " ficou " + string_upper(_status_id) + "!");
            continue;
        }

        var _status_usuario = pokemon_combate_efeito_args(_efeito, "aplicar_status_usuario:");

        if (array_length(_status_usuario) >= 1) {
            var _status_self = _status_usuario[0];
            pokemon_status_aplicar(_atacante, _status_self, pokemon_combate_status_duracao_padrao(_status_self));
            battle_log_push(string_upper(_atacante.pokemon_nome) + " ativou " + string_upper(_status_self) + "!");
            continue;
        }

        var _cura_dano = pokemon_combate_efeito_args(_efeito, "curar_dano:");

        if (array_length(_cura_dano) >= 1) {
            var _curado = pokemon_combate_curar(_atacante, max(1, floor(_dano * real(_cura_dano[0]))));

            if (_curado > 0) {
                battle_log_push(string_upper(_atacante.pokemon_nome) + " recuperou " + string(_curado) + " HP!");
            }

            continue;
        }

        var _sacrificio_hp = pokemon_combate_efeito_args(_efeito, "sacrificar_hp_pct:");

        if (array_length(_sacrificio_hp) >= 1) {
            var _perda = max(1, floor(_atacante.hp_max * real(_sacrificio_hp[0])));
            _perda = min(_perda, max(0, _atacante.hp_atual - 1));

            if (_perda > 0) {
                _atacante.hp_atual -= _perda;

                if (is_struct(_atacante.pokemon_data)) {
                    _atacante.pokemon_data.HpAtual = _atacante.hp_atual;
                }

                battle_log_push(string_upper(_atacante.pokemon_nome) + " converteu " + string(_perda) + " HP em forca!");
            }

            continue;
        }

        var _cura_dano_status = pokemon_combate_efeito_args(_efeito, "curar_dano_status:");

        if (array_length(_cura_dano_status) >= 2 && pokemon_status_tem(_alvo, _cura_dano_status[0])) {
            var _curado_status = pokemon_combate_curar(_atacante, max(1, floor(_dano * real(_cura_dano_status[1]))));

            if (_curado_status > 0) {
                battle_log_push(string_upper(_atacante.pokemon_nome) + " drenou " + string(_curado_status) + " HP!");
            }

            continue;
        }

        var _reduzir_cds = pokemon_combate_efeito_args(_efeito, "reduzir_cooldowns_usuario:");

        if (array_length(_reduzir_cds) >= 1 && is_array(_atacante.habilidades_equipadas)) {
            var _reducao = real(_reduzir_cds[0]);

            for (var _cd_i = 0; _cd_i < array_length(_atacante.habilidades_equipadas); _cd_i += 1) {
                var _skill_cd = _atacante.habilidades_equipadas[_cd_i];

                if (is_struct(_skill_cd)) {
                    _skill_cd.TempoRecargaAtual = max(0, _skill_cd.TempoRecargaAtual - _reducao);
                }
            }

            battle_log_push(string_upper(_atacante.pokemon_nome) + " acelerou seus COOLDOWNS!");
            continue;
        }

        var _aumentar_cds = pokemon_combate_efeito_args(_efeito, "aumentar_cooldowns_alvo:");

        if (array_length(_aumentar_cds) >= 1 && is_array(_alvo.habilidades_equipadas)) {
            var _atraso = real(_aumentar_cds[0]);

            for (var _delay_i = 0; _delay_i < array_length(_alvo.habilidades_equipadas); _delay_i += 1) {
                var _skill_delay = _alvo.habilidades_equipadas[_delay_i];

                if (is_struct(_skill_delay)) {
                    _skill_delay.TempoRecargaAtual = min(_skill_delay.TempoRecargaMax + 2.0, _skill_delay.TempoRecargaAtual + _atraso);
                }
            }

            battle_log_push(string_upper(_alvo.pokemon_nome) + " teve os COOLDOWNS atrasados!");
            continue;
        }

        var _cura_maxhp = pokemon_combate_efeito_args(_efeito, "curar_maxhp:");

        if (array_length(_cura_maxhp) >= 1) {
            var _curado_max = pokemon_combate_curar(_atacante, max(1, floor(_atacante.hp_max * real(_cura_maxhp[0]))));

            if (_curado_max > 0) {
                battle_log_push(string_upper(_atacante.pokemon_nome) + " recuperou " + string(_curado_max) + " HP!");
            }
        }
    }
}

function pokemon_combate_executar_habilidade(_atacante, _habilidade) {
    if (!instance_exists(_atacante) || !is_struct(_habilidade) || !_atacante.vivo) {
        return false;
    }

    var _alvo = pokemon_combate_encontrar_alvo(_atacante);

    if (!instance_exists(_alvo)) {
        return false;
    }

    if (pokemon_status_tem(_atacante, "Ofuscado")) {
        pokemon_status_consumir(_atacante, "Ofuscado");

        if (random(1) < 0.28) {
            pokemon_status_aplicar(_atacante, "ErroEletrico", pokemon_combate_status_duracao_padrao("ErroEletrico"));
            battle_log_push(string_upper(_atacante.pokemon_nome) + " errou o golpe por OFUSCACAO!");
            return true;
        }
    }

    if (pokemon_status_tem(_alvo, "Intangivel")) {
        var _intangivel = variable_struct_get(_alvo.status_map, "Intangivel");
        var _chance_intangivel = min(0.28, 0.16 + (clamp(_intangivel.Stacks, 1, 3) * 0.04));

        if (random(1) < _chance_intangivel) {
            pokemon_status_consumir(_alvo, "Intangivel");
            battle_log_push(string_upper(_alvo.pokemon_nome) + " ficou INTANGIVEL e evitou o golpe!");
            return true;
        }
    }

    if (pokemon_status_tem(_alvo, "CopiaSombria")) {
        var _copia = variable_struct_get(_alvo.status_map, "CopiaSombria");
        var _chance_copia = min(0.30, 0.16 + (clamp(_copia.Stacks, 1, 4) * 0.035));

        if (random(1) < _chance_copia) {
            pokemon_status_consumir(_alvo, "CopiaSombria");
            battle_log_push(string_upper(_alvo.pokemon_nome) + " desviou usando COPIA SOMBRIA!");
            return true;
        }
    }

    if (pokemon_status_tem(_alvo, "CamuflagemSombria")) {
        var _camuflagem = variable_struct_get(_alvo.status_map, "CamuflagemSombria");
        var _chance_camuflagem = min(0.24, 0.12 + (clamp(_camuflagem.Stacks, 1, 4) * 0.03));

        if (random(1) < _chance_camuflagem) {
            pokemon_status_consumir(_alvo, "CamuflagemSombria");
            battle_log_push(string_upper(_alvo.pokemon_nome) + " sumiu na CAMUFLAGEM!");
            return true;
        }
    }

    var _multiplicador = 1.0;
    var _multiplicador_elemental = 1.0;
    var _combo_consumir = "";

    if (is_string(_habilidade.ComboID) && _habilidade.ComboID != "" && pokemon_status_tem(_alvo, _habilidade.ComboID)) {
        _multiplicador += 0.25;
        _combo_consumir = _habilidade.ComboID;
    }

    if (is_struct(_alvo.pokemon_data)) {
        var _tipo_ataque = variable_struct_exists(_habilidade, "TipoElementar") ? _habilidade.TipoElementar : _habilidade.Tipo;
        _multiplicador_elemental = calcular_dano_elemental(_tipo_ataque, _alvo.pokemon_data.Tipo1, _alvo.pokemon_data.Tipo2);
        _multiplicador *= _multiplicador_elemental;
    }

    _multiplicador *= pokemon_combate_multiplicador_efeitos(_atacante, _alvo, _habilidade);

    var _dano = pokemon_combate_calcular_dano(_atacante, _alvo, _habilidade, _multiplicador);
    _alvo.hp_atual = max(0, _alvo.hp_atual - _dano);
    pokemon_visual_mudar_estado(_atacante, ESTADO.ATACANDO, 0.22, _alvo);

    var _houve_combo = _combo_consumir != "";
    var _impacto = _houve_combo ? "Combo!" : string(_dano);
    battle_vfx_criar(_atacante, _alvo, _impacto);
    battle_log_push(string_upper(_atacante.pokemon_nome) + " usou " + string_upper(_habilidade.Nome) + "!" + pokemon_combate_efetividade_log(_multiplicador_elemental));

    pokemon_combate_aplicar_efeitos(_atacante, _alvo, _habilidade, _dano);

    if (pokemon_status_tem(_alvo, "EspinhosFerro") && _alvo.hp_atual > 0 && _atacante.hp_atual > 0) {
        var _espinhos = variable_struct_get(_alvo.status_map, "EspinhosFerro");
        var _retorno_ratio = 0.08 + min(0.06, clamp(_espinhos.Stacks, 1, 4) * 0.015);
        var _retorno = max(1, floor(_dano * _retorno_ratio));
        _atacante.hp_atual = max(0, _atacante.hp_atual - _retorno);

        if (is_struct(_atacante.pokemon_data)) {
            _atacante.pokemon_data.HpAtual = _atacante.hp_atual;
        }

        battle_log_push(string_upper(_atacante.pokemon_nome) + " sofreu " + string(_retorno) + " de ESPINHOS!");
    }

    if (_combo_consumir != "") {
        pokemon_status_consumir(_alvo, _combo_consumir);
    }

    if (_atacante.hp_atual <= 0) {
        _atacante.vivo = false;
        _atacante.batalha_ativo = false;

        if (is_struct(_atacante.pokemon_data)) {
            _atacante.pokemon_data.Desmaiado = true;
        }
    }

    if (_alvo.hp_atual <= 0) {
        _alvo.vivo = false;
        _alvo.batalha_ativo = false;

        if (is_struct(_alvo.pokemon_data)) {
            _alvo.pokemon_data.Desmaiado = true;
        }
    }

    if (_houve_combo) {
        battle_log_push("Combo executado!");
    }

    return true;
}

function pokemon_visual_mudar_estado(_inst, _estado, _tempo, _referencia) {
    if (!instance_exists(_inst)) {
        return;
    }

    _inst.estado_visual = _estado;
    _inst.estado_visual_timer = _tempo;

    var _direcao = 1;

    if (instance_exists(_referencia)) {
        _direcao = sign(_referencia.x - _inst.x);
        if (_direcao == 0) {
            _direcao = _inst.lado_batalha == LadoBatalha.ALIADO ? 1 : -1;
        }
    }

    if (_estado == ESTADO.ATACANDO) {
        _inst.visual_offset_x = 12 * _direcao;
    } else if (_estado == ESTADO.DANO) {
        _inst.visual_offset_x = -8 * _direcao;
        _inst.visual_flash = 1.0;
    }
}

function pokemon_visual_step(_inst, _dt) {
    if (!instance_exists(_inst)) {
        return;
    }

    _inst.visual_offset_x = lerp(_inst.visual_offset_x, 0, min(1, _dt * 12));
    _inst.visual_flash = max(0, _inst.visual_flash - _dt * 8);

    if (_inst.estado_visual != ESTADO.IDLE) {
        _inst.estado_visual_timer -= _dt;

        if (_inst.estado_visual_timer <= 0) {
            _inst.estado_visual = ESTADO.IDLE;
            _inst.estado_visual_timer = 0;
        }
    }
}

function pokemon_draw_action_queue(_inst) {
    if (!instance_exists(_inst)) {
        return;
    }

    var _w = 42;
    var _h = 4;
    var _gap = 2;
    var _start_x = _inst.x - (_w * 0.5);
    var _start_y = _inst.y - 58;

    for (var _i = 0; _i < 4; _i += 1) {
        var _habilidade = _inst.habilidades_equipadas[_i];
        var _y = _start_y + (_i * (_h + _gap));

        draw_set_color(c_black);
        draw_rectangle(_start_x - 1, _y - 1, _start_x + _w + 1, _y + _h + 1, false);

        if (!is_struct(_habilidade)) {
            draw_set_color(c_dkgray);
            draw_rectangle(_start_x, _y, _start_x + _w, _y + _h, false);
            continue;
        }

        var _progresso = 1 - clamp(_habilidade.TempoRecargaAtual / max(0.01, _habilidade.TempoRecargaMax), 0, 1);
        draw_set_color(c_gray);
        draw_rectangle(_start_x, _y, _start_x + _w, _y + _h, false);
        draw_set_color(c_lime);
        draw_rectangle(_start_x, _y, _start_x + (_w * _progresso), _y + _h, false);
    }

    draw_set_color(c_white);
}

function pokemon_combate_speed_cooldown_mult(_speed) {
    return 1 + clamp((_speed - 50) * 0.008, -0.18, 0.42);
}

function pokemon_combate_cooldown_reiniciar(_inst, _habilidade, _slot) {
    var _lado_jitter = _inst.lado_batalha == LadoBatalha.ALIADO ? 0.00 : 0.48;
    var _slot_jitter = (_slot mod 4) * 0.22;
    _habilidade.TempoRecargaAtual = _habilidade.TempoRecargaMax + _lado_jitter + _slot_jitter;
}

function pokemon_combate_step(_inst, _dt) {
    if (!instance_exists(_inst) || !_inst.vivo || !_inst.batalha_ativo) {
        return;
    }

    pokemon_status_tick(_inst, _dt);

    if (!_inst.vivo) {
        return;
    }

    for (var _i = 0; _i < 4; _i += 1) {
        var _habilidade = _inst.habilidades_equipadas[_i];

        if (!is_struct(_habilidade)) {
            continue;
        }

        var _speed_mult = pokemon_combate_speed_cooldown_mult(_inst.stat_speed);

        if (pokemon_status_tem(_inst, "FluxoAcelerado")) {
            _speed_mult *= 1.14;
        }

        if (pokemon_status_tem(_inst, "EstaticaAtiva")) {
            _speed_mult *= 1.13;
        }

        if (pokemon_status_tem(_inst, "Paralisado")) {
            _speed_mult *= 0.88;
        }

        if (pokemon_status_tem(_inst, "NevoaEstagnante")) {
            _speed_mult *= 0.88;
        }

        if (pokemon_status_tem(_inst, "CalorEscaldante")) {
            _speed_mult *= 0.94;
        }

        if (pokemon_status_tem(_inst, "Gelado")) {
            _speed_mult *= 0.90;
        }

        if (pokemon_status_tem(_inst, "Congelando")) {
            _speed_mult *= 0.82;
        }

        if (pokemon_status_tem(_inst, "MantoGelo")) {
            _speed_mult *= 0.94;
        }

        _habilidade.TempoRecargaAtual = max(0, _habilidade.TempoRecargaAtual - (_dt * _speed_mult));

        if (_habilidade.TempoRecargaAtual <= 0) {
            var _executou = pokemon_combate_executar_habilidade(_inst, _habilidade);

            if (_executou) {
                pokemon_combate_cooldown_reiniciar(_inst, _habilidade, _i);
            }
        }
    }
}
