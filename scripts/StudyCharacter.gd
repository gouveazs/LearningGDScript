class_name StudyCharacter
extends RefCounted

# "class_name" registra esta classe com um nome reutilizável no projeto.
# RefCounted é uma boa base para classes de lógica que não aparecem na cena.
# Mais tarde, personagens visuais normalmente serão CharacterBody3D + Nodes filhos.

signal health_changed(previous_health: int, current_health: int)

var display_name: String
var max_health: int
var health: int
var attack: int


func _init(new_name: String, new_max_health: int, new_attack: int) -> void:
	# _init() é o construtor da classe. Ele roda ao chamar StudyCharacter.new(...).
	display_name = new_name
	max_health = new_max_health
	health = max_health
	attack = new_attack


func take_damage(amount: int) -> void:
	# max(valor, minimo) impede que a vida fique negativa.
	# "previous_health" é útil para HUD, efeitos visuais e logs.
	var previous_health: int = health
	health = max(health - amount, 0)
	health_changed.emit(previous_health, health)


func heal(amount: int) -> void:
	# min(valor, maximo) impede cura acima da vida máxima.
	var previous_health: int = health
	health = min(health + amount, max_health)
	health_changed.emit(previous_health, health)


func is_alive() -> bool:
	# Funções com retorno explícito deixam clara a intenção de quem lê o código.
	return health > 0
