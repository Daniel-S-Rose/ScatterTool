extends Resource
class_name SceneData
## This resource is used by the Scatter Tool to instantiate scenes in levels.


## The scene to be instantiated.
@export var scene: PackedScene
## How many of the scene specified in the scene variable to instantiate.
@export var num: int = 0: set = _set_num
func _set_num(value: int) -> void:
	if value >= 0:
		num = value
