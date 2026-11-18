var _spr = sprite_idle;

switch (estado_visual) {
    case ESTADO.ATACANDO:
        _spr = sprite_exists(sprite_ataque) ? sprite_ataque : sprite_idle;
        break;

    case ESTADO.DANO:
        _spr = sprite_exists(sprite_dano) ? sprite_dano : sprite_idle;
        break;
}

var _shake_x = variable_global_exists("screen_shake_x") ? global.screen_shake_x : 0;
var _shake_y = variable_global_exists("screen_shake_y") ? global.screen_shake_y : 0;
var _draw_x = x + visual_offset_x + _shake_x;
var _draw_y = y + _shake_y;
var _xscale = lado_batalha == LadoBatalha.ALIADO ? -1 : 1;

if (sprite_exists(_spr)) {
    var _blend = visual_flash > 0 ? c_red : c_white;
    draw_sprite_ext(_spr, 0, _draw_x, _draw_y, _xscale * 1.32, 1.32, 0, _blend, 1);
} else {
    demo_draw_pokemon_sprite(pokemon_id, _draw_x, _draw_y, 1.32, _xscale, visual_flash);
}
