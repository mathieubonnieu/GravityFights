extends RigidBody2D

@onready var fracturableLib = FracturableLib.new()
@onready var _polygon2D = $Polygon2D
@onready var _collisionPolygon2D = $CollisionPolygon2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	if body.name != "SphereBody":
		return
	fracturableLib.Fracture(self, _polygon2D, _collisionPolygon2D)
