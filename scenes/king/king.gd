extends Node2D
class_name King

@export var ui_laugh_progress: TextureProgressBar

@onready var sprite_head: AnimatedSprite2D = get_node("sprite_pivot/sprite_head")
@onready var sprite_pivot: Node2D = get_node("sprite_pivot")
@onready var amuse_animation_player: AnimationPlayer = get_node("amuse_animation_player")

@onready var LAUGH_MAX = Globals.settings["KING_LAUGH_MAX"]

@export var ui_laugh_progress_target_value = 0
@export var current_laugh_value: float = 0:
	get:
		return current_laugh_value
	set(value):
		current_laugh_value = max(0, min(LAUGH_MAX, value))
		
		if current_laugh_value <= 0:
			Events.emit_signal("lose_game")
		if current_laugh_value >= LAUGH_MAX:
			Events.emit_signal("win_game")
		
		ui_laugh_progress.value = (current_laugh_value / LAUGH_MAX) * 100

var amuse_history = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.king = self
	pass # Replace with function body.

	self.current_laugh_value = LAUGH_MAX / 2
	
	Events.amuse_king.connect(amuse)
	
	sprite_head.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	sprite_pivot.position.y = abs(sin(Time.get_ticks_msec() / 400)) * 4

	# clear amuse_history older than 15 seconds
	while len(amuse_history) and Time.get_ticks_msec() - amuse_history[0][1] > 15000:
		amuse_history.pop_front()

	# change over 15 secs
	var s = 0
	for entry in amuse_history:
		s += entry[0]
		
	if -s > Globals.settings["ANGRY_THRESHOLD_4"]:
		$AudioStreamPlayer2.play()
		sprite_head.play("angry4")
		amuse_history.clear()
		amuse(-200, false)
		
	elif s > Globals.settings["HAPPY_THRESHOLD_1"]:
		$AudioStreamPlayer3.play()
		sprite_head.play("laugh")
		amuse_history.clear()
		amuse(150, false)
		
	#if Input.is_action_just_pressed("test"):
		#amuse(50)

func amuse(val, save_to_history=true):
	current_laugh_value += val
	print("amuse ", val)
	
	# add entry to history
	if save_to_history:
		amuse_history += [[val, Time.get_ticks_msec()]]
	
		if -val > Globals.settings["ANGRY_THRESHOLD_3"]:
			if sprite_head.animation != "angry4":
				sprite_head.play("angry3")
				$AudioStreamPlayer.play()
		if -val > Globals.settings["ANGRY_THRESHOLD_2"]:
			if sprite_head.animation != "angry4":
				sprite_head.play("angry2")
				$AudioStreamPlayer.play()
		if -val > Globals.settings["ANGRY_THRESHOLD_1"]:
			if sprite_head.animation != "angry4":
				sprite_head.play("angry1")
				$AudioStreamPlayer.play()
	
func _on_sprite_head_animation_finished():
	sprite_head.play("default")


func _on_amuse_timer_timeout():
	amuse(-10, false)
