extends Node2D
class_name Spectator

enum SPECTATOR_STATE {
	DEFAULT,
	THROW,
	CHEER
}

@onready var red_sprite = preload("res://assets/sprites/spectator_red.png")

@onready var sprite_pivot: Node2D = get_node("sprite_pivot")
@onready var sprite: Sprite2D = get_node("sprite_pivot/Sprite")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

var random_start_y_offset = 0

var current_state = SPECTATOR_STATE.DEFAULT:
	get: 
		return current_state
	set(value):
		current_state = value
		match current_state:
			SPECTATOR_STATE.DEFAULT:
				pass
			SPECTATOR_STATE.THROW:
				animation_player.play("throw")

# Called when the node enters the scene tree for the first time.
func _ready():
	#sprite.flip_h = randi() % 2 == 1
	random_start_y_offset = randf_range(-3, 3)
	
	if randi() % 2 == 1:
		sprite.texture = red_sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match current_state:
		SPECTATOR_STATE.DEFAULT:
			update_default(delta)


func update_default(delta):
	var side = global_position.x > 320
	
	var rot = sin(Time.get_ticks_msec() / 200) * 8
	if side:
		sprite.rotation_degrees = rot
	else:
		sprite.rotation_degrees = -rot

func spawn_item():
	Globals.items_manager.spawn_item(global_position)
	

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "throw":
		current_state = SPECTATOR_STATE.DEFAULT
