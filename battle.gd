extends Node2D

# BattleState tracks whose turn it is, or if the battle is over
enum BattleState { PLAYER_TURN, ENEMY_TURN, WIN, LOSE }

var player_hp: int
var player_max_hp: int
var player_attack: int
var enemy_hp: int
var enemy_max_hp: int
var enemy_attack: int
var enemy_name: String
var enemy_xp_reward: int
var enemy_gold_reward: int
var enemy_drops: Array
var in_skill_menu = false
var skill_selected_index = 0
var is_dodging = false
var skill_cooldowns = {}
# Tracks which menu option is highlighted (0 = Attack, 1 = Item)
var menu_index = 0

# Starts as player's turn when battle begins
var current_state = BattleState.PLAYER_TURN

# Constants — fixed values that never change, stored in one place for easy editing
const HP_BAR_WIDTH = 400.0         # Width of a full HP bar in pixels
const PANEL_TEX = "res://assets/panel.png"  # Path to the panel background texture
const SLIME_TEX = "res://assets/slime.png"  # Path to the enemy sprite texture

# @onready grabs each node from the scene tree when the scene loads
# The path must match the exact nesting in the scene: Parent/Child/Grandchild
@onready var enemy_name_label = $EnemyArea/EnemySprite/EnemyName
@onready var enemy_hp_label = $EnemyHpArea/EnemyHpFill/EnemyHpLabel
@onready var enemy_hp_fill = $EnemyHpArea/EnemyHpFill
@onready var player_hp_label = $PlayerArea/PlayerHpFill/PlayerHpLabel
@onready var player_hp_fill = $PlayerArea/PlayerHpFill
@onready var message_label = $MessageBox/Panel/MessageLabel
@onready var attack_option = $BattleMenu/AttackOption
@onready var item_option = $BattleMenu/AttackOption/ItemOption
@onready var enemy_sprite = $EnemyArea/EnemySprite
@onready var sfx_player = $SfxPlayer     # Plays short sound effects
@onready var music_player = $MusicPlayer # Plays longer music tracks

# preload loads the audio files into memory before the scene starts
# This prevents a delay when the sound first plays
var sound_attack = preload("res://assets/audio/sfx/attack_hit.wav")
var sound_damage = preload("res://assets/audio/sfx/damage.wav")
var sound_battle_start = preload("res://assets/audio/sfx/BattleStart.wav")
var sound_victory = preload("res://assets/audio/sfx/victory.wav")


# _ready() runs once when the scene first loads
func _ready():
	# Load player stats from GameData
	player_hp = GameData.current_hp
	player_max_hp = GameData.get_total_max_hp()
	player_attack = GameData.get_total_attack()
	
	# Pick a random enemy
	var enemy_data = Enemies.get_random_enemy()
	enemy_name = enemy_data["name"]
	enemy_hp = enemy_data["max_hp"]
	enemy_max_hp = enemy_data["max_hp"]
	enemy_attack = enemy_data["attack"]
	enemy_xp_reward = enemy_data["xp"]
	enemy_gold_reward = enemy_data["gold"]
	enemy_drops = enemy_data["drops"]
	setup_visuals()
	update_ui()
	message_label.text = enemy_name + " appeared!"
	update_menu()
	set_font_colors()
	sfx_player.stream = sound_battle_start
	sfx_player.play()


