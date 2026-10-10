extends CharacterBody3D

# How fast the player moves in meters per second
@export var speed = 14

# The downward acceleration when in the air, in meter per second squared. 
@export var fall_acceleration = 75

# veritical impulse when they jump in meters per sec
@export var jump_impulse = 20

# vertical impulse applied to the charcater upon bouncing over a mob in meters per sec
@export var bounce_impulse = 16

var target_verlocity = Vector3.ZERO

signal hit

# player health
@export var max_health = 100
@export var current_health = max_health
@export var damage_amount = 20

# player stamina
@export var max_stamina = 100.0
@export var stamina = max_stamina
@export var sprint_drain_rate = 25.0
@export var stamina_recovery_rate = 20.0
@export var can_sprint = true

# speed modifiations
@export var sprint_speed = 24.0
@export var current_speed = speed

# player name
@export var player_name = "Player"
@onready var name_label = $player_name

# use _physics_process instead for regular _process because it is designed specifically for physics related code. 
# REASON: It's designed specifically for physics-related code like moving a kinematic or rigid body. It updates the node using fixed time intervals.
# IMPORTANT FOR OUR GAME
func _physics_process(delta):
	# create local variable to store the input directino. 
	var direction = Vector3.ZERO
	
	# check each for each move input and update the direciton accordingly. 
	if Input.is_action_pressed("move_right"):
		direction.x+= 1
	if Input.is_action_pressed("move_left"):
		direction.x-= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1 
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if direction != Vector3.ZERO: 
		direction = direction.normalized()
		# Setting the basis property will affect the rotation fo the node
		$Pivot.basis = Basis.looking_at(direction)
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1
	
	
	
	if Input.is_action_pressed("sprint") and can_sprint and stamina > 0.0:
		current_speed = sprint_speed
	else: 
		current_speed = speed
	
	target_verlocity.x = direction.x * current_speed
	target_verlocity.z = direction.z * current_speed
	
	# Vertical velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Gravity
		target_verlocity.y = target_verlocity.y - (fall_acceleration * delta)
	
	# Moving the character
	velocity = target_verlocity
	move_and_slide()
	
	# jumpoping
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_verlocity.y = jump_impulse
	
	# iterate through all collision that occured this frame
	for index in range(get_slide_collision_count()):
		# get one of the collision with the player
		var collision = get_slide_collision(index)
		# prevent dupe collisions
		# first collision dequeue mob from scene 
		# dupe collisions will return null bc they are not on the scene anymore
		if collision.get_collider() == null:
			continue
		# case where mob is the collision
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# if it is a mob, squash and bounce
				mob.squash()
				target_verlocity.y = bounce_impulse
				# prevent duplicate calls
				break
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse
	
	if Input.is_action_pressed("sprint") and can_sprint:
		stamina -= sprint_drain_rate * delta
	else:
		stamina += stamina_recovery_rate * delta
	
	stamina = clamp(stamina, 0.0, max_stamina)
	
	if stamina <= 0.0: 
		can_sprint = false
	if stamina >= max_stamina:
		can_sprint = true

func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(_body):
	# player now has a hp bar and will die after 5 hits
	current_health -= damage_amount
	if current_health <= 0:
		die()

func set_player_name(new_name: String):
	player_name = new_name
	name_label.text = player_name
