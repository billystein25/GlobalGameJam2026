extends Area2D

signal request_spawn_bullet(pos: Vector2, dir: Vector2, data: Bullet)

var energy: int = 0
var onEnemy = false
var health: float = 10
var souls: int = 0 
var acceleration: float = 100.0
var speed = Vector2.ZERO
var deceleration: float = 0.4
var enemy_health: float = 0.0
var bullet: Bullet
var shot_timer: float = 0.0

var mouse_pos: Vector2
@onready var grab_area: Area2D = $GrabArea
@onready var sprite: Sprite2D = $Sprite2D
@export var enemy_data: Enemy_resource
var enemy_type 

var base_texture: Texture

var potential_grab_target: Enemy = null 



func _ready() -> void:
	add_to_group("player")
	base_texture = sprite.texture
	

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("Player Go Left", "Player Go Right", "Player Go Up", "Player Go Down")
	speed += delta * direction * acceleration
	speed *= 1.0 - deceleration
	position += speed
	
	if onEnemy and bullet:
		shot_timer -= delta
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and shot_timer <= 0:
			shoot()

func _process(delta: float) -> void:
	mouse_pos = get_global_mouse_position()

	if mouse_pos.x < global_position.x:   #TODO: Test if sprite.flip_h = true is better
		scale.x = -1
	else:
		scale.x = 1
	
	# Input handling for Grab/Leave
	if Input.is_action_just_pressed("Jumb"): # Spacebar usually
		print("jumb")
		if onEnemy:
			leave()
		elif is_instance_valid(potential_grab_target):
			try_grab(potential_grab_target)

func kill_enemy() -> void:
	energy += 1
	souls += 1 
	print("Energy Gained! Total: ", energy)
	
	# Existing mechanic: slightly reduce deceleration every 5 kills (optional)
	if souls % 5 == 0:
		deceleration *= 0.95


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
	
	# Transfer stats
	enemy_health = enemy_data.health 
	bullet = enemy_data.bullet
	enemy_type = enemy_data.type
	
	# Visuals
	if enemy_data.texture:
		sprite.texture = enemy_data.texture
	
	# Movement stats (adjust to match enemy feel)
	acceleration = enemy_data.acceleration
	
	onEnemy = true
	potential_grab_target = null 
	
	enemy.queue_free()

func leave() -> void:
	if !onEnemy: return
	
	print("Leaving enemy form.")
	onEnemy = false
	enemy_data = null
	bullet = null
	
	# Restore base stats
	sprite.texture = base_texture

func shoot() -> void:
	if !bullet: return
	
	shot_timer = bullet.seconds_per_shot
	var dir = (get_global_mouse_position() - global_position).normalized()
	
	for i in range(bullet.bullets_per_shot):
		request_spawn_bullet.emit(global_position, dir, bullet)
		
func select(potential_target: Enemy):
	if potential_target.enemy_resource.rank <=energy:
		potential_grab_target = potential_target

func _on_grab_area_body_entered(body: Node2D) -> void:
	if body is Enemy and !is_instance_valid(potential_grab_target):
		select(body)

func _on_grab_area_body_exited(body: Node2D) -> void:
	if body == potential_grab_target:
		potential_grab_target = null
