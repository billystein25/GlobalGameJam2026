extends Node2D

@export var bullet_data: Bullet
@export var bullet_dir: Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(BulletArea.create_bullet(bullet_dir, bullet_data))
