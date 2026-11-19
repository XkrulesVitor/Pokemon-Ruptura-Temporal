persistent = true;

// Mantem um unico objeto de persistencia vivo entre salas.
if (instance_number(obj_game_manager) > 1) {
    instance_destroy();
    exit;
}

battle_ui_init();
autoteste_iniciar();

if (!variable_global_exists("run")) {
    global.run = undefined;
}

if (!variable_global_exists("bestiario")) {
    global.bestiario = criatura_db_criar();
}

bestiario_inicializar(global.bestiario);

if (!variable_global_exists("time_scale")) {
    global.time_scale = 1.0;
}

if (!variable_global_exists("time_scale_preferido")) {
    global.time_scale_preferido = battle_time_scale_normalizar(global.time_scale);
}

if (!variable_global_exists("velocidade_jogo")) {
    global.velocidade_jogo = global.time_scale;
}

if (!variable_global_exists("bestiario_overlay_aberto")) {
    global.bestiario_overlay_aberto = false;
}

time_scale_antes_overlay = global.time_scale_preferido;
bestiario_ui_sprites = {};