# Positions, sizes, and styles every visual element in the scene
func setup_visuals():
	var panel_tex = load(PANEL_TEX) # Load the panel texture to reuse across all panels
	var slime_tex = load(SLIME_TEX)

	# Background — fills the whole screen with a near-black color
	var bg = $Background
	bg.color = Color(0.04, 0.04, 0.04)
	bg.size = Vector2(1152, 648)
	bg.position = Vector2(0, 0)

	# Enemy area — top section, holds the enemy sprite and name
	$EnemyArea.position = Vector2(0, 0)
	setup_panel($EnemyArea/Panel, panel_tex, Vector2(1152, 300))
	enemy_sprite.texture = slime_tex
	enemy_sprite.position = Vector2(576, 150) # Centered horizontally
	enemy_sprite.scale = Vector2(4, 4)        # Scale up so it's visible
	enemy_name_label.position = Vector2(20, 260)
	enemy_name_label.add_theme_font_size_override("font_size", 14)

	# Enemy HP area — thin bar just below the enemy
	$EnemyHpArea.position = Vector2(0, 300)
	setup_panel($EnemyHpArea/Panel, panel_tex, Vector2(1152, 50))
	setup_color_rect($EnemyHpArea/EnemyHpBg, Color(0.1, 0, 0), Vector2(190, 15), Vector2(400, 20))  # Dark red background
	setup_color_rect($EnemyHpArea/EnemyHpFill, Color(0.8, 0, 0), Vector2(190, 15), Vector2(400, 20)) # Bright red fill
	enemy_hp_label.position = Vector2(20, 15)

	# Battle menu — bottom-left, shows Attack and Item options
	$BattleMenu.position = Vector2(0, 350)
	setup_panel($BattleMenu/Panel, panel_tex, Vector2(280, 100))
	attack_option.position = Vector2(20, 15)
	item_option.position = Vector2(20, 50)

	# Message box — fills the rest of the bottom row next to the menu
	$MessageBox.position = Vector2(280, 350)
	setup_panel($MessageBox/Panel, panel_tex, Vector2(872, 100))
	message_label.position = Vector2(20, 20)
	message_label.size = Vector2(830, 70)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD # Wrap long lines automatically

	# Player area — thin strip at the very bottom showing player HP
	$PlayerArea.position = Vector2(0, 450)
	setup_panel($PlayerArea/Panel, panel_tex, Vector2(1152, 60))
	setup_color_rect($PlayerArea/PlayerHpBg, Color(0.1, 0, 0), Vector2(190, 20), Vector2(400, 20))  # Dark red background
	setup_color_rect($PlayerArea/PlayerHpFill, Color(0.8, 0, 0), Vector2(190, 20), Vector2(400, 20)) # Bright red fill
	player_hp_label.position = Vector2(600, 20)


# Helper — applies a texture, size, and position to a panel node
# Called repeatedly so we don't repeat the same 4 lines for every panel
func setup_panel(node, tex, size):
	node.texture = tex
	node.size = size
	node.position = Vector2(0, 0)
	node.stretch_mode = TextureRect.STRETCH_TILE # Tile the texture instead of stretching it


# Helper — sets the color, position, and size of a ColorRect node
# Used for HP bar backgrounds and fills
func setup_color_rect(node, color, pos, size):
	node.color = color
	node.position = pos
	node.size = size


# Applies colors to all text labels to match the battle UI theme
func set_font_colors():
	var red = Color(0.8, 0.0, 0.0)
	var grey = Color(0.8, 0.8, 0.8)
	var dark_red = Color(0.4, 0.0, 0.0)
	enemy_name_label.add_theme_color_override("font_color", red)
	enemy_hp_label.add_theme_color_override("font_color", red)
	player_hp_label.add_theme_color_override("font_color", red)
	message_label.add_theme_color_override("font_color", grey)  # Grey so it's readable on dark background
	attack_option.add_theme_color_override("font_color", red)
	item_option.add_theme_color_override("font_color", dark_red) # Dimmer when not selected


# Updates the arrow to show which menu option is currently highlighted
func update_menu():
	if in_skill_menu:
		# Show skills submenu
		var skills = GameData.known_skills
		attack_option.text = ""
		item_option.text = ""
		# We'll add more labels for skills later
		for i in range(min(skills.size(), 2)):
			var skill = Skills.get_skill(skills[i])
			var cooldown = skill_cooldowns.get(skills[i], 0)
			var label = "  " + skill["name"]
			if cooldown > 0:
				label += " (" + str(cooldown) + ")"
			if i == skill_selected_index:
				label = "->" + label.substr(2)
			if i == 0:
				attack_option.text = label
			else:
				item_option.text = label
	else:
		# Normal menu
		if menu_index == 0:
			attack_option.text = "-> Attack"
			item_option.text = "   Skills"
		else:
			attack_option.text = "   Attack"
			item_option.text = "-> Skills"


