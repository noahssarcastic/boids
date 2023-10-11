extends Node2D


@export var speed: float = 100
@export var neighborhood_radius: float = 100
@export var avoid_collisions: bool = false


@onready var collider: Area2D = $Area2D


var neighborhood: Area2D
var visible_boids: Array[Node2D] = []
var acceleration: Vector2 = Vector2.ZERO


func _ready():
	neighborhood = Area2D.new()
	neighborhood.set_collision_layer(0)
	neighborhood.set_collision_mask(0)
	neighborhood.set_collision_mask_value(2, true)
	neighborhood.area_exited.connect(_on_boid_area_exited)
	add_child(neighborhood)
	
	var neighborhood_collider = CollisionShape2D.new()
	neighborhood.add_child(neighborhood_collider)
	
	var neighborhood_shape = CircleShape2D.new()
	neighborhood_shape.set_radius(neighborhood_radius)
	neighborhood_collider.shape = neighborhood_shape


func _process(delta):
	visible_boids = []
	for x in neighborhood.get_overlapping_areas():
		var posible_boid = x.get_parent()
		if posible_boid != null and posible_boid != self and posible_boid.is_in_group("boids"):
			visible_boids.append(posible_boid)

	if avoid_collisions:
		var acc_request = Vector2.ZERO
		for other_boid in visible_boids:
			var direction = other_boid.position - position
			var acc_direction = -(direction.normalized())
			var acc_strength = sensitivity(direction.length()/neighborhood_radius)
			acc_request += acc_direction*acc_strength
		accelerate(acc_request, delta)
		acceleration = acc_request
		
	translate(get_direction()*speed*delta)
	
	if get_meta("debug"):
		queue_redraw()
		paint_visible()


func get_direction():
	return Vector2.UP.rotated(rotation)


func accelerate(acc: Vector2, dt: float):
	var direction = get_direction()
	var new_direction = direction + acc*dt
	rotate(direction.angle_to(new_direction))


func paint_visible():
	for other_boid in visible_boids:
		var sprite = other_boid.get_node("Sprite2D")
		sprite.set_modulate(Color(0, 1, 0))


func _on_boid_area_exited(area: Area2D):
	if get_meta("debug"):
		var area_parent = area.get_parent()
		if area_parent and area_parent.is_in_group("boids"):
			var other_boid = area_parent
			var sprite: Sprite2D = other_boid.get_node("Sprite2D")
			sprite.set_modulate(Color(0, 0, 1))


func sensitivity(d: float):
	if d == 0:
		return INF
	return 1.0/sqrt(d)


func _draw():
	if get_meta("debug"):
		draw_debug()


func draw_debug():
	var global_to_local: Transform2D = get_global_transform().affine_inverse()
	
	draw_circle(Vector2.ZERO, neighborhood_radius, Color(0, 0, 1, 0.2))
	
	draw_line(Vector2.ZERO, acceleration.normalized()*100, Color.GREEN, 5)
	
	for other_boid in visible_boids:
		var d = (other_boid.position - position).length()
		draw_line(Vector2.ZERO, global_to_local*other_boid.position, Color.RED, sensitivity(d)*25)
