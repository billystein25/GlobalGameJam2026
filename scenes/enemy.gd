extends CharacterBody2D

var isAlive = true

#imports 
@onready var animsprite = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var snd_die = $snd_die
@onready var snd_hit = $snd_hit


#exports
@export var Bullet: Bullet
var knockback = Vector2.ZERO


@export var knockback_recovery = 1
@export var health = 100
@export var power = 100
@export var movementspeed = 100
@export var speed = 0 

func _physics_process(delta: float) -> void:
	
	if isAlive:
		if health <=0:
			emit_signal("remove_from_array",self)
			isAlive = 0
			
		knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
		var direction = global_position.direction_to(player.global_position)
		velocity = delta *speed * direction * movementspeed
		velocity += knockback
		animsprite.flip_h = direction.x > 0
		
		move_and_slide()
		
		
func anim():
	if !isAlive:
		snd_die.play()
		animsprite.play("death")
	elif velocity.x**2 + velocity.y**2 >10: #Running Animation
		animsprite.play("walk")
	else:
		animsprite.play("idle")
		
		
		
func _on_hurtbox_hurt(damage, angle, knockback_amount):
	health -= damage
	snd_hit.play()
	knockback = angle * knockback_amount
