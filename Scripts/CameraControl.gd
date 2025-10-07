extends Camera2D

var zoom_factor: float = 600.0
var max_zoom: float = 2.0
var min_zoom: float = 0.1

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("Player")

	if len(players) == 0:
		position = Vector2(576, 324)
		return
	
	moving(players)
	zooming(players)

func zooming(players: Array) -> void:
	var longest_dist: float = 100

	for player in players:
		for other_player in players:
			if player == other_player:
				continue
			var dist =	player.position.distance_to(other_player.position)
			longest_dist = max(longest_dist, dist)
	var z = zoom_factor / longest_dist
	z = clamp(z, min_zoom, max_zoom)
	self.zoom = Vector2(z, z)

func moving(players: Array) -> void:
	var average_pos = Vector2.ZERO

	for player in players:
		average_pos += player.position
	average_pos /= len(players)
	position = position.lerp(average_pos, 0.1)
