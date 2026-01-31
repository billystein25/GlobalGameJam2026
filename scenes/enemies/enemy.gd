class_name Enemy
extends CharacterBody2D

signal request_spawn_bullet(pos: Vector2, dir: Vector2, data: Bullet, source: Node)

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
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


var knockback = Vector2.ZERO

@onready var health = enemy_resource.health
@onready var power = enemy_resource.power
@onready var movementspeed = enemy_resource.acceleration
@onready var maxspeed = enemy_resource.max_speed


func _ready() -> void:
	time_to_shoot.timeout.connect(_on_request_shoot)
	time_to_shoot.wait_time = enemy_resource.bullet.seconds_per_shot
	animated_sprite_2d.sprite_frames = enemy_resource.sprite_anime
	animated_sprite_2d.offset = enemy_resource.offset
	collision_shape_2d.shape = enemy_resource.collision_box
		

func _physics_process(delta: float) -> void:
	
	if isAlive:
		if health <=0:
			isAlive = false
			
		#knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
		var direction = global_position.direction_to(player.position)
		velocity += delta * direction * movementspeed * 3
		velocity = velocity.limit_length(maxspeed)
		animsprite.flip_h = direction.x > 0
		
		move_and_slide()
	
	anim() # Ensure animation state is updated every frame


func _on_request_shoot() -> void:
	if !isAlive: return # Don't shoot if dead
	for i in enemy_resource.bullet.bullets_per_shot:
		request_spawn_bullet.emit(position, position.direction_to(player.position), enemy_resource.bullet, self)
	time_to_shoot.start()


func anim():
	if !isAlive:
		if animsprite.animation == "death": return # Prevent re-triggering death logic
		
		# Death Logic
		if player and player.has_method("kill_enemy"):
			player.kill_enemy()
		snd_die.play()
		animsprite.play("death")
		await animsprite.animation_finished
		queue_free()
		
	elif velocity.length_squared() > 100: # Running Animation (approx 10^2)
		animsprite.play("walk")
	else:
		animsprite.play("idle")
		
		
		
func got_hit(currentBullet: Bullet, bullet_direction):
	health -= currentBullet.damage
	snd_hit.play()
	velocity = bullet_direction * 500


func be_possessed() -> void:
	# Add any specific logic here (particles, sounds, score)
	queue_free()
