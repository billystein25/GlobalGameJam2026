class_name Player
extends Area2D

signal request_spawn_bullet(pos: Vector2, dir: Vector2, data: Bullet, source: Node)
signal on_leave(animation: AnimatedSprite2D, position: Vector2)
signal died()
signal update_energy(value: int)
signal update_score(value: int)

var energy: int = 10:
	set(value):
		if value > energy:
			update_score.emit(value)
		energy = value
		update_energy.emit(energy)
var onEnemy = false
var health: float = 1
var souls: int = 0 
var acceleration: float = 150.0
var speed = Vector2.ZERO
var deceleration: float = 0.4
var enemy_health: float = 0.0
var bullet: Bullet
var shot_timer: float = 0.0

var mouse_pos: Vector2
@onready var grab_area: Area2D = $GrabArea
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var enemy_data: Enemy_resource
var enemy_type: Enemy_resource.EnemyTypes
@export_flags_2d_physics var bullet_hit_mask: int = 2
var current_enemy_type: Enemy_resource.EnemyTypes

var base_acceleration: float
var base_deceleration: float
var base_shape: Shape2D
var base_sprite_scale: Vector2

var potential_grab_target: Enemy = null 
@onready var hurtbox: CollisionShape2D = $PlayerHurtbox
@onready var health_bar: ProgressBar = $HealthBar

@export var decay_rate: float = 2.0 # Health lost per second while possessing
var is_dying: bool = false


func _ready() -> void:
	add_to_group("player")
	sprite.play("idle")
	base_acceleration = acceleration
	base_deceleration = deceleration
	base_shape = hurtbox.shape
	base_sprite_scale = sprite.scale
	

func _physics_process(delta: float) -> void:
	if is_dying: return
	var direction = Input.get_vector("Player Go Left", "Player Go Right", "Player Go Up", "Player Go Down")
	speed += delta * direction * acceleration
	speed *= 1.0 - deceleration
	position += speed
	
	if onEnemy:
		# enemy_health -= decay_rate * delta
		# health_bar.value = enemy_health
		if enemy_health <= 0:
			leave()
	
	if onEnemy and bullet:
		shot_timer -= delta
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and shot_timer <= 0:
			shoot()

func _process(delta: float) -> void:
	if is_dying: return
	mouse_pos = get_global_mouse_position()

	if onEnemy:
		match current_enemy_type:
			Enemy_resource.EnemyTypes.WIZARD:
				sprite.play("wizard")
			Enemy_resource.EnemyTypes.TROLL:
				sprite.play("troll")
			Enemy_resource.EnemyTypes.ELF:
				sprite.play("elf")
			Enemy_resource.EnemyTypes.VAMPIRE:
				sprite.play("vampire")
			_:
				sprite.play("walk")
	else:
		sprite.play("walk")
	
	if mouse_pos.x > global_position.x:   #TODO: Test if sprite.flip_h = true is better
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	
	# Input handling for Grab/Leave
	if Input.is_action_just_pressed("Jumb"): # Spacebar usually
		print("jumb")
		if onEnemy:
			leave()
		elif is_instance_valid(potential_grab_target):
			try_grab(potential_grab_target)

func kill_enemy(enemy_data: Enemy_resource) -> void:
	energy += enemy_data.power
	souls += 1 
	print("Energy Gained! Total: ", energy)
	
	# Existing mechanic: slightly reduce deceleration every 5 kills (optional)
	if souls % 5 == 0:
		base_deceleration *= 0.95
		if !onEnemy:
			deceleration = base_deceleration


func try_grab(enemy: Enemy) -> void:
	var rank_cost = enemy.enemy_resource.rank
	if energy >= rank_cost:
		energy -= rank_cost
		print("Grabbed Enemy (Rank ", rank_cost, "). Energy Left: ", energy)
		grab(enemy)
	else:
		print("Not enough energy! Need ", rank_cost, ", have ", energy)

func grab(enemy: Enemy) -> void:
	enemy_data = enemy.enemy_resource
	enemy_data.bullet.hit_mask = bullet_hit_mask
	current_enemy_type = enemy_data.type
	
	
	enemy_health = enemy.health 
	bullet = enemy_data.bullet
	enemy_type = enemy_data.type
	
	# init health bar
	health_bar.visible = true
	health_bar.max_value = enemy_data.health # Use resource health as MAX
	health_bar.value = enemy_health          # Use instance health as CURRENT
	
	hurtbox.shape = enemy_data.collision_box
	sprite.scale*=1.5

	
	if enemy_data.collision_box:
		hurtbox.shape = enemy_data.collision_box
	
	# Movement stats (adjust to match enemy feel)
	acceleration = enemy_data.acceleration * 0.8
	
	onEnemy = true
	potential_grab_target = null 
	
	enemy.be_possessed()

func leave() -> void:
	if !onEnemy: return
	
	print("Leaving enemy form.")
	onEnemy = false
	var newAnimSprite := AnimatedSprite2D.new()
	newAnimSprite.sprite_frames = enemy_data.sprite_anime
		
	health_bar.visible = false
	
	on_leave.emit(newAnimSprite, global_position, enemy_data.type == Enemy_resource.EnemyTypes.WIZARD)
	
	enemy_data = null
	bullet = null
	
	# Restore base stats
	sprite.scale = base_sprite_scale
	acceleration = base_acceleration
	deceleration = base_deceleration
	hurtbox.set_deferred("shape", base_shape)

func shoot() -> void:
	if !bullet: return
	
	shot_timer = bullet.seconds_per_shot
	var dir = (get_global_mouse_position() - global_position).normalized()
	
	for i in range(bullet.bullets_per_shot):
		request_spawn_bullet.emit(global_position, dir, bullet, self)
		
func select(potential_target: Enemy):
	if potential_target.enemy_resource.rank <=energy and potential_target.isAlive:
		potential_grab_target = potential_target

func _on_grab_area_body_entered(body: Node2D) -> void:
	if body is Enemy and !is_instance_valid(potential_grab_target):
		select(body)

func _on_grab_area_body_exited(body: Node2D) -> void:
	if body == potential_grab_target:
		potential_grab_target = null


func got_hit(current_bullet: Bullet, bullet_direction: Vector2) -> void:
	health_bar.value = enemy_health
	if onEnemy:
		enemy_health -= current_bullet.damage
		print("Enemy Body Hit! HP: ", enemy_health)
		if enemy_health <= 0:
			leave()
	else:
		health -= current_bullet.damage
		print("Player Mask Hit! HP: ", health)
		if health <= 0:
			print("Player Died!")
			is_dying = true
			sprite.play("death")
			await sprite.animation_finished
			died.emit()
			queue_free()
