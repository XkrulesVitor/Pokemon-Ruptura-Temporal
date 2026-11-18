var _demo = instance_number(obj_demo_game) > 0 ? instance_find(obj_demo_game, 0) : noone;
var _battle_ui_active = instance_exists(_demo) && (_demo.estado_demo == DemoEstado.BATALHA || _demo.estado_demo == DemoEstado.CAPTURA);

if (!_battle_ui_active) {
    exit;
}

var _scale = variable_global_exists("time_scale") ? global.time_scale : 1.0;
var _dt = _demo.estado_demo == DemoEstado.CAPTURA ? (delta_time / 1000000) : (delta_time / 1000000) * _scale;
battle_ui_step(_dt);
