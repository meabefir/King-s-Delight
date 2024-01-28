extends RigidBody2D
class_name Jester

const ACC = 65
const DEC = 150
@onready var SPEED = Globals.settings["PLAYER_SPEED"]
@onready var JUMP_VELOCITY = Globals.settings["PLAYER_JUMP_FORCE"] * -1

const ITEM_INTERACT_DISTANCE = 20

#@onready var sprite = get_node("JesterIdle")
@onready var sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var grab_pivot = get_node("grab_pivot")

@onready var ground_raycast: RayCast2D = get_node("ground_raycast")
@onready var jump_raycast: RayCast2D = get_node("jump_raycast")

var walking_audio_time = null

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_highlighted_item = null
var current_grabbed_item: Item = null

var velocity = Vector2()
var last_jump_at = 0
var direction = 0

var jump_raycast_collided = true
var jump_raycast_collided_last_frame = true
var jump_raycast_just_collided = false
var ground_raycast_collided = true
var ground_raycast_collided_last_frame = true
var ground_raycast_just_collided = false


func _input(event):
	if Input.is_action_just_pressed("use"):
		grab_item()
	if Input.is_action_just_pressed("throw"):
		throw_item()

func grab_item():
	# if item grabbed, use it and return
	if current_grabbed_item:
		use_item()
		return
		
	if not current_highlighted_item:
		return
		
	$AudioStreamPlayer.pitch_scale = .8
	$AudioStreamPlayer.play()
	
	#Globals.items_manager.remove_from_items(current_highlighted_item)
	current_highlighted_item.unhighlight()
	current_grabbed_item = current_highlighted_item
	current_highlighted_item = null
	
	current_grabbed_item.freeze = true
	current_grabbed_item.reparent(grab_pivot)
	current_grabbed_item.position = Vector2()
	#grab_pivot.add_child(current_grabbed_item)
	
func use_item():
	$AudioStreamPlayer.pitch_scale = 1.2
	$AudioStreamPlayer.play()
	
	current_grabbed_item.queue_free()
	var item_data = current_grabbed_item.resource
	current_grabbed_item = null
	
	var type = item_data.clothing_type
	if type == ResourceItem.CLOTHING_TYPE.COSTUME:
		sprite.material.set_shader_parameter("color_body", item_data.color)
	elif type == ResourceItem.CLOTHING_TYPE.HAT:
		sprite.material.set_shader_parameter("color_hat", item_data.color)
	
	Events.emit_signal("item_used", item_data)
	Events.emit_signal("item_despawned")
	
func throw_item():
	if not current_grabbed_item:
		return
	# ?
	var item_global_pos = current_grabbed_item.global_position
	
	current_grabbed_item.reparent(Globals.items_manager.items)
	var side = sign(velocity.x)
	if side == 0:
		side = -1 if sprite.flip_h else 1
	current_grabbed_item.freeze = false
	current_grabbed_item.apply_central_impulse(Vector2(side * 300 + velocity.x, min(-100, -100 + get_linear_velocity().y)))
	current_grabbed_item = null
	
	$AudioStreamPlayer2.play(.2)
	$AudioStreamPlayer2.pitch_scale = randf_range(.9, 1.4)
	
func _ready():
	Globals.jester = self
	
	sprite.material.set_shader_parameter("gray_hat", Color("#bdbdbd"))
	sprite.material.set_shader_parameter("gray_body", Color("#bcbdbd"))
	sprite.material.set_shader_parameter("white_hat", Color("#ffffff"))
	sprite.material.set_shader_parameter("white_body", Color("#feffff"))
	sprite.material.set_shader_parameter("color_hat", Color.FIREBRICK)
	sprite.material.set_shader_parameter("color_body", Color.FIREBRICK)
	

func _process(delta):
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		sprite.play("run")
	else:
		sprite.play("idle")

func can_jump():
	return jump_raycast.is_colliding()
	
func is_grounded():
	return ground_raycast.is_colliding()

func update_raycasts_begin():
	ground_raycast_collided = is_grounded()
	ground_raycast_just_collided = true if ground_raycast_collided == true and ground_raycast_collided_last_frame == false else false
	
	jump_raycast_collided = can_jump()
	jump_raycast_just_collided = true if jump_raycast_collided == true and jump_raycast_collided_last_frame == false else false
	
	if ground_raycast_just_collided:
		Events.emit_signal("jester_touched_ground")
	
func update_raycasts_end():
	ground_raycast_collided_last_frame = ground_raycast_collided
	jump_raycast_collided_last_frame = jump_raycast_collided

func _physics_process(delta):
	update_raycasts_begin()
	
	# Get the input direction and handle the movement/deceleration.
	if direction != 0:
		if direction != sign(velocity.x):
			velocity.x = move_toward(velocity.x, direction * SPEED, DEC)
		else:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACC)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DEC)
		
	apply_force(velocity * mass * delta * 100)
	var linear_vel = get_linear_velocity()
	# decelerate
	if direction == 0 && linear_vel.x != 0:
		apply_force(Vector2(sign(linear_vel.x) * -1 * DEC * mass * delta, 0) * 100)
	
	var final_vel = get_linear_velocity()
	final_vel.x = clamp(final_vel.x, -SPEED, SPEED)
	if direction == 0 and abs(final_vel.x) < 2:
		final_vel.x = 0
	set_linear_velocity(final_vel)
	#print(get_linear_velocity())
	
	# Handle jump.
	if Input.is_action_pressed("jump") and can_jump():
		if Time.get_ticks_msec() - last_jump_at > 150:
			set_linear_velocity(Vector2(get_linear_velocity().x, 0))
			apply_impulse(Vector2(0, JUMP_VELOCITY * 50))
			last_jump_at = Time.get_ticks_msec()
			$AudioStreamPlayer3.play()
	
	# update sprite side
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
		
	if velocity.x != 0:
		if not $AudioStreamPlayer4.playing:
			if walking_audio_time:
				$AudioStreamPlayer4.play(walking_audio_time)
			else:
				$AudioStreamPlayer4.play()
	else:
		if $AudioStreamPlayer4.playing:
			walking_audio_time = $AudioStreamPlayer4.get_playback_position()
			$AudioStreamPlayer4.stop()
	
	update_highlighted_item()
	update_raycasts_end()
	
func update_highlighted_item():
	if current_grabbed_item:
		return
		
	var curr_min_dist = 10000000
	var min_sq_distance = ITEM_INTERACT_DISTANCE * ITEM_INTERACT_DISTANCE
	var curr_closest_item = null
	for item: Item in Globals.items_manager.get_items():
		var curr_dist = item.global_position.distance_squared_to(global_position)
		if curr_dist < min_sq_distance:
			if curr_dist < curr_min_dist:
				curr_closest_item = item
				curr_min_dist = curr_dist
	
	if current_highlighted_item:
		current_highlighted_item.unhighlight()
		
	current_highlighted_item = curr_closest_item
	if not current_highlighted_item:
		return
	
	current_highlighted_item.highlight()
