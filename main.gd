extends Node

@export var mob_scene: PackedScene

# trying to get input from player
@onready var player = $Player
@onready var name_input = $UserInterface/NameInput
@onready var confirm_button = $UserInterface/Confirm

# trying to get health and stamina bars to work
@onready var health_label = $UserInterface/HealthLabel
@onready var health_bar = $UserInterface/HealthBar

@onready var stamina_label = $UserInterface/StaminaLabel 
@onready var stamina_bar = $UserInterface/StaminaBar


func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on the SpawnPath.
	# We store the reference to the SpawnLocation node.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	# And give it a random offset.
	mob_spawn_location.progress_ratio = randf()

	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	
	mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())

func _on_player_hit():
	$MobTimer.stop()
	$UserInterface/Retry.show()
	
func _ready():
	$UserInterface/Retry.hide()
	
	# testing input
	get_tree().paused = true
	$UserInterface.process_mode = Node.PROCESS_MODE_ALWAYS
	#confirm_button.pressed.connect(_on_confirm_pressed)
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()
		
# testing confirm button
func _on_confirm_pressed():
	print("Confirm button pressed")
	var entered_name = name_input.text.strip_edges()
	
	print(entered_name)
	
	if entered_name.is_empty():
		print("please enter name")
		return
	player.set_player_name(entered_name)
	
	name_input.hide()
	confirm_button.hide()
	
	get_tree().paused = false

func _process(delta):
	
	if not is_instance_valid(player):
		return
	health_bar.max_value = player.max_health
	health_bar.value = player.current_health
	
	stamina_bar.max_value = player.max_stamina
	stamina_bar.value = player.stamina
	
