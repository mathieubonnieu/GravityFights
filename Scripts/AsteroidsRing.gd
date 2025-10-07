extends Node

@export var radius: float = 500
@export var numAsteroids: int = 100
@export var collisionPolygon2D: CollisionPolygon2D = null

var asteroidsSprites: Array[Texture] = []

func _ready() -> void:
	var packedVector2Array = PackedVector2Array()
	var _dir = DirAccess.open("res://Assets/Sprites/asteroids")
	_dir.list_dir_begin()

	while true:
		var file = _dir.get_next()
		if file == "":
			break
		if file.get_extension() == "png":
			asteroidsSprites.append(load("res://Assets/Sprites/asteroids/" + file))
	_dir.list_dir_end()

	for i in range(numAsteroids):
		var asteroid = Sprite2D.new()
		asteroid.texture = asteroidsSprites[randi() % asteroidsSprites.size()]
		asteroid.position = Vector2(radius * cos(i * 2 * PI / numAsteroids) + randi() % 10, radius * sin(i * 2 * PI / numAsteroids) + randi() % 10)
		asteroid.scale = Vector2(randf() * 0.5 + 0.5, randf() * 0.5 + 0.5)
		add_child(asteroid)

		packedVector2Array.push_back(Vector2((radius * 0.95) * cos(i * 2 * PI / numAsteroids), (radius * 0.95) * sin(i * 2 * PI / numAsteroids)))

	collisionPolygon2D.polygon = packedVector2Array

func _process(delta: float) -> void:
	self.rotation += delta * 0.1
