# Onboarding do Editor Godot 4.7 — vindo da Unreal

Este guia usa como referência a **Godot 4.7.2 stable** e os nomes da interface em português brasileiro. Ele é a segunda etapa do [onboarding.md](onboarding.md): primeiro você aprende GDScript; aqui aprende a transformar código e assets em uma fase jogável.

> A equivalência mais importante: na Unreal você pensa em *Actors dentro de um Level*. Na Godot você pensa em *Nodes dentro de uma Scene*. Uma Scene pode ser um mapa inteiro, um jogador, uma arma, um inimigo ou uma UI — e pode ser instanciada dentro de outra Scene.

## Antes de abrir: o vocabulário que muda

| Unreal Engine | Godot | Ideia prática |
| --- | --- | --- |
| Projeto `.uproject` | `project.godot` | Arquivo-raiz da configuração do projeto. |
| Level / Map `.umap` | Scene `.tscn` | Um mapa normalmente é uma Scene cujo nó raiz é `Node3D`. |
| Actor | `Node` | Tudo que existe na cena é um Node ou um conjunto deles. |
| Actor com Components | Node com Nodes filhos | Um `CharacterBody3D` pode ter malha, colisão, câmera e áudio como filhos. |
| Blueprint | Scene + script `.gd` | A cena descreve a composição; o script descreve o comportamento. |
| Blueprint Child | Cena herdada ou cena instanciada | Prefira composição/instanciamento para partes reutilizáveis. |
| Prefab | Cena reutilizável / `PackedScene` | Ex.: `EnemySkeleton.tscn` instanciada várias vezes pela wave. |
| Details | **Inspetor** | Propriedades do Node ou Resource selecionado. |
| World Outliner | painel **Cena** | Árvore de Nodes da Scene aberta. |
| Content Browser | **Sistema de Arquivos** | Arquivos sob `res://` do projeto. |
| Data Asset | `Resource` `.tres` | Dados editáveis de inimigo, habilidade ou wave. |
| Event Dispatcher | `signal` | Evento emitido por um Node/script. |
| GameMode / GameInstance | Autoload + gerenciadores de cena | Não há cópia direta 1:1; separe estado global em Autoload. |

## Onde tudo fica no editor

### Menus superiores

- **Cena**: salva, instancia, altera dono e outras operações sobre a Scene aberta.
- **Projeto**: configurações do projeto, Input Map, autoloads, exportação e ferramentas globais.
- **Depurar**: controles de depuração, colisões/navegação visíveis e monitoramento durante teste.
- **Editor**: configurações do editor, layout, atalhos, plugins e painéis encaixáveis.
- **Ajuda**: documentação embutida e busca de classes (`F1`).

### As cinco áreas de trabalho centrais

| Aba em português | Para que serve | Equivalente mental na Unreal |
| --- | --- | --- |
| **2D** | Cenas 2D e interfaces `Control`. | Viewport 2D/UMG. |
| **3D** | Mapas, malhas, iluminação, câmera e Nodes 3D. | Level Viewport. |
| **Script** | Editor de GDScript, documentação e depurador. | IDE/Blueprint editor, mas para código. |
| **Jogo** | Exibe o jogo rodando dentro do editor. Alterações feitas enquanto roda não são salvas. | Play In Editor embutido. |
| **Biblioteca de Recursos** | Add-ons, ferramentas e projetos da comunidade. | Marketplace, mas só conteúdo publicado ali e normalmente aberto. |

### Painéis laterais padrão

**Esquerda**

- **Cena**: árvore da Scene atual. É o seu World Outliner.
- **Importar**: opções de importação do arquivo selecionado no Sistema de Arquivos. Use para ajustar uma textura, um FBX/glTF, áudio etc.; depois clique em **Reimportar**.
- **Sistema de Arquivos**: arquivos do projeto. `res://` é a raiz; `user://` é armazenamento criado em tempo de execução e não aparece como conteúdo do projeto.

**Direita**

- **Inspetor**: propriedades do Node/Resource atual. É o painel que você mais usará.
- **Nó**: sinais e grupos do Node selecionado. A aba **Sinais** é a ponte mais direta para Event Dispatchers; dê duplo clique em um sinal para conectar a um método de script.
- **Histórico**: objetos e Resources visitados recentemente no Inspetor.

