@tool
extends Node2D


@onready var collider = $Area2D
@onready var collision_shape = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D


var edge_padding = 40


@export var width = 100.0:
	set(new_width):
		width = new_width
		update_size()


@export var height = 100.0:
	set(new_height):
		height = new_height
		update_size()


func _ready():
	update_size()
	collider.area_exited.connect(_on_world_area_exited)
	

func _on_world_area_exited(area: Area2D):
	var parent = area.get_parent()
	if parent and parent.is_in_group("boids"):
		reset_boid(parent)


func reset_boid(boid: Node2D):
	if boid.position.x > position.x + width/2:
		boid.position.x = position.x - width/2
	elif boid.position.x < position.x - width/2:
		boid.position.x = position.x + width/2
	if boid.position.y > position.y + height/2:
		boid.position.y = position.y - height/2
	elif boid.position.y < position.y - height/2:
		boid.position.y = position.y + height/2


func update_size():
	if collision_shape:
		collision_shape.scale = Vector2(width, height)
	if sprite:
		sprite.scale = Vector2(width+edge_padding, height+edge_padding)
