# Aulas de GDScript — trilha de 5 dias

Estas aulas expandem o [onboarding resumido](../onboarding.md). Siga uma por dia, na ordem: cada uma usa conceitos da anterior e termina num desafio sem resposta pronta.

| Dia | Aula | Resultado esperado |
| --- | --- | --- |
| 0 | [Como a Godot pensa](00_como_godot_pensa.md) | Entender Node, Scene, script e por que `_ready()` executa. |
| 1 | [Sintaxe e lógica](dia_01_sintaxe_e_logica.md) | Um combate simples rodando no painel **Saída/Output**. |
| 2 | [Coleções e dados](dia_02_colecoes_e_dados.md) | Inventário e loja funcionando. |
| 3 | [Classes e composição](dia_03_classes_e_composicao.md) | Combatentes com habilidades e efeitos. |
| 4 | [Sinais, herança e estados](dia_04_sinais_heranca_e_estados.md) | Inimigo com IA simples e eventos. |
| 5 | [Waves e organização](dia_05_waves_e_organizacao.md) | Simulação completa do núcleo do ABC. |
| 6 | [Personagem 3D em terceira pessoa](dia_06_personagem_terceira_pessoa.md) | Um personagem com input, câmera, colisão e movimento na arena. |

## Como usar as aulas

1. Leia a **aula zero** antes do Dia 1; depois, leia apenas a aula do dia atual.
2. Copie exemplos pequenos para um script de teste e altere valores para observar o resultado.
3. Quando um trecho fizer sentido, reescreva-o sem olhar.
4. Faça o desafio no final. Não tente deixá-lo perfeito antes de funcionar.
5. Use `print()` e o painel **Saída** sem vergonha: ele é o seu primeiro debugger.

## Preparação recomendada

No projeto, crie a pasta `exercises/`. Para cada dia, faça uma cena `Dia01.tscn` com um `Node` de raiz e um script `dia_01.gd` anexado. O código começa assim:

```gdscript
extends Node

func _ready() -> void:
	print("Meu exercício começou")
```

Execute a cena com `F6` e leia o resultado no painel **Saída/Output**. Para os exercícios desta trilha, `Node` é suficiente: não precisamos de malha, física ou interface ainda.

## Convenções que vamos usar

- Variáveis, funções e arquivos: `snake_case` — `current_health`, `take_damage`.
- Classes: `PascalCase` — `StudyCharacter`, `StatusEffect`.
- Constantes: `MAIUSCULO_COM_UNDERSCORE` — `MAX_HEALTH`.
- Tipagem explícita em toda variável cujo tipo não fique óbvio.
- Um arquivo por classe quando começarmos a criar classes.

## Quando travar

Leia primeiro a mensagem de erro. Ela normalmente informa arquivo, linha e o que a Godot esperava. Depois reduza o problema: imprima valores, teste uma função isolada e só então mexa em várias coisas ao mesmo tempo.

Ao terminar o dia, mande o código ou o erro. Eu reviso a lógica sem simplesmente despejar a solução.
