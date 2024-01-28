extends Node2D

@onready var jester_scene = preload("res://scenes/game/jester_ball.tscn")
@onready var jester_scene2 = preload("res://test/rigid_body_2d.tscn")

@onready var clutter_progress: TextureProgressBar = $CanvasLayer/clutter_progress

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	clutter_progress.max_value = int(float(Globals.settings["MAX_ITEMS_IN_ARENA"]) * 2.0 / 3.0)
	clutter_progress.value = 0
	
	Events.item_spawned.connect(item_spawned)
	Events.item_despawned.connect(item_despawned)

func item_spawned():
	clutter_progress.value = min(clutter_progress.value + 1, clutter_progress.max_value)
	if clutter_progress.value == clutter_progress.max_value:
		Events.emit_signal("explode_items")
		Events.emit_signal("amuse_king", Globals.settings["CLUTTER"]) 
	
func item_despawned():
	clutter_progress.value = clutter_progress.value - 1

func _input(event):
	pass
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#var jester = jester_scene.instantiate()
			#get_parent().add_child(jester)
			#jester.global_position = get_global_mouse_position()
			#
		#if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			#var jester = jester_scene2.instantiate()
			#get_parent().add_child(jester)
			#jester.global_position = get_global_mouse_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

