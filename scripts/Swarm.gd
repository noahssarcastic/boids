class_name Swarm
extends Node2D
## Spawn a swarm of [Boid].


@export_group("Swarm Settings")
## Number of [Boid]s in the swarm.
@export var size: int = 100
## Width in pixels of the swarm spawn area.
@export var width: float = 100.0
## Height in piexls of the swarm spawn area.
@export var height: float = 100.0

@export_group("Boid Settings")
## Speed modifier of an individual boid.
@export var speed: float = 100.0
## Cap acceleration
@export var max_acceleration: float = 200.0
## Radius of a boid's sphere of vision.
@export var neighborhood_radius: float = 100.0
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

var _rng := RandomNumberGenerator.new()


func _ready():
	var boid_prefab: Resource = preload("res://scenes/boid.tscn")
	for n in range(size):
		var instance: Boid = boid_prefab.instantiate()
		instance.translate(Vector2(
			position.x+_rng.randf_range(-width/2,width/2), 
			position.y+_rng.randf_range(-height/2,height/2)))
		instance.rotate(_rng.randf_range(0, 2*PI))

		instance.speed = speed
		instance.max_acceleration = max_acceleration
		instance.neighborhood_radius = neighborhood_radius
		instance.color = color

		instance.avoid_collisions = avoid_collisions
		instance.avoidance_strength = avoidance_strength
		instance.avoidance_radius = avoidance_radius

		instance.match_velocity = match_velocity
		instance.matching_strength = matching_strength

		instance.navigate_to_center = navigate_to_center
		instance.centering_strength = centering_strength
		
		instance.set_meta("debug", get_meta("debug"))
		
		add_child(instance)
