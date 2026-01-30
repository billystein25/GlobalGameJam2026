class_name Enemy
extends CharacterBody2D

var isAlive = true

#imports 
@onready var animsprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var snd_die = $snd_die
@onready var snd_hit = $snd_hit


#exports
@export var enemy_resource: Enemy_resource

var knockback = Vector2.ZERO

@onready var health = enemy_resource.health
@onready var power = enemy_resource.power
@onready var movementspeed = enemy_resource.acceleration
@onready var maxspeed = enemy_resource.max_speed

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
		
		
func anim():
	if !isAlive:
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
