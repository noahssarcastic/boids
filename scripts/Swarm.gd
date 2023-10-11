class_name Swarm
extends Node2D
## Spawn a swarm of [Boid].


@export_group("Swarm Settings")
## Number of [Boid]s in the swarm.
@export var size = 100
## Width in pixels of the swarm spawn area.
@export var width = 100.0
## Height in piexls of the swarm spawn area.
@export var height = 100.0

@export_group("Boid Settings")
## Speed modifier of an individual boid.
@export var speed: float = 100.0
## Radius of a boid's sphere of vision.
@export var neighborhood_radius: float = 100.0
## Enable collision-avoidance behavior.
@export var avoid_collisions: bool = false

var _rng = RandomNumberGenerator.new()


func _ready():
	var boid_prefab: Resource = preload("res://scenes/boid.tscn")
	for n in range(size):
		var instance: Boid = boid_prefab.instantiate()
		instance.translate(Vector2(
			position.x+_rng.randf_range(-width/2,width/2), 
			position.y+_rng.randf_range(-height/2,height/2)))
		instance.rotate(_rng.randf_range(0, 2*PI))
		instance.speed = speed
		instance.neighborhood_radius = neighborhood_radius
		instance.avoid_collisions = avoid_collisions
		instance.set_meta("debug", get_meta("debug"))
		add_child(instance)
