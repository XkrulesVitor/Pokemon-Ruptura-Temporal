aliados_campo = [];
inimigos_campo = [];

pos_aliado_x = room_width * 0.25;
pos_inimigo_x = room_width * 0.75;
pos_chao_y = room_height * 0.65;

if (!instance_exists(obj_battle_ui)) {
    instance_create_layer(0, 0, "Instances", obj_battle_ui);
}
