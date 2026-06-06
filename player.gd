extends CharacterBody2D

# VARIABLES
# =========

const TILE_SIZE = 16
var is_moving = false
var target_position = Vector2.ZERO
var move_speed = 17.0

# NEW — tracks how many steps the player has taken on grass
var steps_on_grass = 0

# NEW — how many steps before we check for a battle
# Every 3 steps on grass we roll for an encounter
const STEPS_BEFORE_CHECK = 3

# NEW — percentage chance of battle (20 = 20% chance)
const ENCOUNTER_CHANCE = 20


# _ready() — runs once at the start
func _ready():
	target_position = global_position


# _physics_process() — runs 60 times per second
func _physics_process(delta):
	
	# Smoothly slide to the target tile
	global_position = global_position.lerp(target_position, delta * move_speed)

	# Only read input if we're not already moving
	if not is_moving:
		var direction = Vector2.ZERO
		
		if Input.is_action_pressed("ui_right"):
			direction = Vector2(1, 0)
		elif Input.is_action_pressed("ui_left"):
			direction = Vector2(-1, 0)
		elif Input.is_action_pressed("ui_down"):
			direction = Vector2(0, 1)
		elif Input.is_action_pressed("ui_up"):
			direction = Vector2(0, -1)
		
		if direction != Vector2.ZERO:
			target_position = global_position + direction * TILE_SIZE
			is_moving = true

	# Check if we've arrived at the target tile
	if global_position.distance_to(target_position) < 1.0:
		global_position = target_position
		
		# Only run this the moment we arrive (is_moving was true)
		if is_moving:
			is_moving = false
			# NEW — every time we land on a tile, check for encounter
			check_for_encounter()


# NEW FUNCTION — checks if a battle should start
# ================================================
func check_for_encounter():
	
	# Count this step
	steps_on_grass += 1
	
	# Only check for battle every X steps
	# The % symbol means "remainder" — steps_on_grass % 3 is 0 every 3 steps
	if steps_on_grass % STEPS_BEFORE_CHECK != 0:
		return   # return means "stop this function here, do nothing"
	
	# randi_range() picks a random whole number between 1 and 100
	var roll = randi_range(1, 100)
	
	# Print the roll so we can see it in the Output panel
	print("Encounter roll: ", roll)
	
	# If the roll is within our encounter chance, start a battle!
	if roll <= ENCOUNTER_CHANCE:
		print("Battle triggered!")
		start_battle()


# NEW FUNCTION — switches to the battle scene
# =============================================
func start_battle():
	# get_tree() gives us access to the whole game
	# change_scene_to_file() swaps the current scene for another one
	# "res://" means "starting from my project folder"
	get_tree().change_scene_to_file("res://battle.tscn")
