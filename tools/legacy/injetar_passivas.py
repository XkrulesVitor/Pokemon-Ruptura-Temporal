import os
import re

gml_file = r"d:\VITOR\Jogos\PokemonRogueLike\scripts\scr_pokemon_data\scr_pokemon_data.gml"

# Código das passivas
passivas_code = """
//========================================================
// SISTEMA DE PASSIVAS (GERADO)
//========================================================
function pokemon_tipo_string(_tipo) {
    switch(_tipo) {
        case PokemonTipo.NORMAL: return "normal";
        case PokemonTipo.FIRE: return "fire";
        case PokemonTipo.WATER: return "water";
        case PokemonTipo.GRASS: return "grass";
        case PokemonTipo.ELECTRIC: return "electric";
        case PokemonTipo.ICE: return "ice";
        case PokemonTipo.FIGHTING: return "fighting";
        case PokemonTipo.POISON: return "poison";
        case PokemonTipo.GROUND: return "ground";
        case PokemonTipo.FLYING: return "flying";
        case PokemonTipo.PSYCHIC: return "psychic";
        case PokemonTipo.BUG: return "bug";
        case PokemonTipo.ROCK: return "rock";
        case PokemonTipo.GHOST: return "ghost";
        case PokemonTipo.DRAGON: return "dragon";
        case PokemonTipo.DARK: return "dark";
        case PokemonTipo.STEEL: return "steel";
        case PokemonTipo.FAIRY: return "fairy";
        default: return "normal";
    }
}

global.passivas_db = {
"""

tipos = ["normal", "fire", "water", "grass", "electric", "ice", "fighting", "poison", 
         "ground", "flying", "psychic", "bug", "rock", "ghost", "dragon", "dark", "steel", "fairy"]
focos = ["ataque", "defesa", "velocidade"]