### Painel inferior

Os botões visíveis mudam conforme a Scene, o Node selecionado e plugins ativos. Os mais comuns são:

- **Saída**: `print()`, mensagens do editor e avisos simples.
- **Depurador**: erros, breakpoints, pilha de chamadas, variáveis e monitores de desempenho.
- **Áudio**: buses e mixer de áudio.
- **Animação**: timeline do `AnimationPlayer`.
- **Árvore de Animação**: edição do `AnimationTree`, quando ele está selecionado.
- **Editor de Shader** / **Visual Shader**: aparece ao editar esses recursos.
- Painéis de recursos específicos, como TileSet, Navigation e outros, podem aparecer quando você seleciona o Node/Resource correspondente.

> Não estranhe se sua tela não mostrar todos ao mesmo tempo. Na Godot, o editor revela ferramentas conforme o contexto; isso deixa a interface menor que a da Unreal.

## Criando um mapa 3D: primeiro nível de treino

Vamos montar um mapa mínimo para testar o futuro jogo de waves. O resultado terá chão, câmera, luz solar, céu/ambiente, colisão, pontos de spawn e navegação.

### 1. Crie e salve a cena do mapa

1. Clique em **+** ao lado das abas de Scene ou use **Cena > Nova Cena**.
2. Escolha **Outro Nó** e pesquise por `Node3D`.
3. Renomeie o nó raiz para `Map_Test`.
4. Salve em `scenes/maps/Map_Test.tscn`.

`Node3D` não renderiza nada. Ele é o organizador espacial do mapa, equivalente a começar um Level vazio antes de colocar Actors.

Estrutura inicial sugerida:

```text
Map_Test (Node3D)
├── WorldEnvironment
├── Sun (DirectionalLight3D)
├── Camera3D
├── Ground (StaticBody3D)
│   ├── MeshInstance3D
│   └── CollisionShape3D
├── NavigationRegion3D
├── PlayerSpawn (Marker3D)
└── EnemySpawns (Node3D)
	├── Spawn_01 (Marker3D)
	├── Spawn_02 (Marker3D)
	└── Spawn_03 (Marker3D)
```

### 2. Faça um chão com colisão

No começo, evite criar terreno bonito. Faça um espaço de jogo legível e testável.

1. Adicione um filho `StaticBody3D` chamado `Ground`.
2. Dentro dele, adicione `MeshInstance3D`.
3. No **Inspetor**, em **Mesh**, escolha **Novo BoxMesh**. Clique no BoxMesh criado e ajuste **Size** para algo como `(40, 1, 40)`.
4. Em `Ground`, adicione `CollisionShape3D`.
5. Em **Shape**, escolha **Novo BoxShape3D** e use o mesmo tamanho da malha.
6. Ajuste a posição Y dos filhos se necessário, para a parte de cima ficar em `Y = 0`.

O `MeshInstance3D` é visual; `CollisionShape3D` é físico. A separação é normal na Godot. Nunca deixe a colisão em um Node filho solto sem um corpo físico como `StaticBody3D`, `CharacterBody3D`, `RigidBody3D` ou `Area3D` acima dele.

Para prototipar paredes, rampas e plataformas, `CSGBox3D`, `CSGCylinder3D` e outros CSGs são rápidos. Para o mapa final, use malhas modeladas/importadas, pois CSG não é a solução mais eficiente para uma fase grande.

### 3. Coloque a câmera

1. Adicione `Camera3D` como filho de `Map_Test`.
2. No Inspetor, marque **Current** se ela for a câmera ativa.
3. Ajuste **Transform > Position** e **Transform > Rotation Degrees** até enxergar a arena.

Isso serve para ver o mapa. No jogo real, a câmera deverá ser filha do jogador (frequentemente em um `SpringArm3D`), não do mapa.

### 4. Sol: `DirectionalLight3D`

