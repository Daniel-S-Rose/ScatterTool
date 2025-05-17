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
## The values to randomly rotate this foliage on its Y-Axis by.
@export var rand_rotation := Vector2(-180, 180)
## The values to randomly scale this foliage on all of its axes by.
@export var scale_range := Vector2(1.0, 1.0)
