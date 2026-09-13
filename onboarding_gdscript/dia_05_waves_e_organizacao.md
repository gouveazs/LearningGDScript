# Dia 5 — Waves, organização e mini-projeto

**Meta:** combinar os quatro dias anteriores numa simulação do núcleo do ABC: jogador defendendo uma princesa de ondas de inimigos.

## 1. Defina o loop antes de escrever classes

O loop mínimo é:

```text
Preparar wave
→ criar inimigos
→ jogador e inimigos agem
→ inimigo morto sai da lista
→ todos morreram? próxima wave
→ princesa morreu? derrota
```

Escreva as regras em texto antes do código. Isso evita começar por animações ou UI e descobrir depois que não existe uma condição clara para a wave acabar.

## 2. Estados do jogo

O jogo também tem estados. Não misture “a wave acabou” com “um inimigo está morto”.

```gdscript
enum GameState { PREPARING_WAVE, WAVE_ACTIVE, VICTORY, DEFEAT }

var game_state: GameState = GameState.PREPARING_WAVE
var current_wave: int = 0
var defeated_enemies: int = 0
```

Faça uma função `change_game_state()` como fez para inimigos. Depois, no projeto visual, sinais desses estados atualizarão HUD, música e telas.

## 3. Quem é responsável por quê?

| Parte | Responsabilidade |
| --- | --- |
| `Player` | Escolher ataque/habilidade e receber dano. |
| `Princess` | Guardar a vida do objetivo e emitir morte. |
| `Enemy` | Decidir alvo, atacar, morrer e emitir eventos. |
| `WaveManager` | Criar inimigos, contar vivos e iniciar a próxima wave. |
| `GameManager` | Controlar estado global: começo, vitória e derrota. |

O `WaveManager` não deve calcular dano; o `Enemy` não deve saber quantas waves existem. Essa divisão é o que permitirá trocar a simulação por cenas 3D sem reescrever tudo.

## 4. Lista de inimigos vivos

```gdscript
var alive_enemies: Array[Enemy] = []

func remove_dead_enemies() -> void:
	for index in range(alive_enemies.size() - 1, -1, -1):
		if not alive_enemies[index].is_alive():
			alive_enemies.remove_at(index)
```

Remover de trás para frente evita pular um elemento quando a lista diminui. Outra opção, mais elegante quando você estiver confortável, é conectar o signal `died` e remover aquele inimigo específico.

## 5. Escalonamento simples e previsível

Comece com uma fórmula fácil de depurar:

```gdscript
func get_enemy_count_for_wave(wave_number: int) -> int:
	return 2 + wave_number

func get_enemy_health_for_wave(wave_number: int) -> int:
	return 20 + wave_number * 5
```

Você poderá mudar o balanceamento depois. Primeiro, garanta que wave 1, 2 e 3 funcionam sem casos especiais escondidos.

## 6. Como depurar a simulação

- Imprima começo e fim de cada wave.
- Imprima o nome do inimigo que atacou e quem recebeu dano.
- Ao remover inimigo, mostre quantos ainda vivem.
- Faça uma wave de um inimigo para testar o fim da wave.
- Faça uma princesa com 1 de vida para testar derrota.
- Use valores pequenos para a simulação terminar rápido.

Não esconda os logs cedo demais. Em sistemas de wave, log claro resolve mais problemas que tentar adivinhar o estado.

## Desafio final — núcleo do ABC em texto

Monte uma cena de teste que inicia uma partida automaticamente.

### Requisitos mínimos

- `Player`, `Princess` e classe base `Enemy`.
- Dois inimigos diferentes derivados da base.
- Pelo menos uma habilidade ou ataque do jogador.
- Waves que escalam quantidade, vida ou dano.
- Estados: preparando wave, wave ativa, vitória e derrota.
- Sinais/callbacks para morte de inimigo, fim da wave e dano à princesa.
- Relatório final: wave alcançada, inimigos derrotados e vida final da princesa.

### Bônus, somente depois do básico

- Recompensa entre waves e loja do dia 2.
- Chefe a cada três waves.
- Efeitos de status do dia 3.
- Seed exibida para reproduzir uma partida aleatória.
- Seleção de alvo: inimigos priorizam a princesa ou o jogador conforme uma regra clara.

### Revisão antes de seguir para o editor 3D

- [ ] Não existe classe com responsabilidade por tudo.
- [ ] Uma wave não termina enquanto houver inimigo vivo.
- [ ] A derrota dispara mesmo se a princesa morrer no meio da wave.
- [ ] Cada sinal tem um dono claro e um efeito observável.
- [ ] Você consegue explicar o fluxo da partida sem abrir o código.

Quando essa simulação estiver pronta, o próximo passo não é reescrever a lógica: é criar `Player.tscn`, `Princess.tscn`, `Enemy.tscn` e um `Map_Test.tscn` que instanciam as mesmas ideias visualmente.
