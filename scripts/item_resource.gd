extends Resource
class_name ResourceItem

enum ITEM_TYPE {
	CLOTHING,
	
}

enum CLOTHING_TYPE {
	HAT,
	COSTUME
}

@export var sprite: Texture2D
@export var item_type: ITEM_TYPE
@export var clothing_type: CLOTHING_TYPE
@export var color: Color
