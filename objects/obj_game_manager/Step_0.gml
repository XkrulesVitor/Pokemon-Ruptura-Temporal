if (keyboard_check_pressed(vk_space)) {
    if (global.pokedex_overlay_aberto) {
        exit;
    }

    battle_time_scale_toggle_pause();
    time_scale_antes_overlay = global.time_scale_preferido;
}

if (keyboard_check_pressed(vk_tab) && !global.pokedex_overlay_aberto) {
    battle_time_scale_cycle();
    time_scale_antes_overlay = global.time_scale_preferido;
}

if (keyboard_check_pressed(ord("1"))) {
    time_scale_antes_overlay = 1.0;
    global.time_scale_preferido = 1.0;
    if (!global.pokedex_overlay_aberto) {
        battle_time_scale_set(1.0, true);
    }
}

if (keyboard_check_pressed(ord("2"))) {
    time_scale_antes_overlay = 1.5;
    global.time_scale_preferido = 1.5;
    if (!global.pokedex_overlay_aberto) {
        battle_time_scale_set(1.5, true);
    }
}

if (keyboard_check_pressed(ord("3"))) {
    time_scale_antes_overlay = 2.0;
    global.time_scale_preferido = 2.0;
    if (!global.pokedex_overlay_aberto) {
        battle_time_scale_set(2.0, true);
    }
}

if (keyboard_check_pressed(ord("4"))) {
    time_scale_antes_overlay = 3.0;
    global.time_scale_preferido = 3.0;
    if (!global.pokedex_overlay_aberto) {
        battle_time_scale_set(3.0, true);
    }
}

if (keyboard_check_pressed(ord("P"))) {
    global.pokedex_overlay_aberto = !global.pokedex_overlay_aberto;

    if (global.pokedex_overlay_aberto) {
        time_scale_antes_overlay = global.time_scale;
        global.pokedex_overlay_time_scale_anterior = global.time_scale;
        global.time_scale = 0;
        pokedex_garantir();
    } else {
        global.time_scale = time_scale_antes_overlay;
        pokedex_ui_liberar_sprites();
    }
}

if (global.pokedex_overlay_aberto) {
    pokedex_ui_step();
}

global.velocidade_jogo = global.time_scale;
autoteste_step();
