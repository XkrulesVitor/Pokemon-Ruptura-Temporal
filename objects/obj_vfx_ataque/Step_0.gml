var _scale = variable_global_exists("time_scale") ? global.time_scale : 1.0;
var _dt = (delta_time / 1000000) * _scale;

if (_dt <= 0) {
    exit;
}

life -= _dt;

if (!instance_exists(alvo) || life <= 0) {
    instance_destroy();
    exit;
}

var _target_x = alvo.x;
var _target_y = alvo.y - 28;
var _dx = _target_x - x;
var _dy = _target_y - y;
var _dist = point_distance(x, y, _target_x, _target_y);

if (_dist <= max(8, speed_px * _dt)) {
    x = _target_x;
    y = _target_y;
    pokemon_visual_mudar_estado(alvo, ESTADO.DANO, 0.18, id);
    battle_vfx_impacto(x, y, tipo, texto_impacto == "Combo!");
    battle_screen_shake(4, 0.12);
    battle_float_text_push(alvo.x - 24, alvo.y - 84, texto_impacto, c_white);
    instance_destroy();
} else {
    x += (_dx / _dist) * speed_px * _dt;
    y += (_dy / _dist) * speed_px * _dt;
}
