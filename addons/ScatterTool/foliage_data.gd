extends Resource
class_name FoliageData
## This resource is used by the Scatter Tool to spawn foliage in levels.


## The name of the foliage.
@export var foliage_name: String = ""
## The mesh of the foliage.
@export var mesh: Mesh
## The amount of this foliage to spawn.
@export var num: int = 0: set = _set_num
func _set_num(value: int) -> void:
	if value >= 0:
		num = value
