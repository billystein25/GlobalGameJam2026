class_name BulletArea
extends Area2D


signal deactivate_bullet(bullet: BulletArea)


@export var _bullet_data: Bullet
@export var _direction: Vector2 = Vector2.ZERO
@onready var _speed: float

@export_group("Node References")
@export var collision_shape_2d: CollisionShape2D
@export var sprite_2d: Sprite2D
@export var force_innactive_timer: Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_hit_body)
	force_innactive_timer.timeout.connect(_on_force_innactive)


func _physics_process(delta: float) -> void:
	position += _direction * _speed * delta


func deactivate() -> void:
	self._speed = 0.0
	set_deferred("monitoring", false)
	deactivate_bullet.emit(self)
	force_innactive_timer.stop()


func activate() -> void:
	set_deferred("monitoring", true)
	force_innactive_timer.start()


func _on_hit_body(body: Node2D) -> void:
	if body.has_method("got_hit"):
		body.got_hit(_bullet_data, _direction)
		deactivate()


func _on_force_innactive() -> void:
	deactivate_bullet.emit(self)


static func create_bullet(dir: Vector2, data: Bullet) -> BulletArea:
	var blt_packed_scene: PackedScene = load("uid://4is5wcssq4ed")
	var blt_scene: BulletArea = blt_packed_scene.instantiate()
	BulletArea.assign_properties_to_bullet(blt_scene, dir, data)
	
	return blt_scene

static func assign_properties_to_bullet(bullet: BulletArea, dir: Vector2, data: Bullet) -> BulletArea:
	bullet._bullet_data = data
	bullet._speed = randf_range(data.min_bullet_speed, data.max_bullet_speed)
	bullet._direction = dir.rotated(randf_range(-deg_to_rad(data.spread), deg_to_rad(data.spread)))
	bullet.collision_shape_2d.shape = data.collision_box
	bullet.sprite_2d.texture = data.texture
	return bullet

# ****************************
