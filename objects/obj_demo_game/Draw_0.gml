var _shake_x = variable_global_exists("screen_shake_x") ? global.screen_shake_x : 0;
var _shake_y = variable_global_exists("screen_shake_y") ? global.screen_shake_y : 0;
var _is_route_screen = estado_demo == DemoEstado.ROTA || estado_demo == DemoEstado.VITORIA || estado_demo == DemoEstado.DERROTA;
var _is_city_screen = estado_demo == DemoEstado.CIDADE || estado_demo == DemoEstado.POKESTORE || estado_demo == DemoEstado.LAB_CARVALHO || estado_demo == DemoEstado.MOCHILA || estado_demo == DemoEstado.GINASIO || estado_demo == DemoEstado.CASA_MAE || estado_demo == DemoEstado.SAIR_CIDADE;

if (_is_city_screen) {
    var _city_sprite = demo_city_sprite_get(id, cidade_index);

    if (sprite_exists(_city_sprite)) {
        var _map_rect = demo_city_map_rect(_city_sprite, room_width, room_height, cidade_index);
        draw_clear(make_color_rgb(70, 148, 104));
        draw_sprite_ext(
            _city_sprite,
            0,
            _map_rect.X,
            _map_rect.Y,
            _map_rect.W / sprite_get_width(_city_sprite),
            _map_rect.H / sprite_get_height(_city_sprite),
            0,
            c_white,
            1
        );
        exit;
    }

    draw_clear(make_color_rgb(96, 188, 92));
    draw_set_color(make_color_rgb(72, 154, 74));
    draw_rectangle(0, 0, room_width, room_height * 0.18, false);
    draw_set_color(make_color_rgb(114, 202, 96));
    draw_rectangle(0, room_height * 0.18, room_width, room_height, false);

    for (var _city_patch = 0; _city_patch < 18; _city_patch += 1) {
        var _cx_patch = ((_city_patch * 173) mod room_width) - 32;
        var _cy_patch = 70 + ((_city_patch * 91) mod floor(room_height * 0.62));
        draw_set_color((_city_patch mod 2) == 0 ? make_color_rgb(80, 166, 78) : make_color_rgb(132, 212, 100));
        draw_rectangle(_cx_patch, _cy_patch, _cx_patch + 64, _cy_patch + 18, false);
    }

    var _road_w = 122;
    var _road_x = room_width * 0.40;
    draw_set_color(make_color_rgb(184, 154, 102));
    draw_rectangle(_road_x - _road_w * 0.5, room_height * 0.18, _road_x + _road_w * 0.5, room_height, false);
    draw_rectangle(room_width * 0.17, room_height * 0.58, room_width * 0.70, room_height * 0.70, false);
    draw_set_color(make_color_rgb(142, 118, 78));
    draw_rectangle(_road_x - _road_w * 0.5, room_height * 0.18, _road_x - _road_w * 0.5 + 8, room_height, false);
    draw_rectangle(_road_x + _road_w * 0.5 - 8, room_height * 0.18, _road_x + _road_w * 0.5, room_height, false);

    draw_set_color(make_color_rgb(238, 222, 170));
    draw_rectangle(room_width * 0.13, room_height * 0.28, room_width * 0.29, room_height * 0.43, false);
    draw_set_color(make_color_rgb(198, 54, 62));
    draw_rectangle(room_width * 0.11, room_height * 0.24, room_width * 0.31, room_height * 0.31, false);
    draw_set_color(make_color_rgb(92, 70, 54));
    draw_rectangle(room_width * 0.19, room_height * 0.36, room_width * 0.23, room_height * 0.43, false);

    draw_set_color(make_color_rgb(222, 226, 236));
    draw_rectangle(room_width * 0.47, room_height * 0.24, room_width * 0.66, room_height * 0.43, false);
    draw_set_color(make_color_rgb(66, 126, 210));
    draw_rectangle(room_width * 0.45, room_height * 0.20, room_width * 0.68, room_height * 0.28, false);
    draw_set_color(c_white);
    i18n_draw_text(room_width * 0.525, room_height * 0.225, "MART");

    draw_set_color(make_color_rgb(216, 204, 160));
    draw_rectangle(room_width * 0.17, room_height * 0.63, room_width * 0.31, room_height * 0.78, false);
    draw_set_color(make_color_rgb(122, 86, 176));
    draw_rectangle(room_width * 0.15, room_height * 0.59, room_width * 0.33, room_height * 0.66, false);
    draw_set_color(c_white);
    i18n_draw_text(room_width * 0.195, room_height * 0.615, "GYM");

    var _town_x = room_width * 0.40;
    var _town_y = room_height * 0.58;
    if (sprite_exists(route_trainer_sprite)) {
        var _scale_city = 2.4;
        draw_set_color(c_black);
        draw_ellipse(_town_x - 18, _town_y - 7, _town_x + 18, _town_y + 5, false);
        demo_draw_trainer_frame(route_trainer_sprite, 0, 0, _town_x, _town_y, _scale_city);
    } else {
        draw_set_color(c_black);
        draw_ellipse(_town_x - 15, _town_y - 5, _town_x + 15, _town_y + 4, false);
        draw_set_color(make_color_rgb(42, 72, 150));
        draw_rectangle(_town_x - 10, _town_y - 48, _town_x + 10, _town_y - 22, false);
        draw_set_color(make_color_rgb(248, 203, 156));
        draw_rectangle(_town_x - 8, _town_y - 60, _town_x + 8, _town_y - 46, false);
        draw_set_color(make_color_rgb(222, 54, 48));
        draw_rectangle(_town_x - 13, _town_y - 70, _town_x + 13, _town_y - 58, false);
    }
} else if (_is_route_screen) {
    demo_draw_route_travel_background(id, room_width, room_height);
} else if (sprite_exists(background_sprite) && !_is_route_screen) {
    draw_sprite_ext(
        background_sprite,
        0,
        _shake_x,
        _shake_y,
        room_width / sprite_get_width(background_sprite),
        room_height / sprite_get_height(background_sprite),
        0,
        c_white,
        1
    );
} else {
    draw_clear(make_color_rgb(86, 174, 78));
    draw_set_color(make_color_rgb(67, 145, 70));
    draw_rectangle(0, 0, room_width, room_height * 0.18, false);
    draw_set_color(make_color_rgb(104, 192, 88));
    draw_rectangle(0, room_height * 0.18, room_width, room_height, false);

    for (var _patch = 0; _patch < 14; _patch += 1) {
        var _px = ((_patch * 139) mod room_width) - 28;
        var _py = 72 + ((_patch * 83) mod floor(room_height * 0.46));
        draw_set_color((_patch mod 2) == 0 ? make_color_rgb(76, 157, 72) : make_color_rgb(120, 204, 94));
        draw_rectangle(_px, _py, _px + 64, _py + 18, false);
    }
}

