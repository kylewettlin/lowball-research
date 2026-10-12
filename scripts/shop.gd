extends Node2D
## The shop floor: walk around, interact with the desk, display case and doors.

@onready var player: Player = $Player
@onready var desk: Interactable = $Desk
@onready var display_case: Interactable = $DisplayCase
@onready var back_door: Interactable = $BackDoor
@onready var front_door: Interactable = $FrontDoor
@onready var customer_marker: ColorRect = $CustomerMarker
@onready var hud_label: Label = %HudLabel
@onready var prompt_label: Label = %PromptLabel
@onready var negotiation: NegotiationPanel = %NegotiationPanel
@onready var inventory_panel: InventoryPanel = %InventoryPanel

var current: Interactable   # the object the player is standing next to


func _ready() -> void:
	for it: Interactable in [desk, display_case, back_door, front_door]:
		it.body_entered.connect(_on_body_entered.bind(it))
		it.body_exited.connect(_on_body_exited.bind(it))
	negotiation.closed.connect(_on_panel_closed)
	inventory_panel.closed.connect(_on_panel_closed)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current != null and player.can_move:
		get_viewport().set_input_as_handled()
		_interact(current)


func _interact(it: Interactable) -> void:
	if it == desk:
		if GameState.customers_left > 0:
			_open_panel()
			negotiation.open(GameState.next_customer())
	elif it == display_case or it == back_door:
		_open_panel()
		inventory_panel.open()
	elif it == front_door:
		get_tree().change_scene_to_file("res://scenes/end_of_day.tscn")


func _open_panel() -> void:
	player.can_move = false
	prompt_label.hide()


func _on_panel_closed() -> void:
	player.can_move = true
	_refresh()


func _on_body_entered(body: Node2D, it: Interactable) -> void:
	if body == player:
		current = it
		_refresh()


func _on_body_exited(body: Node2D, it: Interactable) -> void:
	if body == player and current == it:
		current = null
		_refresh()


func _refresh() -> void:
	hud_label.text = "Day %d    Cash: $%d    Customers waiting: %d    Items owned: %d" % [
		GameState.day, GameState.money, GameState.customers_left, GameState.inventory.size()]
	customer_marker.visible = GameState.customers_left > 0
	display_case.set_label("Display Case (%d for sale)" % GameState.displayed_items().size())
	prompt_label.visible = current != null
	if current != null:
		prompt_label.text = _prompt_for(current)


func _prompt_for(it: Interactable) -> String:
	if it == desk:
		return "[E] Serve customer" if GameState.customers_left > 0 else "No customers waiting"
	if it == display_case:
		return "[E] Manage display case"
	if it == back_door:
		return "[E] Go to back room (inventory & repair)"
	return "[E] Close the shop and end the day"
