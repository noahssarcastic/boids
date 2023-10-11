extends Node2D


@export var speed = 100
@export var neighborhood_radius = 50.0


@onready var collider = $Area2D


var direction: Vector2
var neighborhood: Area2D


func _ready():
	direction = Vector2.UP.rotated(rotation)
	
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
	if get_meta("debug"):
		paint_visible()
	translate(direction*speed*delta)


func paint_visible():
	var areas = neighborhood.get_overlapping_areas()
	for a in areas:
		var parent = a.get_parent()
		if not parent or parent == self:
			continue
		if parent.is_in_group("boids"):
			var sprite: Sprite2D = parent.get_node("Sprite2D")
			sprite.set_modulate(Color(0, 1, 0))


func _on_boid_area_exited(area: Area2D):
	if get_meta("debug"):
		var parent = area.get_parent()
		if not parent:
			return
		if parent.is_in_group("boids"):
			var sprite: Sprite2D = parent.get_node("Sprite2D")
			sprite.set_modulate(Color(0, 0, 1))


func sensitivity(d: float):
	return 1.0/sqrt(d)


func _draw():
	if get_meta("debug"):
		draw_circle(position, neighborhood_radius, Color(0, 0, 1, 0.2))
