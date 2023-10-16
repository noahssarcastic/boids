class_name Boid
extends Node2D
## Represents a member of a swarm.
##
## Boids participate in a swarm using swarm behaviors modeled off of the
## SigGraph paper Flocks, Herds, and Schools: A Distributed Behavioral Model
## (https://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/).


## Speed modifier of an individual boid.
@export var speed: float = 100.0
## Cap acceleration
@export var max_acceleration: float = 200.0
## Radius of a boid's sphere of vision.
@export var neighborhood_radius: float = 200.0
# The boid's color.
@export var color: Color = Color.BLUE

@export_group("Collision Avoidance")
## Enable collision-avoidance behavior.
@export var avoid_collisions: bool = true
## Controls the strength of the impulse to avoid collisions.
@export_range(0.0, 1.0) var avoidance_strength: float = 1.0
## Percentage of neighborhood used for calculating possible collisions.
@export_range(0.0, 1.0) var avoidance_radius: float = 0.5

@export_group("Velocity Matching")
## Enable velocity-matching behavior.
@export var match_velocity: bool = true
## Controls the strength of the impulse to match velocity of surrounding boids.
@export_range(0.0, 1.0) var matching_strength: float = 0.5

@export_group("Flock Centering")
## Enable flock-centering behavior.
@export var navigate_to_center: bool = true
## Controls the strength of the impulse to move to the center of the flock.
@export_range(0.0, 1.0) var centering_strength: float = 0.05

## Represents where the boid would like to go, and will trend towards.
var acceleration := Vector2.ZERO

# Sphere collider representing a boid's sphere of vision.
var _neighborhood: Area2D
# Array of other boids within this boid's sphere of vision.
var _visible_boids: Array[Boid] = []

@onready var _sprite := $Sprite2D


func _ready():
	_sprite.modulate = color
	
	_neighborhood = Area2D.new()
	_neighborhood.set_collision_layer(0)
	_neighborhood.set_collision_mask(0)
	_neighborhood.set_collision_mask_value(2, true)
	add_child(_neighborhood)
	
	var neighborhood_collider := CollisionShape2D.new()
	_neighborhood.add_child(neighborhood_collider)
	
	var neighborhood_shape := CircleShape2D.new()
	neighborhood_shape.set_radius(neighborhood_radius)
	neighborhood_collider.shape = neighborhood_shape


func _process(delta):
	_visible_boids = []
	for x in _neighborhood.get_overlapping_areas():
		var posible_boid: Node = x.get_parent()
		if (
			posible_boid != null and 
			posible_boid != self and 
			posible_boid is Boid
		):
			_visible_boids.append(posible_boid)

	var acc_request := Vector2.ZERO
	
	if avoid_collisions:
		var avoidance_acc: Vector2 = _calculate_avoidance_acc()
		acc_request += avoidance_acc
		
	if match_velocity:
		var orienting_acc: Vector2 = _calculate_orienting_acc()
		acc_request += orienting_acc
		
	if navigate_to_center:
		var centering_acc: Vector2 = _calculate_centering_acc()
		acc_request += centering_acc
		
	acceleration = acc_request
	accelerate(acceleration, delta)
		
	translate(get_direction() * speed * delta)
	
	if get_meta("debug"):
		queue_redraw()


func _draw():
	if get_meta("debug"):
		_draw_debug()


func add_acceleration() -> void:
	pass
	

## Get the direction vector of the boid.
func get_direction() -> Vector2:
	return Vector2.UP.rotated(global_rotation)


## Accelerate a boid towards a given desired heading acc.
func accelerate(acc: Vector2, dt: float) -> void:
	if acc.length() > max_acceleration:
		acc *= max_acceleration / acc.length()
	var direction: Vector2 = get_direction()
	var new_direction: Vector2 = direction + acc * dt
	rotate(direction.angle_to(new_direction))


# Calculate the collision avoidance request vector.
func _calculate_avoidance_acc() -> Vector2:
	var acc_request := Vector2.ZERO
	for other_boid in _visible_boids:
		var direction: Vector2 = other_boid.position - position
		if direction.length() > neighborhood_radius * avoidance_radius:
			continue
		var acc_direction: Vector2 = -direction.normalized()
		var acc_strength: float = _inverse_square(
			direction.length() / neighborhood_radius,
		)
		acc_request += acc_direction * acc_strength
	return acc_request * avoidance_strength
	

# Calculate the velocity matching request vector.
func _calculate_orienting_acc() -> Vector2:
	var acc_request := Vector2.ZERO
	for other_boid in _visible_boids:
		acc_request += other_boid.get_direction()
	return acc_request * matching_strength


# Calculate the flock centering request vector.
func _calculate_centering_acc() -> Vector2:
	if _visible_boids.size() < 1:
		return Vector2.ZERO
	var centroid := Vector2.ZERO
	for other_boid in _visible_boids:
		centroid += other_boid.position
	centroid /= _visible_boids.size()
	return (centroid - position) * centering_strength


func _inverse_square(d: float) -> float:
	if d == 0:
		return INF
	return 1.0 / sqrt(d)


func _draw_debug() -> void:
	# Show neighborhood
	draw_circle(Vector2.ZERO, neighborhood_radius, Color(0, 0, 1, 0.2))
	
	# Show acceleration vector
	draw_line(
		Vector2.ZERO, 
		to_local(acceleration * 10 + position), 
		Color.GREEN, 
		5,
	)
	
	if avoid_collisions:
		_draw_possible_collisions()
	
	if match_velocity:
		_draw_surrounding_velocities()
		
	if navigate_to_center:
		_draw_flock_centroid()


func _draw_possible_collisions() -> void:
	draw_circle(
		Vector2.ZERO, 
		neighborhood_radius * avoidance_radius, 
		Color(0, 0, 1, 0.2),
	)
	
	for other_boid in _visible_boids:
		var d: float = (other_boid.position - position).length()
		if d > neighborhood_radius * avoidance_radius:
			continue
		draw_line(
			Vector2.ZERO, 
			to_local(other_boid.position), 
			Color.RED, 
			_inverse_square(d) * 25,
		)


func _draw_surrounding_velocities() -> void:
	for other_boid in _visible_boids:
		draw_line(
			to_local(other_boid.position), 
			to_local(other_boid.position + other_boid.get_direction() * 50),
			Color.BLUE,
			5,
		)


func _draw_flock_centroid() -> void:
	if _visible_boids.size() < 1:
		return
	var centroid := Vector2.ZERO
	for other_boid in _visible_boids:
		centroid += other_boid.position
	centroid /= _visible_boids.size()
	draw_circle(to_local(centroid), 5.0, Color.DARK_ORANGE)
