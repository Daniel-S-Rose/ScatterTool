@tool
extends Node3D
class_name ScatterTool
## This class is designed to help populate a level with foliage, objects with or without collision, and scenes, rather than having to place them
## by hand. It has variables exposed to allow for customization of meshes, rotation, etc.


@export_category("Scatter Settings")
## Clears any spawned nodes, and runs the scatter function.
@export var update: bool = false
## Clears any spawned Nodes.
@export var clear: bool = false
## Determines the range at which this Node will spawn child Nodes.
@export var scatter_range: float = 20.0
## Determines how close together spawned Nodes can be.
@export var instance_distance: float = 0.5
## Determines how far this Node must be moved in the Editor before clearing any spawned nodes, and running the scatter function.
@export var update_distance: float = 0.5
## The data used to drive this Nodes core functionality. This variable must be set in order to achieve any results with this Node.
@export var scatter_data: ScatterData:
	set(value):
		scatter_data = value
		_get_configuration_warnings()
## Used by this Node to determine whether or not to updated when moved in the Editor.
var location: Vector3: set = _set_location
## Used by this Node to determine child Node naming.
var foliage_meshes: Dictionary = {}
## Used by this Node to determine child Node naming.
var object_meshes: Dictionary = {}
## Used by this Node to determine child Node naming.
var scenes: Dictionary = {}
func _set_location(value: Vector3) -> void:
	if Engine.is_editor_hint():
		if value.x >= location.x + update_distance\
		or value.z >= location.z + update_distance\
		or value.y >= location.y + update_distance\
		or value.x <= location.x - update_distance\
		or value.z <= location.z - update_distance\
		or value.y <= location.y - update_distance:
			location = value
			update = true


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if update:
			update = false
			_clear()
			await get_tree().create_timer(0.01).timeout
			scatter()
		
		if clear:
			clear = false
			_clear()
		
		location = self.position


## Runs through the scatter data and creates a multimesh for each of its valid stored Foliage and Object datas.
## Then it will use the multimesh to spawn Nodes equal to the amount set in the Foliage or Object data,
## and update each mutlimesh instance's position based on the scatter range value. Then if random rotation is true,
## it will set the multimesh instance's Y rotation to a random value between -180 and 180.
## Then if generate collisions is true, a static body and collision shape are created for each ObjectData,
## with the collision shape based on the value of collision shape in ObjectData.
## For each of its valid stored Scene datas it will instantiate the scene value and add it as a child Node.
## Then it will update the child's position based on the scatter range value,
## and if random rotation is true, it will set the nodes Y rotation to a random value between -180 and 180.
func scatter() -> void:
	if scatter_data:
		if scatter_data.foliage_data:
			for d in scatter_data.foliage_data:
				create_multimesh(d)
		
		if scatter_data.object_data:
			for d in scatter_data.object_data:
				create_multimesh(d)
			
		
		if scatter_data.scene_data:
			for d in scatter_data.scene_data:
				create_scene_instance(d)
	else:
		push_error("ERROR - Scatter Data is Null. Scatter Data must have a value.")


## Queue_Frees all child Nodes and clears the naming dictionaries.
func _clear() -> void:
	foliage_meshes.clear()
	object_meshes.clear()
	scenes.clear()
	
	for child in get_children():
		child.queue_free()


## Returns true if the two positions distance from each other is less than the instance_distance value.
func too_close(p1: Vector3, p2: Vector3) -> bool:
	var dist: float = sqrt(pow(p2.x - p1.x, 2) + pow(p2.z - p1.z, 2))
	if dist < instance_distance:
		return true
	return false


