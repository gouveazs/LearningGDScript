# Aula 0 — Como a Godot pensa

**Leia esta aula antes do Dia 1.** Você já sabe fundamentos de C++, mas a Godot organiza um jogo de um jeito diferente da programação de terminal e da Unreal. Entender isso primeiro evita decorar `_ready()` sem saber por que ele existe.

## A ideia central

Na Godot, um jogo é formado por uma árvore de **Nodes**. Um Node é uma peça com uma função: pode representar algo visível, uma câmera, uma colisão, uma luz, um gerenciador invisível ou apenas um lugar para anexar código.

```text
Map_Test (Node3D)                 <- organiza o mapa no espaço 3D
├── Ground (StaticBody3D)         <- chão físico
│   ├── MeshInstance3D            <- aparência do chão
│   └── CollisionShape3D          <- colisão do chão
├── Sun (DirectionalLight3D)      <- luz solar
└── Player (CharacterBody3D)      <- personagem que se move
    ├── CollisionShape3D          <- colisão do jogador
    ├── Camera3D                  <- câmera do jogador
    └── player.gd                 <- comportamento do jogador
```

Você já fez parte disso no `map_teste`: `Map_Teste`, `Ground`, `Camera3D`, `Sun` e `WorldEnvironment` são Nodes.

## O que é um Node, em português claro?

Pense em Node como a unidade básica da engine. Ele pode ter:

- **Propriedades**: posição, nome, vida, intensidade de luz, velocidade etc.
- **Filhos**: outros Nodes que pertencem a ele.
- **Funções/callbacks**: código que a Godot chama em momentos específicos.
- **Signals**: avisos que ele emite para outros objetos.
- **Um script**: comportamento personalizado escrito por você.

Não existe um Node único que faça tudo. Você escolhe o tipo de acordo com a função:

| Quando você quer… | Use… |
| --- | --- |
| Só organizar lógica | `Node` |
| Ter posição, rotação e escala em 3D | `Node3D` |
| Um personagem controlado com colisão | `CharacterBody3D` |
| Um objeto imóvel com colisão | `StaticBody3D` |
| Detectar entrada numa área | `Area3D` |
| Uma câmera | `Camera3D` |
| Interface | `Control` |

Todos eles descendem, direta ou indiretamente, de `Node`. É por isso que um script com `extends Node` pode ser anexado ao seu `Node3D`: `Node3D` também é um Node.

## O que é uma Scene?

Uma **Scene** é uma árvore de Nodes salva em um arquivo `.tscn`.

Na Unreal, o paralelo mais próximo é um Level contendo Actors, mas na Godot uma Scene é mais geral:

- `map_teste.tscn` é uma Scene de mapa;
- `Player.tscn` será uma Scene de jogador;
- `Enemy.tscn` será uma Scene de inimigo;
- `HealthBar.tscn` pode ser uma Scene de interface.

Uma Scene pode ser instanciada dentro de outra. Isso é como transformar um conjunto de Nodes reutilizável em uma peça pronta. Por exemplo: o `WaveManager` criará várias instâncias de `Enemy.tscn` em vez de montar cada inimigo do zero.

## O que é um script GDScript?

Um arquivo `.gd` descreve comportamento. Ele não “roda sozinho” só por existir na pasta.

Para o código rodar no exercício, você faz esta ligação:

```text
Dia1.tscn (Scene)
└── Dia1 (Node3D)
    └── Dia1.gd (script anexado)
```

Quando você aperta `F6`, a Godot faz, em uma versão simplificada, isto:

1. Carrega `Dia1.tscn`.
2. Cria o Node raiz `Dia1` na memória.
3. Encontra o script anexado `Dia1.gd` e cria uma instância dele para aquele Node.
4. Coloca o Node na árvore em execução.
5. Chama `_ready()`.

É por isso que `print()` dentro de `_ready()` aparece no Output. Se o script não estiver anexado ao Node, a Godot não tem motivo para criar a instância dele, então `_ready()` não é chamado.

## `extends`: de onde vêm as habilidades do script

A primeira linha informa o tipo-base do objeto que seu script controla:

```gdscript
extends Node
```

Isso significa: “este script se comporta como um Node e pode usar tudo que um Node oferece”. Por exemplo, `queue_free()`, `get_parent()`, `get_children()` e callbacks de ciclo de vida.

Mais tarde você verá outras bases:

```gdscript
extends CharacterBody3D # Movimento e colisão de personagem 3D.
extends RefCounted      # Classe de lógica que não aparece na Scene.
extends Resource        # Dados editáveis no Inspetor, como habilidade ou inimigo.
```

Não escolha `CharacterBody3D` só porque o objeto tem vida; escolha-o quando ele precisa de corpo/movimento físico no mundo 3D.

## Por que não existe `main()`?

Num programa C++ de terminal, você começa em `main()`. Na Godot, a engine controla o programa: ela cria Scenes, processa input, atualiza física e desenha a tela. Seu código responde aos momentos que ela oferece.

Os callbacks mais importantes são:

| Função | Quando roda | Uso inicial |
| --- | --- | --- |
| `_ready()` | Uma vez, quando Node e filhos estão prontos. | Configuração e testes do Dia 1. |
| `_process(delta)` | Todo frame. | Lógica visual que depende de tempo. |
| `_physics_process(delta)` | Em passos fixos de física. | Movimento/colisão de personagens. |
| `_input(event)` | Quando há input do jogador. | Teclado, mouse e controle. |
| `_exit_tree()` | Quando Node sai da Scene. | Limpeza, se necessária. |

`delta` é o tempo desde a última atualização. Ele será importante para fazer algo se mover na mesma velocidade em computadores rápidos e lentos. Por enquanto, não coloque um `while` infinito em `_process()`; um frame já chama `_process()` de novo automaticamente.

```gdscript
extends Node

func _ready() -> void:
	print("Roda uma vez ao iniciar.")

func _process(delta: float) -> void:
	# A Godot chama isto muitas vezes por segundo.
	# Ainda não vamos usar para o combate por turnos.
	pass
```

## Variável do Node versus variável local

Esta diferença é essencial:

```gdscript
extends Node

# Variável de membro: pertence a este Node enquanto ele existir.
var health: int = 100

func take_damage(amount: int) -> void:
	# Variável local: nasce quando a função começa e some quando ela termina.
	var previous_health: int = health
	health -= amount
	print("%d -> %d" % [previous_health, health])
```

`health` fica fora porque outras funções precisam lembrar dela. `previous_health` fica dentro porque só serve durante uma chamada de `take_damage()`.

## Scripts que não são anexados a Nodes

Nem todo `.gd` controla uma cena visual. No Dia 3, você criará classes de lógica:

```gdscript
class_name StatusEffect
extends RefCounted

var remaining_turns: int = 3
```

Esse script representa um objeto de lógica. Ele é criado por código com `StatusEffect.new()`, não precisa ficar na árvore da Scene e não possui `_ready()`.

Resumo:

| Tipo de script | Como nasce | Exemplo |
| --- | --- | --- |
| `extends Node` | Anexado a um Node numa Scene. | `Dia1.gd`, `player.gd`. |
| `extends RefCounted` | Criado com `.new()` por outro script. | `StatusEffect`, lógica de dano. |
| `extends Resource` | Criado/salvo como dado no Inspetor. | Dados de habilidade e inimigo. |

## O seu exercício Dia 1

Para testar o Dia 1, a estrutura correta é:

```text
res://dias/
├── Dia1.tscn
└── Dia1.gd
```

O arquivo `Dia1.gd` deve estar **anexado** ao Node raiz `Dia1`. No painel Cena, o Node mostra o ícone de script quando a ligação existe. Execute com `F6`; o painel Saída/Output deve mostrar os `print()` de `_ready()`.

## Erros que agora fazem sentido

- **Nada aparece no Output:** o script não está anexado, a Scene errada está rodando, ou não há `print()` dentro de `_ready()`.
- **`Unexpected "for" in class body`:** `for`/`while` ficaram fora de uma função. A classe descreve coisas fora; ações executam dentro.
- **`Node not found`:** você tentou buscar um Node que não existe naquele caminho da árvore.
- **Cena funciona no editor, mas não com `F5`:** `F5` usa a cena principal configurada em `project.godot`; `F6` usa somente a Scene aberta.

## Checklist antes do Dia 1

- [ ] Eu sei que Scene é uma árvore salva de Nodes.
- [ ] Eu sei que Node é uma peça do jogo, visual ou invisível.
- [ ] Eu sei que `.gd` precisa estar anexado a um Node para `_ready()` rodar.
- [ ] Eu sei que a Godot chama callbacks; não existe `main()`.
- [ ] Eu sei a diferença entre variável de membro e variável local.