if (_is_route_screen && false) {
    var _road_top = room_height * 0.49;
    var _road_bottom = room_height * 0.66;
    draw_set_color(make_color_rgb(68, 145, 70));
    draw_rectangle(0, _road_top - 36, room_width, _road_top, false);
    draw_set_color(make_color_rgb(136, 112, 74));
    draw_rectangle(0, _road_top, room_width, _road_bottom, false);
    draw_set_color(make_color_rgb(158, 132, 86));
    draw_rectangle(0, _road_top + 10, room_width, _road_bottom - 10, false);
    draw_set_color(make_color_rgb(68, 145, 70));
    draw_rectangle(0, _road_bottom, room_width, room_height, false);
    draw_set_color(make_color_rgb(46, 116, 54));
    draw_rectangle(0, _road_top - 8, room_width, _road_top, false);
    draw_rectangle(0, _road_bottom, room_width, _road_bottom + 8, false);
} else if (!_is_route_screen && !_is_city_screen) {
    draw_set_color(make_color_rgb(88, 164, 76));
    draw_rectangle(0, room_height * 0.58, room_width, room_height, false);
    draw_set_color(make_color_rgb(62, 132, 64));
    draw_rectangle(0, room_height * 0.56, room_width, room_height * 0.61, false);
}

if (estado_demo == DemoEstado.ROTA) {
    var _progress = clamp(route_steps / max(1, route_steps_needed), 0, 1);
    var _walk_x = lerp(room_width * 0.18, room_width * 0.72, _progress);
    var _walk_y = room_height * 0.605;

    // Nos biomas montados, o personagem segue a trilha desenhada no chao.
    if (variable_global_exists("rota_caminho") && is_array(global.rota_caminho)) {
        var _cam = global.rota_caminho;
        var _t_cam = lerp(0.16, 0.66, _progress);
        _walk_x = lerp(_cam[0], _cam[2], _t_cam);
        _walk_y = clamp(lerp(_cam[1], _cam[3], _t_cam) + 16, 150, room_height * 0.70);
    }

    if (sprite_exists(route_trainer_sprite)) {
        var _frame = floor(current_time / 140) mod 4;
        var _row = 2;
        var _scale = 2.4;

        draw_set_color(c_black);
        draw_ellipse(_walk_x - 18, _walk_y - 7, _walk_x + 18, _walk_y + 5, false);
        demo_draw_trainer_frame(route_trainer_sprite, _frame, _row, _walk_x, _walk_y, _scale);
    } else {
        var _step = (floor(current_time / 160) mod 2) * 2 - 1;
        draw_set_color(c_black);
        draw_ellipse(_walk_x - 15, _walk_y - 5, _walk_x + 15, _walk_y + 4, false);
        draw_set_color(make_color_rgb(34, 48, 94));
        draw_rectangle(_walk_x - 7, _walk_y - 24, _walk_x - 1, _walk_y - 7 + _step, false);
        draw_rectangle(_walk_x + 2, _walk_y - 24, _walk_x + 8, _walk_y - 7 - _step, false);
        draw_set_color(make_color_rgb(42, 72, 150));
        draw_rectangle(_walk_x - 10, _walk_y - 48, _walk_x + 10, _walk_y - 22, false);
        draw_set_color(make_color_rgb(248, 203, 156));
        draw_rectangle(_walk_x - 8, _walk_y - 60, _walk_x + 8, _walk_y - 46, false);
        draw_set_color(make_color_rgb(222, 54, 48));
        draw_rectangle(_walk_x - 13, _walk_y - 70, _walk_x + 13, _walk_y - 58, false);
        draw_rectangle(_walk_x - 7, _walk_y - 78, _walk_x + 7, _walk_y - 68, false);
        draw_set_color(make_color_rgb(248, 248, 248));
        draw_rectangle(_walk_x - 13, _walk_y - 58, _walk_x + 13, _walk_y - 54, false);
        draw_set_color(make_color_rgb(34, 48, 94));
        draw_rectangle(_walk_x - 16, _walk_y - 43, _walk_x - 10, _walk_y - 25, false);
        draw_rectangle(_walk_x + 10, _walk_y - 43, _walk_x + 16, _walk_y - 25, false);
    }
}

if (estado_demo == DemoEstado.BATALHA || estado_demo == DemoEstado.CAPTURA) {
    if (instance_exists(player_inst)) {
        demo_draw_battle_criatura_instance(player_inst);
    }

    if (instance_exists(enemy_inst)) {
        var _gym_trainer_should_draw = battle_trainer_active || (battle_context == "ginasio") || (gym_battle_city_index > 0 && !demo_cidade_ginasio_vencido(gym_battle_city_index));

        if (_gym_trainer_should_draw) {
            demo_draw_gym_trainer(gym_trainer_sprite, enemy_inst.x + 128, enemy_inst.y - 22);
        }

        demo_draw_battle_criatura_instance(enemy_inst);
    }

    if (estado_demo == DemoEstado.CAPTURA) {
        demo_draw_capture_animation(id);
    }
}
