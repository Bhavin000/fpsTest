extends Control

onready var label = $Label
onready var sprite = $Sprite

func _ready():
	sprite.global_position = get_viewport().size/2

func _process(_delta):
	label.text = str(Engine.get_frames_per_second())
