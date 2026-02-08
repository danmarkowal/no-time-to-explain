extends Resource
class_name SlotData

@export var item_data: ItemData
@export var quantity: int

func is_empty() -> bool:
	return item_data == null

func is_valid() -> bool:
	if not is_empty():
		return quantity > 0
	return true

func set_item(item: ItemData) -> void:
	if item.stack_size <= 0:
		push_error("Invalid item stack size %d" % item.stack_size)
		return
	item_data = item
	quantity = 1

func clear() -> void:
	item_data = null
	quantity = 0

func item_matches(item: ItemData) -> bool:
	if item_data == null:
		return false
	return item_data.id == item.id

# returns whether the item was successfully added
func try_increment(count: int) -> bool:
	if item_data == null or quantity + count > item_data.stack_size:
		return false
	quantity += count
	return true

# returns whether the item was successfully removed
func try_decrement(count: int) -> bool:
	if item_data == null or quantity - count < 0:
		return false
	quantity -= count
	if quantity == 0:
		clear()
	return true
