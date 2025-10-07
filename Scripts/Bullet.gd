extends RigidBody2D

var ShooterName: String
var shooter_id: int

signal kill_player(shooter_id: int, killed_id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1

func _explode():
	queue_free()

func _on_body_entered(body: Node) -> void:
	var groups = body.get_groups()

	if body.name != ShooterName:
		if "Player" in groups :
			kill_player.emit(shooter_id, body.player_id)
		_explode()

func _on_destroy_timer_timeout() -> void:
	queue_free()
