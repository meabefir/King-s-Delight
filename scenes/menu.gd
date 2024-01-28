extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@onready var game_scene = preload("res://scenes/game/game.tscn")

func _on_button_button_down():
	get_tree().change_scene_to_packed(game_scene)
