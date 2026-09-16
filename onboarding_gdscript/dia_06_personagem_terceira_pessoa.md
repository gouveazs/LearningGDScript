# Dia 6 — Personagem 3D em terceira pessoa

**Meta:** criar o equivalente Godot do `Third Person Character` da Unreal: corpo que colide, input WASD, câmera em terceira pessoa e um boneco temporário visível.

Na Unreal, o template já entrega Character, Capsule, Mesh, Spring Arm, Camera e Enhanced Input. Na Godot esses elementos existem, mas você monta a composição uma vez. Depois, `Player.tscn` vira o seu próprio template reutilizável.

## O que vamos construir

```text
Player (CharacterBody3D)          <- corpo controlado por código
├── CollisionShape3D              <- cápsula física
├── Visual (MeshInstance3D)       <- cápsula visível temporária
└── CameraPivot (Node3D)          <- gira para olhar para cima/baixo
    └── SpringArm3D               <- impede câmera de atravessar paredes
        └── Camera3D               <- visão do jogador
```

`CharacterBody3D` é o Node certo para jogador/inimigo controlado por script. Ele tem `velocity`, detecta chão/parede e `move_and_slide()` resolve colisão e deslize. A malha e a colisão são filhos separados porque aparência e física não são a mesma coisa.

## Parte A — crie a Scene do jogador

1. Crie uma Scene nova.
2. No painel **Cena/Scene**, aperte `Ctrl + A`, pesquise `CharacterBody3D` e crie-o.
3. Renomeie o nó raiz para `Player`.
4. Salve como `scenes/characters/Player.tscn`.

Não use `Node3D` como raiz aqui: ele possui posição, mas não tem o comportamento físico de personagem.

## Parte B — colisão e boneco de teste

### Colisão

1. Selecione `Player`, aperte `Ctrl + A`, crie `CollisionShape3D`.
2. No Inspetor, em `Shape`, crie `CapsuleShape3D`.
3. Clique no CapsuleShape3D e ajuste aproximadamente `Radius = 0.4` e `Height = 1.8`.
4. Mova a colisão para `Y = 0.9`, pois o chão fica em `Y = 0` e a cápsula não deve ficar metade enterrada.

### Visual provisório

1. Adicione `MeshInstance3D` como filho de `Player`; renomeie para `Visual`.
2. Em `Mesh`, crie `CapsuleMesh`.
3. Ajuste o `CapsuleMesh` para dimensões parecidas com a colisão e `Visual > Position > Y = 0.9`.

Esse boneco não é o personagem final. Ele existe para você enxergar e testar controle antes de importar modelo, esqueleto e animações. Mais tarde você substitui somente `Visual` por uma cena/modelo importado; movimento e câmera permanecem.

## Parte C — câmera em terceira pessoa

1. Adicione `Node3D` como filho de `Player`, renomeie para `CameraPivot` e coloque `Position Y = 1.5`.
2. Adicione `SpringArm3D` como filho de `CameraPivot`; defina `Spring Length = 4.0`.
3. Adicione `Camera3D` como filho direto de `SpringArm3D`; marque `Current`.

O `SpringArm3D` puxa a câmera para perto se uma parede ficar entre ela e o jogador. É o papel do Spring Arm da Unreal. A câmera fica como filha do braço porque o braço controla a distância dela.

> Se a câmera estiver olhando para o lado errado, selecione `Camera3D` e use a viewport para rotacionar. O padrão da Godot olha para o eixo `-Z`.

## Parte D — configure ações de input

Não escreva `Input.is_key_pressed(KEY_W)` em todo jogo. Crie ações com nomes de intenção, igual ao Enhanced Input:

1. Abra **Projeto/Project > Configurações do Projeto/Project Settings > Input Map**.
2. Adicione estas ações, exatamente com estes nomes:

```text
move_forward
move_backward
move_left
move_right
jump
```

3. Para cada ação, clique no `+` e associe:

| Ação | Tecla |
| --- | --- |
| `move_forward` | W e seta para cima |
| `move_backward` | S e seta para baixo |
| `move_left` | A e seta para esquerda |
| `move_right` | D e seta para direita |
| `jump` | Espaço |

Você pode adicionar gamepad depois sem alterar o código. O script pergunta “a ação move_forward está pressionada?”, não “a tecla W está pressionada?”.

## Parte E — anexe o script e entenda antes de colar

Selecione `Player`, anexe `res://scripts/characters/player.gd`. Crie a pasta se ela não existir. Cole o código inteiro:

