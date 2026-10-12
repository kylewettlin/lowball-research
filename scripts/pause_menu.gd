extends CanvasLayer
## Esc toggles pause. This node's process_mode is "Always" so it still gets input
## while the rest of the tree is paused.


func _ready() -> void:
	hide()
	%ResumeButton.pressed.connect(_resume)
	%MainMenuButton.pressed.connect(_to_main_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		if visible:
			_resume()
		else:
			_pause()


func _pause() -> void:
	get_tree().paused = true
	show()
	%ResumeButton.grab_focus()


func _resume() -> void:
	get_tree().paused = false
	hide()


func _to_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
