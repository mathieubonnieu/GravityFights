extends RigidBody2D

@export var isStatic = false
@export var verbose = false

var gravityLib = load("res://Scripts/GravityLibrary.gd").new()

func _ready() -> void:
	if verbose:
		print("[GravitySystem] {name} ready".format({"name": self.name}))

func _physics_process(delta: float) -> void:
	gravityLib.process_gravity(self, get_tree().get_nodes_in_group("GravitySystem"), delta, verbose, isStatic)
