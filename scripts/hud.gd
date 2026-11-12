extends CanvasLayer

@onready var ammo_label: Label = find_child("AmmoLabel", true, false)
@onready var asprite: AnimatedSprite2D = $MarginContainer/PanelContainer/HBoxContainer/Banananana/AnimatedSprite2D

func _ready() -> void:
	asprite.play()

func update_ammo(count: int) -> void:
	if not ammo_label:
		ammo_label = find_child("AmmoLabel", true, false)
	
	if ammo_label:
		ammo_label.text = "x " + str(count)
