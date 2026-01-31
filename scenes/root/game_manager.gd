class_name GameManager
extends Node


@export_file("*.tscn") var load_scene: String
## The initial interval to spawn an enemy. A random enemy is spawned every this seconds.
@export var initial_time_to_spawn: float = 5.0
## The interval to spawn an enemy. A random enemy is spawned every this seconds.
@onready var time_to_spawn := initial_time_to_spawn
## [member time_to_spawn] is reduced by [member depletion_value] every this seconds.
@export var deplete_time_to_spawn_interval: float = 5.0
## [member time_to_spawn] is reduced by this every [member deplete_time_to_spawn_interval] seconds.
@export var depletion_value: float = 0.5
## [member time_to_spawn] will never be lower than this.
@export var min_time_to_spawn: float = 3.0
@export_group("Node References")
@export var enemies: Node
@export var projectiles: Node
@export var menu_ui: MenuUI
@export var spawners: Node
@export var enemy_spawn_timer: Timer


var active_bullets: Array[BulletArea]
var innactive_bullets: Array[BulletArea]
@onready var spawners_array: Array[EnemySpawner]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if menu_ui:
		menu_ui.load_scene = load_scene
		menu_ui.set_menu_state(MenuUI.MenuStates.NONE)
		menu_ui.is_start_menu = false
	var player = get_tree().get_first_node_in_group("player")
	player.on_leave.connect(on_leave_manager)
	if player:
		if player.has_signal("request_spawn_bullet"):
			player.request_spawn_bullet.connect(_on_enemy_spawn_bullet)
			
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		enemy.request_spawn_bullet.connect(_on_enemy_spawn_bullet)
	
	for spawner in spawners.get_children():
		if spawner is EnemySpawner:
			spawners_array.append(spawner)
	
	enemy_spawn_timer.timeout.connect(spawn_random_enemy)


func spawn_random_enemy() -> void:
	var enemy: Enemy_resource.EnemyTypes = Enemy_resource.EnemyTypes.keys().pick_random()
	var spawner: EnemySpawner = spawners_array.pick_random()


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
# ***************************************
