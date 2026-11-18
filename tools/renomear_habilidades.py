"""Renomeia (so o nome exibido) habilidades cujo nome vinha de golpes de Pokemon."""
import glob, os, re, sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TROCAS = {
    "Aero Ace": "Asa Certeira", "Aqua Jet": "Jato Veloz", "Gyro Ball": "Giro de Aco",
    "Psybeam": "Raio Mental", "Twister": "Torvelinho", "Jab": "Estocada",
    "Defesa Curl": "Enrolar", "Nucleo Registeel": "Nucleo Blindado", "Troca Volt": "Recuo Eletrico",
    "Tesoura X": "Tesoura Cruzada", "Giga Dreno": "Dreno Profundo", "Mega Dreno": "Dreno Vigoroso",
    "Semente Sanguessuga": "Semente Parasita", "Furia do Dragao": "Ira Ancestral",
    "Golpe Karate": "Golpe de Mao Aberta", "Venenochoque": "Choque Venenoso",
    "Psicochoque": "Impacto Psiquico", "Soco Bala": "Soco Projetil", "Quebra-Tijolo": "Quebra-Pedra",
    "Jogo Sujo": "Golpe Traicoeiro", "Meteoro Draconico": "Estrela Draconica",
    "Hidro Bomba": "Canhao d'Agua", "Lanca-Chamas": "Jorro de Chamas", "Surfar": "Onda Montante",
    "Combate Proximo": "Corpo a Corpo", "Cabeca de Ferro": "Testada de Ferro",
    "Bater Corpo": "Encontrao", "Pulso do Dragao": "Pulso Ancestral", "Folha Navalha": "Folha Cortante",
    "Raio Solar": "Feixe Solar",
}

def main():
    aplicar = "--aplicar" in sys.argv
    total = 0
    for arq in glob.glob(os.path.join(RAIZ, "scripts", "*", "*.gml")):
        s = open(arq, encoding="utf-8", newline="").read()
        novo = s
        for a, b in TROCAS.items():
            # nome exibido = 2o argumento de HabilidadeData, ou qualquer string identica
            novo = re.sub(r'(new HabilidadeData\("[^"]+", )"%s"' % re.escape(a), r'\1"%s"' % b, novo)
            novo = novo.replace('"%s"' % a, '"%s"' % b)
        if novo != s:
            n = sum(s.count('"%s"' % a) for a in TROCAS)
            total += n
            print(os.path.relpath(arq, RAIZ), n)
            if aplicar:
                open(arq, "w", encoding="utf-8", newline="").write(novo)
    print("trocas:", total, "(aplicado)" if aplicar else "(simulacao)")

if __name__ == "__main__":
    main()
