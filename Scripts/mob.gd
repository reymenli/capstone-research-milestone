extends CharacterBody3D

# Min speed of the mob in meters per second
@export var min_speed = 10

# Max speed of the mob in meters per second
@export var max_speed = 18

signal squashed

func _physics_process(_delta):
	move_and_slide()

# func will be called from the main scene
func initialize(start_position, player_position):
	# We position the mob by placing it at start_position
	# and rotate it towards player_position, so it looks at the player.
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Rotate this mob randomly within range of -45 and +45 degrees,
	# so that it doesn't move directly towards the player.
	rotate_y(randf_range(-PI / 4, PI / 4))
	
	# We calculate a random speed (integer)
	var random_speed = randi_range(min_speed, max_speed)
	# We calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# We then rotate the velocity vector based on the mob's Y rotation
	# in order to move in the direction the mob is looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	$AnimationPlayer.speed_scale = random_speed / min_speed

# cosmetic fix
# func initialize(start_position: Vector3, player_position: Vector3) -> void:
#	var target_position: Vector3 = Vector3(player_position.x, start_position.y, player_position.z)
#	look_at_from_position(start_position, target_position, Vector3.UP)

func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()
	
func squash():
	squashed.emit()
	queue_free()
