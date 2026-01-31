extends Area2D

var onEnemy = false
var health: float = 10
var souls: int = 0 
var acceleration: float = 100.0
var speed = Vector2.ZERO
var deceleration: float = 0.4
var enemy_health: float = 0.0
var bullet: Bullet

var mouse_pos: Vector2
@onready var grab_area: Area2D = $GrabArea
@onready var sprite: Sprite2D = $Sprite2D
@export var enemy_data: Enemy_resource
var enemy_type 



func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("Player Go Left", "Player Go Right", "Player Go Up", "Player Go Down")
	speed += delta * direction * acceleration
	speed *= 1.0 - deceleration
	position += speed
	

func _process(delta: float) -> void:
	mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)

	if mouse_pos.x < global_position.x:
		scale.y = -1
	else:
		scale.y = 1




func kill_enemy():
	souls += 1
	print(souls)
	if souls%5 == 0:
		deceleration *= 0.95
	

func grab(enemy: Enemy) -> void:
	enemy_data = enemy.enemy_resource
	enemy.queue_free() # TODO: Transfer to manager
	self.kill_enemy()
	
	enemy_health = enemy_data.health
	bullet = enemy_data.bullet #TODO: Change color to player bullet
	enemy_type = enemy_data.type
	
func leave():
	enemy_health=100
	


func _on_grab_area_body_entered(body: Node2D) -> void:
	if (body is Enemy) and !onEnemy:
		onEnemy = true
		grab(body)
