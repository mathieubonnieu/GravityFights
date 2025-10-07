extends CharacterBody2D

@export var speed = 10
@export var bullet_prefab: PackedScene = preload("res://Prefabs/Bullet.tscn")
@export var device_id: int = 0
@export var player_id: int = 0
@export var is_freeze: bool = false

signal shoot(bullet: PackedScene, direction: Vector2, location: Vector2, shooter_id: int)

var PLAYERS_SPRITES = [
	preload("res://Assets/Sprites/ships/blue.png"),
	preload("res://Assets/Sprites/ships/brown.png"),
	preload("res://Assets/Sprites/ships/gray.png"),
	preload("res://Assets/Sprites/ships/purple.png")
]
const PLAYERS_COLORS = [[Vector3(0.0, 0.5, 0.8), Vector3(0.2, 0.8, 2.5)], [Vector3(0.0, 0.2, 0.0), Vector3(1.60, 0.8, 0.2)]]
const RECOIL_TIME = 0.2
var is_recoilling = false

func _ready() -> void:
	$RecoilTimer.wait_time = RECOIL_TIME


func _process(_delta: float) -> void:
	if is_freeze == false && Input.is_action_just_pressed("first_shoot_%d"%self.device_id):
		first_shoot()

func first_shoot():
	if bullet_prefab == null:
		print("No bullet prefab assigned ;-;")
		return
	if is_recoilling == true:
		return
	shoot.emit(bullet_prefab, rotation, position, player_id)
	is_recoilling = true
	$RecoilTimer.start();

func _physics_process(delta: float):
	if not is_freeze:
		move_player(delta)
	
func move_player(delta: float):
	var acceleration = Vector2.ZERO

	acceleration = Input.get_vector("move_left_%d"%self.device_id, "move_right_%d"%self.device_id, "move_up_%d"%self.device_id, "move_down_%d"%self.device_id)
	acceleration = acceleration.normalized() * speed
	velocity += acceleration
	rotation = velocity.angle() + PI / 2
	velocity -= delta * velocity / 2
	move_and_slide()

func death():
	print("player %d died"%self.device_id)
	self.queue_free()

func set_device_id(new_device_id: int) -> void:
	self.device_id = new_device_id
	return

func set_player_id(new_player_id: int) -> void:
	self.player_id = new_player_id

	var material := self.get_node("Flames").material as Material
	if material:
		self.get_node("Flames").material = material.duplicate()
		material = self.get_node("Flames").material
		material.set_shader_parameter("RemapValueA", PLAYERS_COLORS[(player_id) % len(PLAYERS_COLORS)][0])
		material.set_shader_parameter("RemapValueB", PLAYERS_COLORS[(player_id) % len(PLAYERS_COLORS)][1])
	else:
		print("Should not append")
	var sprite = Sprite2D.new()
	sprite.texture = PLAYERS_SPRITES[player_id % PLAYERS_SPRITES.size()]
	sprite.scale = Vector2(1.5, 1.5)
	add_child(sprite)
	return


func _on_recoil_timer_timeout() -> void:
	is_recoilling = false
