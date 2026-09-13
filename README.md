# LearningGDScript

Projeto de estudo para aprender GDScript antes de começar a desenvolver o jogo de waves na Godot.

## Como abrir

1. Abra a Godot.
2. Clique em **Import**.
3. Selecione o arquivo `project.godot` desta pasta.
4. Abra o projeto e execute com `F6` (cena atual) ou `F5` (projeto).

A cena inicial imprime exemplos no painel **Output** da Godot. Os arquivos em `scripts/` são comentados para leitura junto do [onboarding.md](onboarding.md).

Para estudar GDScript passo a passo, use as [aulas de cada dia](onboarding_gdscript/README.md).

Depois de terminar a trilha de linguagem, siga o [onboarding do editor](onboarding_editor.md) para aprender a montar cenas, mapas 3D, iluminação, ambiente e navegação na Godot.

## Estrutura

```text
LearningGDScript/
├── project.godot          # Configuração do projeto Godot
├── scenes/Main.tscn       # Cena inicial mínima
├── scripts/Main.gd        # Ponto de entrada da cena
├── scripts/StudyCharacter.gd
│                          # Classe, encapsulamento e sinais
└── scripts/exemplos/01_fundamentos.gd
						   # Variáveis, funções, coleções e match
```
