# Dia 6 — Personagem 3D: primeira e terceira pessoa

**Meta:** montar do zero corpo físico, colisão, input, mouse e câmera — as peças que a Unreal costuma entregar prontas nos templates.

No **Wave**, o gameplay normal agora será em **primeira pessoa**. Terceira pessoa continua útil para aprender o `SpringArm3D` e para emotes/finishers, em que o jogador local verá seu corpo por uma câmera externa temporária. Vamos construir os dois como protótipos separados. Não misture as duas câmeras em uma Scene antes de entender cada uma.

Na Unreal, o template já traz Character, Capsule, Mesh, Spring Arm, Camera e Enhanced Input. Na Godot, você monta esses Nodes uma vez; depois a Scene pronta vira seu próprio template reutilizável.

## Antes de começar: `CharacterBody3D`

`CharacterBody3D` é o Node para um personagem movido por código. Ele oferece:

- `velocity`: velocidade desejada;
- `is_on_floor()`: pergunta se o corpo está no chão;
- `move_and_slide()`: realmente move e resolve colisões.

Ele não anda nem cai sozinho. O script atualiza `velocity`, e `move_and_slide()` aplica isso durante o passo de física. A malha e a colisão são filhos diferentes: aparência não é física.

## Preparação comum: Input Map

Abra **Projeto > Configurações do Projeto > Input Map**. Adicione exatamente estas ações:

| Ação | Teclas |
| --- | --- |
| `move_forward` | W e seta para cima |
| `move_backward` | S e seta para baixo |
| `move_left` | A e seta para esquerda |
| `move_right` | D e seta para direita |
| `jump` | Espaço |

O script pergunta pela intenção (`move_forward`), e não pela tecla W. Assim, depois você adiciona gamepad sem reescrever o personagem. O mouse chega como `InputEventMouseMotion`, então não exige ação no Input Map.

Crie também `scenes/characters/` e `scripts/characters/`.

---

## Parte A — Personagem em primeira pessoa (modo normal do Wave)

### 1. Monte a Scene

Crie uma Scene nova. Use `CharacterBody3D` como raiz, renomeie-a para `PlayerFPS` e salve em `scenes/characters/PlayerFPS.tscn`.

Monte esta árvore, com os mesmos nomes:

```text
PlayerFPS (CharacterBody3D)       <- corpo físico que anda e colide
├── CollisionShape3D              <- cápsula física
├── WorldBody (MeshInstance3D)    <- corpo que os outros jogadores enxergam
└── ViewPivot (Node3D)            <- inclinação vertical da visão
    └── Camera3D                  <- olhos do jogador local
```

### 2. Configure colisão, visual e câmera

1. Selecione `PlayerFPS`, aperte `Ctrl + A` e adicione `CollisionShape3D`.
2. No Inspetor, em **Shape**, crie `CapsuleShape3D`.
3. Use aproximadamente `Radius = 0.4` e `Height = 1.8`.
4. Coloque a colisão em `Position Y = 0.9`: a base da cápsula encosta no chão em `Y = 0`.
5. Adicione `MeshInstance3D` como filho, renomeie para `WorldBody`, crie `CapsuleMesh` em **Mesh** e coloque-o em `Y = 0.9`.
6. Adicione `Node3D`, renomeie para `ViewPivot`, e deixe `Position Y = 1.6` — altura aproximada dos olhos.
7. Adicione `Camera3D` como filho de `ViewPivot` e marque **Current/Atual**.

Em FPS não há `SpringArm3D`: a câmera fica nos olhos, dentro do corpo. Uma câmera atrás do personagem é terceira pessoa.

### 3. Entenda a rotação antes do código

```text
Mouse esquerda/direita  -> gira PlayerFPS no eixo Y (corpo e direção horizontal)
Mouse cima/baixo        -> gira ViewPivot no eixo X (somente a visão vertical)
Camera3D                -> herda as duas rotações
```

Essa divisão importa: se o corpo todo girasse no eixo X, olhar para cima faria o personagem tombar e quebraria a física.

### 4. Script FPS

Anexe este script à raiz `PlayerFPS` e salve como `scripts/characters/player_fps.gd`:

