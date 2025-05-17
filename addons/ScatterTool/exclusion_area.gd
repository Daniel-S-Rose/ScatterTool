extends Area3D
class_name ExclusionArea


var collision: CollisionShape3D


func _ready() -> void:
	if Engine.is_editor_hint():
		if not is_in_group("excluded"):
			add_to_group("excluded")
		
		for child in get_children():
			if child is CollisionShape3D:
				collision = child
		
		if not collision:
			collision = CollisionShape3D.new()
			add_child(collision)
			collision.owner = get_tree().edited_scene_root
			collision.name = "ExclusionCollision"
			collision.shape = CylinderShape3D.new()
