class_name Bullet
extends Resource

enum ShotType{
	SHOTGUN,
	RAPID,
}

@export_group("Bullet Properties")
@export var damage: float = 10.0
@export var shots_per_second: float = 1.0
var seconds_per_shot: float = 1.0 / shots_per_second
## Only works when [member shot_type] is [constant ShotType.SHOTGUN].
@export var bullets_per_shot: int = 1
@export var shot_type: ShotType = ShotType.RAPID
@export var min_bullet_speed: float = 100.0:
	set(value):
		min_bullet_speed = value
		max_bullet_speed = maxf(max_bullet_speed, min_bullet_speed)
@export var max_bullet_speed: float = 100.0:
	set(value):
		max_bullet_speed = value
		min_bullet_speed = minf(min_bullet_speed, max_bullet_speed)
## In degrees
@export var spread: float = 0.0
@export_group("Child Properties")
@export var collision_box: Shape2D = CircleShape2D.new()
<<<<<<< HEAD:custom resources/bullet.gd
@export_flags_2d_physics var hit_mask: int = 1
@export var texture: Texture = load("res://icon.svg")
=======
@export var texture: Texture
>>>>>>> 73e90c39c42d0327d8163055c3d8a21092c07c08:custom resources/Bullets/bullet.gd

# *************************************
