extends Node2D
class_name SpectatorsManager

@onready var throw_timer: Timer = get_node("throw_timer")

var spectators: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready():
	throw_timer.wait_time = Globals.settings["THROW_TIMEOUT_NORMAL"]
	print("throw wait time ", throw_timer.wait_time)
	Globals.spectators_manager = self
	spectators = get_node("spectators").get_children()
	spectators.shuffle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_throw_timer_timeout():
	if Time.get_ticks_msec() < 2000:
		return
	# check if we throw
	if not Globals.items_manager.can_spawn_item():
		return
	if len(spectators) == 0:
		return
	
	# get first spectator in list, make him throw, add in somewhere random after the half of the spectators list
	var spectator: Spectator = spectators.pop_front()
	spectator.current_state = Spectator.SPECTATOR_STATE.THROW
	
	var n = len(spectators)
	spectators.insert(randi_range(n / 2, n - 1), spectator)
	
	#throw_timer.queue_free()
