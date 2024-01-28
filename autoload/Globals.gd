extends Node

var items_manager: ItemsManager = null
var spectators_manager: SpectatorsManager = null
var jester: Jester = null
var king: King = null

var settings = {}

func load_settings():
	var json_as_text = FileAccess.get_file_as_string("res://settings.json")
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		settings = json_as_dict
		return
		
	printerr("settings file not loaded")
	get_tree().quit()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	load_settings()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func choose_resource_to_spawn():
	var roll = randf()
	for item_cat in resources:
		if roll <= item_cat["odds"]:
			var roll2 = randf()
			for item_info in item_cat["resources"]:
				if roll <= item_info[1]:
					return item_info[0]
					
	assert(1 != 1)

var resources = [
	# clothing
	{
		"resources": [
			[preload("res://resources/item_blue_hat.tres"), .16],	
			[preload("res://resources/item_green_hat.tres"), .32],	
			[preload("res://resources/item_red_hat.tres"), .48],	
			[preload("res://resources/item_orange_suit.tres"), .64],	
			[preload("res://resources/item_purple_suit.tres"), .8],	
			[preload("res://resources/item_teal_suit.tres"), 1],	
		],
		"odds": 1
	},
	# usable
	{
		
	}
]
