# Dia 1 — Sintaxe e lógica

**Meta:** escrever um programa pequeno que toma decisões, repete ações e mostra o resultado no painel **Saída/Output**.

> Antes desta aula, leia [Aula 0 — Como a Godot pensa](00_como_godot_pensa.md). Ela explica o que é um Node, uma Scene e por que este script executa.

## 1. O formato de um script

Um arquivo `.gd` é uma classe. Quando ele está anexado a um `Node`, `extends Node` dá acesso ao ciclo de vida desse Node. `_ready()` roda uma vez quando a cena entra em execução.

```gdscript
extends Node

func _ready() -> void:
	print("A arena carregou.")
```

Não há `main()`, chaves ou ponto e vírgula. A indentação com tabulação/espaços define os blocos; mantenha o padrão que o editor cria.

## Regra estrutural essencial: fora e dentro de funções

Um script tem duas áreas. Essa distinção é obrigatória e vale para todos os exercícios daqui em diante.

```gdscript
extends Node

# FORA de funções: o que o objeto TEM ou declara.
var health: int = 100
const MAX_HEALTH: int = 100

# FUNÇÃO: o que o objeto FAZ quando ela é chamada.
func _ready() -> void:
	print("A cena começou.")
	if health > 0:
		print("O personagem está vivo.")
```

| Pode ficar fora de função | Precisa ficar dentro de função |
| --- | --- |
| `extends` | `if`, `elif`, `else` |
| `var` e `const` de membro | `for` e `while` |
| `signal` e `enum` | `print()` |
| Declaração de `func` | cálculos, atribuições e chamadas de função |

O motivo: fora da função você descreve a **estrutura** da classe; dentro da função você escreve instruções que vão **executar** em um momento específico. A Godot precisa saber *quando* um loop ou um `print()` deve rodar. `_ready()` é uma dessas ocasiões: ela roda uma vez quando a cena inicia.

### Exemplo inválido

```gdscript
extends Node

var health: int = 30

# ERRO: um loop não pode ficar solto no corpo da classe.
while health > 0:
	health -= 10
```

Isso gera algo como `Unexpected "while" in class body`.

### Exemplo válido

```gdscript
extends Node

var health: int = 30

func _ready() -> void:
	while health > 0:
		health -= 10
		print("Vida restante: %d" % health)
```

Quando houver dúvida, faça esta pergunta: **isto é uma característica do objeto ou uma ação?** Característica fica fora; ação fica dentro de uma função.

## 2. Variáveis, constantes e tipos

`var` pode mudar. `const` não pode ser reatribuída depois de criada.

```gdscript
var player_name: String = "Gouvea"
var health: int = 100
var movement_speed: float = 4.5
var is_defending: bool = false
const MAX_HEALTH: int = 100

health -= 20
print("%s ficou com %d de vida." % [player_name, health])
```

Use `int` para valores inteiros, `float` para valores com casas decimais, `bool` para verdadeiro/falso e `String` para texto. GDScript permite omitir tipos, mas escrevê-los ajuda você e o editor.

`:=` pede para a Godot inferir o tipo:

```gdscript
var critical_multiplier := 1.5 # A Godot infere float.
```

## 3. Operadores úteis

| Tipo | Operadores |
| --- | --- |
| Matemática | `+`, `-`, `*`, `/`, `%` (resto), `**` (potência) |
| Comparação | `==`, `!=`, `<`, `>`, `<=`, `>=` |
| Lógica | `and`, `or`, `not` |
| Alteração | `+=`, `-=`, `*=`, `/=` |

Evite comparar `float` com `==` quando a precisão importar. Para vida, moedas e contadores, `int` costuma ser o tipo certo.

## 4. Funções: dê nome às decisões

Funções impedem que toda a lógica fique dentro de `_ready()`.

```gdscript
func calculate_damage(attack: int, defense: int) -> int:
	var raw_damage: int = attack - defense
	return max(raw_damage, 1)

func _ready() -> void:
	var damage: int = calculate_damage(18, 7)
	print("Dano final: %d" % damage)
```

`-> int` informa o retorno. `-> void` significa que a função só executa uma ação e não devolve valor.

Use nomes de ação para funções: `take_damage`, `choose_monster_action`, `is_alive`. Uma função deve responder uma pergunta ou executar uma ação clara.

## 5. Decisões com `if`

```gdscript
func can_attack(current_health: int, cooldown_ready: bool) -> bool:
	if current_health <= 0:
		return false
	elif not cooldown_ready:
		return false
	else:
		return true
```

O `else` final poderia virar `return true` sem bloco. Prefira a versão que você considera mais legível.

## 6. Repetição com `for` e `while`

`for` é melhor quando você sabe quantas vezes quer repetir:

```gdscript
for turn in range(1, 4):
	print("Turno %d" % turn)
```

`while` é melhor quando existe uma condição de parada:

```gdscript
var health: int = 30
while health > 0:
	health -= 10
	print("Vida restante: %d" % health)
```

> Todo `while` precisa mudar algo que eventualmente o encerre. Um loop infinito congela o jogo.

## 7. Aleatoriedade e limites

```gdscript
var monster_choice: int = randi_range(0, 2)
var clamped_health: int = clampi(health, 0, MAX_HEALTH)
```

- `randi_range(min, max)` inclui os dois extremos.
- `min()` e `max()` são ótimos para limites simples.
- `clampi()` limita um inteiro entre mínimo e máximo.

## Erros comuns hoje

- Esquecer `:` ao fim de `func`, `if`, `elif`, `else`, `for` ou `while`.
- Misturar tabulação e espaços na indentação.
- Tentar chamar uma função antes de criar seus argumentos corretamente.
- Deixar vida negativa em vez de limitar com `max(health - damage, 0)`.
- Colocar tudo em `_ready()` em vez de extrair funções.

## Desafio — combate por turnos

Crie `exercises/dia_01.gd`. Faça jogador e monstro com vida, ataque e defesa. A cada turno:

1. O jogador escolhe, por enquanto no código, `attack`, `defend` ou `heal`.
2. O monstro escolhe aleatoriamente atacar ou defender.
3. Mostre o que os dois fizeram e a vida de cada um.
4. A batalha acaba quando um deles chegar a zero.

### Regras

- Crie pelo menos: `calculate_damage`, `player_turn`, `monster_turn` e `print_status`.
- Defender só vale até o próximo turno daquele personagem.
- Cura não pode passar da vida máxima.
- Não use classes ainda; foque na lógica e nas funções.

### Checklist

- [ ] A cena executa com `F6`.
- [ ] Nunca existe vida negativa.
- [ ] Vitória e derrota funcionam.
- [ ] O Output deixa claro o que aconteceu em cada turno.
