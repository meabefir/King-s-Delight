extends TextureRect

var resource = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(resource_data):
	resource = resource_data
	
	material.set_shader_parameter("gray", Color("#bdbdbd"))
	material.set_shader_parameter("white", Color("#ffffff"))
	material.set_shader_parameter("width", 1.0)
	material.set_shader_parameter("outline_color", Color("#fbf236"))
	
	texture = resource.sprite
	var col = resource.color
	material.set_shader_parameter("color", resource.color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
