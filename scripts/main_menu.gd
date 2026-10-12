extends Control


func _ready() -> void:
	%StartButton.pressed.connect(_on_start)
	%QuitButton.pressed.connect(get_tree().quit)
	%StartButton.grab_focus()


func _on_start() -> void:
	GameState.new_game()
	get_tree().change_scene_to_file("res://scenes/shop.tscn")
