class_name Bullet
extends Resource

enum ShotType{
	SHOTGUN,
	RAPID,
}

@export_group("Bullet Properties")
@export var shots_per_second: float = 1.0
## Only works when [member shot_type] is [constant ShotType.SHOTGUN].
@export var bullets_per_shot: int = 1
@export var shot_type: ShotType = ShotType.RAPID
@export var min_bullet_speed: float = 100.0:
	set(value):
		min_bullet_speed = minf(value, max_bullet_speed)
@export var max_bullet_speed: float = 100.0:
	set(value):
		max_bullet_speed = maxf(value, min_bullet_speed)
## In degrees
@export var spread: float = 0.0
@export_group("Child Properties")
@export var collision_box: Shape2D = CircleShape2D.new()
@export var texture: Texture = load("res://icon.svg")

# *************************************
