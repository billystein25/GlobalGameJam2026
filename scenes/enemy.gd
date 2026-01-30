extends CharacterBody2D

var isAlive = true

#imports 
@onready var animsprite = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")

#exports
@export var Bullet: Bullet
var knockback = Vector2.ZERO


@export var KnockBackRecovery = 1
@export var Health = 100
@export var power = 100
