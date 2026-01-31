class_name EnemySpawner
extends Marker2D

const ENEMY_SCENE = preload("uid://bi38a0e7ae2gf")

const enemy_type_to_enemy_data_uid: Dictionary[Enemy_resource.EnemyTypes, String] = {
	Enemy_resource.EnemyTypes.WIZARD : "uid://c8oydlxfohjk5",
	Enemy_resource.EnemyTypes.GOBLIN : "uid://4pljwajt5qt1",
	Enemy_resource.EnemyTypes.ELF : "uid://ctnc8t8arklb8",
	Enemy_resource.EnemyTypes.TROLL : "uid://w338p4fthl3h",
	Enemy_resource.EnemyTypes.VAMPIRE : "uid://fc3ilhclgyh6",
}

func create_enemy(enemy_type: Enemy_resource.EnemyTypes) -> Enemy:
	var new_enemy: Enemy = ENEMY_SCENE.instantiate()
	var enemy_resource = load(enemy_type_to_enemy_data_uid[enemy_type])
	new_enemy.set_values(enemy_resource)
	return new_enemy
