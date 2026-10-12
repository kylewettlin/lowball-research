class_name Player
extends CharacterBody2D
## Top-down shopkeeper. Placeholder art is drawn in code until we have sprites.

const SPEED := 260.0

var can_move := true


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED if can_move else Vector2.ZERO
	move_and_slide()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 18, Color("3d7dd8"))
	draw_circle(Vector2(0, -4), 9, Color("f1c27d"))
