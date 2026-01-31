class_name Enemy_resource
extends Resource

@export var bullet: Bullet
@export_group("Enemy Properties")
@export var health: float = 100.0
@export var power: float = 100.0
@export var rank: int = 1
@export var max_speed: float = 150
## Only works when [member shot_type] is [constant ShotType.SHOTGUN].
@export var acceleration: float = 100.0
@export var type: int = 0

## In degrees
@export_group("Child Properties")
@export var collision_box: Shape2D = CircleShape2D.new()
@export var texture: Texture = load("res://icon.svg")

# *************************************
