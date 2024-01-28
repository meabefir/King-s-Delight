extends Node2D

@export var parent: Node2D
@export var lock_rotation = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func fract(x):
	return x - floorf(x)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = Vector2(-fract(parent.global_position.x), 1 - fract(parent.global_position.y))
	
	#if lock_rotation:
		#rotation_degrees = -parent.rotation_degrees
