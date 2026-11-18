persistent = true;

// Mantem um unico objeto de persistencia vivo entre salas.
if (instance_number(obj_game_manager) > 1) {
    instance_destroy();
    exit;
}

// Inicializa flags, eventos e rastreamento de missoes da run.
event_manager_init();
battle_ui_init();
autoteste_iniciar();

if (!variable_global_exists("run")) {
    global.run = undefined;
}

if (!variable_global_exists("pokedex")) {
    global.pokedex = pokemon_db_criar();
}

pokedex_inicializar(global.pokedex);

if (!variable_global_exists("time_scale")) {
    global.time_scale = 1.0;
}

if (!variable_global_exists("time_scale_preferido")) {
    global.time_scale_preferido = battle_time_scale_normalizar(global.time_scale);
}

if (!variable_global_exists("velocidade_jogo")) {
    global.velocidade_jogo = global.time_scale;
}

if (!variable_global_exists("pokedex_overlay_aberto")) {
    global.pokedex_overlay_aberto = false;
}

time_scale_antes_overlay = global.time_scale_preferido;
pokedex_ui_sprites = {};
