criatura_data = undefined;
criatura_id = -1;
criatura_nome = "";

hp_atual = 0;
hp_max = 0;
attack = 0;
defense = 0;
stat_speed = 0;
level = 1;
genero = "";
is_shiny = false;
is_female = false;
capture_chance_bonus = 0;
ui_slot = 0;

habilidades_equipadas = array_create(4, noone);
status_map = {};

lado_batalha = LadoBatalha.ALIADO;
batalha_ativo = true;
vivo = true;

sprite_dynamic = -1;
sprite_idle = -1;
sprite_ataque = -1;
sprite_dano = -1;
estado_visual = ESTADO.IDLE;
estado_visual_timer = 0;
visual_offset_x = 0;
visual_flash = 0;

image_speed = 0;
