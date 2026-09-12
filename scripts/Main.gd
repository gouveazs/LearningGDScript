extends Node

# Este é o script ligado ao Node raiz da cena Main.tscn.
# Todo script de cena costuma estender um tipo de Node: aqui usamos o Node
# básico porque esta primeira cena não precisa de movimento, física ou desenho.

# "preload" carrega o arquivo quando este script é carregado.
# Como StudyCharacter usa "class_name", também seria possível escrever
# diretamente StudyCharacter.new(...). Deixamos o preload explícito para
# você enxergar de onde a classe vem.
const StudyCharacter = preload("res://scripts/StudyCharacter.gd")
const FundamentalsExample = preload("res://scripts/exemplos/01_fundamentos.gd")


func _ready() -> void:
	# _ready() é chamado uma vez quando o Node entra na árvore de cena.
	# É um ótimo lugar para inicializar variáveis, conectar sinais e testar lógica.
	print("=== LearningGDScript ===")

	FundamentalsExample.executar()
	_exemplo_de_classe_e_sinal()


func _exemplo_de_classe_e_sinal() -> void:
	# ".new()" cria um objeto a partir de uma classe.
	var hero: StudyCharacter = StudyCharacter.new("Gouvea", 100, 15)

	# Um signal é um aviso emitido por um objeto. O personagem não precisa
	# conhecer a Main; ela escolhe ouvir o evento conectando uma função a ele.
	hero.health_changed.connect(_on_health_changed)

	print("%s começa com %d de vida e %d de ataque." % [hero.display_name, hero.health, hero.attack])
	hero.take_damage(25)
	hero.heal(10)


func _on_health_changed(previous_health: int, current_health: int) -> void:
	# Esta função é chamada automaticamente toda vez que o signal é emitido.
	print("Vida mudou: %d -> %d" % [previous_health, current_health])
