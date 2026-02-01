class_name Enemy_resource
extends Resource

enum EnemyTypes{
	WIZARD,
	GOBLIN,
	ELF,
	TROLL,
	VAMPIRE
}

@export var bullet: Bullet
@export_group("Enemy Properties")
@export var health: float = 100.0
@export var power: float = 100.0
@export var rank: int = 1
@export var max_speed: float = 70
## Only works when [member shot_type] is [constant ShotType.SHOTGUN].
@export var acceleration: float = 100.0
@export var type: EnemyTypes
@export var offset: Vector2

## In degrees
@export_group("Child Properties")
@export var collision_box: Shape2D
@export var texture: Texture
@export var sprite_anime: SpriteFrames
@export var death_sound: AudioStream

# *************************************
