if (variable_global_exists("batalha_pausada") && global.batalha_pausada) {
    exit;
}

var _scale = variable_global_exists("time_scale") ? global.time_scale : 1.0;
var _dt = (delta_time / 1000000) * _scale;

if (_dt <= 0) {
    exit;
}

pokemon_visual_step(id, _dt);
pokemon_combate_step(id, _dt);