1. Adicione `DirectionalLight3D` e chame de `Sun`.
2. Rotacione-o — a posição não importa para esse tipo de luz; o que define o sol é a direção.
3. No Inspetor, ajuste **Light > Energy**, **Light > Color** e habilite **Shadow > Enabled**.

Use `DirectionalLight3D` para sol e lua. Para fontes locais, use:

| Node | Uso |
| --- | --- |
| `PointLight3D` | Lâmpada, tocha, explosão, cristal brilhante. Emite em todas as direções. |
| `SpotLight3D` | Holofote, lanterna ou feixe com direção. |
| `DirectionalLight3D` | Sol/lua; cobre a cena toda com raios paralelos. |

Não coloque dezenas de luzes com sombra por padrão. Comece com sol sombreado e poucas luzes locais; adicione sombras locais apenas quando a cena pedir.

### 5. Céu, luz ambiente, névoa e pós-processamento

Na Unreal você talvez pensasse em Sky Atmosphere + Directional Light + Skylight + Post Process Volume. Na Godot, a maior parte do equivalente central fica em:

```text
WorldEnvironment (Node)
└── Environment (Resource criado no Inspetor)
```

Passo a passo:

1. Adicione `WorldEnvironment` como filho de `Map_Test`.
2. No Inspetor, em **Environment**, escolha **Novo Environment**.
3. Clique no Resource criado para abrir as categorias de configuração.
4. Em **Background**, escolha um modo de céu e crie um **Sky**.
5. No Sky, escolha um material: **ProceduralSkyMaterial** para protótipo rápido, **PhysicalSkyMaterial** para iluminação mais física, ou **PanoramaSkyMaterial** para HDRI.
6. Ajuste **Ambient Light**, **Tonemap**, **Glow**, **Fog** e, quando fizer sentido, **SSAO**.

`WorldEnvironment` vale para a Scene inteira e somente um deve estar ativo por árvore de cena. Para um mapa externo, comece por céu procedural, luz ambiente moderada, uma DirectionalLight3D e névoa leve. Para interior, reduza/controle o céu e ilumine com Point/Spot lights.

> O sol e o ambiente de **visualização** da viewport ajudam você enquanto edita, mas não existem no jogo exportado. No menu de três pontos da viewport 3D, use **Add Sun to Scene** e **Add Environment to Scene** para transformar a prévia em Nodes reais.

### 6. Navegação para monstros

Para os inimigos chegarem à princesa, você precisa de dados de navegação no chão, além da colisão física.

1. Adicione `NavigationRegion3D` ao mapa.
2. No Inspetor, crie um `NavigationMesh` para a propriedade de navegação.
3. Configure as geometrias que serão consideradas no bake e use a ação de **Bake Navmesh** no editor.
4. No inimigo, use `NavigationAgent3D` como filho e entregue a ele a posição-alvo da princesa.

O paralelo é `NavMeshBoundsVolume` + AI Move To da Unreal, mas a Godot normalmente deixa o `NavigationRegion3D` como parte explícita da cena. Sempre refaça o bake depois de uma mudança relevante no chão, paredes ou obstáculos estáticos.

### 7. Pontos de spawn, objetivo e testes

- Use `Marker3D` para spawn de jogador, inimigos, princesa, pickups e câmeras de teste. Eles não aparecem no jogo.
- Agrupe marcadores dentro de `EnemySpawns` para o futuro `WaveManager` encontrá-los.
- Faça uma `Princess.tscn` própria e instancie-a no mapa; não misture toda a lógica dela no arquivo do mapa.
- Coloque um `Player.tscn`, aperte **F6** para executar somente a cena atual e valide: câmera, chão, colisão, luz e navegação.

## Fluxo que substitui “criar um Level” da Unreal

```text
Godot Project
└── Map_Test.tscn (o level)
	├── ambiente e luz
	├── geometria e colisão
	├── navegação
	├── instância de Player.tscn
	├── instância de Princess.tscn
	└── WaveManager.gd
		 └── instancia Enemy.tscn nos Marker3D de spawn
```

É normal dividir uma fase em subcenas: `ArenaGeometry.tscn`, `Lighting.tscn`, `EnemySpawnPoints.tscn` e `Map_Test.tscn`. Isso é mais modular que concentrar tudo num único Level gigante.

