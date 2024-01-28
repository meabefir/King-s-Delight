extends RigidBody2D
class_name Item

@onready var sprite_pivot = get_node("sprite_pivot")
@onready var sprite: Sprite2D = get_node("sprite_pivot/Sprite2D")

var resource: ResourceItem = null

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.material.set_shader_parameter("width", 0)

	Events.explode_items.connect(explode)

	$AudioStreamPlayer.pitch_scale = randf_range(.8, 1.2)

func init(resource_data):
	resource = resource_data
	
	sprite.material.set_shader_parameter("gray", Color("#bdbdbd"))
	sprite.material.set_shader_parameter("white", Color("#ffffff"))
	
	sprite.texture = resource.sprite
	sprite.material.set_shader_parameter("color", resource.color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("test"):
		explode()
	# delete when out of bounds
	if global_position.x < -32 or global_position.x > 640 + 32:
		Events.emit_signal("item_despawned")
		queue_free()

func highlight():
	sprite.material.set_shader_parameter("width", 1)

func unhighlight():
	sprite.material.set_shader_parameter("width", 0)

func explode():
	var dir = Vector2(-1, -1)
	if global_position.x > 320:
		dir = Vector2(1, -1)
	dir = dir.normalized()
	
	apply_central_impulse(dir * 1000)