## Creates a multimesh for the passed FoliageData or ObjectData value.
func create_multimesh(data) -> void:
	var multimesh := MultiMeshInstance3D.new()
	multimesh.multimesh = MultiMesh.new()
	if data is FoliageData:
		var success: bool = false
		for child in get_children():
			if child.name == "MM_Foliage_%s" %data.foliage_name:
				success = true
				break
		if success:
			multimesh.name = "MM_Foliage_%s_" %data.foliage_name + str(foliage_meshes[data.foliage_name])
			foliage_meshes[data.foliage_name] += 1
		else:
			multimesh.name = "MM_Foliage_%s" %data.foliage_name
			foliage_meshes[data.foliage_name] = 1
		
	elif data is ObjectData:
		var success: bool = false
		for child in get_children():
			if child.name == "MM_Object_%s" %data.object_name:
				success = true
				break
		if success:
			multimesh.name = "MM_Object_%s_" %data.object_name + str(object_meshes[data.object_name])
			object_meshes[data.object_name] += 1
		else:
			multimesh.name = "MM_Object_%s" %data.object_name
			object_meshes[data.object_name] = 1
	
	add_child(multimesh)
	multimesh.owner = self.owner
	multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.multimesh.mesh = data.mesh
	multimesh.multimesh.instance_count = data.num
	var pos: Vector3 = Vector3.ZERO
	
	for n in data.num:
		var success: bool = false
		while not success:
			pos = Vector3(randf_range(-scatter_range, scatter_range), 0, randf_range(-scatter_range, scatter_range))
			var origin: Vector3 = self.global_position + (pos + Vector3(0, 200, 0))
			var destination: Vector3 = self.global_position + (pos - Vector3(0, 200, 0))
			var phys_query := PhysicsRayQueryParameters3D.create(origin, destination)
			phys_query.collide_with_areas = true
			var intersection = get_world_3d().direct_space_state.intersect_ray(phys_query)
			if not intersection.is_empty():
				if not intersection["collider"].is_in_group("excluded"):
					pos.y = intersection.position.y - self.global_position.y
					success = true
		
		var rand_scale := float(randf_range(data.scale_range.x, data.scale_range.y))
		multimesh.multimesh.set_instance_transform(n,
		Transform3D(self.basis.rotated(self.basis.y, deg_to_rad(randf_range(data.rand_rotation.x, data.rand_rotation.y))).scaled(Vector3(rand_scale, rand_scale, rand_scale)), pos))
		
		if data is FoliageData:
			continue
		elif data.generate_collisions:
			var body := StaticBody3D.new()
			add_child(body)
			body.position = pos
			body.owner = self.owner
			var col := CollisionShape3D.new()
			body.add_child(col)
			col.shape = data.collision_shape
			col.owner = body.owner


## Instantiates a scene for the passed SceneData value.
func create_scene_instance(data: SceneData) -> void:
	var pos := Vector3.ZERO
	var last_instance_name: String = ""
	for n in data.num:
		var instance = data.scene.instantiate()
		var success: bool = false
		while not success:
			pos = Vector3(randf_range(-scatter_range, scatter_range), 0, randf_range(-scatter_range, scatter_range))
			var origin: Vector3 = self.global_position + (pos + Vector3(0, 50, 0))
			var destination: Vector3 = self.global_position + (pos - Vector3(0, 50, 0))
			var phys_query := PhysicsRayQueryParameters3D.create(origin, destination)
			var intersection = get_world_3d().direct_space_state.intersect_ray(phys_query)
			if not intersection.is_empty():
				if not intersection["collider"].is_in_group("excluded"):
					pos.y = intersection.position.y - self.global_position.y
					success = true
		
		if last_instance_name == "":
			last_instance_name = instance.name
			scenes[instance.name] = 1
		else:
			if instance.name == last_instance_name:
				var num: int = scenes[instance.name]
				instance.name = instance.name + "_" + str(num)
				scenes[last_instance_name] += 1
		
		add_child(instance)
		instance.owner = self.owner
		instance.position = pos
		instance.rotation.y = randf_range(data.rand_rotation.x, data.rand_rotation.y)
		var rand_scale: float = randf_range(data.scale_range.x, data.scale_range.y)
		instance.scale = Vector3(rand_scale, rand_scale, rand_scale)


## Used to push a node configuration warning if the scatter_data variable is not set.
func _get_configuration_warnings() -> PackedStringArray:
	if not scatter_data:
		return ["Warning - Scatter Data is Null. Scatter Data must have a value for this Node to Function"]
	else:
		return []
