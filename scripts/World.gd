@tool
class_name World
extends Node2D
## Create a bounded world which wraps along the edges.


## How much larger should the sprite be on each edge.
## Used to reset [Boid] position before 
## leaving the bounds of the world's sprite.
const EDGE_PADDING = 40

## The width in pixels of the world.
@export var width = 100.0:
	set(new_width):
		width = new_width
		_update_size()
## The height in pixels of the world.
@export var height = 100.0:
	set(new_height):
		height = new_height
		_update_size()
	
@onready var _collider = $Area2D
@onready var _collision_shape = $Area2D/CollisionShape2D
@onready var _sprite = $Sprite2D


func _ready():
	_update_size()
	_collider.area_exited.connect(_on_world_area_exited)
	

func _on_world_area_exited(area: Area2D) -> void:
	var parent: Node = area.get_parent()
	if parent and parent is Boid:
		_reset_boid(parent)


# Teleport boid to other end of the world.
# This is used to simulate the boundaries of the world "wrapping".
func _reset_boid(boid: Boid) -> void:
	if boid.position.x > position.x + width/2:
		boid.position.x = position.x - width/2
	elif boid.position.x < position.x - width/2:
		boid.position.x = position.x + width/2
	if boid.position.y > position.y + height/2:
		boid.position.y = position.y - height/2
	elif boid.position.y < position.y - height/2:
		boid.position.y = position.y + height/2


# Update the collider and sprite size if the width or height changes.
func _update_size() -> void:
	if _collision_shape:
		_collision_shape.scale = Vector2(width, height)
	if _sprite:
		_sprite.scale = Vector2(width + EDGE_PADDING, height + EDGE_PADDING)