## Navegando na viewport 3D

- Clique e arraste com o botão do meio para mover lateralmente.
- Segure botão direito e use `W`, `A`, `S`, `D`, `Q`, `E` para voar pela viewport.
- Roda do mouse ajusta a velocidade de navegação.
- `F` enquadra o Node selecionado.
- `W`, `E`, `R` alternam mover, rotacionar e escalar; confira os atalhos em **Editor > Configurações do Editor > Atalhos** se algum conflitar com seu sistema.

Na barra da viewport 3D você encontra controles de seleção, mover/rotacionar/escalar, snapping, visualização, perspectiva/ortográfica, gizmos e a prévia de sol/ambiente. Diferente da Unreal, muitos controles aparecem ou mudam de acordo com o Node selecionado.

## O que é igual e o que exige mudança de hábito

### Familiar para quem vem da Unreal

- Uma árvore organiza o conteúdo da fase.
- O Inspetor edita valores sem precisar escrever código.
- Assets ficam em uma pasta navegável e podem ser arrastados para a cena.
- Câmeras, luzes, colisores, malhas e animações continuam sendo peças separadas.
- Dá para testar dentro do editor e depurar valores em tempo de execução.

### Diferente de propósito

- Não existe um “Actor universal” tão central quanto `AActor`. Escolha o Node de acordo com a função: `Node`, `Node3D`, `CharacterBody3D`, `Area3D`, `Control` etc.
- Uma Scene não é só mapa. Trate qualquer objeto reutilizável como uma Scene própria.
- Não há um equivalente nativo direto ao Unreal Landscape para esculpir terreno enorme. Para protótipo, use CSG/meshes; para terreno final, importe uma malha/heightmap preparado ou escolha uma solução de terreno compatível.
- Não existe Blueprint como uma linguagem visual nativa geral. A composição é visual na Scene; a lógica fica majoritariamente em GDScript.
- Em vez de Dispatcher ligado em muitos Blueprints, você usará `signal`, aba **Nó > Sinais** e conexões em GDScript.
- Resources `.tres` são o caminho natural para dados editáveis de personagem, ataque, inimigo e wave.

## Organização recomendada para o futuro ABC em Godot

```text
res://
├── assets/              # modelos, texturas, sons e animações licenciados
├── scenes/
│   ├── maps/
│   ├── characters/
│   ├── enemies/
│   ├── weapons/
│   ├── ui/
│   └── props/
├── scripts/
│   ├── combat/
│   ├── ai/
│   ├── waves/
│   └── autoload/
├── resources/
│   ├── characters/
│   ├── enemies/
│   ├── attacks/
│   └── waves/
└── tests/
```

Use nomes consistentes: cenas `PascalCase.tscn`, scripts `snake_case.gd` ou o padrão que o grupo decidir, e nunca renomeie/mova arquivos pelo gerenciador do sistema enquanto o editor estiver aberto. Faça isso pelo **Sistema de Arquivos** da Godot para ela atualizar referências.

## Primeiro exercício de editor

Sem escrever lógica de jogo, crie `Map_Test.tscn` com:

- chão 40×40 com colisão;
- `WorldEnvironment` com céu procedural;
- um sol com sombras;
- três `Marker3D` para inimigos;
- um `Marker3D` para princesa;
- uma câmera que enxergue toda a arena.

Depois execute a cena. Se ela abre com o céu correto, chão iluminado e câmera ativa, você criou seu primeiro “Level” Godot de verdade.

## Referências oficiais

- [Godot 4.7.2 para Linux](https://godotengine.org/download/)
- [Primeiras impressões da interface da Godot](https://docs.godotengine.org/pt-br/4.x/getting_started/introduction/first_look_at_the_editor.html)
- [Introdução ao 3D](https://docs.godotengine.org/pt-br/4.x/tutorials/3d/introduction_to_3d.html)
- [Ambiente e pós-processamento](https://docs.godotengine.org/pt-br/4.5/tutorials/3d/environment_and_post_processing.html)
- [WorldEnvironment](https://docs.godotengine.org/pt-br/4.x/classes/class_worldenvironment.html)
