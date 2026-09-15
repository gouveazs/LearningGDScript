# Dia 2 — Coleções e dados de jogo

**Meta:** representar vários itens e informações relacionadas sem criar dezenas de variáveis soltas.

## 1. `Array`: uma lista ordenada

`Array` é o parente mais próximo de `std::vector`. Ele guarda valores em ordem e começa no índice `0`.

```gdscript
var enemies: Array[String] = ["Esqueleto", "Morcego"]
enemies.append("Goblin")

print(enemies[0]) # Esqueleto
print(enemies.size()) # 3

for enemy_name in enemies:
	print("Inimigo: %s" % enemy_name)
```

Métodos úteis:

| Operação | Exemplo |
| --- | --- |
| Adicionar | `items.append(item)` |
| Remover por índice | `items.remove_at(index)` |
| Verificar valor | `items.has(item)` |
| Encontrar índice | `items.find(item)` |
| Limpar | `items.clear()` |
| Tamanho | `items.size()` |

Antes de acessar `items[index]`, confirme que o índice existe: `if index >= 0 and index < items.size():`.

## 2. `Dictionary`: dados por chave

Um `Dictionary` funciona como mapa/hash map: você usa uma chave em vez de uma posição numérica.

```gdscript
var potion: Dictionary = {
	"id": "healing_potion",
	"display_name": "Poção de Cura",
	"price": 25,
	"quantity": 2,
}

potion["quantity"] += 1
print("%s: %d" % [potion["display_name"], potion["quantity"]])
```

Cheque uma chave antes de usá-la quando ela não é garantida:

```gdscript
if potion.has("price"):
	print(potion["price"])
```

Hoje Dictionaries são bons para prototipar itens. No dia 3, quando o item ganhar comportamento próprio, uma classe ou `Resource` será uma escolha melhor.

## 3. A parte que faltou: `Array[Dictionary]`

Sim, uma Array pode conter Dictionaries. Não é uma estrutura nova ou mágica: é só uma **lista de itens**, em que **cada item é um Dictionary**.

Se vier do C++, a ideia é parecida com:

```cpp
std::vector<std::unordered_map<std::string, Valor>> shop;
```

Em GDScript, você lê `Array[Dictionary]` de fora para dentro:

```text
Array[Dictionary]
│     └─ cada posição da lista deve guardar um Dictionary
└─ uma lista ordenada
```

Imagine uma prateleira de loja:

```text
shop                         <- Array
├── item 0                   <- Dictionary
│   ├── "id": "health_potion"
│   ├── "price": 25
│   └── "quantity": 1
└── item 1                   <- Dictionary
    ├── "id": "iron_sword"
    ├── "price": 80
    └── "quantity": 1
```

### Passo 1: primeiro, crie um item sozinho

```gdscript
var health_potion: Dictionary = {
	"id": "health_potion",
	"display_name": "Poção de Cura",
	"price": 25,
	"quantity": 1,
}

print(health_potion["display_name"]) # Poção de Cura
print(health_potion["price"]) # 25
```

Aqui ainda não existe loja. Existe somente **um** item.

### Passo 2: crie a lista vazia e coloque o item nela

```gdscript
var shop: Array[Dictionary] = []
shop.append(health_potion)

print(shop.size()) # 1
print(shop[0]["display_name"]) # Poção de Cura
```

O acesso `shop[0]["display_name"]` tem duas etapas:

1. `shop[0]`: pega o primeiro Dictionary da Array.
2. `["display_name"]`: pega o valor da chave dentro daquele Dictionary.

Para ficar mais legível enquanto aprende, separe as etapas:

```gdscript
var first_item: Dictionary = shop[0]
var item_name: String = first_item["display_name"]
print(item_name)
```

### Passo 3: faça uma loja com dois itens

```gdscript
var shop: Array[Dictionary] = [
	{
		"id": "health_potion",
		"display_name": "Poção de Cura",
		"price": 25,
		"quantity": 1,
	},
	{
		"id": "iron_sword",
		"display_name": "Espada de Ferro",
		"price": 80,
		"quantity": 1,
	},
]
```

Os colchetes externos `[...]` criam a Array. Cada bloco com chaves `{...}` dentro dela é um Dictionary.

### Laboratório executável: copie isto inteiro antes de continuar

Crie uma cena com um `Node`, anexe um script e substitua o conteúdo por este exemplo. Ele já mostra **onde** cada parte deve ficar:

```gdscript
extends Node

func _ready() -> void:
	# Esta Array é local: existe apenas durante este teste.
	var shop: Array[Dictionary] = [
		{
			"id": "health_potion",
			"display_name": "Poção de Cura",
			"price": 25,
			"quantity": 1,
		},
		{
			"id": "iron_sword",
			"display_name": "Espada de Ferro",
			"price": 80,
			"quantity": 1,
		},
	]

	var first_item: Dictionary = shop[0]
	print("Primeiro item: %s" % first_item["display_name"])
	print("Preço: %d" % first_item["price"])

	for item: Dictionary in shop:
		print("%s custa %d ouro." % [item["display_name"], item["price"]])
```

Execute com `F6`. O Output deve mostrar primeiro a poção e depois os dois itens. Só depois altere nomes, preços e adicione um terceiro item para testar sozinho.

### Passo 4: percorra os itens

```gdscript
for item: Dictionary in shop:
	print("%s custa %d ouro." % [item["display_name"], item["price"]])
```

Em cada repetição, `item` é um Dictionary diferente da Array. No primeiro loop é a poção; no segundo, a espada.

