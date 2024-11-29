@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("ScatterTool", "Node3D",
	preload("res://addons/ScatterTool/scatter_tool.gd"), preload("res://addons/ScatterTool/ScatterTool_Icon.png"))


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
