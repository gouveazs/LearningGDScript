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

## 3. Cópia versus referência

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

## 4. `enum`: nomes para números

Estados e tipos não devem depender de números mágicos como `if state == 3`. Dê nomes a eles.

```gdscript
enum ItemType { WEAPON, POTION, MATERIAL }

var item_type: ItemType = ItemType.POTION
```

Por baixo dos panos, os valores ainda são inteiros. O benefício é legibilidade e autocomplete.

## 5. `match`: escolha por casos

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

## 6. Planeje os dados antes da lógica

Para comprar um item, responda antes:

- Como encontro o item? `id` é melhor que nome visível.
- O item empilha? Qual campo guarda a quantidade?
- O jogador pode ter ouro negativo? Não.
- O que acontece se ele tentar vender algo que não tem?

Escrever essas regras antes evita um inventário que parece funcionar só no caso perfeito.

## Desafio — inventário e loja da princesa

Crie uma loja como `Array[Dictionary]` e um inventário inicialmente vazio. Cada item deve ter `id`, `display_name`, `type`, `price` e `quantity`.

Implemente funções como:

```gdscript
func find_item_index(inventory: Array[Dictionary], item_id: String) -> int:
	return -1 # Você implementa.

func buy_item(item_id: String) -> bool:
	return false # Você implementa.
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
