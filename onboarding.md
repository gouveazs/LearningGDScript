# Onboarding de GDScript — 5 dias

Este roteiro parte de uma base em C++: você já conhece controle de fluxo, funções, vetores, classes, herança e algoritmos. O foco aqui não é reaprender programação; é aprender a pensar e escrever no estilo de GDScript antes de entrar com força no editor da Godot.

> Este arquivo é o mapa resumido da trilha. Para estudar com explicações, exemplos e checklists, abra as [aulas separadas de cada dia](onboarding_gdscript/README.md).

## Objetivo

Em cinco dias, criar uma simulação em texto do núcleo do nosso jogo: jogador, princesa, monstros, combate e waves. No fim, a lógica estará pronta para virar cenas, Nodes, sprites, colisores e UI na Godot.

Sugestão de ritmo: de 1h30 a 3h por dia. Leia os tópicos, faça pequenos testes próprios e só então parta para o desafio. Não procure a solução antes de ter tentado, depurado e reformulado ao menos uma vez.

## Mapa mental: C++ para GDScript

| Em C++ | Em GDScript |
| --- | --- |
| `std::vector` | `Array` |
| `std::unordered_map` / `std::map` | `Dictionary` |
| `struct` / `class` | `class`, normalmente baseada em `RefCounted` ou `Node` |
| Headers e arquivos de implementação | Um arquivo `.gd` por classe, normalmente |
| `switch` | `match` |
| Ponteiros e gerenciamento manual | Referências gerenciadas; sem ponteiros explícitos no uso cotidiano |
| Eventos/callbacks próprios | Signals |
| `int main()` | Um script executado por uma cena/Node, ou via terminal para os exercícios |

GDScript suporta tipagem estática opcional e vale usá-la desde o começo. Ela ajuda o editor a detectar erros e deixa o código mais claro.

```gdscript
var vida: int = 100
var velocidade: float = 240.0
const MAX_VIDA: int = 100

func causar_dano(valor: int) -> void:
	vida -= valor
```

> Atenção: indentação faz parte da sintaxe. Não há chaves (`{}`) nem ponto e vírgula obrigatório.

---

## Dia 1 — A língua do GDScript

### Aprenda

- `var` e `const`
- Tipos básicos: `int`, `float`, `bool`, `String`
- Funções: `func`, parâmetros, retorno e `-> void`
- Operadores aritméticos, relacionais e lógicos
- Fluxo: `if`, `elif`, `else`, `for`, `while`
- Números aleatórios com `randi_range()`
- Interpolação/formatação: `"Vida: %d" % vida`
- Comentários e nomes claros

### Desafio: simulador de combate por turnos

Crie um jogador e um monstro, ambos com vida, ataque e defesa. A cada turno, o jogador escolhe entre atacar, defender ou curar. O monstro toma uma decisão aleatória. A luta termina em vitória ou derrota.

**Regras extras**

- Crie pelo menos três funções além do ponto de entrada do exercício.
- Defesa deve reduzir dano apenas durante o turno em que foi escolhida.
- Vida nunca pode ficar negativa.
- Mostre no terminal o que aconteceu a cada turno.

**Concluído quando:** o combate roda do início ao fim sem intervenção no código entre turnos e os casos de vitória/derrota funcionam.

---

## Dia 2 — Coleções e dados do jogo

### Aprenda

- `Array` e seus métodos: `append`, `erase_at`, `has`, `size`, `find`, `sort`
- `Dictionary`: criar, ler, alterar e verificar chaves
- Laços em coleções
- `enum` para categorias e estados
- `match`, a alternativa expressiva ao `switch`
- Strings e formatação de valores

```gdscript
enum TipoItem { ARMA, POCAO, MATERIAL }

var espada := {
	"nome": "Espada de Treino",
	"tipo": TipoItem.ARMA,
	"preco": 40,
	"quantidade": 1,
}
```

### Desafio: inventário e loja da princesa

