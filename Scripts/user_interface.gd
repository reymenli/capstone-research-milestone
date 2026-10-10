extends Control

# added functionality to main
#func _ready():
#	process_mode = Node.PROCESS_MODE_ALWAYS
#	get_tree().paused = true
#	
#func _on_confirm_button_pressed():
#	var entered_name = $NameInput.text.strip_edges()
#	
#	if entered_name.is_empty:
#		return
#	
#	var player = get_tree().current_scene.get_node("Player")
#	player.set_player_name(entered_name)
#	
#	$NameInput.hide()
#	$Confirm.hide()
#	
#	get_tree().paused = false
