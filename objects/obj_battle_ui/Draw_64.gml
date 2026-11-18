var _demo = instance_number(obj_demo_game) > 0 ? instance_find(obj_demo_game, 0) : noone;
var _battle_ui_active = instance_exists(_demo) && (_demo.estado_demo == DemoEstado.BATALHA || _demo.estado_demo == DemoEstado.CAPTURA);

if (!_battle_ui_active) {
    exit;
}

battle_ui_draw_gui();
