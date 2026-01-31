class_name GameManager
extends Node


@export_file("*.tscn") var load_scene: String
@export_group("Node References")
@export var enemies: Node
@export var projectiles: Node
@export var menu_ui: MenuUI


var active_bullets: Array[BulletArea]
var innactive_bullets: Array[BulletArea]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if menu_ui:
		menu_ui.load_scene = load_scene
		menu_ui.set_menu_state(MenuUI.MenuStates.NONE)
		menu_ui.is_start_menu = false
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.has_signal("request_spawn_bullet"):
			player.request_spawn_bullet.connect(_on_enemy_spawn_bullet)
			
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		enemy.request_spawn_bullet.connect(_on_enemy_spawn_bullet)


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


# ***************************************
