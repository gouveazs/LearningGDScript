# Dia 4 — Sinais, estados e LimboAI

**Meta:** criar inimigos que mudam de comportamento e avisam o resto do jogo sem ficarem acoplados; depois montar a mesma decisão no LimboAI.

> Este é o primeiro dia com plugin. Não instale e saia arrastando Nodes sem entender o fluxo. Primeiro veja o inimigo simples abaixo; depois o LimboAI transforma a mesma lógica em uma Behavior Tree visual.

## Parte A — a pergunta que a IA responde o tempo todo

Todo tick, o inimigo precisa decidir a maior prioridade:

```text
Estou morto?            → morrer, não fazer mais nada
Alvo está no alcance?   → atacar
Tenho alvo visível?     → perseguir
Nada disso?             → patrulhar
```

Essa ordem importa. Um inimigo morto não pode atacar só porque o alvo está perto.

## Parte B — LimboAI no ABC

No início deste dia, instale **LimboAI** pela aba `AssetLib`/Biblioteca de Recursos, pesquisando `LimboAI`. Sua Godot 4.7.2 é compatível com a linha atual do plugin.

Termos que você precisa conhecer antes de clicar em qualquer coisa:

| Termo | É o quê? | Exemplo no ABC |
| --- | --- | --- |
| `BTPlayer` | Node que executa uma árvore. | Filho do inimigo. |
| Behavior Tree | Árvore de decisões por prioridade. | Decide atacar/perseguir/patrulhar. |
| `Selector` | Tenta filhos da esquerda para direita até um funcionar. | Morte, ataque, chase, patrol. |
| `Sequence` | Só tem sucesso se todos os passos funcionarem. | Alvo perto → atacar. |
| Condition | Pergunta verdadeira/falsa. | `TargetInAttackRange`. |
| Action | Ação concreta. | `MoveToTarget`, `AttackTarget`. |
| Blackboard | Dados compartilhados pela árvore. | `target`, `home_position`, `attack_range`. |

O primeiro Behavior Tree do esqueleto terá esta forma:

```text
Selector
├── Sequence: morreu
│   ├── IsDead
│   └── Die
├── Sequence: atacar
│   ├── HasTarget
│   ├── TargetInAttackRange
│   └── AttackTarget
├── Sequence: perseguir
│   ├── HasTarget
│   └── MoveToTarget
└── Patrol
```

Você vai criar tarefas próprias em GDScript, por exemplo `BTAction` para atacar e `BTCondition` para checar distância. A árvore organiza **qual** tarefa roda; o script da tarefa define **como** ela funciona.

## 1. Signals: eventos entre objetos

Um signal é uma mensagem emitida por um objeto. Quem emite não precisa saber quem está escutando. Isso é o equivalente mental a um Event Dispatcher da Unreal.

```gdscript
class_name EnemyLogic
extends RefCounted

signal state_changed(previous_state: State, new_state: State)
signal died

enum State { PATROLLING, CHASING, ATTACKING, DEAD }

var state: State = State.PATROLLING
var health: int = 50

func change_state(new_state: State) -> void:
	if state == new_state:
		return
	var previous_state: State = state
	state = new_state
	state_changed.emit(previous_state, state)
```

Para escutar o evento:

```gdscript
func _ready() -> void:
	var enemy := EnemyLogic.new()
	enemy.state_changed.connect(_on_enemy_state_changed)
	enemy.change_state(EnemyLogic.State.CHASING)

func _on_enemy_state_changed(previous_state: EnemyLogic.State, new_state: EnemyLogic.State) -> void:
	print("Estado mudou: %s -> %s" % [previous_state, new_state])
```

Conecte sinais antes da ação que pode emiti-los. Caso contrário, o evento já terá passado quando você começar a escutar.

## 2. Estados: uma resposta por situação

Uma máquina de estados evita condições confusas como "está atacando, perseguindo e patrulhando ao mesmo tempo?". Um inimigo deve estar em um estado claro por vez.

```gdscript
func update(target_distance: float) -> void:
	if health <= 0:
		change_state(State.DEAD)
		return

	match state:
		State.PATROLLING:
			if target_distance < 12.0:
				change_state(State.CHASING)
		State.CHASING:
			if target_distance <= 2.0:
				change_state(State.ATTACKING)
			elif target_distance > 16.0:
				change_state(State.PATROLLING)
		State.ATTACKING:
			if target_distance > 2.0:
				change_state(State.CHASING)
```

Primeiro centralize a transição em `change_state()`. Só depois, se ficar grande, separe cada estado em classes próprias.

## 3. Herança: use para um “é um” real

Herança serve quando o filho realmente **é um** tipo do pai. Um `MeleeEnemy` é um `Enemy`; um `StatusEffect` não é um `Enemy`.

```gdscript
class_name Enemy
extends RefCounted

var damage: int = 10

func perform_attack() -> int:
	return damage
```

```gdscript
class_name FastEnemy
extends Enemy

func _init() -> void:
	damage = 6

func perform_attack() -> int:
	return super() + 2
```

`super()` chama a implementação do pai. Não use herança apenas para compartilhar algumas variáveis; composição normalmente deixa o código mais simples.

## 4. Separação saudável para o futuro Godot 3D

Mais tarde, uma Scene de inimigo terá coisas visuais e físicas:

```text
EnemySkeleton (CharacterBody3D)
├── CollisionShape3D
├── MeshInstance3D
├── NavigationAgent3D
└── EnemyController.gd
```

O `EnemyController.gd` conversa com uma classe de lógica, como `EnemyLogic`. Hoje você testa a lógica em texto; amanhã mantém a mesma regra e troca `print()` por animação, movimento e partículas.

## 5. Cooldown simples

Para o exercício em turnos, use contador. Em tempo real, a Godot oferece `Timer` como Node filho, ou você pode diminuir um `float` por `delta` em `_process()`/`_physics_process()`.

```gdscript
var attack_cooldown_turns: int = 0

func advance_turn() -> void:
	attack_cooldown_turns = max(attack_cooldown_turns - 1, 0)

func can_attack() -> bool:
	return attack_cooldown_turns == 0
```

## Desafio — IA em estados

Implemente uma classe base de inimigo com estados `PATROLLING`, `CHASING`, `ATTACKING` e `DEAD`.

### Regras

- Declare e emita sinais para mudança de estado, ataque e morte.
- Apenas `change_state()` pode modificar o estado.
- Crie `MeleeEnemy` e `FastEnemy` ou outro par com diferença real de comportamento.
- Simule distâncias e turns no script de teste; não precisa de 3D ainda.
- Ataque apenas se alvo estiver no alcance e o cooldown tiver acabado.

### Checklist

- [ ] O log mostra cada transição uma única vez.
- [ ] Inimigo morto não volta a perseguir.
- [ ] A classe que escuta `died` não altera diretamente a vida do inimigo.
- [ ] Os dois inimigos não duplicam todo o código de IA.
