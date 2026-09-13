extends Node

# Resolução comentada do desafio do Dia 1.
# Ela usa ações pré-definidas porque input de jogador ainda não é assunto desta aula.

enum PlayerAction { ATTACK, DEFEND, HEAL }

const PLAYER_MAX_HEALTH: int = 100
const MONSTER_MAX_HEALTH: int = 100
const PLAYER_HEAL_AMOUNT: int = 18
const DEFENSE_BONUS: int = 15

var player_name: String = "Gouvea"
var player_health: int = PLAYER_MAX_HEALTH
var player_attack: int = 20
var player_defense: int = 8
var player_is_defending: bool = false

var monster_name: String = "Antedegmon"
var monster_health: int = MONSTER_MAX_HEALTH
var monster_attack: int = 16
var monster_defense: int = 6
var monster_is_defending: bool = false

# Em vez de pedir teclado agora, a batalha consome esta lista na ordem.
# Quando a lista acabar, o jogador ataca por padrão.
var planned_player_actions: Array[PlayerAction] = [
	PlayerAction.ATTACK,
	PlayerAction.DEFEND,
	PlayerAction.HEAL,
	PlayerAction.ATTACK,
	PlayerAction.ATTACK,
]
var next_action_index: int = 0
var current_turn: int = 1


func _ready() -> void:
	# _ready() é o ponto de entrada desta Scene.
	start_battle()


func start_battle() -> void:
	print("=== Combate por turnos ===")
	print("Um %s selvagem apareceu!" % monster_name)
	print_status()

	# A luta continua enquanto os dois estiverem vivos.
	while player_health > 0 and monster_health > 0:
		print("\n--- Turno %d ---" % current_turn)

		player_turn()
		if monster_health <= 0:
			break # Não deixa um monstro morto atacar.

		monster_turn()
		print_status()
		current_turn += 1

	print_battle_result()


func player_turn() -> void:
	var action: PlayerAction = get_next_player_action()

	match action:
		PlayerAction.ATTACK:
			var defense: int = monster_defense
			if monster_is_defending:
				defense += DEFENSE_BONUS

			var damage: int = calculate_damage(player_attack, defense)
			monster_health = max(monster_health - damage, 0)
			monster_is_defending = false # A defesa valeu para este ataque.
			print("%s atacou e causou %d de dano." % [player_name, damage])

		PlayerAction.DEFEND:
			player_is_defending = true
			print("%s assumiu posição de defesa." % player_name)

		PlayerAction.HEAL:
			var previous_health: int = player_health
			player_health = min(player_health + PLAYER_HEAL_AMOUNT, PLAYER_MAX_HEALTH)
			var healed_amount: int = player_health - previous_health
			print("%s recuperou %d de vida." % [player_name, healed_amount])


func monster_turn() -> void:
	# 0 significa atacar; 1 significa defender.
	var monster_choice: int = randi_range(0, 1)

	if monster_choice == 0:
		var defense: int = player_defense
		if player_is_defending:
			defense += DEFENSE_BONUS

		var damage: int = calculate_damage(monster_attack, defense)
		player_health = max(player_health - damage, 0)
		print("%s atacou e causou %d de dano." % [monster_name, damage])
	else:
		monster_is_defending = true
		print("%s assumiu posição de defesa." % monster_name)

	# A defesa do jogador só dura o turno do monstro, mesmo se ele decidiu defender.
	player_is_defending = false


func get_next_player_action() -> PlayerAction:
	if next_action_index < planned_player_actions.size():
		var action: PlayerAction = planned_player_actions[next_action_index]
		next_action_index += 1
		return action

	# Evita que o jogo pare quando a lista de decisões acabar.
	return PlayerAction.ATTACK


func calculate_damage(attack: int, defense: int) -> int:
	# O cálculo não altera a vida de ninguém; ele só devolve um resultado.
	# max(..., 1) garante que todo ataque causa ao menos um de dano.
	return max(attack - defense, 1)


func print_status() -> void:
	print("%s: %d/%d | %s: %d/%d" % [
		player_name,
		player_health,
		PLAYER_MAX_HEALTH,
		monster_name,
		monster_health,
		MONSTER_MAX_HEALTH,
	])


func print_battle_result() -> void:
	print("\n=== Resultado ===")
	if player_health > 0:
		print("Vitória! %s derrotou %s." % [player_name, monster_name])
	else:
		print("Derrota. %s foi derrotado por %s." % [player_name, monster_name])
