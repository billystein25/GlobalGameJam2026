class_name Enemy
extends CharacterBody2D

signal request_spawn_bullet(pos: Vector2, dir: Vector2, data: Bullet, source: Node)
signal died(me: Enemy)

var isAlive = true
var direction: Vector2 = Vector2.ZERO
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
@onready var health_bar: ProgressBar = $HealthBar
@onready var rank_label: Label = $RankLabel


var knockback = Vector2.ZERO

@onready var health = enemy_resource.health
@onready var power = enemy_resource.power
@onready var movementspeed = enemy_resource.acceleration
@onready var maxspeed = enemy_resource.max_speed


func _ready() -> void:
	if animated_sprite_2d.material:
		animated_sprite_2d.material = animated_sprite_2d.material.duplicate()
	time_to_shoot.timeout.connect(_on_request_shoot)

	set_values()

func set_values() -> void:
	time_to_shoot.wait_time = enemy_resource.bullet.seconds_per_shot
	print(animated_sprite_2d)
	animated_sprite_2d.sprite_frames = enemy_resource.sprite_anime
	animated_sprite_2d.offset = enemy_resource.offset
	collision_shape_2d.shape = enemy_resource.collision_box
  snd_die.stream = resource.death_sound
	
	health_bar.max_value = health
	health_bar.value = health
	
	if enemy_resource.type == Enemy_resource.EnemyTypes.GOBLIN:
		rank_label.text = "X"
		rank_label.modulate = Color(1, 0, 0)
	else:
		rank_label.text = str(enemy_resource.rank)
		rank_label.modulate = Color(1, 1, 1)
	
	# Adjust Health Bar Position
	var shape = collision_shape_2d.shape
	var top_offset = 0.0
	
	if shape is CapsuleShape2D:
		top_offset = shape.height / 2.0
	elif shape is CircleShape2D:
		top_offset = shape.radius
	elif shape is RectangleShape2D:
		top_offset = shape.size.y / 2.0
		
	health_bar.position.y = collision_shape_2d.position.y - top_offset - 20
	health_bar.position.x = -health_bar.size.x / 2.0
	
	rank_label.position.y = health_bar.position.y - rank_label.size.y
	rank_label.position.x = -rank_label.size.x / 2.0
	


func _physics_process(delta: float) -> void:
	
	if isAlive:
		if health <=0:
			isAlive = false
			
		#knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
		if player:
			direction = global_position.direction_to(player.position)
		
		velocity += delta * direction * movementspeed * 3
		velocity = velocity.limit_length(maxspeed)
		animsprite.flip_h = direction.x > 0
		
		move_and_slide()
	
	anim() # Ensure animation state is updated every frame


func _on_request_shoot() -> void:
	if !isAlive: return # Don't shoot if dead
	for i in enemy_resource.bullet.bullets_per_shot:
		if player:
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
		died.emit(self)
		
	elif velocity.length_squared() > 100: # Running Animation (approx 10^2)
		animsprite.play("walk")
	else:
		animsprite.play("idle")
		
		
		
func got_hit(currentBullet: Bullet, bullet_direction):
	health -= currentBullet.damage
	health_bar.value = health
	snd_hit.play()
	velocity = bullet_direction * 500
	var tween := create_tween()
	tween.tween_method(tween_shader_progress, 0.0, 1.0, 0.01)
	tween.tween_method(tween_shader_progress, 1.0, 0.0, 0.05)


func tween_shader_progress(value: float) -> void:
	if animated_sprite_2d.material is ShaderMaterial:
		animated_sprite_2d.material.set_shader_parameter("progress", value)


func be_possessed() -> void:
	# Add any specific logic here (particles, sounds, score)
	queue_free()
