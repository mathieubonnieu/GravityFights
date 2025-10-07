extends Node

const GRAVITY = 980

func calculate_gravity(object: RigidBody2D, objects_list: Array, delta: float) -> Vector2:
	var final_acceleration = Vector2.ZERO
	for other in objects_list:
		if other != object and other is RigidBody2D:
			var distance = other.global_position.distance_to(object.global_position)
			if distance > 0:
				var force = (GRAVITY * other.mass) / (distance ** 2)
				var direction = (other.global_position - object.global_position).normalized()
				var acceleration = direction * (force / object.mass) * delta * 1000
				final_acceleration += acceleration
	return final_acceleration

func apply_gravity(object: RigidBody2D, objects_list: Array, delta: float, verbose: bool = false) -> void:
	var final_acceleration = calculate_gravity(object, objects_list, delta)
	object.apply_central_force(final_acceleration)
	if verbose:
		print("[GravitySystem] {name} Acceleration = {accel}, Velocity = {velocity}".format({
			"name": object.name,
			"accel": final_acceleration,
			"velocity": object.linear_velocity
		}))

func process_gravity(object: RigidBody2D, object_list: Array, delta: float, verbose: bool = false, isStatic: bool = false) -> void:
	if not isStatic:
		apply_gravity(object, object_list, delta, verbose)
