# Dia 3 — Classes e composição

**Meta:** sair de um script gigante e criar objetos responsáveis por uma única parte do combate.

> **Como estudar este dia:** não leia até o desafio e tente fazer tudo. Faça a Parte A, rode; depois a Parte B, rode; só então leia sobre composição. Cada arquivo abaixo tem um motivo de existir.

## Parte A — por que criar uma classe?

No Dia 1, todas as variáveis estavam no mesmo script. Isso funciona para uma luta de teste, mas fica ruim no momento em que existem jogador, princesa e cinco monstros: cada um precisaria de vida, dano e funções repetidas.

Uma classe é um molde. `Combatant` não é um personagem específico; é a regra comum que cria personagens com nome, vida e ataque diferentes.

```text
Combatant (molde)
├── nome
├── vida
├── ataque
├── take_damage()
└── is_alive()

Gouvea = Combatant.new("Gouvea", 100, 20)
Esqueleto = Combatant.new("Esqueleto", 40, 8)
```

## Parte B — crie a primeira classe, sem pular arquivo

Crie a pasta `dias/Dia3/`. Dentro dela, crie **dois** scripts. O primeiro não será anexado a uma Scene.

### Arquivo 1: `combatant.gd`

```gdscript
class_name Combatant
extends RefCounted

# Cada objeto Combatant criado terá sua própria cópia destas variáveis.
var display_name: String
var max_health: int
var health: int
var attack: int

func _init(new_name: String, new_max_health: int, new_attack: int) -> void:
	# _init é o construtor: roda ao chamar Combatant.new(...).
	display_name = new_name
	max_health = new_max_health
	health = max_health
	attack = new_attack

func take_damage(amount: int) -> void:
	health = max(health - amount, 0)

func is_alive() -> bool:
	return health > 0
```

`RefCounted` significa “objeto de lógica”. Ele não aparece no mapa, não tem posição e não precisa de `_ready()`. A Godot o libera quando ninguém mais mantém referência a ele.

### Arquivo 2: `dia_03_test.gd`

Crie uma Scene com `Node` raiz, anexe este script e execute com `F6`:

```gdscript
extends Node

func _ready() -> void:
	var player: Combatant = Combatant.new("Gouvea", 100, 20)
	var skeleton: Combatant = Combatant.new("Esqueleto", 40, 8)

	skeleton.take_damage(player.attack)
	print("%s ficou com %d de vida." % [skeleton.display_name, skeleton.health])
	print("Está vivo? %s" % skeleton.is_alive())
```

Se o editor reclamar que não conhece `Combatant`, salve `combatant.gd`, espere a Godot terminar de analisar e confira se `class_name Combatant` está na primeira linha útil do arquivo.

## Parte C — o que você acabou de fazer?

| Trecho | Significado |
| --- | --- |
| `class_name Combatant` | Dá um nome global à classe para usar `Combatant.new()`. |
| `extends RefCounted` | Diz que é objeto de lógica, não Node de cena. |
| `_init(...)` | Recebe os dados de cada instância criada. |
| `player` e `skeleton` | Dois objetos diferentes feitos a partir do mesmo molde. |
| `skeleton.take_damage(...)` | Chama função naquele objeto específico. |

Altere a vida/ataque, rode de novo e confirme que cada objeto guarda valores próprios antes de seguir.

## 1. Quando criar uma classe?

Crie uma classe quando um conceito tem dados e comportamento próprios. Para o ABC:

- `Combatant`: vida, ataque e receber dano.
- `Ability`: custo, cooldown e efeito.
- `StatusEffect`: duração e modificador.

Não crie uma classe só porque existe um nome. Uma `ArenaName` que guarda uma String não precisa ser classe.

## 2. Classe de lógica: `RefCounted`

Uma classe sem posição, sprite, colisão ou presença visual pode herdar de `RefCounted`.

```gdscript
# combatant.gd
class_name Combatant
extends RefCounted

var display_name: String
var max_health: int
var health: int
var attack: int

func _init(new_name: String, new_max_health: int, new_attack: int) -> void:
	display_name = new_name
	max_health = new_max_health
	health = max_health
	attack = new_attack

func take_damage(amount: int) -> int:
	var applied_damage: int = max(amount, 0)
	health = max(health - applied_damage, 0)
	return applied_damage

func is_alive() -> bool:
	return health > 0
```

`class_name Combatant` permite usar `Combatant.new(...)` em outros scripts. Sem `class_name`, seria necessário `preload()` do arquivo.

## 3. Encapsulamento sem paranoia

GDScript não força `private` como C++. A disciplina vem do design: exponha ações com métodos e evite que qualquer código altere campos críticos sem regra.

Um setter é útil quando toda mudança precisa ser validada:

```gdscript
var health: int:
	set(value):
		health = clampi(value, 0, max_health)
```

Não use setter só por formalidade. Se `take_damage()` e `heal()` já são os únicos caminhos para alterar vida, eles deixam a regra ainda mais explícita.

## 4. Composição: objetos dentro de objetos

Em vez de fazer `Combatant` conhecer todos os detalhes de veneno, escudo e fogo, ele mantém uma lista de efeitos. Cada efeito cuida da própria regra.

```gdscript
class_name StatusEffect
extends RefCounted

var effect_id: String
var remaining_turns: int

func _init(new_id: String, new_duration: int) -> void:
	effect_id = new_id
	remaining_turns = new_duration

func advance_turn() -> bool:
	remaining_turns -= 1
	return remaining_turns <= 0 # true significa que acabou.
```

No `Combatant`, você teria `var active_effects: Array[StatusEffect] = []`. Isso é composição: o combatente **tem** efeitos, não necessariamente **é um** efeito.

## 5. `static` e responsabilidade

Um método `static` não precisa de objeto. Use para cálculo puro ou fábrica simples:

```gdscript
static func calculate_damage(attack: int, defense: int) -> int:
	return max(attack - defense, 1)
```

Se a função precisa da vida, estados ou habilidades daquele personagem, ela não deve ser estática.

## 6. Organização de arquivos

Para o exercício, uma estrutura suficiente é:

```text
exercises/day_03/
├── combatant.gd
├── ability.gd
├── status_effect.gd
└── day_03.gd
```

`day_03.gd` estende `Node` e cria objetos para testar. As outras classes estendem `RefCounted`.

## Erros comuns hoje

- Colocar regras de habilidade dentro da classe inteira de combatente.
- Esquecer que `Array` de objetos guarda referências, não clones.
- Fazer uma classe herdar de `Node` sem ela precisar entrar numa Scene.
- Escrever um setter que se chama recursivamente sem entender o fluxo.

## Desafio — combatentes, habilidades e efeitos

Crie `Combatant`, `Ability` e `StatusEffect`.

- Um `Combatant` pode ter habilidades e efeitos ativos.
- Uma habilidade deve ter nome, dano base e custo/cooldown simples.
- Crie queimadura: a cada turno, ela causa dano e diminui a duração.
- Crie escudo: ele reduz dano enquanto estiver ativo.
- Quando duração chegar a zero, remova o efeito da lista corretamente.

### Checklist

- [ ] Cada classe está em seu próprio arquivo.
- [ ] Um efeito expira no turno correto.
- [ ] Escudo não continua ativo depois de expirar.
- [ ] `Combatant` não contém um `if` gigante para cada efeito possível.
