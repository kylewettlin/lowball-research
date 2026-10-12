class_name Interactable
extends Area2D
## A shop object the player can walk up to and press E on (desk, display case,
## doors). Builds its own collision shapes from `size` and draws a placeholder box.

@export var label := ""
@export var size := Vector2(64, 64)
@export var color := Color.WHITE
## Solid objects also block the player (desk, display case). Doors don't.
@export var solid := false

const REACH := 48.0


func _ready() -> void:
	var area_rect := RectangleShape2D.new()
	area_rect.size = size + Vector2(REACH, REACH)
	var area_shape := CollisionShape2D.new()
	area_shape.shape = area_rect
	add_child(area_shape)

	if solid:
		var body_rect := RectangleShape2D.new()
		body_rect.size = size
		var body_shape := CollisionShape2D.new()
		body_shape.shape = body_rect
		var body := StaticBody2D.new()
		body.add_child(body_shape)
		add_child(body)


func set_label(text: String) -> void:
	label = text
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-size / 2, size), color)
	var width := maxf(size.x, 160.0)
	draw_string(ThemeDB.fallback_font, Vector2(-width / 2, -size.y / 2 - 8), label,
			HORIZONTAL_ALIGNMENT_CENTER, width, 14)
