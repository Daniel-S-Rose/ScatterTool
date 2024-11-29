extends Resource
class_name ScatterData
## This resource is used by the Scatter Tool to determine what foliage, objects, and scenes to spawn in levels.


## The data used to drive Foliage spawning.
@export var foliage_data: Array[FoliageData] = []
## The data used to drive Object spawning.
@export var object_data: Array[ObjectData] = []
## The data used to drive Scene Instantiation.
@export var scene_data: Array[SceneData] = []
