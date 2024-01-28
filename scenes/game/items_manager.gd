extends Node2D
class_name ItemsManager

@onready var MAX_ITEMS_IN_ARENA = Globals.settings["MAX_ITEMS_IN_ARENA"]

@onready var scene_item = preload("res://scenes/game/item.tscn")
@onready var scene_jester_ball = preload("res://scenes/game/jester_ball.tscn")

@onready var items = get_node("items")
@onready var jester_ball_spawn_points = get_node("jester_ball_spawn_points")
@onready var jester_balls = get_node("jester_balls")

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.items_manager = self

	print("max items in arena ", MAX_ITEMS_IN_ARENA)

func _input(event):
	if Input.is_action_just_pressed("test"):
		spawn_jester_ball(randi() % 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn_item(pos: Vector2):
	# decide what item to spawn
	var item_resource: ResourceItem = Globals.choose_resource_to_spawn()
	
	var new_item: Item = scene_item.instantiate()
	items.add_child(new_item)
	new_item.init(item_resource)
	new_item.global_position = pos
	
	# calculate impulse
	var side = -1 if pos.x > 320 else 1
	var dist_from_center = abs(320 - pos.x)
	var impulse_x = min(100, dist_from_center)
	
	new_item.apply_central_impulse(Vector2(side * impulse_x, -100))

	Events.emit_signal("item_spawned")

func get_items():
	return items.get_children()

func can_spawn_item():
	return len(get_items()) < MAX_ITEMS_IN_ARENA

func remove_from_items(item: Item):
	items.remove_child(item)
	
func spawn_jester_ball(side):
	var spawn_points = jester_ball_spawn_points.get_children()
	var spawn_point = spawn_points[side]
	var jest_ball: JesterBall = scene_jester_ball.instantiate()
	
	jester_balls.add_child(jest_ball)
	var impulse_dir = 1 if spawn_point.global_position.x < 320 else -1
	jest_ball.initial_dir = impulse_dir
	jest_ball.global_position = spawn_point.global_position
	jest_ball.apply_central_impulse(Vector2(impulse_dir * 250, 0))


func _on_jester_ball_timer_timeout():
	if len(jester_balls.get_children()) > 0:
		return
		
	spawn_jester_ball(randi() % 2)
