class_name InfoUI
extends CanvasLayer

@export_group("Node References")
@export var score_label: Label
@export var soul_label: Label

func set_score_label(num: int) -> void:
	score_label.text = "Score: " + str(num)

func set_souls_label(num: int) -> void:
	soul_label.text = str(num)
