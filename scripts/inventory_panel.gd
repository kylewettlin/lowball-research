class_name InventoryPanel
extends CenterContainer
## Back room: view owned items, clean/repair them, and put them on display.

signal closed

@onready var item_list: ItemList = %InvItemList
@onready var detail_label: Label = %InvDetail
@onready var clean_button: Button = %CleanButton
@onready var display_button: Button = %DisplayButton


func _ready() -> void:
	hide()
	item_list.item_selected.connect(_on_item_selected)
	clean_button.pressed.connect(_on_clean)
	display_button.pressed.connect(_on_toggle_display)
	%CloseButton.pressed.connect(_on_close)


func open() -> void:
	_refresh_list(0)
	show()


func _refresh_list(select: int) -> void:
	item_list.clear()
	for item in GameState.inventory:
		var tag := "   [ON DISPLAY]" if item.on_display else ""
		item_list.add_item("%s  -  %d%% condition, est. $%d%s" % [
			item.name, item.condition, item.estimated_worth(), tag])
	if select < item_list.item_count:
		item_list.select(select)
	_update_detail()


func _selected_index() -> int:
	var selected := item_list.get_selected_items()
	return selected[0] if selected.size() > 0 else -1


func _update_detail() -> void:
	var index := _selected_index()
	var has_item := index >= 0
	clean_button.disabled = not has_item
	display_button.disabled = not has_item
	if not has_item:
		detail_label.text = "Your inventory is empty. Buy items from customers at the front desk."
		return
	var item := GameState.inventory[index]
	detail_label.text = item.describe()
	clean_button.disabled = item.defects.is_empty()
	display_button.text = "Take off display" if item.on_display else "Put on display"


func _on_item_selected(_index: int) -> void:
	_update_detail()


func _on_clean() -> void:
	var index := _selected_index()
	GameState.inventory[index].clean()
	_refresh_list(index)


func _on_toggle_display() -> void:
	var index := _selected_index()
	var item := GameState.inventory[index]
	item.on_display = not item.on_display
	_refresh_list(index)


func _on_close() -> void:
	hide()
	closed.emit()