# _process() runs every frame — used only to listen for player input during their turn
func _process(_delta):
	if current_state == BattleState.PLAYER_TURN:
		if Input.is_action_just_pressed("ui_up"):
			if in_skill_menu:
				skill_selected_index = max(0, skill_selected_index - 1)
			else:
				menu_index = 0
			update_menu()
		if Input.is_action_just_pressed("ui_down"):
			if in_skill_menu:
				skill_selected_index = min(GameData.known_skills.size() - 1, skill_selected_index + 1)
			else:
				menu_index = 1
			update_menu()
		if Input.is_action_just_pressed("ui_cancel"):
			if in_skill_menu:
				in_skill_menu = false
				update_menu()
		if Input.is_action_just_pressed("ui_accept"):
			if in_skill_menu:
				use_skill()
			else:
				if menu_index == 0:
					player_attack_enemy()
				elif menu_index == 1:
					in_skill_menu = true
					skill_selected_index = 0
					update_menu()



func use_item():
	in_skill_menu = false
	
	# Check if player has any consumables
	if GameData.consumables.is_empty():
		message_label.text = "You have nothing to use!"
		return
	
	# For now use the first available consumable
	# Later we'll add a submenu to pick which one
	var item_id = GameData.consumables.keys()[0]
	var item = Items.get_item(item_id)
	
	if item == null:
		return
	
	GameData.remove_consumable(item_id)
	
	match item["effect"]:
		"heal":
			player_hp = min(player_hp + item["value"], player_max_hp)
			message_label.text = "Used " + item["name"] + "! +" + str(item["value"]) + " HP."
		
		"heal_and_buff":
			player_hp = min(player_hp + item["value"], player_max_hp)
			GameData.active_buffs["attack_buff"] = item["attack_buff"]
			GameData.active_buffs["buff_turns"] = item["buff_turns"]
			message_label.text = "Used " + item["name"] + "! +" + str(item["value"]) + " HP and ATK up!"
		
		"attack_buff":
			GameData.active_buffs["attack_buff"] = item["attack_buff"]
			GameData.active_buffs["buff_turns"] = item["buff_turns"]
			message_label.text = "Used " + item["name"] + "! ATK doubled for " + str(item["buff_turns"]) + " turns!"
		
		"escape":
			message_label.text = "You vanish into the smoke..."
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://world.tscn")
			return
	
	update_ui()
	current_state = BattleState.ENEMY_TURN
	await get_tree().create_timer(1.0).timeout
	enemy_attack_player()
	# Reduce attack buff duration
	if GameData.active_buffs["buff_turns"] > 0:
		GameData.active_buffs["buff_turns"] -= 1
		if GameData.active_buffs["buff_turns"] == 0:
			GameData.active_buffs["attack_buff"] = 0
			message_label.text = "Attack buff wore off."


# Player attacks — damage is randomized around the base attack value
func player_attack_enemy():
	var damage = randi_range(player_attack - 2, player_attack + 2) # Random int in range
	enemy_hp -= damage
	message_label.text = "You attacked " + enemy_name + " for " + str(damage) + " damage!"
	sfx_player.stream = sound_attack
	sfx_player.play()
	update_ui()
	if enemy_hp <= 0:
		enemy_hp = 0
		update_ui()
		win()
		return # Stop here — don't let the enemy take a turn after dying
	current_state = BattleState.ENEMY_TURN
	await get_tree().create_timer(1.0).timeout
	enemy_attack_player()
	


# Enemy attacks — same pattern as the player but with smaller stat ranges
func use_skill():
	var skill_id = GameData.known_skills[skill_selected_index]
	var skill = Skills.get_skill(skill_id)
	
	# Check cooldown
	if skill_cooldowns.get(skill_id, 0) > 0:
		message_label.text = skill["name"] + " is on cooldown!"
		return
	
	# Set cooldown
	skill_cooldowns[skill_id] = skill["cooldown"]
	in_skill_menu = false
	
	match skill["type"]:
		"damage":
			var damage = randi_range(player_attack - 2, player_attack + 2)
			damage = int(damage * skill["multiplier"])
			enemy_hp -= damage
			message_label.text = "Power Strike! " + str(damage) + " damage!"
			sfx_player.stream = sound_attack
			sfx_player.play()
			update_ui()
			if enemy_hp <= 0:
				enemy_hp = 0
				update_ui()
				win()
				return
			current_state = BattleState.ENEMY_TURN
			await get_tree().create_timer(1.0).timeout
			enemy_attack_player()
		
		"heal":
			player_hp = min(player_hp + skill["heal_amount"], player_max_hp)
			message_label.text = "Patched up! +" + str(skill["heal_amount"]) + " HP."
			update_ui()
			current_state = BattleState.ENEMY_TURN
			await get_tree().create_timer(1.0).timeout
			enemy_attack_player()
		
		"dodge":
			is_dodging = true
			message_label.text = "You slip into the shadows..."
			current_state = BattleState.ENEMY_TURN
			await get_tree().create_timer(1.0).timeout
			enemy_attack_player()


