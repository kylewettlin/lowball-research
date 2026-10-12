extends Control
## End-of-day summary: what happened today, then on to the next day.


func _ready() -> void:
	var s := GameState.stats
	var net: int = GameState.money - s["start_money"]
	%DayTitle.text = "End of Day %d" % GameState.day
	%StatsLabel.text = "\n".join(PackedStringArray([
		"Customers served: %d" % s["customers"],
		"Items bought: %d  (spent $%d)" % [s["bought_count"], s["bought_value"]],
		"Items sold: %d  (earned $%d)" % [s["sold_count"], s["sold_value"]],
		"Net cash today: %s$%d" % ["+" if net >= 0 else "-", absi(net)],
		"",
		"Cash on hand: $%d" % GameState.money,
		"Items in inventory: %d" % GameState.inventory.size(),
	]))
	%NextDayButton.text = "Start Day %d" % (GameState.day + 1)
	%NextDayButton.pressed.connect(_on_next_day)
	%MenuButton.pressed.connect(_on_main_menu)
	%NextDayButton.grab_focus()


func _on_next_day() -> void:
	GameState.next_day()
	get_tree().change_scene_to_file("res://scenes/shop.tscn")


func _on_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
