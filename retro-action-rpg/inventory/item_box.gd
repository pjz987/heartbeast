class_name ItemBox
extends RefCounted

const MIN_ITEM_STACK = 0
const MAX_ITEM_STACK = 99

var item: Item :
	set(value):
		item = value
		item_changed.emit()

var amount := 0 :
	set(value):
		amount = clamp(value, MIN_ITEM_STACK, MAX_ITEM_STACK)
		if amount == 0: item = null
		amount_changed.emit()

signal item_changed()
signal amount_changed()

func set_item_and_amount(new_item: Item, new_amount := 1) -> ItemBox:
	item = new_item # NOTE: set item before amount
	amount = new_amount
	return self

func is_empty() -> bool:
	return item is not Item and amount <= 0
