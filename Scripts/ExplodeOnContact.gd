extends RigidBody2D

@export var fracture_body_color: Color
@onready var polyFracture := PolygonFracture.new()
@onready var _source_polygon := $Polygon2D
@onready var _pool_fracture_bodies := $Pool_FractureBodies
@onready var _rng := RandomNumberGenerator.new()
@onready var _collider := $CollisionPolygon2D

var _cur_fracture_color : Color = fracture_body_color

var cuts : int = 3 
var min_area : int = 25

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
	collision_mask = 0
	collision_layer = 0
	_source_polygon.visible = false
	var fracture_info : Array
	fracture_info = polyFracture.fractureDelaunay(_source_polygon.polygon, _source_polygon.get_global_transform(), cuts, min_area)
	for entry in fracture_info:
		var texture_info : Dictionary = {"texture" : _source_polygon.texture, "rot" : _source_polygon.texture_rotation, "offset" : _source_polygon.texture_offset, "scale" : _source_polygon.texture_scale}
		spawnFractureBody(entry, texture_info)
		
func spawnFractureBody(fracture_shard : Dictionary, texture_info : Dictionary) -> void:
	var instance = _pool_fracture_bodies.getInstance()
	if not instance: 
		return
	
	instance.spawn(fracture_shard.spawn_pos)
	instance.global_rotation = fracture_shard.spawn_rot
	if instance.has_method("setPolygon"):
		var s : Vector2 = fracture_shard.source_global_trans.get_scale()
		instance.setPolygon(fracture_shard.centered_shape, s)


	instance.setColor(_cur_fracture_color)
	var dir : Vector2 = (fracture_shard.spawn_pos - fracture_shard.source_global_trans.get_origin()).normalized()
	#instance.linear_velocity = dir * _rng.randf_range(0, 10)
	#instance.angular_velocity = _rng.randf_range(-1, 1)

	instance.setTexture(PolygonLib.setTextureOffset(texture_info, fracture_shard.centroid))


func _on_rigid_body_2d_new_version_body_entered(body: Node) -> void:
	pass # Replace with function body.
