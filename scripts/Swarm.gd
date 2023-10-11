extends Node2D


@export var size = 100
@export var width = 100.0
@export var height = 100.0


var rng = RandomNumberGenerator.new()


func _ready():
	var boid_prefab = preload("res://scenes/boid.tscn")
	for n in range(size):
		var instance = boid_prefab.instantiate()
		instance.translate(Vector2(
			position.x+rng.randf_range(-width/2,width/2), 
			position.y+rng.randf_range(-height/2,height/2)))
		instance.rotate(rng.randf_range(0, 2*PI))
		add_child(instance)