desc_map = {
    "normal_ataque": "Dano de ataques basicos aumenta em 15% se atacou o mesmo alvo 3x.",
    "normal_defesa": "Ignora debuffs leves de status ao ficar abaixo de 50% HP.",
    "normal_velocidade": "Se ficar 4s sem atacar, a proxima skill eh instantanea.",
    "fire_ataque": "Dano critico +10% contra alvos Queimando.",
    "fire_defesa": "Toma 10% a menos de dano de alvos Queimando.",
    "fire_velocidade": "Ataques basicos em alvos sem armadura aceleram habilidades em 5%.",
    "water_ataque": "Habilidades causam +10% dano se o oponente tiver o CD maior que o seu.",
    "water_defesa": "Cria escudo de 2% ao aplicar Molhado.",
    "water_velocidade": "Ao ser atingido, tem chance de resetar 1s de um golpe de Agua.",
    "grass_ataque": "Inimigos Enraizados sofrem +5% dano verdadeiro basico.",
    "grass_defesa": "Cura +2% HP max sempre que aplicar debuff de Planta.",
    "grass_velocidade": "Cada vez que curar, reduz Cooldown Global em 0.2s.",
    "electric_ataque": "Causa 10% a mais de dano se o alvo falhou um ataque recentemente.",
    "electric_defesa": "Quando atacado, tem 5% de chance de Cegar o atacante.",
    "electric_velocidade": "Se o alvo for Cegado, ganha um burst de 15% MoveSpeed.",
    "ice_ataque": "Ataques basicos contra alvos com Frio causam dano duplo de quebra.",
    "ice_defesa": "Aumenta a Armadura em 10% se houver Granizo no campo.",
    "ice_velocidade": "Retarda o tempo de canalizacao do inimigo em 5% por hit.",
    "fighting_ataque": "Ganha 1% de Dano acumulativo para cada ataque consecutivo no mesmo alvo.",
    "fighting_defesa": "Ao bloquear ou esquivar, cura 3% do HP perdido.",
    "fighting_velocidade": "Inimigos com Postura Quebrada sao atrasados em 0.3s a cada hit.",
    "poison_ataque": "Inimigos recebem +10% de dano final de todos os DoTs.",
    "poison_defesa": "Gera regeneracao de vida baseada na quantidade de veneno em campo.",
    "poison_velocidade": "Movimenta-se 10% mais rapido para cada inimigo Envenenado.",
    "ground_ataque": "Causa 10% a mais de dano contra alvos com Areia Movedica.",
    "ground_defesa": "Dano fisico recebido eh reduzido em 5% (15% se estiver Aterrado).",
    "ground_velocidade": "Passos pesados reduzem a velocidade de recarga do inimigo ao longo do tempo.",
    "flying_ataque": "Dano de Mergulho aumenta em 15% nos primeiros 5s de luta.",
    "flying_defesa": "Evasao aumenta em 10% quando tem menos de 30% de HP.",
    "flying_velocidade": "Cada habilidade voadora conjurada reduz o proprio CD em 0.1s.",
    "psychic_ataque": "Ataques psiquicos causam lentidao mental, aumentando CDs do inimigo.",
    "psychic_defesa": "Cria um escudo cinetico automatico ao receber dano critico.",
    "psychic_velocidade": "Inverte buffs de velocidade do inimigo para lentidao temporaria.",
    "bug_ataque": "O dano de Picada escala com o numero de habilidades lancadas na batalha.",
    "bug_defesa": "Quando sofre controle de grupo, fortalece a armadura natural em 15%.",
    "bug_velocidade": "Cada ataque basico reduz cooldowns da mesma tipagem em 0.05s.",
    "rock_ataque": "Ignora 10% da defesa inimiga passivamente.",
    "rock_defesa": "Dano verdadeiro ou critico recebido eh limitado a 15% do seu HP Max.",
    "rock_velocidade": "Habilidades com CD acima de 10s carregam 10% mais rapido.",
    "ghost_ataque": "Ataques basicos aumentam o dano em 1% para cada segundo de luta.",
    "ghost_defesa": "Toma 15% a menos de dano nos primeiros 5 segundos da partida.",
    "ghost_velocidade": "Evasivos: Tem pequena chance de anular completamente habilidades altas.",
    "dragon_ataque": "Seu dano aumenta em ate 20% dependendo de quanto HP perdeu.",
    "dragon_defesa": "Resiste a debuffs de reducao de status.",
    "dragon_velocidade": "Habilidades de dano macico carregam um pouco mais rapido quanto mais o HP desce.",
    "dark_ataque": "Dano aumentado em 15% em alvos sob qualquer debuff.",
    "dark_defesa": "Esquivas convertem 5% do HP do alvo para si.",
    "dark_velocidade": "Aproveita o CD alto do alvo para atacar mais rapido.",
    "steel_ataque": "Converte 5% da Defesa total em bonus de Ataque base.",
    "steel_defesa": "Bloqueia e reflete passivamente 5% do dano basico recebido.",
    "steel_velocidade": "Nao sofre penalidades de lentidao por terreno ou status leves.",
    "fairy_ataque": "Punicoes e habilidades Ofuscantes tem +10% de eficiendia.",
    "fairy_defesa": "Luz Purificadora aumenta curas recebidas em 15%.",
    "fairy_velocidade": "Aplica um Ofuscado passivo ao ser alvo de finalizadores."
}

def buff_numbers(m):
    val = float(m.group(1))
    return str(int(val * 1.5) if val >= 5 else int(val * 2))

for t in tipos:
    for f in focos:
        chave = f"{t}_{f}"
        desc1 = desc_map.get(chave, f"Passiva padrao de {t} ({f}).")
        desc2 = re.sub(r'(\d+)', buff_numbers, desc1)
        if desc1 == desc2:
            desc2 = desc1 + " (Efeito Dobrado)."
            
        passivas_code += f'    passiva_{t}_{f}_1 : {{ Nivel: 1, Descricao: "{desc1}" }},\n'
        passivas_code += f'    passiva_{t}_{f}_2 : {{ Nivel: 2, Descricao: "{desc2}" }},\n'

passivas_code += "};\n\n"
passivas_code += """function pokemon_get_passiva_data(_passiva_id) {
    if (variable_struct_exists(global.passivas_db, _passiva_id)) {
        return variable_struct_get(global.passivas_db, _passiva_id);
    }
    return undefined;
}
"""

with open(gml_file, "a", encoding="utf-8") as file:
    file.write(passivas_code)

print("Passivas injetadas!")