```gdscript
extends CharacterBody3D

# @export deixa esses ajustes visíveis no Inspetor.
@export var walk_speed: float = 5.0
@export var jump_velocity: float = 5.0
@export var mouse_sensitivity: float = 0.003

# Este Node só inclina a visão para cima/baixo.
@onready var view_pivot: Node3D = $ViewPivot

func _ready() -> void:
	# Prende/esconde o cursor enquanto o personagem está sendo usado.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Y do Player = giro horizontal, o "yaw".
		rotate_y(-event.relative.x * mouse_sensitivity)

		# X do pivot = olhar para cima/baixo, o "pitch".
		view_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		# Sem limite, dá para virar a câmera de cabeça para baixo.
		view_pivot.rotation.x = clamp(view_pivot.rotation.x, -1.4, 1.4)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	# CharacterBody3D não recebe gravidade automaticamente.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_direction: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward",
	)

	# -Z é "frente" na Godot. Como o Player gira com o mouse,
	# W sempre acompanha a direção horizontal da visão.
	var forward: Vector3 = -global_transform.basis.z
	var right: Vector3 = global_transform.basis.x
	var direction: Vector3 = (right * input_direction.x) + (forward * -input_direction.y)
	direction.y = 0.0
	direction = direction.normalized()

	velocity.x = direction.x * walk_speed
	velocity.z = direction.z * walk_speed

	# Alterar velocity não move nada até chamar esta função.
	move_and_slide()
```

### 5. O que cada bloco resolve

| Trecho | Função |
| --- | --- |
| `_ready()` | Roda uma vez quando a Scene entra na árvore; aqui captura o mouse. |
| `_unhandled_input()` | Lê mouse depois que a UI teve chance de usar o evento. |
| `rotate_y()` | Gira corpo/câmera na horizontal. |
| `ViewPivot.rotate_x()` | Inclina só a visão. |
| `clamp()` | Impede inverter a câmera. |
| `Input.get_vector()` | Lê WASD e já evita diagonal mais rápida. |
| `basis` | São os eixos locais do Player; tornam movimento relativo à visão. |
| `move_and_slide()` | Aplica velocidade e colisões. |

### 6. Teste FPS

Abra seu mapa, instancie `PlayerFPS.tscn`, coloque-o em `(0, 1, 8)` e execute o mapa com `F6`.

O esperado: mouse controla a visão, W anda na direção vista, Espaço pula e `Esc` solta o cursor. Se você enxergar a cápsula por dentro, esconda `WorldBody` pelo ícone de olho no painel Cena durante o protótipo. Em jogo real, o jogador local não renderiza seu corpo completo, mas outros jogadores precisam vê-lo.

---

## Parte B — Personagem em terceira pessoa

Crie uma segunda Scene; não reaproveite a FPS ainda. Use `CharacterBody3D` como raiz, renomeie para `PlayerTPP` e salve em `scenes/characters/PlayerTPP.tscn`.

### 1. Monte a árvore

```text
PlayerTPP (CharacterBody3D)       <- corpo físico
├── CollisionShape3D              <- cápsula física
├── Visual (MeshInstance3D)       <- boneco temporário visível
└── CameraPivot (Node3D)          <- altura e inclinação vertical
    └── SpringArm3D               <- encurta contra paredes
        └── Camera3D              <- câmera atrás do boneco
```

Repita a cápsula da Parte A: `CollisionShape3D` com `CapsuleShape3D`, `Y = 0.9`; `Visual` com `CapsuleMesh`, `Y = 0.9`.

Para a câmera:

1. Crie `CameraPivot` em `Y = 1.5`.
2. Crie `SpringArm3D` dentro dele e defina **Spring Length = 4.0**.
3. Crie `Camera3D` dentro do SpringArm e marque **Current/Atual**.

`SpringArm3D` equivale ao Spring Arm da Unreal: se uma parede ficar entre a câmera e o jogador, ele encurta o braço para não atravessar o cenário.

### 2. Script TPP

Anexe este script à raiz e salve como `scripts/characters/player_tpp.gd`:

