extends HBoxContainer

@onready var scene_clothing_variant = preload("res://scenes/game/ui_clothing_variant.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.item_used.connect(item_used)
	
	for child in get_children():
		child.queue_free()
	
	for i in range(3):
		var item_resource: ResourceItem = Globals.choose_resource_to_spawn()
		
		var new_variant = scene_clothing_variant.instantiate()
		new_variant.init(item_resource)
		add_child(new_variant)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_cloth_pick_timer_timeout():
	if get_child_count() < 7:
		var item_resource: ResourceItem = Globals.choose_resource_to_spawn()
			
		var new_variant = scene_clothing_variant.instantiate()
		new_variant.init(item_resource)
		add_child(new_variant)

func item_used(item):
	if get_child_count() == 0:
		return
	var first_child = get_children()[0]
	var res = first_child.resource
	if first_child.resource == item:
		Events.emit_signal("amuse_king", Globals.settings["GOOD_ITEM_USE"])
		$"../../AudioStreamPlayer2".play()
	else:
		Events.emit_signal("amuse_king", Globals.settings["BAD_ITEM_USE"])
	first_child.queue_free()
