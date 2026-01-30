class_name Weapon
extends Resource

enum ShotType{
	SHOTGUN,
	RAPID,
}

@export var shots_per_seconds: float = 1.0
@export var bullets_per_shot: int = 1
@export var shot_type: ShotType = ShotType.RAPID

# *************************************
