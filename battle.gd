extends Node2D

# ENUMS — a clean way to define states
# Instead of using numbers (0, 1, 2, 3) we give them readable names
# Now we can write BattleState.PLAYER_TURN instead of just "0"
enum BattleState {
	PLAYER_TURN,
	ENEMY_TURN,
	WIN,
	LOSE
}

# PLAYER STATS — the player's numbers
var player_hp = 30         # current health points
var player_max_hp = 30     # maximum health points
var player_attack = 8      # how much damage player deals

# ENEMY STATS — the enemy's numbers
var enemy_hp = 20          # current health points
var enemy_max_hp = 20      # maximum health points
var enemy_attack = 5       # how much damage enemy deals
var enemy_name = "Slime"   # the enemy's name (String = text)

# CURRENT STATE — what's happening right now in the battle
# We start on the player's turn
var current_state = BattleState.PLAYER_TURN

# REFERENCES to our Label nodes so we can update their text
# @onready means "get this node as soon as the scene is ready"
# $ is a shortcut for "find the child node named..."
@onready var player_hp_label = $PlayerHP
@onready var enemy_hp_label = $EnemyHP
@onready var message_label = $BattleMessage


# _ready() — runs once when battle scene loads
func _ready():
	update_labels()
	message_label.text = enemy_name + " appeared! Press A to attack."


# _process() — runs every frame
func _process(delta):
	
	# Only accept input during the player's turn
	if current_state == BattleState.PLAYER_TURN:
		
		# Press A to attack
		# We use Input.is_action_just_pressed() instead of is_action_pressed()
		# just_pressed = only triggers ONCE when you press the key
		# is_action_pressed = triggers every frame while held — too fast for turns!
		if Input.is_action_just_pressed("ui_accept"):
			player_attack_enemy()


# FUNCTION — player attacks the enemy
func player_attack_enemy():
	
	# randi_range gives a random damage amount
	# So attack isn't always the same — adds variety
	var damage = randi_range(player_attack - 2, player_attack + 2)
	
	# Subtract damage from enemy HP
	enemy_hp -= damage
	
	# Show what happened
	message_label.text = "You attacked " + enemy_name + " for " + str(damage) + " damage!"
	
	# str() converts a number into text so we can display it
	# You can't add a number to text directly — str() fixes that
	
	# Update the HP display
	update_labels()
	
	# Check if the enemy is dead
	# <= means "less than or equal to"
	if enemy_hp <= 0:
		enemy_hp = 0
		win()
		return   # stop here — don't continue to enemy turn
	
	# Enemy is still alive — switch to enemy turn
	current_state = BattleState.ENEMY_TURN
	
	# Wait 1 second then enemy attacks
	# We use a Timer so the player can read the message first
	await get_tree().create_timer(1.0).timeout
	enemy_attack_player()


# FUNCTION — enemy attacks the player
func enemy_attack_player():
	
	var damage = randi_range(enemy_attack - 1, enemy_attack + 1)
	
	player_hp -= damage
	
	message_label.text = enemy_name + " attacked you for " + str(damage) + " damage!"
	
	update_labels()
	
	# Check if player is dead
	if player_hp <= 0:
		player_hp = 0
		lose()
		return
	
	# Player is still alive — back to player's turn
	current_state = BattleState.PLAYER_TURN
	
	# Wait 1 second then show the prompt again
	await get_tree().create_timer(1.0).timeout
	message_label.text = "Your turn! Press Enter to attack."


# FUNCTION — updates the text on screen
func update_labels():
	player_hp_label.text = "Player HP: " + str(player_hp) + " / " + str(player_max_hp)
	enemy_hp_label.text = enemy_name + " HP: " + str(enemy_hp) + " / " + str(enemy_max_hp)


# FUNCTION — player won!
func win():
	current_state = BattleState.WIN
	message_label.text = "You won! Press Enter to return to world."
	
	# Wait for Enter then go back to world
	await get_tree().create_timer(0.5).timeout
	await wait_for_confirm()
	get_tree().change_scene_to_file("res://world.tscn")


# FUNCTION — player lost
func lose():
	current_state = BattleState.LOSE
	message_label.text = "You lost... Press Enter to try again."
	
	await get_tree().create_timer(0.5).timeout
	await wait_for_confirm()
	get_tree().change_scene_to_file("res://world.tscn")


# FUNCTION — waits until the player presses Enter
# This is a coroutine — a function that can pause and resume
func wait_for_confirm():
	while not Input.is_action_just_pressed("ui_accept"):
		await get_tree().process_frame