Faça um inventário cujos itens tenham nome, preço, tipo e quantidade. O jogador recebe ouro, pode comprar, vender e listar seus itens.

**Regras extras**

- Use um `enum` para os tipos de item.
- Use `Dictionary` para representar os dados de cada item.
- Não permita ouro negativo nem compra sem saldo.
- Itens iguais devem acumular quantidade, não ocupar slots separados.
- A listagem deve ser legível para uma pessoa, não apenas despejar o `Dictionary` cru.

**Concluído quando:** você consegue comprar, vender, tentar uma compra inválida e ver o inventário final correto.

---

## Dia 4 — Herança, sinais e estados

### Aprenda

- Herança com `extends` e chamada a `super()`
- Sobrescrita de métodos e polimorfismo
- `signal`, `emit()` e conexão de sinais
- `Callable`
- Máquinas de estado com `enum`
- Separar transição de estado, comportamento e apresentação

### Desafio: IA de inimigo em estados

Implemente um inimigo com os estados `PATRULHANDO`, `PERSEGUINDO`, `ATACANDO` e `MORTO`. Ele deve trocar de estado conforme a distância até o alvo, vida e cooldown de ataque.

**Regras extras**

- Declare sinais para mudança de estado, ataque e morte.
- Centralize a troca de estado numa função como `mudar_estado(novo_estado)`.
- Não altere o estado diretamente em todo lugar do código.
- Crie pelo menos dois inimigos derivados com uma diferença real de comportamento.

**Concluído quando:** o terminal registra as transições corretas e cada tipo de inimigo se comporta de uma forma própria sem duplicar o sistema inteiro.

---

## Dia 5 — Mini-projeto: núcleo do ABC

Junte os aprendizados em uma versão de terminal do jogo de waves.

### Requisitos mínimos

- Uma `Princesa` com vida e condição de derrota.
- Um `Jogador` que escolhe ou executa ataques contra inimigos.
- Uma classe base de inimigo e pelo menos dois tipos derivados.
- Waves progressivas: quantidade, vida, dano ou combinação deles deve escalar.
- Estados de jogo: preparando wave, wave ativa, vitória e derrota.
- Sinais ou callbacks para morte de inimigo, começo/fim de wave e dano à princesa.
- Relatório final com waves sobrevividas, inimigos derrotados e vida restante da princesa.

### Critérios de qualidade

- Cada classe tem uma responsabilidade clara.
- Valores importantes ficam em constantes ou parâmetros, não espalhados como números mágicos.
- O jogo não quebra se uma wave nascer vazia ou se um inimigo morrer no mesmo turno em que atacaria.
- O terminal permite entender o que aconteceu sem abrir o código.

### Bônus

- Recompensa entre waves para comprar melhorias.
- Elite ou chefe a cada três waves.
- Tipos de dano e resistências.
- Seed aleatória exibida no começo da partida para reproduzir uma simulação.

---

## Como estudar sem se sabotar

1. Escreva o programa pequeno e executável antes de abstrair demais.
2. Quando der erro, leia a linha e a mensagem antes de perguntar ou pesquisar.
3. Use `print()` sem vergonha: depurar estado é parte do trabalho.
4. Só refatore depois que uma versão simples funciona.
5. Ao finalizar cada desafio, explique em voz alta a responsabilidade de cada classe. Se não der para explicar, simplifique.

## Depois dos cinco dias: editor Godot

A próxima etapa será transportar a lógica para o fluxo real da engine:

1. Projeto, cenas, Nodes e hierarquia.
2. Ciclo de vida: `_ready()`, `_process()` e `_physics_process()`.
3. Input, mouse, movimento, colisões e câmeras em primeira/terceira pessoa.
4. Instanciar inimigos e controlar waves em cena.
5. UI da vida da princesa, HUD e telas de fim de jogo.
6. Animações, áudio, partículas e polimento.

O objetivo não é escrever GDScript como C++ com sintaxe diferente. GDScript fica melhor quando o código é direto, classes são pequenas, dados são bem organizados e sistemas se comunicam por sinais.
