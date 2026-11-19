demo_inicializar_globals();

estado_demo = DemoEstado.MENU;
meta_progresso = demo_meta_carregar();
demo_meta_sincronizar_globals(meta_progresso);
meta_inicio_aplicado = false;
meta_shop_scroll = 0;
starter_ids = demo_meta_starter_roll(meta_progresso);
starter_sprites = [];

background_sprite = demo_asset_sprite("datafiles/sprites/interface/fundo.png");
title_bg_sprite = demo_asset_sprite("datafiles/sprites/interface/titulo_fundo.png");
title_start_sprite = demo_asset_sprite("datafiles/sprites/interface/titulo_iniciar.png");
title_splash_sprite = demo_asset_sprite("datafiles/sprites/interface/titulo_splash.png");
title_city_sprite = demo_asset_sprite("datafiles/sprites/interface/titulo_cidade.png");
title_scene_bg_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_fenda_fundo.png");
title_scene_base0_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_fenda_base0.png");
title_scene_base1_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_fenda_base1.png");
// Chefe do Sindicato Eclipse na tela de titulo (ultimo lider do mundo.json).
title_giovanni_sprite = -1;
title_rocketboss_sprite = -1;
title_ultra_beam_sprite = demo_asset_sprite("datafiles/sprites/efeitos/raio_ultra.png");
title_psycho_cut_sprite = demo_asset_sprite("datafiles/sprites/efeitos/corte_psiquico.png");
title_cosmo_sprite = demo_asset_sprite("datafiles/sprites/efeitos/cosmo.png");
title_burst_sprite = demo_asset_sprite("datafiles/sprites/efeitos/explosao.png");
title_electric1_sprite = demo_asset_sprite("datafiles/sprites/efeitos/eletrico1.png");
title_electric2_sprite = demo_asset_sprite("datafiles/sprites/efeitos/eletrico2.png");
space_fragment_icon_sprite = demo_asset_sprite("datafiles/sprites/interface/fragmento_tempo.png");
global.space_fragment_icon_sprite = space_fragment_icon_sprite;
intro_bg_sprite = demo_asset_sprite("datafiles/sprites/interface/intro_fundo.png");
intro_lab_bg_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_lab_fundo.png");
intro_lab_base0_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_lab_base0.png");
intro_lab_base1_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_lab_base1.png");
intro_field_bg_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_campo_fundo.png");
intro_field_base0_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_campo_base0.png");
intro_field_base1_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_campo_base1.png");
intro_field_night_bg_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_noite_fundo.png");
intro_field_night_base0_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_noite_base0.png");
intro_field_night_base1_sprite = demo_asset_sprite("datafiles/sprites/interface/cenario_noite_base1.png");
intro_destroyed_horizon_day_sprite = demo_asset_sprite("datafiles/sprites/cutscene/intro_destroyed_horizon_day.png");
intro_destroyed_horizon_night_sprite = demo_asset_sprite("datafiles/sprites/cutscene/intro_destroyed_horizon_night.png");
// Personagens da intro: chefe final e guardioes definidos em mundo.json.
// (os nomes das variaveis foram mantidos para nao mexer no resto do codigo da intro)
intro_mewtwo_back_sprite = criatura_sprite_carregar_pose(demo_intro_id_chefe(), "back", -1);
intro_mewtwo_front_sprite = criatura_sprite_carregar_pose(demo_intro_id_chefe(), "front", -1);
intro_mew_back_sprite = criatura_sprite_carregar_pose(demo_intro_id_guardiao(0), "back", -1);
intro_mew_front_sprite = criatura_sprite_carregar_pose(demo_intro_id_guardiao(0), "front", -1);
intro_celebi_back_sprite = criatura_sprite_carregar_pose(demo_intro_id_guardiao(1), "back", -1);
intro_celebi_front_sprite = criatura_sprite_carregar_pose(demo_intro_id_guardiao(1), "front", -1);
city_sprite_paths = []; // mapas vem de mundo.json (sprite_cidade) ou viram placeholder
city_sprites = array_create(16, -1);
city_pallet_sprite = -1;
route_background_sprite = demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_campo.png");
route_theme_sprites = {
    campo: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_campo.png"),
    grama: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_grama.jpg"),
    bosque: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_bosque.png"),
    floresta_noite: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_floresta_noite.png"),
    fantasma: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_fantasma.png"),
    cemiterio: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_cemiterio.jpg"),
    montanha: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_montanha.png"),
    montanha2: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_montanha2.jpg"),
    gelo: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_gelo.png"),
    gelo2: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_gelo2.jpg"),
    vulcao: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_vulcao.png"),
    agua: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_agua.png"),
    pantano: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_pantano.png"),
    sucata: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_sucata.png"),
    ruinas: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_ruinas.png"),
    floral: demo_asset_sprite("datafiles/sprites/overworld/routes/route_theme_floral.jpg")
};
route_fx_sprites = {
    clouds: demo_asset_sprite("datafiles/sprites/overworld/routes/route_fx_clouds.png"),
    dark_clouds: demo_asset_sprite("datafiles/sprites/overworld/routes/route_fx_dark_clouds.png"),
    rain: demo_asset_sprite("datafiles/sprites/overworld/routes/route_fx_rain.png"),
    snow: demo_asset_sprite("datafiles/sprites/overworld/routes/route_fx_snow.png"),
    fog: demo_asset_sprite("datafiles/sprites/overworld/routes/route_fx_fog.png"),
    fire: demo_asset_sprite("datafiles/sprites/overworld/routes/route_fx_fire_sheet.png"),
    sparks: demo_asset_sprite("datafiles/sprites/overworld/routes/route_fx_spark_sheet.png"),
    lightning: demo_asset_sprite("datafiles/sprites/overworld/routes/route_fx_lightning_sheet.png")
};
route_trainer_sprite = demo_asset_sprite("datafiles/sprites/treinadores/jogador_andando.png");
route_trainer_placeholder = !sprite_exists(route_trainer_sprite);
if (route_trainer_placeholder) {
    route_trainer_sprite = placeholder_andarilho_folha(progresso().Skin);
}
professor_sprite = demo_trainer_sprite_carregar_generico("professor.png");
mae_sprite = demo_trainer_sprite_carregar_generico("mae.png");
starter_id = -1;
player_criatura_data = undefined;
enemy_criatura_data = undefined;
player_party = [];
player_party_active_index = 0;
player_inst = noone;
enemy_inst = noone;
battle_manager = noone;
gym_trainer_sprite = -1;
battle_trainer_active = false;
battle_trainer_name = "";
route_trainer_data = undefined;
trainer_party = [];
trainer_party_index = 0;
route_trainer_encountered = false;
route_trainer_step = -1;
battle_reward_xp_base_total = 0;
battle_reward_money_total = 0;
battle_reward_ganhos = [];
battle_reward_items = [];
route_steps = 0;
kanto_cidades = demo_kanto_cidades_criar();
title_giovanni_sprite = demo_trainer_sprite_carregar(kanto_cidades[array_length(kanto_cidades) - 1].Lider);
ginasios_vencidos = array_create(array_length(kanto_cidades), false);
cidade_eventos_vistos = array_create(array_length(kanto_cidades), false);
rota_blocos_db = demo_rota_blocos_criar();
rota_drafts = array_create(array_length(rota_blocos_db), undefined);
rota_escolhas = array_create(array_length(rota_blocos_db), "");
rota_atual = undefined;
dialog_sprites_cidade = [mae_sprite, professor_sprite];
for (var _cidade_dialogo = 2; _cidade_dialogo < array_length(kanto_cidades); _cidade_dialogo += 1) {
    array_push(dialog_sprites_cidade, demo_trainer_sprite_carregar(kanto_cidades[_cidade_dialogo].Lider));
}
cidade_index = 0;
rota_origem_index = 0;
rota_destino_index = 0;
saida_destino_index = -1;
route_steps_needed = irandom_range(3, 6);
cidade_nome = "Vila Alvorada";
dinheiro = 0;
inventario = demo_inventario_criar();
mochila_contexto_anterior = DemoEstado.CIDADE;
mae_presente_entregue = false;
professor_carvalho_visto = false;
battle_context = "";
gym_battle_city_index = -1;
message = "Menu inicial";
result_timer = 0;
intro_timer = 0;
intro_step = 0;
game_over_timer = 0;
vitoria_final_timer = 0;
estado_anterior_save = DemoEstado.MENU;
missoes = {};
evento_titulo = "";
vitoria_final_fragmentos = 0;
capture_anim = undefined;
capture_pending_item = "";
capture_pending_success = false;
capture_replace_open = false;
capture_replace_criatura = undefined;
battle_participants = [];
battle_result_info = undefined;

if (!instance_exists(obj_game_manager)) {
    instance_create_layer(0, 0, "Instances", obj_game_manager);
}
