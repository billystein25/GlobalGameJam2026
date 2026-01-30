extends Area2D

var onEnemy = false
var health: float = 10
var souls: int = 0 
var acceleration: float = 100.0
var speed = Vector2.ZERO
var deceleration: float = 0.4
var enemy_health: float = 0.0
var bullet: Bullet


@onready var grab_area: Area2D = $GrabArea
@export var enemy_data: Enemy_resource



func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("Player Go Left", "Player Go Right", "Player Go Up", "Player Go Down")
	speed += delta * direction * acceleration
	speed *= 1.0 - deceleration
	position += speed

func kill_enemy():
	souls += 1
	print(souls)
	if souls%5 == 0:
		deceleration *= 0.95
	
func grab(enemy: Enemy) -> void:
	enemy_data = enemy.enemy_resource
	enemy.queue_free() # TODO: Transfer to manager
	
	enemy_health = enemy_data.health
	bullet = enemy_data.bullet #TODO: Change color to player bullet
	
	
func _on_grab_area_body_entered(body: Node2D) -> void:
	if (body is Enemy) and !onEnemy:
		onEnemy = true
		grab(body)
		
	
