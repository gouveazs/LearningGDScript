extends RefCounted

# Este arquivo não é ligado a uma cena. Main.gd o chama apenas para executar
# exemplos pequenos e concentrados de sintaxe. Experimente editar os valores,
# executar o projeto e observar o painel Output da Godot.


static func executar() -> void:
	_exemplo_de_variaveis_e_funcoes()
	_exemplo_de_colecoes()
	_exemplo_de_match()


static func _exemplo_de_variaveis_e_funcoes() -> void:
	var wave: int = 1
	const INIMIGOS_POR_WAVE: int = 3
	var total: int = calcular_inimigos(wave, INIMIGOS_POR_WAVE)

	print("Wave %d terá %d inimigos." % [wave, total])


static func calcular_inimigos(wave: int, inimigos_base: int) -> int:
	# O operador "**" é exponenciação. Aqui ele não é necessário, mas fica como
	# uma ideia para você testar progressões de dificuldade depois.
	return wave * inimigos_base


static func _exemplo_de_colecoes() -> void:
	# Array é parecido com std::vector. Ele mantém uma lista ordenada de valores.
	var enemies: Array[String] = ["Esqueleto", "Goblin"]
	enemies.append("Morcego")

	# Dictionary guarda pares chave -> valor; parecido com um mapa/hash map.
	var princess: Dictionary = {
		"name": "Princesa",
		"health": 100,
	}

	print("Inimigos: %s" % ", ".join(enemies))
	print("%s tem %d de vida." % [princess["name"], princess["health"]])


static func _exemplo_de_match() -> void:
	# match cumpre papel semelhante a switch no C++, mas pode ser bem expressivo.
	var state: String = "preparing"

	match state:
		"preparing":
			print("A próxima wave está sendo preparada.")
		"active":
			print("A princesa está sob ataque!")
		_:
			# "_" é o caso padrão: executa se nenhum outro caso corresponder.
			print("Estado desconhecido.")
