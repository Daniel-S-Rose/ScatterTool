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
## The values to randomly rotate this foliage on its Y-Axis by.
@export var rand_rotation := Vector2(-180, 180)
## The values to randomly scale this foliage on all of its axes by.
@export var scale_range := Vector2(1.0, 1.0)
