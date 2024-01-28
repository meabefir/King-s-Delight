extends RigidBody2D
class_name JesterBall

@onready var MIN_TIME_BALANCE = Globals.settings["JESTER_BALL_MIN_TIME_BALANCING"]
@onready var impulse_timer: Timer = get_node("random_impulse_timer")

var spawned_at = 0
var jest = null
var jest_entered_at = null
var jest_trying_to_balance = null
var jester_failed_and_despawning = false
var despawn_dir = 0
var last_timestamp_balancing = null

var initial_dir = 0
var walking_audio_time = null

# Called when the node enters the scene tree for the first time.
func _ready():
	spawned_at = Time.get_ticks_msec()
	
	Events.jester_touched_ground.connect(jester_fall)
	
func jester_fall():
	jest_entered_at = null
	if not jest_trying_to_balance:
		return
		
	var time_on = float(Time.get_ticks_msec() - jest_trying_to_balance) / 1000
	print("stop wiggle ", time_on)
	$AudioStreamPlayer4.stop()
	jest_trying_to_balance = null
	jester_failed_and_despawning = true
	
	var jest = Globals.jester
	despawn_dir = sign(global_position.x - jest.global_position.x)
	
	if time_on < MIN_TIME_BALANCE:
		$AudioStreamPlayer.play()
		Events.emit_signal("amuse_king", -Globals.settings["JESTER_BALL_AMUSE_PENALTY"])
	else:
		$AudioStreamPlayer2.play()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Time.get_ticks_msec() - spawned_at > 1200:
		if global_position.x < -32 or global_position.x > 640 + 32:
			queue_free()
	else:
		if Time.get_ticks_msec() - spawned_at < 300:
			apply_central_force(Vector2(initial_dir * 250 * 50, 0))
	
	if jester_failed_and_despawning:
		apply_central_force(Vector2(despawn_dir * 250 * 50, 0))
	else:
		# if jest entered on top of this jest is and jest stood on top for more than 1 sec  and not already trying to balance
		if jest_entered_at and jest and Time.get_ticks_msec() - jest_entered_at >= Globals.settings["JESTER_BALL_TIME_TO_START_BALANCE"] * 1000 and not jest_trying_to_balance:
			jest_trying_to_balance = Time.get_ticks_msec()
			$AudioStreamPlayer4.play()
			print("start wiggle")

func _physics_process(delta):
	pass
	if jest:
		var vel_to_apply = jest.direction * 200 * 100
		#apply_central_impulse(Vector2(vel_to_apply, 0))
		apply_central_force(Vector2(vel_to_apply, 0))
		
	if abs(get_linear_velocity().x) > 20:
		if not $AudioStreamPlayer3.playing:
			if walking_audio_time:
				$AudioStreamPlayer3.play(walking_audio_time)
			else:
				$AudioStreamPlayer3.play()
	else:
		if $AudioStreamPlayer3.playing:
			walking_audio_time = $AudioStreamPlayer3.get_playback_position()
			$AudioStreamPlayer3.stop()

func _on_body_entered(body):
	if body is Jester:
		jest = body
		
		# only make him enter if he entered on top
		if (jest.global_position - global_position).y < 0:
			jest_entered_at = Time.get_ticks_msec()

func _on_body_exited(body):
	if body is Jester:
		jest = null


func _on_random_impulse_timer_timeout():
	#if not jest:
		#return
	if not jest_trying_to_balance:
		return
	
	var trying_to_balance_for = float(Time.get_ticks_msec() - jest_trying_to_balance) / 1000
	#print(trying_to_balance_for)
	
	if last_timestamp_balancing:
		var extra_time = float(Time.get_ticks_msec() - last_timestamp_balancing) / 1000
		#print("extra time ", extra_time)
		Events.emit_signal("amuse_king", extra_time * Globals.settings["JESTE_BALL_AMUSE_PER_SECOND"])
		last_timestamp_balancing = Time.get_ticks_msec()
		
	if not last_timestamp_balancing and trying_to_balance_for > MIN_TIME_BALANCE:
		last_timestamp_balancing = Time.get_ticks_msec()
		var extra_time = float(last_timestamp_balancing - jest_trying_to_balance) / 1000.0 - MIN_TIME_BALANCE
		#print("extra time ", extra_time)
		Events.emit_signal("amuse_king", extra_time * Globals.settings["JESTE_BALL_AMUSE_PER_SECOND"])
		
	# dynamic difficulty, the more you stay on, the harder it gets
	#apply_central_impulse(Vector2((randi() % 2 * 2 - 1) * 200 * randf_range(20, 35) * (1 + trying_to_balance_for * .2), 0))
	impulse_timer.wait_time = randf_range(.3, .8)
