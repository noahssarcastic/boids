class_name Boid
extends Node2D
## Represents a member of a swarm.
##
## Boids participate in a swarm using swarm behaviors modeled off of the
## SigGraph paper Flocks, Herds, and Schools: A Distributed Behavioral Model
## (https://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/).


## Speed modifier of an individual boid.
@export var speed: float = 100.0
## Radius of a boid's sphere of vision.
@export var neighborhood_radius: float = 100.0
# The boid's color.
@export var color: Color = Color.BLUE
## Enable collision-avoidance behavior.
@export var avoid_collisions: bool = false

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

	if avoid_collisions:
		var avoidance_acc: Vector2 = _calculate_avoidance_acc()
		accelerate(avoidance_acc, delta)
		acceleration = avoidance_acc
		
	translate(get_direction()*speed*delta)
	
	if get_meta("debug"):
		queue_redraw()


func _draw():
	if get_meta("debug"):
		_draw_debug()


## Get the direction vector of the boid.
func get_direction() -> Vector2:
	return Vector2.UP.rotated(rotation)


## Accelerate a boid towards a given desired heading acc.
func accelerate(acc: Vector2, dt: float) -> void:
	var direction: Vector2 = get_direction()
	var new_direction: Vector2 = direction + acc*dt
	rotate(direction.angle_to(new_direction))


# Calculate the collision avoidance request vector.
func _calculate_avoidance_acc() -> Vector2:
	var acc_request := Vector2.ZERO
	for other_boid in _visible_boids:
		var direction: Vector2 = other_boid.position - position
		var acc_direction: Vector2 = -(direction.normalized())
		var acc_strength: float = _inverse_square(
			direction.length()/neighborhood_radius,
		)
		acc_request += acc_direction*acc_strength
	return acc_request


func _inverse_square(d: float) -> float:
	if d == 0:
		return INF
	return 1.0/sqrt(d)


func _draw_debug() -> void:
	var global_to_local: Transform2D = get_global_transform().affine_inverse()
	
	# Show neighborhood
	draw_circle(Vector2.ZERO, neighborhood_radius, Color(0, 0, 1, 0.2))
	
	# Show acceleration vector
	draw_line(Vector2.ZERO, acceleration.normalized()*100, Color.GREEN, 5)
	
	# Show possible collisions
	for other_boid in _visible_boids:
		var d: float = (other_boid.position - position).length()
		draw_line(
			Vector2.ZERO, 
			global_to_local*other_boid.position, 
			Color.RED, 
			_inverse_square(d)*25,
		)