# Update enemy_attack_player to check dodge
func enemy_attack_player():
	# Check if player is dodging
	if is_dodging:
		is_dodging = false
		message_label.text = enemy_name + " missed! You stepped aside."
		update_ui()
		current_state = BattleState.PLAYER_TURN
		await get_tree().create_timer(1.0).timeout
		if current_state == BattleState.PLAYER_TURN:
			message_label.text = "Your turn! Choose an action."
		return
	
	var damage = randi_range(enemy_attack - 1, enemy_attack + 1)
	
	# Reduce damage by defense
	damage = max(1, damage - GameData.get_total_defense())
	
	player_hp -= damage
	message_label.text = enemy_name + " attacked for " + str(damage) + " damage!"
	sfx_player.stream = sound_damage
	sfx_player.play()
	update_ui()
	
	# Reduce cooldowns each enemy turn
	for skill_id in skill_cooldowns:
		if skill_cooldowns[skill_id] > 0:
			skill_cooldowns[skill_id] -= 1
	
	if player_hp <= 0:
		player_hp = 0
		update_ui()
		lose()
		return
	
	current_state = BattleState.PLAYER_TURN
	await get_tree().create_timer(1.0).timeout
	if current_state == BattleState.PLAYER_TURN:
		message_label.text = "Your turn! Choose an action."


# Syncs all visible UI elements to match the current HP values
func update_ui():
	# Calculate HP as a 0.0–1.0 ratio to scale the HP bar width
	var enemy_ratio = float(max(0, enemy_hp)) / float(enemy_max_hp)
	var player_ratio = float(player_hp) / float(player_max_hp)
	# Multiply ratio by full bar width — clamp prevents it going negative or over 100%
	enemy_hp_fill.size.x = HP_BAR_WIDTH * clamp(enemy_ratio, 0.0, 1.0)
	player_hp_fill.size.x = HP_BAR_WIDTH * clamp(player_ratio, 0.0, 1.0)
	# Update text labels
	enemy_name_label.text = enemy_name
	enemy_hp_label.text = "HP: " + str(max(0, enemy_hp)) + "/" + str(enemy_max_hp)
	player_hp_label.text = "HP: " + str(player_hp) + "/" + str(player_max_hp)


# Called when enemy HP hits 0 — plays victory music and returns to world
func win():
	current_state = BattleState.WIN
	GameData.current_hp = player_hp
	
	var level_before = GameData.level
	GameData.gain_xp(enemy_xp_reward)
	GameData.gold += enemy_gold_reward
	
	# Declare msg FIRST
	var msg = "Another one down...\nEXP +" + str(enemy_xp_reward) + "  Gold +" + str(enemy_gold_reward)
	
	# THEN the for loop that uses msg
	for item_id in enemy_drops:
		if not GameData.inventory.has(item_id):
			GameData.inventory.append(item_id)
			var item = Items.get_item(item_id)
			msg += "\nFound a " + item["name"] + "!"
	
	GameData.save()
	
	if GameData.level > level_before:
		msg += "\nYou level up. You're now level " + str(GameData.level) + "."
	
	message_label.text = msg
	music_player.stream = sound_victory
	music_player.play()
	await get_tree().create_timer(0.5).timeout
	await wait_for_confirm()
	get_tree().change_scene_to_file("res://world.tscn")


# Called when player HP hits 0 — shows lose message and returns to world
func lose():
	current_state = BattleState.LOSE
	GameData.current_hp = 1
	GameData.save()
	message_label.text = "You got gravely injured...\n Press Enter to try again."
	await get_tree().create_timer(0.5).timeout
	await wait_for_confirm()
	get_tree().change_scene_to_file("res://world.tscn")


# Holds the game at the end screen until the player presses Enter
# process_frame pauses one frame per loop so Godot doesn't freeze
func wait_for_confirm():
	while not Input.is_action_just_pressed("ui_accept"):
		await get_tree().process_frame
