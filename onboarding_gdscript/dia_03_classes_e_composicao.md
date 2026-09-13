# Dia 3 — Classes e composição

**Meta:** sair de um script gigante e criar objetos responsáveis por uma única parte do combate.

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