### Passo 5: procure um item pelo `id`

Não use o índice `0` para representar “a poção”, pois a ordem pode mudar. Procure pelo `id`:

```gdscript
func find_item_index(items: Array[Dictionary], wanted_id: String) -> int:
	for index in range(items.size()):
		var item: Dictionary = items[index]
		if item["id"] == wanted_id:
			return index

	return -1
```

Esta é uma **função**, então ela fica fora de `_ready()`, no mesmo nível da própria `_ready()`. Já a chamada dela fica dentro de `_ready()` ou de outra função:

```gdscript
extends Node

func _ready() -> void:
	var shop: Array[Dictionary] = [] # Imagine que a loja já foi preenchida.
	var shop_index: int = find_item_index(shop, "health_potion")
	print(shop_index)

func find_item_index(items: Array[Dictionary], wanted_id: String) -> int:
	# O loop é uma ação da função, portanto fica indentado aqui dentro.
	for index in range(items.size()):
		var item: Dictionary = items[index]
		if item["id"] == wanted_id:
			return index
	return -1
```

`-1` é um valor combinado para “não encontrei”. Ele funciona porque índices válidos da Array começam em `0`.

Uso:

```gdscript
var shop_index: int = find_item_index(shop, "health_potion")
if shop_index == -1:
	print("Item não encontrado.")
else:
	var shop_item: Dictionary = shop[shop_index]
	print("Encontrei: %s" % shop_item["display_name"])
```

> Antes de tentar loja, copie esses cinco passos para um `Node` de teste e rode com `F6`. Só avance quando conseguir explicar o que `shop[0]["price"]` faz.

## 4. Cópia versus referência

Arrays e Dictionaries são referências. Se duas variáveis apontam ao mesmo Dictionary, mudar uma muda a outra:

```gdscript
var original := {"health": 100}
var same_data := original
same_data["health"] = 50
print(original["health"]) # Também vira 50.
```

Para uma cópia independente, use `duplicate()`:

```gdscript
var copied_data: Dictionary = original.duplicate(true)
```

O `true` pede cópia profunda, útil se houver Arrays/Dictionaries dentro do Dictionary.

## 5. `enum`: nomes para números

Estados e tipos não devem depender de números mágicos como `if state == 3`. Dê nomes a eles.

```gdscript
enum ItemType { WEAPON, POTION, MATERIAL }

var item_type: ItemType = ItemType.POTION
```

Por baixo dos panos, os valores ainda são inteiros. O benefício é legibilidade e autocomplete.

## 6. `match`: escolha por casos

`match` ocupa o espaço do `switch` e é muito bom para enums.

```gdscript
func describe_item(item_type: ItemType) -> String:
	match item_type:
		ItemType.WEAPON:
			return "Pode causar dano."
		ItemType.POTION:
			return "Pode restaurar vida."
		ItemType.MATERIAL:
			return "Serve para crafting."
		_:
			return "Tipo desconhecido."
```

`_` é o caso padrão. Mantenha-o quando uma entrada inesperada não deve quebrar o jogo.

## 7. Planeje os dados antes da lógica

Para comprar um item, responda antes:

- Como encontro o item? `id` é melhor que nome visível.
- O item empilha? Qual campo guarda a quantidade?
- O jogador pode ter ouro negativo? Não.
- O que acontece se ele tentar vender algo que não tem?

Escrever essas regras antes evita um inventário que parece funcionar só no caso perfeito.

## Desafio — inventário e loja da princesa

Este desafio é em quatro etapas. **Não tente comprar/vender antes de a etapa anterior funcionar.**

### Etapa A — mostrar a loja

Crie `shop: Array[Dictionary]` com dois itens e uma função `print_shop()`. Ela deve percorrer a loja e imprimir nome e preço.

### Etapa B — encontrar um item

Copie e entenda `find_item_index()` acima. Teste três casos: primeiro item, segundo item e um `id` inexistente. Só siga se você entende por que retorna `-1`.

### Etapa C — compra sem inventário ainda

Crie `var player_gold: int = 100`. Faça uma função que recebe um `item_id`, procura na loja e:

1. falha se o item não existir;
2. falha se não houver ouro;
3. reduz o ouro e mostra uma mensagem se a compra for válida.

Nesta etapa, você ainda não precisa adicionar nada ao inventário.

### Etapa D — inventário e venda

Agora crie `var inventory: Array[Dictionary] = []`. Quando comprar, adicione uma cópia do item da loja ao inventário. Se ele já existir, aumente `quantity` em vez de adicionar outro Dictionary. Por último, implemente venda.

Cada item deve ter `id`, `display_name`, `type`, `price` e `quantity`.

Esqueleto das funções — agora você já viu cada tipo usado aqui:

```gdscript
func find_item_index(items: Array[Dictionary], wanted_id: String) -> int:
	return -1 # Substitua pela busca que você aprendeu.

func buy_item(item_id: String) -> bool:
	return false # Retorne true apenas se a compra realmente acontecer.
```

### Regras

- Use `enum ItemType`.
- Não compre com ouro insuficiente.
- Item repetido deve aumentar `quantity`.
- Vender deve falhar de maneira amigável quando o item não existir.
- Uma função `print_inventory()` deve mostrar ouro, nome e quantidade de cada item.

### Checklist

- [ ] Compra válida reduz ouro e adiciona item.
- [ ] Compra inválida não altera ouro nem inventário.
- [ ] Venda reduz quantidade e aumenta ouro.
- [ ] Não há dependência de índices fixos da loja.
