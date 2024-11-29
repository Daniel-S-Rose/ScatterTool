extends Resource
class_name ObjectData
## This resource is used by the Scatter Tool to spawn objects with or without collision in levels.


## The name of the object.
@export var object_name: String = ""
## The mesh of the object.
@export var mesh: Mesh
## The collision shape to be used by the object.
@export var collision_shape: Shape3D
## Determines whether or not to generate collisions for this object.
@export var generate_collisions: bool = true
## The amount of this object to spawn.
@export var num: int = 0: set = _set_num
func _set_num(value: int) -> void:
	if value >= 0:
		num = value
