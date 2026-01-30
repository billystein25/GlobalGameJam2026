class_name BulletArea
extends Area2D

@export var _bullet_data: Bullet
@export var _direction: Vector2 = Vector2.ZERO
@onready var _speed: float

@export_group("Node References")
@export var collision_shape_2d: CollisionShape2D
@export var sprite_2d: Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_hit_body)


func _physics_process(delta: float) -> void:
	position += _direction * _speed * delta


func _on_hit_body(body: Node2D) -> void:
	if body.has_method("got_hit"):
		body.got_hit(_bullet_data, _direction)
		queue_free()


static func create_bullet(dir: Vector2, data: Bullet) -> BulletArea:
	var blt_packed_scene: PackedScene = load("uid://4is5wcssq4ed")
	var blt_scene: BulletArea = blt_packed_scene.instantiate()
	if not data:
		data = Bullet.new()
	else:
		blt_scene._bullet_data = data
	blt_scene._speed = randf_range(data.min_bullet_speed, data.max_bullet_speed)
	blt_scene._direction = dir.rotated(randf_range(-deg_to_rad(data.spread), deg_to_rad(data.spread)))
	blt_scene.collision_shape_2d.shape = data.collision_box
	blt_scene.sprite_2d.texture = data.texture
	
	return blt_scene

# ****************************