```gdscript
extends CharacterBody3D

@export var walk_speed: float = 5.0
@export var jump_velocity: float = 5.0
@export var mouse_sensitivity: float = 0.003

@onready var camera_pivot: Node3D = $CameraPivot

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Corpo/câmera giram horizontalmente juntos.
		rotate_y(-event.relative.x * mouse_sensitivity)
		# Só o pivot inclina verticalmente.
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -1.0, 0.5)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_direction: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward",
	)

	var forward: Vector3 = -global_transform.basis.z
	var right: Vector3 = global_transform.basis.x
	var direction: Vector3 = (right * input_direction.x) + (forward * -input_direction.y)
	direction.y = 0.0
	direction = direction.normalized()

	velocity.x = direction.x * walk_speed
	velocity.z = direction.z * walk_speed
	move_and_slide()
```

O movimento é parecido com FPS. A diferença é estrutural: a câmera está atrás do corpo, por isso `Visual` fica visível e `SpringArm3D` é necessário.

### 3. Teste TPP

Instancie `PlayerTPP.tscn` no mapa e execute. Você deve ver a cápsula por trás, andar relativo à câmera e notar a câmera aproximar ao encostar em uma parede que tenha colisão.

## FPS versus TPP

| Pergunta | Primeira pessoa | Terceira pessoa |
| --- | --- | --- |
| Onde fica a câmera? | Nos olhos, em `ViewPivot`. | Atrás do corpo, no `SpringArm3D`. |
| Usa SpringArm? | Normalmente não. | Sim, para colisão da câmera. |
| Corpo do jogador aparece? | Não para a câmera local; depois haverá viewmodel/braços. | Sim, o `Visual` é parte da leitura. |
| Uso no Wave | Gameplay comum. | Emote/finisher local temporário. |
| Atenção principal | FOV, clipping, conforto e mira. | Enquadramento e colisão da câmera. |

## Como isto vira o Wave de verdade

Estes scripts são laboratórios, não o personagem multiplayer definitivo. Os docs atualizados do Wave definem esta ideia:

```text
Jogador local em FPS
├── WorldBody: corpo completo replicado, visto pelos outros peers
├── ViewModel: braços/arma locais, quando necessário
└── Camera FPS: apresentação local

Emote/finisher aceito
└── câmera externa TPP temporária, com colisão e retorno seguro ao FPS
```

O servidor não pode decidir ataque/dano só pela câmera local: câmeras são apresentação e podem diferir em cada máquina. No Wave, vida, combate e rede já têm componentes próprios (`WaveHealthComponent`, `WaveCombatController` etc.); não colocaremos essas responsabilidades neste script de movimento.

## Problemas comuns

| Sintoma | Causa provável | Correção |
| --- | --- | --- |
| Player cai para sempre | Chão sem `StaticBody3D` e `CollisionShape3D`. | Revise a colisão do mapa. |
| Não anda | Nome no Input Map é diferente do script. | Compare letra por letra. |
| Mouse não gira | Script não está na raiz ou câmera não está Current. | Confira ambos. |
| Cursor preso | É `MOUSE_MODE_CAPTURED`. | Aperte Esc. |
| Câmera TPP atravessa tudo | Parede sem colisão. | Adicione colisão ao cenário. |
| FPS vê cápsula por dentro | `WorldBody` visível na câmera local. | Esconda-o só no protótipo; depois use viewmodel. |
| Player nasce enterrado | Cápsula/Player baixos demais. | Cápsula em Y 0.9; Player acima do chão. |

## Depois desta aula

1. Trocar cápsula por modelo/esqueleto.
2. Adicionar `AnimationPlayer` e `AnimationTree`.
3. Criar braços/arma para visão FPS.
4. Separar input, movimento, combate e animação em componentes no Wave.
5. Fazer a câmera TPP de emote/finisher trocar e retornar ao FPS com segurança.

## Referências oficiais

- [CharacterBody3D](https://docs.godotengine.org/en/4.7/classes/class_characterbody3d.html)
- [Camera3D](https://docs.godotengine.org/en/4.7/classes/class_camera3d.html)
- [SpringArm3D](https://docs.godotengine.org/en/4.7/classes/class_springarm3d.html)
- [InputEventMouseMotion](https://docs.godotengine.org/en/4.7/classes/class_inputeventmousemotion.html)
