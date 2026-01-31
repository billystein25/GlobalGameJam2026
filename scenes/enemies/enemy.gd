class_name Enemy
extends CharacterBody2D

signal request_spawn_bullet(pos: Vector2, dir: Vector2, data: Bullet)

var isAlive = true

#imports 
@onready var animsprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Node2D = get_tree().get_first_node_in_group("player")
@onready var snd_die = $snd_die
@onready var snd_hit = $snd_hit


#exports
@export var enemy_resource: Enemy_resource
@export_group("Node References")
@export var time_to_shoot: Timer

var knockback = Vector2.ZERO

@onready var health = enemy_resource.health
@onready var power = enemy_resource.power
@onready var movementspeed = enemy_resource.acceleration
@onready var maxspeed = enemy_resource.max_speed


func _ready() -> void:
	time_to_shoot.timeout.connect(_on_request_shoot)
	time_to_shoot.wait_time = enemy_resource.bullet.seconds_per_shot
	


func _physics_process(delta: float) -> void:
	
	if isAlive:
		if health <=0:
			isAlive = false
			
		#knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
		var direction = global_position.direction_to(Vector2(100,100))
		velocity += delta * direction * movementspeed * 5
		velocity = velocity.limit_length(maxspeed)
		animsprite.flip_h = direction.x > 0
		
		move_and_slide()
		

func _on_request_shoot() -> void:
	for i in enemy_resource.bullet.bullets_per_shot:
		request_spawn_bullet.emit(position, position.direction_to(player.position), enemy_resource.bullet)
	time_to_shoot.start()


func anim():
	if !isAlive:
		if player and player.has_method("kill_enemy"):
			player.kill_enemy()
		snd_die.play()
		animsprite.play("death")
		await animsprite.animation_finished
		queue_free()
		
	elif velocity.x**2 + velocity.y**2 >10: #Running Animation
		animsprite.play("walk")
	else:
		animsprite.play("idle")
		
		
		
func got_hit(currentBullet: Bullet, bullet_direction):
	health -= currentBullet.damage
	snd_hit.play()
	velocity = bullet_direction * 500
