class_name GameManager
extends Node


@export_file("*.tscn") var load_scene: String
@export_group("Spawn Rate")
## The initial interval to spawn an enemy. A random enemy is spawned every this seconds.
@export var initial_time_to_spawn: float = 5.0
## [member time_to_spawn] is reduced by [member depletion_value] every this seconds.
@export var deplete_time_to_spawn_interval: float = 5.0
## [member time_to_spawn] is reduced by this every [member deplete_time_to_spawn_interval] seconds.
@export var depletion_value: float = 0.5
## [member time_to_spawn] will never be lower than this.
@export var min_time_to_spawn: float = 3.0
@export_group("Max Enemies")
## Initial max spawned enemies
@export var initial_max_enemies: int = 5
@onready var max_allowed_spawned_enemies: int = initial_max_enemies:
	set(value):
		max_allowed_spawned_enemies = mini(value, max_spawned_enemies)
## [member max_allowed_spawned_enemies] will increase by 1 every this seconds
@export var increase_max_enemies_interval: float = 5.0
## [member max_allowed_spawned_enemies] will never be higher than this
@export var max_spawned_enemies: int = 5
@export_group("Node References")
@export var enemies: Node
@export var projectiles: Node
@export var menu_ui: MenuUI
<<<<<<< HEAD
@export var info_ui: InfoUI
=======
@export var background_animation: AnimatedSprite2D
>>>>>>> 21c475a697ec6bf4e027a1b81999dd7e8f4d477a
@export var spawners: Node
@export var enemy_spawn_timer: Timer
@export var increase_spawn_interval_timer: Timer
@export var increase_max_spawned_enemies_timer: Timer


var active_bullets: Array[BulletArea]
var innactive_bullets: Array[BulletArea]
@onready var spawners_array: Array[EnemySpawner]

var curr_num_enemies: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if background_animation:
		background_animation.visible = true
		background_animation.play("open")
		_handle_intro_animation()

	get_tree().paused = false
	if menu_ui:
		menu_ui.load_scene = load_scene
		menu_ui.is_start_menu = false
<<<<<<< HEAD
	var player: Player = get_tree().get_first_node_in_group("player")
=======
		menu_ui.set_menu_state(MenuUI.MenuStates.NONE)
	var player = get_tree().get_first_node_in_group("player")
>>>>>>> 21c475a697ec6bf4e027a1b81999dd7e8f4d477a
	player.on_leave.connect(on_leave_manager)
	player.died.connect(_on_player_died)
	if player:
		if player.has_signal("request_spawn_bullet"):
			player.request_spawn_bullet.connect(_on_enemy_spawn_bullet)
		player.update_energy.connect(
			func(value: int):
				info_ui.set_souls_label(value)
		)
		player.update_score.connect(
			func(value: int):
				info_ui.set_score_label(value)
		)
		
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		enemy.request_spawn_bullet.connect(_on_enemy_spawn_bullet)
	
	for spawner in spawners.get_children():
		if spawner is EnemySpawner:
			spawners_array.append(spawner)
	
	enemy_spawn_timer.wait_time = initial_time_to_spawn
	enemy_spawn_timer.start()
	
	enemy_spawn_timer.timeout.connect(spawn_random_enemy)
	increase_spawn_interval_timer.timeout.connect(_on_increase_spawn_interval)
	increase_max_spawned_enemies_timer.timeout.connect(_on_increase_max_spawned_enemies)


func spawn_random_enemy() -> void:
	if curr_num_enemies >= max_spawned_enemies: return
	var enemy: Enemy_resource.EnemyTypes = Enemy_resource.EnemyTypes.values().pick_random()
	var spawner: EnemySpawner = spawners_array.pick_random()
	var new_enemy := spawner.create_enemy(enemy)
	new_enemy.position = spawner.position
	new_enemy.request_spawn_bullet.connect(_on_enemy_spawn_bullet)
	enemies.add_child(new_enemy)
	new_enemy.died.connect(_on_enemy_death)
	curr_num_enemies += 1


func _on_enemy_death(enemy: Enemy) -> void:
	curr_num_enemies -= 1

func _on_increase_spawn_interval() -> void:
	enemy_spawn_timer.wait_time = maxf(enemy_spawn_timer.wait_time - depletion_value, min_time_to_spawn)


func _on_increase_max_spawned_enemies() -> void:
	max_allowed_spawned_enemies += 1


func _on_enemy_spawn_bullet(pos: Vector2, dir: Vector2, data: Bullet, source: Node) -> void:
	print("shoot from manager")
	var this_bullet: BulletArea
	if innactive_bullets.size() > 0:
		this_bullet = innactive_bullets.pop_front()
		BulletArea.assign_properties_to_bullet(this_bullet, dir, data, source)
		this_bullet.activate()
	else:
		this_bullet = BulletArea.create_bullet(dir, data, source)
		this_bullet.deactivate_bullet.connect(_on_bullet_deactivate)
		projectiles.add_child(this_bullet)
	active_bullets.append(this_bullet)
	this_bullet.position = pos
	this_bullet.activate()


func _on_bullet_deactivate(bullet: BulletArea) -> void:
	innactive_bullets.append(active_bullets.pop_at(active_bullets.find(bullet)))

func on_leave_manager(animation: AnimatedSprite2D, position: Vector2, isWizard: bool):
	add_child(animation)
	animation.global_position = position
	animation.scale*=6
	
	if isWizard:
		animation.play("death_wizard")
	else:
		animation.play("death")
	await animation.animation_finished
	animation.queue_free()

func _handle_intro_animation() -> void:
	await background_animation.animation_finished
	background_animation.visible = false

func _on_player_died() -> void:
	if background_animation:
		background_animation.visible = true
		background_animation.play("close")
		await background_animation.animation_finished
	
	get_tree().paused = true
	if menu_ui:
		menu_ui.visible = true
		menu_ui.set_menu_state(MenuUI.MenuStates.DEATH_MENU)
# ***************************************