```gdscript
extends CharacterBody3D

# @export faz a variável aparecer no Inspetor. Assim você ajusta velocidade
# sem editar código toda vez.
@export var walk_speed: float = 5.0
@export var jump_velocity: float = 5.0

# @onready procura Nodes depois que a Scene estiver pronta.
# O caminho usa os nomes da árvore criada acima.
@onready var camera_pivot: Node3D = $CameraPivot

func _physics_process(delta: float) -> void:
	# Gravidade: CharacterBody3D não cai sozinho.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo só é permitido no chão.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# get_vector transforma quatro ações em Vector2.
	# Ele já normaliza diagonal: W+D não deixa o jogador mais rápido.
	var input_direction: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward",
	)

	# Converte o input 2D em direção no chão 3D.
	var direction: Vector3 = Vector3(input_direction.x, 0.0, input_direction.y)

	if direction != Vector3.ZERO:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
		# Faz o boneco olhar para onde ele anda.
		look_at(global_position + direction, Vector3.UP)
	else:
		# Para suavemente quando o jogador solta as teclas.
		velocity.x = move_toward(velocity.x, 0.0, walk_speed)
		velocity.z = move_toward(velocity.z, 0.0, walk_speed)

	# É esta chamada que move o corpo e testa colisões.
	move_and_slide()
```

### O que cada bloco resolve

| Bloco | Sem ele, o que aconteceria? |
| --- | --- |
| `extends CharacterBody3D` | Não existiriam `velocity`, `is_on_floor()` e `move_and_slide()`. |
| `_physics_process` | Movimento/collision ficariam fora do passo físico e dariam comportamento inconsistente. |
| `get_gravity()` | O Player flutuaria depois de pular ou cair de uma plataforma. |
| `Input.get_vector()` | Você teria quatro `if`s e diagonal mais rápida por acidente. |
| `velocity` | A Godot não saberia direção e velocidade desejadas. |
| `move_and_slide()` | Alterar velocity sozinho não move nada. |

## Parte F — coloque Player na arena

Abra `map_teste.tscn`.

1. Selecione `Map_Teste`.
2. Clique no ícone de instanciar Scene (corrente) ou botão direito > **Instanciar Cena Filha**.
3. Escolha `Player.tscn`.
4. Ajuste `Player > Position` para algo como `(0, 1.0, 8)`.
5. Salve o mapa e aperte `F6` com o mapa aberto.

O `Y = 1.0` coloca o centro da cápsula acima do chão; sem isso o jogador pode nascer colidindo/enterrado.

## Teste esperado

- W/A/S/D move o boneco cápsula.
- Diagonal tem velocidade igual à reta.
- Espaço pula somente no chão.
- O boneco não atravessa `Ground`.
- Ao chegar perto de uma parede futura, SpringArm3D impedirá a câmera de atravessá-la.

## Problemas comuns — e a causa

| Sintoma | Provável causa | Correção |
| --- | --- | --- |
| Player cai para sempre | Chão sem `StaticBody3D`/`CollisionShape3D`, ou Player fora da arena. | Revise a colisão do mapa e posição inicial. |
| Player não mexe | Ação no Input Map com nome diferente do script. | Compare letra por letra. |
| Player não aparece | Sem `MeshInstance3D`, sem câmera ativa ou nasceu fora da visão. | Revise Visual, Camera3D e Position. |
| Player atravessa chão | Falta `CollisionShape3D` no Player ou no Ground. | Ambos precisam de colisão. |
| Erro `Node not found: CameraPivot` | Nome/caminho da árvore não coincide com `$CameraPivot`. | Renomeie o Node ou ajuste o caminho. |
| Pulo no ar | `is_on_floor()` ausente ou colisão não funciona. | Revise o bloco de pulo e colisores. |

## O que vem depois do boneco cápsula

1. Importar um modelo 3D com esqueleto e animações licenciadas.
2. Trocar `Visual` pelo modelo.
3. Adicionar `AnimationPlayer` e `AnimationTree`.
4. Fazer câmera girar com mouse.
5. Fazer movimento relativo à câmera, em vez de relativo ao mundo.
6. Adicionar ataque, dodge e habilidades.

Isso é exatamente a vantagem da Scene `Player.tscn`: você evolui uma peça isolada e instancia no mapa, como um Blueprint reutilizável.

## Referências oficiais

- [CharacterBody3D](https://docs.godotengine.org/en/4.7/classes/class_characterbody3d.html)
- [SpringArm3D](https://docs.godotengine.org/en/stable/classes/class_springarm3d.html)
- [Movimento de personagem 3D](https://docs.godotengine.org/en/latest/getting_started/first_3d_game/03.player_movement_code.html)
