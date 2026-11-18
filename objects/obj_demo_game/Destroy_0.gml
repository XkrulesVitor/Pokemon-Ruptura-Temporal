demo_cleanup_battle(id);
pokemon_sprite_liberar(background_sprite);
pokemon_sprite_liberar(title_bg_sprite);
pokemon_sprite_liberar(title_start_sprite);
pokemon_sprite_liberar(title_splash_sprite);
pokemon_sprite_liberar(title_city_sprite);
pokemon_sprite_liberar(title_scene_bg_sprite);
pokemon_sprite_liberar(title_scene_base0_sprite);
pokemon_sprite_liberar(title_scene_base1_sprite);
pokemon_sprite_liberar(title_giovanni_sprite);
pokemon_sprite_liberar(title_rocketboss_sprite);
pokemon_sprite_liberar(title_ultra_beam_sprite);
pokemon_sprite_liberar(title_psycho_cut_sprite);
pokemon_sprite_liberar(title_cosmo_sprite);
pokemon_sprite_liberar(title_burst_sprite);
pokemon_sprite_liberar(title_electric1_sprite);
pokemon_sprite_liberar(title_electric2_sprite);
pokemon_sprite_liberar(space_fragment_icon_sprite);
if (variable_global_exists("space_fragment_icon_sprite")) {
    if (global.space_fragment_icon_sprite != space_fragment_icon_sprite) {
        pokemon_sprite_liberar(global.space_fragment_icon_sprite);
    }

    global.space_fragment_icon_sprite = -1;
}
pokemon_sprite_liberar(intro_bg_sprite);
pokemon_sprite_liberar(intro_lab_bg_sprite);
pokemon_sprite_liberar(intro_lab_base0_sprite);
pokemon_sprite_liberar(intro_lab_base1_sprite);
pokemon_sprite_liberar(intro_field_bg_sprite);
pokemon_sprite_liberar(intro_field_base0_sprite);
pokemon_sprite_liberar(intro_field_base1_sprite);
pokemon_sprite_liberar(intro_field_night_bg_sprite);
pokemon_sprite_liberar(intro_field_night_base0_sprite);
pokemon_sprite_liberar(intro_field_night_base1_sprite);
pokemon_sprite_liberar(intro_destroyed_horizon_day_sprite);
pokemon_sprite_liberar(intro_destroyed_horizon_night_sprite);
pokemon_sprite_liberar(intro_mewtwo_back_sprite);
pokemon_sprite_liberar(intro_mewtwo_front_sprite);
pokemon_sprite_liberar(intro_mew_back_sprite);
pokemon_sprite_liberar(intro_mew_front_sprite);
pokemon_sprite_liberar(intro_celebi_back_sprite);
pokemon_sprite_liberar(intro_celebi_front_sprite);

if (variable_instance_exists(id, "city_sprites") && is_array(city_sprites)) {
    for (var _city_spr_i = 0; _city_spr_i < array_length(city_sprites); _city_spr_i += 1) {
        pokemon_sprite_liberar(city_sprites[_city_spr_i]);
    }
}

pokemon_sprite_liberar(route_background_sprite);

if (variable_instance_exists(id, "route_theme_sprites") && is_struct(route_theme_sprites)) {
    var _route_theme_keys = variable_struct_get_names(route_theme_sprites);

    for (var _route_theme_i = 0; _route_theme_i < array_length(_route_theme_keys); _route_theme_i += 1) {
        pokemon_sprite_liberar(variable_struct_get(route_theme_sprites, _route_theme_keys[_route_theme_i]));
    }
}

if (variable_instance_exists(id, "route_fx_sprites") && is_struct(route_fx_sprites)) {
    var _route_fx_keys = variable_struct_get_names(route_fx_sprites);

    for (var _route_fx_i = 0; _route_fx_i < array_length(_route_fx_keys); _route_fx_i += 1) {
        pokemon_sprite_liberar(variable_struct_get(route_fx_sprites, _route_fx_keys[_route_fx_i]));
    }
}

pokemon_sprite_liberar(route_trainer_sprite);
pokemon_sprite_liberar(professor_sprite);
pokemon_sprite_liberar(mae_sprite);

if (variable_instance_exists(id, "dialog_sprites_cidade") && is_array(dialog_sprites_cidade)) {
    for (var _dialog_spr_i = 0; _dialog_spr_i < array_length(dialog_sprites_cidade); _dialog_spr_i += 1) {
        var _dialog_spr = dialog_sprites_cidade[_dialog_spr_i];

        if (_dialog_spr != professor_sprite && _dialog_spr != mae_sprite) {
            pokemon_sprite_liberar(_dialog_spr);
        }
    }
}

pokemon_sprite_liberar(gym_trainer_sprite);
demo_liberar_sprite_cache();
demo_liberar_item_icon_cache();
demo_liberar_pokemon_icon_cache();
demo_liberar_effect_sprite_cache();
